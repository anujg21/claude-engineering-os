# Operations

What the system needs from you after it ships.

- `runbooks/` one per failure mode, from `templates/runbook.md`. Written for someone woken
  at 3am who did not build this. Exact commands, linked dashboards.
- `incidents/` one note per incident, `<date>-<slug>.md`. Blameless, with a timeline and
  actions that have owners.
- `readiness/` GO / NO-GO reports from `/production-readiness`, kept as a record of what
  was known at the time of each release.

## The rule about alerts

Every alert maps to a runbook entry. An alert with no documented response trains people to
ignore alerts, and then the one that matters gets ignored too. If an alert cannot be acted
on, delete it rather than muting it.

## The rule about runbooks

Write the runbook at the end of the incident, while you still remember what you needed and
could not find. A runbook written from memory a week later documents the tidy version of
what happened.

Test them by handing one to someone who has not seen the system. Every step that needs
knowledge they do not have is a step that will fail at 3am.
