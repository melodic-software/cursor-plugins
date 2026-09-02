# Plugin philosophy (Cursor)

Durable design policy for plugins in this marketplace. The
[migration playbook](MIGRATION-PLAYBOOK.md) applies it when porting from
[`claude-code-plugins`](https://github.com/melodic-software/claude-code-plugins).
Official URL pointers live in [OFFICIAL-DOCS.md](OFFICIAL-DOCS.md) — **fetch live;
never treat this file as a procedure cache.**

## Design boundary

A plugin is a reusable, independently useful vertical slice of one cohesive
capability. It must work outside the repository and organization that produced
it. Publisher metadata may identify its source; runtime behavior must not depend
on publisher names, organization-specific environment variables, repository
names, absolute machine paths, or an undocumented consumer layout.

Keep plugins horizontally decoupled:

- A plugin owns its skills, rules, agents, hooks, MCP config, scripts, and state.
- It never imports files from a sibling plugin or discovers another plugin's
  install directory.
- Cooperation uses a documented public seam (explicit invocation, documented
  artifact contract, or presence-gated optional collaboration with a fallback).
- Every plugin remains useful alone.

This repo is the **Cursor-only** SSOT. Do not dual-read Claude manifests at
runtime. Do not auto-export Cursor artifacts into `claude-code-plugins`.

## Mandatory live-doc fetch

Before advising on install, update, marketplace layout, component format, or
changing a stance row below:

1. Fetch the relevant pages from [OFFICIAL-DOCS.md](OFFICIAL-DOCS.md) /
   [`plugins/plugin-ops/reference/DOC-SOURCES.md`](../plugins/plugin-ops/reference/DOC-SOURCES.md).
2. Prefer the fetched page over this file, training data, or prior chat memory.
3. If a fetch diverges from a stance row, update the row and its verified date.

`plugin-ops` skills encode this gate operationally.

## Claude Code vs Cursor (do not confuse hosts)

| Topic | Claude Code | Cursor (this marketplace) |
| --- | --- | --- |
| Skills | Primary; Agent Skills standard | Primary; Agent Skills standard |
| `commands/` | Merged into skills; use `skills/` for new plugins (legacy flat files still load) | Still a **documented** plugin component in the plugins reference; Melodic **discourages** new `commands/` and ships skills instead |
| Slash UX | Skill or legacy command → `/name` | Skills appear in `/skill-name` (attaches to one message). Keep a skill on for the session by using it as a Custom Mode (Option+Enter / Alt+Enter). Optional `disable-model-invocation: true` for explicit-only. There is no `@name` attach path in the live skills docs. |
| Migration helper | Host docs | Built-in `/migrate-to-skills` (Cursor 2.4+) for dynamic rules and user/workspace slash commands; rules with `alwaysApply: true` or `globs`, and user rules, are **not** migrated |
| Config scalars | Manifest `userConfig` | Plugin `variables` + dashboard **Plugins → Configure** |
| Hooks / MCP | Claude contracts | Cursor contracts — reshape; never assume Claude plugin hooks auto-run |
| Plugin format | Host-specific marketplace | This marketplace ships **Cursor Plugins** (`.cursor-plugin/plugin.json` + `.cursor-plugin/marketplace.json`). Cursor also loads the Agent Plugins open standard (root `plugin.json`, skills + MCP only). Stay on the Cursor format here: multi-plugin marketplaces, rules/agents/hooks/variables, and `plugin-ops` verification are Cursor-format seams. Accept a root `plugin.json` when verifying a foreign checkout; do not convert this catalog. |

Claude fleet policy that **prohibits** `commands/` is **not** Cursor law. Copy
ideas, not host-specific prohibitions, unless a live Cursor fetch says the same.

Cursor-side rows re-checked live 2026-09-02 against
[docs/skills](https://cursor.com/docs/skills) (*How skills work*, Custom Modes,
`disable-model-invocation`),
[docs/plugins](https://cursor.com/docs/plugins) (*Supported plugin formats*,
Agent Plugins vs Cursor Plugins), and
[reference/plugins](https://cursor.com/docs/reference/plugins) (*Commands format*,
*Cursor Plugin component discovery*, *Variables*). The Slash UX `@name` claim
was dropped — the skills page documents `/skill-name` (one message) and Custom
Mode (session), not `@name`.
[help/customization/skills](https://cursor.com/help/customization/skills) timed
out this session and is **not** re-dated. The Claude Code column is not
re-verified here — it is context, not policy.

## Component stances

> **Staleness disclaimer.** The platform changes constantly. Every row carries
> the date its facts were last verified by a **live fetch of the linked page** —
> not the date the row was last edited. A date here is never a substitute for
> re-fetching before you act on the row. If a fetch is blocked (403/429/timeout),
> the row keeps its older date and says so; a blocked fetch is not a verification.

| Component | Stance | Rationale and constraints | Verified |
| --- | --- | --- | --- |
| [Skills](https://cursor.com/docs/skills) | **Primary surface** | Default unit of capability. Folder `skills/<name>/SKILL.md` (+ optional `scripts/`, `references/`, `assets/`). Cursor walks the skills root recursively, so category subfolders are organizational only — identity comes from the folder holding `SKILL.md`. Use `paths` (`globs` is accepted only as a legacy fallback) / `disable-model-invocation` per live skills docs. Invoke with `/skill-name` (one message) or as a Custom Mode for the session. | 2026-09-02 |
| [`commands/`](https://cursor.com/docs/reference/plugins) | **Discouraged** | Cursor still discovers command markdown under `commands/`. Melodic policy: do not add new command files; put the procedure in a skill. Thin slash stubs that only say “follow the skill” are prohibited. Exception requires a one-line README note + philosophy re-fetch that still needs a separate command. | 2026-09-02 |
| [Rules](https://cursor.com/docs/rules) | Adopt on need | Short persistent guidance (`.mdc`). Prefer skills for multi-step procedures. | 2026-08-30 |
| [Agents](https://cursor.com/docs/reference/plugins) | Adopt on need | Custom agent markdown under `agents/` when a distinct agent role is load-bearing. | 2026-09-02 |
| [Hooks](https://cursor.com/docs/hooks) | Adopt on need | Cursor event model ≠ Claude; plugin hooks live at `hooks/hooks.json`. See also [third-party / Claude Code hooks](https://cursor.com/docs/reference/third-party-hooks). | 2026-08-30 |
| [MCP](https://cursor.com/docs/mcp) | Adopt on need | `mcp.json` + `variables` for secrets (dashboard Configure). Clears trust review in the migration playbook. | 2026-08-30 |
| Claude-only surfaces (workflows, channels, LSP plugin slots, Claude `userConfig`, Claude settings `agent`, etc.) — checked against [Cursor Plugin component discovery](https://cursor.com/docs/reference/plugins) | **Drop or map** | No silent port. Cursor's discovery table still admits exactly six component types (`skills/`, `rules/`, `agents/`, `commands/`, `hooks/hooks.json`, `mcp.json`, plus a root `SKILL.md` single-skill form); none of the Claude-only surfaces above appear anywhere in the Cursor plugin docs. Map only when a Cursor-native equivalent exists after a live-doc check; otherwise leave in Claude SSOT. | 2026-09-02 |

## Decision matrix: rules vs skills vs commands

| Need | Prefer | Avoid |
| --- | --- | --- |
| Short always-on or file-scoped coding constraint | **Rule** (`.mdc`, `alwaysApply` / `globs` / description) | Long procedure dumped into a rule |
| Multi-step workflow, checklists, scripts, progressive refs | **Skill** | Duplicating the same text as a rule and a skill |
| Explicit-only slash invoke (no auto agent pick-up) | **Skill** with `disable-model-invocation: true` | New `commands/` file |
| Thin “run the skill” slash alias | **Nothing extra** — skill already registers `/skill-name` | `commands/<name>.md` stub |

Pointers (fetch live): [Skills](https://cursor.com/docs/skills),
[Rules](https://cursor.com/docs/rules),
[Plugins reference](https://cursor.com/docs/reference/plugins),
[Plugins overview](https://cursor.com/docs/plugins).

Skills and plugins/reference rows re-checked live 2026-09-02; the rules page
was not re-fetched this session (leave its 2026-08-30 date). Supporting facts
from the pages that *were* fetched: `disable-model-invocation: true` makes a
skill behave "like a traditional slash command"; a skill already registers
`/skill-name` (one message) or Custom Mode (session), so a `commands/` alias
adds nothing. Migrating an existing `commands/` layer is a one-shot job for
Cursor's built-in `/migrate-to-skills` (2.4+) — see the Migration helper row
above for what it does **not** convert.

## Configuration ownership

| Concern | Owner and mechanism |
| --- | --- |
| Invocation-specific choice | Explicit skill argument / chat clarification |
| Personal or admin scalar / secret | Plugin manifest `variables` → dashboard **Plugins → Configure** (`${VAR}` in `mcp.json`) |
| Tracked repo convention | Documented consumer-project file or rule |
| Bundled plugin assets | Paths relative to the plugin root (no absolute machine paths) |

Never commit secret values into the plugin tree.

## Native-first

Prefer Cursor-native mechanisms (skills, rules, hooks, MCP, Team Marketplace,
local `~/.cursor/plugins/local`) over custom distribution hacks. Adopt a native
surface only when it fills a real gap, is stable enough for fleet use after a
live-doc check, and meets Melodic standards. Retire custom channels when a
native one matures.

## Related

- [MIGRATION-PLAYBOOK.md](MIGRATION-PLAYBOOK.md) — port gates and acceptance
- [OFFICIAL-DOCS.md](OFFICIAL-DOCS.md) — URL jump sheet
- [`plugin-ops`](../plugins/plugin-ops/README.md) — install / update / sync / verify skills
