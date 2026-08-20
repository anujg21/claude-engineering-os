---
name: performance-review
description: Measure and analyze latency, throughput, and resource use against stated budgets before shipping. Finds algorithmic and query problems by measurement rather than by inspection. Phase 11 of the lifecycle.
when_to_use: A change touches a hot path, a query, a loop over user-scaled data, or a new external call. Also before a launch, when a latency or throughput target exists in the requirements, or when someone reports that something feels slow.
argument-hint: "[endpoint, path, or component]"
---

# Performance review

Measure first. An agent reading code will confidently identify the wrong bottleneck,
because the real one is usually a query plan, a serialization, or a network round trip
that the source does not show.

## 1. State the budget

From the requirements: the target latency at a percentile, the throughput, and the
resource ceiling. Without a number there is no review, only opinions. If no target exists,
set one with the user before continuing.

Use percentiles, never averages. p50 tells you how it feels on a good day; p95 and p99 tell
you how often it is bad, and those are the users who complain.

## 2. Measure the current state

- Reproduce with realistic data volume. Performance on a thousand rows predicts nothing
  about ten million; the plan changes, not just the constant factor.
- Reproduce with realistic concurrency. Serial timing hides lock contention, pool
  exhaustion, and queueing, which is where most production latency comes from.
- Record the numbers before any change, so improvement is a measurement rather than a claim.

## 3. Find the actual cost

Work from the outside in:

- **Round trips.** Count queries and external calls per request. N+1 access is the single
  most common cause of slowness in application code, and it is invisible in a code read.
- **Query plans.** Read the plan for every query on a large table. Sequential scans,
  sorts that spill, and missing index usage show up here and nowhere else.
- **Payload size.** Over-fetching columns, unbounded result sets, and serialization of
  objects nobody reads.
- **Algorithmic cost.** Nested iteration over user-scaled collections, repeated work inside
  a loop that could be hoisted, sorting when a partial selection would do.
- **Waiting.** Serial calls that could run concurrently, synchronous work that belongs in a
  background job, lock scope wider than the operation needs, and connection pool limits.
- **Allocation.** Large object churn, copies of collections, unbounded caches, and leaks
  that show up as a slow climb rather than a spike.

## 4. Fix in order of leverage

1. Do not do the work: cache, precompute, or remove the requirement.
2. Do less work: better query, narrower selection, an index, batching, pagination.
3. Do the work elsewhere: background job, queue, asynchronous path.
4. Do the work in parallel.
5. Only then, make the work faster.

Micro-optimization at the top of that list is wasted effort. A missing index beats a week
of tuning.

## 5. Prove it

Re-measure with the same setup. Report before and after with the percentile and the
conditions. State what got worse, because most optimizations trade something: memory,
write throughput, cache invalidation complexity, or code clarity.

Add a regression guard for anything that mattered: an assertion on query count, a timing
budget in an integration test, or a load test in the pipeline. Without one, the regression
returns within a few releases.

## Reporting

For each finding: where it is, the measurement that shows it, the cause, the expected
improvement, and the cost of the fix. Rank by measured impact.

Do not report a finding you did not measure. "This loop looks inefficient" is not a
performance finding, it is a code review comment.
