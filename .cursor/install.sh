#!/usr/bin/env bash
# Cloud Agent install phase for the cursor-plugins marketplace.
#
# This repo has no build and no package manager: bash, git, python3, jq, node
# and curl (the tools its own scripts use at runtime) are already in the base
# image. What is NOT preinstalled is the *checking* toolchain the repo documents
# in AGENTS.md and runs in CI. This script installs exactly that, idempotently,
# so a fresh agent can lint, validate, and test without any manual setup:
#
#   - shellcheck             lint scripts/*.sh
#   - PowerShell + PSScript   run the .ps1 twin + PSScriptAnalyzer (mirrors CI)
#     Analyzer                (optional: the .sh twin covers Linux on its own)
#   - node deps (ajv)         validate manifests against Cursor's schemas
#
# It is safe to run repeatedly and makes no change to the base image's runtime
# tools.
set -euo pipefail

log() { printf '==> %s\n' "$*"; }

_install_dir="${BASH_SOURCE[0]%/*}"
[[ "$_install_dir" == "${BASH_SOURCE[0]}" ]] && _install_dir=.
repo_root="$(cd "$_install_dir/.." && pwd)"
unset _install_dir
cd "$repo_root"

# --- shellcheck + PowerShell (one apt-get update) -----------------------------
# Adding Microsoft's apt source requires a subsequent `apt-get update`, so when
# both tools are missing the previous script updated twice. Register the extra
# source first (if pwsh is absent), then update once, then install each missing
# package separately so a PowerShell failure cannot roll back shellcheck.
# A PowerShell failure is still tolerated: the .sh twin covers Linux on its own.
need_shellcheck=0
need_pwsh=0
command -v shellcheck >/dev/null 2>&1 || need_shellcheck=1
command -v pwsh >/dev/null 2>&1 || need_pwsh=1

if [[ "$need_shellcheck" -eq 0 ]]; then
  log "shellcheck present: $(shellcheck --version | awk '/^version:/ {print $2}')"
fi
if [[ "$need_pwsh" -eq 0 ]]; then
  log "PowerShell present: $(pwsh --version)"
fi

if [[ "$need_pwsh" -eq 1 ]]; then
  ver="$(awk -F= '$1 == "VERSION_ID" { gsub(/"/, "", $2); print $2 }' /etc/os-release)"
  deb="$(mktemp --suffix=.deb)"
  if curl -fsSL "https://packages.microsoft.com/config/ubuntu/${ver}/packages-microsoft-prod.deb" -o "$deb" &&
    sudo dpkg -i "$deb"; then
    :
  else
    log "PowerShell repo package failed; continuing (the .sh twin covers Linux)"
    need_pwsh=0
  fi
  rm -f "$deb"
fi

if [[ "$need_shellcheck" -eq 1 || "$need_pwsh" -eq 1 ]]; then
  log "apt-get update"
  sudo apt-get update
fi
if [[ "$need_shellcheck" -eq 1 ]]; then
  log "Installing shellcheck"
  sudo apt-get install -y --no-install-recommends shellcheck
fi
if [[ "$need_pwsh" -eq 1 ]]; then
  log "Installing PowerShell"
  if sudo apt-get install -y --no-install-recommends powershell; then
    log "PowerShell installed: $(pwsh --version)"
  else
    log "PowerShell install failed; continuing (the .sh twin covers Linux)"
  fi
fi

if command -v pwsh >/dev/null 2>&1; then
  if pwsh -NoProfile -c 'if (Get-Module -ListAvailable PSScriptAnalyzer) { exit 0 } else { exit 1 }'; then
    log "PSScriptAnalyzer present"
  else
    log "Installing PSScriptAnalyzer"
    pwsh -NoProfile -c 'Set-PSRepository PSGallery -InstallationPolicy Trusted; Install-Module PSScriptAnalyzer -Scope CurrentUser -Force' \
      || log "PSScriptAnalyzer install failed; continuing"
  fi
fi

# --- node deps for the manifest schema validator ------------------------------
# scripts/validate-manifests.mjs imports ajv + ajv-formats. Node resolves those
# from ./node_modules (which .gitignore already excludes). Install via a temp
# prefix and move only node_modules across, so no package.json / package-lock
# is left untracked in the working tree.
# Skip when both packages are already present: a repeat run otherwise paid a
# measured ~0.9s npm install plus an `rm -rf node_modules` of a good tree.
if [[ -d node_modules/ajv && -d node_modules/ajv-formats ]]; then
  log "manifest-validator node deps present (ajv, ajv-formats)"
else
  log "Installing manifest-validator node deps (ajv, ajv-formats)"
  npm_tmp="$(mktemp -d)"
  npm install --prefix "$npm_tmp" --no-fund --no-audit --silent ajv@8 ajv-formats
  rm -rf node_modules
  mv "$npm_tmp/node_modules" node_modules
  rm -rf "$npm_tmp"
fi

log "Install complete. Checks available:"
log "  shellcheck scripts/*.sh"
log "  bash scripts/test-sync-local.sh"
log "  pwsh -c 'Invoke-ScriptAnalyzer -Path ./scripts/sync-local.ps1'"
log "  jq empty .cursor-plugin/marketplace.json"
log "  node scripts/validate-manifests.mjs   # after fetching the two schemas"
