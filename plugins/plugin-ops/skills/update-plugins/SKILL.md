---
name: update-plugins
description: Update installed Cursor plugins/marketplaces for the user's plan. Fetches official docs live; covers Team Auto Refresh, personal /add-plugin limits, and local sync-from-URL/path.
---

# Update Cursor plugins (plan-aware)

## Official docs (fetch live first — mandatory)

1. https://cursor.com/docs/plugins — section **Keep plugins up to date** (Team Auto Refresh / Refresh), Installing / Managing plugins
2. https://cursor.com/docs/integrations/github — GitHub App requirement for Auto Refresh
3. https://cursor.com/docs/reference/plugins — only if validating marketplace layout after a pull

`plugins/plugin-ops/reference/DOC-SOURCES.md` lists URLs. **Docs win.**
Melodic policy: `docs/PLUGIN-PHILOSOPHY.md`.

## Clarify how they installed

- Official Cursor Marketplace plugin
- Team Marketplace (org)
- Personal `/add-plugin <url>`
- Local `~/.cursor/plugins/local`
- Unknown → ask / inspect Customize scopes

## Update paths (verify against fetched docs)

| Install method | Update approach |
| --- | --- |
| **Team Marketplace** | Per docs: enable **Auto Refresh** (GitHub App on repo) and/or click **Refresh**. New plugins added to the repo may require **re-import** of the repo URL — confirm in live docs. |
| **Personal `/add-plugin`** | Docs focus Team refresh. In practice this path often pins a commit; Update/Reinstall may no-op. Prefer **`sync-local`** with the same GitHub URL (or a fresh clone path) to replace `~/.cursor/plugins/local/<name>`. |
| **Local copies** | Re-run `sync-local` with path or URL (+ optional plugin names / ref). Then Reload Window. |
| **Official Marketplace** | Use Customize install/update UI per current docs; do not invent version pins. |

## Steps

1. Fetch docs; state which install method applies.
2. Recommend the matching update path; execute `sync-local` when that is the chosen path.
3. If Team Auto Refresh fails, check GitHub App install per integrations docs.
4. Remind: multi-plugin marketplaces update **installed** plugins; brand-new catalog entries may need re-import (Team) or re-sync (local).

## Do not

- Promise personal `/add-plugin` auto-updates unless live docs explicitly document them.
- Delete the user’s other local plugins unless asked.
