#Requires -Version 5.1
<#
.SYNOPSIS
  Copy plugins from this marketplace repo into ~/.cursor/plugins/local (real copies).

.DESCRIPTION
  Cursor rejects junctions whose target is outside ~/.cursor/plugins/local.
  This script mirrors plugins/<name>/ -> %USERPROFILE%\.cursor\plugins\local\<name>\.

.PARAMETER Plugin
  Optional plugin name(s). Default: all directories under plugins/ that contain
  .cursor-plugin/plugin.json.

.PARAMETER DryRun
  Print actions without writing.
#>
[CmdletBinding()]
param(
  [string[]] $Plugin,
  [switch] $DryRun
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$pluginsRoot = Join-Path $repoRoot "plugins"
$localRoot = Join-Path $env:USERPROFILE ".cursor\plugins\local"

if (-not (Test-Path $pluginsRoot)) {
  throw "No plugins/ directory at $pluginsRoot"
}

New-Item -ItemType Directory -Force -Path $localRoot | Out-Null

$candidates = @()
if ($Plugin -and $Plugin.Count -gt 0) {
  foreach ($name in $Plugin) {
    $candidates += (Join-Path $pluginsRoot $name)
  }
} else {
  $candidates = Get-ChildItem $pluginsRoot -Directory | ForEach-Object { $_.FullName }
}

$synced = @()
$skipped = @()

foreach ($src in $candidates) {
  $name = Split-Path $src -Leaf
  $manifest = Join-Path $src ".cursor-plugin\plugin.json"
  if (-not (Test-Path $manifest)) {
    $skipped += "$name (missing .cursor-plugin/plugin.json)"
    continue
  }

  $dst = Join-Path $localRoot $name
  if ($DryRun) {
    Write-Host "[dry-run] would sync $name -> $dst"
    $synced += $name
    continue
  }

  if (Test-Path $dst) {
    $item = Get-Item $dst -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
      cmd /c "rmdir `"$dst`"" | Out-Null
    } else {
      Remove-Item $dst -Recurse -Force
    }
  }

  Copy-Item -Recurse -Force $src $dst
  Write-Host "synced $name -> $dst"
  $synced += $name
}

Write-Host ""
Write-Host "Synced ($($synced.Count)): $($synced -join ', ')"
if ($skipped.Count -gt 0) {
  Write-Host "Skipped ($($skipped.Count)): $($skipped -join '; ')"
}
Write-Host "Reload Cursor: Developer: Reload Window"
