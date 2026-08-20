---
name: implement
description: Execute the next task from an implementation plan: write the test, write the code, run the verification, update the plan and project state. Enforces one task at a time with evidence. Phases 7 and 8 of the lifecycle.
when_to_use: A plan exists in docs/project/plans/ and it is time to build. Also use to resume implementation in a fresh session, since it starts by re-reading state rather than assuming context.
argument-hint: "[plan name or task number]"
---

# Implement

One task at a time, verified, with the plan and state updated as you go. The point is that
work is durable across sessions and that "done" means something a machine confirmed.

## Loop

**1. Orient.** Read `docs/project/STATE.md` and the plan. Identify the next unchecked task.
If the plan disagrees with the code, trust the code and fix the plan before working.

**2. Confirm the task is still right.** If what you now know makes the task wrong, say so
and adjust the plan first. Do not quietly implement something else.

**3. Write the failing test first** where a test is the right check. Run it and confirm it
fails for the reason you expect. A test that passes before the code exists is testing
nothing, and finding that out later costs a day.

For work where a unit test is not the right check, such as a migration, a config change, or
a UI adjustment, decide the check now and state it: a script, a query, a screenshot
comparison, a log line. There is always a check.

**4. Write the smallest code that passes.** Follow the design. Follow the rules in
`.claude/rules/` that apply to the paths you are touching. Do not refactor unrelated code,
do not add abstraction for a second caller that does not exist, and do not fix things you
notice along the way. Note them in the plan's discovered-work list instead.

**5. Verify.** Run `./scripts/verify.sh`, or the narrower check for a fast loop, and finish
with the full one. Paste the actual output. If it fails, fix the cause rather than the
symptom, and never weaken a test to make it pass.

**6. Refactor with the check green.** Names, duplication, dead code. Behavior does not
change, so the check stays green throughout.

**7. Record.** Tick the task in the plan, update `docs/project/STATE.md` with what was
completed, what was learned, and anything discovered. Commit with a message that says what
and why.

Then take the next task. Stop at any checkpoint the plan marks, and at any approval gate
in CLAUDE.md.

## Rules that do not bend

- No task is complete without a check that ran and passed, with the output shown.
- No commented-out code, no `TODO` without an owner and a plan entry, no skipped or
  quarantined tests left behind.
- No secrets, no credentials, no production data in fixtures.
- No new dependency without saying why in the commit and, if it is significant, an ADR.
- If you are stuck after two genuinely different attempts, stop and say what you tried,
  what you observed, and what you think is happening. Do not keep flailing at it; the
  context is now full of failed approaches and a fresh start will beat a third attempt.

## When the plan is wrong

Plans are written before contact with the code, so some will be wrong. Say so explicitly,
explain what you found, propose the change, and update the plan. Silent deviation is the
failure mode that makes plans useless.

## Testing depth

`testing-strategy.md` in this directory covers which kind of test to write for which kind
of change, and what not to test. Read it when the right level is not obvious.

## Definition of done

`docs/engineering/definition-of-done.md`. A task is not done because the code exists.
