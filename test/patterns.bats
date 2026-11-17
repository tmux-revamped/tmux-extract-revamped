#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2088

# shellcheck source=test/extract_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/extract_helpers.bash"

@test "patterns - docker gives container ids, image references and digests, never a port mapping or a clock" {
  # Arrange
  local text='CONTAINER ID   IMAGE                    PORTS                    NAMES
3f2a9c1b7d4e   ghcr.io/acme/api:1.4.2   0.0.0.0:8080->8080/tcp   api
9b8c7d6e5f4a   postgres:16              5432/tcp                 db
Digest: sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
done at 12:30:45'

  # Act
  extract docker "${text}"

  # Assert
  [[ "${output}" == $'3f2a9c1b7d4e\nghcr.io/acme/api:1.4.2\n9b8c7d6e5f4a\npostgres:16\nsha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' ]]
}

@test "patterns - kubernetes gives typed names and generated pod names, never a plain hyphenated word" {
  # Arrange
  local text='NAME                       READY   STATUS
web-7d4b9c6f5-x2k9q        1/1     Running
deployment.apps/web configured
service/web-svc unchanged
pod/db-0 created
read-write hello-world'

  # Act
  extract kubernetes "${text}"

  # Assert
  [[ "${output}" == $'web-7d4b9c6f5-x2k9q\ndeployment.apps/web\nservice/web-svc\npod/db-0' ]]
}

@test "patterns - git-status reads the long form, both sides of a rename and the untracked files" {
  # Arrange
  local text
  text=$(printf 'On branch main\nChanges to be committed:\n  (use "git restore --staged <file>..." to unstage)\n\tnew file:   lib/new file.sh\n\trenamed:    old.sh -> lib/renamed.sh\n\nChanges not staged for commit:\n\tmodified:   README.md\n        deleted:    gone.txt\n\nUntracked files:\n  (use "git add <file>..." to include in what will be committed)\n\tnotes.md\n\ttest/extra/\n\nno changes added to commit')

  # Act
  extract git-status "${text}"

  # Assert
  [[ "${output}" == $'lib/new file.sh\nold.sh\nlib/renamed.sh\nREADME.md\ngone.txt\nnotes.md\ntest/extra/' ]]
}

@test "patterns - git-status reads the short form and skips indented prose" {
  # Arrange
  local text=' M README.md
A  lib/new.sh
R  old.sh -> new.sh
?? notes.md
  indented text'

  # Act
  extract git-status "${text}"

  # Assert
  [[ "${output}" == $'README.md\nlib/new.sh\nold.sh\nnew.sh\nnotes.md' ]]
}

@test "patterns - diff gives each file once, without its a or b prefix, its timestamp or the null device" {
  # Arrange
  local text
  text=$(printf 'diff --git a/lib/a.sh b/lib/a.sh\nindex 1..2 100644\n--- a/lib/a.sh\n+++ b/lib/a.sh\n@@ -1 +1 @@\n--- /dev/null\n+++ b/new file.txt\n--- old/plain.c\t2026-01-01\n+++ new/plain.c\t2026-01-02')

  # Act
  extract diff "${text}"

  # Assert
  [[ "${output}" == $'lib/a.sh\nnew file.txt\nold/plain.c\nnew/plain.c' ]]
}

@test "patterns - markdown gives the target of each link and nothing for plain brackets" {
  # Arrange
  local text='See [the docs](https://example.com/docs) and [local](./README.md), not (plain) or [x] (y).'

  # Act
  extract markdown "${text}"

  # Assert
  [[ "${output}" == $'https://example.com/docs\n./README.md' ]]
}

@test "patterns - branches come from git status, git branch and the decorations of git log" {
  # Arrange
  local text="On branch feature/login
Your branch is up to date with 'origin/feature/login'.
* main
  fix/typo
+ wip
  remotes/origin/HEAD -> origin/main
commit 1a2b3c4 (HEAD -> main, origin/main, tag: v1.0)
commit 5d6e7f8 (origin/dev)
  two words
plain line (not a branch) with 'nothing"

  # Act
  extract branches "${text}"

  # Assert
  [[ "${output}" == $'feature/login\norigin/feature/login\nmain\nfix/typo\nwip\nremotes/origin/HEAD\norigin/main\nv1.0\norigin/dev' ]]
}
