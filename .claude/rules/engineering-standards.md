# Engineering standards

These apply to all code in this repository. Language-specific conventions live in the
rules files scoped to those paths.

## Naming and structure

- Name by intent, not by pattern. `PaymentRetryPolicy` beats `PaymentManager`.
- One reason to change per module. If you cannot describe a file's job in one sentence,
  it does two jobs.
- Dependencies point inward: domain logic never imports transport, storage, or framework
  code. Adapters depend on the core, not the reverse.
- No cyclic dependencies between modules. If two modules need each other, the shared part
  belongs in a third.

## Errors

- Fail fast on programmer errors, handle expected failures explicitly. A caught exception
  that is logged and swallowed hides a bug.
- Errors carry context: what operation failed, on what identifier, and why. Never lose the
  original cause when wrapping.
- Do not use exceptions or error returns for normal control flow.
- Every external call has a timeout. Every retry has a bound and jitter. Retries are only
  safe on idempotent operations.

## Logging and observability

- Structured logs with a consistent key set. One event per meaningful state change,
  not one per line of code.
- Never log secrets, tokens, full request bodies, or personal data. Log identifiers.
- Log at the boundary you own: incoming request, outgoing call, background job start
  and finish, and every error with its cause.
- Emit a metric for anything you would page on. If there is no signal, there is no SLO.

## Configuration

- Configuration comes from the environment. No environment branching inside business
  logic, no `if (env === "production")`.
- Validate configuration once at startup and fail loudly if it is missing or malformed.
  A service that boots with a broken config and fails at request time is worse than one
  that refuses to boot.
- Defaults are safe defaults: secure, low limit, off.

## Dependencies

- Adding a dependency is a decision. Check maintenance activity, transitive weight,
  license, and whether the standard library already does it.
- Pin versions and commit the lockfile.
- No dependency for something you can write in twenty lines and will have to debug anyway.

## Comments and documentation

- Comment why, not what. The code says what.
- A comment that repeats the function name is noise. Delete it.
- Update the doc in the same change as the code. A stale doc is worse than none.

## Git

- One logical change per commit. Commit messages say what changed and why, in the
  imperative mood.
- Never commit generated files, secrets, or large binaries.
- Rebase your own branch freely, never rewrite shared history.
