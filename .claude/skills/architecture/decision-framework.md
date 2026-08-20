# Architecture decision framework

Each question has a default. Defaults are chosen because they are cheap to reverse and
cheap to operate. Departing from a default requires a stated requirement, not a preference,
and the departure goes in an ADR.

Complexity you add here is paid for every day by whoever operates the system.

---

## 1. Deployment shape

**Default: a modular monolith.** One deployable, clear internal module boundaries,
one database, modules talking through in-process interfaces.

Move to separate services only when at least one is true and written down:

- Two parts have genuinely different scaling profiles and the cheap fix (scale the whole
  thing, cache, or move work to a queue) has been measured and rejected.
- Independent teams are blocked on each other's release cadence, and the number of teams
  is greater than one.
- A part has a materially different availability or compliance boundary, for example
  cardholder data or a regulated workload.
- A part must be written in a different runtime for a reason that is not preference.

Signals you are about to make a mistake: "microservices are best practice", "we might need
to scale later", "it is cleaner". None of these is a requirement. A distributed system
converts local function calls into network calls that can fail partially, and buys you
distributed tracing, versioned contracts, eventual consistency, and a much harder local
development story. The cost is real and immediate; the benefit is speculative.

If you do split: each service owns its data exclusively, no shared database, and the
number of services stays at the smallest number that satisfies the reasons above.

**Serverless functions** fit spiky, stateless, event-driven work with tolerance for cold
starts. They fit poorly for long-running work, heavy local state, chatty inter-component
calls, and anything where per-invocation cost at your volume exceeds a small instance.

---

## 2. Communication style

**Default: synchronous request and response, with timeouts and bounded retries.** It is
easier to reason about, easier to debug, and the failure is visible.

Go asynchronous through a queue or event log when:

- The caller does not need the result to continue.
- The work is slow, bursty, or must survive the consumer being down.
- Several consumers need the same fact and you want to stop editing the producer to add
  each one.

The cost of asynchronous: ordering, duplicate delivery, retry storms, poison messages,
and the need for idempotent consumers and a dead letter path. If you choose it, decide
those five now, not in production.

Never use a queue purely to decouple deployment. That is what a versioned interface is for.

---

## 3. Consistency

**Default: strong consistency inside one transactional boundary.**

Only accept eventual consistency where the requirement tolerates it, and then state the
window and what the user sees inside it. "The dashboard may lag by up to 30 seconds" is a
requirement; "eventually consistent" alone is a shrug.

If an operation spans two stores, you have a distributed transaction problem. In order of
preference: redraw the boundary so it does not, use the outbox pattern with idempotent
consumers, or use an explicit saga with compensating actions. Two-phase commit is almost
never the answer.

---

## 4. State and storage

**Default: one relational database, normalized, with the constraints enforced in the schema.**

Reach further only on evidence:

- A document store when the shape is genuinely variable per record and you never query
  across the variable parts.
- A cache when a measured read is too slow, and only with a stated invalidation rule
  and correct behavior when the cache is empty or stale.
- A search index when relevance ranking or full-text is a product requirement, treated as
  a derived store that can be rebuilt from the source of truth.
- Object storage for blobs. Blobs never go in the database.
- A time-series or analytical store when analytical queries start hurting the operational
  one, and not before.

Every additional store is another thing to back up, secure, migrate, monitor, and keep
consistent. Count them; the number should embarrass you if it grows.

---

## 5. Build versus buy

**Default: buy or use a managed service for anything that is not your product.** Auth,
email, payments, search, queues, observability, feature flags.

Build it yourself only when the capability is the product, when no option meets a hard
compliance or latency constraint, or when the cost at your scale is genuinely worse.
Include operating cost, not just licence cost, on both sides.

Vendor risk is real: check the exit path and the data export before you commit, and
isolate the vendor behind an interface you own.

---

## 6. Boundaries within the code

Regardless of the deployment shape:

- Domain logic does not import transport, storage, or framework types.
- Each module exposes an interface and hides its storage.
- Dependencies point one way. Cycles between modules are a design defect, not a style issue.
- A module that needs another module's private data means the boundary is wrong.

A modular monolith with these properties can be split later in weeks. A monolith without
them cannot be split at all, which is the actual reason teams end up rewriting.

---

## 7. Operability, decided now

An architecture that cannot be observed or rolled back is not finished:

- How do you know it is healthy? Name the signals.
- How do you roll back a bad release, including a schema change?
- What happens when each dependency is slow rather than down? Slow is the harder case.
- What is the blast radius of each component failing, and does it degrade or collapse?
- Who gets paged, and what does the runbook tell them to do?

---

## 8. Cost and team

- Estimate the monthly cost of the design at expected volume. If nobody has done that
  arithmetic, the design is not finished.
- Match the design to the team you have. A four-person team running twelve services is a
  team that is not shipping features.
- Prefer the technology the team already operates well over the one that scores better on
  paper.
