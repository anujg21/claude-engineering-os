# Production readiness checklist

Ten dimensions. Each item needs evidence, not an assertion. Items marked **[B]** are
blocking: a failure means NO-GO.

## 1. Functional

- **[B]** Every acceptance criterion in the requirement has a passing test or a
  demonstrated result.
- **[B]** Edge cases named in the design are covered: empty, boundary, maximum, concurrent,
  duplicate.
- Error paths return the documented error, and the user-facing message is useful.
- Behavior with a stale or partially migrated client is defined.
- Feature flag exists where the change is risky, and the off path is tested.

## 2. Architecture

- The change fits the documented architecture, or an ADR records why it departs.
- No new cyclic dependency; no component writing another's data.
- No new service, datastore, or vendor introduced without a decision record.
- Interfaces are versioned and backward compatible, or the break is coordinated.

## 3. Security

- **[B]** No open blocking finding from `/security-review`.
- **[B]** No secrets in code, config, logs, images, or git history.
- **[B]** Authorization enforced per resource on every new path, including tenant isolation.
- **[B]** Untrusted input is parameterized, escaped, size-bounded, and schema-validated.
- Dependency scan is clean of known-exploited vulnerabilities on reachable paths.
- Sensitive data is classified, encrypted where required, and has a retention rule.
- Audit events exist for authentication, authorization, and privileged actions.

## 4. Reliability

- **[B]** Every external call has a timeout. Every retry is bounded, jittered, and only on
  idempotent operations.
- **[B]** Operations that a client may retry are idempotent, keyed explicitly.
- **[B]** The behavior when each dependency is down, and when it is slow, is defined and
  does not cascade.
- Degradation is graceful: the system sheds load or reduces function rather than failing
  entirely.
- No unbounded queue, loop, retry, or memory growth.
- Startup and shutdown are clean: readiness reflects actual readiness, in-flight work
  drains, no data is lost on restart.
- Concurrency and race conditions considered where two callers can hit the same row.

## 5. Observability

- **[B]** An alert fires on elevated error rate and on latency breach, and it reaches a
  person who can act.
- Structured logs at every boundary with correlation identifiers, and no sensitive fields.
- Metrics for the signals you would page on: rate, errors, duration, saturation.
- Tracing across service boundaries where more than one component is involved.
- A dashboard exists that answers "is this healthy right now" in one screen.
- Alerts are actionable. Every alert maps to a runbook entry; anything that cannot be acted
  on is deleted, not muted.

## 6. Performance

- **[B]** Meets the stated latency and throughput targets at realistic volume and
  concurrency, measured.
- Query plans reviewed for anything touching a large table; required indexes exist.
- No N+1 access on a hot path.
- Resource ceilings set: memory, connections, workers, and file descriptors.
- Behavior under overload is defined: shed, queue, or throttle, chosen deliberately.
- A regression guard exists for the property that was measured.

## 7. Data

- **[B]** Migrations are expand-and-contract, tested forward, and reversible without data
  loss.
- **[B]** Backups exist, and a restore has been performed and timed, not merely configured.
- Migration lock behavior and duration on the largest table are known.
- Backfills are batched, bounded, and restartable.
- Constraints enforce the invariants in the schema, not only in code.
- Data deletion and export paths work, where the data is personal or regulated.

## 8. Deployment

- **[B]** Rollback is a documented, tested command, with a known execution time and a
  defined behavior for the schema.
- The pipeline is the only path to production, and it gates on tests, scans, and plan review.
- Configuration is environment-driven and validated at startup.
- The artifact is versioned and immutable; the deployed version is identifiable at runtime.
- The rollout is progressive where the blast radius justifies it, with a health gate that
  halts it automatically.

## 9. Operations

- **[B]** A runbook exists in `docs/operations/runbooks/` for the known failure modes,
  written so someone woken at 3am can follow it.
- Ownership is named: who is on call, who escalates, and to whom.
- Capacity headroom is known, along with the leading indicator that it is running out.
- Cost at expected volume is estimated, and there is an alert on unexpected spend.
- Dependencies on other teams or vendors are documented with their support path.

## 10. Documentation

- Architecture overview reflects what was actually built.
- ADRs exist for the decisions that were contested, with current statuses.
- API documentation is generated from the contract and is current.
- `docs/project/STATE.md` reflects reality: what shipped, what is deferred, what is known
  to be broken.
- Known limitations and accepted risks are written down where the next engineer will find
  them.
