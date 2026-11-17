# shellcheck shell=bash
# shellcheck disable=SC2207

_extract_revamped() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  case "${prev}" in
  --theme)
    COMPREPLY=($(compgen -W "kodougu catppuccin-mocha catppuccin-latte dracula nord gruvbox tokyo-night mono" -- "${cur}"))
    return
    ;;
  --picker)
    COMPREPLY=($(compgen -W "fzf hints" -- "${cur}"))
    return
    ;;
  --mode)
    COMPREPLY=($(compgen -W "all urls paths words lines shas ipv4 ipv6 hex uuids numbers quoted bracketed docker kubernetes git-status diff markdown branches custom" -- "${cur}"))
    return
    ;;
  --scope)
    COMPREPLY=($(compgen -W "pane all-panes last-log" -- "${cur}"))
    return
    ;;
  --reverse)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --multi)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --osc52)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --frecency)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --key | --navigate-key | --open-key | --copy-key | --edit-key | --run-key | --chooser-key | --doctor-key | --modes | --log-dir | --custom-regex | --command | --min-length | --lines | --popup-width | --popup-height)
    return
    ;;
  *) ;;
  esac

  COMPREPLY=($(compgen -W "apply list insert navigate open copy edit run choose doctor version help --json --theme --key --navigate-key --open-key --copy-key --edit-key --run-key --chooser-key --doctor-key --picker --mode --modes --scope --log-dir --custom-regex --command --min-length --reverse --multi --osc52 --frecency --lines --popup-width --popup-height" -- "${cur}"))
}

complete -F _extract_revamped extract-revamped
