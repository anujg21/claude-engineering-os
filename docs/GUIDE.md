# Guide

How to use this repo day to day. For the full phase spec see
[lifecycle.md](engineering/lifecycle.md).

## Getting it

```
/plugin marketplace add anujg21/claude-engineering-os
/plugin install engineering-os@claude-engineering-os
```

Then `/adopt` in any repository. It surveys the project first and reports before it writes,
so run it with `--check` if you want to see the plan without the changes.

The one thing to look at afterwards is `scripts/verify.sh`. `/adopt` writes it from the
commands it found in your project, but you know whether those are the right ones. Every
other part of this system treats a passing run as the definition of done.

Not sure which skill to reach for next? Run `/guide`. Tell it what you are trying to do
in a sentence, it checks `docs/project/STATE.md`, asks one short round of questions if it
needs to, and names the exact command to run and why. It routes, it does not do the work,
so it hands you off rather than taking over.

## The idea in one paragraph

Claude reads `CLAUDE.md` every session, so it stays short. Standards sit in
`.claude/rules/` with path globs and only load when Claude opens a matching file.
Procedures sit in `skills/` and load when invoked. Reviews run in a separate
agent that never saw the code being written. Hooks handle the things that cannot depend
on Claude remembering.

That is the whole design. Everything else follows from it.

## Starting something new

Run `/discovery`. Claude will interview you. Answer properly, this is the cheapest place
to change your mind. You get `docs/product/brief.md` and `requirements.md`.

Run `/architecture`. It works through a decision framework whose default is a modular
monolith, one database, synchronous calls. It only departs from that when a requirement
forces it, and it has to say which one. You get an architecture doc, some ADRs, and an
independent review. **You approve the shape before anything gets built.**

Then per feature: `/design` for the contract and the failure modes, `/plan` for ordered
tasks, `/implement` to build them one at a time.

Before merging: `/review`. Add `/security-review` if it touches auth, secrets, user input,
external calls, or personal data.

Before shipping: `/production-readiness` gives you a GO or NO-GO with evidence, then
`/release` prepares everything and stops to ask.

## Working example

"Track which vendor contracts are about to auto-renew."

`/discovery` asks who chases renewals now, what a missed one costs, how many contracts
exist, who can see them. Writes requirements with real numbers in them.

`/architecture` sees a few thousand contracts and a handful of users, so the default
holds: one app, one database, a managed mail provider. One ADR records the decision *not*
to build an event pipeline for four writes a day.

`/design` for reminders pins the schedule table, the idempotency key that stops duplicate
emails on a job retry, and what happens when the mail provider is slow rather than down.

`/plan` puts the mail provider's retry behaviour in task two, because that is the risky
unknown and you want to find out early.

`/implement` works the list, pasting verify output each time.

`/production-readiness` fails the first pass: nobody has tested a restore, and there is no
alert for the reminder job failing quietly. Fix both, second pass is GO.

## Bringing in an existing codebase

Run `/adopt`. It goes in stages and each one is useful on its own.

Stage 1 takes an hour: copy the files, make `verify.sh` real, teach the guard hook your
tooling. **Then use it for a week before doing anything else.** You will know better
where this codebase actually hurts.

Stage 2 takes a day: write down the architecture as it actually is, and write ADRs for
the ten decisions somebody made implicitly and never recorded. This is the part that pays
for itself, because it stops the next change from quietly breaking a constraint nobody
documented.

After that, apply the lifecycle to new work only. Do not retrofit it. Do not rewrite
working code to satisfy a rule.

## Long-running work

`docs/project/STATE.md` is the one file that must always be true. A hook injects it at
session start, so a fresh session knows where things stand without you re-explaining.

Update it when you finish something, not in a weekly batch. Keep it short, it gets
truncated at 60 lines. `/project-state` handles both that and the handoff file you write
before stopping for the day.

The handoff is worth caring about. Its most useful section is what you tried that did not
work, because that is the part always lost between sessions.

## Approval gates

Claude stops and asks before: production deploys, anything touching production data or
infrastructure, destructive database operations, credential changes, auth or encryption
boundary changes, superseding an ADR, new recurring cloud cost, force pushes, publishing.

The full list is in `CLAUDE.md`. The hooks enforce some of it mechanically, but the hooks
match command patterns and will miss tooling they do not recognise. Treat them as a
backstop.

## Customising it

Four places, in the order you will want them.

**`docs/architecture/principles.md`** is the main one. It takes a position: monolith
first, synchronous until proven otherwise, one owner per piece of data. Disagree with it
and edit it. `/architecture` follows whatever it says.

**`.claude/rules/`** holds the standards. Change the `paths:` globs to match your layout
and rewrite the content to describe what your code already does. A rule that contradicts
every existing file gets ignored, and then people stop believing any of them.

**`CLAUDE.md`** for project facts and commands. Test every line against "would removing
this cause a mistake?" and delete it if not.

**`.claude/hooks/guard-commands.sh`** needs your production context names and deploy
command. A guard that fires on normal work gets switched off, which is worse than no
guard.

## Adding to the system

Before you add a skill or a rule, answer three things: what breaks without it, what it
costs in context, and what it duplicates. A weak answer to any of them means leave it out.

Prune too. A rule that never fires or a skill nobody runs is costing context for nothing.

## When it misbehaves

Claude ignores a rule repeatedly: the file is probably too long and the rule is buried.

Claude asks about something the rules answer: the wording is ambiguous.

Claude says something is done without evidence: `verify.sh` probably is not running
anything real. Check it.
