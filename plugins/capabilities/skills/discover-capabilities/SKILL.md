---
name: discover-capabilities
description: Inventory what this Cursor session can already do — built-in skills, agent tools and modes, Cursor-managed agents, installed plugins and skills, MCP servers, integrations — for the current surface (IDE, CLI, cloud agent, automation) and plan, and recommend native capabilities or a composition of them before anyone writes a new prompt. Use when someone asks "what do I have available", "is there a built-in for this", or wants a long prompt refactored onto existing skills. Reads live official docs and the local machine; never a cached list.
---

# Discover capabilities

Answer three questions with evidence: **what exists here**, **what each thing is for**,
and **which one to use for a given goal**. Native first, composition second, a new prompt
last.

## Official docs (fetch live first — mandatory)

1. Fetch https://cursor.com/docs/llms.txt and use it to resolve every page below.
2. Fetch https://cursor.com/docs/skills — read *Built-in Cursor skills* (the only
   authoritative list of built-ins; there is no CLI command that lists them) and *Skill
   directories* (which directories load on which surface).
3. Fetch https://cursor.com/docs/agent/overview for agent tools and
   https://cursor.com/docs/cli/reference/slash-commands when the surface is the CLI.
4. If the question touches cloud or automation: fetch
   https://cursor.com/docs/cloud-agent/capabilities (Cursor Cloud MCP tools, subscriptions)
   and https://cursor.com/docs/automations (managed agents, automation tools).
5. If plugins or marketplaces matter: fetch https://cursor.com/docs/plugins.
6. For any plan gate, fetch the **feature page** that states it; do not infer from a
   pricing table.
7. Skim https://cursor.com/changelog for capabilities newer than the docs.
8. State the fetch date. Anything that timed out or returned 403/429 is unverified; say so.

Index, tiers, and expansion rule: `plugins/capabilities/reference/DOC-SOURCES.md`.

## Establish surface and plan

Detect what you can; ask for the rest with the ask-questions tool.

- **Surface**: cloud agent (a `cursor-cloud` MCP or `CURSOR_AGENT_SOCKET` is present; call
  `run-info` if available), CLI, IDE, or an automation run (`agent/source` in metadata).
- **Plan and role**: individual (Pro/Ultra), Teams member, Teams/Enterprise admin. Read
  gates on feature pages as fetched.

## Enumerate what is installed

Look, do not assume. Report each location you checked, including empty ones.

| Source | Where to look |
| --- | --- |
| Repository skills | `.cursor/skills/`, `.agents/skills/`, `.claude/skills/` (compatibility) — recursively, any `SKILL.md`; nested project directories too |
| Repository context | `AGENTS.md` (root and nested), `.cursor/rules/*.mdc`, `.cursor/hooks.json`, `.cursor/mcp.json`, `.cursor/environment.json` |
| User skills (local machine only) | `~/.cursor/skills/`, `~/.agents/skills/`, `~/.claude/skills/` |
| Local plugins (local machine only) | `~/.cursor/plugins/local/*` — read each `.cursor-plugin/plugin.json` or root `plugin.json` |
| Marketplaces and installed plugins (CLI) | `agent plugin marketplace list --format json`; `/plugin` interactively |
| MCP servers | `/mcp list` (CLI); the tool catalog visible to you in this session; `.cursor/mcp.json` |
| Cloud-VM built-ins | `~/.cursor/skills-cursor/*/SKILL.md` (read their frontmatter; note any that the Skills page does not list) |
| IDE-only | The Customize page (Rules, Skills, Plugins, MCP by scope) — ask the user to report it when you cannot open it |

## Classify

For every capability found or documented, record:

- **Source**: built-in skill · agent tool · mode · managed agent · integration · plugin
  (which marketplace) · repository skill · user skill · MCP server · automation tool.
- **Surface availability**: IDE / CLI / cloud / automation, taken from the page that says
  so (Skills page for skill directories; Capabilities page for cloud-only; Automations
  page for automation tools).
- **Plan gate**: as stated on the feature page, or "not stated".
- **For**: one line, taken from the capability's own `description` or its doc row. Do not
  paraphrase a purpose you did not read.
- **Evidence**: the URL or path you read it from, and the date.

Flag anything present on the machine but absent from the docs as *observed, not
documented*, and anything in the docs but absent from the machine as *documented, not
present here*.

## Recommend

When the user has a goal:

1. Name the single native capability that covers it, if one does (a built-in skill, a
   managed agent, an integration option, a subscription).
2. Otherwise propose a **composition**: which existing capabilities, in what order, with
   the one-line reason each is there.
3. Only then propose a new prompt or skill, and say what it adds that nothing existing
   does.

When the user hands you a long prompt to refactor: map each paragraph to an existing
capability or to "no equivalent", then rewrite the prompt as invocations of what exists
plus the residue. Show the mapping.

## Report

- Grouped tables (built-in, managed agents, integrations, plugins, repository, user,
  MCP), each row with Source · For · Surface · Plan gate · Evidence.
- Locations checked, including empty ones.
- One line: `Verified <date>; unverified: <pages that timed out or were refused>`.
- Do not write the inventory to disk unless asked. When asked, write it where the user
  says, with the verified date in its header, and remind them it is a snapshot that will
  drift.

## Do not

- Produce a built-in skills list from memory. Fetch the table.
- Mark something available on a surface without the page or a local observation that says
  so.
- Present a third-party claim as availability.
- Recommend writing a prompt for something a built-in or managed agent already does.
