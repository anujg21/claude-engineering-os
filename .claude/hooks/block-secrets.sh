#!/usr/bin/env bash
# PreToolUse(Write|Edit): refuse to write credential material into the repository.
#
# Matches on shapes that are almost never false positives: provider key prefixes,
# PEM private key headers, and assignments of a literal password or token. Placeholder
# values are allowed so that examples and templates still work.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

CONTENT="$(json_get "tool_input.content")"
[ -z "$CONTENT" ] && CONTENT="$(json_get "tool_input.new_string")"
[ -z "$CONTENT" ] && exit 0

FILE="$(json_get "tool_input.file_path")"

# Placeholders that should never be blocked.
if printf '%s' "$CONTENT" | grep -Eqi 'your[-_]?(api[-_]?)?key|<[a-z_ -]+>|xxxx+|changeme|example\.com|placeholder|\$\{[A-Z_]+\}'; then
  SAFE_PLACEHOLDER=1
else
  SAFE_PLACEHOLDER=0
fi

hit() {
  printf '%s' "$CONTENT" | grep -Eq -- "$1"
}

REASON=""
hit 'AKIA[0-9A-Z]{16}'                              && REASON="an AWS access key id"
hit 'ASIA[0-9A-Z]{16}'                              && REASON="an AWS session key id"
hit '(gh[pousr]_[A-Za-z0-9]{30,})'                  && REASON="a GitHub token"
hit 'sk-(ant-)?[A-Za-z0-9_-]{20,}'                  && REASON="an API secret key"
hit 'xox[baprs]-[A-Za-z0-9-]{10,}'                  && REASON="a Slack token"
hit '\-\-\-\-\-BEGIN [A-Z ]*PRIVATE KEY'            && REASON="a private key"
hit 'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.'   && REASON="a signed JWT"

if [ -z "$REASON" ] && [ "$SAFE_PLACEHOLDER" -eq 0 ]; then
  hit '(password|passwd|secret|token|api[_-]?key|private[_-]?key)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{12,}["'"'"']' &&
    REASON="a hardcoded credential"
fi

if [ -n "$REASON" ]; then
  deny "This write contains what looks like $REASON${FILE:+ (target: $FILE)}. Secrets never enter the repository. Reference an environment variable or a secret manager, and if the value is already live, rotate it."
fi

exit 0
