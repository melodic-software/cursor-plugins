# plugin-ops

Plan-aware operators for Cursor plugins and marketplaces (Ultra / Teams / Enterprise).

Skills and commands **fetch official Cursor docs live** before advising — see
[`reference/DOC-SOURCES.md`](reference/DOC-SOURCES.md).

## Commands

| Command | Purpose |
| --- | --- |
| `/sync-local` | Copy plugin(s) from a path or git URL into `~/.cursor/plugins/local` |
| `/install-marketplace` | Choose personal `/add-plugin`, Team Dashboard import, or local sync |
| `/update-plugins` | Team Auto Refresh vs personal pin vs local re-sync |

## Skills

- `sync-local` — general local sync (any marketplace/plugin URL or path)
- `install-marketplace` — plan-aware install
- `update-plugins` — plan-aware update
- `verify-plugin` — validate checkout against live reference docs

## Script

From the `cursor-plugins` repo (or pass another source):

```powershell
pwsh -File scripts/sync-local.ps1 -Source https://github.com/org/repo
pwsh -File scripts/sync-local.ps1 -Source . -Plugin hello,plugin-ops
pwsh -File scripts/sync-local.ps1 -Source D:\path\to\single-plugin
```

```bash
bash scripts/sync-local.sh https://github.com/org/repo
bash scripts/sync-local.sh . hello plugin-ops
```
