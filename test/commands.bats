#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034

# shellcheck source=test/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

bats_require_minimum_version 1.5.0

setup() {
  harness_setup
  for name in $(compgen -v EXTRACT_REVAMPED_) KODOUGU_THEME KODOUGU_ACCENT NO_COLOR; do
    unset "${name}"
  done
}

tool() {
  # shellcheck disable=SC2086
  run ${REVAMPED_TEST_SHELL:-sh} "${REVAMPED_TESTS_DIR}/../bin/extract-revamped" "$@"
}

plain_tty() {
  local shell_words
  read -r -a shell_words <<<"${REVAMPED_TEST_SHELL:-sh}"
  run python3 "${REVAMPED_TESTS_DIR}/on_tty.py" "${shell_words[@]}" "${REVAMPED_TESTS_DIR}/../bin/extract-revamped"
}

@test "commands - list prints every binding apply would make" {
  # Arrange
  local command=list

  # Act
  tool "${command}"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "bind-key M-x display-popup -E -w 80% -h 60% '"*"/bin/extract-revamped' insert" ]]
}

@test "commands - list --json prints one JSON object" {
  # Arrange
  export EXTRACT_REVAMPED_KEY=none

  # Act
  tool list --json

  # Assert
  [[ "${output}" == '{"bindings":[]}' ]]
}

@test "commands - an option in both forms wins over the environment" {
  # Arrange
  export EXTRACT_REVAMPED_KEY=a EXTRACT_REVAMPED_POPUP_WIDTH=10%

  # Act
  tool --key=b --popup-width 50% list

  # Assert
  [[ "${output}" == "bind-key b display-popup -E -w 50% -h 60% "* ]]
}

@test "commands - apply sends the plan in one tmux call and prints nothing" {
  # Arrange
  export REVAMPED_TEST_TMUX_ARGV="${BATS_TEST_TMPDIR}/argv"

  # Act
  # shellcheck disable=SC2086
  run --separate-stderr ${REVAMPED_TEST_SHELL:-sh} "${REVAMPED_TESTS_DIR}/../bin/extract-revamped" apply

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
  run grep -c '^bind-key|M-x|display-popup|-E|-w|80%|-h|60%|' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "1" ]]
}

@test "commands - the menu applies the keys and counts them" {
  # Arrange
  harness_hide gum

  # Act
  plain_tty <<<"2"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Applied. 1 keys are bound."* ]]
}

@test "commands - the menu runs doctor" {
  # Arrange
  harness_hide gum

  # Act
  plain_tty <<<"3"

  # Assert
  [[ "${output}" =~ tmux\ +ok ]]
}

@test "commands - an unknown option is a usage error even without a value" {
  # Arrange
  local option=--colour

  # Act
  tool "${option}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "extract-revamped: unknown option '--colour'. run 'extract-revamped help' for usage." ]]
}

@test "commands - an unknown option with a value is a usage error" {
  # Arrange
  local option=--colour=red

  # Act
  tool "${option}" list

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "extract-revamped: unknown option '--colour'. run 'extract-revamped help' for usage." ]]
}

@test "commands - a setting option without its value is a usage error" {
  # Arrange
  local option=--lines

  # Act
  tool list "${option}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "extract-revamped: option '--lines' needs a value. run 'extract-revamped help' for usage." ]]
}

@test "commands - a single-dash option is a usage error" {
  # Arrange
  local option=-x

  # Act
  tool "${option}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "extract-revamped: unknown option '-x'. run 'extract-revamped help' for usage." ]]
}

@test "commands - --json with any command but list is a usage error" {
  # Arrange
  local flag=--json

  # Act
  tool "${flag}" apply

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "extract-revamped: option '--json' works only with list. run 'extract-revamped help' for usage." ]]
}

@test "commands - -- ends the options" {
  # Arrange
  local command=list

  # Act
  tool --theme nord -- "${command}"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" == bind-key\ * ]]
}

@test "commands - an inherited guard variable of the plugin is ignored" {
  # Arrange
  export EXTRACT_REVAMPED_EXTRACT_LOADED=1 EXTRACT_REVAMPED_CORE_LOADED=1

  # Act
  tool version

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" =~ ^extract-revamped\ [0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "commands - a pick command without a pane reads the client's active pane" {
  # Arrange
  harness_hide gum
  tmux_answer '#{pane_id}' %7

  # Act
  tool insert

  # Assert
  [[ "${status}" -eq 0 ]]
  run grep -c '^capture-pane -p -t %7 -S -200$' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
}

@test "commands - doctor reports a missing picker and a key someone else holds" {
  # Arrange
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  printf '#!/bin/sh\nif [ "$1" = list-keys ]; then printf "%%s\\n" "bind-key -T prefix M-x display-message mine"; exit 0; fi\nexec "%s/bin/tmux" "$@"\n' "${REVAMPED_TESTS_DIR}" >"${BATS_TEST_TMPDIR}/stubs/tmux"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/tmux"
  harness_hide fzf xdg-open open pbcopy wl-copy xclip xsel base64

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" =~ fzf\ +missing ]]
  [[ "${output}" =~ opener\ +warn ]]
  [[ "${output}" =~ clipboard\ +warn ]]
  [[ "${output}" =~ base64\ +warn ]]
  [[ "${output}" =~ prefix\ M-x\ +warn\ +already\ bound ]]
}
