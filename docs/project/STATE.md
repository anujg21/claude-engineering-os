# Project state

Last updated: 2026-08-19

Replace this content the moment a real project starts. Right now it describes the template
itself, which is the only honest thing it can say.

## Now

Phase: not started.
Active plan: none.
Working on: nothing. This repository is the engineering operating system, not a project.

To start a new product, run `/discovery`. To install this into an existing repository, run
`/adopt`.

## Done

| Date | What | Evidence |
| --- | --- | --- |
| 2026-08-19 | Engineering operating system scaffolded: CLAUDE.md, 14 skills, 4 reviewer agents, 6 path-scoped rule sets, 4 hooks, 11 templates, lifecycle documentation. | This repository |

## Next

1. Adapt `scripts/verify.sh` to the project's real checks. Nothing else works until this does.
2. Fill in the build and run commands in CLAUDE.md.
3. Adapt the deploy and migration patterns in `.claude/hooks/guard-commands.sh`.
4. Run `/discovery` or `/adopt`.

## Blocked

| What | Blocked on | Since | Owner |
| --- | --- | --- | --- |
| Nothing | | | |

## Decisions

| ADR | Decision | Date |
| --- | --- | --- |
| [0001](../decisions/0001-record-architecture-decisions.md) | Record architecture decisions as ADRs | 2026-08-19 |

## Assumptions

| Assumption | What breaks if wrong | How to confirm |
| --- | --- | --- |
| `jq` or `python3` is available on the machine | Hooks fall back to coarse text matching and become less precise | `./scripts/setup.sh` reports which one it found |

## Risks and open items

| Item | Impact | Owner | Decision |
| --- | --- | --- | --- |
| `scripts/verify.sh` auto-detects the toolchain and will guess wrong on unusual setups | Every "done" claim in the system depends on this script | Adopter | Replace the detection with explicit commands during adoption |
| Hook command patterns are generic and do not know your deploy tooling | A destructive command could pass the guard | Adopter | Add your own tooling's patterns during adoption |
