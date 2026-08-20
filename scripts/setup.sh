#!/usr/bin/env bash
# One-time setup: make the hooks runnable and check their prerequisites.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

echo "Setting up the engineering operating system in $ROOT"
echo

chmod +x "$ROOT"/hooks/*.sh "$ROOT"/.claude/hooks/*.sh "$ROOT"/scripts/*.sh 2>/dev/null
if ls "$ROOT"/hooks/*.sh "$ROOT"/.claude/hooks/*.sh >/dev/null 2>&1; then
  echo "  hooks and scripts are executable"
else
  echo "  no hook scripts found (fine if you installed the plugin, which carries its own)"
fi

if command -v jq >/dev/null 2>&1; then
  echo "  jq found"
elif command -v python3 >/dev/null 2>&1; then
  echo "  python3 found (jq not installed; hooks will use python3)"
else
  echo "  WARNING: neither jq nor python3 is installed."
  echo "  The hooks fall back to coarse text matching without one of them."
  echo "  Install jq:  brew install jq  |  apt-get install jq"
fi

mkdir -p \
  docs/product \
  docs/architecture/designs \
  docs/decisions \
  docs/engineering \
  docs/security \
  docs/operations/runbooks \
  docs/operations/incidents \
  docs/operations/readiness \
  docs/project/plans
echo "  documentation directories present"

if [ ! -f docs/project/STATE.md ]; then
  cp templates/project-state.md docs/project/STATE.md
  echo "  created docs/project/STATE.md from the template"
fi

echo
echo "Checking the verification script:"
if ./scripts/verify.sh --quiet >/dev/null 2>&1; then
  echo "  ./scripts/verify.sh passes"
else
  echo "  ./scripts/verify.sh has nothing to run yet, or is failing."
  echo "  Point it at this project's real lint, type check, and test commands before"
  echo "  starting work. Everything else in this system depends on it."
fi

cat <<'EOF'

Next:
  1. Edit CLAUDE.md and fill in the project's build and run commands.
  2. Adapt scripts/verify.sh to the real checks.
  3. Adapt the patterns in .claude/hooks/guard-commands.sh to your deploy tooling.
  4. Start Claude Code and run /context to confirm CLAUDE.md and the rules loaded.

New project:      run /discovery
Existing project: run /adopt
EOF
