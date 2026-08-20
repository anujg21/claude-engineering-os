---
name: project-state
description: Read, update, or hand off the canonical project state in docs/project/STATE.md so work survives lost context, compaction, and long gaps between sessions. Cross-cutting, used in every phase.
when_to_use: At the start of a session to recover context, at the end of a session or before a break, after finishing a task or a phase, when context is about to compact, or when the user asks what the current state of the project is.
argument-hint: "[update | handoff | read]"
---

# Project state

Conversation history is not durable. Sessions end, contexts compact, and weeks pass.
`docs/project/STATE.md` is the one file that must always be true, because it is what a
cold session reads before doing anything.

Keep it short. A state file nobody reads because it is 400 lines long has failed at its
only job.

## Reading

`docs/project/STATE.md` is loaded automatically at session start by a hook, truncated to the
first 60 lines. Read the whole file before planning anything, then read what it points at:
the current plan, the active design, the open ADRs.

If the file contradicts the code, the code wins. Fix the file immediately, then continue.

## Updating

Update after finishing a task, after a decision, after a phase transition, and before the
session ends. Keep it to the seven sections in `templates/project-state.md`:

- **Now.** The current phase, the active plan, and the one thing being worked on. One
  paragraph, rewritten each time rather than appended to.
- **Done.** Shipped and verified, most recent first, with dates. Trim to the last few weeks;
  git holds the rest.
- **Next.** The ordered queue. Not a wish list.
- **Blocked.** What is stuck, on whom or on what, and since when. A blocker with no date is
  invisible.
- **Decisions.** Recent ones with a link to the ADR. This section holds pointers, not the
  reasoning.
- **Assumptions.** What is being treated as true without confirmation, and what breaks if
  it is wrong. Remove them as they get confirmed.
- **Risks and open items.** Known problems, deferred work, and things discovered during
  implementation that were kept out of scope.

Write for a stranger. No pronouns without antecedents, no "as discussed", no references to
a conversation that no longer exists. Every entry names files, dates, and identifiers.

## Handoff

At the end of a working session, or before handing to another person or a fresh session,
write `docs/project/HANDOFF.md` from `templates/session-handoff.md`. It captures what the
state file does not: what you were in the middle of, what you tried that did not work, the
next concrete step with the command to run, and anything you know that is not yet written
down anywhere.

The negative results matter most. Knowing which three approaches already failed is worth
more than the summary of what succeeded, and it is the part that is always lost.

Overwrite the previous handoff. It is a baton, not a log.

## Discipline

- One canonical state file. If a fact lives in two files, they will disagree within a week
  and both become untrusted.
- Update it in the same action as the work, never in a batch at the end of the week.
- Delete aggressively. Anything true but no longer load-bearing belongs in git history or a
  document, not here.
- Never record a status you have not verified. "Deployed" means you checked.
