# Implementation plan: <feature>

Design: docs/architecture/designs/<feature>.md
Status: in progress
Last updated: <YYYY-MM-DD>

## Verification

Command that proves the whole thing works: `./scripts/verify.sh`

Manual checks that cannot be automated, with exact steps:

## Tasks

Ordered so the tree is green after every task. Riskiest unknown first.
Mark a checkpoint where a human should look before the next task starts.

| # | Task | Files | Check | Done when | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | | | | | todo |
| 2 | | | | | todo |

Status values: todo, doing, done, blocked, dropped. Dropped tasks stay in the table with a
reason. Deleting them hides the fact that the plan changed.

### Checkpoints

| After task | What a human should confirm |
| --- | --- |

## Rollback

How to reverse this if it goes wrong after release, including the schema. If the schema
cannot be reversed, say so and state the forward fix instead.

## Out of scope

What is deliberately not in this plan. This is the list you point at when scope arrives
mid-implementation.

## Discovered during implementation

Things found while building that were kept out of the diff. Each becomes a task, a ticket,
or an accepted risk. Nothing gets fixed silently.

| Found | Where | Decision |
| --- | --- | --- |
