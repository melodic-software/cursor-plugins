---
name: install-marketplace
description: Install a Cursor plugin marketplace or plugin for the user's plan (Ultra/personal, Teams, Enterprise). Fetches official Cursor docs live, then guides /add-plugin, Team Dashboard import, or local sync.
---

# Install a Cursor marketplace / plugin (plan-aware)

## Official docs (fetch live first — mandatory)

Before any recommendation, fetch and skim:

1. https://cursor.com/docs/plugins — Team marketplaces, Add marketplace, Installing plugins, Test plugins locally
2. https://cursor.com/docs/reference/plugins — multi-plugin `marketplace.json` shape
3. https://cursor.com/docs/integrations/github — only if Team Auto Refresh / GitHub App comes up

Use `plugins/plugin-ops/reference/DOC-SOURCES.md`. **Docs win** over this skill.
Melodic policy: `docs/PLUGIN-PHILOSOPHY.md`.

## Clarify

1. **Source** — GitHub repo URL and whether it is a marketplace (`marketplace.json`) or single plugin.
2. **Plan / role** — Ultra/Pro personal, Teams member, Teams/Enterprise **admin**, or unknown (ask).
3. **Audience** — just this user, a group, or whole org.
4. **Goal** — browse/install selectively vs force local copies.

## Decision tree (after docs)

| Situation | Path to prefer (confirm against live docs) |
| --- | --- |
| Personal / Ultra / “just me” + easy UI | `/add-plugin <github-url>` (personal marketplace). Warn that refresh/update may be flaky; offer `sync-local` as the reliable updater. |
| Enterprise/Teams **admin** + share with org/group | Dashboard → **Plugins** → **Team Marketplaces** → **Add Marketplace** / Import from Repo. Set Marketplace Access + install modes per docs. |
| Admin but **only myself** | Prefer personal `/add-plugin` or `sync-local`. Team Marketplace is org-scoped; restricting to a one-person Organization Group is possible but heavier. |
| Teams/Enterprise **member** (not admin) | Install from Customize after admin added the marketplace; cannot import the repo yourself. |
| Need disk-truth / stuck updates | `sync-local` with path or URL (real copies into `~/.cursor/plugins/local`). |
| Official Cursor Marketplace listing | Publish flow at https://cursor.com/marketplace/publish — separate from Team/personal GitHub import. |

## Steps

1. Fetch docs; note today’s date.
2. Map user answers → one primary path (+ fallback).
3. Give **exact** UI labels / commands from the fetched docs (not memory).
4. For multi-plugin repos: explain marketplace = catalog; user installs **individual** plugins from Customize after the marketplace is added.
5. Offer to run `sync-local` if they want local copies now.
6. End with Reload Window if anything was copied locally.

## Do not

- Claim Team Marketplace Auto Refresh exists for personal `/add-plugin` unless docs say so.
- Put Melodic (or any third-party) marketplace into a work org without the user confirming policy.
