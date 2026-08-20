# Runbook: <failure mode>

Severity: <what this affects and how badly>
Owner: <team or person>
Last tested: <YYYY-MM-DD>

Written for someone woken at 3am who did not build this system. Exact commands, not
descriptions of commands. Every dashboard and query linked directly.

## You are here because

The alert name, the symptom, or the report that leads to this page.

## Confirm it is this

How to tell this failure from the ones it resembles. The query or dashboard that shows it,
and what the healthy value looks like.

```
```

## Mitigate now

Numbered steps, in order, with the exact command and its expected output. Say what each
step does and what it risks. Put the reversible options first.

1.
2.

If a step needs an approval gate from CLAUDE.md, say so here and name who can give it.

## Confirm recovery

What must return to normal, over what period, and where you watch it. Include the backlog,
the queue depth, and anything that piled up while it was broken.

## If that did not work

The next thing to try, then the escalation path: who to wake, how, and what to tell them.

## Cause

What actually goes wrong, if it is known. Link the incident notes and the fix if one is in
flight.

## Related

Dashboards, related runbooks, the design document, the ADR.
