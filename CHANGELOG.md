# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
