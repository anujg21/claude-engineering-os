# Requirements: <name>

Status: draft | agreed
Source: docs/product/brief.md
Last updated: <YYYY-MM-DD>

## Functional requirements

Each is numbered, testable, and traceable into the plan. Priority is must, should, or
could. Acceptance criteria are in given/when/then form and are what the tests assert.

### FR-1 <short title>

Priority: must
As a <role>, I need <capability>, so that <outcome>.

Acceptance criteria:

- Given <state>, when <action>, then <observable result>.
- Given <error state>, when <action>, then <specific error behavior>.

Notes: edge cases, permissions, anything a reader would otherwise assume.

### FR-2 <short title>

...

## Non-functional requirements

These decide the architecture, so a missing value here becomes an expensive rewrite later.
Record an assumption rather than leaving a blank.

| Area | Requirement | Value | Source |
| --- | --- | --- | --- |
| Volume today | | | |
| Volume in 12 months | | | |
| Peak versus average | | | |
| Latency | p95, p99 for the main paths | | |
| Availability | target and measurement window | | |
| Durability | what must never be lost | | |
| Consistency | where stale reads are acceptable, and for how long | | |
| Data sensitivity | classification of what is stored | | |
| Retention and deletion | how long, and how it is deleted | | |
| Compliance | regimes that apply | | |
| Auditability | what must be reconstructable, and for how long | | |
| Supported clients | versions, browsers, locales | | |
| Cost ceiling | monthly, at expected volume | | |

## Access control

| Role | Can do | Cannot do |
| --- | --- | --- |
| | | |

## Integrations

| System | Direction | Synchronous | Failure behavior | Owner |
| --- | --- | --- | --- | --- |
| | | | | |

## Failure behavior

What the user sees when each dependency is unavailable. What is queued, what is rejected,
what is degraded.

## Out of scope

## Open questions

| # | Question | Blocks | Owner | Status |
| --- | --- | --- | --- | --- |
