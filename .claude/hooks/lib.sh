#!/usr/bin/env bash
# Shared helpers for Claude Code hooks.
#
# Hook input arrives as a single JSON object on stdin. We read it once into
# HOOK_INPUT and pull fields out with whatever JSON reader the machine has.
# If neither jq nor python3 is present, json_get returns empty and callers
# fall back to matching against the raw JSON text, which is coarser but safe.

set -uo pipefail

HOOK_INPUT="$(cat)"

_json_reader=""
if command -v jq >/dev/null 2>&1; then
  _json_reader="jq"
elif command -v python3 >/dev/null 2>&1; then
  _json_reader="python3"
fi

# json_get <dotted.path>  ->  prints value or nothing
json_get() {
  local path="$1"
  case "$_json_reader" in
    jq)
      printf '%s' "$HOOK_INPUT" | jq -r --arg p "$path" '
        getpath($p | split(".")) // empty
      ' 2>/dev/null
      ;;
    python3)
      printf '%s' "$HOOK_INPUT" | python3 -c '
import json, sys
path = sys.argv[1].split(".")
try:
    node = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for key in path:
    if isinstance(node, dict) and key in node:
        node = node[key]
    else:
        sys.exit(0)
if node is None:
    sys.exit(0)
sys.stdout.write(node if isinstance(node, str) else json.dumps(node))
' "$path" 2>/dev/null
      ;;
    *)
      printf ''
      ;;
  esac
}

# json_escape <string> -> JSON string body, newlines preserved as \n escapes
json_escape() {
  printf '%s' "$1" \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e 's/\r//g' \
    | awk 'BEGIN{ORS=""} {printf "%s\\n", $0}'
}

# deny <reason>     block the tool call outright
deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$(json_escape "$1")"
  exit 0
}

# escalate <reason> hand the decision to the human
escalate() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"escalate","permissionDecisionReason":"%s"}}\n' "$(json_escape "$1")"
  exit 0
}
