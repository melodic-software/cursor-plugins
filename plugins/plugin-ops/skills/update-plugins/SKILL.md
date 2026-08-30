---
name: update-plugins
description: Update installed Cursor plugins/marketplaces for the user's plan. Fetches official docs live; covers Team Auto Refresh, personal /add-plugin limits, and local sync-from-URL/path.
---

# Update Cursor plugins (plan-aware)

## Official docs (fetch live first — mandatory)

1. https://cursor.com/docs/plugins — sections **Keep plugins up to date** (Auto Refresh / Refresh), **Installing plugins**, **Managing installed plugins**
2. https://cursor.com/docs/integrations/github — GitHub App requirement for Auto Refresh
3. https://cursor.com/docs/reference/plugins — only if validating marketplace layout after a pull

`plugins/plugin-ops/reference/DOC-SOURCES.md` lists URLs. **Docs win.**
Melodic policy: `docs/PLUGIN-PHILOSOPHY.md`.

**Verified 2026-08-30.** `/add-plugin` and “personal marketplace” do not appear
anywhere in the current Cursor docs; the documented install routes are the Cursor
Marketplace via **Customize**, Team marketplaces, and `~/.cursor/plugins/local`.
Treat the `/add-plugin` row below as *how some users got here*, not as a supported
path to recommend, unless a live fetch shows otherwise. See `install-marketplace`.

## Clarify how they installed

- Official Cursor Marketplace plugin
- Team Marketplace (org)
- Personal `/add-plugin <url>` (undocumented — see note above; ask what they actually ran)
- Local `~/.cursor/plugins/local`
- Unknown → ask / inspect Customize scopes

## Update paths (verify against fetched docs)

| Install method | Update approach |
| --- | --- |
| **Team Marketplace** | Per docs: **Enable Auto Refresh** (needs the Cursor GitHub App on the repo) and/or click **Refresh**. Cursor re-indexes at most once every 10 minutes, batching rapid pushes to the latest commit. Whether new catalog entries are picked up depends on how the marketplace was created: **Import from Repo** re-reads the full manifest on each push, so new plugins appear automatically; marketplaces whose plugins were added individually refresh only *existing* plugins, and need a **re-import of the repo URL** for new ones. |
| **Personal `/add-plugin`** | Not a documented route (see note above). If a user is on it, docs offer no refresh story; in practice it pins a commit and Update/Reinstall may no-op. Move them to **`sync-local`** with the same GitHub URL (or a fresh clone path) to replace `~/.cursor/plugins/local/<name>`, or to a **Customize** install. |
| **Local copies** | Re-run `sync-local` with path or URL (+ optional plugin names / ref). Then Reload Window. |
| **Official Marketplace** | Use Customize install/update UI per current docs; do not invent version pins. |

## Steps

1. Fetch docs; state which install method applies.
2. Recommend the matching update path; execute `sync-local` when that is the chosen path.
3. If Team Auto Refresh fails, check GitHub App install per integrations docs.
4. Remind: refresh updates **installed** plugins. Brand-new catalog entries need a re-import of the repo URL on Team marketplaces built by adding plugins individually (Import-from-Repo marketplaces pick them up on their own), or a re-run of `sync-local` for local copies.

## Do not

- Promise personal `/add-plugin` auto-updates unless live docs explicitly document them.
- Delete the user’s other local plugins unless asked.
