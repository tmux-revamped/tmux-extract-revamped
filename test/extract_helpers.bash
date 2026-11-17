#!/usr/bin/env bash
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

untraced() {
  # shellcheck disable=SC2154
  output=$(printf '%s\n' "${output}" | sed -e 's/+*BASHCOV>.*//' -e '/^$/d')
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
