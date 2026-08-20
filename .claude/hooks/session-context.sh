#!/usr/bin/env bash
# SessionStart: put the project's current state in front of Claude before it does anything.
#
# This is the context-recovery mechanism for long-running work. A session that
# starts cold still knows what is in flight, what is blocked, and what branch it
# is on, without anyone re-explaining it.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$DIR/../.." && pwd)}"
STATE="$ROOT/docs/project/STATE.md"

out=""

if [ -f "$STATE" ]; then
  out+="Current project state (docs/project/STATE.md, first 60 lines):"$'\n'
  out+="$(head -n 60 "$STATE")"$'\n\n'
  out+="Read the full file before planning. Update it before this session ends."$'\n'
else
  out+="No docs/project/STATE.md yet. If this project has ongoing work, run /project-state to create it."$'\n'
fi

if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  branch="$(git -C "$ROOT" branch --show-current 2>/dev/null)"
  dirty="$(git -C "$ROOT" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
  out+=$'\n'"Git: branch ${branch:-detached}, ${dirty} uncommitted file(s)."$'\n'
fi

if [ -d "$ROOT/docs/decisions" ]; then
  proposed="$(grep -rl '^status:[[:space:]]*proposed' "$ROOT/docs/decisions" 2>/dev/null | wc -l | tr -d ' ')"
  [ "$proposed" != "0" ] && out+="ADRs awaiting a decision: $proposed. See docs/decisions/README.md."$'\n'
fi

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$(json_escape "$out")"
