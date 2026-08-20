# Testing strategy

Optimize for confidence per unit of maintenance. Coverage percentage is a weak proxy:
it is possible to reach ninety percent while testing nothing that matters, and a hundred
percent while shipping a broken system.

The question for every test is: what failure would this have caught, and how likely is
that failure?

## Choosing the level

**Unit tests** for logic with branches: calculations, validation, state machines, parsers,
policy decisions, anything with edge cases. Fast, numerous, no external dependencies.
This is where the arithmetic of your domain gets pinned down.

Do not write unit tests for code with no logic. A repository method that builds one query
and returns rows is tested by an integration test, not by asserting that a mock was called.

**Integration tests** for anything crossing a boundary you own: HTTP handlers with real
routing and serialization, repositories against a real database in a container, migrations
applied to a realistic schema, queue consumers with a real broker. This layer catches the
errors that actually reach production: wrong column type, missing index, serialization
mismatch, transaction scope, a migration that locks a table.

Most projects are under-invested here and over-invested in mocked unit tests.

**Contract tests** where two independently deployed things agree on a schema, and where
one can change without the other's tests running. Verify the provider against the
consumer's expectations in CI. If everything deploys together, a shared type is enough.

**End to end tests** only for the handful of flows whose failure means the product is down:
sign in, the primary transaction, payment. They are slow and brittle, so keep the number
small and deliberate. If you cannot name why each one exists, delete it.

**Property-based tests** where a rule must hold over a large input space: round-trip
serialization, parsers, sorting and merging, invariants like "balance never goes negative".
One property test can replace twenty examples and find the case you did not imagine.

**Load and performance tests** when a latency or throughput target exists in the
requirements, when a change touches a hot path, and before a launch with a known traffic
spike. Test against a realistic data volume; a query that is fast on a thousand rows tells
you nothing about ten million.

**Security tests** as automated dependency and secret scanning on every pipeline run,
authorization tests asserting that the wrong user gets denied on every protected resource,
and input fuzzing at the boundary for anything parsing untrusted data.

## What to test

For each unit of behavior: the ordinary case, the boundaries (empty, one, many, maximum,
just over the maximum), the invalid inputs, the concurrent case if concurrency is possible,
and the failure of each dependency.

The bugs that reach production are mostly in the last three.

## What not to test

- Framework and library behavior. It is not your code.
- Getters, constructors, and pass-through delegation.
- Implementation details: private methods, internal call order, the number of times a
  collaborator was invoked when the collaboration is not the contract.
- Generated code, unless you generated the generator.

## Regression

Every bug fix begins with a test that reproduces the bug and fails. It proves you found
the real cause, and it is the only thing stopping the bug from coming back. A fix without
one is a guess.

## Test data

Build objects through a factory or builder with sensible defaults, and set only the fields
the test is about in the test itself. A test that sets fifteen irrelevant fields hides
which one matters.

Fixtures are synthetic. Production data never enters the repository, including
"anonymized" exports, which usually are not.
