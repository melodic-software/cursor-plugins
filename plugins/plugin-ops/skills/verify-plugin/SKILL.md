---
name: verify-plugin
description: Validate a Cursor plugin or marketplace checkout against live official Cursor plugin reference docs (manifests, discovery paths, frontmatter).
---

# Verify Cursor plugin / marketplace layout

## Official docs (fetch live first — mandatory)

1. https://cursor.com/docs/reference/plugins — manifests, discovery, marketplace.json, variables, submission checklist
2. https://cursor.com/docs/plugins — high-level structure / local test
3. Related pages from `plugins/plugin-ops/reference/DOC-SOURCES.md` if hooks/MCP/rules/skills are present

Build the checklist from **fetched** docs, not from memory.

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
4. Report **pass / fail** with file paths; cite the doc section you used.
5. Optional: suggest `sync-local` after fixes for local reload testing.

## Do not

- Invent Melodic-only gates as if they were Cursor requirements.
- Modify files unless the user asks to fix findings.
