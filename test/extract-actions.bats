#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2088

# shellcheck source=test/extract_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/extract_helpers.bash"

plan_lines() {
  lib_run extract 'extract_revamped_plan; extract_revamped_lines_of_plan'
}

@test "actions - edit sends any token to the editor in a new window at the pane's folder" {
  # Arrange
  screen 'see Makefile and ~/notes/a.md'
  option mode words
  fzf_answers 'Makefile'
  export EDITOR=nano

  # Act
  lib_run extract 'extract_revamped_pick edit %1'

  # Assert
  run grep -c "^new-window -c ${BATS_TEST_TMPDIR} -- sh -c set -f; exec \$1 \"\$2\" extract-revamped nano Makefile$" "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
}

@test "actions - run starts the person's command in a new window with each pick as its own argument" {
  # Arrange
  screen 'commit 1a2b3c4d and 5e6f7a8b'
  option mode shas
  option multi 1
  option command 'git show "$@"'
  fzf_answers '1a2b3c4d' '5e6f7a8b'

  # Act
  lib_run extract 'extract_revamped_pick run %1'

  # Assert
  run grep -c "^new-window -c ${BATS_TEST_TMPDIR} -- sh -c git show \"\$@\" extract-revamped 1a2b3c4d 5e6f7a8b$" "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "1" ]]
}

@test "actions - run without a command says so, fails and starts nothing" {
  # Arrange
  screen 'commit 1a2b3c4d'
  option mode shas
  fzf_answers '1a2b3c4d'

  # Act
  lib_run extract 'extract_revamped_pick run %1'

  # Assert
  [[ "${status}" -eq 1 ]]
  untraced
  [[ "${output}" == 'extract-revamped: no command to run, so nothing was started. set @extract_revamped_command, such as git show "$1".' ]]
  run grep -c '^new-window' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "0" ]]
}

@test "actions - in the chooser, C-e edits the pick and C-x runs the command on it" {
  # Arrange
  screen 'commit 1a2b3c4d'
  option mode shas
  option command 'git show "$1"'
  fzf_answers x
  printf '%s\n' 'ctrl-e' '1a2b3c4d' -- 'ctrl-x' '1a2b3c4d' >"${BATS_TEST_TMPDIR}/fzf-answers"
  export EDITOR=nano

  # Act
  lib_run extract 'extract_revamped_pick choose %1; extract_revamped_pick choose %1'

  # Assert
  run grep '^new-window' "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${lines[0]}" == "new-window -c ${BATS_TEST_TMPDIR} -- sh -c set -f; exec \$1 \"\$2\" extract-revamped nano 1a2b3c4d" ]] || false
  [[ "${lines[1]}" == "new-window -c ${BATS_TEST_TMPDIR} -- sh -c git show \"\$1\" extract-revamped 1a2b3c4d" ]]
}

@test "actions - the edit and run keys open their pickers" {
  # Arrange
  option key none
  option edit_key E
  option run_key R

  # Act
  plan_lines

  # Assert
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "bind-key E display-popup -E -w 80% -h 60% '"*"/bin/extract-revamped' edit" ]] || false
  [[ "${lines[1]}" == "bind-key R display-popup -E -w 80% -h 60% '"*"/bin/extract-revamped' run" ]]
}

@test "actions - a command from the environment rides on the picker keys, hash-free" {
  # Arrange
  option key none
  option run_key R
  export EXTRACT_REVAMPED_COMMAND='echo "#$1"'

  # Act
  plan_lines

  # Assert
  [[ "${lines[0]}" == *"/bin/extract-revamped' --command 'echo \"'\"\$(printf '%b' '\\0043')\"'\$1\"' run" ]]
}
