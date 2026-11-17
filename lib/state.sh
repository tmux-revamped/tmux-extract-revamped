#!/bin/sh
# shellcheck disable=SC2034

[ -n "${EXTRACT_REVAMPED_STATE_LOADED:-}" ] && return 0
EXTRACT_REVAMPED_STATE_LOADED=1

EXTRACT_REVAMPED_SETTINGS='key	M-x
navigate_key
open_key
copy_key
edit_key
run_key
chooser_key
doctor_key
picker	fzf
mode	all
modes	all urls paths words lines
scope	pane
log_dir
custom_regex
command
min_length	0
reverse	0
multi	0
osc52	0
frecency	0
lines	200
popup_width	80%
popup_height	60%'
EXTRACT_REVAMPED_PICK_NAMES='mode modes scope log_dir custom_regex command min_length reverse multi osc52 frecency lines'
EXTRACT_REVAMPED_NAMES='key navigate_key open_key copy_key edit_key run_key chooser_key doctor_key picker mode modes scope log_dir custom_regex command min_length reverse multi osc52 frecency lines popup_width popup_height'
EXTRACT_REVAMPED_S_key='M-x'
EXTRACT_REVAMPED_S_navigate_key=''
EXTRACT_REVAMPED_S_open_key=''
EXTRACT_REVAMPED_S_copy_key=''
EXTRACT_REVAMPED_S_edit_key=''
EXTRACT_REVAMPED_S_run_key=''
EXTRACT_REVAMPED_S_chooser_key=''
EXTRACT_REVAMPED_S_doctor_key=''
EXTRACT_REVAMPED_S_picker='fzf'
EXTRACT_REVAMPED_S_mode='all'
EXTRACT_REVAMPED_S_modes='all urls paths words lines'
EXTRACT_REVAMPED_S_scope='pane'
EXTRACT_REVAMPED_S_log_dir=''
EXTRACT_REVAMPED_S_custom_regex=''
EXTRACT_REVAMPED_S_command=''
EXTRACT_REVAMPED_S_min_length='0'
EXTRACT_REVAMPED_S_reverse='0'
EXTRACT_REVAMPED_S_multi='0'
EXTRACT_REVAMPED_S_osc52='0'
EXTRACT_REVAMPED_S_frecency='0'
EXTRACT_REVAMPED_S_lines='200'
EXTRACT_REVAMPED_S_popup_width='80%'
EXTRACT_REVAMPED_S_popup_height='60%'
EXTRACT_REVAMPED_S_recent=''
EXTRACT_REVAMPED_RECENT=@extract_revamped_recent
EXTRACT_REVAMPED_RECENT_MAX=20
EXTRACT_REVAMPED_CHOOSER_ROUNDS=12
EXTRACT_REVAMPED_HINT_KEYS=asdfghjklqwertyuiopzxcvbnm
EXTRACT_REVAMPED_HINT_PICK=""
EXTRACT_REVAMPED_OVERLAY=0
EXTRACT_REVAMPED_QUOTE="'"
EXTRACT_REVAMPED_PLAN=""
EXTRACT_REVAMPED_TOOL=""
EXTRACT_REVAMPED_CARRIED=""
EXTRACT_REVAMPED_TAKEN=""
REVAMPED_LOG_NS=extract-revamped
