---
name: release
description: Prepare, execute, verify, and if necessary roll back a deployment. Enforces the human approval gate and records what shipped. Phase 15 of the lifecycle.
when_to_use: Invoke directly when a release is about to happen or a rollback is needed. Never runs automatically.
disable-model-invocation: true
argument-hint: "[environment] [version or branch]"
---

# Release

Deploying is a human approval gate. This skill prepares everything, then stops and asks.
It never deploys on an inferred yes.

## Before

1. `/production-readiness` has a recorded GO or CONDITIONAL GO for this change. If it does
   not, run it. A release without a verdict is not ready by definition.
2. The pipeline is green on the exact commit being released. Not on a similar one, not on
   the branch tip if that has moved.
3. Migrations are separated from code changes, and the order is stated: schema first,
   additive, deployable on its own and safe under the currently running code.
4. The rollback command is written down here, in this release record, with its expected
   duration and what it does about the schema.
5. Someone is available to watch it. Nobody releases into an empty room.

## Ask

Present, in one message: what is shipping, the commit, the target environment, the
migrations included, the blast radius, the rollback command, and the health signals you
will watch. Then stop and wait for an explicit yes.

Do not proceed on "sounds good" in an earlier message about something else.

## During

- Deploy through the pipeline. There is no manual path.
- Progressive rollout where the change warrants it: one instance, then a slice of traffic,
  then the rest, with a pause and a look at the signals between each.
- Watch error rate, latency, saturation, and the specific signal this change should move.
  Compare against the pre-deploy baseline, which you recorded, rather than against a
  remembered normal.
- Do not start anything else while a rollout is in progress.

## Verify

- The intended behavior works in production, checked directly rather than inferred from a
  green deploy.
- Error rate and latency are within their normal band after enough traffic to be meaningful.
- No new error class appeared in the logs.
- Background jobs, consumers, and scheduled work are still healthy. They are the usual
  casualty of a deploy that "looked fine".

## Roll back

Roll back first and investigate afterwards. A rollback is cheap; an extended outage while
someone debugs in production is not.

Roll back when the error rate rises above the agreed threshold, latency degrades past the
budget, a new error class appears, or data is being written incorrectly. Do not wait for
certainty about the cause.

If the release included a migration, follow the documented schema rollback path. If the
schema cannot be reversed, that was a design defect and the fix is forward: ship a
correcting release rather than restoring over live data. Restoring a backup over a live
database is its own approval gate and its own incident.

## After

Write the release record: what shipped, when, who approved, what was observed, and anything
surprising. Update `docs/project/STATE.md`. If anything went wrong, run `/operate` to write
the incident note while the details are fresh.
