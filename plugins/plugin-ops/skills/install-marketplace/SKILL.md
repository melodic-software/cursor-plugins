---
name: install-marketplace
description: Install a Cursor plugin marketplace or plugin for the user's plan (Ultra/personal, Teams, Enterprise). Fetches official Cursor docs live, then guides /plugin marketplace add, Team Dashboard import, or local sync.
---

# Install a Cursor marketplace / plugin (plan-aware)

## Official docs (fetch live first — mandatory)

Before any recommendation, fetch and skim:

1. https://cursor.com/docs/plugins — sections **Team marketplaces**, **Add a team marketplace**, **Installing plugins**, **Test plugins locally**
2. https://cursor.com/docs/reference/plugins — multi-plugin `marketplace.json` shape
3. https://cursor.com/docs/integrations/github — only if Team Auto Refresh / GitHub App comes up

Use `plugins/plugin-ops/reference/DOC-SOURCES.md`. **Docs win** over this skill.
Melodic policy: `docs/PLUGIN-PHILOSOPHY.md`.

**Verified 2026-08-30.** The literal string `/add-plugin` does not appear anywhere in
the current docs. A **user-scoped marketplace added by git URL** very much does — it
just has a different command. From
https://cursor.com/docs/cli/reference/slash-commands and
https://cursor.com/docs/cli/changelog:

- `/plugin marketplace add <git-url>` registers a marketplace; `/plugin` also browses
  and manages marketplaces **by scope** and installs at user or project scope.
- Non-interactively: `agent plugin marketplace add <git-url>`, with `--git-ref` to pin
  a branch, tag, or commit; `list` (add `--format json`), `update` to re-index from
  the repository, and `remove` for a **user-scoped** marketplace.
- `--plugin-dir <path>` loads a local plugin directory.

So `/add-plugin` is a **renamed** command, not a removed capability. Do not tell a user
that personal, non-team marketplaces are undocumented — route them to
`/plugin marketplace add` instead. Re-fetch both pages before advising.

## Clarify

1. **Source** — GitHub repo URL and whether it is a marketplace (`marketplace.json`) or single plugin.
2. **Plan / role** — Ultra/Pro personal, Teams member, Teams/Enterprise **admin**, or unknown (ask).
3. **Audience** — just this user, a group, or whole org.
4. **Goal** — browse/install selectively vs force local copies.

## Decision tree (after docs)

| Situation | Path to prefer (confirm against live docs) |
| --- | --- |
| Personal / Ultra / “just me”, third-party repo (this marketplace included) | `/plugin marketplace add <git-url>`, then install the plugins you want at user or project scope. Pin with `agent plugin marketplace add <git-url> --git-ref <ref>`; refresh with `/plugin marketplace update`. **Customize** browses what is already registered, so it will not find an unregistered third-party repo — register it first. `/add-plugin` is the old name for this; if the user reports it, they mean this route. |
| Enterprise/Teams **admin** + share with org/group | Dashboard → **Plugins** → **Team Marketplaces** → **Add Marketplace** / Import from Repo. Set Marketplace Access + install modes per docs. |
| Admin but **only myself** | Prefer a user-scoped `/plugin marketplace add <git-url>`, or `sync-local`. Team Marketplace is org-scoped; restricting to a one-person Organization Group is possible but heavier. |
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

- Claim Team Marketplace Auto Refresh reaches anything outside a Team marketplace (personal installs, `~/.cursor/plugins/local`) unless docs say so.
- Put Melodic (or any third-party) marketplace into a work org without the user confirming policy.
