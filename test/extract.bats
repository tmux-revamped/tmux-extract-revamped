#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2088

# shellcheck source=test/extract_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/extract_helpers.bash"

@test "extract - a URL loses its trailing punctuation and repeats" {
  # Arrange
  local text='see https://github.com/tmux-revamped/tmux-extract-revamped/issues?q=1, and (https://github.com/tmux-revamped/tmux-extract-revamped/issues?q=1).'

  # Act
  extract urls "${text}"

  # Assert
  [[ "${output}" == "https://github.com/tmux-revamped/tmux-extract-revamped/issues?q=1" ]]
}

@test "extract - an email counts as a URL" {
  # Arrange
  local text='mail noreply@github.com or noreply@github.com'

  # Act
  extract urls "${text}"

  # Assert
  [[ "${output}" == "noreply@github.com" ]]
}

@test "extract - paths are absolute, home, relative and bare with a slash" {
  # Arrange
  local text='open /etc/hosts, ~/notes/todo.md ./src/a.ts ../up/x.c and lib/b.sh'

  # Act
  extract paths "${text}"

  # Assert
  [[ "${output}" == $'/etc/hosts\n~/notes/todo.md\n./src/a.ts\n../up/x.c\nlib/b.sh' ]]
}

@test "extract - words split on any blank and repeat once" {
  # Arrange
  local text=$'one two\tone\nthree'

  # Act
  extract words "${text}"

  # Assert
  [[ "${output}" == $'one\ntwo\nthree' ]]
}

@test "extract - lines are trimmed and blank ones dropped" {
  # Arrange
  local text=$'  first  \n\n\tsecond\n  first'

  # Act
  extract lines "${text}"

  # Assert
  [[ "${output}" == $'first\nsecond' ]]
}

@test "extract - a hash needs a letter, so plain decimals are skipped" {
  # Arrange
  local text='commit 3f9a2b7c and 1234567 and 3f9a2b7c'

  # Act
  extract shas "${text}"

  # Assert
  [[ "${output}" == "3f9a2b7c" ]]
}

@test "extract - IPv4 keeps valid octets only" {
  # Arrange
  local text='192.168.1.10 999.1.1.1 10.0.0.1'

  # Act
  extract ipv4 "${text}"

  # Assert
  [[ "${output}" == $'192.168.1.10\n10.0.0.1' ]]
}

@test "extract - IPv6 matches full and compressed forms but not a clock" {
  # Arrange
  local text='fe80::1 2001:0db8:0000:0000:0000:ff00:0042:8329 at 12:30'

  # Act
  extract ipv6 "${text}"

  # Assert
  [[ "${output}" == $'fe80::1\n2001:0db8:0000:0000:0000:ff00:0042:8329' ]]
}

@test "extract - hex colours keep the longest form" {
  # Arrange
  local text='#12345678 #a1b2c3 #fff #12g'

  # Act
  extract hex "${text}"

  # Assert
  [[ "${output}" == $'#12345678\n#a1b2c3\n#fff' ]]
}

@test "extract - a canonical UUID is matched" {
  # Arrange
  local text='id 123e4567-e89b-12d3-a456-426614174000 done'

  # Act
  extract uuids "${text}"

  # Assert
  [[ "${output}" == "123e4567-e89b-12d3-a456-426614174000" ]]
}

@test "extract - numbers keep their sign and decimals" {
  # Arrange
  local text='-42 then +3.14 and 7'

  # Act
  extract numbers "${text}"

  # Assert
  [[ "${output}" == $'-42\n+3.14\n7' ]]
}

@test "extract - quoted text loses its quotes, and empty pairs are dropped" {
  # Arrange
  local text="\"double\" 'single' \`tick\` \"\""

  # Act
  extract quoted "${text}"

  # Assert
  [[ "${output}" == $'double\nsingle\ntick' ]]
}

@test "extract - bracketed text loses each kind of bracket" {
  # Arrange
  local text='(paren) [square] {curly} <angle>'

  # Act
  extract bracketed "${text}"

  # Assert
  [[ "${output}" == $'paren\nsquare\ncurly\nangle' ]]
}

@test "extract - the custom mode reads its regex, and an empty one finds nothing" {
  # Arrange
  option custom_regex 'JIRA-[0-9]+'
  export PROBE_TEXT='JIRA-12 and JIRA-7'

  # Act
  lib_run extract 'extract_revamped_load; extract_revamped_for custom "${PROBE_TEXT}"; printf "[%s]" "$(extract_revamped_custom "" "${PROBE_TEXT}")"'

  # Assert
  [[ "${output}" == $'JIRA-12\nJIRA-7\n[]' ]]
}

@test "extract - all joins URLs, paths and words without repeats" {
  # Arrange
  local text='go to https://github.com/tmux-revamped/tmux-extract-revamped and /tmp/y'

  # Act
  extract all "${text}"

  # Assert
  [[ "${output}" == $'https://github.com/tmux-revamped/tmux-extract-revamped\n//github.com/tmux-revamped/tmux-extract-revamped\n/tmp/y\ngo\nto\nand' ]]
}

@test "extract - every mode name routes, the synonyms included" {
  # Arrange
  local script='for m in color colors uuid nums; do printf "[%s]" "$(extract_revamped_for "$m" "#abc 7 123e4567-e89b-12d3-a456-426614174000" | head -n 1)"; done'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == "[#abc][#abc][123e4567-e89b-12d3-a456-426614174000][7]" ]]
}

@test "extract - min length drops short tokens and reads a bad minimum as zero" {
  # Arrange
  local script='printf "%s|" $(extract_revamped_min_length 3 "$(printf "ab\nabc\nabcd")"); printf "%s|" $(extract_revamped_min_length x "$(printf "a\nbb")")'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == "abc|abcd|a|bb|" ]]
}

@test "extract - reverse flips the order" {
  # Arrange
  local script='extract_revamped_reverse "$(printf "a\nb\nc")" | tr "\n" " "'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == "c b a " ]]
}

@test "extract - frecency floats recent picks to the top and keeps order without any" {
  # Arrange
  local script='extract_revamped_frecency "$(printf "c\na")" "$(printf "a\nb\nc\nd")" | tr "\n" " "; printf "|"; extract_revamped_frecency "" "$(printf "a\nb")" | tr "\n" " "'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == "a c b d |a b " ]]
}

@test "extract - candidates apply min length, reverse and frecency in turn" {
  # Arrange
  option min_length 2
  option reverse 1
  option frecency 1
  export PROBE_TEXT='a bb cc dd'

  # Act
  lib_run extract 'extract_revamped_load; EXTRACT_REVAMPED_S_recent=bb; extract_revamped_candidates words "${PROBE_TEXT}" | tr "\n" " "'

  # Assert
  [[ "${output}" == "bb dd cc" ]]
}

@test "extract - a token is classified as URL, path or other" {
  # Arrange
  local script='for t in https://github.com ftp://ftp.gnu.org file:///x /etc/hosts "~/x" ./a ../b noreply@github.com git@github.com:tmux-revamped/tmux-extract-revamped.git a/b@c.d:1 src/app.ts justaword; do printf "%s " "$(extract_revamped_classify "$t")"; done'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == "url url url path path path path url other url path other " ]]
}

@test "extract - a selection joins its lines and its first line is found" {
  # Arrange
  local script='extract_revamped_join "$(printf "\na\n\nb\n")"; printf "|"; extract_revamped_first "$(printf "\n\nx\ny")"'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == "a b|x" ]]
}

@test "extract - the next mode advances, wraps and falls back to the first" {
  # Arrange
  local script='for m in urls lines nope; do printf "%s " "$(extract_revamped_next_mode "$m" "all urls lines")"; done'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == "lines all all " ]]
}

@test "extract - regex metacharacters are escaped and text is left alone" {
  # Arrange
  local script='extract_revamped_regex_escape "a.b[c](d){e}*+?|^\$\\z"'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == 'a\.b\[c\]\(d\)\{e\}\*\+\?\|\^\$\\z' ]]
}

@test "extract - an OSC 52 sequence carries the text in base64" {
  # Arrange
  local script='extract_revamped_osc52 hello | od -An -c | tr -s " " | tr -d "\n"'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == " 033 ] 5 2 ; c ; a G V s b G 8 = \\a" ]]
}

@test "extract - the default key opens the insert picker in a popup" {
  # Arrange
  export REVAMPED_TEST_TMUX_VERSION=3.6

  # Act
  lib_run extract 'extract_revamped_plan; extract_revamped_lines_of_plan'

  # Assert
  [[ "${output}" == "bind-key M-x display-popup -E -w 80% -h 60% '"*"/bin/extract-revamped' insert" ]]
}

@test "extract - action keys, the chooser and doctor bind only when set" {
  # Arrange
  option key none
  option navigate_key n
  option open_key o
  option copy_key y
  option chooser_key c
  option doctor_key D
  option popup_width 50%

  # Act
  lib_run extract 'extract_revamped_plan; extract_revamped_lines_of_plan; extract_revamped_bindings'

  # Assert
  [[ "${lines[0]}" == "bind-key n display-popup -E -w 50% -h 60% '"*"' navigate" ]]
  [[ "${lines[1]}" == *"' open" ]]
  [[ "${lines[2]}" == *"' copy" ]]
  [[ "${lines[3]}" == *"' choose" ]]
  [[ "${lines[4]}" == "bind-key D display-popup -E -w 50% -h 60% '"*"' doctor; read -r extract_revamped_wait" ]]
  [[ "${lines[5]}" == "5" ]]
}

@test "extract - a key the person bound is left alone and reported" {
  # Arrange
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  printf '#!/bin/sh\nif [ "$1" = list-keys ]; then printf "%%s\\n" "bind-key -T prefix M-x display-message mine"; exit 0; fi\nexec "%s/bin/tmux" "$@"\n' "${REVAMPED_TESTS_DIR}" >"${BATS_TEST_TMPDIR}/stubs/tmux"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/tmux"

  # Act
  lib_run extract 'extract_revamped_plan; printf "[%s][%s]" "$(extract_revamped_lines_of_plan)" "${EXTRACT_REVAMPED_TAKEN}"'

  # Assert
  [[ "${output}" == "[][M-x]" ]]
}

@test "extract - the tool path is quoted for the shell and carries no hash" {
  # Arrange
  export PROBE_LIB="/tmp/it's #1/lib"

  # Act
  lib_run extract 'REVAMPED_LIB="${PROBE_LIB}"; quoted=$(extract_revamped_tool); printf "%s\n" "${quoted}"; eval "printf \"%s\\n\" ${quoted}"'

  # Assert
  [[ "${lines[0]}" == "'/tmp/it'\\''s '\"\$(printf '%b' '\\0043')\"'1/bin/extract-revamped'" ]] || false
  [[ "${lines[1]}" == "/tmp/it's #1/bin/extract-revamped" ]]
}

@test "extract - apply sends every binding to tmux in one call" {
  # Arrange
  option navigate_key n
  export REVAMPED_TEST_TMUX_ARGV="${BATS_TEST_TMPDIR}/argv"

  # Act
  lib_run extract extract_revamped_apply

  # Assert
  run grep -c '^bind-key|M-x|display-popup|.*|;|bind-key|n|' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "1" ]]
  run grep -c '|;$' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "0" ]]
}

@test "extract - apply calls tmux for nothing when no key is set" {
  # Arrange
  option key none
  export REVAMPED_TEST_TMUX_ARGV="${BATS_TEST_TMPDIR}/argv"

  # Act
  lib_run extract extract_revamped_apply

  # Assert
  [[ "${status}" -eq 0 ]]
  run grep -c 'bind-key' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "0" ]]
}

@test "extract - json lists every command as its arguments" {
  # Arrange
  local script='EXTRACT_REVAMPED_PLAN="$(printf "a\\\\b\nsay \"hi\"\n\nnext\n")"; extract_revamped_json'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == '{"bindings":[["a\\b","say \"hi\""],["next"]]}' ]]
}

@test "extract - a setting name comes from its long option" {
  # Arrange
  local script='for o in --mode --min-length --colour; do printf "[%s]" "$(extract_revamped_setting_name "$o")"; done'

  # Act
  lib_run extract "${script}"

  # Assert
  [[ "${output}" == "[mode][min_length][]" ]]
}
