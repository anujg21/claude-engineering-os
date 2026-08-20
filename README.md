# Claude Code engineering operating system

A repository template that takes a coding agent from a vague idea to a system running in
production, with the decisions written down and the dangerous operations gated.

It is opinionated, technology-agnostic, and deliberately small: fourteen skills, four
agents, six rule sets, four hooks, eleven templates. Every component exists because a
specific failure happens without it.

## What it fixes

A coding agent starts each session with no memory, high confidence, and a context window
that degrades as it fills. Without structure it solves the wrong problem well, removes
constraints nobody wrote down, and reports success it never verified.

This template answers that with four mechanisms:

- **A phase-based lifecycle** where each phase produces a written artifact and has exit
  criteria, so work is resumable and "done" is checkable.
- **Progressive disclosure** so that context holds only what the current task needs.
- **Independent review** by agents that never saw the code being written.
- **Deterministic guards** for the things that must not depend on the agent remembering.

## Install

```bash
git clone <this repo> my-project && cd my-project
rm -rf .git && git init
./scripts/setup.sh
```

Then, before doing anything else:

1. Edit `scripts/verify.sh` so it runs the project's real lint, type check, and tests.
   Everything else depends on this. A system whose check is fake produces confident
   nonsense.
2. Fill in the build and run commands in the commands section of `CLAUDE.md`.
3. Adapt the patterns in `.claude/hooks/guard-commands.sh` to your deployment and migration
   tooling.
4. Start Claude Code and run `/context` to confirm `CLAUDE.md` and the rules loaded.

Installing into an existing repository: copy `.claude/`, `templates/`, `scripts/`, and
`CLAUDE.md`, keeping any existing configuration, then run `/adopt`.

## How it fits together

```
CLAUDE.md              Standing rules. Loaded every session. Under 200 lines by design.
.claude/
  rules/               Standards, loaded only when Claude touches matching file paths.
  skills/              Procedures, loaded only when invoked.
  agents/              Four read-only reviewers, each in its own context.
  hooks/               Guards that run whether or not the agent agrees.
  settings.json        Permissions and hook wiring.
docs/
  product/             What we are building and why.
  architecture/        How it is built, plus per-feature designs.
  decisions/           Why it is built that way. ADRs, immutable once accepted.
  engineering/         Lifecycle, principles, definition of done, MCP policy.
  security/            Threat model and posture.
  operations/          Runbooks, incidents, readiness reports.
  project/             STATE.md, handoffs, plans. The memory between sessions.
templates/             Canonical document shapes that skills fill in.
scripts/               verify.sh, new-adr.sh, setup.sh.
```

The placement rule: everything is positioned by when it needs to be in context. Standing
rules load always, path rules load on contact, procedures load on invocation, reference
material loads when a skill decides to read it. `docs/engineering/system-design.md` explains
the reasoning and what was rejected.

## From an idea to production

The full phase specification is `docs/engineering/lifecycle.md`. The routing table is in
`CLAUDE.md`. In practice it looks like this.

### A new product

```
/discovery      Claude interviews you, then writes the brief and the requirements.
                Stop and read them. This is the cheapest place to change your mind.

/architecture   Works the decision framework, writes the overview and the ADRs, then
                sends it to the architecture-reviewer for an independent read.
                You approve the shape before anything else happens.

/design         Per feature. The contract, the data model, the failure modes.

/plan           Turns the design into ordered tasks, each with files and a check.

/implement      One task at a time. Test, code, verify, tick the plan, commit.
                Repeat until the plan is done.

/review         A fresh context reads the diff and reports what is wrong with it.

/security-review    If it touches auth, secrets, input, external calls, or personal data.

/performance-review If a latency or throughput budget exists.

/production-readiness   Ten dimensions, evidence required, ends in GO or NO-GO.

/release        Prepares everything, then stops and asks you. Always asks.

/operate        When it breaks. Mitigate, then diagnose, then write the runbook.
```

Between every step, `/project-state` keeps `docs/project/STATE.md` true so a fresh session
can pick the work up cold.

### An existing codebase

`/adopt` runs five stages, each useful on its own if you stop there: make the guards and the
verify script real, reconstruct the architecture and the decisions that already exist,
apply the lifecycle to new work only, add rules that describe what the code already does,
then close the gaps that a readiness review finds.

The thing it will not do is rewrite working code to match a rule.

### A one-line fix

Skip to `/implement`, then `/review`. The lifecycle is a sequence, not a ceremony. Say which
phases you skipped.

## Making it yours

Four places, in the order you will want them.

**`docs/architecture/principles.md`** is the main customization point. It states a position:
modular monolith first, synchronous until proven otherwise, one owner per piece of data,
buy the undifferentiated parts. Disagree with it and edit it. The `/architecture` skill
applies whatever it says.

**`.claude/rules/`** holds the standards. Adjust the `paths:` globs to your layout, and
change the content so it describes what your code actually does. A rule that contradicts
every existing file gets ignored, and it teaches everyone that the rules are decoration.

**`CLAUDE.md`** carries the approval gates and the routing table. Add project facts, and
delete anything that turns out not to change behavior. Apply its own test to every line:
would removing this cause a mistake?

**`.claude/hooks/guard-commands.sh`** knows about generic tooling. Teach it the names of
your production contexts, your migration tool, and your deploy command.

To add a skill, ask what failure it prevents, what it costs in context, and what it
duplicates. If any answer is weak, the system is better without it.

## Security posture

- Destructive commands are denied by a hook, and production-touching ones are escalated to
  a human permission prompt. `.claude/hooks/README.md` explains the split.
- Writes containing credential material are blocked before they reach disk.
- Reading `.env`, key files, and `secrets/` is denied in `.claude/settings.json`.
- Approval gates for production, data destruction, credentials, trust boundaries, and
  anything irreversible are listed in `CLAUDE.md` and repeated in the lifecycle.
- The security control catalogue lives in `.claude/skills/security-review/checklist.md` and
  is the single copy.
- MCP servers are treated as production integrations with live credentials. The policy,
  including prompt injection through tool output, is in `docs/engineering/mcp.md`.

The hooks are a backstop. They match patterns, so they will miss things your tooling names
differently. Adapt them, and do not treat them as the reason it is safe to run unattended.

## Maintaining it

Prune on a schedule. A rule that never fires, a skill nobody invokes, and a checklist item
that never fails are all costing context for nothing. The component count should go down as
often as it goes up.

When Claude repeatedly does something wrong despite a rule, the file is probably too long
and the rule is getting lost. When Claude asks about something the rules answer, the wording
is ambiguous. Treat these files like code: review them when things go wrong, and test a
change by watching whether behavior actually shifts.

## Where to look next

- `docs/engineering/lifecycle.md` every phase, its inputs, outputs, exit criteria, and gates.
- `docs/engineering/system-design.md` the research behind this design, and what was rejected.
- `docs/engineering/definition-of-done.md` what "done" means at the task, feature, and
  release level.
- `.claude/hooks/README.md` how the guards work and how to add one.
