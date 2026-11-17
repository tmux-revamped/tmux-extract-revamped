#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/server_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/server_helpers.bash"

bats_require_minimum_version 1.5.0

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

@test "edit - pressing its key opens the pick in the editor, even when it is not a path" {
  # Arrange
  local folder="${BATS_TEST_TMPDIR}/work dir"
  mkdir -p "${folder}"
  folder=$(cd "${folder}" && pwd -P)
  printf '#!/bin/sh\nprintf "%%s|%%s\\n" "$PWD" "$1" >"%s"\n' "${BATS_TEST_TMPDIR}/editor.out" >"${BATS_TEST_TMPDIR}/stubs/fake-editor"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fake-editor"
  tmux set-environment -g EDITOR "${BATS_TEST_TMPDIR}/stubs/fake-editor"
  bound_on edit_key E
  tmux send-keys -t "${PANE}" "cd '${folder}' && echo see Makefile" Enter
  wait_for typed 'see Makefile'
  tmux set-option -g @extract_revamped_mode words
  answer 'Makefile'
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b E

  # Assert
  wait_for file_holds "${BATS_TEST_TMPDIR}/editor.out" "${folder}|Makefile"
}

@test "run - pressing its key starts the person's command on the pick at the pane's folder" {
  # Arrange
  local folder="${BATS_TEST_TMPDIR}/work dir"
  mkdir -p "${folder}"
  folder=$(cd "${folder}" && pwd -P)
  tmux set-option -g @extract_revamped_command "printf '%s|%s\\n' \"\$PWD\" \"\$1\" >'${BATS_TEST_TMPDIR}/run.out'"
  bound_on run_key R
  tmux send-keys -t "${PANE}" "cd '${folder}' && echo commit 1a2b3c4d" Enter
  wait_for typed 'commit 1a2b3c4d'
  tmux set-option -g @extract_revamped_mode shas
  answer '1a2b3c4d'
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b R

  # Assert
  wait_for file_holds "${BATS_TEST_TMPDIR}/run.out" "${folder}|1a2b3c4d"
}

@test "run - a command holding a hash and quotes, given to apply on the command line, reaches the key" {
  # Arrange
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  tmux send-keys -t "${PANE}" 'echo commit 1a2b3c4d' Enter
  wait_for typed 'commit 1a2b3c4d'
  answer '1a2b3c4d'
  tool --mode shas --run-key R --command "printf '#%s \"it'\\''s\"\\n' \"\$1\" >'${BATS_TEST_TMPDIR}/run.out'" apply
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b R

  # Assert
  wait_for file_holds "${BATS_TEST_TMPDIR}/run.out" "#1a2b3c4d \"it's\""
}

@test "hints - pressing the picker key draws letters over the pane, and a letter types its token" {
  # Arrange
  tmux set-option -g @extract_revamped_picker hints
  tmux set-option -g @extract_revamped_mode urls
  bound_on key X
  tmux send-keys -t "${PANE}" 'clear; echo go https://example.com/hint' Enter
  wait_for typed 'go https://example.com/hint'
  attach_host
  command tmux -S "${HOST}" send-keys -t host C-b X
  wait_for host_shows 'go attps://example.com/hint'

  # Act
  command tmux -S "${HOST}" send-keys -t host a

  # Assert
  wait_for typed '$ https://example.com/hint'
}

@test "hints - the overlay covers exactly the pane it was opened on" {
  # Arrange
  local second
  tmux set-option -g @extract_revamped_picker hints
  tmux set-option -g @extract_revamped_mode urls
  bound_on key X
  second=$(tmux split-window -h -P -F '#{pane_id}' -t "${PANE}" "env -i PATH='${PATH}' HOME='${BATS_TEST_TMPDIR}/home' PS1='$ ' TERM=xterm sh")
  tmux send-keys -t "${second}" 'clear; echo right https://example.com/r' Enter
  tmux send-keys -t "${PANE}" 'clear; echo left https://example.com/l' Enter
  tmux select-pane -t "${second}"
  attach_host
  wait_for host_shows 'right https://example.com/r'

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b X

  # Assert
  wait_for host_shows 'right attps://example.com/r'
  host_shows 'left https://example.com/l'
}
