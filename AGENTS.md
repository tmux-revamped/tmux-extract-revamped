# tmux-extract-revamped

Guidance for anyone, human or agent, changing tmux-extract-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-extract-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`extract-revamped.tmux`](extract-revamped.tmux) | The entry point TPM runs: it runs `bin/extract-revamped apply` |
| [`bin/extract-revamped`](bin/extract-revamped) | The command: `apply`, `list`, `insert`, `navigate`, `open`, `copy`, `edit`, `run`, `choose`, `doctor`, `version`, `help` and the menu. `apply` and the pick commands run without loading the interface modules |
| [`lib/extract.sh`](lib/extract.sh) | Reading the settings, the binding plan, the extractors, gathering the text, the picker and the actions |
| [`lib/patterns.sh`](lib/patterns.sh), [`lib/hints.sh`](lib/hints.sh) | The extractors for tool output, from Docker to git branches, and the letter hints drawn over a pane |
| [`lib/state.sh`](lib/state.sh) | Every global, including `EXTRACT_REVAMPED_SETTINGS`, the table of setting names and defaults the rest reads |
| [`lib/core.sh`](lib/core.sh) | The version |
| [`lib/`](lib) | Every other file is the shared library, identical in every member |
| [`test/extract.bats`](test/extract.bats), [`test/patterns.bats`](test/patterns.bats), [`test/extract-pick.bats`](test/extract-pick.bats), [`test/extract-actions.bats`](test/extract-actions.bats), [`test/hints.bats`](test/hints.bats), [`test/commands.bats`](test/commands.bats), [`test/entrypoint.bats`](test/entrypoint.bats), [`test/keys.bats`](test/keys.bats) | This member's suites: the extractors, the plan, the pickers and the hints through stubs, the commands, and the bindings, actions and key presses on a private tmux server with a plain `sh` pane; the last two share [`test/server_helpers.bash`](test/server_helpers.bash) |
| [`screens/`](screens) | The tapes, the recording's tmux config and a demo build log the tapes pick from |

## Names

- Settings are the tmux options `@extract_revamped_<setting>` listed in `EXTRACT_REVAMPED_SETTINGS`, the long options with dashes, such as `--min-length`, and the environment variables `EXTRACT_REVAMPED_<SETTING>`.
- The plugin writes `@extract_revamped_recent`, the last 20 picks, while frecency is on; it is state, never a setting.
- It has no status placeholders.
- The version constant is `EXTRACT_REVAMPED_VERSION`.

## Behaviour

- `apply` reads every setting with one `tmux display-message` call and one `env` read, reads `list-keys -T prefix` once for the default key, builds the plan, and sends every binding to tmux in one call separated by `;`.
- A key runs `display-popup -E` with one pick command and no pane, because tmux expands no format in a popup's command; the pick command reads the client's active pane, the one under the popup. A setting from a tmux option is read when the pick runs, so a change needs no reload; one `apply` got from the command line or the environment, of those in `EXTRACT_REVAMPED_PICK_NAMES`, rides on the picker keys as an option, since neither exists when tmux runs a key.
- Everything placed in a popup's command goes through `extract_revamped_quote`, which single-quotes it and writes each `#` as `"$(printf '%b' '\0043')"`, so a path or a regex holding a hash reads the same whether or not the tmux running it expands formats there.
- An empty tmux option means its default; `@extract_revamped_key` set to `none` binds no picker key.
- A default key the person bound before the plugin loaded stays theirs, and `doctor` reports it.
- The entry point clears every inherited `REVAMPED_` variable except the test switches, and every `EXTRACT_REVAMPED_*_LOADED` guard; every other global is assigned outright in the state file.

## Domain rules

- A picked token is typed with `send-keys -l`, so it reaches the pane as literal text, and several marked tokens are joined by spaces.
- Open sends a URL to `xdg-open` or `open`, starts `$EDITOR` on a path in a new window at the source pane's folder, passing the path as one argument with globbing off, and types anything else.
- A copy goes to `pbcopy` on macOS, then `wl-copy`, `xclip` and `xsel`, or out as an OSC 52 sequence when `@extract_revamped_osc52` is `1`.
- `all-panes` captures every pane of the window in one tmux call; `last-log` reads the newest file of the log folder, found by a glob and `-nt`, never by parsing `ls`.
- The chooser's mode changes are bounded at 12 rounds, so an answer that keeps changing the mode cannot loop forever.
- Edit starts `$EDITOR` on any pick, and run starts `@extract_revamped_command` through `sh -c` with each pick as its own argument, both in a new window at the pane's folder. The library function behind run is `extract_revamped_command`, because the command file owns `extract_revamped_run`.
- With the picker set to hints, on tmux 3.3 and later, each pick key runs `run-shell`, which expands the pane's size and starts `display-popup -B` over the pane with `##{popup_pane_left}` and `##{popup_pane_bottom}` left for `display-popup` to expand, since a popup's size takes no format and only those two place it right whether the status line is on top or at the bottom. The overlay binding carries `--picker hints`, and a pick draws hints only when told so on its command line or environment, so an option changed without `apply` never draws hints into the fzf popup.
- Hints label the tokens of the visible screen in reading order with one `awk` run under the C locale: the longest token wins an overlap, a token inside a longer word is skipped, and a label is drawn over the first one or two bytes of its token, so a token that starts with a multibyte character or is shorter than its label gets none.

## Release

- `EXTRACT_REVAMPED_VERSION` in [`lib/core.sh`](lib/core.sh) holds the version. Nobody edits it by hand.
- After a green `ci` run on `main`, [`release.yml`](.github/workflows/release.yml) runs semantic-release: a `feat` or `fix` since the last tag publishes a release, [`set-version.sh`](.github/scripts/set-version.sh) stamps the constant, and the notes go into [`CHANGELOG.md`](CHANGELOG.md).

## Gaps against FAMILY.md

As of 2026-11-17, none.
