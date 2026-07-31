---
name: sync-local
description: Sync any Cursor plugin or marketplace (local path or git URL) into ~/.cursor/plugins/local with real copies. Use when /add-plugin updates are stale, for Ultra/personal installs, or to pin disk copies of selected plugins.
---

# Sync plugins to ~/.cursor/plugins/local

## Official docs (fetch live first)

1. Fetch https://cursor.com/docs/plugins — especially **Test plugins locally**.
2. Fetch https://cursor.com/docs/reference/plugins — marketplace vs single-plugin layout.
3. Follow `plugins/plugin-ops/reference/DOC-SOURCES.md` for the full URL list.
4. Prefer live docs over this skill if they disagree.

## When to use

- Personal / Ultra: reliable update path (personal `/add-plugin` can pin stale commits).
- Any plan: local override or offline copy of selected plugins.
- Source can be **this Melodic repo**, **any marketplace URL**, or **a single-plugin repo**.

## Inputs

Ask only if missing:

- **Source** — local path, or git URL (`https://github.com/org/repo`). Default: open workspace if it has `.cursor-plugin/marketplace.json` or `plugin.json`, else this `cursor-plugins` checkout if present.
- **Plugin names** (optional) — subset when Source is a multi-plugin marketplace.
- **Ref** (optional) — branch/tag/SHA for URL sources.

## Steps

1. Resolve Source (path or URL) and optional plugin filter / ref.
2. Run from a machine that has the `cursor-plugins` scripts **or** copy the script invocation into the Source repo if it vendors the same scripts. Prefer Melodic scripts when available:
   - Windows:  
     `pwsh -File <cursor-plugins>/scripts/sync-local.ps1 -Source <path-or-url> [-Plugin a,b] [-Ref main] [-DryRun]`
   - Unix:  
     `bash <cursor-plugins>/scripts/sync-local.sh [--dry-run] [--ref main] <path-or-url> [plugin ...]`
3. If Melodic scripts are unavailable, still perform **real directory copies** of each plugin dir (must contain `.cursor-plugin/plugin.json`) into `~/.cursor/plugins/local/<name>/` (Windows: `%USERPROFILE%\.cursor\plugins\local\`). Do not rely on junctions unless the user explicitly accepts Cursor may reject them (docs mention symlinks for local test; Melodic default is real copies).
4. Report synced names + destination root.
5. Instruct **Developer: Reload Window**.

## Out of scope

- Team Marketplace Dashboard import (use `install-marketplace` / `update-plugins`).
- Committing secrets into plugins.
