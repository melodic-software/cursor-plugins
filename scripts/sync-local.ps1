#Requires -Version 5.1
<#
.SYNOPSIS
  Copy Cursor plugin(s) into ~/.cursor/plugins/local (real copies).

.DESCRIPTION
  Works for any Cursor plugin or marketplace checkout — not only this repo.
  Accepts a local path or GitHub URL. Detects:
    - multi-plugin marketplace (.cursor-plugin/marketplace.json)
    - single plugin (.cursor-plugin/plugin.json at root or under pluginRoot)

  Cursor may reject junctions whose target is outside ~/.cursor/plugins/local,
  so this script always writes real directory copies.

.PARAMETER Source
  Local path to a plugin or marketplace repo, or a git URL
  (https://github.com/org/repo[.git] or git@github.com:org/repo.git).
  Default: parent of scripts/ (this marketplace repo).

.PARAMETER Plugin
  Optional plugin name(s) when Source is a marketplace. Default: all plugins
  with a .cursor-plugin/plugin.json.

.PARAMETER Ref
  Optional git ref when Source is a URL (branch, tag, or SHA). Default: remote HEAD.

.PARAMETER KeepClone
  When Source is a URL, keep the temp clone directory (printed at end).

.PARAMETER DryRun
  Print actions without writing.
#>
[CmdletBinding()]
param(
  [string] $Source = "",
  [string[]] $Plugin,
  [string] $Ref = "",
  [switch] $KeepClone,
  [switch] $DryRun
)

$ErrorActionPreference = "Stop"

function Get-LocalPluginsRoot {
  if ($env:USERPROFILE) { return (Join-Path $env:USERPROFILE ".cursor\plugins\local") }
  if ($env:HOME) { return (Join-Path $env:HOME ".cursor/plugins/local") }
  throw "Neither USERPROFILE nor HOME is set"
}

function Test-IsGitUrl([string] $value) {
  return $value -match '^(https://|git@|ssh://)' -or $value -match '\.git$'
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
    $pluginRoot = $Root
    if ($json.metadata -and $json.metadata.pluginRoot) {
      $pluginRoot = Join-Path $Root ([string]$json.metadata.pluginRoot)
    }

    $names = @()
    if ($Only -and $Only.Count -gt 0) {
      $names = $Only
    } elseif ($json.plugins) {
      $names = @($json.plugins | ForEach-Object { [string]$_.name })
    }

    foreach ($name in $names) {
      $entry = $null
      if ($json.plugins) {
        $entry = @($json.plugins | Where-Object { [string]$_.name -eq $name } | Select-Object -First 1)
      }
      $rel = $name
      if ($entry -and $entry.source) {
        if ($entry.source -is [string]) { $rel = [string]$entry.source }
        elseif ($entry.source.path) { $rel = [string]$entry.source.path }
      }
      $dirs += [pscustomobject]@{ Name = $name; Path = (Join-Path $pluginRoot $rel) }
    }
  } elseif (Test-Path $rootPlugin) {
    $name = (Get-Content $rootPlugin -Raw | ConvertFrom-Json).name
    if (-not $name) { $name = Split-Path $Root -Leaf }
    if ($Only -and $Only.Count -gt 0 -and ($Only -notcontains $name)) {
      return @()
    }
    $dirs += [pscustomobject]@{ Name = $name; Path = $Root }
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
        $dirs += [pscustomobject]@{ Name = (Split-Path $p -Leaf); Path = $p }
      }
    }
  }

  return $dirs
}

function Copy-PluginReal {
  param(
    [Parameter(Mandatory)][string] $Src,
    [Parameter(Mandatory)][string] $Dst,
    [switch] $DryRun
  )
  if ($DryRun) {
    Write-Host "[dry-run] would sync -> $Dst"
    return
  }
  if (Test-Path $Dst) {
    $item = Get-Item $Dst -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
      cmd /c "rmdir `"$Dst`"" | Out-Null
    } else {
      Remove-Item $Dst -Recurse -Force
    }
  }
  $parent = Split-Path $Dst -Parent
  New-Item -ItemType Directory -Force -Path $parent | Out-Null
  Copy-Item -Recurse -Force $Src $Dst
}

$scriptRepoDefault = Resolve-Path (Join-Path $PSScriptRoot "..")
if (-not $Source) { $Source = [string]$scriptRepoDefault }

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
    if (-not (Test-Path $Source)) { throw "Source path not found: $Source" }
    $workRoot = (Resolve-Path $Source).Path
  }

  $localRoot = Get-LocalPluginsRoot
  New-Item -ItemType Directory -Force -Path $localRoot | Out-Null

  $pluginDirs = @(Resolve-PluginDirs -Root $workRoot -Only $Plugin)
  if ($pluginDirs.Count -eq 0) {
    throw "No Cursor plugins found under $workRoot (need marketplace.json or plugin.json)."
  }

  $synced = @()
  $skipped = @()

  foreach ($entry in $pluginDirs) {
    $manifest = Join-Path $entry.Path ".cursor-plugin\plugin.json"
    if (-not (Test-Path $manifest)) {
      # single-plugin repo already checked root; marketplace entry missing on disk
      $alt = Join-Path $entry.Path ".cursor-plugin/plugin.json"
      if (-not (Test-Path $alt)) {
        $skipped += "$($entry.Name) (missing .cursor-plugin/plugin.json)"
        continue
      }
    }
    $dst = Join-Path $localRoot $entry.Name
    Copy-PluginReal -Src $entry.Path -Dst $dst -DryRun:$DryRun
    if (-not $DryRun) { Write-Host "synced $($entry.Name) -> $dst" }
    else { Write-Host "[dry-run] $($entry.Name) -> $dst" }
    $synced += $entry.Name
  }

  Write-Host ""
  Write-Host "Source: $workRoot"
  Write-Host "Local:  $localRoot"
  Write-Host "Synced ($($synced.Count)): $($synced -join ', ')"
  if ($skipped.Count -gt 0) {
    Write-Host "Skipped ($($skipped.Count)): $($skipped -join '; ')"
  }
  Write-Host "Reload Cursor: Developer: Reload Window"
}
finally {
  if ($tempClone -and (Test-Path $tempClone)) {
    if ($KeepClone) {
      Write-Host "Kept clone: $tempClone"
    } else {
      Remove-Item $tempClone -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}
