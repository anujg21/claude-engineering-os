# Architecture decision records

One file per decision that is expensive to reverse. Records are immutable once accepted:
to change course, write a new one and mark the old one superseded.

Create one with `./scripts/new-adr.sh "Title"` or the `/adr` skill. Template:
`templates/adr.md`.

## Statuses

- `proposed` written, awaiting a human decision.
- `accepted` in force. Binding until superseded.
- `superseded by NNNN` replaced by a later record.
- `deprecated` no longer applies, and nothing replaced it.

## Index

Newest last. Keep this table current in the same change that adds the record.

| # | Decision | Status | Date |
| --- | --- | --- | --- |
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | accepted | 2026-08-19 |
