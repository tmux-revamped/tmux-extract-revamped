#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2088

# shellcheck source=test/extract_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/extract_helpers.bash"

@test "pick - the picked token is typed into the pane as literal text" {
  # Arrange
  screen 'deploy https://example.com/x now'
  option mode urls
  fzf_answers 'https://example.com/x'

  # Act
  lib_run extract 'extract_revamped_pick insert %1'

  # Assert
  run grep -c '^capture-pane -p -t %1 -S -200$' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
  run grep -c '^send-keys -t %1 -l -- https://example.com/x$' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
  run cat "${BATS_TEST_TMPDIR}/fzf.args"
  [[ "${output}" == "--no-sort --reverse --height=100%" ]]
}

@test "pick - several marked tokens are typed joined by spaces" {
  # Arrange
  screen 'one two three'
  option mode words
  option multi 1
  fzf_answers $'one\nthree'

  # Act
  lib_run extract 'extract_revamped_pick insert %1'

  # Assert
  run grep -c '^send-keys -t %1 -l -- one three$' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
  run cat "${BATS_TEST_TMPDIR}/fzf.args"
  [[ "${output}" == *"--multi" ]]
}

@test "pick - an empty screen or a cancelled picker types nothing" {
  # Arrange
  screen ''
  fzf_answers ''

  # Act
  lib_run extract 'extract_revamped_pick insert %1; printf "a b" >"${BATS_TEST_TMPDIR}/screen"; extract_revamped_pick insert %1'

  # Assert
  [[ "${status}" -eq 0 ]]
  run grep -c '^send-keys' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "0" ]]
}

@test "pick - navigate searches the escaped token backward in copy-mode" {
  # Arrange
  screen 'error at a.b[1]'
  option mode words
  fzf_answers 'a.b[1]'

  # Act
  lib_run extract 'extract_revamped_pick navigate %1'

  # Assert
  run grep -c '^copy-mode -t %1 ; send-keys -t %1 -X search-backward a\\.b\\\[1\\\]$' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
}

@test "pick - open hands a URL to the opener" {
  # Arrange
  screen 'see https://a.io/x'
  option mode urls
  fzf_answers 'https://a.io/x'
  stub_command xdg-open

  # Act
  lib_run extract 'extract_revamped_pick open %1'

  # Assert
  run stub_calls xdg-open
  [[ "${output}" == "https://a.io/x" ]]
}

@test "pick - open falls back to the macOS opener" {
  # Arrange
  screen 'see https://a.io/y'
  option mode urls
  fzf_answers 'https://a.io/y'
  stub_command open
  harness_hide xdg-open

  # Act
  lib_run extract 'extract_revamped_pick open %1'

  # Assert
  run stub_calls open
  [[ "${output}" == "https://a.io/y" ]]
}

@test "pick - open sends a path to the editor in a new window at the pane's folder" {
  # Arrange
  screen 'edit ~/notes/a b.md and src/x.c'
  option mode paths
  fzf_answers '~/notes/a'
  export HOME="${BATS_TEST_TMPDIR}/home" EDITOR=nano

  # Act
  lib_run extract 'extract_revamped_pick open %1'

  # Assert
  run grep -c "^new-window -c ${BATS_TEST_TMPDIR} -- sh -c set -f; exec \$1 \"\$2\" extract-revamped nano ${BATS_TEST_TMPDIR}/home/notes/a$" "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
}

@test "pick - open types a token that is neither a URL nor a path" {
  # Arrange
  screen 'word'
  option mode words
  fzf_answers 'word'

  # Act
  lib_run extract 'extract_revamped_pick open %1'

  # Assert
  run grep -c '^send-keys -t %1 -l -- word$' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
}

@test "pick - copy uses the clipboard tool, in the family's order" {
  # Arrange
  screen 'token'
  option mode words
  fzf_answers 'token' -- 'token' -- 'token' -- 'token'
  stub_command pbcopy
  stub_command wl-copy
  stub_command xclip
  stub_command xsel

  # Act
  lib_run extract 'REVAMPED_TEST_UNAME_S=Darwin extract_revamped_pick copy %1; REVAMPED_TEST_UNAME_S=Linux; export REVAMPED_TEST_UNAME_S; extract_revamped_pick copy %1; rm -f "${BATS_TEST_TMPDIR}/stubs/wl-copy"; hash -r; extract_revamped_pick copy %1; rm -f "${BATS_TEST_TMPDIR}/stubs/xclip"; hash -r; extract_revamped_pick copy %1'

  # Assert
  run cat "${BATS_TEST_TMPDIR}/pbcopy.calls" "${BATS_TEST_TMPDIR}/wl-copy.calls" "${BATS_TEST_TMPDIR}/xclip.calls" "${BATS_TEST_TMPDIR}/xsel.calls"
  [[ "${output}" == $'--selection clipboard -in\n--clipboard --input' || "${output}" == $'-selection\nclipboard\n-in\n--clipboard\n--input' ]]
}

@test "pick - copy without a clipboard tool says so and fails" {
  # Arrange
  screen 'token'
  option mode words
  fzf_answers 'token'
  harness_hide pbcopy wl-copy xclip xsel

  # Act
  lib_run extract 'REVAMPED_TEST_UNAME_S=Linux extract_revamped_pick copy %1'

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"extract-revamped: no clipboard tool found, so nothing was copied. install pbcopy, wl-copy, xclip or xsel, or set @extract_revamped_osc52 to 1."* ]]
}

@test "pick - copy with OSC 52 prints the sequence instead" {
  # Arrange
  screen 'token'
  option mode words
  option osc52 1
  fzf_answers 'token'

  # Act
  lib_run extract 'extract_revamped_pick copy %1 2>/dev/null | od -An -c | tr -s " " | tr -d "\n"'

  # Assert
  [[ "${output}" == " 033 ] 5 2 ; c ; d G 9 r Z W 4 = \\a" ]]
}

@test "pick - frecency records the pick, newest first and at most twenty" {
  # Arrange
  screen 'alpha beta'
  option mode words
  option frecency 1
  local recent
  recent=$(awk 'BEGIN { for (n = 1; n <= 25; n++) print "old" n }')
  option recent "${recent}"
  fzf_answers 'beta'

  # Act
  lib_run extract 'extract_revamped_pick insert %1'

  # Assert
  run cat "${REVAMPED_TEST_TMUX_DIR}/g.-._extract_revamped_recent"
  [[ "${lines[0]}" == "beta" ]]
  [[ "${#lines[@]}" -eq 20 ]]
}

@test "pick - all-panes reads every pane of the window in one tmux call" {
  # Arrange
  screen 'x'
  option scope all-panes
  option mode words
  cat >"${BATS_TEST_TMPDIR}/stubs/tmux" <<EOF
#!/bin/sh
case "\$1" in
list-panes) printf '%%1\n%%2\n' ;;
capture-pane)
  printf '%s\n' "\$*" >>"${REVAMPED_TEST_TMUX_LOG}"
  printf 'from-%s\n' "\$4" "\${11}"
  ;;
*) exec "${REVAMPED_TESTS_DIR}/bin/tmux" "\$@" ;;
esac
EOF
  fzf_answers ''

  # Act
  lib_run extract 'extract_revamped_pick insert %1'

  # Assert
  run cat "${BATS_TEST_TMPDIR}/fzf.input"
  [[ "${output}" == $'from-%1\nfrom-%2' ]]
  run grep -c '^capture-pane -p -t %1 -S -200 ; capture-pane -p -t %2 -S -200$' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
}

@test "pick - last-log reads the newest file in the log folder" {
  # Arrange
  screen 'x'
  option scope last-log
  option mode words
  option log_dir "${BATS_TEST_TMPDIR}/logs"
  mkdir -p "${BATS_TEST_TMPDIR}/logs"
  printf 'older\n' >"${BATS_TEST_TMPDIR}/logs/a.log"
  touch -t 202601010000 "${BATS_TEST_TMPDIR}/logs/a.log"
  printf 'newer\n' >"${BATS_TEST_TMPDIR}/logs/b.log"
  fzf_answers ''

  # Act
  lib_run extract 'extract_revamped_pick insert %1; EXTRACT_REVAMPED_S_log_dir="${BATS_TEST_TMPDIR}/none"; extract_revamped_newest "${EXTRACT_REVAMPED_S_log_dir}"'

  # Assert
  run cat "${BATS_TEST_TMPDIR}/fzf.input"
  [[ "${output}" == "newer" ]]
}

@test "pick - last-log defaults to the logging folder under home" {
  # Arrange
  screen 'x'
  option scope last-log
  option mode words
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}/.tmux/logging-revamped"
  printf 'logged\n' >"${HOME}/.tmux/logging-revamped/x.log"
  fzf_answers ''

  # Act
  lib_run extract 'extract_revamped_pick insert %1'

  # Assert
  run cat "${BATS_TEST_TMPDIR}/fzf.input"
  [[ "${output}" == "logged" ]]
}

@test "choose - C-n moves to the next mode, then Enter types the pick" {
  # Arrange
  screen 'go https://a.io/x'
  fzf_answers '' 'ctrl-n' 'https://a.io/x' -- '' 'https://a.io/x'
  printf '%s\n' 'ctrl-n' 'https://a.io/x' -- '' 'https://a.io/x' >"${BATS_TEST_TMPDIR}/fzf-answers"

  # Act
  lib_run extract 'extract_revamped_pick choose %1'

  # Assert
  run cat "${BATS_TEST_TMPDIR}/fzf.args"
  [[ "${lines[0]}" == *"--expect=ctrl-o,ctrl-y,ctrl-n --header all: "* ]]
  [[ "${lines[1]}" == *"--header urls: "* ]]
  run grep -c '^send-keys -t %1 -l -- https://a.io/x$' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
}

@test "choose - C-o opens and C-y copies the pick" {
  # Arrange
  screen 'https://a.io/x'
  printf '%s\n' 'ctrl-o' 'https://a.io/x' -- 'ctrl-y' 'https://a.io/x' >"${BATS_TEST_TMPDIR}/fzf-answers"
  fzf_answers_keep=1
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  cp "${BATS_TEST_TMPDIR}/fzf-answers" "${BATS_TEST_TMPDIR}/answers.keep"
  fzf_answers x
  cp "${BATS_TEST_TMPDIR}/answers.keep" "${BATS_TEST_TMPDIR}/fzf-answers"
  stub_command xdg-open
  stub_command wl-copy
  harness_hide pbcopy

  # Act
  lib_run extract 'REVAMPED_TEST_UNAME_S=Linux; export REVAMPED_TEST_UNAME_S; extract_revamped_pick choose %1; extract_revamped_pick choose %1'

  # Assert
  run stub_calls xdg-open
  [[ "${output}" == "https://a.io/x" ]]
  [[ -f "${BATS_TEST_TMPDIR}/wl-copy.calls" ]]
}

@test "choose - an empty screen, a cancel or a key alone ends it" {
  # Arrange
  screen ''
  fzf_answers 'ctrl-y'

  # Act
  lib_run extract 'extract_revamped_pick choose %1; printf "a" >"${BATS_TEST_TMPDIR}/screen"; extract_revamped_pick choose %1; extract_revamped_pick choose %1'

  # Assert
  [[ "${status}" -eq 0 ]]
  run grep -c '^send-keys' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "0" ]]
}

@test "choose - the rounds are bounded when every answer changes the mode" {
  # Arrange
  screen 'https://a.io/b'
  fzf_answers x
  awk 'BEGIN { for (i = 0; i < 20; i++) { print "ctrl-n"; print "https://a.io/b"; print "--" } }' >"${BATS_TEST_TMPDIR}/fzf-answers"

  # Act
  lib_run extract 'extract_revamped_pick choose %1'

  # Assert
  [[ "${status}" -eq 0 ]]
  run cat "${BATS_TEST_TMPDIR}/fzf.round"
  [[ "${output}" == "12" ]]
}

@test "extract - the keys around a bad one are still bound" {
  # Arrange
  refuse
  option open_key BAD
  export REVAMPED_TEST_TMUX_ARGV="${BATS_TEST_TMPDIR}/argv"

  # Act
  lib_run extract extract_revamped_apply

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"unknown key: BAD"* ]]
  run grep -c '|;|' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "0" ]]
  run grep -c '^bind-key\|^set-option' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" -ge 1 ]]
}

@test "extract - a quoted value survives the shell with its hash, quote and spaces, and carries no hash" {
  # Arrange
  export PROBE_TEXT="a#b it's #1  two"

  # Act
  lib_run extract 'quoted=$(extract_revamped_quote "${PROBE_TEXT}"); printf "%s\n" "${quoted}"; eval "printf \"%s\\n\" ${quoted}"'

  # Assert
  [[ "${lines[0]}" != *"#"* ]]
  [[ "${lines[1]}" == "a#b it's #1  two" ]]
}

@test "extract - what a pick reads rides on the picker keys when it came from the command line or environment" {
  # Arrange
  option open_key o
  export EXTRACT_REVAMPED_SCOPE=all-panes EXTRACT_REVAMPED_MODE=urls EXTRACT_REVAMPED_POPUP_WIDTH=50% EXTRACT_REVAMPED_CUSTOM_REGEX="id#[0-9]+"

  # Act
  lib_run extract 'extract_revamped_plan; extract_revamped_lines_of_plan'

  # Assert
  [[ "${lines[0]}" == "bind-key M-x display-popup -E -w 50% -h 60% '"*"/bin/extract-revamped' --mode 'urls' --scope 'all-panes' --custom-regex 'id'\"\$(printf '%b' '\\0043')\"'[0-9]+' insert" ]]
  [[ "${lines[1]}" == *"/bin/extract-revamped' --mode 'urls' --scope 'all-panes' --custom-regex "*" open" ]]
  [[ "${output}" != *"#"* ]]
}

@test "extract - a setting from a tmux option stays off the keys, and doctor carries none" {
  # Arrange
  option mode urls
  option doctor_key D
  export EXTRACT_REVAMPED_MIN_LENGTH=4

  # Act
  lib_run extract 'extract_revamped_plan; extract_revamped_lines_of_plan'

  # Assert
  [[ "${lines[0]}" == *"/bin/extract-revamped' --min-length '4' insert" ]]
  [[ "${lines[1]}" == *"/bin/extract-revamped' doctor; read -r extract_revamped_wait" ]]
}
