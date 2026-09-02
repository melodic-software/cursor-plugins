---
name: design-automation
description: Design a Cursor Automation end to end — pick the lane (managed agent, native trigger, schedule, webhook, API/CLI, on-demand), settle repository scope, identity, tools, config bindings, and guardrails, write the prompt, and save a source-controlled record plus a UI paste checklist. Use when someone wants to automate a workflow with Cursor, asks which trigger to use, or has an automation prompt to write or rework. Reads every platform fact from live official docs.
---

# Design a Cursor Automation

Turn a goal into one lane with a spec, a prompt, a record in source control, and the
exact steps to paste it into the Automations UI. You are the interviewer: never fill a
gap with an assumption, and never state a platform fact you did not read this session.

## Official docs (fetch live first — mandatory)

1. Fetch https://cursor.com/docs/llms.txt. It is the live page index; use it to find any
   page this skill names, because pages move.
2. Fetch https://cursor.com/docs/automations and read *Triggers*, *Tools*, *Automation
   settings* (Repositories, Permissions, Identity), *Billing*, and *Writing prompts*.
3. Open `plugins/automations/reference/LANES.md`, pick the candidate lanes, and fetch the
   pages its catalog names for them (managed agents, integrations, API, CLI).
4. Fetch the plan gate on the **feature page** for anything gated (Jira, Team Rules,
   Team Owned scope, marketplaces, managed agents).
5. State the fetch date in your reply. If a page times out or returns 403/429, say it is
   unverified; do not fall back to memory.

Source policy and tiers: `plugins/automations/reference/DOC-SOURCES.md`. Docs win over
this skill, over training data, and over any blog.

## Discover before you ask

Read what the workspace already tells you, then ask only for the rest.

- Repository: `AGENTS.md` (root and nested), `.cursor/rules/`, `.cursor/skills/`,
  `.agents/skills/`, `.cursor/environment.json`, `.cursor/hooks.json`, `CODEOWNERS`,
  `.github/workflows/`, `.cursor/approval-policies/`, and any existing automation records
  (search for files whose frontmatter has `kind: automation-record`).
- Cloud session: if the Cursor Cloud MCP is present, call `run-info` and
  `environment-info` to learn the environment, repos, and egress policy in force.
- Capabilities: if a `/discover-capabilities` skill is installed, invoke it to learn the
  built-in skills, managed agents, integrations, and plugins available on this plan and
  surface. If it is not installed, read the *Built-in Cursor skills* table on
  https://cursor.com/docs/skills and the managed agents list on the Automations page
  yourself. Prefer composing what already exists over writing a new prompt.

## Interview

Use the ask-questions tool. Group questions; do not send one at a time. Every answer
lands in the decision record. Minimum set, skipping anything discovery already answered:

1. **Goal and done.** What outcome, in one sentence, and what "nothing to do" looks like.
2. **Plan and role.** Individual (Pro/Ultra), Teams member, Teams/Enterprise admin. Gates
   everything below.
3. **Trigger source.** Which system sees the event first, which provider (GitHub, GitLab,
   Bitbucket, Slack, Linear, Jira, Sentry, PagerDuty, your own), and how fast the reaction
   must be. Latency tolerance decides schedule vs webhook.
4. **Repository scope.** None, one repository, or an existing multi-repo environment.
   Which repositories, which base branch.
5. **Identity and permission scope.** Private, Team Visible, or Team Owned; whether a PR
   or comment may appear under a personal account.
6. **Tools.** Which actions the run may take (PR creation, PR comments/approvals, reviewer
   requests, Slack send/read, MCP servers, Memories, computer use), taken from the *Tools*
   section as fetched. Default to the fewest.
7. **Config keys.** Every consumer-specific value the prompt needs (field ids, state
   names, rosters, prefixes) as a **named key**, and which binding channel the consumer
   will use (see *Config binding* in `LANES.md`).
8. **Quality bar.** When to open a PR, when to comment, when to do nothing.
9. **Output.** What artifact the world should see, in what format, where.
10. **Failure and idempotency.** What to do on partial state, on a re-fire, on missing
    config.
11. **Record location.** Where the consumer keeps automation records; do not assume a
    folder. Suggest `.cursor/automations/<name>/PROMPT.md` only if they have no convention.

## Choose the lane

Apply *Selection order* from `plugins/automations/reference/LANES.md` top-down and stop
at the first fit. A managed agent (Bugbot, Security Agents, PR Routing & Approval) that
covers the need ends the design; report its configuration page instead of a prompt. Write
the lane and the reason it beat the alternatives into the record.

## Design the spec

Fill every field of the record header (`assets/automation-record.md`). Read each value
from the fetched pages: trigger names exactly as the Automations page spells them, tool
names as listed, permission scope semantics as described. Note plan gates you confirmed
and the page you confirmed them on.

## Compose the prompt

Structure, in this order:

1. Role and goal (one paragraph).
2. Inputs the run can rely on: trigger payload, repository, config keys and where they are
   bound (env var name, rule name, MCP lookup).
3. Procedure as numbered steps, each verifiable.
4. Decision rules: the do-nothing conditions first, then act conditions.
5. Guardrails from *Guardrails baked into every generated prompt* in `LANES.md`, adapted
   to the lane, never removed.
6. Idempotency rule: inspect current state first; update or stop if the outcome already
   exists.
7. Output contract: format, destination, and what to report when nothing was done.
8. Verification the run must perform before it acts (tests, artifacts, checks), and how
   to prove it (walkthrough artifacts when computer use applies).

Prefer built-in skills and managed agents inside the prompt ("run `/review-bugbot`",
"subscribe to the PR and keep it green") over re-describing their behavior.

## Outputs

Deliver all five, in this order:

1. **Record** — `assets/automation-record.md` filled in, written to the location the
   consumer chose. The prompt is the body; the header is the spec.
2. **Binding checklist** — each config key, its channel, who sets it, and the page that
   documents the channel.
3. **UI paste checklist** — the fields to fill in the Automations UI with labels copied
   from the fetched page, plus the record path to paste from and the `last-pasted` field
   to update afterwards.
4. **First-run verification plan** — how to trigger once safely, what to inspect
   (run page, events, outputs), and how to roll back.
5. **Gaps** — anything unverified (timed-out pages, staff statements relied on,
   undocumented behavior), each with the page or thread to re-check.

## Do not

- Copy a trigger list, tool list, or plan table into the record or the reply as fact
  without having fetched it this session.
- Bake a consumer-specific literal (field id, state name, team name) into the prompt when
  a named key and a binding channel exist.
- Recommend a webhook or multi-trigger chain when a schedule meets the latency need.
- Recommend Team Owned scope without the consumer confirming an admin will own it.
- Recommend auto-approval, merging, or force-pushing.
- Promise that the UI will stay in sync with the record; there is no API. Say so.
