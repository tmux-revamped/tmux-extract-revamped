#!/bin/sh

[ -n "${EXTRACT_REVAMPED_HINTS_LOADED:-}" ] && return 0
EXTRACT_REVAMPED_HINTS_LOADED=1

# shellcheck source=SCRIPTDIR/state.sh
. "${REVAMPED_LIB:?}/state.sh"

extract_revamped_hints_plan() {
  extract_revamped_hints_plan_label='\033[1;30;43m'
  extract_revamped_hints_plan_match='\033[1;33m'
  extract_revamped_hints_plan_rest='\033[2m'
  if [ -n "${NO_COLOR:-}" ]; then
    extract_revamped_hints_plan_label='\033[7m'
    extract_revamped_hints_plan_match='\033[1m'
    extract_revamped_hints_plan_rest=''
  fi
  printf '%s\n' "$1" | LC_ALL=C EXTRACT_REVAMPED_HINT_ITEMS="$2" awk -v keys="${EXTRACT_REVAMPED_HINT_KEYS}" -v on_label="${extract_revamped_hints_plan_label}" -v on_match="${extract_revamped_hints_plan_match}" -v on_rest="${extract_revamped_hints_plan_rest}" -v off='\033[0m' '
    function word(ch) { return ch ~ /[A-Za-z0-9_]/ }
    function bounded(text, start, len, c) {
      if (start > 1 && word(substr(c, 1, 1)) && word(substr(text, start - 1, 1))) { return 0 }
      if (word(substr(c, len, 1)) && word(substr(text, start + len, 1))) { return 0 }
      return 1
    }
    function free(row, start, len,    p) {
      for (p = start; p < start + len; p++) { if ((row, p) in taken) { return 0 } }
      return 1
    }
    function claim(row, start, len, id,    p) {
      for (p = start; p < start + len; p++) { taken[row, p] = 1 }
      begins[row, start] = id
    }
    function plain(text) { return (text == "") ? "" : ((on_rest == "") ? text : on_rest text off) }
    BEGIN {
      count = split(ENVIRON["EXTRACT_REVAMPED_HINT_ITEMS"], item, "\n")
      n = 0
      for (i = 1; i <= count; i++) {
        if (item[i] == "" || (item[i] in known)) { continue }
        known[item[i]] = 1
        cand[++n] = item[i]
      }
      for (i = 1; i <= n; i++) { order[i] = i }
      for (i = 2; i <= n; i++) {
        v = order[i]
        j = i - 1
        while (j >= 1 && length(cand[order[j]]) < length(cand[v])) { order[j + 1] = order[j]; j-- }
        order[j + 1] = v
      }
    }
    { line[NR] = $0 }
    END {
      for (r = 1; r <= NR; r++) {
        for (k = 1; k <= n; k++) {
          c = cand[order[k]]
          len = length(c)
          from = 1
          while ((at = index(substr(line[r], from), c)) > 0) {
            start = from + at - 1
            if (free(r, start, len) && bounded(line[r], start, len, c)) { claim(r, start, len, order[k]) }
            from = start + 1
          }
        }
      }
      m = 0
      for (r = 1; r <= NR; r++) {
        for (p = 1; p <= length(line[r]); p++) {
          if (!((r, p) in begins)) { continue }
          id = begins[r, p]
          if (!(id in met)) { met[id] = 1; found[++m] = id }
        }
      }
      size = length(keys)
      width = (m > size) ? 2 : 1
      used = 0
      for (i = 1; i <= m; i++) {
        c = cand[found[i]]
        if (length(c) < width || substr(c, 1, width) !~ /^[ -~]+$/ || used >= ((width == 1) ? size : size * size)) { continue }
        label[found[i]] = (width == 1) ? substr(keys, used + 1, 1) : substr(keys, int(used / size) + 1, 1) substr(keys, used % size + 1, 1)
        used++
        print "M\t" label[found[i]] "\t" c
      }
      for (r = 1; r <= NR; r++) {
        out = ""
        run = ""
        p = 1
        while (p <= length(line[r])) {
          if (((r, p) in begins) && (begins[r, p] in label)) {
            id = begins[r, p]
            tail = substr(cand[id], width + 1)
            out = out plain(run) on_label label[id] off ((tail == "") ? "" : on_match tail off)
            run = ""
            p += length(cand[id])
            continue
          }
          run = run substr(line[r], p, 1)
          p++
        }
        print "S\t" out plain(run)
      }
    }
  '
}

extract_revamped_hints_read() {
  extract_revamped_hints_read_typed=""
  while [ "${#extract_revamped_hints_read_typed}" -lt "$1" ]; do
    extract_revamped_hints_read_key=$(dd bs=1 count=1 2>/dev/null | tr -d '\000')
    case "${extract_revamped_hints_read_key}" in
    [a-z]) extract_revamped_hints_read_typed="${extract_revamped_hints_read_typed}${extract_revamped_hints_read_key}" ;;
    *) return 0 ;;
    esac
  done
  printf '%s' "${extract_revamped_hints_read_typed}"
}

extract_revamped_hints_draw() {
  printf '\033[?25l\033[H\033[2J'
  printf '%s\n' "$1" | awk -F '\t' '$1 == "S" { sub(/^S\t/, ""); printf "%s%s", (seen++ ? "\r\n" : ""), $0 }'
}

extract_revamped_hints_ask() {
  extract_revamped_hints_ask_tty=$(stty -g 2>/dev/null) || extract_revamped_hints_ask_tty=""
  [ -z "${extract_revamped_hints_ask_tty}" ] || stty -icanon -echo min 1 time 0 2>/dev/null || :
  extract_revamped_hints_ask_typed=$(extract_revamped_hints_read "$1")
  [ -z "${extract_revamped_hints_ask_tty}" ] || stty "${extract_revamped_hints_ask_tty}" 2>/dev/null || :
  printf '%s' "${extract_revamped_hints_ask_typed}"
}

extract_revamped_hints_pick() {
  EXTRACT_REVAMPED_HINT_PICK=""
  extract_revamped_hints_pick_screen=$(tmux capture-pane -p -t "$1" 2>/dev/null) || extract_revamped_hints_pick_screen=""
  extract_revamped_hints_pick_items=$(extract_revamped_candidates "$2" "${extract_revamped_hints_pick_screen}")
  [ -n "${extract_revamped_hints_pick_items}" ] || return 0
  extract_revamped_hints_pick_plan=$(extract_revamped_hints_plan "${extract_revamped_hints_pick_screen}" "${extract_revamped_hints_pick_items}")
  extract_revamped_hints_pick_first=$(printf '%s\n' "${extract_revamped_hints_pick_plan}" | awk -F '\t' '$1 == "M" { print $2; exit }')
  [ -n "${extract_revamped_hints_pick_first}" ] || return 0
  extract_revamped_hints_draw "${extract_revamped_hints_pick_plan}"
  extract_revamped_hints_pick_typed=$(extract_revamped_hints_ask "${#extract_revamped_hints_pick_first}")
  [ -n "${extract_revamped_hints_pick_typed}" ] || return 0
  EXTRACT_REVAMPED_HINT_PICK=$(printf '%s\n' "${extract_revamped_hints_pick_plan}" | awk -F '\t' -v typed="${extract_revamped_hints_pick_typed}" '$1 == "M" && $2 == typed { sub(/^M\t[^\t]*\t/, ""); print; exit }')
}

extract_revamped_hints() {
  extract_revamped_hints_pick "$2" "${EXTRACT_REVAMPED_S_mode}"
  [ -n "${EXTRACT_REVAMPED_HINT_PICK}" ] || return 0
  extract_revamped_act "$1" "$2" "${EXTRACT_REVAMPED_HINT_PICK}"
}
