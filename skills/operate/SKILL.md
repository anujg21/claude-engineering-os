---
name: operate
description: Handle a production incident and turn what was learned into a runbook and durable fixes. Covers triage, mitigation, root cause, and the blameless write-up. Phase 16 of the lifecycle.
when_to_use: Something is broken or degraded in production, an alert fired, a customer reported a failure, or you need to write or update a runbook for a known failure mode.
argument-hint: "[symptom or runbook name]"
---

# Operate

Two modes: an incident happening now, and writing down what should have existed before it.

## Incident

**Mitigate before you diagnose.** The goal in the first minutes is to stop the harm, not to
understand it. Roll back the recent deploy, disable the feature flag, shed the load, fail
over. Understanding comes after the bleeding stops.

**1. Establish the facts.** What is the observable symptom, since when, affecting whom, and
how many? Get a number. "Users are seeing errors" is not a fact you can act on.

**2. Correlate with change.** What deployed, what config changed, what migration ran, what
started in a dependency? Most incidents are caused by a change, and the change is usually
recent. Check that before theorizing.

**3. Mitigate.** Take the reversible action. Announce what you did and when.

**4. Confirm.** Watch the signal recover. Do not declare it over on the first data point.
Check that the backlog drained, the queue emptied, and no data was lost or duplicated while
it was broken.

**5. Then diagnose.** Work from evidence: logs, metrics, traces, the diff. Form one
hypothesis at a time and state what would disprove it. Do not change two things at once,
and do not change production to test a theory.

Throughout: keep a timestamped log of what you observed and what you did. It is the input to
the write-up, and after the fact nobody remembers the order.

## Approval during an incident

The gates in CLAUDE.md still apply. An incident is exactly when someone runs a destructive
command under pressure. Restoring a backup over a live database, deleting resources, and
modifying production data all need a human to say yes, out loud, in the incident channel.

Reading production, rolling back a deploy, and flipping a flag are the mitigations that do
not need one, which is why they are the mitigations to reach for.

## Write-up

Blameless. The question is what made the failure possible and what made it slow to detect,
not who typed the command.

Cover: the timeline with timestamps, the impact in user terms and duration, how it was
detected and how long that took, the contributing causes rather than a single root cause,
what stopped it, what made it harder than it needed to be, and the actions with owners.

Actions worth taking are the ones that prevent the class of failure or shorten detection.
"Be more careful" is not an action. Adding the alert that would have caught it in two
minutes instead of forty is.

Save to `docs/operations/incidents/<date>-<slug>.md`.

## Runbooks

A runbook is written for someone woken at 3am who did not build this. Test it by handing it
to someone who has not seen the system.

Use `templates/runbook.md`. Each one covers one failure mode: the alert or symptom that
brings you here, how to confirm it is really this, the immediate mitigation as exact
commands, how to verify recovery, when to escalate and to whom, and the underlying cause if
it is known.

Exact commands, not descriptions of commands. Every dashboard and query linked directly.

Write the runbook when you finish the incident, while you still remember what you needed
and could not find. Save to `docs/operations/runbooks/`.
