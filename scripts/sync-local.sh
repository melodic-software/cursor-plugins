#!/usr/bin/env bash
# Copy plugins from this marketplace repo into ~/.cursor/plugins/local (real copies).
# Usage: scripts/sync-local.sh [plugin-name ...]
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
plugins_root="$repo_root/plugins"
local_root="${HOME}/.cursor/plugins/local"
dry_run=0

if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=1
  shift
fi

mkdir -p "$local_root"

if [[ ! -d "$plugins_root" ]]; then
  echo "No plugins/ directory at $plugins_root" >&2
  exit 1
fi

if [[ "$#" -gt 0 ]]; then
  names=("$@")
else
  mapfile -t names < <(find "$plugins_root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
fi

synced=()
skipped=()

for name in "${names[@]}"; do
  src="$plugins_root/$name"
  manifest="$src/.cursor-plugin/plugin.json"
  if [[ ! -f "$manifest" ]]; then
    skipped+=("$name (missing .cursor-plugin/plugin.json)")
    continue
  fi
  dst="$local_root/$name"
  if [[ "$dry_run" -eq 1 ]]; then
    echo "[dry-run] would sync $name -> $dst"
    synced+=("$name")
    continue
  fi
  rm -rf "$dst"
  cp -R "$src" "$dst"
  echo "synced $name -> $dst"
  synced+=("$name")
done

echo
echo "Synced (${#synced[@]}): $(IFS=,; echo "${synced[*]}")"
if [[ "${#skipped[@]}" -gt 0 ]]; then
  echo "Skipped (${#skipped[@]}): $(IFS='; echo "${skipped[*]}")"
fi
echo "Reload Cursor: Developer: Reload Window"
