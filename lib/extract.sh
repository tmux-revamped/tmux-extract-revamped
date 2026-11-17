#!/bin/sh

[ -n "${EXTRACT_REVAMPED_EXTRACT_LOADED:-}" ] && return 0
EXTRACT_REVAMPED_EXTRACT_LOADED=1

# shellcheck source=SCRIPTDIR/state.sh
. "${REVAMPED_LIB:?}/state.sh"
# shellcheck source=SCRIPTDIR/platform.sh
. "${REVAMPED_LIB}/platform.sh"
# shellcheck source=SCRIPTDIR/command.sh
. "${REVAMPED_LIB}/command.sh"

extract_revamped_format() {
  printf '%s\n' "${EXTRACT_REVAMPED_SETTINGS}" | awk -F '\t' '{ printf "%s#{@extract_revamped_%s}", (NR > 1 ? "\t" : ""), $1 }'
}

extract_revamped_resolve() {
  env | EXTRACT_REVAMPED_ROWS="${EXTRACT_REVAMPED_SETTINGS}" EXTRACT_REVAMPED_LIVE="$1" awk '
    BEGIN {
      count = split(ENVIRON["EXTRACT_REVAMPED_ROWS"], rows, "\n")
      split(ENVIRON["EXTRACT_REVAMPED_LIVE"], live, "\t")
      for (i = 1; i <= count; i++) {
        split(rows[i], field, "\t")
        name[i] = field[1]
        value[i] = (live[i] != "") ? live[i] : field[2]
        want["EXTRACT_REVAMPED_" toupper(field[1])] = i
      }
    }
    {
      at = index($0, "=")
      key = substr($0, 1, at - 1)
      if (key in want) { value[want[key]] = substr($0, at + 1) }
    }
    END { for (i = 1; i <= count; i++) { print name[i] "\t" value[i] } }
  '
}

extract_revamped_load() {
  extract_revamped_load_format=$(extract_revamped_format)
  extract_revamped_load_live=$(tmux display-message -p "${extract_revamped_load_format}" 2>/dev/null) || extract_revamped_load_live=""
  extract_revamped_load_values=$(extract_revamped_resolve "${extract_revamped_load_live}")
  while IFS='	' read -r extract_revamped_load_name extract_revamped_load_value; do
    IFS= read -r "EXTRACT_REVAMPED_S_${extract_revamped_load_name}" <<EOF
${extract_revamped_load_value}
EOF
  done <<EOF
${extract_revamped_load_values}
EOF
}

extract_revamped_emit() {
  for extract_revamped_emit_arg in "$@"; do
    EXTRACT_REVAMPED_PLAN="${EXTRACT_REVAMPED_PLAN}${extract_revamped_emit_arg}
"
  done
  EXTRACT_REVAMPED_PLAN="${EXTRACT_REVAMPED_PLAN}
"
}

extract_revamped_send() {
  set --
  extract_revamped_send_sep=""
  while IFS= read -r extract_revamped_send_line; do
    if [ -z "${extract_revamped_send_line}" ]; then
      [ "$#" -eq 0 ] || extract_revamped_send_sep=";"
      continue
    fi
    [ -z "${extract_revamped_send_sep}" ] || set -- "$@" "${extract_revamped_send_sep}"
    extract_revamped_send_sep=""
    set -- "$@" "${extract_revamped_send_line}"
  done <<PLAN
${EXTRACT_REVAMPED_PLAN}
PLAN
  [ "$#" -gt 0 ] || return 0
  tmux "$@"
}

extract_revamped_quote() {
  printf '%s\n' "$1" | sed -e "s/'/'\\\\''/g" -e "s/#/'\"\$(printf '%b' '\\\\0043')\"'/g" -e "1s/^/'/" -e "\$s/\$/'/"
}

extract_revamped_tool() {
  extract_revamped_quote "${REVAMPED_LIB%/lib}/bin/extract-revamped"
}

extract_revamped_carried_rows() {
  env | EXTRACT_REVAMPED_ROWS="${EXTRACT_REVAMPED_PICK_NAMES}" awk '
    BEGIN {
      count = split(ENVIRON["EXTRACT_REVAMPED_ROWS"], names, " ")
      for (i = 1; i <= count; i++) { want["EXTRACT_REVAMPED_" toupper(names[i])] = i }
    }
    {
      at = index($0, "=")
      key = substr($0, 1, at - 1)
      if (key in want) { value[want[key]] = substr($0, at + 1) }
    }
    END {
      for (i = 1; i <= count; i++) {
        if (value[i] == "") { continue }
        option = names[i]
        gsub(/_/, "-", option)
        print option "\t" value[i]
      }
    }
  '
}

extract_revamped_carried() {
  extract_revamped_carried_out=""
  extract_revamped_carried_list=$(extract_revamped_carried_rows)
  while IFS='	' read -r extract_revamped_carried_name extract_revamped_carried_value; do
    [ -n "${extract_revamped_carried_name}" ] || continue
    extract_revamped_carried_out="${extract_revamped_carried_out} --${extract_revamped_carried_name} $(extract_revamped_quote "${extract_revamped_carried_value}")"
  done <<EOF
${extract_revamped_carried_list}
EOF
  printf '%s' "${extract_revamped_carried_out}"
}

extract_revamped_binding() {
  tmux list-keys -T prefix 2>/dev/null | awk -v key="$1" '{ for (i = 1; i < NF; i++) { if ($i == "-T") { if ($(i + 2) == key) { print } break } } }'
}

extract_revamped_popup() {
  extract_revamped_emit bind-key "$1" display-popup -E -w "${EXTRACT_REVAMPED_S_popup_width}" -h "${EXTRACT_REVAMPED_S_popup_height}" "$2"
}

extract_revamped_plan_main() {
  EXTRACT_REVAMPED_TAKEN=""
  case "${EXTRACT_REVAMPED_S_key}" in
  none) return 0 ;;
  *) : ;;
  esac
  extract_revamped_plan_main_bound=$(extract_revamped_binding "${EXTRACT_REVAMPED_S_key}")
  # shellcheck disable=SC2034
  case "${extract_revamped_plan_main_bound}" in
  "" | *extract-revamped*) extract_revamped_popup "${EXTRACT_REVAMPED_S_key}" "${EXTRACT_REVAMPED_TOOL}${EXTRACT_REVAMPED_CARRIED} insert" ;;
  *) EXTRACT_REVAMPED_TAKEN="${EXTRACT_REVAMPED_S_key}" ;;
  esac
}

extract_revamped_plan_action() {
  [ -n "$1" ] || return 0
  extract_revamped_popup "$1" "${EXTRACT_REVAMPED_TOOL}${EXTRACT_REVAMPED_CARRIED} $2"
}

extract_revamped_plan() {
  extract_revamped_load
  EXTRACT_REVAMPED_PLAN=""
  EXTRACT_REVAMPED_TOOL=$(extract_revamped_tool)
  EXTRACT_REVAMPED_CARRIED=$(extract_revamped_carried)
  extract_revamped_plan_main
  extract_revamped_plan_action "${EXTRACT_REVAMPED_S_navigate_key}" navigate
  extract_revamped_plan_action "${EXTRACT_REVAMPED_S_open_key}" open
  extract_revamped_plan_action "${EXTRACT_REVAMPED_S_copy_key}" copy
  extract_revamped_plan_action "${EXTRACT_REVAMPED_S_chooser_key}" choose
  [ -z "${EXTRACT_REVAMPED_S_doctor_key}" ] || extract_revamped_popup "${EXTRACT_REVAMPED_S_doctor_key}" "${EXTRACT_REVAMPED_TOOL} doctor; read -r extract_revamped_wait"
}

extract_revamped_apply() {
  extract_revamped_plan
  extract_revamped_send 2>/dev/null || extract_revamped_apply_each
}

extract_revamped_apply_each() {
  extract_revamped_apply_each_status=0
  set --
  while IFS= read -r extract_revamped_apply_each_line; do
    if [ -n "${extract_revamped_apply_each_line}" ]; then
      set -- "$@" "${extract_revamped_apply_each_line}"
      continue
    fi
    [ "$#" -gt 0 ] || continue
    tmux "$@" || extract_revamped_apply_each_status=1
    set --
  done <<PLAN
${EXTRACT_REVAMPED_PLAN}
PLAN
  return "${extract_revamped_apply_each_status}"
}

extract_revamped_unique() {
  awk 'NF && !seen[$0]++'
}

extract_revamped_trim_tail() {
  sed -E 's/[].,;:)}>"'"'"']+$//'
}

extract_revamped_urls() {
  printf '%s\n' "$1" | grep -oE '(https?|ftp|file)://[A-Za-z0-9._~:/?#@!$&'"'"'()*+,;=%-]+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' | extract_revamped_trim_tail | extract_revamped_unique
}

extract_revamped_paths() {
  printf '%s\n' "$1" | grep -oE '(~|\.{1,2})?/[A-Za-z0-9._/-]+|[A-Za-z0-9._-]+/[A-Za-z0-9._/-]+' | extract_revamped_trim_tail | extract_revamped_unique
}

extract_revamped_words() {
  printf '%s\n' "$1" | tr '[:space:]' '\n' | extract_revamped_unique
}

extract_revamped_lines() {
  printf '%s\n' "$1" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | extract_revamped_unique
}

extract_revamped_shas() {
  printf '%s\n' "$1" | grep -oiE '[0-9a-f]{7,40}' | grep -iE '[a-f]' | extract_revamped_unique
}

extract_revamped_ipv4() {
  printf '%s\n' "$1" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | awk -F. '$1 <= 255 && $2 <= 255 && $3 <= 255 && $4 <= 255 && !seen[$0]++'
}

extract_revamped_ipv6() {
  printf '%s\n' "$1" | grep -oiE '([0-9a-f]{1,4}:){7}[0-9a-f]{1,4}|([0-9a-f]{1,4}:){1,7}:|([0-9a-f]{1,4}:){1,6}:[0-9a-f]{1,4}|([0-9a-f]{1,4}:){1,5}(:[0-9a-f]{1,4}){1,2}|([0-9a-f]{1,4}:){1,4}(:[0-9a-f]{1,4}){1,3}|([0-9a-f]{1,4}:){1,3}(:[0-9a-f]{1,4}){1,4}|([0-9a-f]{1,4}:){1,2}(:[0-9a-f]{1,4}){1,5}|[0-9a-f]{1,4}:(:[0-9a-f]{1,4}){1,6}|:(:[0-9a-f]{1,4}){1,7}' | extract_revamped_unique
}

extract_revamped_hex() {
  printf '%s\n' "$1" | grep -oiE '#([0-9a-f]{8}|[0-9a-f]{6}|[0-9a-f]{4}|[0-9a-f]{3})' | extract_revamped_unique
}

extract_revamped_uuids() {
  printf '%s\n' "$1" | grep -oiE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | extract_revamped_unique
}

extract_revamped_numbers() {
  printf '%s\n' "$1" | grep -oE '[-+]?[0-9]+(\.[0-9]+)?' | extract_revamped_unique
}

extract_revamped_quoted() {
  # shellcheck disable=SC2016
  printf '%s\n' "$1" | grep -oE '"[^"]*"'"|'[^']*'|"'`[^`]*`' | sed -E 's/^.(.*).$/\1/' | extract_revamped_unique
}

extract_revamped_bracketed() {
  printf '%s\n' "$1" | grep -oE '\([^()]*\)|\[[^][]*\]|\{[^{}]*\}|<[^<>]*>' | sed -E 's/^.(.*).$/\1/' | extract_revamped_unique
}

extract_revamped_custom() {
  [ -n "$1" ] || return 0
  printf '%s\n' "$2" | grep -oE "$1" 2>/dev/null | extract_revamped_unique
}

extract_revamped_all() {
  {
    extract_revamped_urls "$1"
    extract_revamped_paths "$1"
    extract_revamped_words "$1"
  } | extract_revamped_unique
}

extract_revamped_for() {
  case "$1" in
  urls) extract_revamped_urls "$2" ;;
  paths) extract_revamped_paths "$2" ;;
  words) extract_revamped_words "$2" ;;
  lines) extract_revamped_lines "$2" ;;
  shas) extract_revamped_shas "$2" ;;
  ipv4) extract_revamped_ipv4 "$2" ;;
  ipv6) extract_revamped_ipv6 "$2" ;;
  color | colors | hex) extract_revamped_hex "$2" ;;
  uuid | uuids) extract_revamped_uuids "$2" ;;
  numbers | nums) extract_revamped_numbers "$2" ;;
  quoted) extract_revamped_quoted "$2" ;;
  bracketed) extract_revamped_bracketed "$2" ;;
  custom) extract_revamped_custom "${EXTRACT_REVAMPED_S_custom_regex}" "$2" ;;
  *) extract_revamped_all "$2" ;;
  esac
}

extract_revamped_min_length() {
  extract_revamped_min_length_min="$1"
  case "${extract_revamped_min_length_min}" in
  "" | *[!0-9]*) extract_revamped_min_length_min=0 ;;
  *) : ;;
  esac
  printf '%s\n' "$2" | awk -v m="${extract_revamped_min_length_min}" 'NF && length($0) >= m'
}

extract_revamped_reverse() {
  printf '%s\n' "$1" | awk 'NF { a[++n] = $0 } END { for (i = n; i >= 1; i--) { print a[i] } }'
}

extract_revamped_frecency() {
  printf '%s\n' "$2" | EXTRACT_REVAMPED_RECENT_LIST="$1" awk '
    BEGIN { count = split(ENVIRON["EXTRACT_REVAMPED_RECENT_LIST"], recent, "\n"); for (i = 1; i <= count; i++) { if (recent[i] != "") { known[recent[i]] = 1 } } }
    NF && !seen[$0]++ { if ($0 in known) { print } else { rest[++n] = $0 } }
    END { for (i = 1; i <= n; i++) { print rest[i] } }
  '
}

extract_revamped_candidates() {
  extract_revamped_candidates_items=$(extract_revamped_for "$1" "$2")
  extract_revamped_candidates_items=$(extract_revamped_min_length "${EXTRACT_REVAMPED_S_min_length}" "${extract_revamped_candidates_items}")
  [ "${EXTRACT_REVAMPED_S_reverse}" != 1 ] || extract_revamped_candidates_items=$(extract_revamped_reverse "${extract_revamped_candidates_items}")
  [ "${EXTRACT_REVAMPED_S_frecency}" != 1 ] || extract_revamped_candidates_items=$(extract_revamped_frecency "${EXTRACT_REVAMPED_S_recent}" "${extract_revamped_candidates_items}")
  printf '%s' "${extract_revamped_candidates_items}"
}

extract_revamped_newest() {
  extract_revamped_newest_file=""
  for extract_revamped_newest_path in "$1"/* "$1"/.[!.]*; do
    [ -f "${extract_revamped_newest_path}" ] || continue
    [ -z "${extract_revamped_newest_file}" ] || [ "${extract_revamped_newest_path}" -nt "${extract_revamped_newest_file}" ] || continue
    extract_revamped_newest_file="${extract_revamped_newest_path}"
  done
  [ -z "${extract_revamped_newest_file}" ] || cat "${extract_revamped_newest_file}"
}

extract_revamped_all_panes() {
  extract_revamped_all_panes_ids=$(tmux list-panes -F '#{pane_id}' 2>/dev/null) || return 0
  set --
  for extract_revamped_all_panes_id in ${extract_revamped_all_panes_ids}; do
    [ "$#" -eq 0 ] || set -- "$@" ";"
    set -- "$@" capture-pane -p -t "${extract_revamped_all_panes_id}" -S "-${EXTRACT_REVAMPED_S_lines}"
  done
  [ "$#" -eq 0 ] || tmux "$@" 2>/dev/null
}

extract_revamped_gather() {
  case "${EXTRACT_REVAMPED_S_scope}" in
  all-panes) extract_revamped_all_panes ;;
  last-log) extract_revamped_newest "${EXTRACT_REVAMPED_S_log_dir:-${HOME}/.tmux/logging-revamped}" ;;
  *) tmux capture-pane -p -t "$1" -S "-${EXTRACT_REVAMPED_S_lines}" 2>/dev/null ;;
  esac
}

extract_revamped_classify() {
  # shellcheck disable=SC2088
  case "$1" in
  http://* | https://* | ftp://* | file://*) printf 'url' ;;
  /* | "~/"* | ./* | ../*) printf 'path' ;;
  *@*:*) extract_revamped_classify_remote "$1" ;;
  *) extract_revamped_classify_rest "$1" ;;
  esac
}

extract_revamped_classify_remote() {
  case "${1%%:*}" in
  */*) extract_revamped_classify_rest "$1" ;;
  *) printf 'other' ;;
  esac
}

extract_revamped_classify_rest() {
  case "$1" in
  *@*.*) printf 'url' ;;
  */*) printf 'path' ;;
  *) printf 'other' ;;
  esac
}

extract_revamped_join() {
  printf '%s\n' "$1" | awk 'NF { a[++n] = $0 } END { for (i = 1; i <= n; i++) { printf "%s%s", (i > 1 ? " " : ""), a[i] } }'
}

extract_revamped_first() {
  printf '%s\n' "$1" | awk 'NF { print; exit }'
}

extract_revamped_next_mode() {
  extract_revamped_next_mode_first=""
  extract_revamped_next_mode_found=0
  for extract_revamped_next_mode_name in $2; do
    [ -n "${extract_revamped_next_mode_first}" ] || extract_revamped_next_mode_first="${extract_revamped_next_mode_name}"
    if [ "${extract_revamped_next_mode_found}" = 1 ]; then
      printf '%s' "${extract_revamped_next_mode_name}"
      return 0
    fi
    [ "${extract_revamped_next_mode_name}" != "$1" ] || extract_revamped_next_mode_found=1
  done
  printf '%s' "${extract_revamped_next_mode_first}"
}

extract_revamped_regex_escape() {
  printf '%s\n' "$1" | sed 's/[].\\[(){}*+?|^$]/\\&/g'
}

extract_revamped_osc52() {
  extract_revamped_osc52_data=$(printf '%s' "$1" | base64 | tr -d '\n')
  printf '\033]52;c;%s\007' "${extract_revamped_osc52_data}"
}

extract_revamped_clipboard() {
  if revamped_is_macos && revamped_has_command pbcopy; then
    printf 'pbcopy'
  elif revamped_has_command wl-copy; then
    printf 'wl-copy'
  elif revamped_has_command xclip; then
    printf 'xclip'
  elif revamped_has_command xsel; then
    printf 'xsel'
  fi
}

extract_revamped_copy() {
  if [ "${EXTRACT_REVAMPED_S_osc52}" = 1 ]; then
    extract_revamped_osc52 "$1"
    return 0
  fi
  case "$(extract_revamped_clipboard)" in
  pbcopy) printf '%s' "$1" | pbcopy ;;
  wl-copy) printf '%s' "$1" | wl-copy ;;
  xclip) printf '%s' "$1" | xclip -selection clipboard -in ;;
  xsel) printf '%s' "$1" | xsel --clipboard --input ;;
  *)
    printf 'extract-revamped: no clipboard tool found, so nothing was copied. install pbcopy, wl-copy, xclip or xsel, or set @extract_revamped_osc52 to 1.\n' >&2
    return 1
    ;;
  esac
}

extract_revamped_opener() {
  if revamped_has_command xdg-open; then
    printf 'xdg-open'
  elif revamped_has_command open; then
    printf 'open'
  fi
}

extract_revamped_open_path() {
  extract_revamped_open_path_file="$2"
  # shellcheck disable=SC2088
  case "${extract_revamped_open_path_file}" in
  "~/"*) extract_revamped_open_path_file="${HOME}/${extract_revamped_open_path_file#"~/"}" ;;
  *) : ;;
  esac
  extract_revamped_open_path_dir=$(tmux display-message -p -t "$1" '#{pane_current_path}' 2>/dev/null) || extract_revamped_open_path_dir=""
  extract_revamped_open_path_dir=$(printf '%s\n' "${extract_revamped_open_path_dir:-${PWD}}" | sed 's/#/##/g')
  # shellcheck disable=SC2016
  tmux new-window -c "${extract_revamped_open_path_dir}" -- sh -c 'set -f; exec $1 "$2"' extract-revamped "${EDITOR:-vi}" "${extract_revamped_open_path_file}" 2>/dev/null || :
}

extract_revamped_open() {
  extract_revamped_open_first=$(extract_revamped_first "$2")
  case "$(extract_revamped_classify "${extract_revamped_open_first}")" in
  url)
    extract_revamped_open_tool=$(extract_revamped_opener)
    [ -z "${extract_revamped_open_tool}" ] || "${extract_revamped_open_tool}" "${extract_revamped_open_first}" >/dev/null 2>&1 || :
    ;;
  path) extract_revamped_open_path "$1" "${extract_revamped_open_first}" ;;
  *) tmux send-keys -t "$1" -l -- "${extract_revamped_open_first}" ;;
  esac
}

extract_revamped_record() {
  [ "${EXTRACT_REVAMPED_S_frecency}" = 1 ] || return 0
  extract_revamped_record_first=$(extract_revamped_first "$1")
  extract_revamped_record_list=$(printf '%s\n%s\n' "${extract_revamped_record_first}" "${EXTRACT_REVAMPED_S_recent}" | awk -v max="${EXTRACT_REVAMPED_RECENT_MAX}" 'NF && !seen[$0]++ && ++n <= max')
  tmux set-option -gq "${EXTRACT_REVAMPED_RECENT}" "${extract_revamped_record_list}"
}

extract_revamped_act() {
  extract_revamped_record "$3"
  case "$1" in
  navigate)
    extract_revamped_act_first=$(extract_revamped_first "$3")
    extract_revamped_act_pattern=$(extract_revamped_regex_escape "${extract_revamped_act_first}")
    tmux copy-mode -t "$2" \; send-keys -t "$2" -X search-backward "${extract_revamped_act_pattern}" 2>/dev/null || :
    ;;
  open) extract_revamped_open "$2" "$3" ;;
  copy) extract_revamped_copy "$3" ;;
  *)
    extract_revamped_act_text=$(extract_revamped_join "$3")
    tmux send-keys -t "$2" -l -- "${extract_revamped_act_text}"
    ;;
  esac
}

extract_revamped_fzf() {
  if [ "${EXTRACT_REVAMPED_S_multi}" = 1 ]; then
    fzf --no-sort --reverse --height=100% --multi
    return 0
  fi
  fzf --no-sort --reverse --height=100%
}

extract_revamped_choose() {
  extract_revamped_choose_mode="${EXTRACT_REVAMPED_S_mode}"
  extract_revamped_choose_round=0
  while [ "${extract_revamped_choose_round}" -lt "${EXTRACT_REVAMPED_CHOOSER_ROUNDS}" ]; do
    extract_revamped_choose_round=$((extract_revamped_choose_round + 1))
    extract_revamped_choose_items=$(extract_revamped_candidates "${extract_revamped_choose_mode}" "$2")
    [ -n "${extract_revamped_choose_items}" ] || return 0
    extract_revamped_choose_out=$(printf '%s\n' "${extract_revamped_choose_items}" | fzf --no-sort --reverse --height=100% --multi --expect=ctrl-o,ctrl-y,ctrl-n --header "${extract_revamped_choose_mode}: Enter types, C-o opens, C-y copies, C-n next mode") || :
    extract_revamped_choose_key=$(printf '%s\n' "${extract_revamped_choose_out}" | sed -n 1p)
    extract_revamped_choose_pick=$(printf '%s\n' "${extract_revamped_choose_out}" | sed 1d)
    [ -n "${extract_revamped_choose_pick}" ] || return 0
    case "${extract_revamped_choose_key}" in
    ctrl-n) extract_revamped_choose_mode=$(extract_revamped_next_mode "${extract_revamped_choose_mode}" "${EXTRACT_REVAMPED_S_modes}") ;;
    ctrl-o)
      extract_revamped_act open "$1" "${extract_revamped_choose_pick}"
      return 0
      ;;
    ctrl-y)
      extract_revamped_act copy "$1" "${extract_revamped_choose_pick}"
      return 0
      ;;
    *)
      extract_revamped_act insert "$1" "${extract_revamped_choose_pick}"
      return 0
      ;;
    esac
  done
}

extract_revamped_pane() {
  [ -z "$1" ] || {
    printf '%s' "$1"
    return 0
  }
  tmux display-message -p '#{pane_id}' 2>/dev/null || :
}

extract_revamped_pick() {
  extract_revamped_pick_pane=$(extract_revamped_pane "${2:-}")
  set -- "$1" "${extract_revamped_pick_pane}"
  extract_revamped_load
  [ "${EXTRACT_REVAMPED_S_frecency}" != 1 ] || EXTRACT_REVAMPED_S_recent=$(tmux show-option -gqv "${EXTRACT_REVAMPED_RECENT}" 2>/dev/null) || EXTRACT_REVAMPED_S_recent=""
  extract_revamped_pick_text=$(extract_revamped_gather "$2")
  if [ "$1" = choose ]; then
    extract_revamped_choose "$2" "${extract_revamped_pick_text}"
    return 0
  fi
  extract_revamped_pick_items=$(extract_revamped_candidates "${EXTRACT_REVAMPED_S_mode}" "${extract_revamped_pick_text}")
  [ -n "${extract_revamped_pick_items}" ] || return 0
  extract_revamped_pick_choice=$(printf '%s\n' "${extract_revamped_pick_items}" | extract_revamped_fzf) || :
  [ -n "${extract_revamped_pick_choice}" ] || return 0
  extract_revamped_act "$1" "$2" "${extract_revamped_pick_choice}"
}

extract_revamped_lines_of_plan() {
  printf '%s' "${EXTRACT_REVAMPED_PLAN}" | awk 'NF == 0 && line != "" { print line; line = ""; next } NF == 0 { next } { line = (line == "" ? $0 : line " " $0) } END { if (line != "") { print line } }'
}

extract_revamped_json() {
  printf '%s' "${EXTRACT_REVAMPED_PLAN}" | awk '
    function quote(s,    out, i, c) {
      out = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\\") { out = out "\\\\" } else if (c == "\"") { out = out "\\\"" } else { out = out c }
      }
      return "\"" out "\""
    }
    /^$/ { if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" } args = ""; next }
    { args = args (args == "" ? "" : ",") quote($0) }
    END {
      if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" }
      print "{\"bindings\":[" rows "]}"
    }
  '
}

extract_revamped_bindings() {
  printf '%s' "${EXTRACT_REVAMPED_PLAN}" | awk 'previous == "" && $0 == "bind-key" { count++ } { previous = $0 } END { print count + 0 }'
}

extract_revamped_setting_name() {
  extract_revamped_setting_name_raw=$(printf '%s\n' "${1#--}" | tr '-' '_')
  case " ${EXTRACT_REVAMPED_NAMES} " in
  *" ${extract_revamped_setting_name_raw} "*) printf '%s\n' "${extract_revamped_setting_name_raw}" ;;
  *) printf '\n' ;;
  esac
}
