#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRACT_CMD="${CURRENT_DIR}/src/extract.sh"

get_opt() {
  local v
  v=$(tmux show-option -gqv "${1}")
  echo "${v:-${2}}"
}

chmod +x "${EXTRACT_CMD}" 2>/dev/null || true

key="$(get_opt "@extract_revamped_key" "M-x")"
mode="$(get_opt "@extract_revamped_mode" "all")"
width="$(get_opt "@extract_revamped_popup_width" "80%")"
height="$(get_opt "@extract_revamped_popup_height" "60%")"

quoted_cmd="$(printf '%q' "${EXTRACT_CMD}")"
quoted_mode="$(printf '%q' "${mode}")"

tmux bind-key "${key}" display-popup -E -w "${width}" -h "${height}" "${quoted_cmd} ${quoted_mode} '#{pane_id}'"

bind_action() {
  local opt="${1}" action="${2}" k
  k="$(get_opt "${opt}" "")"
  if [[ -n "${k}" ]]; then
    tmux bind-key "${k}" display-popup -E -w "${width}" -h "${height}" \
      "${quoted_cmd} ${quoted_mode} '#{pane_id}' ${action}"
  fi
}

bind_action "@extract_revamped_navigate_key" "navigate"
bind_action "@extract_revamped_open_key" "open"
bind_action "@extract_revamped_copy_key" "copy"
bind_action "@extract_revamped_chooser_key" "chooser"

doctor_key="$(get_opt "@extract_revamped_doctor_key" "")"
if [[ -n "${doctor_key}" ]]; then
  tmux bind-key "${doctor_key}" display-popup -E -w "${width}" -h "${height}" \
    "${quoted_cmd} ${quoted_mode} '#{pane_id}' doctor; read -r"
fi
