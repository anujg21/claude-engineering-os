---
name: review
description: Independent code review of a diff, run in a fresh subagent context. Ranks findings by severity, requires a concrete failure scenario for every claim, and separates blocking defects from optional suggestions. Phase 9 of the lifecycle.
when_to_use: A change is implemented and before it is merged or released. Also use when reviewing someone else's pull request, or when asked to check whether a diff matches its plan.
argument-hint: "[branch, commit range, or path]"
---

# Code review

The reviewer must not be the author. A model that just wrote the code is biased toward it
and will re-derive the same wrong assumption. Review always runs in a fresh context.

## Dispatching (main session)

Delegate to the `code-reviewer` agent. Give it exactly:

- The diff to review: `git diff main...HEAD`, a commit range, or the file list.
- The plan or design it should satisfy.
- What is out of scope.

Then act on the findings. Fix blocking ones, decide explicitly on the rest, and say which
ones you are not fixing and why. Do not silently drop findings.

A reviewer asked to find problems will find some. Weigh the finding, do not obey it.
Chasing every suggestion produces defensive code and abstraction nobody needed.

## Review procedure (reviewer)

Read the diff first, then read enough surrounding code to judge it. Do not review the diff
in isolation: most real defects are interactions with code that did not change.

Work in this order, because the early items are the ones that hurt.

**1. Correctness.** Does it do what the plan says? Off-by-one, inverted condition, wrong
operator precedence, unhandled null or empty, unhandled error path, wrong type coercion.
Trace at least one full path by hand rather than pattern-matching for it to look right.

**2. Edge cases.** Empty, one, many, maximum, just over. Concurrent callers. Duplicate
delivery. Partial failure halfway through a multi-step operation. Timeouts. What happens
if the process dies between two writes?

**3. Contract and compatibility.** Does this break an existing caller, a stored format, a
serialized message, or a public schema? Is the migration safe to deploy before the code
that needs it, and safe if the code rolls back?

**4. Security.** Injection, authorization checked per resource rather than per route,
secrets in the diff, sensitive data in logs and errors, unbounded input. Anything deeper
goes to `/security-review`; flag it and move on.

**5. Reliability and resource use.** Timeouts and bounded retries on external calls,
idempotency on anything retried, a bound on every loop and query, connections and files
closed, no unbounded growth in memory or in a table.

**6. Tests.** Do they test behavior or implementation? Would they fail if the bug the plan
was written for came back? Is there a test for each edge case named in the design? Is
anything skipped, sleeping, or order-dependent?

**7. Clarity.** Names that say what they mean, no dead code, no commented-out blocks, no
duplication that is about to diverge. This is the last section for a reason.

## Reporting

Rank by severity, most severe first. For every finding give:

- The file and line.
- One sentence on the defect.
- **A concrete failure scenario**: the input or state, and the wrong result or crash.
  If you cannot write one, it is not a defect. Delete it or downgrade it to a suggestion.
- The fix, briefly.

Severities:

- **Blocking**: wrong behavior, data loss, a security defect, a breaking contract change,
  or an unsafe migration. Must be fixed before merge.
- **Should fix**: a real problem with a bounded blast radius, or a missing test for a
  stated edge case. Fix now or file it with an owner.
- **Suggestion**: style, naming, structure. Optional, and say so.

State what you verified and could not fault, not only what you found. A review that lists
only complaints gives no signal about coverage. If the change is sound, say it is sound.
