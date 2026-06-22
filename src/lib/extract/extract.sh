#!/usr/bin/env bash
#
# extract.sh: pure token extractors for tmux-extract-revamped.
#
# Each extractor turns captured pane text into a newline-separated, de-duplicated
# list of candidates. They are pure: text in, list out, no pane and no fzf. The
# pane capture and the picker sit behind seams in the dispatcher.

[[ -n "${_EXTRACT_REVAMPED_LOADED:-}" ]] && return 0
_EXTRACT_REVAMPED_LOADED=1

# extract_urls TEXT -> http(s), ftp, file, and git URLs, trailing punctuation
# trimmed, de-duplicated in first-seen order.
extract_urls() {
  printf '%s\n' "${1}" \
    | grep -oE '(https?|ftp|file)://[A-Za-z0-9._~:/?#@!$&'"'"'()*+,;=%-]+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
    | sed -E 's/[].,;:)}>"'"'"']+$//' \
    | awk 'NF && !seen[$0]++'
}

# extract_paths TEXT -> absolute, home, and relative file paths, de-duplicated.
extract_paths() {
  printf '%s\n' "${1}" \
    | grep -oE '(~|\.{1,2})?/[A-Za-z0-9._/-]+|[A-Za-z0-9._-]+/[A-Za-z0-9._/-]+' \
    | sed -E 's/[].,;:)}>"'"'"']+$//' \
    | awk 'NF && !seen[$0]++'
}

# extract_words TEXT -> whitespace-separated tokens, de-duplicated.
extract_words() {
  printf '%s\n' "${1}" \
    | tr '[:space:]' '\n' \
    | awk 'NF && !seen[$0]++'
}

# extract_lines TEXT -> non-blank lines, leading and trailing spaces trimmed.
extract_lines() {
  printf '%s\n' "${1}" \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
    | awk 'NF && !seen[$0]++'
}

# extract_all TEXT -> urls, then paths, then words, de-duplicated across all three
# so the most specific candidates sort first.
extract_all() {
  { extract_urls "${1}"; extract_paths "${1}"; extract_words "${1}"; } | awk 'NF && !seen[$0]++'
}

export -f extract_urls
export -f extract_paths
export -f extract_words
export -f extract_lines
export -f extract_all
