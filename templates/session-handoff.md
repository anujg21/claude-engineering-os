# Session handoff

From: <session or person>
Date: <YYYY-MM-DD>

A baton, not a log. Overwrite this file each time. It carries what `STATE.md` does not:
the half-finished thing and the approaches that already failed.

## Where I stopped

The exact task, the file, and the line if it matters. What is committed, what is staged,
what is uncommitted, and which branch it is on.

## Next step

The single concrete next action, with the command to run.

```
```

## What I tried that did not work

The most valuable section. For each attempt: what you tried, what happened, and what you
concluded. Without this the next session repeats it, which is where most wasted time goes.

| Attempt | Result | Conclusion |
| --- | --- | --- |

## What I learned that is not written down anywhere

Behavior of the system that surprised you, a quirk in a dependency, a command that works
when the documented one does not. Move anything durable into CLAUDE.md, a rule, or an ADR
before it gets lost here.

## Open decisions waiting on a human

| Question | Options | Who decides |
| --- | --- | --- |

## State of the checks

`./scripts/verify.sh`: passing | failing (paste the failure)
Anything skipped, quarantined, or known broken:
