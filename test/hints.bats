#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2088

# shellcheck source=test/extract_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/extract_helpers.bash"

hints_for() {
  export PROBE_SCREEN="$1" PROBE_ITEMS="$2"
  lib_run extract 'extract_revamped_hints_plan "${PROBE_SCREEN}" "${PROBE_ITEMS}"'
}

hint_pick() {
  export EXTRACT_REVAMPED_PICKER=hints PROBE_KEYS="$1"
  lib_run extract "printf '%s' \"\${PROBE_KEYS}\" | extract_revamped_pick $2 %1"
}

plan_lines() {
  lib_run extract 'extract_revamped_plan; extract_revamped_lines_of_plan'
}

@test "hints - each token on the screen gets a letter in reading order, drawn over its first character" {
  # Arrange
  local screen=$'see lib/a.sh\nand https://a.io/x here'
  export NO_COLOR=1

  # Act
  hints_for "${screen}" $'https://a.io/x\nlib/a.sh'

  # Assert
  [[ "${lines[0]}" == $'M\ta\tlib/a.sh' ]] || false
  [[ "${lines[1]}" == $'M\ts\thttps://a.io/x' ]] || false
  [[ "${lines[2]}" == $'S\tsee \e[7ma\e[0m\e[1mib/a.sh\e[0m' ]] || false
  [[ "${lines[3]}" == $'S\tand \e[7ms\e[0m\e[1mttps://a.io/x\e[0m here' ]] || false
  [[ "${#lines[@]}" -eq 4 ]]
}

@test "hints - with colour, the letter is highlighted, the token bold and the rest dimmed" {
  # Arrange
  local screen='go lib/a.sh now'
  unset NO_COLOR

  # Act
  hints_for "${screen}" 'lib/a.sh'

  # Assert
  [[ "${lines[1]}" == $'S\t\e[2mgo \e[0m\e[1;30;43ma\e[0m\e[1;33mib/a.sh\e[0m\e[2m now\e[0m' ]]
}

@test "hints - a token shown twice carries one letter in both places" {
  # Arrange
  local screen=$'main ahead\nback to main'
  export NO_COLOR=1

  # Act
  hints_for "${screen}" 'main'

  # Assert
  [[ "${lines[0]}" == $'M\ta\tmain' ]] || false
  [[ "${lines[1]}" == $'S\t\e[7ma\e[0m\e[1main\e[0m ahead' ]] || false
  [[ "${lines[2]}" == $'S\tback to \e[7ma\e[0m\e[1main\e[0m' ]] || false
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "hints - a token inside a longer word is left alone, and the longer token wins an overlap" {
  # Arrange
  local screen='plugin in lib/in'
  export NO_COLOR=1

  # Act
  hints_for "${screen}" $'in\nlib/in'

  # Assert
  [[ "${lines[0]}" == $'M\ta\tin' ]] || false
  [[ "${lines[1]}" == $'M\ts\tlib/in' ]] || false
  [[ "${lines[2]}" == $'S\tplugin \e[7ma\e[0m\e[1mn\e[0m \e[7ms\e[0m\e[1mib/in\e[0m' ]]
}

@test "hints - past twenty-six tokens every letter pair is two keys, and a one-character token gets none" {
  # Arrange
  local screen items
  items=$(printf 'w%s\n' 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27)
  screen="x ${items//$'\n'/ }"
  export NO_COLOR=1

  # Act
  hints_for "${screen}" $'x\n'"${items}"

  # Assert
  [[ "${lines[0]}" == $'M\taa\tw01' ]] || false
  [[ "${lines[25]}" == $'M\tam\tw26' ]] || false
  [[ "${lines[26]}" == $'M\tsa\tw27' ]] || false
  [[ "${lines[27]}" == $'S\tx \e[7maa\e[0m\e[1m1\e[0m \e[7mas\e[0m\e[1m2\e[0m '* ]] || false
  [[ "${#lines[@]}" -eq 28 ]]
}

@test "hints - typing a token's letter types that token into the pane" {
  # Arrange
  screen 'see lib/a.sh and https://a.io/x'
  option mode urls
  export NO_COLOR=1

  # Act
  hint_pick a insert

  # Assert
  untraced
  [[ "${output}" == $'\e[?25l\e[H\e[2Jsee lib/a.sh and \e[7ma\e[0m\e[1mttps://a.io/x\e[0m' ]] || false
  run grep -c '^send-keys -t %1 -l -- https://a.io/x$' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
}

@test "hints - a second letter picks among more than twenty-six tokens" {
  # Arrange
  local words
  words=$(printf 'w%s ' 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27)
  screen "${words}"
  option mode words

  # Act
  hint_pick sa insert

  # Assert
  run grep '^send-keys' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "send-keys -t %1 -l -- w27" ]]
}

@test "hints - any other key, or no token on the screen, picks nothing" {
  # Arrange
  screen 'see https://a.io/x'
  option mode urls

  # Act
  hint_pick Q insert

  # Assert
  [[ "${status}" -eq 0 ]]
  run grep -c '^send-keys' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "0" ]]
}

@test "hints - a screen with nothing to pick draws nothing" {
  # Arrange
  screen 'plain words only'
  option mode urls

  # Act
  hint_pick a insert

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}

@test "hints - the chooser keeps fzf" {
  # Arrange
  screen 'see https://a.io/x'
  option mode urls
  fzf_answers '' 'https://a.io/x'

  # Act
  hint_pick a choose

  # Assert
  run grep -c '^send-keys -t %1 -l -- https://a.io/x$' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
}

@test "hints - the picker keys open a borderless popup the size of the pane, and the chooser its usual one" {
  # Arrange
  option picker hints
  option open_key O
  option chooser_key G
  export REVAMPED_TEST_TMUX_VERSION=3.6

  # Act
  plan_lines

  # Assert
  [[ "${lines[0]}" == "bind-key M-x run-shell tmux display-popup -c '#{client_name}' -E -B -x '##{popup_pane_left}' -y '##{popup_pane_bottom}' -w '#{pane_width}' -h '#{pane_height}' ''\\''"*"/bin/extract-revamped'\\'' --picker hints insert'" ]] || false
  [[ "${lines[1]}" == "bind-key O run-shell tmux display-popup -c "*"/bin/extract-revamped'\\'' --picker hints open'" ]] || false
  [[ "${lines[2]}" == "bind-key G display-popup -E -w 80% -h 60% '"*"/bin/extract-revamped' choose" ]]
}

@test "hints - before tmux 3.3, which has no borderless popup, the keys keep fzf" {
  # Arrange
  option picker hints
  export REVAMPED_TEST_TMUX_VERSION=3.2

  # Act
  plan_lines

  # Assert
  [[ "${output}" == "bind-key M-x display-popup -E -w 80% -h 60% '"*"/bin/extract-revamped' insert" ]]
}
