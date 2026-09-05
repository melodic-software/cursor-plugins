# AGENTS.md

## Cursor Cloud specific instructions

This repository is a **Cursor plugin marketplace** (not a compiled application). It
contains Markdown docs, JSON manifests (`.cursor-plugin/marketplace.json`,
`plugins/<name>/.cursor-plugin/plugin.json`), plugin skills (`skills/<name>/SKILL.md`),
and the `scripts/sync-local.*` sync tooling. See `README.md` and
`docs/PLUGIN-PHILOSOPHY.md` for the full model.

### Environment / dependencies

- There is **no package manager and no application build**. Runtime tools the
  repo's own scripts need (`bash`, `git`, `python3`, `jq`) are already in the
  Cloud Agent base image.
- Checking-toolchain provisioning for Cloud Agent **Builds** is
  [`.cursor/install.sh`](.cursor/install.sh), invoked by
  [`.cursor/environment.json`](.cursor/environment.json) (`install` only; no
  `start` — this repo has no long-running service). Official contract:
  [Cloud Environment Setup](https://cursor.com/docs/cloud-agent/setup) and
  [Builds](https://cursor.com/docs/cloud-agent/builds). The script is
  idempotent and installs `shellcheck`, optional PowerShell +
  PSScriptAnalyzer (a PowerShell failure is tolerated — the `.sh` twin covers
  Linux), and `ajv`/`ajv-formats` into `./node_modules`.
- Just-in-time starts (no successful Build yet) still hit a stock base image.
  Probe with `command -v` and install what is missing; never assume the
  checking tools are present:

  | Tool | Needed for | If missing |
  | --- | --- | --- |
  | `shellcheck` | linting `scripts/*.sh` and `.cursor/install.sh` | `sudo apt-get install -y shellcheck` |
  | `pwsh` | running/testing `sync-local.ps1` | see the caveat below — the `.sh` twin covers Linux |
  | `PSScriptAnalyzer` | linting `sync-local.ps1` | `pwsh -c "Install-Module PSScriptAnalyzer -Scope CurrentUser -Force"` |
  | `node` + `ajv` | validating manifests and `.cursor/environment.json` against Cursor's schemas | `npm install ajv@8 ajv-formats` |

  Only `bash`, `git`, `python3` and `jq` are relied on at runtime; everything in that
  table is for checking the repo, not for using it.
- There **is** a test suite: `bash scripts/test-sync-local.sh`. See "Test" below.

### Lint / validate (there is no configured linter — use these proxies)

- Shell: prefer `shellcheck scripts/sync-local.sh .cursor/install.sh` **whenever
  the tool is available**.
  `bash -n` only *parses* — it exited clean over a path traversal, a silently swallowed
  failure, and a GNU-only `find` builtin that all had to be found and fixed by hand.
  `shellcheck` catches that class. It is packaged for Debian/Ubuntu, so if it is missing
  install it (`sudo apt-get install -y shellcheck`) when the network allows. Do **not**
  assume it is preinstalled: probe with `command -v shellcheck` first.
  Only if it can be neither found nor installed, fall back to
  `bash -n scripts/sync-local.sh .cursor/install.sh` as the floor — a syntax check, not a lint.
  The default rule set must stay at zero findings; a repo-root `.shellcheckrc`, if
  present, records which *optional* checks were considered and deliberately declined.
- JSON manifests: `jq empty .cursor-plugin/marketplace.json` and
  `jq empty plugins/*/.cursor-plugin/plugin.json`
- Skill frontmatter: each `plugins/*/skills/*/SKILL.md` must start with a `---` YAML block.
- PowerShell: `pwsh -c "Invoke-ScriptAnalyzer -Path ./scripts/sync-local.ps1"` must report
  **zero** findings. `sync-local.ps1` carries two file-level
  `SuppressMessageAttribute` entries, each with a written Justification; add
  `-SuppressedOnly` to see them. Do not add a suppression without one.
- Manifest **schemas**: `jq empty` only proves the JSON parses. Cursor publishes real
  schemas, and its prose reference disagrees with them **in both directions** — the prose
  lists plugin-entry fields the schema forbids, and marks `owner` required where the
  schema does not. The schema wins. CI fetches both and runs
  `node scripts/validate-manifests.mjs`; run it the same way locally. CI also
  fetches `https://cursor.com/schemas/environment.schema.json` and runs
  `node scripts/validate-environment.mjs` against `.cursor/environment.json`.

### Test

- `bash scripts/test-sync-local.sh` — the sync-local regression suite. Every case runs
  **both** twins against the same fixture and asserts the same exit code and
  byte-identical stdout, because a divergence between documented parity twins is itself a
  defect. It builds its fixtures under `$TMPDIR` and redirects `HOME` per case, so it
  never touches your real `~/.cursor`.
- `pwsh` is optional: without it the PowerShell half reports as skipped and the bash half
  still runs.
- Add a case whenever you fix a defect here. The suite already pins the ones that were
  found the hard way: path traversal via a plugin `name` and via an entry `source`, a
  `pluginRoot` that escapes the repo, an empty `plugins/` and `"plugins": []` (which used
  to exit 0 printing `Synced (0)`), a nameless marketplace entry (which used to dump a
  Python traceback), prefix-name sort order, a symlinked plugin directory (which must
  install as a **real** directory, not a link), implicit source (no path/URL), and
  local-git update (fast-forward a behind checkout, leave a dirty tree and a
  `--no-update` / `--dry-run` run behind, and update a submodule gitlink after
  fast-forward).

### Run (the "application")

- The core tool is `scripts/sync-local.sh`, which copies plugin(s) from a path or git URL
  into `~/.cursor/plugins/local/<name>/`. Usage is documented in `README.md` and
  `plugins/plugin-ops/skills/sync-local/SKILL.md`. Example:
  `bash scripts/sync-local.sh . plugin-ops` (sync this repo's `plugin-ops` plugin).
- `scripts/sync-local.sh` uses `python3` to parse `marketplace.json`; it is required for
 any source that has a `.cursor-plugin/marketplace.json`, including when specific plugin
 names are passed (the script resolves `metadata.pluginRoot` and each entry's `source`
 with `python3` either way).
- The other plugins are skills only, no scripts: `plugins/automations` (design an
 automation lane and write a source-controlled record) and `plugins/capabilities`
 (inventory what a session can already do). Exercising them means running the skill in an
 agent session; there is nothing to execute from a shell. Each keeps its own live-doc
 index at `plugins/<name>/reference/DOC-SOURCES.md`, tiered by authority and dated by
 live fetch under the same "Verified means fetched" rule as `docs/OFFICIAL-DOCS.md`.

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

### CI

`.github/workflows/ci.yml` runs the checks above on every push and pull request: shell
lint of `scripts/*.sh` **and** `.cursor/install.sh`, plus the regression suite,
PSScriptAnalyzer, JSON and schema validation of the manifests and
`.cursor/environment.json`, and internal markdown link integrity. It deliberately does
**not** check external URLs — GitHub and cursor.directory answer CI runners with
403/429, which would fail the build for reasons that say nothing about the repository.
Note that GitHub's runners preinstall `pwsh`, so CI exercises both twins even though a
just-in-time Cloud Agent box may not (`.cursor/install.sh` tries to add `pwsh` on
Builds; a failure there is tolerated).

The repo-root files synced from `melodic-software/standards` are not re-linted here; they
are validated upstream, and this repo must not hand-edit them.

### Non-obvious caveats

- The PowerShell twin `scripts/sync-local.ps1` requires `pwsh` (PowerShell), which is
  **not** in the stock base image. `.cursor/install.sh` attempts to install it during
  a Build and continues if that fails. On Linux use the `.sh` variant; only the `.ps1`
  path needs PowerShell.
- The two scripts are twins in behavior but **not** in argument-error reporting: bash
  parses its own flags (exit 2, `Missing value for --ref` / `Unknown flag: <flag>`), while
  PowerShell's parameter binder rejects bad arguments before the script body runs (exit 1,
  its own message text). Shared failures — bad source, no plugins resolved, filter
  excludes the only plugin — do exit 1 on both. See
  `plugins/plugin-ops/skills/sync-local/SKILL.md`.

## Pull requests

`ci-status` is the single required check. It fails on a title that is not
Conventional Commits (`build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`,
`refactor`, `revert`, `security`, `style`, `test`) and on a `do-not-merge`
label. Every body opens with a closing keyword and issue (`Closes #<issue>`,
`Fixes`, or `Resolves`, cross-repo as `Closes <owner>/<repo>#<issue>`) or with
the literal `No related issue: <reason>`, then carries a non-empty
`## Summary`, `## Fix`, `## Verification` and `## Related`. The linkage rule is
advisory: a body missing the keyword or a section gets a comment and the
`needs-issue-linkage` label, not a red check. Draft the body to
`.github/PULL_REQUEST_TEMPLATE.md` before opening the pull request.
