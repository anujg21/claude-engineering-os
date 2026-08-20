#!/usr/bin/env bash
# PreToolUse(Write|Edit): refuse to write credential material into the repository.
#
# Matching is per line, and a line that looks like a placeholder is excused on its
# own rather than excusing the whole file. That distinction matters: an earlier
# version let a single "<div>" or "example.com" anywhere in a file disable the
# check for every other line in it.
#
# This catches common shapes. It is not a secret scanner, and it cannot see
# content written through Bash redirection. Keep a real scanner in the pipeline.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

FILE="$(json_get "tool_input.file_path")"

# Write uses content, Edit uses new_string, MultiEdit carries an edits array.
CONTENT="$(json_get "tool_input.content")"
[ -z "$CONTENT" ] && CONTENT="$(json_get "tool_input.new_string")"
[ -z "$CONTENT" ] && CONTENT="$(json_get "tool_input.edits")"

# No JSON reader available, or a payload shape we do not recognise. Scan the raw
# input rather than silently passing everything: a scanner that quietly turns
# itself off is worse than no scanner, because the docs still promise it works.
[ -z "$CONTENT" ] && CONTENT="$HOOK_INPUT"

# A line that is clearly illustrative. Applied per line, never file-wide.
PLACEHOLDER='your[-_ ]?(api[-_ ]?)?(key|token|secret|password)|<[a-z]+[-_ ][a-z]+>|xxxx+|changeme|placeholder|example|dummy|redacted|\.\.\.|\$\{?[a-z_]+\}?$|process\.env|os\.environ|getenv'

# Match one pattern against the content, ignoring lines that read as placeholders.
# Sets REASON when a real-looking hit survives.
scan() { # scan <regex> <reason>
  [ -n "$REASON" ] && return 0
  local found
  found="$(printf '%s' "$CONTENT" | grep -Ei -- "$1" 2>/dev/null | grep -Eiv -- "$PLACEHOLDER" 2>/dev/null)"
  [ -n "$found" ] && REASON="$2"
  return 0
}

REASON=""

# Provider-issued credentials. Distinctive enough to match on shape alone.
scan 'AKIA[0-9A-Z]{16}'                                 "an AWS access key id"
scan 'ASIA[0-9A-Z]{16}'                                 "an AWS session key id"
scan 'aws_secret_access_key[[:space:]]*[:=]'            "an AWS secret access key"
scan 'gh[pousr]_[A-Za-z0-9]{30,}'                       "a GitHub token"
scan 'glpat-[A-Za-z0-9_-]{16,}'                         "a GitLab access token"
scan 'sk-(ant-)?[A-Za-z0-9_-]{20,}'                     "an API secret key"
scan 'sk_(live|test)_[A-Za-z0-9]{16,}'                  "a Stripe secret key"
scan 'AIza[0-9A-Za-z_-]{30,}'                           "a Google API key"
scan 'xox[baprs]-[A-Za-z0-9-]{10,}'                     "a Slack token"
scan 'hooks\.slack\.com/services/[A-Za-z0-9/]{20,}'     "a Slack webhook URL"
scan 'npm_[A-Za-z0-9]{30,}'                             "an npm access token"
scan 'pypi-[A-Za-z0-9_-]{20,}'                          "a PyPI token"
scan 'SG\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}'       "a SendGrid API key"
scan 'hvs\.[A-Za-z0-9_-]{20,}'                          "a Vault token"
scan '\-\-\-\-\-BEGIN [A-Z ]*PRIVATE KEY'               "a private key"
scan 'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.'      "a signed JWT"

# A password embedded in a connection string.
scan '[a-z][a-z0-9+.-]*://[^:@/[:space:]]+:[^@/[:space:]]{8,}@' "a password inside a connection URI"

# Generic assignment, quoted or bare. Case-insensitive, because the uppercase
# environment-variable form is the one that actually shows up in leaks.
scan '(password|passwd|secret|token|api[_-]?key|private[_-]?key|access[_-]?key)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{12,}["'"'"']' \
     "a hardcoded credential"
scan '(password|passwd|secret|token|api[_-]?key|private[_-]?key|access[_-]?key)[[:space:]]*=[[:space:]]*[^"'"'"'[:space:]$]{12,}' \
     "a hardcoded credential"

if [ -n "$REASON" ]; then
  deny "This write contains what looks like $REASON${FILE:+ (target: $FILE)}. Secrets never enter the repository. Reference an environment variable or a secret manager, and if the value is already live, rotate it. If this is genuinely an example, make it look like one."
fi

exit 0
