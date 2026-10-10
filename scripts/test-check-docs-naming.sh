#!/usr/bin/env bash
# Regression suite for check-docs-naming.sh: runs it against throwaway git repos.
# Usage: bash scripts/test-check-docs-naming.sh
# Exit:  0 all cases passed, 1 otherwise.
set -euo pipefail

src_dir="${BASH_SOURCE[0]%/*}"
[[ "$src_dir" == "${BASH_SOURCE[0]}" ]] && src_dir=.
sut="$(cd "$src_dir" && pwd)/check-docs-naming.sh"
work="$(mktemp -d "${TMPDIR:-/tmp}/docs-naming-tests.XXXXXX")"
trap 'rm -rf "$work"' EXIT
fail=0

# run_case NAME WANT_EXIT FILE...  (files are created under docs/ and staged)
run_case() {
  local name="$1" want="$2" repo rc=0 f
  shift 2
  repo="$work/$name"
  mkdir -p "$repo/scripts"
  cp "$sut" "$repo/scripts/"
  git -C "$repo" init -q
  for f in "$@"; do
    mkdir -p "$repo/docs/$(dirname "$f")"
    : >"$repo/docs/$f"
  done
  git -C "$repo" add -A
  bash "$repo/scripts/check-docs-naming.sh" --check >/dev/null 2>&1 || rc=$?
  if [[ "$rc" == "$want" ]]; then
    printf '  ok   %s\n' "$name"
  else
    printf '  FAIL %s (exit %s, want %s)\n' "$name" "$rc" "$want"
    fail=1
  fi
}

run_case clean 0 plugin-philosophy.md README.md CHANGELOG.md v1.2.schema.json
run_case upper-kebab 1 UPPER-KEBAB.md
run_case mixed-case 1 Mixed.md
run_case snake-case 1 snake_case.md
run_case empty-segment 1 foo..md
run_case nested-offender 1 sub/Bad-Name.md
run_case nested-exempt 0 sub/README.md sub/SKILL.md
run_case dir-case-collision 1 Guides/a.md guides/a.md
run_case reference-offender 1 ../plugins/p/reference/DOC-SOURCES.md

exit "$fail"
