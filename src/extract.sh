#!/usr/bin/env bash
#
# extract.sh: command dispatcher for tmux-extract-revamped.
#
# Usage: extract.sh MODE TARGET_PANE
#
# Captures the target pane, extracts candidates for MODE (all, urls, paths, words,
# lines), shows them in fzf, and inserts the choice back into the pane. Designed to
# run inside a tmux popup, so the capture, the picker, and the insert are seams.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/tmux/tmux-ops.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/extract/extract.sh"

# Host-probe seams. Tests override these.
_capture_pane() {
  tmux capture-pane -t "${1}" -p -S "-$(get_tmux_option "@extract_revamped_lines" "200")" 2>/dev/null
}
_fzf() { fzf --no-sort --reverse --height=100%; }
_insert() { tmux send-keys -t "${1}" -- "${2}"; }
_navigate() {
  tmux copy-mode -t "${1}" 2>/dev/null
  tmux send-keys -t "${1}" -X search-backward "${2}" 2>/dev/null
}

# _extract_for MODE TEXT -> the candidate list for MODE.
_extract_for() {
  case "${1}" in
    urls)  extract_urls "${2}" ;;
    paths) extract_paths "${2}" ;;
    words) extract_words "${2}" ;;
    lines) extract_lines "${2}" ;;
    *)     extract_all "${2}" ;;
  esac
}

extract_run() {
  local mode="${1:-all}" target="${2:-}" action="${3:-insert}" text items selection
  text="$(_capture_pane "${target}")"
  items="$(_extract_for "${mode}" "${text}")"
  [[ -z "${items}" ]] && return 0
  selection="$(printf '%s\n' "${items}" | _fzf)"
  [[ -z "${selection}" ]] && return 0
  if [[ "${action}" == "navigate" ]]; then
    _navigate "${target}" "$(extract_regex_escape "${selection}")"
  else
    _insert "${target}" "${selection}"
  fi
}

main() {
  extract_run "${1:-all}" "${2:-}" "${3:-insert}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
