# Architecture principles

The standing position this system takes before it knows anything about your project.
The decision framework in `.claude/skills/architecture/decision-framework.md` applies these
to a specific choice. Replace this file with your own when you have opinions that differ;
that is the intended customization point.

## Start with a modular monolith

One deployable, real internal boundaries, one database. It is faster to build, far cheaper
to operate, and it can be split later if the boundaries are real. Distribution is a cost you
pay for organizational or scaling reasons, and you should be able to name which.

## Boundaries follow the domain, not the layers

Group code by what it does for the business, not by what kind of code it is. A directory of
every controller in the system tells you nothing about the system. Features that change
together should live together.

## One owner per piece of data

Exactly one component writes a given table or entity. Everyone else asks it. Shared write
access is how two components become one component that nobody can deploy independently.

## Dependencies point inward and never cycle

Domain logic knows nothing about HTTP, SQL, or your framework. Adapters depend on the core.
A cycle between modules is a design defect, and it is the thing that makes a monolith
impossible to split later.

## Explicit contracts at every boundary

Schemas, types, and versioned interfaces, not conventions and hope. If two things are
deployed separately, their contract is tested separately.

## Synchronous until asynchronous is required

Request and response is easier to reason about, easier to debug, and its failures are
visible. Queues buy decoupling and durability, and charge you in ordering, duplicates,
poison messages, and idempotency. Pay when you need the goods.

## Strong consistency by default

Eventual consistency is a requirement someone accepted, with a stated window and a defined
user experience inside it, not a side effect of an architecture diagram.

## Design for failure, including slow failure

Every dependency has a timeout, a bounded retry, and defined behavior when it degrades.
Slow dependencies cause more outages than dead ones, because everything upstream waits.

## Observable by construction

If you cannot tell from the outside whether a component is healthy, it is not finished.
Signals, logs at the boundaries, and one alert that means something are part of the build.

## Buy the undifferentiated parts

Auth, email, payments, search, queues, observability. Build what is your product. Isolate
each vendor behind an interface you own so the decision stays reversible.

## Evolve rather than rewrite

Architecture is a series of small, reversible moves. Expand and contract for schemas,
strangler patterns for components, flags for behavior. A big-bang rewrite is a bet that
you understand the old system perfectly, and you do not.

## Match the design to the team

A four-person team running twelve services is not shipping features. Prefer technology the
team already operates well over the one that scores better on a benchmark. Operational
capacity is a design constraint, the same as latency.
