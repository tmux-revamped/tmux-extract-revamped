<div align="center">

# tmux-extract-revamped

<strong>Pick a URL, path, hash or any other token off the screen with fzf and type it at the cursor, in pure shell.</strong>

English &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-extract-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-extract-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-extract-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-extract-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-extract-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-extract-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-extract-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#quick-start"><strong>Quick start</strong></a> &nbsp;|&nbsp;
  <a href="#usage">Usage</a> &nbsp;|&nbsp;
  <a href="#modes">Modes</a> &nbsp;|&nbsp;
  <a href="#screens">Screens</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="extract-revamped picking a URL off a build log with fzf and typing it at the prompt" width="800">
</p>

```console
$ EXTRACT_REVAMPED_OPEN_KEY=o extract-revamped list
bind-key M-x display-popup -E -w 80% -h 60% '/home/user/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped' insert '#{pane_id}'
bind-key o display-popup -E -w 80% -h 60% '/home/user/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped' open '#{pane_id}'
```

Press `prefix M-x` and a popup lists every URL, path and word on the screen in fzf. Pick one and it is typed at the cursor of the pane you were in, as literal text. Other keys open the token, copy it, or find it in copy-mode.

---

## Quick start

### Prerequisites

| Tool | Version | Used for |
|:-----|:--------|:---------|
| tmux | 3.2 or later | the popup |
| fzf | any | the picker; `doctor` reports it missing |
| opener | optional | `open` on macOS or `xdg-open` on Linux, for URLs |
| clipboard tool | optional | `pbcopy` on macOS, `wl-copy`, `xclip` or `xsel` on Linux, or OSC 52 through `base64` |
| gum | optional | the menu, tables and colours of `extract-revamped`; without it every command prints plain text |

### Install

```tmux
set -g @plugin 'tmux-revamped/tmux-extract-revamped'
```

Then press `prefix + I`. Without TPM, clone the repository and run its entry point from `~/.tmux.conf`:

```bash
git clone https://github.com/tmux-revamped/tmux-extract-revamped ~/.tmux/plugins/tmux-extract-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-extract-revamped/extract-revamped.tmux
```

`make install` in the clone also puts `extract-revamped` in `~/.local/bin`, with its man page and completions under `~/.local/share`.

### Verify

```bash
~/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped doctor
```

## Usage

| Key | Action | Default |
|:----|:-------|:--------|
| `prefix M-x` | Pick a token and type it at the cursor | bound |
| `@extract_revamped_navigate_key` | Pick a token and find it in copy-mode | unbound |
| `@extract_revamped_open_key` | Pick a token and open it: a URL in the browser, a path in `$EDITOR` in a new window, anything else typed | unbound |
| `@extract_revamped_copy_key` | Pick a token and copy it | unbound |
| `@extract_revamped_edit_key` | Pick a token and open it in `$EDITOR` in a new window, whatever it is | unbound |
| `@extract_revamped_run_key` | Pick a token and run `@extract_revamped_command` on it in a new window | unbound |
| `@extract_revamped_chooser_key` | Pick in a chooser: `Enter` types, `C-o` opens, `C-y` copies, `C-e` edits, `C-x` runs your command, `C-n` moves to the next mode | unbound |
| `@extract_revamped_doctor_key` | The doctor report in a popup | unbound |

`M-x` is this plugin's slot in the family key allocation. When you already bound `prefix M-x` yourself, the plugin leaves it alone and `doctor` says so; set `@extract_revamped_key` to another key, or to `none` for no key.

| Command | What it does |
|:--------|:-------------|
| `extract-revamped apply` | Binds the keys now; the entry point runs it when tmux loads the plugin |
| `extract-revamped list` | Prints every binding apply would make; `--json` prints one object |
| `extract-revamped insert`, `navigate`, `open`, `copy`, `edit`, `run`, `choose` `PANE` | Run a picker on a pane; the keys run these in a popup |
| `extract-revamped doctor` | One row per dependency, a default key someone else holds included |
| `extract-revamped version` | The version, then the tmux version |
| `extract-revamped help` | The help page; `man extract-revamped` documents the same commands and settings |
| `extract-revamped` | On a terminal, a menu |

| tmux option | Default | Meaning |
|:------------|:--------|:--------|
| `@extract_revamped_key` | `M-x` | Prefix key of the insert picker; `none` for no key |
| `@extract_revamped_picker` | `fzf` | `hints` draws a letter over each token on the pane itself and acts on the one whose letter you type; needs tmux 3.3 and takes effect after `extract-revamped apply` |
| `@extract_revamped_mode` | `all` | What to pick, one of the modes below |
| `@extract_revamped_modes` | `all urls paths words lines` | Modes `C-n` cycles in the chooser |
| `@extract_revamped_scope` | `pane` | Text to read: `pane`, `all-panes` of the window, or `last-log`, the newest file in the log folder |
| `@extract_revamped_log_dir` | `~/.tmux/logging-revamped` | Folder `last-log` reads |
| `@extract_revamped_custom_regex` | none | Extended regex of the `custom` mode |
| `@extract_revamped_command` | none | Shell command the run action starts in a new window at the pane's folder, with each pick as `"$1"`, `"$2"` and so on, such as `git show "$1"` |
| `@extract_revamped_min_length` | `0` | Drop tokens shorter than this |
| `@extract_revamped_reverse` | `0` | `1` puts the last match on screen first |
| `@extract_revamped_multi` | `0` | `1` lets fzf mark several tokens with `Tab`; insert types them joined by spaces |
| `@extract_revamped_osc52` | `0` | `1` copies with an OSC 52 sequence instead of a clipboard tool |
| `@extract_revamped_frecency` | `0` | `1` puts recent picks first, keeping the last 20 in `@extract_revamped_recent` |
| `@extract_revamped_lines` | `200` | Scrollback lines read above the screen |
| `@extract_revamped_popup_width` | `80%` | Popup width |
| `@extract_revamped_popup_height` | `60%` | Popup height |

A setting given as a tmux option is read when a key runs, so a change takes effect on the next pick, and one given to `extract-revamped apply` on the command line or in the environment rides on the keys it binds; the keys themselves take effect after `extract-revamped apply` or a config reload. Every option is also a command option with dashes, such as `--min-length 4`, and an environment variable, such as `EXTRACT_REVAMPED_MIN_LENGTH`; the command line wins over the environment, and the environment over the tmux option. An empty tmux option means its default.

<a id="modes"></a>

## Modes

| Mode | Picks |
|:-----|:------|
| `all` | URLs, paths and words, without repeats |
| `urls` | `http`, `https`, `ftp` and `file` URLs, and email addresses, with trailing punctuation removed |
| `paths` | Absolute, home, `./` and `../` paths, and any word with a slash |
| `words` | Every word between blanks |
| `lines` | Every non-blank line, trimmed |
| `shas` | Hex object names of 7 to 40 characters that hold a letter |
| `ipv4`, `ipv6` | Addresses, with out-of-range IPv4 octets dropped |
| `hex` | Hex colours such as `#a1b2c3` |
| `uuids` | Canonical UUIDs |
| `numbers` | Integers and decimals, with their sign |
| `quoted` | Text inside double quotes, single quotes or backticks |
| `bracketed` | Text inside parentheses, square, curly or angle brackets |
| `docker` | Container ids, image references such as `ghcr.io/acme/api:1.4.2`, and `sha256` digests |
| `kubernetes` | Resource names such as `pod/web-0` and `deployment.apps/web`, and generated pod names such as `web-7d4b9c6f5-x2k9q` |
| `git-status` | The files `git status` lists, in its long and short forms, both sides of a rename included |
| `diff` | The files a diff names in its `diff --git`, `---` and `+++` lines |
| `markdown` | The target of each Markdown link |
| `branches` | Branch and tag names from `git status`, `git branch` and the decorations of `git log` |
| `custom` | Matches of `@extract_revamped_custom_regex` |

A picked token is typed with `send-keys -l`, so a token such as `Enter` is typed as text rather than pressed. Open starts the editor with the path as one argument, from the folder of the pane the key was pressed in.

With `@extract_revamped_picker hints`, a key covers the pane with a borderless popup, draws a letter over the start of each token on the visible screen, and acts on the token whose letter you type, or two letters when the screen holds more than 26 tokens. Any other key closes it. Hints read the visible screen only, whatever `@extract_revamped_scope` says, and the chooser keeps fzf.

<a id="screens"></a>

## Screens

<details>
<summary>Every screen, recorded inside a real tmux with <code>make screens</code>, with each key on the status line</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/picker.png" alt="extract-revamped: prefix M-x lists every token on the screen"><br><sub><code>prefix M-x</code> lists every token on the screen, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/inserted.png" alt="extract-revamped: The picked URL typed at the prompt"><br><sub>The picked URL typed at the prompt, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/urls.png" alt="extract-revamped: @extract_revamped_mode urls lists URLs only"><br><sub><code>@extract_revamped_mode urls</code> lists URLs only, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/navigate.png" alt="extract-revamped: The navigate key finds the token in copy-mode"><br><sub>The navigate key finds the token in copy-mode, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/open.png" alt="extract-revamped: The open key shows a path in the editor"><br><sub>The open key shows a path in the editor, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/copy.png" alt="extract-revamped: The copy key puts the token on the clipboard"><br><sub>The copy key puts the token on the clipboard, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/chooser.png" alt="extract-revamped: The chooser after C-n, in a 60% popup"><br><sub>The chooser after <code>C-n</code>, in a 60% popup, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/filters.png" alt="extract-revamped: Minimum length, reverse order and two marked tokens"><br><sub>Minimum length, reverse order and two marked tokens, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/all-panes.png" alt="extract-revamped: @extract_revamped_scope all-panes reads the other pane"><br><sub><code>@extract_revamped_scope all-panes</code> reads the other pane, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/modes.png" alt="extract-revamped: The git-status mode lists the files of a git status"><br><sub>The git-status mode lists the files of a git status, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/edit.png" alt="extract-revamped: The edit picker opens the pick in the editor"><br><sub>The edit picker opens the pick in the editor, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/run.png" alt="extract-revamped: The run picker starts your command on the pick"><br><sub>The run picker starts your command on the pick, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/hints.png" alt="extract-revamped: Letter hints drawn over the pane"><br><sub>Letter hints drawn over the pane, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/hints-typed.png" alt="extract-revamped: The token typed after its letter"><br><sub>The token typed after its letter, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/doctor-popup.png" alt="extract-revamped: The doctor key"><br><sub>The doctor key, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="extract-revamped: The menu"><br><sub>The menu, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="extract-revamped: doctor"><br><sub><code>doctor</code>, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="extract-revamped: list"><br><sub><code>list</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="extract-revamped: list --json"><br><sub><code>list --json</code>, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="extract-revamped: The menu without gum"><br><sub>The menu without gum, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="extract-revamped: apply from the menu"><br><sub><code>apply</code> from the menu, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="extract-revamped: The version"><br><sub>The version, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="extract-revamped: An unknown command"><br><sub>An unknown command, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="extract-revamped: The header in six themes"><br><sub>The header in six themes, from <code>themes.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="extract-revamped: The help page"><br><sub>The help page, from <code>help.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="extract-revamped: An accent from EXTRACT_REVAMPED_ACCENT"><br><sub>An accent from <code>EXTRACT_REVAMPED_ACCENT</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## Portability

The plugin is POSIX `sh`. CI runs every suite on each row below.

| Shell | Status |
|:------|:-------|
| `dash`, `/bin/sh` on macOS | Supported |
| `bash` 3.2 and 5.x, the system's `zsh` and Homebrew's | Supported |

| System | Status |
|:-------|:-------|
| macOS | Tahoe on Apple Silicon and Intel, with the tools it ships, Homebrew's GNU tools and Homebrew's uutils |
| Linux | Ubuntu 26.04 on x86_64 and arm64, with GNU coreutils, uutils and BusyBox |

## Development

| Command | What it runs |
|:--------|:-------------|
| `make fmt` | shfmt `-i 2` on every script |
| `make lint` | shfmt, ShellCheck, mandoc, yamllint and actionlint, at zero findings |
| `make test` | The bats suites under the system `sh` |
| `make test-all` | The suites under every installed shell, both builds of bash and zsh on macOS |
| `make test-linux` | The suites in an Ubuntu container |
| `make coverage` | bashcov on this Mac and in the Ubuntu container, merged and gated at 100 percent |
| `make screens` | The screens above, recorded from the real plugin inside tmux with VHS, on macOS |
| `make install` | The command, its man page and completions under `PREFIX` |

On macOS, `brew bundle` installs every tool these targets call, from the [`Brewfile`](Brewfile).

Commits follow the conventional commit format and go straight to `main`. After a green `ci` run on `main`, `release.yml` runs semantic-release: every `feat` or `fix` since the last tag publishes a release, stamps the version constant and adds the notes to [`CHANGELOG.md`](CHANGELOG.md).

## License

[MIT](LICENSE), copyright Gustavo Franco.

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the same contract in [`FAMILY.md`](FAMILY.md) and the same shared library, and they are built to be installed together: no member claims a key or a tmux option that another member claims.

A defect found in one member is hunted across all of them before the fix is called done.

| Member | What it does |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | Edit your tmux config, save, and watch it reload itself, no key, no command |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | Battery status for your tmux status bar, without ever blocking the status render |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | Disk usage for your tmux status bar, without ever blocking the status render |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | **this plugin**, Pick a URL, path, hash or any other token off the screen with fzf and type it at the cursor, in pure shell |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Switch to, kill, rename or create tmux sessions, windows and panes from fzf pickers in a popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Show the active pane's git branch, changes and provider counts in the tmux status bar without blocking it |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, clock, power and memory in the tmux status bar, from NVIDIA, AMD, Intel and Apple GPUs |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in the tmux status bar, parsed from kubeconfig without kubectl |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Open any terminal app in a tmux popup, window or split from one menu, starting at the project root |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness and CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

<!-- family:end -->
