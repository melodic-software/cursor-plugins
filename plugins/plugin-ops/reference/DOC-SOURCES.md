# Official Cursor doc sources (fetch live)

Skills in this plugin **must not** invent install/update UI steps from memory.
Before advising, fetch the current pages.

Repo jump sheet (same URLs + Melodic stance notes):
[`docs/OFFICIAL-DOCS.md`](../../../docs/OFFICIAL-DOCS.md).
Policy: [`docs/PLUGIN-PHILOSOPHY.md`](../../../docs/PLUGIN-PHILOSOPHY.md).

| Topic | URL |
| --- | --- |
| Plugins overview (marketplaces, Team, local test, install) | https://cursor.com/docs/plugins |
| Plugins reference (manifests, multi-plugin marketplaces, variables, commands format) | https://cursor.com/docs/reference/plugins |
| Hooks | https://cursor.com/docs/hooks |
| Third-party / Claude Code hooks | https://cursor.com/docs/reference/third-party-hooks |
| Rules | https://cursor.com/docs/rules |
| Skills | https://cursor.com/docs/skills |
| Skills (help) | https://cursor.com/help/customization/skills |
| MCP | https://cursor.com/docs/mcp |
| GitHub App (required by Team Auto Refresh; Auto Refresh itself is on the plugins page) | https://cursor.com/docs/integrations/github |
| Marketplace manifest JSON Schema (authority for entry fields) | https://raw.githubusercontent.com/cursor/plugins/main/schemas/marketplace.schema.json |
| Plugin manifest JSON Schema (authority for plugin fields) | https://raw.githubusercontent.com/cursor/plugins/main/schemas/plugin.schema.json |
| CLI slash commands (lists `/plugin [subcommand]` — "Manage plugins and marketplaces") | https://cursor.com/docs/cli/reference/slash-commands |
| CLI changelog (authority for `/plugin marketplace add <git-url>`, `--git-ref` pinning, `marketplace list/update/remove`, `--plugin-dir`) | https://cursor.com/docs/cli/changelog |
| Publish to Cursor Marketplace | https://cursor.com/marketplace/publish |
| Plugin template | https://github.com/cursor/plugin-template |
| Agent Skills open standard | https://agentskills.io |

Optional community index (not official): https://cursor.directory

When docs and this repo disagree, **docs win**. Note the fetch date in your reply.
Do not treat Claude Code “commands merged into skills” as Cursor platform law
without a live Cursor fetch that says the same — Melodic still prefers skills
(see philosophy).

## Fetch status, 2026-08-30

Every URL above was fetched this session and returned HTTP 200 — **except** these
two, which returned a transport-layer refusal through the agent proxy:

| URL | Result | How to read it |
| --- | --- | --- |
| https://github.com/cursor/plugin-template | HTTP 403 | Anti-automation / bot response. **Not** evidence the repository is gone or renamed. Unverified this session; open it in a browser before relying on its contents. |
| https://cursor.directory | HTTP 429 | Rate limit. **Not** evidence the site is gone. Unverified this session; it is a community index and never authoritative anyway. |

A 403 or 429 is a refusal to serve *this client*, not a statement about the
resource. Do not delete, re-date, or “fix” a row on one — only a 404/410 from an
unthrottled fetch is evidence of a dead link. Re-check both by hand or from a
different network before acting on them.
