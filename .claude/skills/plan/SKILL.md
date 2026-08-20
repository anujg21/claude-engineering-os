---
name: plan
description: Turn a technical design into an ordered list of small, independently verifiable implementation tasks, written to docs/project/plans/<feature>.md. Each task names its files, its check, and its done condition. Phase 6 of the lifecycle.
when_to_use: A design is agreed and work is about to start, or a piece of work is large enough that you would otherwise lose track of it across sessions. Also use to re-plan when reality has diverged from an existing plan.
argument-hint: "[feature name]"
---

# Implementation plan

Input: a technical design. Output: `docs/project/plans/<feature>.md` from
`templates/implementation-plan.md`.

A plan exists so that work survives a lost context window and so progress is visible
without reading the diff. It is a checklist, not an essay.

## Task shape

Each task is:

- **Small.** One coherent change, finishable and verifiable on its own. If a task needs
  more than a few files or has an "and" in its title, split it.
- **Ordered.** Sequenced so the tree builds and tests pass after every task. Never leave a
  task that only makes sense once a later one lands.
- **Specific.** Names the files to create or change and the interfaces involved. "Add
  validation" is not a task. "Add request schema validation to `src/api/orders.ts`,
  rejecting unknown fields with `INVALID_REQUEST`" is.
- **Verifiable.** States the command that proves it works and what a pass looks like.
  Usually `./scripts/verify.sh`, sometimes a single test file, sometimes a manual check
  with the exact steps.
- **Done-conditioned.** One line stating what is true when the task is complete.

## Sequencing rules

1. Schema and migration first, additive only, deployed before the code that uses it.
2. Then the domain logic with its tests, isolated from transport and storage.
3. Then the adapters: handlers, repositories, clients.
4. Then wiring, configuration, and feature flag.
5. Then observability: logs, metrics, and the alert.
6. Then the contract or end to end test that proves the whole path.
7. Cleanup and the contract step of any migration go in a later, separate release.

Put the riskiest unknown in the first two tasks. If the approach is wrong, you want to
discover it on day one, not after eleven tasks of scaffolding.

## Writing the plan

Fill the template. It carries the task table, the verification command, the rollback
approach, and an explicit out-of-scope list. The out-of-scope list is not decoration: it
is what you point at when scope creep arrives mid-implementation.

Estimate nothing in hours. Order and size relative to each other.

## Checkpoints

Mark tasks where a human should look before continuing: the first task that touches a
trust boundary, the migration, anything that changes a public contract, and the release
itself. Those are stops, not notifications.

## Keeping it true

The plan is a living file. `/implement` ticks tasks off as it goes and adds discovered
work to the plan rather than doing it silently. When reality diverges far enough that
resequencing is needed, re-plan explicitly and note what changed and why. A plan nobody
updates is worse than no plan, because people trust it.

## Exit criteria

- Every task names files and a check.
- The tree is green after every task, at least in principle.
- The riskiest work is early.
- Rollback is written down.
- Out of scope is written down.
