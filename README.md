# cursor-plugins

Melodic Software — **Cursor** plugin marketplace: reusable, repo-agnostic skills,
agents, rules, hooks, and MCP servers under Cursor-native contracts.

This repository is intentionally separate from
[`claude-code-plugins`](https://github.com/melodic-software/claude-code-plugins)
(Claude Code marketplace). Ideas may be inspired by that catalog; manifests and
runtime behavior here are Cursor-only.

## Docs

| Doc | Purpose |
| --- | --- |
| [docs/PLUGIN-PHILOSOPHY.md](docs/PLUGIN-PHILOSOPHY.md) | Component stances, skills-first policy, Claude vs Cursor |
| [docs/MIGRATION-PLAYBOOK.md](docs/MIGRATION-PLAYBOOK.md) | Port gates from Claude → Cursor |
| [docs/OFFICIAL-DOCS.md](docs/OFFICIAL-DOCS.md) | Official URL jump sheet (fetch live; not a procedure cache) |

## Layout

```text
.cursor-plugin/marketplace.json   # marketplace catalog
plugins/<name>/
  .cursor-plugin/plugin.json      # per-plugin manifest
  skills/                         # primary capability surface
  agents/ | rules/ | hooks/ | mcp.json   # adopt on need
scripts/sync-local.*              # sync any path/URL into ~/.cursor/plugins/local
docs/PLUGIN-PHILOSOPHY.md
docs/MIGRATION-PLAYBOOK.md
docs/OFFICIAL-DOCS.md
```

Skills are the primary surface (they appear in Agent `/`). Do not add new
`commands/` — see philosophy.

## Install / update (all plans)

Use **`plugin-ops`** skills (they fetch [Cursor docs](https://cursor.com/docs/plugins) live):

| Goal | Skill |
| --- | --- |
| Add a marketplace the right way for your plan | `/install-marketplace` |
| Update after upstream changes | `/update-plugins` |
| Force disk copies (path or git URL) | `/sync-local` |
| Validate layout vs live docs + Melodic policy | `/verify-plugin` |

Script (works for **any** marketplace or single-plugin repo, not only Melodic):

```powershell
pwsh -File scripts/sync-local.ps1 -Source https://github.com/org/repo
pwsh -File scripts/sync-local.ps1 -Source . -Plugin plugin-ops
```

```bash
bash scripts/sync-local.sh https://github.com/org/repo
bash scripts/sync-local.sh . plugin-ops
```

Then **Developer: Reload Window**.

Plan cheat-sheet (always re-check live docs):

- **Personal / Ultra:** **Customize** → find the plugin → **Install** (project or user
  scope), and/or `sync-local`. The current docs document **no** `/add-plugin` command.
- **Teams/Enterprise admin:** Dashboard → Plugins → Team Marketplaces (Auto Refresh optional)
- **Org member:** install from Customize after admin import

## Contributing

1. Follow [docs/PLUGIN-PHILOSOPHY.md](docs/PLUGIN-PHILOSOPHY.md); fetch live docs via [docs/OFFICIAL-DOCS.md](docs/OFFICIAL-DOCS.md) / `plugin-ops`.
2. Port Claude ideas via [docs/MIGRATION-PLAYBOOK.md](docs/MIGRATION-PLAYBOOK.md).
3. Open a PR against `main`.

## Governance

Repository creation and settings are managed by
[`melodic-software/github-iac`](https://github.com/melodic-software/github-iac).
