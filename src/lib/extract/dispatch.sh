#!/usr/bin/env bash

[[ -n "${_EXTRACT_REVAMPED_DISPATCH_LOADED:-}" ]] && return 0
_EXTRACT_REVAMPED_DISPATCH_LOADED=1

classify_target() {
  local s="${1}"
  case "${s}" in
    http://* | https://* | ftp://* | file://*) printf 'url'; return 0 ;;
    /* | ~/* | ./* | ../*) printf 'path'; return 0 ;;
  esac
  if [[ "${s}" == *@*:* && "${s%%:*}" != */* ]]; then
    printf 'other'
    return 0
  fi
  case "${s}" in
    *@*.*) printf 'url' ;;
    */*) printf 'path' ;;
    *) printf 'other' ;;
  esac
}

join_selection() {
  local sep="${1}" text="${2}"
  printf '%s\n' "${text}" \
    | awk -v s="${sep}" 'NF{a[++n]=$0} END{for(i=1;i<=n;i++) printf "%s%s",(i>1?s:""),a[i]}'
}

first_line() {
  printf '%s\n' "${1}" | awk 'NF{print; exit}'
}

next_mode() {
  local cur="${1}" list="${2}" first="" found=0 m
  for m in ${list}; do
    [[ -z "${first}" ]] && first="${m}"
    if [[ "${found}" == "1" ]]; then
      printf '%s' "${m}"
      return 0
    fi
    [[ "${m}" == "${cur}" ]] && found=1
  done
  printf '%s' "${first}"
  return 0
}

parse_expect_key() {
  printf '%s\n' "${1}" | awk 'NR==1{print; exit}'
}

parse_expect_rest() {
  printf '%s\n' "${1}" | awk 'NR>1'
}

osc52_sequence() {
  printf '\033]52;c;%s\a' "${1}"
}

frecency_reorder() {
  local recent="${1}" items="${2}"
  {
    printf '%s\n' "${items}" | grep -xF -f <(printf '%s\n' "${recent}" | awk 'NF') 2>/dev/null
    printf '%s\n' "${items}" | grep -vxF -f <(printf '%s\n' "${recent}" | awk 'NF') 2>/dev/null
  } | awk 'NF && !seen[$0]++'
}

doctor_report() {
  printf 'tmux-extract-revamped doctor\n'
  printf '  fzf picker:    %s\n' "${1}"
  printf '  url opener:    %s\n' "${2}"
  printf '  clipboard:     %s\n' "${3}"
  printf '  base64 (osc52): %s\n' "${4}"
}

export -f classify_target
export -f join_selection
export -f first_line
export -f next_mode
export -f parse_expect_key
export -f parse_expect_rest
export -f osc52_sequence
export -f frecency_reorder
export -f doctor_report
