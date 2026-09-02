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

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# --- shellcheck (system lint for scripts/*.sh) -------------------------------
if command -v shellcheck >/dev/null 2>&1; then
  log "shellcheck present: $(shellcheck --version | awk '/^version:/ {print $2}')"
else
  log "Installing shellcheck"
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends shellcheck
fi

# --- PowerShell (optional: exercises the .ps1 twin + PSScriptAnalyzer) --------
# The .sh twin fully covers Linux, so a PowerShell install failure is logged and
# tolerated rather than failing the whole environment.
install_powershell() {
  local ver deb
  ver="$(awk -F= '$1 == "VERSION_ID" { gsub(/"/, "", $2); print $2 }' /etc/os-release)"
  deb="$(mktemp --suffix=.deb)"
  curl -fsSL "https://packages.microsoft.com/config/ubuntu/${ver}/packages-microsoft-prod.deb" -o "$deb"
  sudo dpkg -i "$deb"
  rm -f "$deb"
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends powershell
}

if command -v pwsh >/dev/null 2>&1; then
  log "PowerShell present: $(pwsh --version)"
elif install_powershell; then
  log "PowerShell installed: $(pwsh --version)"
else
  log "PowerShell install failed; continuing (the .sh twin covers Linux)"
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
log "Installing manifest-validator node deps (ajv, ajv-formats)"
npm_tmp="$(mktemp -d)"
npm install --prefix "$npm_tmp" --no-fund --no-audit --silent ajv@8 ajv-formats
rm -rf node_modules
mv "$npm_tmp/node_modules" node_modules
rm -rf "$npm_tmp"

log "Install complete. Checks available:"
log "  shellcheck scripts/*.sh"
log "  bash scripts/test-sync-local.sh"
log "  pwsh -c 'Invoke-ScriptAnalyzer -Path ./scripts/sync-local.ps1'"
log "  jq empty .cursor-plugin/marketplace.json"
log "  node scripts/validate-manifests.mjs   # after fetching the two schemas"
