# plugin-ops

Plan-aware operators for Cursor plugins and marketplaces (Ultra / Teams / Enterprise).

Skills **fetch official Cursor docs live** before advising — see
[`reference/DOC-SOURCES.md`](reference/DOC-SOURCES.md).

Melodic policy (skills primary; no new `commands/`):  
[`docs/PLUGIN-PHILOSOPHY.md`](../../docs/PLUGIN-PHILOSOPHY.md).

## Skills

| Skill | Purpose |
| --- | --- |
| `/sync-local` | Copy plugin(s) from a path or git URL into `~/.cursor/plugins/local` |
| `/install-marketplace` | Choose `/plugin marketplace add`, Team Dashboard import, or local sync |
| `/update-plugins` | Team Auto Refresh vs personal pin vs local re-sync |
| `/verify-plugin` | Validate checkout against live Cursor docs + Melodic stances |

Invoke via Agent chat `/skill-name` (skills register in the slash menu). No
separate `commands/` layer.

## Script

From the `cursor-plugins` repo (or pass another source):

```powershell
pwsh -File scripts/sync-local.ps1 -Source https://github.com/org/repo
pwsh -File scripts/sync-local.ps1 -Source . -Plugin plugin-ops
pwsh -File scripts/sync-local.ps1 -Source D:\path\to\single-plugin
```

```bash
bash scripts/sync-local.sh https://github.com/org/repo
bash scripts/sync-local.sh . plugin-ops
```
