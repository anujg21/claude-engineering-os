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

set -uo pipefail

QUIET=0
FAST=0
for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=1 ;;
    --fast)  FAST=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

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
script_exists() { [ -f package.json ] && grep -q "\"$1\"" package.json; }

# --- Project-defined entry points take precedence --------------------------------

if [ -f Makefile ] && grep -qE '^(verify|check):' Makefile; then
  target="$(grep -oE '^(verify|check)' Makefile | head -n1)"
  run "make $target" make "$target"

# --- Node / TypeScript -----------------------------------------------------------

elif [ -f package.json ]; then
  pm="npm"
  [ -f pnpm-lock.yaml ] && pm="pnpm"
  [ -f yarn.lock ] && pm="yarn"
  [ -f bun.lockb ] && pm="bun"

  script_exists "lint"      && run "lint" "$pm" run lint
  script_exists "typecheck" && run "typecheck" "$pm" run typecheck
  script_exists "build"     && [ "$FAST" -eq 0 ] && run "build" "$pm" run build
  script_exists "test"      && run "test" "$pm" test

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
  exit 1
fi

say ""
say "verify.sh: all $RAN check(s) passed."
exit 0
