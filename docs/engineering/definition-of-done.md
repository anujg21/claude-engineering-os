# Definition of done

"Done" is not "the code exists". Use the level that matches what you finished.

## A task is done when

- The behavior it describes works, and a check proves it.
- `./scripts/verify.sh` passes, and the output was shown rather than assumed.
- The check would fail if the change were reverted. A test that passes either way tests
  nothing.
- Edge cases named in the design are covered: empty, boundary, invalid, concurrent.
- Errors are handled at the level that can do something about them, with context preserved.
- No secrets, no commented-out code, no `TODO` without an owner and a plan entry, no
  skipped tests.
- The rules in `.claude/rules/` for the paths you touched are followed.
- The plan is ticked and `docs/project/STATE.md` reflects reality.
- It is committed, with a message saying what changed and why.

## A feature is done when

Everything above, for every task, plus:

- Every acceptance criterion in the requirement passes.
- `/review` has run and no blocking finding is open.
- `/security-review` has run if it touches auth, secrets, input, external calls, payments,
  or personal data, and no blocking finding is open.
- Performance is within budget where a budget exists, measured rather than assumed.
- Migrations are expand and contract, tested forward, and reversible.
- Logs, metrics, and at least one alert exist for the new path.
- Documentation is current: the design matches what was built, the API docs are generated
  from the contract, and any decision that was contested has an ADR.
- Whatever was discovered and deliberately not fixed is recorded with an owner.

## A release is done when

Everything above, plus:

- `/production-readiness` returned GO or a CONDITIONAL GO whose conditions have owners and
  dates.
- A human approved the deployment.
- The behavior was verified in production directly, not inferred from a green pipeline.
- Error rate, latency, and background workers are within their normal bands after enough
  traffic to be meaningful.
- Rollback was tested and its duration is known.
- A runbook exists for the failure modes you know about.
- The release record and `docs/project/STATE.md` are updated.

## Not done

- "It works on my machine."
- "The tests pass except for that one, which was already failing."
- "I could not run it, but the change is straightforward."
- "Monitoring is a follow-up."
- "I will write the migration rollback if we need it."

Each of these is a normal, defensible position. State it plainly as an open item. What is
not acceptable is calling it done.
