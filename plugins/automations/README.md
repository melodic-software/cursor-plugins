# automations

Design Cursor Automations one **lane** at a time — trigger source, runtime, outputs — and
keep the prompt in source control while the platform has no config-as-code.

Skills **fetch official Cursor docs live** before stating any platform fact; the plugin
holds pointers and procedure, never copied documentation. Sources and their read order:
[`reference/DOC-SOURCES.md`](reference/DOC-SOURCES.md). Lane model, selection order, and
the cross-cutting seams (plan gates, repository scope, identity, config binding,
concurrency, guardrails): [`reference/LANES.md`](reference/LANES.md).

Melodic policy (skills primary; no `commands/`):
[`docs/PLUGIN-PHILOSOPHY.md`](../../docs/PLUGIN-PHILOSOPHY.md).

## Skills

| Skill | Purpose |
| --- | --- |
| `/design-automation` | Interview → lane → spec → prompt → source-controlled record → UI paste checklist → first-run plan |

Invoke via Agent chat `/design-automation`. The skill uses `/discover-capabilities` from
the `capabilities` plugin when it is installed, and falls back to reading the built-in
skills table on the live Skills page when it is not; neither plugin imports the other.

## What the record is

[`automation-record.md`](skills/design-automation/assets/automation-record.md) is the
template every designed automation is written into: a YAML header that is the spec (lane, triggers, scope,
identity, tools, config keys and their bindings, plan gates confirmed, docs date, last
pasted) and a Markdown body that is the prompt. The repository copy is the source of
truth; the Automations UI holds a paste of it. Where a consumer keeps records is their
choice; the skill asks and never assumes.

## Boundaries

- Consumer-specific values (work-tracking field ids, workflow state names, rosters) are
  named keys in the prompt and bound by the consumer through a channel their plan offers.
  They never appear in this repository.
- Nothing here depends on marketplace plugins loading inside cloud runs; that behavior is
  undocumented.
- Later concerns, deliberately not in this version: auditing an existing automation
  against live docs, designing cloud environments, and ranking or deprecating rows in the
  source index.
