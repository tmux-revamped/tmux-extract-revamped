# tmux-extract-revamped

Guidance for anyone, human or agent, changing tmux-extract-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-extract-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`extract-revamped.tmux`](extract-revamped.tmux) | The entry point TPM runs: it runs `bin/extract-revamped apply` |
| [`bin/extract-revamped`](bin/extract-revamped) | The command: `apply`, `list`, `insert`, `navigate`, `open`, `copy`, `choose`, `doctor`, `version`, `help` and the menu. `apply` and the pick commands run without loading the interface modules |
| [`lib/extract.sh`](lib/extract.sh) | Reading the settings, the binding plan, the extractors, gathering the text, the picker and the actions |
| [`lib/state.sh`](lib/state.sh) | Every global, including `EXTRACT_REVAMPED_SETTINGS`, the table of setting names and defaults the rest reads |
| [`lib/core.sh`](lib/core.sh) | The version |
| [`lib/`](lib) | Every other file is the shared library, identical in every member |
| [`test/extract.bats`](test/extract.bats), [`test/commands.bats`](test/commands.bats), [`test/entrypoint.bats`](test/entrypoint.bats) | This member's suites: the extractors, the plan and the pickers through stubs, the commands, and the bindings and actions on a private tmux server with a plain `sh` pane |
| [`screens/`](screens) | The tapes, the recording's tmux config and a demo build log the tapes pick from |

## Names

- Settings are the tmux options `@extract_revamped_<setting>` listed in `EXTRACT_REVAMPED_SETTINGS`, the long options with dashes, such as `--min-length`, and the environment variables `EXTRACT_REVAMPED_<SETTING>`.
- The plugin writes `@extract_revamped_recent`, the last 20 picks, while frecency is on; it is state, never a setting.
- It has no status placeholders.
- The version constant is `EXTRACT_REVAMPED_VERSION`.

## Behaviour

- `apply` reads every setting with one `tmux display-message` call and one `env` read, reads `list-keys -T prefix` once for the default key, builds the plan, and sends every binding to tmux in one call separated by `;`.
- A key runs `display-popup -E` with one pick command and no pane, because tmux expands no format in a popup's command; the pick command reads the client's active pane, the one under the popup, and the settings when it runs, so a setting change needs no reload.
- An empty tmux option means its default; `@extract_revamped_key` set to `none` binds no picker key.
- A default key the person bound before the plugin loaded stays theirs, and `doctor` reports it.
- The entry point clears every inherited `REVAMPED_` variable except the test switches, and every `EXTRACT_REVAMPED_*_LOADED` guard; every other global is assigned outright in the state file.

## Domain rules

- A picked token is typed with `send-keys -l`, so it reaches the pane as literal text, and several marked tokens are joined by spaces.
- Open sends a URL to `xdg-open` or `open`, starts `$EDITOR` on a path in a new window at the source pane's folder, passing the path as one argument with globbing off, and types anything else.
- A copy goes to `pbcopy` on macOS, then `wl-copy`, `xclip` and `xsel`, or out as an OSC 52 sequence when `@extract_revamped_osc52` is `1`.
- `all-panes` captures every pane of the window in one tmux call; `last-log` reads the newest file of the log folder, found by a glob and `-nt`, never by parsing `ls`.
- The chooser's mode changes are bounded at 12 rounds, so an answer that keeps changing the mode cannot loop forever.

## Release

- `EXTRACT_REVAMPED_VERSION` in [`lib/core.sh`](lib/core.sh) holds the version. Nobody edits it by hand.
- After a green `ci` run on `main`, [`release.yml`](.github/workflows/release.yml) runs semantic-release: a `feat` or `fix` since the last tag publishes a release, [`set-version.sh`](.github/scripts/set-version.sh) stamps the constant, and the notes go into [`CHANGELOG.md`](CHANGELOG.md).

## Gaps against FAMILY.md

As of 2026-11-16:

- Only `prefix M-x` is pressed through a real client in a test; the navigate, open, copy, chooser and doctor keys are checked as bindings and their commands called directly.
