---
name: verify-plugin
description: Validate a Cursor plugin or marketplace checkout against live official Cursor plugin reference docs (manifests, discovery paths, frontmatter), then Melodic marketplace policy (skills-first; no new commands/).
---

# Verify Cursor plugin / marketplace layout

## Official docs (fetch live first — mandatory)

1. https://cursor.com/docs/reference/plugins — manifests, discovery, marketplace.json, variables, submission checklist
2. https://cursor.com/docs/plugins — high-level structure / local test
3. Related pages from `plugins/plugin-ops/reference/DOC-SOURCES.md` if hooks/MCP/rules/skills are present
4. Melodic policy pointers (not Cursor requirements):
   - `docs/PLUGIN-PHILOSOPHY.md`
   - `docs/MIGRATION-PLAYBOOK.md`

Build the Cursor checklist from **fetched** docs, not from memory.

## Inputs

- Path to a plugin directory or marketplace repo (default: workspace root).

## Steps

1. Fetch reference docs; extract current required/optional fields and discovery rules.
2. Detect mode:
   - Marketplace: `.cursor-plugin/marketplace.json`
   - Single plugin: `.cursor-plugin/plugin.json`
3. Validate against live docs, at minimum:
   - `name` kebab-case rules
   - paths relative (no `..`, no absolute)
   - marketplace entries resolve to dirs with `plugin.json`
   - skills/rules/agents/commands frontmatter if those files exist
   - `variables` vs `${VAR}` in `mcp.json` if MCP present
4. **Melodic marketplace policy** (label findings as **policy**, never as Cursor
   platform requirements):
   - Flag new or retained `commands/` without a documented exception in the
     plugin README (philosophy: skills primary; `commands/` discouraged).
   - Flag thin command stubs that only delegate to a skill.
   - Flag Claude-only surfaces ported without reshape (see migration playbook).
5. Report **pass / fail** with file paths; cite the doc section (Cursor) or
   philosophy/playbook section (policy).
6. Optional: suggest `sync-local` after fixes for local reload testing.

## Do not

- Invent Melodic-only gates as if they were Cursor requirements.
- Modify files unless the user asks to fix findings.
