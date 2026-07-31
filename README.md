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

## Local install (personal)

Ultra / personal plans do not get Team Marketplace GitHub import. To try a
plugin locally:

1. Copy `plugins/<name>/` to `%USERPROFILE%\.cursor\plugins\local\<name>\`
   (real directory copy — junctions whose target is outside `local` are rejected).
2. **Developer: Reload Window**.
3. Confirm the plugin appears under Cursor Plugins.

Team Marketplace import (when available on your plan): add this GitHub repo as a
marketplace per [Cursor plugins docs](https://cursor.com/docs/plugins).

## Contributing

1. Follow [docs/OFFICIAL-DOCS.md](docs/OFFICIAL-DOCS.md) for manifest shapes.
2. Port work from the Claude catalog via
   [docs/MIGRATION-PLAYBOOK.md](docs/MIGRATION-PLAYBOOK.md).
3. Open a PR against `main` (org ruleset requires pull requests).

## Governance

Repository creation and settings are managed by
[`melodic-software/github-iac`](https://github.com/melodic-software/github-iac).
