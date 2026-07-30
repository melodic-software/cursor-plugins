# Migration playbook (Claude → Cursor)

This repo is the **Cursor-native** Melodic marketplace. It is intentionally
separate from
[`melodic-software/claude-code-plugins`](https://github.com/melodic-software/claude-code-plugins).

Do **not** dual-read Claude manifests at runtime. Do **not** regenerate
`.cursor-plugin/` from Claude plugins as a continuous export into the Claude
repo. Migrate and adapt here.

## Goals

1. One install surface for Cursor (this repo / Team Marketplace / local copies).
2. One install surface for Claude Code (`claude-code-plugins`).
3. Shared *ideas* (skill names, agent roles, workflows) where they still make
   sense under Cursor contracts.

## Source of inspiration

| Claude (SSOT for Claude) | Cursor (SSOT here) |
| --- | --- |
| `.claude-plugin/marketplace.json` | `.cursor-plugin/marketplace.json` |
| `plugins/*/.claude-plugin/plugin.json` | `plugins/*/.cursor-plugin/plugin.json` |
| Claude `hooks/hooks.json` | Cursor `hooks/hooks.json` (different event model) |
| Claude `.mcp.json` / plugin MCP | Cursor `mcp.json` + optional `variables` |
| Skills / agents / commands | Same folder names when Cursor discovery applies |

Official Cursor shapes: [OFFICIAL-DOCS.md](./OFFICIAL-DOCS.md).

## Per-plugin migrate checklist

For each Claude plugin you choose to port:

1. **Decide keep / reshape / drop.** Claude-only tooling (Claude hook events,
   Claude MCP tool names, Claude settings paths) may not belong here.
2. **Create** `plugins/<name>/.cursor-plugin/plugin.json` with Cursor fields only
   (`name`, `version`, `description`, `author`, `license`, `keywords`, optional
   component path overrides and `variables`).
3. **Port content** into Cursor discovery folders (`skills/`, `agents/`,
   `rules/`, `commands/`, `hooks/`, `mcp.json`) under that plugin directory.
4. **Adapt hooks.** Cursor hook events and payload contracts differ from Claude
   plugin hooks. Claude `hooks/hooks.json` is not Cursor's default. Prefer
   Cursor-native hooks, or document intentional third-party Claude settings
   hooks separately — never assume Claude plugin hooks auto-run in Cursor.
5. **Adapt MCP.** Use Cursor `mcp.json` (`mcpServers`) and declare secrets via
   plugin `variables` (dashboard **Plugins → Configure**), not committed values.
6. **Register** the plugin in root `.cursor-plugin/marketplace.json`
   (`metadata.pluginRoot` is `plugins`; entry `source` is the directory name).
7. **Verify locally** by copying into
   `%USERPROFILE%\.cursor\plugins\local\<name>\` (real copy — junctions outside
   that tree are rejected) and **Developer: Reload Window**.
8. **Document** Cursor-specific limits in the plugin README.

## Sync policy (how we stay related without dual-host)

- **Inspiration sync:** periodic review of Claude catalog for new/renamed
  skills — tracked as issues/PRs in *this* repo.
- **No automatic export** from Claude manifests into this tree.
- **No shared marketplace JSON** between hosts.
- Optional later: a *read-only* inventory script that diffs Claude plugin names
  vs Cursor plugin names and prints a gap report (never writes Claude SSOT).

## First wave (suggested)

Start with plugins whose value is mostly skills/agents/rules (low hook/MCP
coupling), e.g. planning, discovery, review, discipline, verification. Port
formatter hooks only after Cursor-native hook scripts exist.

## Out of scope here

- Changing `claude-code-plugins` to emit Cursor artifacts again.
- Team Marketplace admin import (Teams/Enterprise); Ultra alone uses local
  copies or other supported personal paths.
