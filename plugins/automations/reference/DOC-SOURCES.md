# Official sources for Cursor Automations (fetch live)

This is a **pointer index**, not a cache. Skills in this plugin fetch the pages below
at run time and reason from what they read today. Nothing in this file describes how
a trigger, tool, setting, or plan limit behaves — that text lives upstream and changes
without notice. When a fetched page and anything in this repo disagree, **the page
wins**, and the disagreement is the trigger to update this index.

Repo policy: [`docs/PLUGIN-PHILOSOPHY.md`](../../../docs/PLUGIN-PHILOSOPHY.md).
Lane model this index serves: [`LANES.md`](LANES.md).

## Read order

1. **Tier 0 — the live index.** Always first. It lists every current page, so a
   renamed or added page is found without editing this file.
2. **Tier 1 — official docs.** The only tier a skill may state platform facts from.
3. **Tier 2 — official changelog.** Newer than docs; use it to catch behavior the docs
   have not absorbed yet, and to date a feature.
4. **Tier 3 — Cursor staff replies on the community forum.** Dated statements about
   undocumented behavior. Cite as "staff statement, <date>", never as documentation.
5. **Tier 4 — third parties.** Never indexed here. Search on demand when Tiers 0–3 are
   silent, label the source, and treat any claim that contradicts Tier 1 as wrong
   until Tier 1 says otherwise. (Live example, 2026-09-02: several blogs describe a
   `.cursor/automations/*.yml` config format that the official docs do not have.)

## Tier 0 — live index

| Topic | URL | Verified |
| --- | --- | --- |
| Every Cursor docs page, grouped by section | https://cursor.com/docs/llms.txt | 2026-09-02 |

Section names used below (`cloud-agents`, `Integrations`, `customizing`, `cli`, `Account`,
`Help Center`) are the headings of that index.

## Tier 1 — official docs

Column *Use for* says which question sends you to the page; it is not a summary of the page.

### Automations core (`cloud-agents`)

| Use for | URL | Verified |
| --- | --- | --- |
| Triggers by provider, tools, repository modes, permission scopes, billing, identity, prompt-writing tips | https://cursor.com/docs/automations | 2026-09-02 |
| Same page under its section path (either resolves) | https://cursor.com/docs/cloud-agent/automations | 2026-09-02 |
| Plain-language FAQ, trigger table, tool list | https://cursor.com/help/ai-features/automations | 2026-09-02 |

### Cloud agent runtime (`cloud-agents`)

| Use for | URL | Verified |
| --- | --- | --- |
| What a run is, where it can be started from, MCP and hooks support summary, artifacts, sharing, billing | https://cursor.com/docs/cloud-agent | 2026-09-02 |
| Computer use, artifacts, remote desktop, MCP transports, Cursor Cloud MCP tools, subscriptions, CI autofix, OIDC | https://cursor.com/docs/cloud-agent/capabilities | 2026-09-02 |
| Environments, multi-repo environments, resolution order, install/start, `environment.json`, secrets, Docker/Tailscale/Cloudflare | https://cursor.com/docs/cloud-agent/setup | 2026-09-02 |
| `environment.json` JSON Schema (authority for allowed keys; draft 2019-09) | https://cursor.com/schemas/environment.schema.json | 2026-09-02 |
| Dashboard defaults, network modes, security toggles, team feature flags, team follow-ups | https://cursor.com/docs/cloud-agent/settings | 2026-09-02 |
| Secret types (Environment Variable / Runtime / Build), egress allowlists, artifact upload host, retention | https://cursor.com/docs/cloud-agent/security-network | 2026-09-02 |
| Rules levels a cloud agent reads (user, team, repo), skills and `AGENTS.md` guidance | https://cursor.com/docs/cloud-agent/best-practices | 2026-09-02 |
| Run metadata readable from inside the VM (`agent/source`, `workspace/automation-id`, …) | https://cursor.com/docs/cloud-agent/metadata | 2026-09-02 |
| Builds (prebuilt environments) | https://cursor.com/docs/cloud-agent/builds | 2026-09-02 |
| Security architecture overview | https://cursor.com/docs/cloud-agent/security | listed in index; not fetched this session |
| OIDC identity tokens | https://cursor.com/docs/cloud-agent/identity | listed in index; not fetched this session |

### Context a run loads from the repository (`customizing`)

| Use for | URL | Verified |
| --- | --- | --- |
| `AGENTS.md`, project rules, Team Rules, precedence | https://cursor.com/docs/rules | 2026-09-02 |
| Skill directories, which are loaded in cloud vs local, built-in skills table | https://cursor.com/docs/skills | 2026-09-02 |
| Hooks: cloud-agent support matrix, configuration sources, command-only limit | https://cursor.com/docs/hooks | 2026-09-02 |
| Claude Code hooks compatibility and the third-party toggle | https://cursor.com/docs/reference/third-party-hooks | 2026-09-02 |
| Plugins, team marketplaces, install modes, local imports | https://cursor.com/docs/plugins | 2026-09-02 |

### Trigger sources and integrations (`Integrations`)

| Use for | URL | Verified |
| --- | --- | --- |
| GitHub app setup, permissions, GHES, IP allow lists, Protected Git Scopes | https://cursor.com/docs/integrations/github | 2026-09-02 |
| Slack: commands, options (`repo`, `env`, `branch`, `model`, `autopr`, `channel`), routing rules | https://cursor.com/docs/integrations/slack | 2026-09-02 |
| Jira: plan requirement, Rovo, assign / `@Cursor`, auth modes, routing rules | https://cursor.com/docs/integrations/jira | 2026-09-02 |
| Linear: delegate / `@Cursor`, `[key=value]` options, repo labels, triage rules | https://cursor.com/docs/integrations/linear | 2026-09-02 |
| GitLab | https://cursor.com/docs/integrations/gitlab | listed in index; not fetched this session |
| Bitbucket | https://cursor.com/docs/integrations/bitbucket | listed in index; not fetched this session |
| Azure DevOps | https://cursor.com/docs/integrations/azure-devops | listed in index; not fetched this session |
| Microsoft Teams | https://cursor.com/docs/integrations/microsoft-teams | listed in index; not fetched this session |
| Notion | https://cursor.com/docs/integrations/notion | listed in index; not fetched this session |

Sentry and PagerDuty triggers have no page of their own; they are sections of the
Automations page.

### Cursor-managed agents (`cloud-agents`)

| Use for | URL | Verified |
| --- | --- | --- |
| Bugbot: triggers, draft-PR setting, CI check statuses, rules, autofix, MCP, API | https://cursor.com/docs/bugbot | 2026-09-02 |
| PR Routing & Approval: reviewer assignment, risk approval, `APPROVAL_POLICY.md`, `.cursor/approval-policies/ROUTING.md` | https://cursor.com/docs/approval-agents | 2026-09-02 |
| Security Agents | https://cursor.com/docs/security-agents | listed in index; not fetched this session |

### Programmatic lanes (`cloud-agents`, `cli`, `SDK`)

| Use for | URL | Verified |
| --- | --- | --- |
| Cloud Agents API v1: create agent (`prompt`, `repos`/`env`, `autoCreatePR`, `mcpServers`, `customSubagents`, `envVars`), runs, artifacts | https://cursor.com/docs/cloud-agent/api/endpoints | 2026-09-02 |
| Outbound status webhooks from a run (`statusChange`, signature verification) | https://cursor.com/docs/cloud-agent/api/webhooks | 2026-09-02 |
| Cursor CLI in GitHub Actions; full vs restricted autonomy; permission allow/deny | https://cursor.com/docs/cli/github-actions | 2026-09-02 |
| CLI headless mode | https://cursor.com/docs/cli/headless | listed in index; not fetched this session |
| CLI changelog (authority for `agent plugin …`, `/plugin`, admin controls such as disabling headless) | https://cursor.com/docs/cli/changelog | 2026-09-02 |
| SDK (TypeScript, Python) | https://cursor.com/docs/sdk/typescript | listed in index; not fetched this session |

### Plan gates (`Account`, `Get Started`)

| Use for | URL | Verified |
| --- | --- | --- |
| Which individual plans include Cloud Agents, Bugbot, Automations; Teams vs Enterprise summary | https://cursor.com/docs/models-and-pricing | 2026-09-02 |
| Teams pricing detail | https://cursor.com/docs/account/teams/pricing | 2026-09-02 |
| Enterprise-only controls: model access, MCP allowlist, Protected Git Scopes, integrations | https://cursor.com/docs/enterprise/model-and-integration-management | 2026-09-02 |

Plan gates also appear inline on feature pages (Jira, Plugins, Bugbot, Settings). Read
the feature page; do not infer a gate from a pricing table alone.

## Tier 2 — official changelog

| Use for | URL | Verified |
| --- | --- | --- |
| Dated feature announcements (subscriptions, `/goal`, custom modes, Builds, Origin) | https://cursor.com/changelog | 2026-09-02 (HTML only — `changelog.md` returns 404) |

## Tier 3 — Cursor staff statements on the community forum

Dated, attributable, and **not documentation**. Re-check the thread before relying on
one; a later reply or a docs update supersedes it.

| Established (as of the reply date) | Thread | Reply date |
| --- | --- | --- |
| No config-as-code and no CRUD API for automations; both are tracked feature requests | https://forum.cursor.com/t/automations-as-code-or-api/162376 | 2026-06 |
| Same request, declarative-format angle | https://forum.cursor.com/t/config-as-code-for-automations/154831 | 2026-08 |
| A scheduled trigger that fires while a run of the same automation is active is skipped, not run in parallel; manual Play has no such guard | https://forum.cursor.com/t/disable-automations-play-while-a-run-is-in-progress/167539 | 2026-08-06 |
| Duplicate-run prevention for scheduled automations; a stuck run blocks later scheduled runs until cancelled or the automation is recreated | https://forum.cursor.com/t/cursor-automations-stopped-running-on-hourly-schedule/155679 | 2026-03-24 |
| A team-wide concurrent-agent limit and the team on-demand spend limit both block runs | https://forum.cursor.com/t/unable-to-run-automations/156379 | 2026-03 |
| Team Marketplace Auto Refresh requires the Cursor GitHub App on the org that hosts the marketplace repo | https://forum.cursor.com/t/cursor-2-6-team-marketplaces-for-plugins/153484 | 2026 |
| Repo-committed skills load in cloud agents; a team marketplace plugin marked Required is the managed distribution path for IDE users | https://forum.cursor.com/t/shared-skills-on-cloud-agents/165324 | 2026 |

## Expansion rule

When a question is not answered by Tiers 0–3: search the web, prefer results on
`cursor.com`, then the forum, then everything else; label the tier of whatever you
cite; and propose the URL for this index in your reply (topic, URL, tier, what it
answered). Adding, re-ordering, or deprecating rows is a repository change reviewed
like any other. Ranking and deprecation policy for this index is a later concern and is
deliberately not specified yet.

## Fetch status, 2026-09-02

Every Tier 1 and Tier 2 row marked `2026-09-02` returned HTTP 200 with content that
matched its *Use for* cell. Rows marked *listed in index* were taken from the Tier 0
index and not opened. `https://cursor.com/docs/account/teams/pricing` and
`https://cursor.com/docs/cloud-agent/builds` were re-fetched this session (both
HTTP 200; pricing had timed out earlier the same calendar day). A timeout, 403,
or 429 is a refusal to serve this client, not a statement about the resource;
only a 404/410 from an unthrottled fetch is evidence of a dead link.
