# capabilities

Answer "what can this Cursor session already do, and which of it should I use?" from live
official docs and the local machine — built-in skills, agent tools and modes,
Cursor-managed agents, integrations, installed plugins and skills, MCP servers — for the
surface (IDE, CLI, cloud agent, automation) and plan in use.

The plugin holds pointers and procedure, never a copied list. Sources and read order:
[`reference/DOC-SOURCES.md`](reference/DOC-SOURCES.md). Melodic policy (skills primary;
no `commands/`): [`docs/PLUGIN-PHILOSOPHY.md`](../../docs/PLUGIN-PHILOSOPHY.md).

## Skills

| Skill | Purpose |
| --- | --- |
| `/discover-capabilities` | Inventory what exists here, what each item is for, and recommend native capabilities or a composition before writing a new prompt; refactor long prompts onto existing skills |

Invoke via Agent chat `/discover-capabilities`. Other plugins may invoke it by name when
present and must work without it; this plugin imports nothing from them.

## Why a skill and not a committed cheat sheet

Cursor's built-in skills, tools, and plan gates change without notice, and there is no
CLI command that lists the built-ins — the Skills page is the only authority. A committed
list would be stale on the day it merged. The skill reads the page, inspects the machine,
and reports with a verified date; it writes an inventory to disk only when asked, and
labels it a snapshot.

## Boundaries

- Reports availability only with a page or a local observation as evidence; items found on
  the machine but missing from the docs are labeled *observed, not documented*.
- Designing automations from what is discovered belongs to the `automations` plugin.
- Later concerns, deliberately not in this version: ranking or deprecating rows in the
  source index, and any generated human-readable inventory page.
