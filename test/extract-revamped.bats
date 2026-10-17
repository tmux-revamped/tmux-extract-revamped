#!/usr/bin/env bats

setup() {
  PLUGIN_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  PLUGIN_COPY="${BATS_TEST_TMPDIR}/plug in's"
  mkdir -p "${PLUGIN_COPY}"
  cp -R "${PLUGIN_ROOT}/src" "${PLUGIN_COPY}/src"
  cp "${PLUGIN_ROOT}/extract-revamped.tmux" "${PLUGIN_COPY}/extract-revamped.tmux"
  BINDS_FILE="${BATS_TEST_TMPDIR}/binds"
  export BINDS_FILE
}

record_tmux() {
  case "${1}" in
    bind-key) printf '%s\n' "${!#}" >> "${BINDS_FILE}" ;;
    show-option) [[ "${*}" == *"@extract_revamped_open_key"* ]] && [[ -n "${OPEN_KEY:-}" ]] && printf '%s' "${OPEN_KEY}" ;;
  esac
  return 0
}

@test "extract-revamped.tmux - main popup command keeps a path with a space and a quote as one word" {
  # Arrange
  tmux() { record_tmux "$@"; }
  export -f tmux record_tmux

  # Act
  bash "${PLUGIN_COPY}/extract-revamped.tmux"

  # Assert
  eval "set -- $(sed -n 1p "${BINDS_FILE}")"
  [[ "${1}" == "${PLUGIN_COPY}/src/extract.sh" ]] || false
  [[ "${2}" == "all" ]] || false
  [[ "${3}" == "#{pane_id}" ]]
}

@test "extract-revamped.tmux - action popup command keeps a path with a space and a quote as one word" {
  # Arrange
  tmux() { record_tmux "$@"; }
  OPEN_KEY="o"
  export OPEN_KEY
  export -f tmux record_tmux

  # Act
  bash "${PLUGIN_COPY}/extract-revamped.tmux"

  # Assert
  eval "set -- $(sed -n 2p "${BINDS_FILE}")"
  [[ "${1}" == "${PLUGIN_COPY}/src/extract.sh" ]] || false
  [[ "${4}" == "open" ]]
}

@test "extract-revamped.tmux - the action keys stay unbound by default" {
  # Arrange
  tmux() { record_tmux "$@"; }
  export -f tmux record_tmux

  # Act
  bash "${PLUGIN_COPY}/extract-revamped.tmux"

  # Assert
  [ "$(wc -l < "${BINDS_FILE}" | tr -d ' ')" = "1" ]
}
