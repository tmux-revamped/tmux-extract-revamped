export PS1='$ '
export PATH="/Users/Shared/demo/tmux-extract-revamped/bin:${PATH}"
export TZ=UTC EDITOR=less
unset FZF_DEFAULT_OPTS FZF_DEFAULT_COMMAND
unset KODOUGU_THEME KODOUGU_ACCENT EXTRACT_REVAMPED_THEME EXTRACT_REVAMPED_ACCENT NO_COLOR
export HOME=/Users/Shared/demo/home
cd /Users/Shared/demo/project || return 1
printf '\033]2;demo\033\134'
clear
