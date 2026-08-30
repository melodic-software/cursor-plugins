# AGENTS.md

## Cursor Cloud specific instructions

This repository is a **Cursor plugin marketplace** (not a compiled application). It
contains Markdown docs, JSON manifests (`.cursor-plugin/marketplace.json`,
`plugins/<name>/.cursor-plugin/plugin.json`), plugin skills (`skills/<name>/SKILL.md`),
and the `scripts/sync-local.*` sync tooling. See `README.md` and
`docs/PLUGIN-PHILOSOPHY.md` for the full model.

### Environment / dependencies

- There is **no package manager, build step, or test framework**. Nothing needs to be
  installed to work here — the required tools (`bash`, `git`, `python3`, `jq`) are all
  present in the base image, so the startup update script is a no-op.

### Lint / validate (there is no configured linter — use these proxies)

- Shell syntax: `bash -n scripts/sync-local.sh`
- JSON manifests: `jq empty .cursor-plugin/marketplace.json` and
  `jq empty plugins/*/.cursor-plugin/plugin.json`
- Skill frontmatter: each `plugins/*/skills/*/SKILL.md` must start with a `---` YAML block.

### Run (the "application")

- The core tool is `scripts/sync-local.sh`, which copies plugin(s) from a path or git URL
  into `~/.cursor/plugins/local/<name>/`. Usage is documented in `README.md` and
  `plugins/plugin-ops/skills/sync-local/SKILL.md`. Example:
  `bash scripts/sync-local.sh . plugin-ops` (sync this repo's `plugin-ops` plugin).
- `scripts/sync-local.sh` uses `python3` to parse `marketplace.json`; it is required for
  any source that has a `.cursor-plugin/marketplace.json`, including when specific plugin
  names are passed (the script resolves `metadata.pluginRoot` and each entry's `source`
  with `python3` either way).

### Non-obvious caveats

- The PowerShell twin `scripts/sync-local.ps1` requires `pwsh` (PowerShell), which is
  **not** installed in the base image. On Linux use the `.sh` variant; only the `.ps1`
  path needs PowerShell.
