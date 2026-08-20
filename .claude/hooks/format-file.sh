#!/usr/bin/env bash
# PostToolUse(Write|Edit): format the file that was just written.
#
# Formatting is mechanical, so it belongs in a hook rather than in an instruction
# that Claude has to remember. This hook never blocks: if no formatter is
# configured for the file type, it exits quietly.
#
# Projects with their own entry point should put it in scripts/format.sh; this
# hook prefers that over guessing.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

FILE="$(json_get "tool_input.file_path")"
[ -z "$FILE" ] && exit 0
[ -f "$FILE" ] || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$DIR/../.." && pwd)}"

if [ -x "$ROOT/scripts/format.sh" ]; then
  "$ROOT/scripts/format.sh" "$FILE" >/dev/null 2>&1
  exit 0
fi

run() { command -v "$1" >/dev/null 2>&1 && "$@" >/dev/null 2>&1; }

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.css|*.json|*.md|*.yaml|*.yml)
    run npx --no-install biome format --write "$FILE" ||
    run npx --no-install prettier --write "$FILE"
    ;;
  *.py)
    run ruff format "$FILE" || run black -q "$FILE"
    ;;
  *.go)
    run gofmt -w "$FILE"
    ;;
  *.rs)
    run rustfmt --edition 2021 "$FILE"
    ;;
  *.sh)
    run shfmt -w "$FILE"
    ;;
  *.tf)
    run terraform fmt "$FILE"
    ;;
esac

exit 0
