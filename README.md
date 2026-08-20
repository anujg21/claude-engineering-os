# claude-engineering-os

A repository template that gives Claude Code a working method: phases that produce
documents, standards that load only when relevant, reviews done by an agent that did not
write the code, and hooks that block the dangerous commands.

Technology-agnostic. Works for a new project or an existing one.

## Why

Claude starts every session with no memory and a context window that gets worse as it
fills. Without structure it solves the wrong problem well, drops constraints nobody wrote
down, and says work is done without checking.

## Install

```bash
git clone <this repo> my-project && cd my-project
rm -rf .git && git init
./scripts/setup.sh
```

Then do these four things before any real work:

1. Make `scripts/verify.sh` run your actual lint, types, and tests. Everything else
   depends on it.
2. Put your build and run commands in `CLAUDE.md`.
3. Add your deploy and migration tooling to `.claude/hooks/guard-commands.sh`.
4. Start Claude Code, run `/context`, confirm CLAUDE.md and the rules loaded.

New project: run `/discovery`. Existing codebase: run `/adopt`.

## The flow

```
/discovery   idea to brief and requirements
/architecture  shape it, write the ADRs, get it reviewed      <- you approve
/design      contract, data, failure modes, per feature
/plan        ordered tasks, each with a check
/implement   one task at a time, verified
/review      fresh context reads the diff
/security-review  if it touches auth, secrets, input, or user data
/production-readiness  GO or NO-GO with evidence              <- you approve
/release     prepares, then stops and asks                    <- you approve
/operate     when it breaks
```

Skip what you do not need. A one-line fix goes straight to `/implement` and `/review`.

## What is in here

```
CLAUDE.md      standing rules, 114 lines
.claude/
  rules/       standards, most load only when you touch matching files
  skills/      14 procedures, loaded when invoked
  agents/      4 read-only reviewers
  hooks/       session context, command guard, secret guard, formatter
docs/          lifecycle, principles, ADRs, runbooks, project state
templates/     11 document templates
scripts/       verify.sh, new-adr.sh, setup.sh
```

## Next

- [docs/GUIDE.md](docs/GUIDE.md) how to actually use it, with two worked examples.
- [docs/engineering/lifecycle.md](docs/engineering/lifecycle.md) every phase in detail.
- [docs/engineering/system-design.md](docs/engineering/system-design.md) why it is built
  this way, and what was left out.
