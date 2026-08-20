#!/usr/bin/env bash
# PreToolUse(Bash): stop destructive and production-touching commands.
#
# Two verdicts:
#   deny     - the command is destructive with no legitimate agent use case.
#   escalate - the command may be correct, but a human owns the decision.
#
# This enforces the approval gates in CLAUDE.md. It is a backstop, not a
# substitute for asking. Tune the patterns to your stack; keep them narrow
# enough that ordinary work never trips them.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

CMD="$(json_get "tool_input.command")"
[ -z "$CMD" ] && CMD="$HOOK_INPUT" # degraded mode: match against raw input

lc="$(printf '%s' "$CMD" | tr '[:upper:]' '[:lower:]')"

match() { printf '%s' "$lc" | grep -Eq "$1"; }

# --- Deny: destructive, no legitimate autonomous use -------------------------

match 'rm[[:space:]]+(-[a-z]*[rf][a-z]*[[:space:]]+)+(/|~|\$home|\.\.)([[:space:]]|$)' &&
  deny "Recursive delete of a root, home, or parent path. Refusing. Name the exact directory instead."

match 'git[[:space:]]+push[[:space:]]+.*(--force|-f)([[:space:]]|$)' &&
  escalate "Force push rewrites shared history. Confirm the branch is yours and unshared before approving."

match 'git[[:space:]]+(reset[[:space:]]+--hard|clean[[:space:]]+-[a-z]*f)' &&
  escalate "This discards uncommitted work permanently. Confirm nothing valuable is unstaged."

match '(drop[[:space:]]+(database|table|schema)|truncate[[:space:]]+table)' &&
  deny "Destructive schema or data operation. Route it through a reviewed migration and the /release gate."

match 'delete[[:space:]]+from[[:space:]]+[a-z_."]+[[:space:]]*(;|$)' &&
  deny "Unscoped DELETE with no WHERE clause. Add a predicate or run it as a reviewed migration."

match 'update[[:space:]]+[a-z_."]+[[:space:]]+set[[:space:]]+[^;]*$' &&
  ! match 'where' &&
  deny "Unscoped UPDATE with no WHERE clause."

match 'terraform[[:space:]]+destroy' &&
  deny "Infrastructure destruction requires a human to run it. Not an agent operation."

match 'curl[[:space:]]+[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh)' &&
  deny "Piping a downloaded script into a shell. Download it, read it, then run it."

match 'chmod[[:space:]]+(-[a-z]+[[:space:]]+)*777' &&
  deny "World-writable permissions. Use the narrowest mode that works."

# --- Escalate: legitimate, but a human owns the call -------------------------

match '(kubectl|helm)[[:space:]]+.*(delete|uninstall)' &&
  escalate "Deleting a live workload. Confirm the cluster and namespace first."

match 'kubectl[[:space:]]+.*(--context|--namespace)[[:space:]]*[= ]?[a-z-]*(prod|production)' &&
  escalate "Command targets a production cluster."

match '(prod|production)' && match '(psql|mysql|mongosh|redis-cli|aws[[:space:]]+rds|flyway|alembic|prisma[[:space:]]+migrate)' &&
  escalate "Command appears to target a production datastore."

match 'terraform[[:space:]]+apply.*-auto-approve' &&
  escalate "Applying infrastructure changes without a plan review."

match '(npm|pnpm|yarn)[[:space:]]+publish|cargo[[:space:]]+publish|twine[[:space:]]+upload|gh[[:space:]]+release[[:space:]]+create' &&
  escalate "Publishing is irreversible once the artifact is public."

match '(aws|gcloud|az)[[:space:]]+.*(delete|destroy|terminate|rm)' &&
  escalate "Cloud resource deletion."

match 'git[[:space:]]+push[[:space:]]+.*(origin[[:space:]]+)?(main|master|release)([[:space:]]|$)' &&
  escalate "Direct push to a protected branch. Open a pull request instead unless told otherwise."

exit 0
