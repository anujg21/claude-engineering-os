---
name: production-readiness
description: Run the GO / NO-GO review across functionality, architecture, security, reliability, observability, performance, data, deployment, operations, and documentation. Produces a written verdict with named blockers. Phases 12 to 14 of the lifecycle.
when_to_use: Before a first production release, before exposing something to real users or real money, and before any release that changes a trust boundary, a schema, or an external contract. Also use to assess an inherited system.
argument-hint: "[service or release name]"
---

# Production readiness

Input: a change that is believed ready. Output: a written GO or NO-GO with the evidence,
saved to `docs/operations/readiness/<name>-<date>.md` from
`templates/production-readiness-report.md`.

The verdict is the point. A review that ends in a list of observations lets everyone assume
someone else was worried, and the release ships anyway.

## How to run it

Work `checklist.md` in this directory, dimension by dimension. For each item, record one of:

- **Pass**, with the evidence: the test output, the dashboard, the file, the command.
- **Fail**, with what is missing and who owns it.
- **Not applicable**, with the reason. This is a real answer, but it must be argued, not
  assumed. "No personal data is stored" is a reason; silence is not.

Do not accept an intention as evidence. "We will add monitoring" is a fail with an owner.

Delegate the whole pass to the `production-readiness-reviewer` agent when the change is
substantial. A fresh context is less willing to accept "we already discussed that".

## The verdict

**GO** requires every blocking item to pass. Blocking items are the ones where the failure
mode is data loss, a security breach, an outage you cannot detect, or a release you cannot
reverse:

- The change works against its acceptance criteria, with evidence.
- No blocking security finding is open.
- Every external call has a timeout and bounded retries; retried operations are idempotent.
- The failure of each dependency has a defined behavior and does not cascade.
- Errors and latency are alerting, and the alert reaches a person who can act.
- Migrations are expand-and-contract, tested forward, and reversible without data loss.
- Backups exist and a restore has actually been performed, not merely configured.
- Rollback is a documented, tested command with a stated time to execute.
- Secrets are managed, scoped per environment, and rotatable.
- A runbook exists for the failures you know about.

**CONDITIONAL GO** is allowed when the remaining failures are non-blocking, each has a
named owner and a date, and the risk is written down and accepted by a human. Record the
conditions in the report. A conditional go with no date is a no-go wearing a disguise.

**NO-GO** when any blocking item fails. List the blockers in order and stop. Do not soften
the verdict because a deadline exists; the deadline is not evidence.

## Reporting

Fill the template: scope, what was assessed, the dimension-by-dimension table with
evidence, the blockers, the accepted risks with owners, and the verdict with a name and a
date against it.

Attach the artifacts rather than describing them. A pasted test summary, a query plan, a
screenshot of the alert firing in staging. Someone will read this after an incident.

## Approval

The verdict is a recommendation. Deploying is a human approval gate in every case. Present
the report, state the verdict, and wait.
