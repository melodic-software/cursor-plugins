---
name: sync-local
description: Copy plugins from this cursor-plugins checkout into ~/.cursor/plugins/local (real copies), then tell the user to reload.
---

# Sync marketplace plugins to local Cursor

Update the user's personal Cursor install by mirroring this repo's `plugins/`
into `~/.cursor/plugins/local/` (Windows: `%USERPROFILE%\.cursor\plugins\local\`).

## Why

Personal `/add-plugin` GitHub marketplaces often stick on a stale commit.
Team Auto Refresh is org-scoped. Real local copies are the reliable personal
update path. Cursor rejects junctions whose target is outside `plugins/local`.

## Steps

1. Resolve the marketplace repo root (directory that contains `.cursor-plugin/marketplace.json` and `plugins/`). Prefer the open workspace if it is `cursor-plugins`; otherwise use the clone at `D:/repos/github.com/melodic-software/cursor-plugins` when present, or ask the user for the path.
2. Optional: `git pull --ff-only` in that repo if the user wants latest `main` first (ask if dirty).
3. Run the sync script from the repo root:
   - Windows PowerShell:
     `pwsh -File scripts/sync-local.ps1`
     Optional: `-Plugin hello,local-sync` to sync a subset; `-DryRun` to preview.
   - macOS/Linux:
     `bash scripts/sync-local.sh`
     Optional plugin names as args; `--dry-run` first.
4. Report which plugin names were synced and the destination root.
5. Tell the user to run **Developer: Reload Window**.
6. Do not invent other install paths. Do not create junctions/symlinks for Melodic plugins unless the user explicitly overrides after knowing Cursor may reject them.
