---
paths:
  - "**/migrations/**"
  - "**/migrate/**"
  - "**/models/**"
  - "**/entities/**"
  - "**/repositories/**"
  - "**/schema.{sql,rb,prisma}"
  - "**/*.sql"
---

# Data and migration rules

A schema change reaches production before the code that needs it and stays there after
the code that needed it is gone. Design for that window.

## Schema

- The database enforces what must always be true: not null, foreign keys, unique
  constraints, check constraints. Application-only invariants get violated eventually.
- Choose the narrowest type that fits. Money is never a float. Timestamps are stored in
  UTC with a timezone-aware type.
- Every table has a primary key and a creation timestamp. Soft deletes are a decision,
  not a default; if you use one, every query path must respect it.
- Index what you filter, join, and sort on. Every index costs write throughput, so add
  them from measured queries rather than from imagination.

## Migrations

- Migrations are forward-only and idempotent where the tool allows. Every migration has a
  tested rollback path, even if the rollback is "restore from backup and replay".
- Expand, migrate, contract. Add the new column, backfill it, dual-write, switch reads,
  then drop the old one in a later release. Never in one deploy.
- Never rename or drop a column in the same release that stops using it.
- Backfills run in batches with a bound, outside the migration transaction, and are
  restartable from where they stopped.
- Any migration on a large table states the expected lock behavior and duration before it
  runs. Locking a hot table for a table rewrite is an outage.
- Destructive migrations are an approval gate. See CLAUDE.md.

## Queries

- No unbounded queries. Every read has a limit or a cursor.
- No N+1 access patterns. Batch or join.
- Parameterized statements only. String-built SQL is a vulnerability regardless of the
  input's apparent source.
- Transactions cover exactly the operations that must be atomic. Never hold a transaction
  open across a network call to another service.

## Data handling

- Know the classification of every column you add: public, internal, confidential,
  personal, or regulated. Personal and regulated data needs a retention rule and a
  deletion path before it is stored.
- Test fixtures use synthetic data. Never copy production rows into the repository.
