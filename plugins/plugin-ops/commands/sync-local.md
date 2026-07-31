---
name: sync-local
description: Sync a Cursor plugin or marketplace (path or git URL) into ~/.cursor/plugins/local, then reload reminder.
---

# /sync-local

Follow the **sync-local** skill in this plugin.

1. Fetch https://cursor.com/docs/plugins (local test section) live.
2. Resolve Source: user arg, else workspace marketplace/plugin root, else Melodic `cursor-plugins` checkout.
3. Optional plugin name filter and git ref.
4. Run `scripts/sync-local.ps1` / `scripts/sync-local.sh` with `-Source` / URL.
5. Report results; **Developer: Reload Window**.
