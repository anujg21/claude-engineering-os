---
number: 0001
title: Record architecture decisions
status: accepted
date: 2026-08-19
deciders: repository owner
supersedes:
superseded-by:
tags: [process]
---

# 0001. Record architecture decisions

## Context

Decisions that shape a system are made once, usually under time pressure, and then live in
the memory of whoever made them. Six months later nobody can tell the difference between a
deliberate tradeoff and an accident. The result is predictable: people either work around
a constraint they do not understand, or they remove it and rediscover the reason in
production.

An agent makes this sharper. A coding agent starts each session without the reasoning that
produced the current shape, and it is confident enough to change that shape. Without a
written record it will optimize away a constraint that exists for a reason nobody wrote down.

## Options considered

### Option A: no formal record

Rely on commit messages, pull request discussion, and the code itself.

Cheapest at the moment of the decision. The context is scattered across tools, is not
searchable in the repository, and disappears when a platform is migrated or an account is
closed. Agents cannot use it because it is not in the working tree.

### Option B: a single architecture document

One living document describing the current design.

Better than nothing, and this system keeps one at `docs/architecture/overview.md`. But it
describes what is, not why, and editing it destroys the history of what was rejected. The
rejected options are usually the valuable part.

### Option C: architecture decision records

One immutable file per decision, numbered, in the repository, with context, options,
decision, and consequences.

Costs about fifteen minutes per decision. Versioned with the code, greppable by both people
and agents, and the reasoning survives the people.

## Decision

We record architecture decisions as ADRs in `docs/decisions/`, one file per decision,
immutable once accepted, superseded rather than edited.

## Rationale

The cost is small and lands on the person with the most context, at the moment they have
it. The benefit lands on everyone who touches the system afterwards, including agents that
start every session with no memory.

Immutability matters more than it seems. An edited record loses the fact that the decision
changed, which is often the most useful thing in the file.

## Consequences

**Becomes easier:** understanding why the system is shaped this way; onboarding; agents
checking constraints before proposing changes; disagreeing with a past decision on the
record rather than by accident.

**Becomes harder:** nothing about writing code. Some friction at decision time, which is
the point.

**Now required:** keeping the index in `docs/decisions/README.md` current, and consulting
existing records before proposing architectural changes.

**Accepted risks:** records go stale if nobody supersedes them. Mitigated by the "revisit
when" section in the template and by checking statuses during production readiness reviews.

## Revisit when

Never, most likely. If the practice is being ignored, the problem is the culture around it,
not the format, and replacing it with something lighter will be ignored too.
