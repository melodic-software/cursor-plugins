#!/usr/bin/env bash
# Copy Cursor plugin(s) into ~/.cursor/plugins/local (real copies).
# Usage:
#   scripts/sync-local.sh [--dry-run] [--ref REF] [--keep-clone] [source] [plugin-name ...]
# source: local path or git URL (default: this repo).
set -euo pipefail

repo_default="$(cd "$(dirname "$0")/.." && pwd)"
dry_run=0
keep_clone=0
ref=""
source=""
plugins=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --keep-clone) keep_clone=1; shift ;;
    --ref)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --ref" >&2
        exit 2
      fi
      ref="$2"
      shift 2
      ;;
    -*)
      echo "Unknown flag: $1" >&2
      exit 2
      ;;
    *)
      if [[ -z "$source" ]]; then
        source="$1"
      else
        plugins+=("$1")
      fi
      shift
      ;;
  esac
done

[[ -n "$source" ]] || source="$repo_default"

local_root="${HOME}/.cursor/plugins/local"

is_git_url() {
  [[ "$1" =~ ^(https://|git@|ssh://) ]] || [[ "$1" == *.git ]]
}

temp_clone=""
cleanup() {
  if [[ -n "${temp_clone}" && -d "${temp_clone}" && "${keep_clone}" -eq 0 ]]; then
    rm -rf "${temp_clone}"
  fi
}
trap cleanup EXIT

if is_git_url "$source"; then
  temp_clone="$(mktemp -d "${TMPDIR:-/tmp}/cursor-plugin-sync.XXXXXX")"
  echo "Cloning $source ..."
  if [[ -n "$ref" ]]; then
    git clone --depth 1 --branch "$ref" "$source" "$temp_clone"
  else
    git clone --depth 1 "$source" "$temp_clone"
  fi
  work_root="$temp_clone"
else
  if [[ ! -d "$source" ]]; then
    echo "Source path not found: $source" >&2
    exit 1
  fi
  work_root="$(cd "$source" && pwd)"
fi

mkdir -p "$local_root"

marketplace="$work_root/.cursor-plugin/marketplace.json"
root_plugin="$work_root/.cursor-plugin/plugin.json"

names=()
paths=()

if [[ -f "$marketplace" ]]; then
  if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 required to parse marketplace.json" >&2
    exit 1
  fi
  plugin_root="$work_root"
  pr="$(python3 -c 'import json,sys; m=json.load(open(sys.argv[1])); print((m.get("metadata") or {}).get("pluginRoot") or "")' "$marketplace")"
  if [[ -n "$pr" ]]; then
    plugin_root="$work_root/$pr"
  fi
  if [[ "${#plugins[@]}" -gt 0 ]]; then
    sel=("${plugins[@]}")
  else
    sel=()
    while IFS= read -r line; do
      if [[ -n "$line" ]]; then sel+=("$line"); fi
    done < <(python3 -c 'import json,sys; m=json.load(open(sys.argv[1])); print("\n".join(p["name"] for p in m.get("plugins",[])))' "$marketplace")
  fi
  for name in "${sel[@]}"; do
    rel="$(python3 -c 'import json,sys
m=json.load(open(sys.argv[1])); name=sys.argv[2]
for p in m.get("plugins", []):
  if p.get("name") == name:
    s = p.get("source", name)
    print(s if isinstance(s, str) else s.get("path", name))
    break
else:
  print(name)
' "$marketplace" "$name")"
    names+=("$name")
    paths+=("$plugin_root/$rel")
  done
elif [[ -f "$root_plugin" ]]; then
  name="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("name") or "")' "$root_plugin" 2>/dev/null || basename "$work_root")"
  [[ -n "$name" ]] || name="$(basename "$work_root")"
  if [[ "${#plugins[@]}" -gt 0 ]]; then
    match=0
    for p in "${plugins[@]}"; do
      if [[ "$p" == "$name" ]]; then match=1; fi
    done
    if [[ "$match" -ne 1 ]]; then
      echo "Plugin filter excluded single plugin '$name'" >&2
      exit 1
    fi
  fi
  names+=("$name")
  paths+=("$work_root")
elif [[ -d "$work_root/plugins" ]]; then
  if [[ "${#plugins[@]}" -gt 0 ]]; then
    sel=("${plugins[@]}")
  else
    # Glob rather than `find -printf`: -printf/-mindepth/-maxdepth are GNU
    # extensions (absent from POSIX and BSD find). Pathname expansion is already
    # sorted, so this also replaces the `| sort`.
    sel=()
    for dir in "$work_root"/plugins/*/; do
      if [[ -d "$dir" ]]; then sel+=("$(basename "$dir")"); fi
    done
  fi
  for name in "${sel[@]}"; do
    names+=("$name")
    paths+=("$work_root/plugins/$name")
  done
fi

# Covers both "no recognised layout" and "layout found but it named no plugins"
# (e.g. an empty plugins/ dir, or "plugins": [] in marketplace.json).
if [[ "${#names[@]}" -eq 0 ]]; then
  echo "No Cursor plugins found under $work_root" >&2
  exit 1
fi

synced=()
skipped=()
for i in "${!names[@]}"; do
  name="${names[$i]}"
  src="${paths[$i]}"
  # `name` comes from untrusted marketplace.json/plugin.json and is joined onto
  # $local_root before `rm -rf`. Keep it a single path segment so the destination
  # cannot escape the plugins root.
  if [[ -z "$name" || "$name" == "." || "$name" == ".." || "$name" == */* || "$name" == *\\* ]]; then
    skipped+=("$name (invalid plugin name)")
    continue
  fi
  if [[ ! -f "$src/.cursor-plugin/plugin.json" ]]; then
    skipped+=("$name (missing .cursor-plugin/plugin.json)")
    continue
  fi
  dst="$local_root/$name"
  if [[ "$dry_run" -eq 1 ]]; then
    echo "[dry-run] $name -> $dst"
  else
    rm -rf "$dst"
    cp -R "$src" "$dst"
    echo "synced $name -> $dst"
  fi
  synced+=("$name")
done

echo
echo "Source: $work_root"
echo "Local:  $local_root"
# "${arr[*]}" can only join on the FIRST character of IFS (bash(1), Arrays), so a
# two-character separator needs printf + trailing-separator trim.
synced_list="$(printf '%s, ' "${synced[@]}")"
echo "Synced (${#synced[@]}): ${synced_list%, }"
if [[ "${#skipped[@]}" -gt 0 ]]; then
  skipped_list="$(printf '%s; ' "${skipped[@]}")"
  echo "Skipped (${#skipped[@]}): ${skipped_list%; }"
fi
if [[ "$keep_clone" -eq 1 && -n "$temp_clone" ]]; then
  echo "Kept clone: $temp_clone"
fi
echo "Reload Cursor: Developer: Reload Window"
