---
name: verify-plugin
description: Validate a Cursor plugin or marketplace checkout against live official Cursor plugin reference docs (manifests, discovery paths, frontmatter), then Melodic marketplace policy (skills-first; no new commands/).
---

# Verify Cursor plugin / marketplace layout

## Official docs (fetch live first — mandatory)

1. https://cursor.com/docs/reference/plugins — manifests, discovery, marketplace.json, variables, submission checklist
2. https://cursor.com/docs/plugins — high-level structure / local test
3. The published JSON Schemas — machine-checkable, and stricter than the prose tables. Validate the actual files against them (ajv or equivalent), do not just eyeball the docs:
   - https://raw.githubusercontent.com/cursor/plugins/main/schemas/marketplace.schema.json
   - https://raw.githubusercontent.com/cursor/plugins/main/schemas/plugin.schema.json
4. Related pages from `plugins/plugin-ops/reference/DOC-SOURCES.md` if hooks/MCP/rules/skills are present
5. Melodic policy pointers (not Cursor requirements):
   - `docs/PLUGIN-PHILOSOPHY.md`
   - `docs/MIGRATION-PLAYBOOK.md`

Build the Cursor checklist from **fetched** docs, not from memory.

## Inputs

- Path to a plugin directory or marketplace repo (default: workspace root).

## Steps

1. Fetch reference docs; extract current required/optional fields and discovery rules.
2. Detect mode (the reference page's **Supported plugin formats** table lists two manifest locations — check for both):
   - Marketplace: `.cursor-plugin/marketplace.json`
   - Cursor Plugin: `.cursor-plugin/plugin.json` (full component set)
   - Agent Plugin (open standard): `plugin.json` at the plugin root (skills + MCP only)
3. Validate against live docs **and the fetched schemas**, at minimum:
   - `name` matches the published pattern `^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$` — lowercase, hyphens **and periods** allowed, must start and end with an alphanumeric. "kebab-case" alone is a loose paraphrase; check the pattern.
   - paths relative (no `..`, no absolute)
   - marketplace entries resolve to dirs with `plugin.json`
   - **Prose vs schema is a TWO-WAY check.** The reference page's field tables and the published schemas diverge in *both* directions. Walk every prose table row against the schema and every schema constraint back against the prose, and report each divergence with its direction. The schema is what a validator enforces, so report the schema result as the verdict and the prose gap as a documentation finding — never the reverse. Known divergences, both confirmed against the live schema:
     - *Prose **looser** than schema — marketplace `plugins[]` entries are a closed set.* `marketplace.schema.json` sets `"additionalProperties": false`, permits only `name`, `source`, `description`, `minClientVersions`, and requires `["name", "source"]`. The reference page's *Plugin entry fields* table additionally lists `version`, `author`, `homepage`, `repository`, `license`, `keywords`, `logo`, `category`, `tags`, component paths, `hooks`, `mcpServers` and `variables`, and marks only `name` as required. Any extra key **fails** validation; a missing `source` also fails despite the prose not marking it required.
     - *Prose **stricter** than schema — `owner`.* The reference page's *Marketplace manifest fields* table marks `owner` **(required)**, but `marketplace.schema.json` has `"required": ["name", "plugins"]`, so a marketplace with no `owner` validates. Report this as a prose/schema divergence (and note that submission review may still expect `owner`); do **not** report a missing `owner` as a schema failure.
     - `plugin.json` is also `"additionalProperties": false` — any field not in the schema fails, including ones the prose implies.
   - `category` and `tags` are declared in `plugin.schema.json`, so the **plugin** manifest is where they validate. Per the reference page's *How resolution works*, the per-plugin manifest is merged into the marketplace entry (manifest values take precedence), so nothing is lost by keeping them there.
   - skills/rules/agents/commands frontmatter if those files exist (skills: `name` + `description` required, `name` must match the parent folder)
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
