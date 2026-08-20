#!/usr/bin/env bash
# PreToolUse(Bash): stop destructive and production-touching commands.
#
# Two verdicts:
#   deny     - the command is destructive with no legitimate agent use case.
#   escalate - the command may be correct, but a human owns the decision. This
#              emits permissionDecision "ask", which raises a permission prompt.
#
# This enforces the approval gates in CLAUDE.md. It is a backstop and nothing
# more. It matches command text, so it will miss tooling it does not know by
# name, and a determined evasion beats it. Tune the patterns to your stack;
# keep them narrow enough that ordinary work never trips them.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

CMD="$(json_get "tool_input.command")"
[ -z "$CMD" ] && CMD="$HOOK_INPUT" # degraded mode: match against raw input

# Normalize before matching: lowercase, join backslash line continuations, and
# collapse runs of whitespace. Without this, `rm -rf \<newline> /` evades every
# pattern below, because grep works a line at a time.
lc="$(printf '%s' "$CMD" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -e ':a' -e '/\\$/{N;s/\\\n//;ba' -e '}' \
  | tr '\n' ' ' \
  | tr -s '[:space:]' ' ')"

match() { printf '%s' "$lc" | grep -Eq -- "$1"; }

# A path argument that means "somewhere catastrophic". Covers the bare form and
# the trailing slash, glob, quote, and variable forms.
DANGER_PATH='(^|[[:space:]]|["'"'"'])(/|~|\$\{?home\}?|\.\.)(["'"'"']|/[[:space:]"'"'"']|/?\*|[[:space:]]|/?$)'

# --- Deny: destructive, no legitimate autonomous use -------------------------

if match 'rm[[:space:]]' &&
   match '(-[a-z]*r[a-z]*f|-[a-z]*f[a-z]*r|--recursive|--force)' &&
   match "$DANGER_PATH"; then
  deny "Recursive delete targeting a root, home, or parent path. Refusing. Name the exact directory instead."
fi

# A recursive delete of something outside the project, but not the whole tree.
# Deleting ~/Documents or /etc/foo is not obviously wrong, but nobody should do
# it without being asked.
if match 'rm[[:space:]]' &&
   match '(-[a-z]*r[a-z]*f|-[a-z]*f[a-z]*r|--recursive|--force)' &&
   match '(^|[[:space:]]|["'"'"'])(~|\$\{?home\}?|/(etc|usr|var|bin|sbin|opt|library|system|users|home))/'; then
  escalate "Recursive delete of a path outside the project. Confirm the exact target before approving."
fi

match 'git[[:space:]]+(-c[[:space:]]+[^[:space:]]+[[:space:]]+)*push[[:space:]]+.*(--force([[:space:]]|$)|--force-with-lease|[[:space:]]-f([[:space:]]|$))' &&
  escalate "Force push rewrites shared history. Confirm the branch is yours and unshared before approving."

match 'git[[:space:]]+(reset[[:space:]]+--hard|clean[[:space:]]+-[a-z]*f)' &&
  escalate "This discards uncommitted work permanently. Confirm nothing valuable is unstaged."

match '(drop[[:space:]]+(database|table|schema)|truncate([[:space:]]+table)?[[:space:]]+[a-z_."]+)' &&
  deny "Destructive schema or data operation. Route it through a reviewed migration and the /release gate."

# No WHERE anywhere in the command. A WHERE in an unrelated part of the same
# command line will suppress this; that is the accepted cost of a text matcher.
match 'delete[[:space:]]+from[[:space:]]+[a-z_."]' && ! match 'where' &&
  deny "DELETE with no WHERE clause. Add a predicate or run it as a reviewed migration."

match 'update[[:space:]]+[a-z_."]+[[:space:]]+set[[:space:]]' && ! match 'where' &&
  deny "UPDATE with no WHERE clause."

match 'terraform[[:space:]]+destroy' &&
  deny "Infrastructure destruction requires a human to run it. Not an agent operation."

match '(curl|wget)[[:space:]][^|]*\|[[:space:]]*(sudo[[:space:]]+(-[a-z]+[[:space:]]+)*)?(bash|sh|zsh|python3?|perl|ruby|node)([[:space:]]|$)' &&
  deny "Piping a download into an interpreter. Download it, read it, then run it."

match 'chmod[[:space:]]+(-[a-z]+[[:space:]]+)*(0?777|a\+rwx)([[:space:]]|$)' &&
  deny "World-writable permissions. Use the narrowest mode that works."

match '(mkfs|dd[[:space:]]+[^|]*of=/dev/|shred[[:space:]]|find[[:space:]]+/[[:space:]].*-delete)' &&
  deny "Destroys a device or bulk-deletes from the filesystem root."

# --- Escalate: legitimate, but a human owns the call -------------------------

match 'docker[[:space:]]+(compose|-compose)[[:space:]]+down.*(-v([[:space:]]|$)|--volumes)' &&
  escalate "This removes the compose volumes, which destroys the local database and any other persisted state."

match 'docker[[:space:]]+volume[[:space:]]+(rm|prune)' &&
  escalate "Deleting Docker volumes destroys whatever data they hold."

match '(kubectl|helm)[[:space:]]+.*(delete|uninstall)' &&
  escalate "Deleting a live workload. Confirm the cluster and namespace first."

match 'kubectl[[:space:]]+.*(--context|--namespace)[[:space:]]*[= ]?[a-z-]*(prod|production)' &&
  escalate "Command targets a production cluster."

match '(prod|production)' && match '(psql|mysql|mongosh|redis-cli|aws[[:space:]]+rds|flyway|alembic|prisma[[:space:]]+migrate)' &&
  escalate "Command appears to target a production datastore."

match 'redis-cli[[:space:]]+.*(flushall|flushdb)' &&
  escalate "This empties the Redis instance."

match 'terraform[[:space:]]+apply.*-auto-approve' &&
  escalate "Applying infrastructure changes without a plan review."

match '((npm|pnpm|yarn)[[:space:]]+publish|cargo[[:space:]]+publish|twine[[:space:]]+upload|gh[[:space:]]+release[[:space:]]+create)' &&
  escalate "Publishing is irreversible once the artifact is public."

match '(aws|gcloud|az)[[:space:]]+.*([[:space:]](delete|destroy|terminate|rm)([[:space:]]|$))' &&
  escalate "Cloud resource deletion."

match 'git[[:space:]]+(-c[[:space:]]+[^[:space:]]+[[:space:]]+)*push[[:space:]]+.*(origin[[:space:]]+)?(main|master|release)([[:space:]]|$)' &&
  escalate "Direct push to a protected branch. Open a pull request instead unless told otherwise."

exit 0
