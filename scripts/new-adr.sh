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

if [ -z "$slug" ]; then
  echo "that title has no letters or digits in it, so there is no filename to build" >&2
  exit 2
fi

FILE="$DIR/$num-$slug.md"
[ -e "$FILE" ] && { echo "already exists: $FILE" >&2; exit 1; }

TODAY="$(date +%Y-%m-%d)"

# Escape the characters that are special on the replacement side of s///.
# Without this, a title containing "/" aborts sed (leaving a zero-byte ADR that
# the script still reports as created) and "&" expands to the matched text.
esc_title="$(printf '%s' "$TITLE" | sed -e 's/[\\/&]/\\&/g')"

if ! sed -e "s/^number: NNNN/number: $num/" \
         -e "s/^title: <short imperative title>/title: $esc_title/" \
         -e "s/^date: <YYYY-MM-DD>/date: $TODAY/" \
         -e "s/^# NNNN\. <title>/# $num. $esc_title/" \
         "$TEMPLATE" > "$FILE"; then
  rm -f "$FILE"
  echo "failed to write $FILE" >&2
  exit 1
fi

if [ ! -s "$FILE" ]; then
  rm -f "$FILE"
  echo "wrote an empty ADR, refusing to keep it. Check the title for unusual characters." >&2
  exit 1
fi

if [ -f "$INDEX" ]; then
  printf '| [%s](%s-%s.md) | %s | proposed | %s |\n' \
    "$num" "$num" "$slug" "$TITLE" "$TODAY" >> "$INDEX"
fi

echo "$FILE"
echo "Status is 'proposed'. Set it to 'accepted' once a human agrees."
