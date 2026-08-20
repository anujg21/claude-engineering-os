---
name: adopt
description: Bring an existing repository into this engineering system incrementally, without a rewrite. Reconstructs the missing architecture and decision records from the code, then adds the workflow one layer at a time.
when_to_use: This system is being installed into a repository that already has code, or the user wants to apply the lifecycle to a codebase nobody documented. Also use to audit how much of the system a project is actually using.
argument-hint: "[repository path]"
---

# Adopt an existing codebase

The failure mode here is turning a working project into a documentation project. Adoption
is incremental, in this order, and each stage is useful on its own if you stop there.

## Stage 1: make the system safe to use here (an hour)

1. Copy `.claude/`, `templates/`, and `scripts/` into the repository. Keep any existing
   `.claude/` content and merge rather than replace; if the repo already has a CLAUDE.md,
   preserve its project-specific facts and fold the operating rules in around them.
2. Adapt `scripts/verify.sh` to run the project's real checks. This matters more than
   everything else combined, because it is the check that makes every later phase honest.
3. Adapt the patterns in `.claude/hooks/guard-commands.sh` to the project's actual
   deployment and migration tooling.
4. Fill in the commands section of CLAUDE.md with the real build, test, and run commands.
5. Confirm the hooks work: `./scripts/setup.sh`, then start a session and check `/context`.

Stop here and use the system for a week if you want. Everything below is worth more once
you have felt where this codebase actually hurts.

## Stage 2: reconstruct what is already true (a day)

Use `Explore` subagents so this does not consume the main context.

- **Architecture as built.** Map the real components, their dependencies, the datastores,
  and the external integrations. Write `docs/architecture/overview.md` describing what
  exists, not what someone wishes existed. Mark the parts that surprised you.
- **Decisions already made.** Every significant choice in a running system was decided by
  someone, often implicitly. Write ADRs for the load-bearing ones with status `accepted`
  and a context section that says the decision was reconstructed from the code rather than
  recorded at the time. This is the highest-value hour of the whole adoption: it stops the
  next change from silently contradicting a constraint nobody wrote down.
- **The state file.** `docs/project/STATE.md` with what is in flight, what is broken, and
  what everyone knows but has not written down.

Ask the team about anything that looks deliberate but unexplained. A weird workaround is
usually load-bearing, and removing it is how adoption gets a bad name.

## Stage 3: apply the workflow to new work only (ongoing)

Do not retrofit the lifecycle onto the existing code. Apply it to the next feature:
`/design` before building, `/plan` before coding, `/review` before merging. The system
proves itself on new work and leaves the old code alone.

## Stage 4: add standards where they will land (weeks)

Add rules to `.claude/rules/` for the conventions this codebase already follows, then adjust
the path globs to match its real layout. Rules that describe what the code already does get
followed. Rules imported from a template that contradict every existing file get ignored,
and they teach everyone that the rules are decoration.

Where a standard is aspirational, say so in the rule and apply it to new code only.

## Stage 5: close the gaps you found (as they matter)

Run `/production-readiness` on the existing system to get an honest inventory. Expect it to
fail on observability, runbooks, and restore testing, because most inherited systems do.
Fix in the order the failures would hurt: detection first, then reversibility, then
prevention.

## What not to do

- Do not rewrite working code to match a rule.
- Do not write ADRs for every decision ever made. Ten load-bearing ones beat sixty.
- Do not add hooks that fire on the existing code's normal state, for example a lint gate
  on a codebase with 4,000 warnings. Gate new code instead.
- Do not skip the verify script. Without a runnable check, the rest of the system is
  paperwork.
