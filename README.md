# cursor-plugins

Melodic Software — **Cursor** plugin marketplace: reusable, repo-agnostic skills,
agents, rules, hooks, and MCP servers under Cursor-native contracts.

This repository is intentionally separate from
[`claude-code-plugins`](https://github.com/melodic-software/claude-code-plugins)
(Claude Code marketplace). Ideas may be inspired by that catalog; manifests and
runtime behavior here are Cursor-only.

## Layout

```text
.cursor-plugin/marketplace.json   # marketplace catalog
plugins/<name>/
  .cursor-plugin/plugin.json      # per-plugin manifest
  skills/ | agents/ | rules/ | commands/ | hooks/ | mcp.json
scripts/sync-local.*              # sync any path/URL into ~/.cursor/plugins/local
docs/MIGRATION-PLAYBOOK.md
docs/OFFICIAL-DOCS.md             # jump sheet; plugin-ops fetches docs live
```

## Install / update (all plans)

Use **`plugin-ops`** (skills/commands fetch [Cursor docs](https://cursor.com/docs/plugins) live):

| Goal | Command |
| --- | --- |
| Add a marketplace the right way for your plan | `/install-marketplace` |
| Update after upstream changes | `/update-plugins` |
| Force disk copies (path or git URL) | `/sync-local` |

Script (works for **any** marketplace or single-plugin repo, not only Melodic):

```powershell
pwsh -File scripts/sync-local.ps1 -Source https://github.com/org/repo
pwsh -File scripts/sync-local.ps1 -Source . -Plugin hello,plugin-ops
```

```bash
bash scripts/sync-local.sh https://github.com/org/repo
bash scripts/sync-local.sh . hello plugin-ops
```

Then **Developer: Reload Window**.

Plan cheat-sheet (always re-check live docs):

- **Personal / Ultra:** `/add-plugin <url>` and/or `sync-local`
- **Teams/Enterprise admin:** Dashboard → Plugins → Team Marketplaces (Auto Refresh optional)
- **Org member:** install from Customize after admin import

## Contributing

1. Prefer live docs via [docs/OFFICIAL-DOCS.md](docs/OFFICIAL-DOCS.md) / `plugin-ops`.
2. Port Claude ideas via [docs/MIGRATION-PLAYBOOK.md](docs/MIGRATION-PLAYBOOK.md).
3. Open a PR against `main`.

## Governance

Repository creation and settings are managed by
[`melodic-software/github-iac`](https://github.com/melodic-software/github-iac).
