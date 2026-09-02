# Official docs (Cursor)

Jump sheet of canonical Cursor URLs for authoring and operating this marketplace.
Skills under `plugins/plugin-ops/` **fetch these pages live** before advising.

> **This file goes stale. The platform changes constantly.** Always re-fetch the
> linked page before acting on it — never trust row descriptions or remembered
> content as procedures. When docs and this repo disagree, **docs win**. A fetch
> that no longer matches a row is that row’s recheck trigger: update the row and
> its verified date. Skill-facing copy of the URL list:
> [`plugins/plugin-ops/reference/DOC-SOURCES.md`](../plugins/plugin-ops/reference/DOC-SOURCES.md).

Policy: [PLUGIN-PHILOSOPHY.md](PLUGIN-PHILOSOPHY.md).  
Ports: [MIGRATION-PLAYBOOK.md](MIGRATION-PLAYBOOK.md).

## Plugin components → doc page

| Component | Official doc | Melodic stance | Verified |
| --- | --- | --- | --- |
| Skills (`skills/`) | https://cursor.com/docs/skills | Primary | 2026-08-30 |
| Skills (help) | https://cursor.com/help/customization/skills | Primary (help) | 2026-08-30 |
| Commands (`commands/`) | https://cursor.com/docs/reference/plugins (Commands format) | Discouraged here — still documented by Cursor | 2026-08-30 |
| Rules (`rules/`) | https://cursor.com/docs/rules | Adopt on need | 2026-08-30 |
| Agents (`agents/`) | https://cursor.com/docs/reference/plugins (Agents format) | Adopt on need | 2026-08-30 |
| Hooks | https://cursor.com/docs/hooks | Adopt on need | 2026-08-30 |
| Third-party / Claude Code hooks | https://cursor.com/docs/reference/third-party-hooks | Reshape / document separately — Cursor loads Claude Code hooks only after "Include third-party Plugins, Skills, and other configs" is enabled | 2026-08-30 |
| MCP | https://cursor.com/docs/mcp | Adopt on need | 2026-08-30 |

## Authoring / packaging

| Topic | Official doc | Verified |
| --- | --- | --- |
| Plugins overview (Team, install, local test) | https://cursor.com/docs/plugins | 2026-08-30 |
| Plugins reference (manifests, discovery, marketplace.json, variables) | https://cursor.com/docs/reference/plugins | 2026-08-30 |
| Plugin template | https://github.com/cursor/plugin-template | **blocked** — HTTP 403 via proxy on 2026-08-30 (bot response, not a dead link; see [DOC-SOURCES fetch status](../plugins/plugin-ops/reference/DOC-SOURCES.md#fetch-status-2026-08-30)) |
| Marketplace manifest JSON Schema (authority; prose table is looser) | https://raw.githubusercontent.com/cursor/plugins/main/schemas/marketplace.schema.json | 2026-08-30 |
| Plugin manifest JSON Schema (declares `category`, `tags`) | https://raw.githubusercontent.com/cursor/plugins/main/schemas/plugin.schema.json | 2026-08-30 |
| CLI slash commands (lists `/plugin [subcommand]` — "Manage plugins and marketplaces") | https://cursor.com/docs/cli/reference/slash-commands | 2026-08-30 |
| CLI changelog (authority for `/plugin marketplace add <git-url>`, `--git-ref` pinning, `marketplace list/update/remove`, `--plugin-dir`; user-scoped marketplaces) | https://cursor.com/docs/cli/changelog | 2026-08-30 |
| Publish to Cursor Marketplace | https://cursor.com/marketplace/publish | 2026-08-30 |
| Agent Skills open standard | https://agentskills.io | 2026-08-30 |

## Distribution / marketplace

| Topic | Official doc | Verified |
| --- | --- | --- |
| Team marketplaces, Auto Refresh, install modes | https://cursor.com/docs/plugins | 2026-08-30 |
| GitHub App (required by Team Auto Refresh; Auto Refresh itself is documented on the plugins page) | https://cursor.com/docs/integrations/github | 2026-08-30 |
| Test plugins locally (`~/.cursor/plugins/local`) | https://cursor.com/docs/plugins (Test plugins locally) | 2026-08-30 |

## Automations, cloud agents, and capability discovery

Those concerns have their own tiered source indexes, owned by the plugin that reads them
(things that change together live together):

| Concern | Index |
| --- | --- |
| Automations, cloud agent runtime, trigger sources, managed agents, programmatic lanes | [`plugins/automations/reference/DOC-SOURCES.md`](../plugins/automations/reference/DOC-SOURCES.md) |
| Built-in skills, agent tools, plugins, MCP, integrations, plan gates | [`plugins/capabilities/reference/DOC-SOURCES.md`](../plugins/capabilities/reference/DOC-SOURCES.md) |

Both start from the live page index https://cursor.com/docs/llms.txt (verified 2026-09-02),
which is the self-healing root for every URL in this repository.

Optional community index (not official): https://cursor.directory — **blocked**,
HTTP 429 via proxy on 2026-08-30 (rate limit, not a dead link; see
[DOC-SOURCES fetch status](../plugins/plugin-ops/reference/DOC-SOURCES.md#fetch-status-2026-08-30)).

Every other Cursor URL on this page was fetched live on 2026-08-30 and returned
HTTP 200. A `Verified` date here means exactly that — a live fetch whose content
still matched the row — never "the row was edited that day".

## Claude Code (inspiration only)

Ideas may come from [`melodic-software/claude-code-plugins`](https://github.com/melodic-software/claude-code-plugins).
Manifests and runtime here are Cursor-only. Do not treat Claude “commands merged /
prohibited” as Cursor platform law — see [PLUGIN-PHILOSOPHY.md](PLUGIN-PHILOSOPHY.md).

| Topic | Official Claude doc |
| --- | --- |
| Plugins | https://code.claude.com/docs/en/plugins |
| Plugins reference | https://code.claude.com/docs/en/plugins-reference |
| Skills (commands merged note) | https://code.claude.com/docs/en/skills |
| Plugin marketplaces | https://code.claude.com/docs/en/plugin-marketplaces |
| Claude docs master list | https://code.claude.com/docs/llms.txt |
