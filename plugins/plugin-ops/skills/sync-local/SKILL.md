---
name: sync-local
description: Sync any Cursor plugin or marketplace (local path or git URL) into ~/.cursor/plugins/local with real copies. Use when marketplace updates are stale or pinned, for Ultra/personal installs, or to pin disk copies of selected plugins.
---

# Sync plugins to ~/.cursor/plugins/local

## Official docs (fetch live first)

1. Fetch https://cursor.com/docs/plugins — especially **Test plugins locally**.
2. Fetch https://cursor.com/docs/reference/plugins — marketplace vs single-plugin layout.
3. Follow `plugins/plugin-ops/reference/DOC-SOURCES.md` for the full URL list.
4. Prefer live docs over this skill if they disagree.
5. Melodic policy: `docs/PLUGIN-PHILOSOPHY.md` (skills primary; no `commands/` layer for this workflow).

## When to use

- Personal / Ultra: disk-truth update path. A personally-added marketplace
  (`/plugin marketplace add`, formerly `/add-plugin`) can be pinned with `--git-ref`,
  so `/plugin marketplace update` will keep returning the pinned commit.
- Any plan where local plugin imports are permitted: local override or offline copy of selected plugins (see step 6 — Enterprise disallows them by default).
- Source can be **this Melodic repo**, **any marketplace URL**, or **a single-plugin repo**.

## Inputs

Ask only if missing:

- **Source** — local path, or git URL (`https://github.com/org/repo`). Default: open workspace if it has `.cursor-plugin/marketplace.json` or `plugin.json`, else this `cursor-plugins` checkout if present.
- **Plugin names** (optional) — subset when Source is a multi-plugin marketplace.
- **Ref** (optional) — branch/tag/SHA for URL sources.

## Steps

1. Resolve Source (path or URL) and optional plugin filter / ref.
2. Run from a machine that has the `cursor-plugins` scripts **or** copy the script invocation into the Source repo if it vendors the same scripts. Prefer Melodic scripts when available:
   - Windows:  
     `pwsh -File <cursor-plugins>/scripts/sync-local.ps1 [-Source <path-or-url>] [-Plugin a,b] [-Ref main] [-KeepClone] [-DryRun]`
   - Unix:  
     `bash <cursor-plugins>/scripts/sync-local.sh [--dry-run] [--ref main] [--keep-clone] [<path-or-url>] [plugin ...]`
   - `-Source` / the positional source is optional: both default to the repo containing the script. `-KeepClone` / `--keep-clone` keeps the temp clone when the source is a URL (its path is printed at the end) — useful when inspecting what was synced. `-DryRun` / `--dry-run` writes nothing and prints `[dry-run] <name> -> <dst>` per plugin, closing with **`Would sync (n): ...`** — a dry run never prints `Synced`, so `Synced (n)` in the output is proof a real copy ran. Bash flags are position-independent; PowerShell parameters are named.
   - **Check the exit code, not just the banner.** Both twins exit **1** and copy nothing on: a source path that does not exist (`Source path not found: <path>`), a `metadata.pluginRoot` that escapes the source repo (`metadata.pluginRoot escapes the source repo: <value>`), a plugin filter that excludes the only plugin (`Plugin filter excluded single plugin '<name>'`), and *no plugins resolved* — including an empty `plugins/` directory or `"plugins": []`, which exit 1 with `No Cursor plugins found under <path> (need marketplace.json or plugin.json).` rather than reporting a hollow `Synced (0)`. The messages are worded identically in both twins; the pwsh twin wraps them in a PowerShell error record, so expect the same sentence surrounded by a stack trace.
   - **Argument errors are twin-specific — do not quote one twin's message or code when running the other.** `sync-local.sh` parses its own flags, so a `--ref` with no value prints `Missing value for --ref` and exits **2** (an unknown flag prints `Unknown flag: <flag>` and also exits **2**). `sync-local.ps1` declares `param([string] $Ref = "")`, so PowerShell's own parameter binder rejects the argument before the script body runs: `-Ref` with nothing after it gives `Missing an argument for parameter 'Ref'. Specify a parameter of type 'System.String' and try again.` and exits **1**, and an unknown `-Flag` gives `A parameter cannot be found that matches parameter name '<flag>'.`, also exit **1**. The binder emits that code before the script can set one, so the divergence is by design; match the message and code to the twin you actually invoked.
   - Individual plugins can also be skipped and reported, in both twins: `(source escapes plugin root)` when an entry's `source` resolves outside the plugin root, `(invalid plugin name)` for a name that is not a single path segment, `(missing .cursor-plugin/plugin.json)` for a directory with no manifest. A non-empty `Skipped (n)` line with `Synced (0)` is exit 0 but still means nothing landed — read both lines.
3. If Melodic scripts are unavailable, still perform **real directory copies** of each plugin dir (must contain `.cursor-plugin/plugin.json`) into `~/.cursor/plugins/local/<name>/` (Windows: `%USERPROFILE%\.cursor\plugins\local\`). Do not rely on junctions unless the user explicitly accepts Cursor may reject them (docs mention symlinks for local test; Melodic default is real copies).
4. Report synced names + destination root.
5. Instruct **Developer: Reload Window**.
6. If the plugin still does not appear, check the two gates the live **Test plugins locally** section documents before assuming the sync failed:
   - Local imports must be permitted. On Teams/Enterprise admins control this with **Allow Local Plugin Imports** under **Dashboard → Settings → Security & Identity → Marketplace and Plugins**, and it is **off by default on Enterprise**.
   - "If a marketplace plugin with the same name is already installed, that install takes precedence over the local copy" — uninstall the marketplace copy first, or a correct sync will look like a no-op.

## Out of scope

- Team Marketplace Dashboard import (use `install-marketplace` / `update-plugins`).
- Committing secrets into plugins.
