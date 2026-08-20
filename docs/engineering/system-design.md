# How this system was designed

Why this repository is shaped the way it is: what was researched, what was taken, what was
rejected, and what each part is for. Read this before adding to the system, so the next
addition earns its place.

## The problem

A coding agent starts every session with no memory, unlimited confidence, and a context
window that degrades as it fills. Left alone it writes plausible code that solves the wrong
problem, forgets constraints nobody wrote down, and reports success it did not verify.

The fix is not a longer prompt. It is an operating system: a small set of standing rules,
procedures that load only when needed, deterministic guards for things that must not be
optional, and durable files that carry state across sessions.

## Design constraints

Four platform facts drove almost every structural decision.

**Context is the scarce resource.** Everything loaded at session start is paid for on every
turn, and adherence drops as the file grows. So CLAUDE.md stays under 200 lines, standards
move to `.claude/rules/` where they load only when Claude touches matching paths, and
procedures move to skills that load only when invoked.

**Skill content persists once loaded.** An invoked skill stays in context for the rest of
the session. That makes long skill bodies expensive, so each `SKILL.md` here is a procedure
with references to files it can read on demand, not a manual.

**Subagents start cold.** A subagent gets its own prompt and no conversation history. That
is a cost for implementation work and a benefit for review, which is why every agent in
this system is a reviewer.

**Instructions are advisory, hooks are not.** CLAUDE.md shapes behavior; a hook executes.
Anything that must happen every time is a hook.

## Where each kind of content lives

| Content | Home | Loaded |
| --- | --- | --- |
| Rules that apply to every session | `CLAUDE.md` | Always, under 200 lines |
| Standards for a kind of file | `.claude/rules/*.md` with `paths:` | When Claude touches matching files |
| Procedures | `skills/*/SKILL.md` | When invoked, by you or by Claude |
| Long checklists and reference tables | Files beside the SKILL.md | When the skill decides to read them |
| Independent review personas | `agents/*.md` | In a separate context, on delegation |
| Non-negotiable enforcement | `hooks/` | Automatically, at lifecycle events |
| Knowledge for humans | `docs/` | On demand |
| Current status | `docs/project/STATE.md` | Injected at session start by a hook |
| Document shapes | `templates/` | When a skill fills one in |

If you add something to this system, place it by asking when it needs to be in context. That
question answers the placement every time.

## What was researched

The design draws on Anthropic's own documentation and product behavior, and on a set of
community projects. The evaluation criterion was whether an idea survives contact with a
real production codebase, not how popular the repository is.

**Anthropic Claude Code documentation and the `anthropics/skills` repository.** The
authoritative source for what the platform actually does: skill frontmatter and the
1,536-character budget shared by `description` and `when_to_use`, `.claude/rules/` with
path scoping, subagent context
semantics, the full hook event and decision model, and the guidance to keep CLAUDE.md short
and verifiable. Adopted directly, including the "would removing this cause a mistake?" test
for every line of CLAUDE.md and the adversarial review step for finished work.

**Anthropic's official plugin directory (`anthropics/claude-plugins-official`).** Confirmed
the plugin packaging conventions and the shape of a curated catalogue. Adopted the layout
conventions; did not adopt the plugin wrapper, since this system is a repository template
rather than a distributable plugin.

**Superpowers (`obra/superpowers`).** The most complete community methodology: brainstorming
before design, written plans before code, mandatory red-green-refactor, verification before
completion, and subagent-driven execution with staged review. Adopted the sequencing
discipline, the plan-as-artifact idea, verification before claiming completion, and the
insistence that the reviewer is never the author. Changed: tasks here are sized by coherence
rather than by a two to five minute target, TDD is the default rather than an absolute law
because migrations and configuration changes need a different kind of check, and
implementation stays in the main session.

**`thatjuan/agent-skills`.** A single orchestrating skill routing work through triage,
design validation, issue creation, delegated implementation, and review. Adopted the routing
idea, but as a table in CLAUDE.md rather than a router skill, which removes a layer and a
token cost. Its integration skills, embedding vendor-specific API knowledge, are a good
pattern and are deliberately left out of the technology-agnostic core.

**`muratcankoylan/Agent-Skills-for-Context-Engineering`.** Context engineering as a
discipline: attention degradation, progressive disclosure, filesystem-as-context, and
long-horizon task briefs. Adopted progressive disclosure as the organizing principle of the
whole repository and the filesystem-as-memory pattern that `docs/project/STATE.md`
implements. Rejected the more speculative machinery, including multi-agent latent briefing
and self-improvement loops, as more complexity than a working engineering team can maintain.

**`WaiYanNyeinNaing/claude-md-skill`.** CLAUDE.md as a context-injection file rather than
documentation, with a target of about 200 lines and durable state files for long-running
agent work. Adopted both, including the removal test for each line. Its progress-file
pattern is the direct ancestor of `STATE.md` and `HANDOFF.md`, narrowed here to one
canonical state file plus one overwritten handoff, because multiple progress files drift.

**Vercel's agent skills (`vercel-labs/agent-skills`, `vercel-labs/skills`).** Skill authoring
conventions: kebab-case directories matching the frontmatter name, `SKILL.md` under about
500 lines, detail in separate reference files, and descriptions specific enough to control
activation. Adopted the conventions.

**GitHub `spec-kit`.** Spec-driven development with an explicit constitution, specify,
clarify, plan, tasks, analyze, implement sequence, each producing an artifact. Adopted the
core insight that each phase must produce a durable artifact and that clarification is its
own step. Rejected the parallel `.specify/` directory tree and the branded command
namespace: artifacts belong in `docs/` where the team already reads, and a second
documentation hierarchy is a second thing to keep current.

**The awesome-list ecosystem (`hesreallyhim/awesome-claude-code`,
`subinium/awesome-claude-code`, `viktorbezdek/awesome-ai-productivity`) and
`VoltAgent/awesome-claude-code-subagents`.** Useful as a survey of what people build and as
a warning. The 158-agent collection is the clearest example of the failure this system
avoids: a role per technology produces overlapping personas, none of which is better than
the main session with a good skill, and all of which cost description tokens in every
session. Adopted the read-only tool restriction pattern and the model-per-agent idea.
Rejected the taxonomy.

## What was deliberately rejected

**An agent per role.** Backend engineer, frontend engineer, database engineer, and DevOps
engineer agents were considered and cut. A subagent starts without conversation history, so
delegating implementation means re-explaining the task and losing the reasoning that
produced the plan. The four agents here are all reviewers, where a cold context is the
entire point. If you find yourself wanting an implementation agent, what you actually want
is a skill.

**A router or orchestrator skill.** An extra hop that costs tokens and adds a place for
instructions to conflict. The routing table in CLAUDE.md does the same job in twenty lines.

**A skill per phase.** Eighteen phases, fourteen skills. Discovery covers phases 0 to 2
because they are one conversation. Implementation covers 7 and 8 because writing the test
is part of writing the code. Production readiness covers 12 to 14 because they share a
checklist and a verdict.

**Duplicating checklists between skills and agents.** Each reviewer agent preloads its
skill, so the procedure exists in exactly one file. The agent contributes the persona, the
tool restrictions, and the standards of evidence.

**A large committed MCP configuration.** MCP servers cost context in every session and carry
live credentials. `docs/engineering/mcp.md` sets the policy and the default is a CLI.

**Mandatory test-driven development everywhere.** The discipline is right and it is the
default in `/implement`, but stated as an absolute it produces theatre: nobody writes a
failing test for a configuration change. The rule here is that every task names a check,
and a failing test first wherever a test is the right check.

**Coverage targets.** They measure execution, not verification, and optimizing for them
produces tests that assert nothing. The testing strategy asks what failure each test would
catch instead.

**A prescribed technology stack.** The core is technology-agnostic. Path-scoped rules and
`scripts/verify.sh` are the two places a stack becomes visible, and both are meant to be
edited on adoption.

**Auto-generated documentation of the codebase.** Directory listings and file-by-file
descriptions go stale immediately and Claude can read the code faster than it can read a
description of the code. Only what cannot be derived from the source is written down.

## Component inventory

Fourteen skills, four agents, six rules files, four hooks, eleven templates. Each exists
because a specific failure happens without it.

| Component | Prevents |
| --- | --- |
| `/discovery` | Building the wrong thing, precisely and on schedule. |
| `/architecture` and its decision framework | Speculative microservices; complexity with no requirement behind it. |
| `/adr` | Constraints being removed by someone who assumed they were arbitrary. |
| `/design` | Discovering the migration problem after the code is written. |
| `/plan` | Work that cannot resume after a lost context window. |
| `/implement` | Scope creep, unverified claims of completion, silent deviation from the plan. |
| `/review` | The author reviewing their own work and re-deriving the same mistake. |
| `/security-review` | Authorization checked per route instead of per resource. Everything downstream of that. |
| `/performance-review` | Optimizing the bottleneck someone guessed at. |
| `/production-readiness` | Shipping with no alert, no rollback, and an untested restore. |
| `/release` | Deploying without an approval, a baseline, or a way back. |
| `/operate` | Debugging in production before mitigating; incidents that teach nothing. |
| `/project-state` | Everything above evaporating when the session ends. |
| `/adopt` | Turning a working repository into a documentation project. |
| Reviewer agents | Review performed by the context that wrote the code. |
| Path-scoped rules | Standards loaded into every session whether or not they apply. |
| Hooks | Rules that are followed most of the time. |
| Templates | Every document having a different shape and missing a different section. |

## Attribution

No source files were copied. Concepts were extracted, adapted, and reimplemented for this
system. The sources: Anthropic's Claude Code documentation and skills repository,
`anthropics/claude-plugins-official`, `obra/superpowers`, `thatjuan/agent-skills`,
`muratcankoylan/Agent-Skills-for-Context-Engineering`, `WaiYanNyeinNaing/claude-md-skill`,
`vercel-labs/agent-skills`, `github/spec-kit`, and the awesome-list surveys named above.
Longstanding practices predating all of them, including architecture decision records,
expand-and-contract migrations, blameless postmortems, and production readiness reviews,
are used as the industry practices they are.

## Maintaining the system

Every addition needs an answer to three questions: what failure does it prevent, what does
it cost in context, and what does it duplicate. Anything that fails one of those makes the
system worse even if it is individually good.

Prune on a schedule. If a rule is never triggered, a skill is never invoked, or a checklist
item never fails, delete it. This repository is subject to the same standard it applies to
code: the components must justify their existence, and the count should go down as often as
it goes up.
