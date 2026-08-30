#!/usr/bin/env bash
# Regression suite for the sync-local parity twins.
#
# Every case runs BOTH scripts/sync-local.sh and scripts/sync-local.ps1 against
# the same fixture and asserts the same exit code and the same stdout, because
# the two are documented parity twins and a divergence between them is itself a
# defect. Only stdout is compared: PowerShell wraps stderr in its own exception
# frame, so the twins' error *text* matches while their error *framing* does not.
#
# pwsh is optional. When it is absent the PowerShell half is reported as skipped
# and the bash half still runs, so this suite is useful on a machine that only
# has bash.
#
# Usage: bash scripts/test-sync-local.sh
# Exit:  0 all assertions passed, 1 otherwise.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
sh_script="$repo_root/scripts/sync-local.sh"
ps_script="$repo_root/scripts/sync-local.ps1"

have_pwsh=0
if command -v pwsh >/dev/null 2>&1; then have_pwsh=1; fi

pass=0
fail=0
skip=0
failed_names=()

work="$(mktemp -d "${TMPDIR:-/tmp}/sync-local-tests.XXXXXX")"
trap 'rm -rf "$work"' EXIT

# --- assertions ---------------------------------------------------------------

ok() { pass=$((pass + 1)); printf '  ok   %s\n' "$1"; }

not_ok() {
  fail=$((fail + 1))
  failed_names+=("$1")
  printf '  FAIL %s\n' "$1"
  shift
  while [[ $# -gt 0 ]]; do printf '         %s\n' "$1"; shift; done
}

# run_sh / run_ps write stdout to $out_file and return the exit code. HOME is
# redirected per call so a test never touches the real ~/.cursor.
run_sh() {
  local home="$1" out="$2"
  shift 2
  local rc=0
  HOME="$home" bash "$sh_script" "$@" >"$out" 2>"$out.err" || rc=$?
  return "$rc"
}

run_ps() {
  local home="$1" out="$2"
  shift 2
  local rc=0
  env -u USERPROFILE HOME="$home" pwsh -NoProfile -File "$ps_script" "$@" \
    >"$out" 2>"$out.err" || rc=$?
  return "$rc"
}

# Normalize the sandbox HOME out of the output so the two twins are comparable.
normalize() { sed "s|$1|<HOME>|g" "$2"; }

# assert_twins <name> <expected-exit> <sh-args...> -- <ps-args...>
# Asserts both twins exit with <expected-exit> and produce identical stdout.
assert_twins() {
  local name="$1" want="$2"
  shift 2
  local sh_args=() ps_args=() seen=0
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == "--" ]]; then seen=1; shift; continue; fi
    if [[ "$seen" -eq 0 ]]; then sh_args+=("$1"); else ps_args+=("$1"); fi
    shift
  done

  local h1 h2 o1 o2 rc1 rc2
  h1="$work/h.$name.sh"; h2="$work/h.$name.ps"
  o1="$work/o.$name.sh"; o2="$work/o.$name.ps"
  mkdir -p "$h1" "$h2"

  rc1=0; run_sh "$h1" "$o1" "${sh_args[@]}" || rc1=$?
  if [[ "$rc1" -ne "$want" ]]; then
    not_ok "$name (sh exit)" "expected $want, got $rc1" "$(head -3 "$o1" "$o1.err" 2>/dev/null)"
  else
    ok "$name (sh exit $want)"
  fi

  if [[ "$have_pwsh" -eq 0 ]]; then
    skip=$((skip + 1)); printf '  skip %s (pwsh not installed)\n' "$name"
    return 0
  fi

  rc2=0; run_ps "$h2" "$o2" "${ps_args[@]}" || rc2=$?
  if [[ "$rc2" -ne "$want" ]]; then
    not_ok "$name (ps1 exit)" "expected $want, got $rc2" "$(head -3 "$o2" "$o2.err" 2>/dev/null)"
  else
    ok "$name (ps1 exit $want)"
  fi

  if diff <(normalize "$h1" "$o1") <(normalize "$h2" "$o2") >"$work/d.$name" 2>&1; then
    ok "$name (twins byte-identical)"
  else
    not_ok "$name (twin parity)" "$(head -8 "$work/d.$name")"
  fi
}

# assert_contains <name> <file> <needle>
assert_contains() {
  if grep -qF -- "$3" "$2"; then ok "$1"; else
    not_ok "$1" "expected to find: $3" "got: $(head -3 "$2")"
  fi
}

# assert_absent <name> <file> <needle>
assert_absent() {
  if grep -qF -- "$3" "$2"; then
    not_ok "$1" "should NOT contain: $3" "got: $(head -5 "$2")"
  else ok "$1"; fi
}

# --- fixtures -----------------------------------------------------------------

mkplugin() { # mkplugin <dir> <name>
  mkdir -p "$1/.cursor-plugin"
  printf '{ "name": "%s" }\n' "$2" >"$1/.cursor-plugin/plugin.json"
}

mkmarket() { # mkmarket <dir> <json-body-for-plugins-array> [pluginRoot]
  mkdir -p "$1/.cursor-plugin"
  printf '{ "name": "fx", "metadata": { "pluginRoot": "%s" }, "plugins": [%s] }\n' \
    "${3:-plugins}" "$2" >"$1/.cursor-plugin/marketplace.json"
}

# 1. a well-formed marketplace with two plugins
f_ok="$work/f_ok"
mkmarket "$f_ok" '{"name":"alpha","source":"alpha"},{"name":"beta","source":"beta"}'
mkplugin "$f_ok/plugins/alpha" alpha
mkplugin "$f_ok/plugins/beta" beta

# 2. empty plugins/ directory, no marketplace.json
f_empty="$work/f_empty"; mkdir -p "$f_empty/plugins"

# 3. marketplace declaring no plugins at all
f_noplugins="$work/f_noplugins"; mkmarket "$f_noplugins" ''

# 4. a plugin name that tries to escape the destination root
f_badname="$work/f_badname"
mkmarket "$f_badname" '{"name":"../../pwned","source":"alpha"},{"name":"alpha","source":"alpha"}'
mkplugin "$f_badname/plugins/alpha" alpha

# 5. a plugin source that tries to escape the plugin root
f_badsrc="$work/f_badsrc"
mkmarket "$f_badsrc" '{"name":"escapee","source":"../../../etc"},{"name":"alpha","source":"alpha"}'
mkplugin "$f_badsrc/plugins/alpha" alpha

# 6. a pluginRoot that escapes the source repo
f_badroot="$work/f_badroot"; mkmarket "$f_badroot" '{"name":"a","source":"a"}' '../../..'

# 7. a marketplace entry with no name key at all
f_noname="$work/f_noname"; mkmarket "$f_noname" '{"source":"alpha"}'
mkplugin "$f_noname/plugins/alpha" alpha

# 8. plugins/ fallback layout containing a SYMLINK to a plugin outside plugins/
f_link="$work/f_link"
mkplugin "$f_link/plugins/real" real
mkplugin "$f_link/vendor/linked" linked
ln -s ../vendor/linked "$f_link/plugins/linked"

# 9. prefix-related names, to pin enumeration order
f_sort="$work/f_sort"
for n in ai ai-briefing docs docs-hygiene; do mkplugin "$f_sort/plugins/$n" "$n"; done

# 10. a single-plugin repo
f_single="$work/f_single"; mkplugin "$f_single" solo

# --- cases --------------------------------------------------------------------

printf 'sync-local regression suite\n'
printf 'bash: %s\n' "$(bash --version | head -1)"
if [[ "$have_pwsh" -eq 1 ]]; then
  printf 'pwsh: %s\n\n' "$(pwsh --version)"
else
  printf 'pwsh: NOT INSTALLED (PowerShell half will be skipped)\n\n'
fi

printf 'happy path\n'
assert_twins repo-dry-run 0 --dry-run "$repo_root" -- -Source "$repo_root" -DryRun
assert_twins marketplace 0 --dry-run "$f_ok" -- -Source "$f_ok" -DryRun

printf 'failures must not look like success\n'
assert_twins missing-source 1 --dry-run "$work/does-not-exist" -- -Source "$work/does-not-exist" -DryRun
assert_twins empty-plugins-dir 1 --dry-run "$f_empty" -- -Source "$f_empty" -DryRun
assert_twins empty-plugins-array 1 --dry-run "$f_noplugins" -- -Source "$f_noplugins" -DryRun
assert_twins nameless-entry 1 --dry-run "$f_noname" -- -Source "$f_noname" -DryRun
assert_twins plugin-root-escape 1 --dry-run "$f_badroot" -- -Source "$f_badroot" -DryRun
assert_twins single-filter-miss 1 --dry-run "$f_single" nomatch -- -Source "$f_single" -Plugin nomatch -DryRun

printf 'traversal is refused on both sides\n'
assert_twins name-escape 0 --dry-run "$f_badname" -- -Source "$f_badname" -DryRun
assert_twins source-escape 0 --dry-run "$f_badsrc" -- -Source "$f_badsrc" -DryRun

printf 'enumeration\n'
assert_twins symlinked-plugin 0 --dry-run "$f_link" -- -Source "$f_link" -DryRun
assert_twins prefix-sort-order 0 --dry-run "$f_sort" -- -Source "$f_sort" -DryRun

# --- content assertions -------------------------------------------------------

printf 'output content\n'
h="$work/h.content"; mkdir -p "$h"

o="$work/c.badname"; run_sh "$h" "$o" --dry-run "$f_badname" || true
assert_contains "escaping name is skipped, not synced" "$o" '(invalid plugin name)'
assert_absent   "escaping name never reaches the sync list" "$o" 'Would sync (2)'

o="$work/c.badsrc"; run_sh "$h" "$o" --dry-run "$f_badsrc" || true
assert_contains "escaping source is skipped" "$o" '(source escapes plugin root)'
assert_contains "the sibling plugin still syncs" "$o" 'alpha'

o="$work/c.noname"; run_sh "$h" "$o" --dry-run "$f_noname" || true
assert_absent "a nameless entry does not raise a Python traceback" "$o.err" 'Traceback'
assert_absent "a nameless entry does not raise KeyError" "$o.err" 'KeyError'

o="$work/c.sort"; run_sh "$h" "$o" --dry-run "$f_sort" || true
assert_contains "prefix names keep basename sort order" "$o" 'ai, ai-briefing, docs, docs-hygiene'

o="$work/c.dry"; run_sh "$h" "$o" --dry-run "$f_ok" || true
assert_contains "a dry run says it would sync" "$o" 'Would sync'
assert_absent   "a dry run never claims it synced" "$o" 'Synced ('

# --ref with no value is bash-only: pwsh's parameter binder owns that path.
rc=0; run_sh "$h" "$work/c.ref" --dry-run "$f_ok" --ref || rc=$?
if [[ "$rc" -eq 2 ]]; then ok "--ref with no value exits 2"; else
  not_ok "--ref with no value" "expected exit 2, got $rc"
fi
assert_contains "--ref with no value explains itself" "$work/c.ref.err" 'Missing value for --ref'

# --- real (non-dry) sync: the destination must be a real directory ------------

printf 'real sync\n'
h="$work/h.real"; mkdir -p "$h"
run_sh "$h" "$work/r.link" "$f_link" || true
linked="$h/.cursor/plugins/local/linked"
if [[ -L "$linked" ]]; then
  not_ok "a symlinked plugin installs as a real directory" "installed a symlink instead"
elif [[ -f "$linked/.cursor-plugin/plugin.json" ]]; then
  ok "a symlinked plugin installs as a real directory"
else
  not_ok "a symlinked plugin installs as a real directory" "destination missing or empty"
fi

if [[ "$have_pwsh" -eq 1 ]]; then
  h="$work/h.real.ps"; mkdir -p "$h"
  run_ps "$h" "$work/r.link.ps" -Source "$f_link" || true
  linked="$h/.cursor/plugins/local/linked"
  if [[ -L "$linked" ]]; then
    not_ok "pwsh: a symlinked plugin installs as a real directory" "installed a symlink"
  elif [[ -f "$linked/.cursor-plugin/plugin.json" ]]; then
    ok "pwsh: a symlinked plugin installs as a real directory"
  else
    not_ok "pwsh: a symlinked plugin installs as a real directory" "destination missing"
  fi
fi

# --- summary ------------------------------------------------------------------

printf '\n%s\n' "----------------------------------------"
printf 'passed %d, failed %d, skipped %d\n' "$pass" "$fail" "$skip"
if [[ "$fail" -gt 0 ]]; then
  printf 'failing:\n'
  for n in "${failed_names[@]}"; do printf '  - %s\n' "$n"; done
  exit 1
fi
printf 'all assertions passed\n'
