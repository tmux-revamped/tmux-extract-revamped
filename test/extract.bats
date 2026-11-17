#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2088

# shellcheck source=test/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  harness_setup
  for name in $(compgen -v EXTRACT_REVAMPED_); do
    unset "${name}"
  done
}

option() {
  printf '%s' "$2" >"${REVAMPED_TEST_TMUX_DIR}/$(printf '%s' "g.-.@extract_revamped_$1" | tr -c 'A-Za-z0-9_.-' '_')"
}

extract() {
  export PROBE_TEXT="$2"
  lib_run extract "extract_revamped_for $1 \"\${PROBE_TEXT}\""
}

fzf_answers() {
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  printf '%s\n' "$@" >"${BATS_TEST_TMPDIR}/fzf-answers"
  cat >"${BATS_TEST_TMPDIR}/stubs/fzf" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >>"${BATS_TEST_TMPDIR}/fzf.args"
cat >>"${BATS_TEST_TMPDIR}/fzf.input"
round=\$(( \$(cat "${BATS_TEST_TMPDIR}/fzf.round" 2>/dev/null || printf 0) + 1 ))
printf '%s' "\${round}" >"${BATS_TEST_TMPDIR}/fzf.round"
awk -v r="\${round}" 'BEGIN { RS = "--\\n" } NR == r { printf "%s", \$0 }' "${BATS_TEST_TMPDIR}/fzf-answers"
EOF
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fzf"
}

screen() {
  tmux_answer '#{pane_current_path}' "${BATS_TEST_TMPDIR}" %1
  printf '%s' "$1" >"${BATS_TEST_TMPDIR}/screen"
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  cat >"${BATS_TEST_TMPDIR}/stubs/tmux" <<EOF
#!/bin/sh
if [ "\$1" = capture-pane ]; then
  printf '%s\n' "\$*" >>"${REVAMPED_TEST_TMUX_LOG}"
  cat "${BATS_TEST_TMPDIR}/screen"
  exit 0
fi
exec "${REVAMPED_TESTS_DIR}/bin/tmux" "\$@"
EOF
  chmod +x "${BATS_TEST_TMPDIR}/stubs/tmux"
}

refuse() {
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  printf '#!/bin/sh\nfor a in "$@"; do [ "$a" != ";" ] || exit 1; [ "$a" != BAD ] || { printf "unknown key: BAD\\n" >&2; exit 1; }; done\nexec "%s/bin/tmux" "$@"\n' "${REVAMPED_TESTS_DIR}" >"${BATS_TEST_TMPDIR}/stubs/tmux"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/tmux"
}

@test "extract - a URL loses its trailing punctuation and repeats" {
  # Arrange
  local text='see https://example.com/a?b=1, and (https://example.com/a?b=1).'

  # Act
  extract urls "${text}"

  # Assert
  [[ "${output}" == "https://example.com/a?b=1" ]]
}

@test "extract - an email counts as a URL" {
  # Arrange
  local text='mail ops@example.org or ops@example.org'

  # Act
  extract urls "${text}"

  # Assert
  [[ "${output}" == "ops@example.org" ]]
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
  local text='go to https://a.io/x and /tmp/y'

  # Act
  extract all "${text}"

  # Assert
  [[ "${output}" == $'https://a.io/x\n//a.io/x\n/tmp/y\ngo\nto\nand' ]]
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
  local script='for t in https://a.com ftp://a.com file:///x /etc/hosts "~/x" ./a ../b user@host.com git@github.com:owner/repo.git a/b@c.d:1 src/app.ts justaword; do printf "%s " "$(extract_revamped_classify "$t")"; done'

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
