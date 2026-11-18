# Changelog

# [3.1.0](https://github.com/tmux-revamped/tmux-extract-revamped/compare/v3.0.1...v3.1.0) (2026-11-17)


### Features

* add letter hints, edit, run and six modes ([28ff06a](https://github.com/tmux-revamped/tmux-extract-revamped/commit/28ff06a5f8771b46697e7b3ede5a5180bc4bb8ba))

## [3.0.1](https://github.com/tmux-revamped/tmux-extract-revamped/compare/v3.0.0...v3.0.1) (2026-11-17)


### Bug Fixes

* carry settings to keys, keep # out of popups ([25a1d61](https://github.com/tmux-revamped/tmux-extract-revamped/commit/25a1d613db83c6c68cbc3930529b1390499efcf5))
* start in a folder whose path has a # ([56b2865](https://github.com/tmux-revamped/tmux-extract-revamped/commit/56b286524250a644712115cfa1f50e047e78cc9b))

# [3.0.0](https://github.com/tmux-revamped/tmux-extract-revamped/compare/v2.0.0...v3.0.0) (2026-11-16)


* feat!: rewrite the plugin in POSIX sh ([8cb3860](https://github.com/tmux-revamped/tmux-extract-revamped/commit/8cb38606d4acbcc69aadac28c6cdcb37e5fb7bae))


### Bug Fixes

* **family:** fail when git cannot read a mode ([e57d72e](https://github.com/tmux-revamped/tmux-extract-revamped/commit/e57d72ef7759f1041ba04540f63a2368f185e511))
* **family:** honor only active exceptions ([d7202c0](https://github.com/tmux-revamped/tmux-extract-revamped/commit/d7202c0fe077ebd211e4423e45f379f5e52cd393))
* **family:** reject unquoted replacements ([f9de3f0](https://github.com/tmux-revamped/tmux-extract-revamped/commit/f9de3f0e4361f97413bb91a1a911a535a2de7aaa))
* **family:** require executable entry points ([fbfa1fa](https://github.com/tmux-revamped/tmux-extract-revamped/commit/fbfa1faf530c7fa179f47c8950338ebd44de83ad))


### Features

* add a shared desktop notifier ([73587ab](https://github.com/tmux-revamped/tmux-extract-revamped/commit/73587abc35f8238f535ff2f0dd66d4a5c46c838b))
* **family:** accept bot updates in the audit ([6f44be3](https://github.com/tmux-revamped/tmux-extract-revamped/commit/6f44be32101e68f3b49e95301976e8f2153f6cba))


### BREAKING CHANGES

* last-log reads the new @extract_revamped_log_dir,
default ~/.tmux/logging-revamped, instead of logging's
@logging_revamped_path. The old src/extract.sh MODE PANE ACTION
interface is gone; the keys and scripts call bin/extract-revamped.

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-17

### Changed

- **Breaking:** the picker now opens on `prefix + M-x` by default instead of
  `prefix + Tab`, because tmux 3.8 binds `prefix + Tab` to a floating new-pane
  helper and the family keeps stock keys free. Set `@extract_revamped_key` to
  `Tab` to keep the old key.

### Fixed

- The popup commands quote the plugin path and mode, so a plugin directory
  containing a space or a single quote still launches the picker.
- Platform tests assert their negative checks, which previously could not
  fail, and the README states the real tmux floor of 3.2.
- Inserting a pick sends it as literal text, so a token such as `Enter` or
  `C-c` is typed rather than pressed as a key.
- Opening a path passes it to the editor as one argument instead of a shell
  string, so spaces and shell syntax in a picked token stay literal, and a
  relative path opens from the source pane's directory.
- An scp-like git remote such as `git@github.com:tmux-revamped/tmux-extract-revamped.git` is no longer
  classified as a URL, so the open action pastes it instead of handing it to
  the browser.

## [1.2.0] - 2026-06-30

### Added

- Eight new extractors: git SHAs, IPv4 addresses (octet-validated), IPv6
  addresses (full and `::`-compressed), CSS hex colors, UUIDs, numbers, quoted
  values, and bracketed values. Each is a pure grep + awk function.
- Custom regex mode (`@extract_revamped_custom_regex`) for one-off patterns.
- Candidate tuning: minimum length (`@extract_revamped_min_length`) and reverse
  order (`@extract_revamped_reverse`).
- Open action: opening a URL launches the browser, a path opens in `$EDITOR`,
  anything else is pasted. Bind with `@extract_revamped_open_key`.
- Copy action: copy the choice to the clipboard, or over SSH with OSC 52 when
  `@extract_revamped_osc52` is set. Bind with `@extract_revamped_copy_key`.
- Multi-select (`@extract_revamped_multi`): mark several candidates and insert
  them joined.
- In-popup action chooser (`@extract_revamped_chooser_key`): cycle the extractor
  with `ctrl-n`, open with `ctrl-o`, copy with `ctrl-y`, insert with `Enter`,
  without rebinding.
- Wider grab area (`@extract_revamped_scope`): `all-panes` mines every pane in
  the window, `last-log` mines the newest tmux-logging-revamped capture.
- Frecency (`@extract_revamped_frecency`): recently picked candidates float to
  the top, stored in a tmux option with no temp file.
- Doctor report (`@extract_revamped_doctor_key`): shows which optional tools
  (fzf, opener, clipboard, base64) this host has.

## [1.1.0] - 2026-06-23

### Added

- Optional navigate action: bind `@extract_revamped_navigate_key` to open the
  picker and, instead of pasting the choice, jump to it in copy-mode so you can
  read it in its surrounding context. The search term is regex-escaped so it
  matches literally (upstream extrakto #130).

## [1.0.0] - 2026-06-22

### Added

- Fuzzy-extract URLs, file paths, words, or whole lines from a pane and paste
  the choice at the cursor, in an fzf popup.
- Pure-shell extraction with grep and awk, no Python runtime to install.
- Five modes (all, urls, paths, words, lines) with trailing punctuation trimmed,
  duplicates removed, and the most specific candidates first.
- Configurable key, mode, scrollback depth, and popup size.
