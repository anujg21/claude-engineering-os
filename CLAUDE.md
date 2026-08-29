# Engineering operating system

This repository runs a phase-based engineering workflow. Procedures live in skills,
standards live in `.claude/rules/`, decisions and state live in `docs/`.
This file holds only the rules that apply to every session.

## Start of every session

1. Read `docs/project/STATE.md`. It is the source of truth for what is in progress,
   what is blocked, and what was decided. Conversation history is not.
2. Before changing anything architectural, search `docs/decisions/` for an ADR that
   already settles the question. An accepted ADR is binding until superseded by a new one.
3. Before writing code in an unfamiliar area, read the code first. Do not guess at
   interfaces that you can read.

## Operating rules

- **Work the phase you are in.** An idea does not become code in one step. Use the
  routing table below. If you cannot name the current phase, you are in the wrong one.
- **Verify, do not assert.** Every change ships with a check a machine can run:
  a test, a build, a script, a screenshot diff. Run it and show the output. Work with
  no runnable check is not done, it is a proposal.
- **No silent scope growth.** Implement what the plan says. Anything you discover that
  is out of scope goes to the "Open items" section of `docs/project/STATE.md`, not into
  the diff.
- **Smallest change that works.** No speculative abstraction, no new dependency, and no
  new service without a written reason. Three occurrences before you extract a shared
  abstraction.
- **Write the decision down.** If you chose between real alternatives and the choice is
  expensive to reverse, write an ADR (`/adr`) before you write the code.
- **Ask versus assume.** Assume when the choice is cheap and reversible, then record the
  assumption in the current phase document. Ask when the choice is a product judgement,
  is expensive, is hard to reverse, or touches money, personal data, or auth.
- **Never fabricate results.** If a test fails, say so and paste the output. If you
  skipped a step, say which one. "Should work" is not a status.
- **Secrets never enter the repo.** No credentials in code, config, logs, test fixtures,
  or commit messages. Reference an env var or a secret manager.

## Approval gates

Stop and get explicit human approval before any of these. Do not proceed on an assumed yes.

- Deploying to production, or promoting a release.
- Any command against production data or production infrastructure.
- Destructive data operations anywhere: schema drops, table truncation, unscoped
  `DELETE`/`UPDATE`, irreversible migrations, restoring over a live database.
- Deleting or replacing infrastructure (`terraform destroy`, cluster or namespace deletes).
- Rotating, creating, or revoking credentials, keys, and tokens.
- Changing an authentication, authorization, or encryption boundary.
- Superseding an accepted ADR, or changing a service boundary.
- Adding cloud resources with recurring cost, or a new third-party vendor.
- `git push --force` to a shared branch, history rewrites, direct pushes to the default branch.
- Publishing a package, or anything else that leaves the machine and cannot be recalled.

The hooks deny or prompt on some of these, but they match command text, so they miss
tooling they do not recognise by name and a determined evasion beats them. They are a
backstop, not the rule. The rule is: ask first.

## Lifecycle routing

| Goal | Use | Produces |
| --- | --- | --- |
| Not sure which of these fits what you need | `/guide` | a pointed recommendation |
| Turn a rough idea into a product brief and requirements | `/discovery` | `docs/product/` |
| Choose an architecture and record why | `/architecture` | `docs/architecture/overview.md`, ADRs |
| Record one decision | `/adr` | `docs/decisions/NNNN-*.md` |
| Design a feature before building it | `/design` | `docs/architecture/designs/` |
| Break a design into ordered, verifiable tasks | `/plan` | `docs/project/plans/` |
| Build the next task from a plan | `/implement` | code, tests, state update |
| Get an independent review of a diff | `/review` | findings, ranked |
| Check a change for security defects | `/security-review` | findings, blocking or not |
| Check latency, throughput, resource use | `/performance-review` | measurements, findings |
| Decide whether this can ship | `/production-readiness` | GO / NO-GO report |
| Prepare, run, or roll back a release | `/release` | release record |
| Handle an incident or write a runbook | `/operate` | `docs/operations/` |
| Save or restore project state | `/project-state` | `docs/project/STATE.md`, handoff |
| Bring an existing repository into this system | `/adopt` | phased adoption plan |

Full phase specification, including entry and exit criteria for each phase:
`docs/engineering/lifecycle.md`.

## Delegation

Work directly for anything you can finish in one context. Delegate to a subagent when
the work would flood this context with files you do not need afterwards, or when a
fresh, independent read produces a better answer.

- Broad search across many files: use `Explore`.
- Review of your own work: always a subagent, never yourself. `code-reviewer`,
  `security-reviewer`, `architecture-reviewer`, `production-readiness-reviewer`.
- Implementation stays in the main session. The orchestrator writes the code so the
  context that planned it is the context that builds it.

## Commands

- `./scripts/verify.sh` runs the project's checks. Use it as the definition of "it works".
  It auto-detects the toolchain and is the single entry point for tests, lint, and types.
- `./scripts/new-adr.sh "<title>"` creates the next numbered ADR from the template.
- `./scripts/setup.sh` installs hook prerequisites and makes hooks executable.

Project-specific build and run commands belong here once this template is adopted by a
real project. Keep them short and keep them accurate.

## Where things live

Paths below are where these land in a project that has adopted the system. In the
engineering-os source repository itself, skills, agents, and hooks sit at the root
instead, because that is where the plugin loader expects them.

- `.claude/rules/` standards that load automatically when you touch matching files.
- `.claude/skills/` the procedures behind each routing table entry.
- `.claude/agents/` independent reviewers, all read-only.
- `.claude/hooks/` deterministic guards. See `.claude/hooks/README.md`.
- `docs/product/` what we are building and why.
- `docs/architecture/` how it is built. `docs/decisions/` why it is built that way.
- `docs/engineering/` how we work: lifecycle, principles, definition of done.
- `docs/security/` threat model and security posture for this system.
- `docs/operations/` runbooks and incident records.
- `docs/project/` current state, plans, handoffs. The long-running memory.
- `templates/` canonical document templates. Skills fill these in.
