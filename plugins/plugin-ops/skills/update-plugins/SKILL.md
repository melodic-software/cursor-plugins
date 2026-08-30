---
name: update-plugins
description: Update installed Cursor plugins/marketplaces for the user's plan. Fetches official docs live; covers Team Auto Refresh, /plugin marketplace update for personally-added marketplaces, and local sync-from-URL/path.
---

# Update Cursor plugins (plan-aware)

## Official docs (fetch live first — mandatory)

1. https://cursor.com/docs/plugins — sections **Keep plugins up to date** (Auto Refresh / Refresh), **Installing plugins**, **Managing installed plugins**
2. https://cursor.com/docs/integrations/github — GitHub App requirement for Auto Refresh
3. https://cursor.com/docs/reference/plugins — only if validating marketplace layout after a pull

`plugins/plugin-ops/reference/DOC-SOURCES.md` lists URLs. **Docs win.**
Melodic policy: `docs/PLUGIN-PHILOSOPHY.md`.

**Verified 2026-08-30.** The string `/add-plugin` does not appear in the current docs,
but the capability was renamed, not removed: `/plugin marketplace add <git-url>`
registers a **user-scoped** marketplace, and `/plugin marketplace update` re-indexes
one from its repository (https://cursor.com/docs/cli/reference/slash-commands,
https://cursor.com/docs/cli/changelog). So there *is* a documented refresh story for
personally-added marketplaces. Read the row below as the current command, and treat
`/add-plugin` as the old name users may still say. See `install-marketplace`.

## Clarify how they installed

- Official Cursor Marketplace plugin
- Team Marketplace (org)
- Personally-added marketplace via `/plugin marketplace add <url>` (older sessions: `/add-plugin`; ask what they actually ran, and whether they pinned a `--git-ref`)
- Local `~/.cursor/plugins/local`
- Unknown → ask / inspect Customize scopes

## Update paths (verify against fetched docs)

| Install method | Update approach |
| --- | --- |
| **Team Marketplace** | Per docs: **Enable Auto Refresh** (needs the Cursor GitHub App on the repo) and/or click **Refresh**. Cursor re-indexes at most once every 10 minutes, batching rapid pushes to the latest commit. Whether new catalog entries are picked up depends on how the marketplace was created: **Import from Repo** re-reads the full manifest on each push, so new plugins appear automatically; marketplaces whose plugins were added individually refresh only *existing* plugins, and need a **re-import of the repo URL** for new ones. |
| **Personally-added marketplace** (`/plugin marketplace add`, formerly `/add-plugin`) | Documented refresh: `/plugin marketplace update` (or `agent plugin marketplace update`) re-indexes it from the repository. Note the marketplace may be **pinned** — `--git-ref` sets a branch, tag, or commit at add time — so an `update` that appears to no-op usually means it is pinned to a ref, not broken; re-add without `--git-ref`, or point it at a moving branch. `sync-local` remains the disk-truth fallback. |
| **Local copies** | Re-run `sync-local` with path or URL (+ optional plugin names / ref). Then Reload Window. |
| **Official Marketplace** | Use Customize install/update UI per current docs; do not invent version pins. |

## Steps

1. Fetch docs; state which install method applies.
2. Recommend the matching update path; execute `sync-local` when that is the chosen path.
3. If Team Auto Refresh fails, check GitHub App install per integrations docs.
4. Remind: refresh updates **installed** plugins. Brand-new catalog entries need a re-import of the repo URL on Team marketplaces built by adding plugins individually (Import-from-Repo marketplaces pick them up on their own), or a re-run of `sync-local` for local copies.

## Do not

- Promise that a personally-added marketplace auto-updates. The documented refresh is
  explicit (`/plugin marketplace update`); Auto Refresh is a Team Marketplace feature.
- Delete the user’s other local plugins unless asked.
