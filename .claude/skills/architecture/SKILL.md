---
name: architecture
description: Choose a system architecture from stated requirements, justify it against alternatives, and record it in docs/architecture/overview.md plus ADRs. Includes an independent architecture review before the design is treated as settled. Phases 3 and 4 of the lifecycle.
when_to_use: Starting a new system or a major subsystem, replacing a component, deciding between a monolith and services, choosing a datastore or a communication style, or when a change no longer fits the current structure.
---

# Architecture

Input: `docs/product/requirements.md`. Output: `docs/architecture/overview.md`, one ADR per
consequential decision, and a review verdict.

Architecture is the set of decisions that are expensive to reverse. Everything else is
implementation, and you should not spend this phase on it.

## 1. Extract the drivers

From the requirements, list the constraints that actually force the design: load profile,
latency and availability targets, consistency requirements, data sensitivity, team size
and skills, cost ceiling, deadline, and the systems this must integrate with.

If a driver is missing, go back to `/discovery`. Do not invent a load number to justify a
design you already have in mind. That is the most common way agents produce a distributed
system nobody needed.

## 2. Decide the shape

Work through `decision-framework.md` in this skill directory. It walks the deployment
shape, communication style, consistency model, and state placement, each as a question
with a default and the evidence needed to depart from the default.

The starting position is a modular monolith with clear internal boundaries, a single
relational database, synchronous calls, and managed services for anything undifferentiated.
Move away from it only where a stated requirement makes it fail. Write down which
requirement forced each departure.

## 3. Name the boundaries

For each module or service:

- The one thing it owns, in a sentence.
- Its interface: the operations, the data it exposes, and the guarantees it makes.
- What it depends on, and in which direction.
- What it owns exclusively in the datastore. Two components writing the same table are one
  component with extra steps.

Then check: can each boundary be tested on its own, deployed without coordinating with
another team, and understood by one person? If not, redraw it.

## 4. Cross-cutting concerns

Decide these once, at this level, or every feature will decide them differently:
identity and authorization model, error and retry semantics, idempotency strategy,
observability (what is logged, measured, traced), configuration and secrets, data
lifecycle and retention, and the failure behavior of each dependency.

## 5. Write it down

Fill `templates/architecture-overview.md` into `docs/architecture/overview.md`. Include a
context diagram and a component diagram as Mermaid, the boundary table, cross-cutting
decisions, and an explicit list of what this architecture is not good at.

Write an ADR with `/adr` for each decision that was genuinely contested: deployment shape,
datastore, communication style, and any technology chosen over a viable alternative. The
overview says what; the ADRs say why, and they are what a future engineer reads before
undoing your work.

## 6. Independent review

Delegate to the `architecture-reviewer` agent. Give it the requirements, the overview, and
the ADRs. It reviews without your reasoning, which is the point.

Act on the findings before proceeding. If you disagree with a finding, record the
disagreement and the reason in the relevant ADR rather than dropping it silently.

## Exit criteria

- Every driver in step 1 maps to something in the design.
- Every departure from the default shape cites the requirement that forced it.
- Every component has one owner, one responsibility, and no cyclic dependency.
- ADRs exist for the contested decisions and are marked accepted.
- The reviewer's blocking findings are resolved.
- A named human has approved the shape. Architecture is an approval gate.
