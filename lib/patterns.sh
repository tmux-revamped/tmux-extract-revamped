#!/bin/sh

[ -n "${EXTRACT_REVAMPED_PATTERNS_LOADED:-}" ] && return 0
EXTRACT_REVAMPED_PATTERNS_LOADED=1

# shellcheck source=SCRIPTDIR/state.sh
. "${REVAMPED_LIB:?}/state.sh"

extract_revamped_patterns_unique() {
  awk 'NF && !seen[$0]++'
}

extract_revamped_docker() {
  printf '%s\n' "$1" | grep -owE 'sha256:[0-9a-f]{64}|[0-9a-f]{64}|[0-9a-f]{12}|[a-z0-9]+([._/-][a-z0-9]+)*:[A-Za-z0-9_][A-Za-z0-9._-]*' | grep -vE '^[0-9.]+:' | extract_revamped_patterns_unique
}

extract_revamped_kubernetes() {
  printf '%s\n' "$1" | grep -owE '[a-z][a-z0-9.]*/[a-z0-9]([a-z0-9.-]*[a-z0-9])?|[a-z0-9]+(-[a-z0-9]+)*-[a-z0-9]{5}' | grep -vE '^[a-z0-9]+-[a-z]{5}$' | extract_revamped_patterns_unique
}

extract_revamped_git_status() {
  printf '%s\n' "$1" | awk '
    function emit(path,    at) {
      at = index(path, " -> ")
      if (at > 0) { print substr(path, 1, at - 1); print substr(path, at + 4); return }
      print path
    }
    /^Untracked files:/ { untracked = 1; next }
    /^[^ \t]/ && !/^[MADRCU?!][ MADRCU?!] / { untracked = 0 }
    /^[ \t]+(modified|new file|deleted|renamed|copied|typechange|both modified|both added|both deleted|added by us|added by them|deleted by us|deleted by them):[ \t]+/ {
      sub(/^[ \t]+[a-z ]+:[ \t]+/, "")
      emit($0)
      next
    }
    /^[ MADRCU?!][ MADRCU?!] [^ ]/ && !/^  / { emit(substr($0, 4)); next }
    untracked && /^[ \t]+[^ \t(]/ { sub(/^[ \t]+/, ""); print }
  ' | extract_revamped_patterns_unique
}

extract_revamped_diff() {
  printf '%s\n' "$1" | awk '
    /^diff --git a\/.+ b\// { sub(/^diff --git a\/.+ b\//, ""); print; next }
    /^(---|\+\+\+) / {
      sub(/^(---|\+\+\+) /, "")
      sub(/\t.*$/, "")
      if ($0 == "/dev/null") { next }
      sub(/^[ab]\//, "")
      print
    }
  ' | extract_revamped_patterns_unique
}

extract_revamped_markdown() {
  printf '%s\n' "$1" | grep -oE '\]\([^) ]+' | sed 's/^](//' | extract_revamped_patterns_unique
}

extract_revamped_branches() {
  printf '%s\n' "$1" | awk -v quote="${EXTRACT_REVAMPED_QUOTE}" '
    function clean(name) {
      sub(/^HEAD -> /, "", name)
      sub(/^tag: /, "", name)
      return name
    }
    /^On branch / { print substr($0, 11); next }
    /^[*+ ] +[A-Za-z0-9._\/-]+( +-> +[A-Za-z0-9._\/-]+)?$/ {
      line = $0
      sub(/^[*+ ] +/, "", line)
      count = split(line, part, / +-> +/)
      for (i = 1; i <= count; i++) { print part[i] }
      next
    }
    {
      rest = $0
      while (match(rest, /\((HEAD -> |tag: |origin\/)[^()]*\)/)) {
        inner = substr(rest, RSTART + 1, RLENGTH - 2)
        rest = substr(rest, RSTART + RLENGTH)
        count = split(inner, part, /, /)
        for (i = 1; i <= count; i++) { print clean(part[i]) }
      }
      at = index($0, "with " quote)
      if (at == 0) { next }
      rest = substr($0, at + 6)
      stop = index(rest, quote)
      if (stop > 1) { print substr(rest, 1, stop - 1) }
    }
  ' | extract_revamped_patterns_unique
}
