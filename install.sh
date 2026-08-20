#!/usr/bin/env bash
# Copy the engineering operating system into a repository.
#
#   ./install.sh /path/to/repo         install into that repository
#   ./install.sh                       install into the current directory
#   ./install.sh /path/to/repo --uninstall   remove exactly what was installed
#
# This does the mechanical part: copying files that are safe to copy. It never
# overwrites a file that already exists, never guesses your test commands, and
# does not adapt the rule globs to your layout. Run /adopt inside Claude Code
# afterwards for that, since it can read your project and decide properly.
#
# Prefer the plugin if you only want it for yourself:
#   /plugin marketplace add anujg21/claude-engineering-os
#   /plugin install engineering-os@claude-engineering-os
#
# Use this script when the configuration should be committed, so everyone who
# clones the repository gets it without installing anything.

set -uo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="install"
TARGET=""
MANIFEST_NAME=".claude/.engineering-os-manifest"

for arg in "$@"; do
  case "$arg" in
    --uninstall) MODE="uninstall" ;;
    -h|--help) sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "unknown option: $arg" >&2; exit 2 ;;
    *)
      [ -n "$TARGET" ] && { echo "give one target directory, got two: $TARGET and $arg" >&2; exit 2; }
      TARGET="$arg"
      ;;
  esac
done

[ -z "$TARGET" ] && TARGET="$PWD"
if ! RESOLVED="$(cd "$TARGET" 2>/dev/null && pwd)"; then
  echo "no such directory: $TARGET" >&2
  exit 1
fi
TARGET="$RESOLVED"
MANIFEST="$TARGET/$MANIFEST_NAME"

# Refuse to operate on a home directory or a filesystem root under any mode.
# ~/.claude holds personal skills, agents, and settings; this script has no
# business there in either direction.
case "$TARGET" in
  "$HOME"|/) echo "refusing to touch $TARGET. Give the path to a project." >&2; exit 1 ;;
esac

if [ "$TARGET" = "$SRC" ]; then
  echo "That is this repository. Give me the path to the project you want to install into." >&2
  exit 1
fi

# ---------------------------------------------------------------- uninstall

if [ "$MODE" = "uninstall" ]; then
  if [ ! -f "$MANIFEST" ]; then
    cat >&2 <<EOF
Nothing to uninstall: no install manifest at
  $MANIFEST

This script only removes files it recorded writing. If you installed by hand,
remove the files by hand, or use git to revert them.
EOF
    exit 1
  fi

  echo "Removing the engineering OS from $TARGET"
  removed=0
  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    if [ -f "$TARGET/$rel" ]; then
      rm -f "$TARGET/$rel"
      removed=$((removed + 1))
    fi
  done < "$MANIFEST"
  rm -f "$MANIFEST"

  # Clean up directories that are now empty. rmdir refuses non-empty ones, which
  # is exactly the behaviour we want: anything you added survives.
  for d in .claude/skills .claude/agents .claude/rules .claude/hooks .claude \
           templates docs/decisions docs/project/plans docs/project \
           docs/architecture/designs docs/architecture docs/product \
           docs/security docs/operations/runbooks docs/operations/incidents \
           docs/operations/readiness docs/operations docs/engineering docs scripts; do
    find "$TARGET/$d" -type d -empty -delete 2>/dev/null
  done

  echo "  removed $removed file(s)"
  cat <<'EOF'

Anything you or Claude wrote afterwards is still there: ADRs you authored, the
project state file, designs, plans, and any file that already existed when you
installed. Check `git status` and remove what you no longer want.
EOF
  exit 0
fi

# ---------------------------------------------------------------- checks

echo "Installing the engineering OS"
echo "  from: $SRC"
echo "  into: $TARGET"
echo

if git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  dirty="$(git -C "$TARGET" status --porcelain | wc -l | tr -d ' ')"
  if [ "$dirty" != "0" ]; then
    echo "  note: $dirty uncommitted change(s) already in the tree."
    echo "        Commit or stash first if you want a clean diff to review."
    echo
  fi
else
  echo "  warning: not a git repository, so there is no undo."
  echo
fi

if [ -f "$MANIFEST" ]; then
  echo "  Already installed here. Run /adopt --check inside Claude Code to see what is present," >&2
  echo "  or uninstall first: $0 $TARGET --uninstall" >&2
  exit 1
fi

# ---------------------------------------------------------------- copy

written=0
skipped=0
failed=0
: > "$MANIFEST.tmp"

put() { # put <source file> <relative destination>
  local src="$1" rel="$2"
  if [ -e "$TARGET/$rel" ]; then
    echo "  = $rel (yours, left alone)"
    skipped=$((skipped + 1))
    return 0
  fi
  mkdir -p "$(dirname "$TARGET/$rel")"
  if cp "$src" "$TARGET/$rel"; then
    printf '%s\n' "$rel" >> "$MANIFEST.tmp"
    written=$((written + 1))
  else
    echo "  ! failed to write $rel" >&2
    failed=$((failed + 1))
  fi
}

put_tree() { # put_tree <source dir> <relative destination dir>
  local from="$1" to="$2" f rel
  if [ ! -d "$SRC/$from" ]; then
    echo "  ! missing from source: $from" >&2
    failed=$((failed + 1))
    return 1
  fi
  while IFS= read -r f; do
    rel="${f#"$SRC/$from/"}"
    put "$f" "$to/$rel"
  done < <(find "$SRC/$from" -type f ! -name '.DS_Store' | sort)
  echo "  + $to"
}

# In this repository skills, agents, and hooks sit at the root because that is
# where the plugin loader expects them. In a project they belong under .claude/.
put_tree "skills"         ".claude/skills"
put_tree "agents"         ".claude/agents"
put_tree "hooks"          ".claude/hooks"
put_tree ".claude/rules"  ".claude/rules"
put_tree "templates"      "templates"
put_tree "docs/decisions" "docs/decisions"

for s in verify.sh setup.sh new-adr.sh; do
  put "$SRC/scripts/$s" "scripts/$s"
done

put "$SRC/templates/project-settings.json" ".claude/settings.json"

# Plugin-only files mean nothing inside a project.
for junk in ".claude/hooks/hooks.json" "templates/project-settings.json"; do
  if [ -f "$TARGET/$junk" ] && grep -qxF "$junk" "$MANIFEST.tmp"; then
    rm -f "$TARGET/$junk"
    grep -vxF "$junk" "$MANIFEST.tmp" > "$MANIFEST.tmp2" && mv "$MANIFEST.tmp2" "$MANIFEST.tmp"
    written=$((written - 1))
  fi
done

mv "$MANIFEST.tmp" "$MANIFEST"

# Only files this run actually wrote. Marking a script the user already had as
# executable is a modification, however small, and this script promises not to
# make any.
while IFS= read -r rel; do
  case "$rel" in
    *.sh) [ -f "$TARGET/$rel" ] && chmod +x "$TARGET/$rel" ;;
  esac
done < "$MANIFEST"

if [ "$failed" -gt 0 ]; then
  echo >&2
  echo "Install incomplete: $failed file(s) failed to copy. Nothing was overwritten." >&2
  exit 1
fi

# ---------------------------------------------------------------- next

echo
echo "Wrote $written file(s). Left $skipped existing file(s) alone."
cat <<EOF

Two things are still generic and need your project's real details:

  scripts/verify.sh      currently auto-detects; it should run your actual commands
  .claude/rules/*.md     the paths: globs are generic and may match nothing here

Both are what /adopt does properly, because it can read your project first.

Next:
  cd into the project, run \`claude\`, accept the workspace trust prompt, then:

  /adopt

To undo exactly what was written:
  $0 $TARGET --uninstall
EOF
