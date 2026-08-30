# Migration playbook (Claude → Cursor)

This repo is the **Cursor-native** Melodic marketplace. It is intentionally
separate from
[`melodic-software/claude-code-plugins`](https://github.com/melodic-software/claude-code-plugins).

Design policy SSOT: [PLUGIN-PHILOSOPHY.md](PLUGIN-PHILOSOPHY.md).  
Official URL pointers: [OFFICIAL-DOCS.md](OFFICIAL-DOCS.md) (fetch live).

Do **not** dual-read Claude manifests at runtime. Do **not** regenerate
`.cursor-plugin/` from Claude plugins as a continuous export into the Claude
repo. Migrate and adapt here.

## Goals

1. One install surface for Cursor (this repo / Team Marketplace / local copies).
2. One install surface for Claude Code (`claude-code-plugins`).
3. Shared *ideas* (skill names, agent roles, workflows) where they still make
   sense under Cursor contracts and Melodic component stances.

## Source of inspiration

| Claude (SSOT for Claude) | Cursor (SSOT here) |
| --- | --- |
| `.claude-plugin/marketplace.json` | `.cursor-plugin/marketplace.json` |
| `plugins/*/.claude-plugin/plugin.json` | `plugins/*/.cursor-plugin/plugin.json` |
| Claude `hooks/hooks.json` | Cursor `hooks/hooks.json` (different event model) |
| Claude `.mcp.json` / plugin MCP | Cursor `mcp.json` + optional `variables` |
| Claude `skills/` (and legacy `commands/`) | Cursor `skills/` only for new ports (see philosophy) |
| Claude `userConfig` | Cursor plugin `variables` + dashboard Configure |

## Mandatory pre-port review (keep / reshape / drop)

For **every** Claude component before copying files, decide using live Cursor
docs + [PLUGIN-PHILOSOPHY.md](PLUGIN-PHILOSOPHY.md) stances:

| Claude surface | Default decision | Notes |
| --- | --- | --- |
| Skill (`skills/<name>/SKILL.md`) | **Keep** (adapt frontmatter/paths) | Primary Cursor surface. Rewrite Claude-only tool/path assumptions. |
| Flat `commands/*.md` | **Reshape → skill** | Do not port as `commands/`. Prefer skill; use `disable-model-invocation: true` if explicit-only slash UX is required. |
| Rules / CLAUDE.md-style guidance | **Reshape →** Cursor `.mdc` rules or skill | Short constraints → rules; procedures → skills. |
| Agents | **Keep or reshape** | Port only if a distinct agent role remains load-bearing under Cursor agent format. |
| Hooks | **Reshape or drop** | Event names and payloads differ. Prefer Cursor-native hooks; third-party Claude settings hooks are a separate, documented choice — never assume Claude plugin hooks auto-run. |
| MCP | **Reshape** | Cursor `mcp.json` + `variables`; no committed secrets. Triggers trust review below. |
| Claude `userConfig` / settings `agent` / workflows / channels / LSP plugin slots / monitors / themes | **Drop** (or map only after live-doc proof of Cursor equivalent) | Leave in Claude SSOT unless mapped. |
| Sibling-plugin imports / Claude cache paths | **Drop** | Violates design boundary. |

Record the decision in the PR description (one line per non-trivial reshape/drop).

## Per-plugin migrate checklist

For each Claude plugin you choose to port:

1. **Run the pre-port review** (table above). Reject ports that would add
   discouraged `commands/` or Claude-only surfaces without a map.
2. **Create** `plugins/<name>/.cursor-plugin/plugin.json` with Cursor fields only
   (`name`, `version`, `description`, `author`, `license`, `keywords`, `category`,
   `tags`, optional component path overrides and `variables`). `category` and `tags`
   belong **here**, not on the marketplace entry: `plugin.schema.json` declares both,
   while `marketplace.schema.json` sets `"additionalProperties": false` on a plugin
   entry.
3. **Port content skills-first** into Cursor discovery folders under that plugin
   (`skills/`, and only as needed `agents/`, `rules/`, `hooks/`, `mcp.json`).
   Do **not** create `commands/` for new ports.
4. **Adapt hooks** against live [hooks](https://cursor.com/docs/hooks) /
   [third-party hooks](https://cursor.com/docs/reference/third-party-hooks) docs.
5. **Adapt MCP** to Cursor `mcp.json` (`mcpServers`) and declare secrets via
   plugin `variables` (dashboard **Plugins → Configure**).
6. **Register** the plugin in root `.cursor-plugin/marketplace.json`
   (`metadata.pluginRoot` is `plugins`; entry `source` is the directory name). A
   schema-valid entry carries only `name`, `source`, `description`, and optional
   `minClientVersions` — narrower than the "Plugin entry fields" table in the plugins
   reference, so validate against `marketplace.schema.json`, not the prose table.
7. **Acceptance gates** (all required before merge):
   - Component-stance check against [PLUGIN-PHILOSOPHY.md](PLUGIN-PHILOSOPHY.md)
   - Live verify via `verify-plugin` skill (Cursor checklist + Melodic policy)
   - Local sync into `~/.cursor/plugins/local/<name>/` (real copy) and
     **Developer: Reload Window**
   - Plugin README documents Cursor-specific limits and install path
8. **Trust review** if the plugin ships MCP and/or hooks (next section).

## Trust review (MCP / hooks)

Triggered when a port or version bump adds MCP servers or hooks.

1. Fetch live [MCP](https://cursor.com/docs/mcp) and [hooks](https://cursor.com/docs/hooks) docs.
2. Confirm: no committed secrets; `variables` cover every `${VAR}`; egress and
   trust delegation are explicit in the plugin README.
3. Confirm hook scripts are reviewed (no unexpected network/`eval`), and event
   matchers are as narrow as practical.
4. PR records **ACCEPT** (or blockers) in one short paragraph — not a Claude-style
   multi-page security dossier unless the surface warrants it.

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
- Cloning Claude’s full security-review record format or naming grammar.
- Treating Claude “commands prohibited” as Cursor platform law (see philosophy).
