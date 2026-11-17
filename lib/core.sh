#!/bin/sh
# shellcheck disable=SC2034

[ -n "${EXTRACT_REVAMPED_CORE_LOADED:-}" ] && return 0
EXTRACT_REVAMPED_CORE_LOADED=1

readonly EXTRACT_REVAMPED_VERSION="3.1.0"
