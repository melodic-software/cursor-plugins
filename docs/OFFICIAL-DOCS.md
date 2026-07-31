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
| Skills (`skills/`) | https://cursor.com/docs/skills | Primary | 2026-07-31 |
| Skills (help) | https://cursor.com/help/customization/skills | Primary (help) | 2026-07-31 |
| Commands (`commands/`) | https://cursor.com/docs/reference/plugins (Commands format) | Discouraged here — still documented by Cursor | 2026-07-31 |
| Rules (`rules/`) | https://cursor.com/docs/rules | Adopt on need | 2026-07-31 |
| Agents (`agents/`) | https://cursor.com/docs/reference/plugins (Agents format) | Adopt on need | 2026-07-31 |
| Hooks | https://cursor.com/docs/hooks | Adopt on need | 2026-07-31 |
| Third-party / Claude Code hooks | https://cursor.com/docs/reference/third-party-hooks | Reshape / document separately | 2026-07-31 |
| MCP | https://cursor.com/docs/mcp | Adopt on need | 2026-07-31 |

## Authoring / packaging

| Topic | Official doc | Verified |
| --- | --- | --- |
| Plugins overview (Team, install, local test) | https://cursor.com/docs/plugins | 2026-07-31 |
| Plugins reference (manifests, discovery, marketplace.json, variables) | https://cursor.com/docs/reference/plugins | 2026-07-31 |
| Plugin template | https://github.com/cursor/plugin-template | 2026-07-31 |
| Publish to Cursor Marketplace | https://cursor.com/marketplace/publish | 2026-07-31 |
| Agent Skills open standard | https://agentskills.io | 2026-07-31 |

## Distribution / marketplace

| Topic | Official doc | Verified |
| --- | --- | --- |
| Team marketplaces, Auto Refresh, install modes | https://cursor.com/docs/plugins | 2026-07-31 |
| GitHub App (Team Auto Refresh) | https://cursor.com/docs/integrations/github | 2026-07-31 |
| Test plugins locally (`~/.cursor/plugins/local`) | https://cursor.com/docs/plugins (Test plugins locally) | 2026-07-31 |

Optional community index (not official): https://cursor.directory

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
