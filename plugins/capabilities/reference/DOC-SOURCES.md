# Official sources for discovering Cursor capabilities (fetch live)

A **pointer index**, not a cache. The skill in this plugin never hard-codes what Cursor
ships; it fetches these pages and inspects the machine it is running on, then reports
what exists **today**. A built-in skill, tool, integration, or plan limit named anywhere
in this repository is an observation with a date, never a fact to reuse.

Repo policy: [`docs/PLUGIN-PHILOSOPHY.md`](../../../docs/PLUGIN-PHILOSOPHY.md).

## Read order

1. **Tier 0 — live index.** First, always; finds renamed and new pages.
2. **Tier 1 — official docs.** The only tier a skill may state availability from.
3. **Tier 2 — official changelog.** Catches capabilities newer than the docs; dates them.
4. **Tier 3 — Cursor staff replies on the forum.** Dated statements about undocumented
   behavior; cite as "staff statement, <date>".
5. **Tier 4 — third parties.** Not indexed. Search on demand, label, and defer to Tier 1
   on any conflict.

## Tier 0 — live index

| Topic | URL | Verified |
| --- | --- | --- |
| Every Cursor docs page, grouped by section | https://cursor.com/docs/llms.txt | 2026-09-02 |

## Tier 1 — official docs

*Use for* names the question that sends you to the page; it is not a summary.

### Built-in surfaces (`Agent`, `customizing`, `cli`)

| Use for | URL | Verified |
| --- | --- | --- |
| **Built-in Cursor skills** table; skill directories; which directories load in cloud vs local; custom modes; `/migrate-to-skills` | https://cursor.com/docs/skills | 2026-09-02 |
| Agent tools (search, web, read/edit, shell, browser, image generation, ask questions), queueing, `/goal` | https://cursor.com/docs/agent/overview | 2026-09-02 |
| Plan, Debug, Design modes | https://cursor.com/docs/agent/plan-mode · https://cursor.com/docs/agent/debug-mode · https://cursor.com/docs/agent/design-mode | listed in index; not fetched this session |
| Subagents (built-in and custom) | https://cursor.com/docs/subagents | request timed out on 2026-09-02 — unverified, not dead |
| CLI slash commands (`/plugin`, `/mcp`, `/shell`, `/goal`, …) | https://cursor.com/docs/cli/reference/slash-commands | 2026-09-02 |
| CLI changelog (authority for `agent plugin …` subcommands, `--plugin-dir`, `/usage`) | https://cursor.com/docs/cli/changelog | 2026-09-02 |
| Rules: project, user, team, `AGENTS.md`, nested `AGENTS.md`, precedence | https://cursor.com/docs/rules | 2026-09-02 |
| Hooks: events, cloud support matrix, configuration sources, plugin hooks | https://cursor.com/docs/hooks | 2026-09-02 |
| Claude Code compatibility and the third-party toggle | https://cursor.com/docs/reference/third-party-hooks | 2026-09-02 |
| MCP configuration and scopes | https://cursor.com/docs/mcp | listed in index; not fetched this session |

### Plugins and marketplaces (`customizing`)

| Use for | URL | Verified |
| --- | --- | --- |
| Plugin formats, Customize page, team marketplaces, install modes, local plugin folder | https://cursor.com/docs/plugins | 2026-09-02 |
| Component discovery and manifests | https://cursor.com/docs/reference/plugins | 2026-09-02 |
| Public marketplace catalog (official plugins and automation templates) | https://cursor.com/marketplace | 2026-09-02 |
| Plugins FAQ | https://cursor.com/help/customization/plugins | 2026-09-02 |
| Marketplace security and review model | https://cursor.com/help/security-and-privacy/marketplace-security | 2026-09-02 |

### Cloud-only capabilities (`cloud-agents`)

| Use for | URL | Verified |
| --- | --- | --- |
| Where cloud agents start from; MCP and hooks support; artifacts; sharing | https://cursor.com/docs/cloud-agent | 2026-09-02 |
| Computer use, artifacts, remote desktop, **Cursor Cloud MCP tools**, **subscriptions** (`/subscribe`, `/loop`), CI autofix | https://cursor.com/docs/cloud-agent/capabilities | 2026-09-02 |
| Automations: triggers, tools, and the three **Cursor-managed agents** | https://cursor.com/docs/automations | 2026-09-02 |
| Bugbot (including `/review-bugbot` context) | https://cursor.com/docs/bugbot | 2026-09-02 |
| PR Routing & Approval | https://cursor.com/docs/approval-agents | 2026-09-02 |
| Security Agents | https://cursor.com/docs/security-agents | listed in index; not fetched this session |

### Integrations (`Integrations`)

| Use for | URL | Verified |
| --- | --- | --- |
| GitHub | https://cursor.com/docs/integrations/github | 2026-09-02 |
| Slack | https://cursor.com/docs/integrations/slack | 2026-09-02 |
| Jira (plan-gated) | https://cursor.com/docs/integrations/jira | 2026-09-02 |
| Linear | https://cursor.com/docs/integrations/linear | 2026-09-02 |
| GitLab · Bitbucket · Azure DevOps · Microsoft Teams · Notion · JetBrains · Xcode | see the `Integrations` section of the Tier 0 index | listed in index; not fetched this session |

### Plan gates (`Get Started`, `Account`)

| Use for | URL | Verified |
| --- | --- | --- |
| Which individual plans include Cloud Agents, Bugbot, Automations, plugins | https://cursor.com/docs/models-and-pricing | 2026-09-02 |
| Enterprise-only controls (model access, MCP allowlist, Protected Git Scopes) | https://cursor.com/docs/enterprise/model-and-integration-management | 2026-09-02 |
| Teams pricing detail | https://cursor.com/docs/account/teams/pricing | request timed out twice on 2026-09-02 — unverified, not dead |

Gates are also stated inline on feature pages; the feature page is authoritative for its
own gate.

### Standards the formats follow

| Use for | URL | Verified |
| --- | --- | --- |
| Agent Skills specification (`SKILL.md` frontmatter, naming, progressive disclosure) | https://agentskills.io/specification | 2026-09-02 |
| Agent Plugins standard (portable `plugin.json` + skills + MCP) | https://agent-plugins.org | 2026-09-02 |

## Tier 2 — official changelog

| Use for | URL | Verified |
| --- | --- | --- |
| Dated announcements of new capabilities | https://cursor.com/changelog | 2026-09-02 (HTML only — `changelog.md` returns 404) |

## Tier 3 — Cursor staff statements on the community forum

| Established (as of the reply date) | Thread | Reply date |
| --- | --- | --- |
| Repo-committed skills load in cloud agents; a team marketplace plugin marked Required is the managed distribution path for IDE users; no dashboard "roll out a skill" button | https://forum.cursor.com/t/shared-skills-on-cloud-agents/165324 | 2026 |

## Expansion rule

When Tiers 0–3 are silent, search the web, prefer `cursor.com`, then the forum, then
everything else; label the tier of what you cite; propose the URL for this index in your
reply. Ranking and deprecation policy for this index is a later concern and is deliberately
not specified yet.

## Fetch status, 2026-09-02

Rows marked `2026-09-02` returned HTTP 200 with content matching their *Use for* cell.
Rows marked *listed in index* were taken from the Tier 0 index and not opened. Two pages
timed out (`subagents`, `account/teams/pricing`): unverified, not evidence of a dead link.
