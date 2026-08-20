#!/usr/bin/env bash
# Create the next numbered ADR from the template and add it to the index.
#
# Usage: ./scripts/new-adr.sh "Use PostgreSQL as the primary datastore"

set -uo pipefail

if [ $# -lt 1 ]; then
  echo "usage: $0 \"<decision title>\"" >&2
  exit 2
fi

TITLE="$*"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$ROOT/docs/decisions"
TEMPLATE="$ROOT/templates/adr.md"
INDEX="$DIR/README.md"

[ -f "$TEMPLATE" ] || { echo "missing template: $TEMPLATE" >&2; exit 1; }
mkdir -p "$DIR"

# Next number: highest existing NNNN plus one, starting at 0001.
last=0
for f in "$DIR"/[0-9][0-9][0-9][0-9]-*.md; do
  [ -e "$f" ] || continue
  n="$(basename "$f" | cut -c1-4)"
  n=$((10#$n))
  [ "$n" -gt "$last" ] && last=$n
done
num=$(printf '%04d' $((last + 1)))

slug="$(printf '%s' "$TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' \
  | cut -c1-60)"

FILE="$DIR/$num-$slug.md"
[ -e "$FILE" ] && { echo "already exists: $FILE" >&2; exit 1; }

TODAY="$(date +%Y-%m-%d)"
sed -e "s/^number: NNNN/number: $num/" \
    -e "s/^title: <short imperative title>/title: $TITLE/" \
    -e "s/^date: <YYYY-MM-DD>/date: $TODAY/" \
    -e "s/^# NNNN\. <title>/# $num. $TITLE/" \
    "$TEMPLATE" > "$FILE"

if [ -f "$INDEX" ]; then
  printf '| [%s](%s-%s.md) | %s | proposed | %s |\n' \
    "$num" "$num" "$slug" "$TITLE" "$TODAY" >> "$INDEX"
fi

echo "$FILE"
echo "Status is 'proposed'. Set it to 'accepted' once a human agrees."
