---
name: adopt
description: Install the engineering operating system into the current repository. Detects the stack, writes a verify script that runs the project's real checks, adapts the rule globs to the actual layout, and merges with any existing CLAUDE.md instead of overwriting it. Run once per repository.
when_to_use: The user wants to set this system up in a repository, has just installed the plugin, asks how to get started in an existing codebase, or asks what parts of the system this repo is already using.
argument-hint: "[--check to report without writing]"
allowed-tools: Read Glob Grep Bash(git status:*) Bash(git rev-parse:*) Bash(git log:*) Bash(git branch:*) Bash(ls:*) Bash(cat:*) Bash(command -v:*) Bash(chmod +x:*)
---

# Adopt

Install this system into the repository the user is working in. You do the work; the user
should not be copying files or editing globs by hand.

**Never rewrite working code to match a rule. Never overwrite a file the user wrote.**

With `--check`, do steps 1 and 2 and report. Write nothing.

## 1. Find the source files

The system's files come from wherever this skill is installed from:

- Installed as a plugin: they are under `${CLAUDE_PLUGIN_ROOT}`.
- Running from a checkout: the placeholder above is not substituted, so ask the user for
  the path to their clone, or look for `.claude-plugin/plugin.json` nearby.

You need `.claude/rules/`, `hooks/`, `skills/`, `agents/`, `templates/`, `scripts/`,
and `docs/decisions/`. Confirm they exist before writing anything.

## 2. Survey the target repository

Gather all of this before writing. Report it, then write.

- **Is it a git repo, and is the tree clean?** If dirty, say so and offer to continue.
  If it is not a git repo, warn that there is no undo and ask before proceeding.
- **Already adopted?** If `.claude/skills/` or `scripts/verify.sh` exist, switch to
  reporting what is present and what is missing. Do not reinstall over it.
- **Stack and real commands.** Read the manifest (`package.json`, `pyproject.toml`,
  `go.mod`, `Cargo.toml`, `Gemfile`, `Makefile`). Read any existing `CLAUDE.md`,
  `README.md`, and `CONTRIBUTING.md` for the commands the project actually uses. The
  commands written down by the team beat anything you infer from the manifest.
- **Source layout.** Where the code lives, where tests live, and the directories that
  correspond to each rule file. You need real paths, not guesses.
- **Collisions.** Does `CLAUDE.md`, `docs/README.md`, `scripts/README.md`, `templates/`,
  or `docs/architecture.md` already exist?
- **Existing agent instructions.** `AGENTS.md`, `agent.md`, `.cursorrules`, or similar. If
  one is cited as a source of truth, the system defers to it and must say so.

## 3a. External tooling

Before writing anything, learn what the team runs outside git — a ticket tracker, a wiki,
a chat tool — so the rest of the system can point at it correctly instead of assuming
git is the only system in play.

- **Scan for signals first.** Commit messages matching `[A-Z]{2,}-\d+` (Jira/Linear
  keys), env var names like `SLACK_WEBHOOK*`, `CONFLUENCE_*`, `JIRA_*`, `TEAMS_WEBHOOK*`
  in `.env.example` or CI config, and any servers already declared in `.mcp.json`. Use
  what you find as suggested defaults in the question below, never as a silent answer —
  repo evidence can be stale or wrong.
- **Ask one question**, multiSelect, escape hatch first:
  `["None — just git", "Jira/Linear (tickets)", "Confluence/Notion (docs)", "Slack/Teams (chat)", "Separate ADR tool"]`
- **"None — just git" is a hard stop.** Write nothing for this step, add nothing to the
  step 6 report. Never scaffold anything on the no-tools path, the same way you never
  overwrite a file the user wrote.
- **For each tool selected**, ask one follow-up covering direction (repo stays source of
  truth with a one-way mirror out / repo reads it read-only / not connected, just
  referenced by URL) and mechanism (CLI / MCP server / manual / none yet). Offer a CLI
  first wherever one exists for that tool (e.g. `acli` covers Jira, Confluence, and
  Bitbucket) — an MCP server's tool schema costs context on every turn whether it's used
  or not, a CLI invoked through Bash costs nothing until called. Reserve MCP for cases a
  CLI can't cover: a session doing enough back-and-forth that Bash round-trips are the
  bottleneck, or a per-user OAuth audit trail a shared CLI credential can't give.
- **Never write `.mcp.json` or touch credentials here.** That is a separate,
  human-approved step per `docs/engineering/mcp.md` and the CLAUDE.md approval gate on
  third-party vendors and credentials. This step records intent; mcp.md covers mechanism.
- If at least one tool was selected, write `docs/project/integrations.md` from
  `templates/integrations.md`, filled with what was selected. If "None — just git" was
  chosen, do not create this file.

## 3. Write the verify script

This is the most important file you will write, and the one thing you must not leave
generic. Everything else in the system treats a passing run as the definition of done.

Write `scripts/verify.sh` with the project's actual commands, in this order: lint, then
types, then the fast tests. Support three modes:

- default: lint, types, fast tests
- `--fast`: lint only
- `--full`: adds slower suites, integration tests, anything needing a live dependency

Rules for what goes in the default path:

- Only commands that pass right now. Run each one first and check. A default path that
  fails on a clean checkout teaches Claude that red is normal, which destroys the signal
  the whole system depends on.
- If a check is noisy or unconfigured, put it behind `--full` and record it as an open
  item in `STATE.md` rather than dropping it silently.
- Scope commands to the source and test directories. Never let a check walk a vendored
  dependency directory or a virtualenv.
- Anything needing a database, a broker, or Docker goes behind `--full`.

Then run it and show the user the output.

## 4. Write the rest

- `.claude/rules/`: copy the six rule files, then rewrite each `paths:` block to the real
  layout you found. A glob that matches nothing is a rule that never loads.
- `templates/`: copy as is, unless the repo already has a root `templates/` used for
  something else. If it does, put them in `docs/templates/` and tell the user.
- `scripts/new-adr.sh` and `scripts/setup.sh`: copy. Make them executable.
- `docs/`: create only the directories the system writes into, plus `docs/decisions/`
  with ADR 0001 and the index.
- `.claude/settings.json`: copy. If one already exists, merge the permission rules and
  keep theirs on any conflict. Never touch `settings.local.json`.
- Hooks: only when running from a checkout rather than the plugin, since the plugin
  already provides them. Adapt the patterns in `guard-commands.sh` to this project's real
  tooling: its deploy command, migration tool, production context names, and anything that
  destroys local state, such as a compose command that removes volumes.
- `docs/project/STATE.md`: fill it from the repo's real state, using the recent commits
  and any existing status or backlog document. It has to be true on day one.
- `.gitignore`: append entries for `.env`, `.env.*`, `*.pem`, `*.key`, and `secrets/` if
  they are missing. The write hook catches common credential shapes, but this is the
  control that actually keeps them out of history.

## 5. Merge, never overwrite

- **`CLAUDE.md` exists:** append a section of about 40 lines, no more: the routing table,
  the approval gates, and the handful of operating rules. Leave everything they wrote
  alone. If another file is the cited source of truth, state in your section that it
  outranks the workflow rules on structural questions.
- **`CLAUDE.md` does not exist:** write the full one, then add the project's real build
  and test commands to it.
- **`docs/README.md` or `scripts/README.md` exist:** append a short pointer. Do not
  replace them.
- **`docs/architecture.md` or similar exists:** treat it as the architecture overview.
  Do not create a second one. Point the architecture skill at theirs.

## 6. Report

Tell the user, in this order: what you wrote, what you merged into, what you deliberately
left alone, and what needs a human decision. If `docs/project/integrations.md` was
written, name it and what it records. Then the two things that matter:

1. The verify command, and whether it passes right now.
2. What to do next. `/discovery` for a new feature, or just keep working and let the rules
   and guards do their job. If they are not sure which of those fits, point them at
   `/guide`.

Offer to revert. Everything you did is additive except the appends, so it is one
`git checkout` of the named files plus deleting the new paths.

## What not to do

- Do not reformat, refactor, or fix anything in the existing codebase.
- Do not write ADRs during adoption. That is a separate pass, worth doing after the system
  has been used on real work for a week, and the user should choose to do it.
- Do not add a lint or type gate that the current code fails.
- Do not enable an autoformatter the project has not configured.
- Do not create documentation for its own sake. Empty directories with README files
  explaining what would go in them are noise.
- Do not write `.mcp.json` or any credential during the external-tooling step. Record
  intent in `docs/project/integrations.md` only; live access is a separate, human-run
  step per `docs/engineering/mcp.md`.
