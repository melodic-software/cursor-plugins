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
docs/MIGRATION-PLAYBOOK.md        # Claude → Cursor migrate/adapt process
docs/OFFICIAL-DOCS.md             # Cursor official doc jump sheet
```

## Local install / update (personal)

Personal `/add-plugin` GitHub marketplaces often stick on a stale commit. The
reliable personal path is real copies under `~/.cursor/plugins/local/`
(junctions whose target is outside `local` are rejected).

From this repo (recommended):

```powershell
pwsh -File scripts/sync-local.ps1
```

```bash
bash scripts/sync-local.sh
```

Then **Developer: Reload Window**. After `local-sync` is installed once, you can
also run **`/sync-local`** in Cursor.

Optional: `/add-plugin https://github.com/melodic-software/cursor-plugins` for a
personal marketplace catalog (updates are flaky today). Team Marketplace Auto
Refresh is documented for org admins under Dashboard → Plugins.

## Contributing

1. Follow [docs/OFFICIAL-DOCS.md](docs/OFFICIAL-DOCS.md) for manifest shapes.
2. Port work from the Claude catalog via
   [docs/MIGRATION-PLAYBOOK.md](docs/MIGRATION-PLAYBOOK.md).
3. Open a PR against `main` (org ruleset requires pull requests).

## Governance

Repository creation and settings are managed by
[`melodic-software/github-iac`](https://github.com/melodic-software/github-iac).
