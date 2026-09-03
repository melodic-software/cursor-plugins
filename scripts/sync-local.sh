#!/usr/bin/env bash
# Copy Cursor plugin(s) into ~/.cursor/plugins/local (real copies).
# Usage:
#   scripts/sync-local.sh [--dry-run] [--no-update] [--ref REF] [--keep-clone] [source] [plugin-name ...]
# Flags are position-independent: the parser accepts them before, between or after
# the positional arguments. The first non-flag argument is the source; every later
# non-flag argument is a plugin name.
# source: local path or git URL (default: this repo, then known checkouts, then
# the Melodic marketplace URL). A local git checkout is fast-forwarded unless
# --no-update or --dry-run.
set -euo pipefail

repo_default="$(cd "$(dirname "$0")/.." && pwd)"
melodic_marketplace_url="https://github.com/melodic-software/cursor-plugins"
dry_run=0
keep_clone=0
no_update=0
ref=""
source=""
plugins=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --keep-clone) keep_clone=1; shift ;;
    --no-update) no_update=1; shift ;;
    --ref)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --ref" >&2
        exit 2
      fi
      ref="$2"
      shift 2
      ;;
    -*)
      # Exit 2 here, but the pwsh twin exits 1 for an unknown flag. That code is
      # emitted by PowerShell's own parameter binder before the script body runs
      # and cannot be overridden from the script, so the divergence is intentional
      # and settled -- do not "fix" it.
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

# True when $1 looks like a Cursor plugin or marketplace root. Used only for
# implicit source discovery -- never as a recursive search predicate.
has_plugin_layout() {
  [[ -f "$1/.cursor-plugin/marketplace.json" || -f "$1/.cursor-plugin/plugin.json" || -d "$1/plugins" ]]
}

# Fixed candidate list. Test each with `[ -d ]` only -- do not glob or walk
# $HOME, OneDrive, Documents, or AppData. Those walks hang for minutes on Windows.
known_checkout_paths() {
  local seen="|"
  emit_known() {
    local p="$1"
    [[ -n "$p" ]] || return 0
    case "$seen" in
      *"|$p|"*) return 0 ;;
    esac
    seen="$seen$p|"
    printf '%s\n' "$p"
  }
  emit_known "${MELODIC_CURSOR_PLUGINS:-}"
  if [[ -n "${HOME:-}" ]]; then
    emit_known "$HOME/cursor-plugins"
    emit_known "$HOME/repos/github.com/melodic-software/cursor-plugins"
    emit_known "$HOME/src/github.com/melodic-software/cursor-plugins"
  fi
  if [[ -n "${USERPROFILE:-}" ]]; then
    emit_known "$USERPROFILE/cursor-plugins"
    emit_known "$USERPROFILE/repos/github.com/melodic-software/cursor-plugins"
    emit_known "$USERPROFILE/src/github.com/melodic-software/cursor-plugins"
  fi
  emit_known "D:/repos/github.com/melodic-software/cursor-plugins"
  emit_known "C:/repos/github.com/melodic-software/cursor-plugins"
}

# When the caller omitted a source: this script's repo if it is a marketplace
# or plugin, else a known checkout path, else the official Melodic URL (clone).
resolve_implicit_source() {
  if has_plugin_layout "$repo_default"; then
    printf '%s\n' "$repo_default"
    return 0
  fi
  local p
  while IFS= read -r p; do
    if [[ -d "$p" ]] && has_plugin_layout "$p"; then
      echo "Using checkout: $p" >&2
      printf '%s\n' "$p"
      return 0
    fi
  done < <(known_checkout_paths)
  echo "No local checkout found; cloning $melodic_marketplace_url" >&2
  printf '%s\n' "$melodic_marketplace_url"
}

# Fast-forward a local git checkout so a stale clone does not get copied.
# Never prompted (GIT_TERMINAL_PROMPT=0). Failures degrade to "sync current HEAD".
# Prints one stdout line so both twins stay byte-identical. Dry-run and
# --no-update skip this entirely (a dry run must not mutate the source).
update_local_git() {
  local root="$1"
  if [[ ! -e "$root/.git" ]]; then
    return 0
  fi
  local head
  head="$(git -C "$root" rev-parse --short=7 HEAD 2>/dev/null || true)"
  if [[ -z "$head" ]]; then
    return 0
  fi
  if [[ -n "$(git -C "$root" status --porcelain 2>/dev/null || true)" ]]; then
    echo "Local checkout is dirty; syncing the working tree at $head without pulling"
    return 0
  fi
  if ! git -C "$root" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    echo "Local checkout has no upstream; syncing current HEAD $head"
    return 0
  fi
  if ! GIT_TERMINAL_PROMPT=0 git -C "$root" fetch --quiet 2>/dev/null; then
    echo "Could not fetch; syncing current HEAD $head"
    return 0
  fi
  local remote_head
  remote_head="$(git -C "$root" rev-parse --short=7 '@{u}' 2>/dev/null || true)"
  if [[ -n "$remote_head" && "$remote_head" == "$head" ]]; then
    echo "Local checkout already up to date ($head)"
    return 0
  fi
  if GIT_TERMINAL_PROMPT=0 git -C "$root" merge --ff-only --no-edit '@{u}' >/dev/null 2>&1; then
    echo "Fast-forwarded $head..$(git -C "$root" rev-parse --short=7 HEAD)"
    return 0
  fi
  echo "Could not fast-forward; syncing current HEAD $head"
}

[[ -n "$source" ]] || source="$(resolve_implicit_source)"

local_root="${HOME}/.cursor/plugins/local"

is_git_url() {
  # Matched case-insensitively: URI schemes are case-insensitive (RFC 3986 3.1),
  # so "HTTPS://host/repo" is a URL, not a local path. `[[ =~ ]]` and `==` are
  # case-sensitive, so fold the value first rather than relying on the caller.
  # (The pwsh twin's -match/-like are case-insensitive by default; this keeps the
  # two in step.) Folded with tr, not bash 4's ${x,,}, to stay usable under 3.2.
  local value
  value="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  [[ "$value" =~ ^(https://|git@|ssh://) ]] || [[ "$value" == *.git ]]
}

# Resolve a path to an absolute, lexically normalised form: "." and ".." segments
# are collapsed and a leading "" is anchored to $PWD. Deliberately does NOT follow
# symlinks, for two reasons: `realpath -m` (resolve a not-yet-existing path) is a
# GNU extension that BSD/macOS realpath lacks, and the pwsh twin's counterpart
# [IO.Path]::GetFullPath is itself purely lexical -- so both twins agree. Symlinks
# are not the threat here: a symlinked plugin directory is a supported layout, and
# planting one already requires write access to the source tree, whereas ".."
# reaches files the *user* keeps outside it.
resolve_path() {
  local input="$1" out="" rest comp
  [[ "$input" == /* ]] || input="$PWD/$input"
  rest="$input"
  while [[ -n "$rest" ]]; do
    comp="${rest%%/*}"
    if [[ "$comp" == "$rest" ]]; then rest=""; else rest="${rest#*/}"; fi
    case "$comp" in
      "" | .) ;;
      ..) out="${out%/*}" ;;
      *) out="$out/$comp" ;;
    esac
  done
  printf '%s\n' "${out:-/}"
}

# True when $2 is $1 itself or lies under it. Both must already be absolute and
# normalised (resolve_path), so this is a comparison of resolved paths rather than
# a substring test on raw input.
path_contains() {
  [[ "$2" == "$1" || "$2" == "$1"/* ]]
}

temp_clone=""
cleanup() {
  if [[ -n "${temp_clone}" && -d "${temp_clone}" ]]; then
    if [[ "${keep_clone}" -eq 1 ]]; then
      # Printed from the exit handler, not from the main flow, so the path is
      # still reported when the run fails part-way -- and so it lands after
      # "Reload Cursor:", exactly where the pwsh twin's `finally` prints it.
      echo "Kept clone: ${temp_clone}"
    else
      rm -rf "${temp_clone}"
    fi
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
    echo "If you do not have a checkout, pass a git URL (for this marketplace: $melodic_marketplace_url)." >&2
    exit 1
  fi
  work_root="$(cd "$source" && pwd)"
  if [[ "$dry_run" -eq 0 && "$no_update" -eq 0 ]]; then
    update_local_git "$work_root"
  fi
fi

mkdir -p "$local_root"

marketplace="$work_root/.cursor-plugin/marketplace.json"
root_plugin="$work_root/.cursor-plugin/plugin.json"

names=()
paths=()
skipped=()

if [[ -f "$marketplace" ]]; then
  if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 required to parse marketplace.json" >&2
    exit 1
  fi
  work_root_resolved="$(resolve_path "$work_root")"
  plugin_root="$work_root_resolved"
  pr="$(python3 -c 'import json,sys; m=json.load(open(sys.argv[1])); print((m.get("metadata") or {}).get("pluginRoot") or "")' "$marketplace")"
  if [[ -n "$pr" ]]; then
    plugin_root="$(resolve_path "$work_root_resolved/$pr")"
    # metadata.pluginRoot is untrusted input too: "../.." here would move the base
    # of every later join outside the source tree, so refuse it up front rather
    # than skipping each plugin in turn.
    if ! path_contains "$work_root_resolved" "$plugin_root"; then
      echo "metadata.pluginRoot escapes the source repo: $pr" >&2
      exit 1
    fi
  fi
  if [[ "${#plugins[@]}" -gt 0 ]]; then
    # The requested names are matched case-SENSITIVELY (Python's == below, and
    # -ceq in the pwsh twin): the official schema constrains a plugin name to
    # ^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$, so exact matching is the schema-correct
    # and stricter choice.
    sel=("${plugins[@]}")
  else
    sel=()
    while IFS= read -r line; do
      if [[ -n "$line" ]]; then sel+=("$line"); fi
    # .get("name"), not ["name"]: an entry with no "name" key made this raise a
    # KeyError and print a raw Python traceback to stderr. It now yields an empty
    # line, which the -n guard above drops -- the same treatment the pwsh twin
    # gives a nameless entry.
    done < <(python3 -c 'import json,sys; m=json.load(open(sys.argv[1])); print("\n".join(str(p.get("name") or "") for p in m.get("plugins",[])))' "$marketplace")
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
    # `rel` is untrusted marketplace.json content (plugins[].source, or
    # plugins[].source.path). A value of "../../../etc" would make the read side
    # copy files from outside the source repo into the user's plugins root -- the
    # mirror image of the write-side name guard below, which was already closed.
    # Resolve the join and require it to stay under $plugin_root.
    src_resolved="$(resolve_path "$plugin_root/$rel")"
    if ! path_contains "$plugin_root" "$src_resolved"; then
      skipped+=("$name (source escapes plugin root)")
      continue
    fi
    names+=("$name")
    paths+=("$src_resolved")
  done
elif [[ -f "$root_plugin" ]]; then
  # Two stacked fallbacks, kept because they cover different failure modes:
  # python3 missing or plugin.json unparseable (non-zero exit), and python3 fine
  # but "name" absent or empty (empty output). Both end at the *directory* name,
  # which is a guess -- a manifest saying {"name":"good"} in a directory called
  # "single" would otherwise sync silently as "single", with exit 0 and no hint
  # that the name is wrong. So each fallback announces itself on stderr. The
  # marketplace branch above hard-errors when python3 is absent; this branch stays
  # usable without it (AGENTS.md scopes the python3 requirement to marketplace
  # sources) but is no longer silent about the consequence.
  name=""
  if ! command -v python3 >/dev/null 2>&1; then
    echo "Warning: python3 not found; cannot read \"name\" from $root_plugin" >&2
  elif ! name="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("name") or "")' "$root_plugin" 2>/dev/null)"; then
    echo "Warning: could not parse $root_plugin" >&2
    name=""
  fi
  if [[ -z "$name" ]]; then
    name="$(basename "$work_root")"
    echo "Warning: falling back to the directory name '$name', which may not be the plugin's declared name" >&2
  fi
  if [[ "${#plugins[@]}" -gt 0 ]]; then
    match=0
    for p in "${plugins[@]}"; do
      # Case-SENSITIVE on purpose, in both twins. The official manifest schema
      # constrains a plugin name to ^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$ -- already
      # lowercase -- so an exact match is both the stricter reading and the
      # schema-correct one, and "Foo" must not silently select "foo".
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
    # extensions (absent from POSIX and BSD find). The glob sorts by full path
    # *including* the trailing slash, and `-` (0x2D) and `.` (0x2E) both sort
    # before `/` (0x2F) -- so a name that is a prefix of another would come out
    # after it ("ai-briefing" before "ai"). Sort the basenames explicitly to keep
    # the order `find | sort` produced, which is also what the pwsh twin's
    # Get-ChildItem yields.
    sel=()
    while IFS= read -r plugin_name; do
      if [[ -n "$plugin_name" ]]; then sel+=("$plugin_name"); fi
    done < <(
      for dir in "$work_root"/plugins/*/; do
        if [[ -d "$dir" ]]; then basename "$dir"; fi
      done | LC_ALL=C sort
    )
  fi
  for name in "${sel[@]}"; do
    names+=("$name")
    paths+=("$work_root/plugins/$name")
  done
fi

# Covers both "no recognised layout" and "layout found but it named no plugins"
# (e.g. an empty plugins/ dir, or "plugins": [] in marketplace.json). Entries that
# were named but refused above are not "not found", so they fall through to the
# Skipped report instead of being swallowed by this message.
if [[ "${#names[@]}" -eq 0 && "${#skipped[@]}" -eq 0 ]]; then
  echo "No Cursor plugins found under $work_root (need marketplace.json or plugin.json)." >&2
  exit 1
fi

synced=()
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
    # Copy the *contents* ("$src/."), not the directory entry. `cp -R` without
    # -H/-L copies a symlinked source as a symlink (POSIX-specified, same on GNU
    # and BSD), which would install a link into the plugins root and break this
    # script's stated contract of real directory copies -- and leave a dangling
    # link once a temp clone is cleaned up. Trailing "/." dereferences only the
    # top level, so symlinks *inside* a plugin are still copied as symlinks.
    mkdir -p "$dst"
    cp -R "$src/." "$dst"
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
# A dry run copies nothing, so it must not report "Synced" -- that reads as work
# done. The real-run line is unchanged.
if [[ "$dry_run" -eq 1 ]]; then
  echo "Would sync (${#synced[@]}): ${synced_list%, }"
else
  echo "Synced (${#synced[@]}): ${synced_list%, }"
fi
if [[ "${#skipped[@]}" -gt 0 ]]; then
  skipped_list="$(printf '%s; ' "${skipped[@]}")"
  echo "Skipped (${#skipped[@]}): ${skipped_list%; }"
fi
echo "Reload Cursor: Developer: Reload Window"
# "Kept clone:" is printed by the EXIT trap, after this line -- see cleanup().
