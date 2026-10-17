#!/usr/bin/env bash

[[ -n "${_EXTRACT_REVAMPED_LOADED:-}" ]] && return 0
_EXTRACT_REVAMPED_LOADED=1

extract_urls() {
  printf '%s\n' "${1}" \
    | grep -oE '(https?|ftp|file)://[A-Za-z0-9._~:/?#@!$&'"'"'()*+,;=%-]+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
    | sed -E 's/[].,;:)}>"'"'"']+$//' \
    | awk 'NF && !seen[$0]++'
}

extract_paths() {
  printf '%s\n' "${1}" \
    | grep -oE '(~|\.{1,2})?/[A-Za-z0-9._/-]+|[A-Za-z0-9._-]+/[A-Za-z0-9._/-]+' \
    | sed -E 's/[].,;:)}>"'"'"']+$//' \
    | awk 'NF && !seen[$0]++'
}

extract_words() {
  printf '%s\n' "${1}" \
    | tr '[:space:]' '\n' \
    | awk 'NF && !seen[$0]++'
}

extract_lines() {
  printf '%s\n' "${1}" \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
    | awk 'NF && !seen[$0]++'
}

extract_shas() {
  printf '%s\n' "${1}" \
    | grep -oiE '[0-9a-f]{7,40}' \
    | grep -iE '[a-f]' \
    | awk 'NF && !seen[$0]++'
}

extract_ipv4() {
  printf '%s\n' "${1}" \
    | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' \
    | awk -F. '$1<=255 && $2<=255 && $3<=255 && $4<=255 && !seen[$0]++'
}

extract_ipv6() {
  printf '%s\n' "${1}" \
    | grep -oiE '([0-9a-f]{1,4}:){7}[0-9a-f]{1,4}|([0-9a-f]{1,4}:){1,7}:|([0-9a-f]{1,4}:){1,6}:[0-9a-f]{1,4}|([0-9a-f]{1,4}:){1,5}(:[0-9a-f]{1,4}){1,2}|([0-9a-f]{1,4}:){1,4}(:[0-9a-f]{1,4}){1,3}|([0-9a-f]{1,4}:){1,3}(:[0-9a-f]{1,4}){1,4}|([0-9a-f]{1,4}:){1,2}(:[0-9a-f]{1,4}){1,5}|[0-9a-f]{1,4}:(:[0-9a-f]{1,4}){1,6}|:(:[0-9a-f]{1,4}){1,7}' \
    | awk 'NF && !seen[$0]++'
}

extract_hex_colors() {
  printf '%s\n' "${1}" \
    | grep -oiE '#([0-9a-f]{8}|[0-9a-f]{6}|[0-9a-f]{4}|[0-9a-f]{3})' \
    | awk 'NF && !seen[$0]++'
}

extract_uuids() {
  printf '%s\n' "${1}" \
    | grep -oiE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' \
    | awk 'NF && !seen[$0]++'
}

extract_numbers() {
  printf '%s\n' "${1}" \
    | grep -oE '[-+]?[0-9]+(\.[0-9]+)?' \
    | awk 'NF && !seen[$0]++'
}

extract_quoted() {
  printf '%s\n' "${1}" \
    | grep -oE '"[^"]*"'"|'[^']*'|"'`[^`]*`' \
    | sed -E 's/^.(.*).$/\1/' \
    | awk 'NF && !seen[$0]++'
}

extract_bracketed() {
  printf '%s\n' "${1}" \
    | grep -oE '\([^()]*\)|\[[^][]*\]|\{[^{}]*\}|<[^<>]*>' \
    | sed -E 's/^.(.*).$/\1/' \
    | awk 'NF && !seen[$0]++'
}

extract_custom() {
  local re="${1}"
  [[ -z "${re}" ]] && return 0
  printf '%s\n' "${2}" \
    | grep -oE "${re}" 2>/dev/null \
    | awk 'NF && !seen[$0]++'
}

extract_all() {
  { extract_urls "${1}"; extract_paths "${1}"; extract_words "${1}"; } | awk 'NF && !seen[$0]++'
}

extract_min_length() {
  local min="${1:-0}"
  case "${min}" in '' | *[!0-9]*) min=0 ;; esac
  printf '%s\n' "${2}" | awk -v m="${min}" 'NF && length($0) >= m'
}

extract_reverse() {
  printf '%s\n' "${1}" | awk 'NF{a[NR]=$0} END{for(i=NR;i>=1;i--) print a[i]}'
}

extract_regex_escape() {
  local s="${1}" out="" ch i
  for ((i = 0; i < ${#s}; i++)); do
    ch="${s:i:1}"
    case "${ch}" in
      '.' | '\' | '[' | ']' | '(' | ')' | '{' | '}' | '*' | '+' | '?' | '|' | '^' | '$')
        out+="\\${ch}" ;;
      *) out+="${ch}" ;;
    esac
  done
  printf '%s' "${out}"
}

export -f extract_urls
export -f extract_paths
export -f extract_words
export -f extract_lines
export -f extract_shas
export -f extract_ipv4
export -f extract_ipv6
export -f extract_hex_colors
export -f extract_uuids
export -f extract_numbers
export -f extract_quoted
export -f extract_bracketed
export -f extract_custom
export -f extract_all
export -f extract_min_length
export -f extract_reverse
export -f extract_regex_escape
