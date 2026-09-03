#Requires -Version 5.1
<#
.SYNOPSIS
  Copy Cursor plugin(s) into ~/.cursor/plugins/local (real copies).

.DESCRIPTION
  Works for any Cursor plugin or marketplace checkout - not only this repo.
  Accepts a local path or GitHub URL. Detects:
    - multi-plugin marketplace (.cursor-plugin/marketplace.json)
    - single plugin (.cursor-plugin/plugin.json at root or under pluginRoot)

  Cursor may reject junctions whose target is outside ~/.cursor/plugins/local,
  so this script always writes real directory copies.

  An unrecognised switch exits 1, where the bash twin exits 2. That code is
  emitted by PowerShell's own parameter binder before this script body runs and
  cannot be overridden from the script, so the divergence is intentional and
  settled - do not "fix" it.

.PARAMETER Source
  Local path to a plugin or marketplace repo, or a git URL
  (https://github.com/org/repo[.git] or git@github.com:org/repo.git).
  Default: parent of scripts/ when that tree is a marketplace or plugin; else a
  short known-checkout list; else https://github.com/melodic-software/cursor-plugins.

.PARAMETER Plugin
  Optional plugin name(s) when Source is a marketplace. Default: all plugins
  with a .cursor-plugin/plugin.json.

.PARAMETER Ref
  Optional git ref when Source is a URL (branch, tag, or SHA). Default: remote HEAD.

.PARAMETER KeepClone
  When Source is a URL, keep the temp clone directory (printed at end).

.PARAMETER NoUpdate
  Skip fetch/fast-forward of a local git checkout. Default is to update a clean
  tracking branch so a stale clone is not copied. Dry-run never updates.

.PARAMETER DryRun
  Print actions without writing. Does not fetch or pull a local git source.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
  'PSAvoidUsingWriteHost', '',
  Justification = 'Every Write-Host here is script-scope output of a terminal-facing CLI: the console text IS the deliverable, and it is kept byte-identical to the bash twin scripts/sync-local.sh. Write-Output would emit these lines onto the pipeline, where a caller doing $x = ./sync-local.ps1 would capture the banner as data, and Write-Information is off by default so the user would see nothing.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
  'PSUseSingularNouns', '',
  Justification = 'Resolve-PluginDirs is a private helper inside a standalone script, not an exported cmdlet, and it genuinely returns a collection of plugin directories. A singular name would misdescribe its return value.')]
param(
  [string] $Source = "",
  [string[]] $Plugin,
  [string] $Ref = "",
  [switch] $KeepClone,
  [switch] $NoUpdate,
  [switch] $DryRun
)

$ErrorActionPreference = "Stop"
# Mirrors the bash twin's `set -u`: an unset variable, a missing property or an
# out-of-range index becomes a terminating error instead of a silent $null.
Set-StrictMode -Version 3.0

function Get-LocalPluginsRoot {
  if ($env:USERPROFILE) { return (Join-Path $env:USERPROFILE ".cursor\plugins\local") }
  if ($env:HOME) { return (Join-Path $env:HOME ".cursor/plugins/local") }
  throw "Neither USERPROFILE nor HOME is set"
}

function Get-JsonMember {
  # Strict mode turns a reference to a missing property into a terminating error,
  # but ConvertFrom-Json objects legitimately lack optional members (metadata,
  # plugins, source, path, name). Ask the PSObject for the property instead, so
  # "absent" stays a value rather than a throw. Also tolerates a $null input and a
  # non-object input (a [string] source has no 'path' member, and must not throw).
  param(
    $InputObject,
    [Parameter(Mandatory)][string] $Name
  )
  if ($null -eq $InputObject) { return $null }
  $property = $InputObject.PSObject.Properties[$Name]
  if ($null -eq $property) { return $null }
  return $property.Value
}

function Test-IsGitUrl([string] $value) {
  # -match is case-insensitive by default, which is what we want and what the bash
  # twin now folds its input to achieve: URI schemes are case-insensitive
  # (RFC 3986 3.1), so "HTTPS://host/repo" is a URL, not a local path.
  return $value -match '^(https://|git@|ssh://)' -or $value -match '\.git$'
}

function Get-NormalizedPath {
  # Absolute, lexically normalised ("." and ".." collapsed). GetFullPath does not
  # follow symlinks, matching the bash twin's resolve_path: symlinks are not the
  # threat (a symlinked plugin directory is a supported layout, and planting one
  # already requires write access to the source tree), whereas ".." reaches files
  # the user keeps outside it. Returns $null for input GetFullPath rejects, e.g. a
  # Windows-illegal join like "C:\repo\C:\Windows" - refused, not crashed.
  param([Parameter(Mandatory)][string] $Path)
  try { return [IO.Path]::GetFullPath($Path) } catch { return $null }
}

function Test-PathContained {
  # True when $Candidate is $Base itself or lies under it. Both must already be
  # absolute and normalised, so this compares resolved paths rather than raw input.
  param(
    [Parameter(Mandatory)][string] $Base,
    [Parameter(Mandatory)][string] $Candidate
  )
  $sep = [IO.Path]::DirectorySeparatorChar
  $trimmed = $Base.TrimEnd($sep)
  return ($Candidate -ceq $trimmed) -or
    $Candidate.StartsWith($trimmed + $sep, [StringComparison]::Ordinal)
}

function Resolve-PluginDirs {
  param(
    [Parameter(Mandatory)][string] $Root,
    [string[]] $Only
  )

  $marketplace = Join-Path $Root ".cursor-plugin\marketplace.json"
  $rootPlugin = Join-Path $Root ".cursor-plugin\plugin.json"
  $dirs = @()

  if (Test-Path $marketplace) {
    $json = Get-Content $marketplace -Raw | ConvertFrom-Json
    $entries = @(Get-JsonMember $json 'plugins')

    $rootFull = Get-NormalizedPath $Root
    if (-not $rootFull) { throw "Source path cannot be resolved: $Root" }
    $pluginRoot = $rootFull
    $relRoot = Get-JsonMember (Get-JsonMember $json 'metadata') 'pluginRoot'
    if ($relRoot) {
      # metadata.pluginRoot is untrusted input too: "../.." here would move the
      # base of every later join outside the source tree, so refuse it up front
      # rather than skipping each plugin in turn.
      $pluginRoot = Get-NormalizedPath (Join-Path $rootFull ([string]$relRoot))
      if (-not $pluginRoot -or -not (Test-PathContained -Base $rootFull -Candidate $pluginRoot)) {
        throw "metadata.pluginRoot escapes the source repo: $relRoot"
      }
    }

    $names = @()
    if ($Only -and $Only.Count -gt 0) {
      # Matched case-SENSITIVELY (-ceq below; the bash twin uses Python's ==).
      # The official schema constrains a plugin name to
      # ^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$, so exact matching is the schema-correct
      # and stricter choice: "Foo" must not silently select "foo".
      $names = $Only
    } else {
      # Nameless entries are dropped here rather than carried through to the
      # write-side guard, so a malformed marketplace produces the same result in
      # both twins (the bash lister filters the empty line its parser emits).
      $names = @($entries | ForEach-Object { [string](Get-JsonMember $_ 'name') } | Where-Object { $_ })
    }

    foreach ($name in $names) {
      $entry = $entries | Where-Object { [string](Get-JsonMember $_ 'name') -ceq $name } | Select-Object -First 1
      $rel = $name
      $entrySource = Get-JsonMember $entry 'source'
      if ($entrySource) {
        if ($entrySource -is [string]) {
          $rel = [string]$entrySource
        } else {
          $entryPath = Get-JsonMember $entrySource 'path'
          if ($entryPath) { $rel = [string]$entryPath }
        }
      }
      # $rel is untrusted marketplace.json content (plugins[].source, or
      # plugins[].source.path). A value of "../../../etc" would make the read side
      # copy files from outside the source repo into the user's plugins root - the
      # mirror image of the write-side name guard in the caller, which was already
      # closed. Resolve the join and require it to stay under $pluginRoot.
      $candidate = Get-NormalizedPath (Join-Path $pluginRoot $rel)
      if (-not $candidate -or -not (Test-PathContained -Base $pluginRoot -Candidate $candidate)) {
        $dirs += [pscustomobject]@{ Name = $name; Path = $null; Skip = "source escapes plugin root" }
        continue
      }
      $dirs += [pscustomobject]@{ Name = $name; Path = $candidate; Skip = $null }
    }
  } elseif (Test-Path $rootPlugin) {
    # An unparseable plugin.json aborts here (ConvertFrom-Json throws under
    # $ErrorActionPreference = "Stop"), where the bash twin warns and falls back
    # to the directory name. That divergence is deliberate: bash's parser is an
    # external optional dependency, so it must distinguish "python3 missing" from
    # "manifest broken" and stay usable in the first case; ConvertFrom-Json is
    # built in, so a failure here can only mean a broken manifest.
    $name = [string](Get-JsonMember (Get-Content $rootPlugin -Raw | ConvertFrom-Json) 'name')
    if (-not $name) {
      # The directory name is a guess: a manifest saying {"name":"good"} in a
      # directory called "single" would otherwise sync silently as "single", with
      # exit 0 and no hint that the name is wrong. Say so, as the bash twin does.
      # Written straight to stderr (not Write-Warning) so the text matches the
      # twin's byte for byte.
      $name = Split-Path $Root -Leaf
      [Console]::Error.WriteLine("Warning: falling back to the directory name '$name', which may not be the plugin's declared name")
    }
    # Case-SENSITIVE (-cnotcontains) for the reason given above.
    if ($Only -and $Only.Count -gt 0 -and ($Only -cnotcontains $name)) {
      throw "Plugin filter excluded single plugin '$name'"
    }
    $dirs += [pscustomobject]@{ Name = $name; Path = $Root; Skip = $null }
  } else {
    # Fallback: plugins/* layout without marketplace.json
    $pluginsDir = Join-Path $Root "plugins"
    if (Test-Path $pluginsDir) {
      $candidates = if ($Only -and $Only.Count -gt 0) {
        $Only | ForEach-Object { Join-Path $pluginsDir $_ }
      } else {
        Get-ChildItem $pluginsDir -Directory | ForEach-Object { $_.FullName }
      }
      foreach ($p in $candidates) {
        $dirs += [pscustomobject]@{ Name = (Split-Path $p -Leaf); Path = $p; Skip = $null }
      }
    }
  }

  return $dirs
}

$MelodicMarketplaceUrl = "https://github.com/melodic-software/cursor-plugins"

function Test-PluginLayout {
  param([Parameter(Mandatory)][string] $Root)
  return (
    (Test-Path (Join-Path $Root ".cursor-plugin\marketplace.json")) -or
    (Test-Path (Join-Path $Root ".cursor-plugin\plugin.json")) -or
    (Test-Path (Join-Path $Root "plugins"))
  )
}

function Get-KnownCheckoutPaths {
  # Fixed candidate list. Test-Path only -- do not glob or walk $HOME,
  # OneDrive, Documents, or AppData. Those walks hang for minutes on Windows.
  $paths = New-Object System.Collections.Generic.List[string]
  $add = {
    param([string] $Candidate)
    if ($Candidate -and -not $paths.Contains($Candidate)) { [void]$paths.Add($Candidate) }
  }
  if ($env:MELODIC_CURSOR_PLUGINS) { & $add $env:MELODIC_CURSOR_PLUGINS }
  $homes = @()
  if ($env:HOME) { $homes += $env:HOME }
  if ($env:USERPROFILE) { $homes += $env:USERPROFILE }
  foreach ($userHome in $homes) {
    & $add (Join-Path $userHome "cursor-plugins")
    & $add (Join-Path $userHome "repos\github.com\melodic-software\cursor-plugins")
    & $add (Join-Path $userHome "src\github.com\melodic-software\cursor-plugins")
  }
  & $add "D:\repos\github.com\melodic-software\cursor-plugins"
  & $add "C:\repos\github.com\melodic-software\cursor-plugins"
  return $paths
}

function Resolve-ImplicitSource {
  param([Parameter(Mandatory)][string] $ScriptDefault)
  if (Test-PluginLayout $ScriptDefault) { return $ScriptDefault }
  foreach ($candidate in Get-KnownCheckoutPaths) {
    if ((Test-Path -LiteralPath $candidate) -and (Test-PluginLayout $candidate)) {
      [Console]::Error.WriteLine("Using checkout: $candidate")
      return $candidate
    }
  }
  [Console]::Error.WriteLine("No local checkout found; cloning $MelodicMarketplaceUrl")
  return $MelodicMarketplaceUrl
}

function Get-ShortHead {
  param([Parameter(Mandatory)][string] $Root)
  $head = git -C $Root rev-parse --short=7 HEAD 2>$null
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($head)) { return $null }
  return ([string]$head).Trim()
}

function Invoke-LocalGitFastForward {
  # Fast-forward a local git checkout so a stale clone does not get copied.
  # Never prompted (GIT_TERMINAL_PROMPT=0). Failures degrade to syncing HEAD.
  # Prints one stdout line so both twins stay byte-identical.
  param([Parameter(Mandatory)][string] $Root)
  if (-not (Test-Path (Join-Path $Root ".git"))) { return }

  $head = Get-ShortHead $Root
  if (-not $head) { return }

  $porcelain = git -C $Root status --porcelain 2>$null
  if ($LASTEXITCODE -eq 0 -and $porcelain) {
    Write-Host "Local checkout is dirty; syncing the working tree at $head without pulling"
    return
  }

  git -C $Root rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Local checkout has no upstream; syncing current HEAD $head"
    return
  }

  $previousPrompt = $env:GIT_TERMINAL_PROMPT
  $env:GIT_TERMINAL_PROMPT = "0"
  try {
    git -C $Root fetch --quiet 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Write-Host "Could not fetch; syncing current HEAD $head"
      return
    }

    $upstream = git -C $Root rev-parse --short=7 '@{u}' 2>$null
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($upstream) -and
        ([string]$upstream).Trim() -eq $head) {
      Write-Host "Local checkout already up to date ($head)"
      return
    }

    git -C $Root merge --ff-only --no-edit '@{u}' 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
      Write-Host "Fast-forwarded $head..$(Get-ShortHead $Root)"
      return
    }
    Write-Host "Could not fast-forward; syncing current HEAD $head"
  } finally {
    if ($null -eq $previousPrompt) {
      Remove-Item Env:GIT_TERMINAL_PROMPT -ErrorAction SilentlyContinue
    } else {
      $env:GIT_TERMINAL_PROMPT = $previousPrompt
    }
  }
}

function Copy-PluginReal {
  param(
    [Parameter(Mandatory)][string] $Src,
    [Parameter(Mandatory)][string] $Dst,
    [switch] $DryRun
  )
  # The caller prints the per-plugin line (bash prints exactly one); print nothing here.
  if ($DryRun) { return }
  if (Test-Path $Dst) {
    $item = Get-Item $Dst -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
      # Drop the link, never its target. Directory.Delete "does not recurse through
      # the reparse point", which is what `rmdir` gave us -- but on every platform.
      # (`cmd` does not exist on Linux/macOS, where .NET also reports a symlinked
      # directory as Directory, ReparsePoint.)
      [IO.Directory]::Delete($Dst, $false)
    } else {
      Remove-Item $Dst -Recurse -Force
    }
  }
  $parent = Split-Path $Dst -Parent
  New-Item -ItemType Directory -Force -Path $parent | Out-Null
  Copy-Item -Recurse -Force $Src $Dst
}

$scriptRepoDefault = Resolve-Path (Join-Path $PSScriptRoot "..")
if (-not $Source) { $Source = Resolve-ImplicitSource -ScriptDefault ([string]$scriptRepoDefault) }

$tempClone = $null
$workRoot = $null

try {
  if (Test-IsGitUrl $Source) {
    $tempClone = Join-Path ([IO.Path]::GetTempPath()) ("cursor-plugin-sync-" + [guid]::NewGuid().ToString("n"))
    New-Item -ItemType Directory -Force -Path $tempClone | Out-Null
    Write-Host "Cloning $Source ..."
    if ($Ref) {
      git clone --depth 1 --branch $Ref $Source $tempClone
    } else {
      git clone --depth 1 $Source $tempClone
    }
    if ($LASTEXITCODE -ne 0) { throw "git clone failed (exit $LASTEXITCODE)" }
    $workRoot = $tempClone
  } else {
    if (-not (Test-Path $Source)) {
      [Console]::Error.WriteLine("If you do not have a checkout, pass a git URL (for this marketplace: $MelodicMarketplaceUrl).")
      throw "Source path not found: $Source"
    }
    $workRoot = (Resolve-Path $Source).Path
    if (-not $DryRun -and -not $NoUpdate) {
      Invoke-LocalGitFastForward -Root $workRoot
    }
  }

  $localRoot = Get-LocalPluginsRoot
  New-Item -ItemType Directory -Force -Path $localRoot | Out-Null

  $pluginDirs = @(Resolve-PluginDirs -Root $workRoot -Only $Plugin)
  # Covers both "no recognised layout" and "layout found but it named no plugins"
  # (e.g. an empty plugins/ dir, or "plugins": [] in marketplace.json). Entries
  # that were named but refused are still counted here, so they fall through to
  # the Skipped report instead of being swallowed by this message.
  if ($pluginDirs.Count -eq 0) {
    throw "No Cursor plugins found under $workRoot (need marketplace.json or plugin.json)."
  }

  $synced = @()
  $skipped = @()

  foreach ($entry in $pluginDirs) {
    if ($entry.Skip) {
      $skipped += "$($entry.Name) ($($entry.Skip))"
      continue
    }
    # Name comes from untrusted marketplace.json/plugin.json and is joined onto
    # $localRoot before Remove-Item. Keep it a single path segment so the
    # destination cannot escape the plugins root.
    if ([string]::IsNullOrWhiteSpace($entry.Name) -or
        $entry.Name -match '[\\/]' -or $entry.Name -eq '.' -or $entry.Name -eq '..') {
      $skipped += "$($entry.Name) (invalid plugin name)"
      continue
    }
    $manifest = Join-Path $entry.Path ".cursor-plugin\plugin.json"
    if (-not (Test-Path $manifest)) {
      $skipped += "$($entry.Name) (missing .cursor-plugin/plugin.json)"
      continue
    }
    $dst = Join-Path $localRoot $entry.Name
    Copy-PluginReal -Src $entry.Path -Dst $dst -DryRun:$DryRun
    $label = if ($DryRun) { "[dry-run]" } else { "synced" }
    Write-Host "$label $($entry.Name) -> $dst"
    $synced += $entry.Name
  }

  Write-Host ""
  Write-Host "Source: $workRoot"
  Write-Host "Local:  $localRoot"
  # A dry run copies nothing, so it must not report "Synced" -- that reads as work
  # done. The real-run line is unchanged.
  $syncedLabel = if ($DryRun) { "Would sync" } else { "Synced" }
  Write-Host "$syncedLabel ($($synced.Count)): $($synced -join ', ')"
  if ($skipped.Count -gt 0) {
    Write-Host "Skipped ($($skipped.Count)): $($skipped -join '; ')"
  }
  Write-Host "Reload Cursor: Developer: Reload Window"
}
finally {
  # Known limitation, deliberately not worked around: this `finally` runs on normal
  # completion, on a thrown error and on SIGINT (Ctrl+C), but PowerShell offers no
  # portable SIGTERM/SIGHUP hook, so a `kill` or a closed terminal leaves the temp
  # clone behind in the temp directory. The bash twin's `trap cleanup EXIT` does
  # cover TERM and HUP; that stronger guarantee is kept there rather than degraded
  # to match here. "Kept clone:" is printed from here, after "Reload Cursor:", and
  # the bash twin prints it from its exit handler for the same ordering.
  if ($tempClone -and (Test-Path $tempClone)) {
    if ($KeepClone) {
      Write-Host "Kept clone: $tempClone"
    } else {
      Remove-Item $tempClone -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}
