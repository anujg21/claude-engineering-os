#!/usr/bin/env bash
# The single check that decides whether the code works.
#
# Everything in this system treats a passing run of this script as the definition of
# done. That is only true if the script actually runs the project's real checks, so
# replace the auto-detection below with explicit commands as soon as the project has
# them. Explicit beats clever here.
#
# Usage:
#   ./scripts/verify.sh            run everything
#   ./scripts/verify.sh --quiet    only print failures (use from a Stop hook)
#   ./scripts/verify.sh --fast     skip the slow suites
#   ./scripts/verify.sh --hook     quiet, and exit 2 on failure so a Stop hook blocks

set -uo pipefail

QUIET=0
FAST=0
HOOK=0
for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=1 ;;
    --fast)  FAST=1 ;;
    --hook)  HOOK=1; QUIET=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

# A Stop hook only blocks the turn on exit code 2. Exit 1 is reported as an
# error and the turn ends anyway, which would make the gate look like it works
# while letting failing work through.
fail_code() { [ "$HOOK" -eq 1 ] && echo 2 || echo 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

FAILED=()
RAN=0

say() { [ "$QUIET" -eq 1 ] || printf '%s\n' "$*"; }

# run <label> <command...>
run() {
  local label="$1"; shift
  RAN=$((RAN + 1))
  say ""
  say "=== $label ==="
  local out status
  out="$("$@" 2>&1)"
  status=$?
  if [ $status -ne 0 ]; then
    FAILED+=("$label")
    printf '\n=== FAILED: %s ===\n%s\n' "$label" "$out"
  else
    say "$out"
    say "--- ok: $label"
  fi
  return 0
}

has() { command -v "$1" >/dev/null 2>&1; }

# Look inside the "scripts" object, not the whole file. A top-level key with the
# same name (electron-builder's "build", for instance) is not an npm script, and
# running it produces a false failure that blocks every phase of this system.
script_exists() {
  [ -f package.json ] || return 1
  if has jq; then
    jq -e --arg s "$1" '.scripts[$s] // empty' package.json >/dev/null 2>&1
  elif has python3; then
    python3 -c 'import json,sys; sys.exit(0 if json.load(open("package.json")).get("scripts",{}).get(sys.argv[1]) else 1)' "$1" 2>/dev/null
  else
    sed -n '/"scripts"[[:space:]]*:/,/}/p' package.json | grep -q "\"$1\"[[:space:]]*:"
  fi
}

# --- Project-defined entry points take precedence --------------------------------

if [ -f Makefile ] && grep -qE '^(verify|check):' Makefile; then
  # Take the target from the same match that gated this branch. Re-deriving it
  # with a looser pattern can pick up an unrelated earlier target.
  target="$(grep -oE '^(verify|check):' Makefile | head -n1 | tr -d ':')"
  run "make $target" make "$target"

# --- Node / TypeScript -----------------------------------------------------------

elif [ -f package.json ]; then
  pm="npm"
  [ -f pnpm-lock.yaml ] && pm="pnpm"
  [ -f yarn.lock ] && pm="yarn"
  [ -f bun.lockb ] && pm="bun run"

  script_exists "lint"      && run "lint" $pm run lint
  script_exists "typecheck" && run "typecheck" $pm run typecheck
  script_exists "build"     && [ "$FAST" -eq 0 ] && run "build" $pm run build
  script_exists "test"      && run "test" $pm test

# --- Python ----------------------------------------------------------------------

elif [ -f pyproject.toml ] || [ -f setup.py ] || [ -f requirements.txt ]; then
  has ruff  && run "ruff" ruff check .
  has mypy  && [ -f mypy.ini -o -f pyproject.toml ] && run "mypy" mypy .
  has pytest && run "pytest" pytest -q

# --- Go --------------------------------------------------------------------------

elif [ -f go.mod ]; then
  run "go vet" go vet ./...
  run "go test" go test ./...

# --- Rust ------------------------------------------------------------------------

elif [ -f Cargo.toml ]; then
  run "clippy" cargo clippy -- -D warnings
  run "test" cargo test
fi

# --- Nothing to run --------------------------------------------------------------

if [ "$RAN" -eq 0 ]; then
  cat >&2 <<'EOF'
verify.sh found no checks to run.

This is the check that every phase of this system depends on. Until it runs something
real, "done" means nothing. Edit scripts/verify.sh and call the project's actual lint,
type check, and test commands.
EOF
  exit 1
fi

if [ ${#FAILED[@]} -gt 0 ]; then
  printf '\nverify.sh: %d check(s) failed: %s\n' "${#FAILED[@]}" "${FAILED[*]}" >&2
  exit "$(fail_code)"
fi

say ""
say "verify.sh: all $RAN check(s) passed."
exit 0
