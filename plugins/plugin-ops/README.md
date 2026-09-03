# plugin-ops

Plan-aware operators for Cursor plugins and marketplaces (Ultra / Teams / Enterprise).

Skills **fetch official Cursor docs live** before advising — see
[`reference/DOC-SOURCES.md`](reference/DOC-SOURCES.md).

Melodic policy (skills primary; no new `commands/`):  
[`docs/PLUGIN-PHILOSOPHY.md`](../../docs/PLUGIN-PHILOSOPHY.md).

## Skills

| Skill | Purpose |
| --- | --- |
| `/sync-local` | Copy plugin(s) from a path or git URL into `~/.cursor/plugins/local` |
| `/install-marketplace` | Choose `/plugin marketplace add`, Team Dashboard import, or local sync |
| `/update-plugins` | Team Auto Refresh vs personal pin vs local re-sync |
| `/verify-plugin` | Validate checkout against live Cursor docs + Melodic stances |

Invoke via Agent chat `/skill-name` (skills register in the slash menu). No
separate `commands/` layer.

## Script

`scripts/sync-local.ps1` and `scripts/sync-local.sh` copy plugin(s) into
`~/.cursor/plugins/local/<name>/` as **real directory copies**. The source is
**optional** — both twins default to the repo containing the script if it is a
marketplace or plugin, then a short known-checkout list (no home-directory
walk), then they clone `https://github.com/melodic-software/cursor-plugins`.
A local git checkout is fetched and fast-forwarded when the tree is clean and
has an upstream (including checked-out submodules), then copied in the same run.

| Behavior | PowerShell | Bash |
| --- | --- | --- |
| Source (local path or git URL) | `-Source <path-or-url>` | first positional argument |
| Plugin subset (marketplace sources) | `-Plugin a,b` | trailing positional arguments |
| Git ref for URL sources | `-Ref <branch\|tag\|sha>` | `--ref <branch\|tag\|sha>` |
| Skip fetch/fast-forward of a local git checkout | `-NoUpdate` | `--no-update` |
| Print actions, write nothing | `-DryRun` | `--dry-run` |
| Keep the temp clone of a URL source (path printed at the end) | `-KeepClone` | `--keep-clone` |

Bash flags are position-independent: they may appear before, between, or after the
positional arguments.

```powershell
pwsh -File scripts/sync-local.ps1                                    # this repo, all plugins
pwsh -File scripts/sync-local.ps1 -Source . -Plugin plugin-ops
pwsh -File scripts/sync-local.ps1 -Source https://github.com/org/repo -Ref main -KeepClone
pwsh -File scripts/sync-local.ps1 -Source D:\path\to\single-plugin -DryRun
```

```bash
bash scripts/sync-local.sh                                           # this repo, all plugins
bash scripts/sync-local.sh . plugin-ops
bash scripts/sync-local.sh --ref main --keep-clone https://github.com/org/repo
bash scripts/sync-local.sh --dry-run /path/to/single-plugin
```

Exit codes and the per-twin failure contract:
[`skills/sync-local/SKILL.md`](skills/sync-local/SKILL.md).
