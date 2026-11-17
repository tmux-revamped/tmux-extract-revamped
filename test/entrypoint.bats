#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/tmux_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/tmux_helpers.bash"

bats_require_minimum_version 1.5.0

setup() {
  ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  setup_tmux_server
  PANE=$(tmux display-message -p -t test '#{pane_id}')
  HOST="${TMUX_SOCKET}-host"
  mkdir -p "${BATS_TEST_TMPDIR}/stubs" "${BATS_TEST_TMPDIR}/home"
  tmux respawn-pane -k -t "${PANE}" "env -i PATH='${PATH}' HOME='${BATS_TEST_TMPDIR}/home' PS1='$ ' TERM=xterm sh"
  wait_for typed '$'
}

teardown() {
  command tmux -S "${HOST}" kill-server 2>/dev/null || :
  rm -f "${HOST}"
  teardown_tmux_server
}

load_plugin() {
  local quoted
  quoted=$(printf '%s' "$1" | sed "s/'/'\\\\''/g")
  tmux run-shell "'${quoted}/extract-revamped.tmux'"
}

key_binding() {
  local table
  table=$(tmux list-keys -T prefix)
  awk -v key="$1" '{ for (i = 1; i < NF; i++) { if ($i == "-T") { if ($(i + 2) == key) { print } break } } }' <<<"${table}"
}

answer() {
  printf '%s\n' "$1" >"${BATS_TEST_TMPDIR}/fzf.answer"
  printf '#!/bin/sh\ncat >/dev/null\ncat "%s"\n' "${BATS_TEST_TMPDIR}/fzf.answer" >"${BATS_TEST_TMPDIR}/stubs/fzf"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fzf"
}

tool() {
  # shellcheck disable=SC2086
  TMUX="${TMUX_SOCKET},1,0" PATH="${BATS_TEST_TMPDIR}/stubs:${PATH}" run ${REVAMPED_TEST_SHELL:-sh} "${ROOT}/bin/extract-revamped" "$@"
}

typed() {
  local screen
  screen=$(tmux capture-pane -p -t "${PANE}")
  [[ "${screen}" == *"$1"* ]]
}

wait_for() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.2 0.5 1 1; do
    "$@" && return 0
    sleep "${delay}"
  done
  "$@"
}

attached() {
  local clients
  clients=$(tmux list-clients -F x 2>/dev/null)
  [[ -n "${clients}" ]]
}

offered() {
  printf '#!/bin/sh\ncat >"%s.tmp"\nmv -f "%s.tmp" "%s"\nhead -n 1 "%s"\n' "${BATS_TEST_TMPDIR}/fzf.offered" "${BATS_TEST_TMPDIR}/fzf.offered" "${BATS_TEST_TMPDIR}/fzf.offered" "${BATS_TEST_TMPDIR}/fzf.offered" >"${BATS_TEST_TMPDIR}/stubs/fzf"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fzf"
}

offered_is() {
  local now want
  now=$(sort -u "${BATS_TEST_TMPDIR}/fzf.offered" 2>/dev/null)
  want=$(sort -u <<<"$1")
  [[ "${now}" == "${want}" ]]
}

attach_host() {
  command tmux -S "${HOST}" -f /dev/null new-session -d -s host -x 100 -y 30 "env -u TMUX TERM=xterm-256color tmux -S '${TMUX_SOCKET}' attach-session -t test"
  wait_for attached
}

@test "entrypoint - loading binds the picker on prefix M-x and nothing else" {
  # Arrange
  local key=M-x

  # Act
  load_plugin "${ROOT}"

  # Assert
  run key_binding "${key}"
  [[ "${output}" == *"display-popup -E "*"/bin/extract-revamped' insert\""* ]]
  run tmux list-keys -T prefix
  run grep -c extract-revamped <<<"${output}"
  [[ "${output}" == "1" ]]
}

@test "entrypoint - a key the person bound keeps its command" {
  # Arrange
  tmux bind-key M-x display-message mine

  # Act
  load_plugin "${ROOT}"

  # Assert
  run key_binding M-x
  [[ "${output}" == *"display-message mine"* ]]
}

@test "entrypoint - a checkout path with a space, a quote and a hash still opens the picker from its key" {
  # Arrange
  local copy="${BATS_TEST_TMPDIR}/it's #1 dir" quoted
  mkdir -p "${copy}"
  cp -Rf "${ROOT}/bin" "${ROOT}/lib" "${ROOT}/extract-revamped.tmux" "${copy}/"
  quoted=$(printf '%s' "${copy}" | sed -e "s/'/'\\\\''/g" -e 's/#/##/g')
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  tmux run-shell "'${quoted}/extract-revamped.tmux'"
  tmux send-keys -t "${PANE}" 'echo see https://example.com/odd' Enter
  wait_for typed 'see https://example.com/odd'
  answer 'https://example.com/odd'
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b M-x

  # Assert
  wait_for typed $'\n$ https://example.com/odd'
}

@test "entrypoint - git tracks the entry point and the tool as executable" {
  # Arrange
  local entry=extract-revamped.tmux tool=bin/extract-revamped

  # Act
  run git -C "${ROOT}" ls-files --stage -- "${entry}" "${tool}"

  # Assert
  [[ "${lines[0]}" == 100755\ * ]]
  [[ "${lines[1]}" == 100755\ * ]]
}

@test "insert - the picked token reaches the pane as literal text" {
  # Arrange
  tmux send-keys -t "${PANE}" 'echo see https://example.com/x' Enter
  wait_for typed 'see https://example.com/x'
  tmux set-option -g @extract_revamped_mode urls
  answer 'https://example.com/x'

  # Act
  tool insert "${PANE}"

  # Assert
  [[ "${status}" -eq 0 ]]
  wait_for typed $'\n$ https://example.com/x'
}

@test "insert - a token that names a key is typed, never pressed" {
  # Arrange
  tmux send-keys -t "${PANE}" 'echo Enter' Enter
  wait_for typed 'Enter'
  tmux set-option -g @extract_revamped_mode words
  answer 'Enter'

  # Act
  tool insert "${PANE}"

  # Assert
  wait_for typed $'\n$ Enter'
}

@test "open - a path opens in the editor in a new window at the pane's folder" {
  # Arrange
  local folder="${BATS_TEST_TMPDIR}/work dir"
  mkdir -p "${folder}"
  folder=$(cd "${folder}" && pwd -P)
  tmux send-keys -t "${PANE}" "cd '${folder}' && echo notes/a.md" Enter
  wait_for typed 'notes/a.md'
  tmux set-option -g @extract_revamped_mode paths
  answer 'notes/a.md'
  printf '#!/bin/sh\nprintf "%%s|%%s\\n" "$PWD" "$1" >"%s"\n' "${BATS_TEST_TMPDIR}/editor.out" >"${BATS_TEST_TMPDIR}/stubs/fake-editor"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fake-editor"
  tmux set-environment -g EDITOR "${BATS_TEST_TMPDIR}/stubs/fake-editor"

  # Act
  EDITOR="${BATS_TEST_TMPDIR}/stubs/fake-editor" tool open "${PANE}"

  # Assert
  wait_for test -s "${BATS_TEST_TMPDIR}/editor.out"
  run cat "${BATS_TEST_TMPDIR}/editor.out"
  [[ "${output}" == "${folder}|notes/a.md" ]]
}

@test "open - the editor starts in a folder whose name holds a hash tmux reads as a format" {
  # Arrange
  local folder="${BATS_TEST_TMPDIR}/a #S dir"
  mkdir -p "${folder}"
  folder=$(cd "${folder}" && pwd -P)
  tmux send-keys -t "${PANE}" "cd '${folder}' && echo notes/a.md" Enter
  wait_for typed 'notes/a.md'
  tmux set-option -g @extract_revamped_mode paths
  answer 'notes/a.md'
  printf '#!/bin/sh\nprintf "%%s|%%s\\n" "$PWD" "$1" >"%s"\n' "${BATS_TEST_TMPDIR}/editor.out" >"${BATS_TEST_TMPDIR}/stubs/fake-editor"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fake-editor"
  tmux set-environment -g EDITOR "${BATS_TEST_TMPDIR}/stubs/fake-editor"

  # Act
  EDITOR="${BATS_TEST_TMPDIR}/stubs/fake-editor" tool open "${PANE}"

  # Assert
  wait_for test -s "${BATS_TEST_TMPDIR}/editor.out"
  run cat "${BATS_TEST_TMPDIR}/editor.out"
  [[ "${output}" == "${folder}|notes/a.md" ]]
}

@test "open - a path with spaces and shell syntax reaches the editor as one argument" {
  # Arrange
  tmux send-keys -t "${PANE}" "echo './a \$(b);c'" Enter
  wait_for typed "./a \$(b);c"
  tmux set-option -g @extract_revamped_mode lines
  answer './a $(b);c'
  printf '#!/bin/sh\nprintf "%%s|%%s\\n" "$#" "$1" >"%s"\n' "${BATS_TEST_TMPDIR}/editor.out" >"${BATS_TEST_TMPDIR}/stubs/fake-editor"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fake-editor"

  # Act
  EDITOR="${BATS_TEST_TMPDIR}/stubs/fake-editor" tool open "${PANE}"

  # Assert
  wait_for test -s "${BATS_TEST_TMPDIR}/editor.out"
  run cat "${BATS_TEST_TMPDIR}/editor.out"
  [[ "${output}" == "1|./a \$(b);c" ]]
}

@test "navigate - the pane enters copy-mode on the picked token" {
  # Arrange
  tmux send-keys -t "${PANE}" 'echo marker-token' Enter
  wait_for typed 'marker-token'
  tmux set-option -g @extract_revamped_mode words
  answer 'marker-token'

  # Act
  tool navigate "${PANE}"

  # Assert
  run tmux display-message -p -t "${PANE}" '#{pane_in_mode}'
  [[ "${output}" == "1" ]]
}

@test "insert - pressing prefix M-x types the pick into the pane under the popup" {
  # Arrange
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  load_plugin "${ROOT}"
  tmux send-keys -t "${PANE}" 'echo see https://example.com/key' Enter
  wait_for typed 'see https://example.com/key'
  tmux set-option -g @extract_revamped_mode urls
  answer 'https://example.com/key'
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b M-x

  # Assert
  wait_for typed $'\n$ https://example.com/key'
}

@test "insert - a mode given to apply on the command line reaches the picker the key opens" {
  # Arrange
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  tmux send-keys -t "${PANE}" 'echo see https://example.com/key' Enter
  wait_for typed 'see https://example.com/key'
  offered
  tool --mode urls apply
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b M-x

  # Assert
  wait_for typed $'\n$ https://example.com/key'
  run cat "${BATS_TEST_TMPDIR}/fzf.offered"
  [[ "${output}" == "https://example.com/key" ]]
}

@test "insert - a regex holding a hash and a quote, given on the command line, reaches the picker" {
  # Arrange
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  tmux send-keys -t "${PANE}" "echo id#42 it\\'s id#7" Enter
  wait_for typed "id#42 it's id#7"
  offered
  tool --mode custom --custom-regex "(id#[0-9]+|it's)" apply
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b M-x

  # Assert
  wait_for offered_is $'id#7\nit\'s\nid#42'
}

host_shows() {
  local screen
  screen=$(command tmux -S "${HOST}" capture-pane -p -t host)
  [[ "${screen}" == *"$1"* ]]
}

host_lacks() {
  ! host_shows "$1"
}

in_mode() {
  local now
  now=$(tmux display-message -p -t "${PANE}" '#{pane_in_mode}')
  [[ "${now}" == "1" ]]
}

file_holds() {
  [[ -f "$1" ]] || return 1
  grep -qF -- "$2" "$1"
}

bound_on() {
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  tmux set-option -g "@extract_revamped_$1" "$2"
  load_plugin "${ROOT}"
}

@test "navigate - pressing its key puts the pane under the popup into copy-mode on the pick" {
  # Arrange
  bound_on navigate_key N
  tmux send-keys -t "${PANE}" 'echo marker-token' Enter
  wait_for typed 'marker-token'
  tmux set-option -g @extract_revamped_mode words
  answer 'marker-token'
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b N

  # Assert
  wait_for in_mode
}

@test "open - pressing its key opens the picked path in the editor at the pane's folder" {
  # Arrange
  local folder="${BATS_TEST_TMPDIR}/work dir"
  mkdir -p "${folder}"
  folder=$(cd "${folder}" && pwd -P)
  printf '#!/bin/sh\nprintf "%%s|%%s\\n" "$PWD" "$1" >"%s"\n' "${BATS_TEST_TMPDIR}/editor.out" >"${BATS_TEST_TMPDIR}/stubs/fake-editor"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fake-editor"
  tmux set-environment -g EDITOR "${BATS_TEST_TMPDIR}/stubs/fake-editor"
  bound_on open_key O
  tmux send-keys -t "${PANE}" "cd '${folder}' && echo notes/a.md" Enter
  wait_for typed 'notes/a.md'
  tmux set-option -g @extract_revamped_mode paths
  answer 'notes/a.md'
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b O

  # Assert
  wait_for file_holds "${BATS_TEST_TMPDIR}/editor.out" "${folder}|notes/a.md"
}

@test "copy - pressing its key sends the pick to the clipboard tool" {
  # Arrange
  local name
  for name in pbcopy wl-copy xclip xsel; do
    printf '#!/bin/sh\ncat >"%s"\n' "${BATS_TEST_TMPDIR}/clipboard" >"${BATS_TEST_TMPDIR}/stubs/${name}"
    chmod +x "${BATS_TEST_TMPDIR}/stubs/${name}"
  done
  bound_on copy_key C
  tmux send-keys -t "${PANE}" 'echo see https://example.com/copy' Enter
  wait_for typed 'see https://example.com/copy'
  tmux set-option -g @extract_revamped_mode urls
  answer 'https://example.com/copy'
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b C

  # Assert
  wait_for file_holds "${BATS_TEST_TMPDIR}/clipboard" 'https://example.com/copy'
}

@test "choose - pressing its key and taking the pick with Enter types it into the pane" {
  # Arrange
  bound_on chooser_key H
  tmux send-keys -t "${PANE}" 'echo see https://example.com/choose' Enter
  wait_for typed 'see https://example.com/choose'
  tmux set-option -g @extract_revamped_mode urls
  printf '\n%s\n' 'https://example.com/choose' >"${BATS_TEST_TMPDIR}/fzf.answer"
  printf '#!/bin/sh\ncat >/dev/null\ncat "%s"\n' "${BATS_TEST_TMPDIR}/fzf.answer" >"${BATS_TEST_TMPDIR}/stubs/fzf"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fzf"
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b H

  # Assert
  wait_for typed $'\n$ https://example.com/choose'
}

@test "doctor - pressing its key shows the dependency rows in a popup until Enter closes it" {
  # Arrange
  answer 'unused'
  bound_on doctor_key D
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b D

  # Assert
  wait_for host_shows 'awk'
  command tmux -S "${HOST}" send-keys -t host Enter
  wait_for host_lacks 'awk'
  command tmux -S "${HOST}" send-keys -t host "echo clo''sed" Enter
  wait_for typed $'\nclosed'
}
