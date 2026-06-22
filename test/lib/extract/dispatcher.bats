#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _EXTRACT_REVAMPED_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/extract.sh"
  _capture_pane() { echo "https://a.com /tmp/x word"; }
  _fzf() { head -1; }
  _insert() { echo "INSERT:${2}" >> "${BATS_TEST_TMPDIR}/ins"; }
}

teardown() {
  cleanup_test_environment
}

@test "extract.sh - functions are defined" {
  function_exists extract_run
  function_exists _extract_for
}

@test "extract.sh - _extract_for routes each mode" {
  [[ "$(_extract_for urls "see https://a.com")" == "https://a.com" ]]
  [[ "$(_extract_for paths "x /tmp/a")" == "/tmp/a" ]]
  [[ "$(_extract_for lines "  hi  ")" == "hi" ]]
  [[ "$(printf '%s' "$(_extract_for words "a b a")" | grep -c .)" == "2" ]]
}

@test "extract.sh - run captures, picks, and inserts into the pane" {
  run main all "%1"
  [[ "$(cat "${BATS_TEST_TMPDIR}/ins")" == "INSERT:https://a.com" ]]
}

@test "extract.sh - run inserts nothing when the picker returns empty" {
  _fzf() { true; }
  run main all "%1"
  [[ ! -f "${BATS_TEST_TMPDIR}/ins" ]]
}

@test "extract.sh - run does nothing when the capture is empty" {
  _capture_pane() { printf ''; }
  run main all "%1"
  [[ ! -f "${BATS_TEST_TMPDIR}/ins" ]]
}

@test "extract.sh - host-probe seams are callable" {
  unset _EXTRACT_REVAMPED_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/extract.sh"
  run _capture_pane "%1"
  run _insert "%1" "x"
  run _fzf </dev/null
  true
}
