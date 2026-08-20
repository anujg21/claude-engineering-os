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

# json_escape <string> -> JSON string body, newlines preserved as \n escapes.
# Control characters are stripped: an unescaped one makes the whole decision
# invalid JSON, and Claude Code then discards the verdict and runs the command.
json_escape() {
  printf '%s' "$1" \
    | tr -d '\000-\010\013\014\016-\037' \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e 's/\r//g' \
    | awk 'BEGIN{ORS=""} {printf "%s\\n", $0}'
}

# Valid permissionDecision values are allow, deny, ask, and defer. Anything else
# fails schema validation, and a failed decision is dropped: the tool call then
# proceeds as though the hook said nothing. Do not invent a fifth verdict here.
_decide() { # _decide <decision> <reason>
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' \
    "$1" "$(json_escape "$2")"
  exit 0
}

# deny <reason>     block the tool call outright
deny() { _decide deny "$1"; }

# escalate <reason> put the decision in front of the human as a permission prompt
escalate() { _decide ask "$1"; }
