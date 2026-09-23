<div align="center">

<h1>tmux-extract-revamped</h1>

**Fuzzy-grab any URL, path, or word off the screen and paste it, pure shell, no Python.**

[![Tests](https://github.com/tmux-revamped/tmux-extract-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-extract-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](CHANGELOG.md)

</div>

**13** extractors · **zero Python** · **tmux 1.9 to 3.5** · **open · copy · multi-select** · **95%+** coverage

Press one key, fuzzy-search everything on screen, and the choice lands at your cursor. It captures the pane, pulls out URLs, file paths, words, or whole lines, and shows them in an fzf popup. Unlike extrakto, the extraction is **pure shell**, no Python runtime to install or keep working.

Built from [tmux-plugin-template](https://github.com/tmux-revamped/tmux-plugin-template).

<table>
<tr>
<td><strong>Zero Python</strong><br>URLs, paths, words, and lines are extracted with grep and awk. Nothing to <code>pip install</code>.</td>
<td><strong>Five modes</strong><br>all, urls, paths, words, or lines, each a focused extractor over the captured text.</td>
</tr>
<tr>
<td><strong>Smart candidates</strong><br>Trailing punctuation trimmed, duplicates removed, most specific matches first.</td>
<td><strong>fzf popup</strong><br>Runs in a tmux popup and pastes the choice back into the originating pane.</td>
</tr>
</table>

## Usage

Press `prefix + Tab` to open the picker over the current pane. Type to filter, `Enter` to insert the selection at your cursor. The key, the mode, and the popup size are all configurable.

## Modes

| Mode | Extracts |
|------|----------|
| `all` | URLs, then paths, then words, de-duplicated, most specific first |
| `urls` | http, https, ftp, file URLs and email addresses |
| `paths` | absolute, home, and relative file paths |
| `words` | every whitespace-separated token |
| `lines` | every non-blank line, trimmed |
| `shas` | git-style hex object names, 7 to 40 chars |
| `ipv4` | dotted-quad addresses, octets validated 0 to 255 |
| `ipv6` | full and `::`-compressed IPv6 addresses |
| `color` | CSS hex colors (`#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa`) |
| `uuid` | canonical 8-4-4-4-12 UUIDs |
| `numbers` | integers and decimals, optional sign |
| `quoted` | values inside single quotes, double quotes, or backticks |
| `bracketed` | values inside `()`, `[]`, `{}`, or `<>` |
| `custom` | matches of `@extract_revamped_custom_regex` |

## Actions

Beyond pasting, bind extra keys to act on the choice. Each is opt-in.

| Action | What it does |
|--------|--------------|
| insert | paste the choice at the cursor (default) |
| navigate | open copy-mode and search for the choice in context |
| open | URL to the browser, path to `$EDITOR`, anything else pasted |
| copy | copy to the clipboard, or over SSH with OSC 52 |
| chooser | in-popup: `ctrl-n` cycles the extractor, `ctrl-o` opens, `ctrl-y` copies, `Enter` inserts |
| doctor | report which optional tools this host has |

## Install

With [TPM](https://github.com/tmux-plugins/tpm), add to `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-revamped/tmux-extract-revamped'
```

Press `prefix + I`. Requires [fzf](https://github.com/junegunn/fzf) on the path.

## Configuration

| Option | Default | Meaning |
|--------|---------|---------|
| `@extract_revamped_key` | `Tab` | key that opens the picker |
| `@extract_revamped_navigate_key` | unset | optional key that opens copy-mode and searches for the choice in context |
| `@extract_revamped_open_key` | unset | optional key that opens the choice by type (URL, path, else paste) |
| `@extract_revamped_copy_key` | unset | optional key that copies the choice to the clipboard |
| `@extract_revamped_chooser_key` | unset | optional key for the in-popup action chooser |
| `@extract_revamped_doctor_key` | unset | optional key that prints the capability report |
| `@extract_revamped_mode` | `all` | which extractor the picker uses |
| `@extract_revamped_modes` | `all urls paths words lines` | extractors the chooser cycles through |
| `@extract_revamped_scope` | `pane` | source text: `pane`, `all-panes`, or `last-log` |
| `@extract_revamped_custom_regex` | unset | extended-regex for the `custom` mode |
| `@extract_revamped_min_length` | `0` | drop candidates shorter than this |
| `@extract_revamped_reverse` | `0` | set to `1` to list candidates oldest-first |
| `@extract_revamped_multi` | `0` | set to `1` to allow multi-select, inserted joined |
| `@extract_revamped_osc52` | `0` | set to `1` to copy over SSH with OSC 52 |
| `@extract_revamped_frecency` | `0` | set to `1` to float recently picked candidates to the top |
| `@extract_revamped_lines` | `200` | lines of scrollback to capture |
| `@extract_revamped_popup_width` | `80%` | popup width |
| `@extract_revamped_popup_height` | `60%` | popup height |

## Compatibility

Works on every tmux version with `display-popup`, tmux 3.2 and up for the popup; on older tmux the picker can be wired to a split. Linux (x86_64 and arm64) and macOS (Intel and Apple Silicon). Needs only fzf plus core tmux.

## Development

```bash
make test    # bats suite
make lint    # shellcheck
make coverage  # kcov line coverage on Linux
```

The extractors live in [`src/lib/extract/extract.sh`](src/lib/extract/extract.sh) as pure functions, text in, candidate list out, with the pane capture, the fzf picker, and the paste behind seams so the tests need no pane and no fzf.

## License

[MIT](LICENSE), copyright Gustavo Franco.

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the
same contract in [`FAMILY.md`](FAMILY.md), the same tooling under `family/`, and
the same shared library, all held byte-identical by a checksum manifest. They are
built to be installed together: no member claims a key or a tmux option that
another member claims.

A defect found in one member is hunted across all of them before the fix is
called done. That obligation is written into the contract rather than left to
memory, and `family/bin/sweep` is how it is discharged.

| Member | What it does |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | Edit your tmux config, save, and watch it reload itself, no key, no command |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | Battery status for your tmux status bar, without ever blocking the status render |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | Disk usage for your tmux status bar, without ever blocking the status render |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | **this plugin**, Fuzzy-grab any URL, path, or word off the screen and paste it, pure shell, no Python |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Jump to any session, window, or pane, or kill it, from one fzf popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Git repository status in your tmux status bar, without ever blocking the render |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, frequency, and memory for your tmux status bar |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in your tmux status bar, async, kubectl-free, never blocking |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Standard pane and window management bindings for tmux, version aware, vim friendly, and fully configurable |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | One plugin that captures every session, window, pane, layout, and working |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | A template for building non-blocking tmux status plugins |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in your tmux status bar, with zero temp files: all state lives in tmux options |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM usage for your tmux status bar, without ever blocking the status render |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Mouse wheel that does the right thing: scroll the app directly, copy-mode everywhere else. No app names to con |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults that normalize behavior across every tmux version, OS, and terminal, without clobbering |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | --- |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local clock and world clocks in your tmux status bar, without ever blocking the render |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather in your tmux status bar, fetched in the background so the render never waits on the network |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
