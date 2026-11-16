#!/bin/sh
set -eu

: "${SCREENS_REPO:?}"
demo=/Users/Shared/demo
rm -rf "${demo}"
mkdir -p "${demo}/home" "${demo}/bin"
tmux_path=$(command -v tmux)
ln -s "${tmux_path}" "${demo}/bin/tmux"
mkdir -p "${demo}/tmux-extract-revamped" "${demo}/project/notes"
cp -Rpf "${SCREENS_REPO}/bin" "${SCREENS_REPO}/lib" "${SCREENS_REPO}/extract-revamped.tmux" "${demo}/tmux-extract-revamped/"
printf '# Release notes\n\nShip it on Friday.\n' >"${demo}/project/notes/release.md"
cat >"${demo}/project/build.log" <<'LOG'
build 2f9c41e started on host 10.0.4.17
fetched https://registry.example.com/pkg/api-client-2.4.1.tgz
compiled src/server/handler.go and src/server/routes.go
wrote ./dist/app.tar.gz (12.4 MB) in 3.2 s
request 7d3f2a90-5b1c-4e8f-9a2d-0c6b8e1f4a37 failed: see notes/release.md
deployed to https://staging.example.com as v2.4.1
LOG
