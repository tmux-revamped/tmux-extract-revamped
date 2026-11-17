#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/tmux_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/tmux_helpers.bash"

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
