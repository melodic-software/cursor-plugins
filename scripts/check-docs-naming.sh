#!/usr/bin/env bash
# Check that every tracked file under docs/ has a lower-kebab-case basename.
#
# Rule: the basename matches ^[a-z0-9]+([.-][a-z0-9]+)*\.[a-z0-9]+$.
# Exempt: README, AGENTS, CLAUDE, CHANGELOG, LICENSE, SKILL, CONTRIBUTING, SECURITY, REVIEW
# and CODE_OF_CONDUCT (each .md), the conventional names forges and tooling look for
# by exact spelling.
# Independently, no two tracked paths under docs/ may differ only by case: a
# case-insensitive checkout (Windows, macOS) writes the second over the first.
#
# Usage: bash scripts/check-docs-naming.sh [--check]
# Exit:  0 clean, 1 any offender, 2 usage or environment.
set -euo pipefail

case "${1:-}" in
'' | --check) ;;
*)
  printf 'usage: %s [--check]\n' "${0##*/}" >&2
  exit 2
  ;;
esac

cd "${BASH_SOURCE[0]%/*}/.." || exit 2
git rev-parse --show-toplevel >/dev/null 2>&1 || {
  printf 'check-docs-naming: not inside a git repository\n' >&2
  exit 2
}

name_re='^[a-z0-9]+([.-][a-z0-9]+)*\.[a-z0-9]+$'
exempt_re='^(README|AGENTS|CLAUDE|CHANGELOG|LICENSE|SKILL|CONTRIBUTING|SECURITY|REVIEW|CODE_OF_CONDUCT)\.md$'
offenders=()

while IFS= read -r -d '' path; do
  base="${path##*/}"
  [[ "$base" =~ $exempt_re || "$base" =~ $name_re ]] ||
    offenders+=("$path: basename is not lower-kebab-case")
done < <(git ls-files -z -- docs/)

while IFS= read -r folded; do
  [[ -n "$folded" ]] || continue
  while IFS= read -r path; do
    if [[ "$(printf '%s' "$path" | tr '[:upper:]' '[:lower:]')" == "$folded" ]]; then
      offenders+=("$path: differs only by case from another tracked path")
    fi
  done < <(git ls-files -- docs/)
done < <(git ls-files -- docs/ | tr '[:upper:]' '[:lower:]' | sort | uniq -d)

if ((${#offenders[@]} == 0)); then
  printf 'check-docs-naming: every tracked file under docs/ is lower-kebab-case.\n'
  exit 0
fi
printf '%s\n' "${offenders[@]}" | sort -u >&2
printf 'check-docs-naming: %d offender(s); rename to lower-kebab-case.\n' "${#offenders[@]}" >&2
exit 1
