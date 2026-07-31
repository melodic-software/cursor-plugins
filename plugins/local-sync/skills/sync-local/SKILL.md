---
name: sync-local
description: Sync Melodic cursor-plugins marketplace plugins into ~/.cursor/plugins/local via real copies. Use when updating local Cursor plugins after repo changes, or when /add-plugin marketplace updates are stale.
---

# Sync local Cursor plugins

## Instructions

1. Find the `cursor-plugins` repo root (has `.cursor-plugin/marketplace.json` + `plugins/`).
2. Run `scripts/sync-local.ps1` (Windows) or `scripts/sync-local.sh` (Unix) from that root.
3. Summarize synced plugin names.
4. Instruct **Developer: Reload Window**.

Prefer real copies. Do not junction Melodic plugins into `plugins/local` unless the user explicitly accepts Cursor may reject them.
