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

- Shell: prefer `shellcheck scripts/sync-local.sh` **whenever the tool is available**.
  `bash -n` only *parses* — it exited clean over a path traversal, a silently swallowed
  failure, and a GNU-only `find` builtin that all had to be found and fixed by hand.
  `shellcheck` catches that class. It is packaged for Debian/Ubuntu, so if it is missing
  install it (`sudo apt-get install -y shellcheck`) when the network allows. Do **not**
  assume it is preinstalled: probe with `command -v shellcheck` first.
  Only if it can be neither found nor installed, fall back to
  `bash -n scripts/sync-local.sh` as the floor — a syntax check, not a lint.
  The default rule set must stay at zero findings; a repo-root `.shellcheckrc`, if
  present, records which *optional* checks were considered and deliberately declined.
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

### Doc conventions

- **How to cite a repo path in Markdown.** In human-facing files — `README.md`,
  `docs/*.md`, `plugins/*/README.md`, `plugins/*/reference/*.md` — cite a repo file as a
  **resolvable relative link** — from `plugins/plugin-ops/README.md` that is
  `[docs/PLUGIN-PHILOSOPHY.md]` followed by `(../../docs/PLUGIN-PHILOSOPHY.md)` — so it
  renders as a working link on GitHub. Inside a `SKILL.md` **body** the reader is an
  agent with the repo checked out, so a bare repo-root-relative code span —
  `docs/PLUGIN-PHILOSOPHY.md` — is the convention, the same one this file uses. Pick the
  style from the file's kind and do not mix the two within one file.
- Doc dates (`Verified` columns in `docs/OFFICIAL-DOCS.md` and
  `docs/PLUGIN-PHILOSOPHY.md`) mean "a live fetch of that URL still matched this row on
  that date". Never bump one without fetching. A 403/429 is a blocked fetch, not a
  verification and not a dead link — record it as blocked and leave the old date.

### Non-obvious caveats

- The PowerShell twin `scripts/sync-local.ps1` requires `pwsh` (PowerShell), which is
  **not** installed in the base image. On Linux use the `.sh` variant; only the `.ps1`
  path needs PowerShell.
- The two scripts are twins in behavior but **not** in argument-error reporting: bash
  parses its own flags (exit 2, `Missing value for --ref` / `Unknown flag: <flag>`), while
  PowerShell's parameter binder rejects bad arguments before the script body runs (exit 1,
  its own message text). Shared failures — bad source, no plugins resolved, filter
  excludes the only plugin — do exit 1 on both. See
  `plugins/plugin-ops/skills/sync-local/SKILL.md`.
