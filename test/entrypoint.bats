#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/server_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/server_helpers.bash"

bats_require_minimum_version 1.5.0

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
  tmux send-keys -t "${PANE}" 'echo see https://github.com/tmux-revamped/tmux-extract-revamped' Enter
  wait_for typed 'see https://github.com/tmux-revamped/tmux-extract-revamped'
  answer 'https://github.com/tmux-revamped/tmux-extract-revamped'
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b M-x

  # Assert
  wait_for typed $'\n$ https://github.com/tmux-revamped/tmux-extract-revamped'
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
  tmux send-keys -t "${PANE}" 'echo see https://github.com/tmux-revamped/tmux-extract-revamped' Enter
  wait_for typed 'see https://github.com/tmux-revamped/tmux-extract-revamped'
  tmux set-option -g @extract_revamped_mode urls
  answer 'https://github.com/tmux-revamped/tmux-extract-revamped'

  # Act
  tool insert "${PANE}"

  # Assert
  [[ "${status}" -eq 0 ]]
  wait_for typed $'\n$ https://github.com/tmux-revamped/tmux-extract-revamped'
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
  tmux send-keys -t "${PANE}" 'echo see https://github.com/tmux-revamped/tmux-extract-revamped' Enter
  wait_for typed 'see https://github.com/tmux-revamped/tmux-extract-revamped'
  tmux set-option -g @extract_revamped_mode urls
  answer 'https://github.com/tmux-revamped/tmux-extract-revamped'
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b M-x

  # Assert
  wait_for typed $'\n$ https://github.com/tmux-revamped/tmux-extract-revamped'
}

@test "insert - a mode given to apply on the command line reaches the picker the key opens" {
  # Arrange
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  tmux send-keys -t "${PANE}" 'echo see https://github.com/tmux-revamped/tmux-extract-revamped' Enter
  wait_for typed 'see https://github.com/tmux-revamped/tmux-extract-revamped'
  offered
  tool --mode urls apply
  attach_host

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b M-x

  # Assert
  wait_for typed $'\n$ https://github.com/tmux-revamped/tmux-extract-revamped'
  run cat "${BATS_TEST_TMPDIR}/fzf.offered"
  [[ "${output}" == "https://github.com/tmux-revamped/tmux-extract-revamped" ]]
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
