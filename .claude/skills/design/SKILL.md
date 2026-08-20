---
name: design
description: Produce a technical design for one feature before any code is written. Covers the interface contract, data model, control flow, failure modes, and the test approach, and writes docs/architecture/designs/<feature>.md. Phase 5 of the lifecycle.
when_to_use: A feature is agreed and its shape is not obvious: it crosses a boundary, changes a schema, adds an endpoint or an integration, or touches money, auth, or personal data. Skip it for changes whose diff you could describe in one sentence.
argument-hint: "[feature name]"
---

# Technical design

Input: a requirement plus the architecture overview. Output:
`docs/architecture/designs/<feature>.md`, filled from `templates/tech-design.md`.

The purpose is to make the expensive mistakes on paper. If the design takes longer than
the implementation, the feature did not need a design.

## 1. Ground yourself in what exists

Read the relevant requirement, the architecture overview, and any ADR covering this area.
Then read the code you are about to change. Name the specific files and interfaces in the
design. A design written without reading the code produces a plan that does not apply.

## 2. Design the contract first

Whatever the caller sees: the endpoint and its schema, the function signature, the event
shape, the CLI. Decide the contract before the internals, because the contract is what you
cannot change later.

Include validation rules, the full error set with codes, authorization requirements, and
idempotency behavior. Follow `.claude/rules/api-design.md`.

## 3. Data

- New or changed tables, columns, types, constraints, and indexes.
- The migration path, stated as expand, backfill, contract steps with which release each
  lands in.
- Whether existing rows need a backfill, how long it takes, and whether it is restartable.
- Data classification for anything new, and its retention rule.

## 4. Control flow

Walk the happy path, step by step, naming the components involved. A short Mermaid sequence
diagram beats three paragraphs. Then state where the transaction boundaries are and what
is atomic with what.

## 5. Failure modes

This is the section that separates a design from a wish. For each external dependency and
each step that can fail:

- What happens when it is down. What happens when it is slow, which is the harder case.
- Timeout, retry policy, and whether the operation is safe to retry.
- What the user sees. What gets logged. What gets alerted on.
- What state the system is left in if the process dies exactly here, and how it recovers.

Then ask: what does a malicious caller do with this? Rate limits, authorization on every
resource, and input bounds are part of the design, not a later hardening pass.

## 6. Observability and performance

- The signals that will tell you this feature is working in production, and the one you
  would alert on.
- Expected volume, and the latency budget for the path, split across its steps.
- The query plan for anything reading a large table.

## 7. Test approach

State what will be tested at which level and what the acceptance check is, so the plan can
turn it into tasks. See `../implement/testing-strategy.md`.

## 8. Alternatives

One paragraph on what else was considered and why it lost. If a decision here is expensive
to reverse, it needs an ADR, not a paragraph.

## Exit criteria

- The contract is complete enough that a caller could be written against it today.
- Every external call has a timeout and a stated failure behavior.
- The migration is expand and contract, with the releases named.
- Authorization is decided per resource, not per route.
- Someone else could implement this without asking you a question. That is the test.
