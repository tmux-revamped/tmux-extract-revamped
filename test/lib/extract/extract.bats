#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _EXTRACT_REVAMPED_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/extract/extract.sh"
}

teardown() {
  cleanup_test_environment
}

@test "extract_urls pulls a url and trims trailing punctuation" {
  run extract_urls "go to https://example.com/p, now"
  [[ "${output}" == "https://example.com/p" ]]
}

@test "extract_urls captures emails and de-duplicates" {
  run extract_urls $'mail user@example.com\nmail user@example.com'
  [[ "${output}" == "user@example.com" ]]
}

@test "extract_paths extracts absolute and relative paths" {
  run extract_paths "edit /usr/local/bin/x and ./src/a.sh here"
  [[ "${output}" == *"/usr/local/bin/x"* ]]
  [[ "${output}" == *"./src/a.sh"* ]]
}

@test "extract_words splits on whitespace and de-duplicates" {
  run extract_words "foo bar foo baz"
  [[ "$(printf '%s' "${output}" | grep -c .)" == "3" ]]
}

@test "extract_lines keeps non-blank trimmed lines" {
  run extract_lines $'  hello  \n\n  world'
  [[ "${lines[0]}" == "hello" ]]
  [[ "${lines[1]}" == "world" ]]
}

@test "extract_all combines extractors and de-duplicates across them" {
  run extract_all "https://a.com /path/x word"
  [[ "${output}" == *"https://a.com"* ]]
  [[ "${output}" == *"/path/x"* ]]
  [[ "${output}" == *"word"* ]]
}
