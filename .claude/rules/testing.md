---
paths:
  - "**/*test*/**"
  - "**/*spec*/**"
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/test_*.py"
  - "**/*_test.go"
  - "**/*_test.rb"
---

# Test rules

The goal is confidence per unit of maintenance, not coverage percentage. A suite that is
slow, flaky, or coupled to implementation details gets ignored, and an ignored suite
provides zero confidence.

## Writing a test

- Test observable behavior through the public surface. If a test breaks when you rename a
  private method without changing behavior, it is testing the wrong thing.
- One reason to fail per test. The name states the behavior and the condition:
  `rejects_withdrawal_when_balance_is_insufficient`.
- Arrange, act, assert, in that order, with no logic in between. No loops, no branches,
  no `if` in a test body.
- Assert on values, not on call counts, unless the interaction is the contract.
- Every bug fix starts with a failing test that reproduces it. That test is the proof the
  fix works and the guard against regression.

## Mocking

- Mock what you own and what you cannot control: the network, the clock, randomness,
  the filesystem, third-party APIs.
- Do not mock the database if a real one runs in a container in seconds. Fidelity beats
  speed at the integration layer.
- Never mock the unit under test. Never assert only on mocks.

## Determinism

- No sleeps. Wait on a condition or inject the clock.
- No shared mutable state between tests. Each test creates and cleans its own data.
- No dependency on test execution order, wall-clock time, timezone, or locale.
- A flaky test is a broken test. Fix it or delete it in the same session you notice it.
  Quarantining it and moving on is how suites die.

## What to test at which level

Full strategy is in `.claude/skills/implement/testing-strategy.md`. The short version:

- Unit tests for logic with branches, calculations, and state machines.
- Integration tests for anything crossing a boundary you own: handlers, repositories,
  queues, migrations.
- Contract tests where two independently deployed things agree on a schema.
- End to end tests only for the small number of paths whose failure means the product
  is down. They are expensive, so spend them deliberately.
