---
name: adr
description: Write, supersede, or look up an Architecture Decision Record in docs/decisions/. Use for any decision that is expensive to reverse, so the reasoning survives the people who made it.
when_to_use: A choice was made between real alternatives and someone will ask why in six months. Also use before changing anything an existing ADR covers, and when the user asks what was decided about a topic.
argument-hint: "[decision title, or a topic to look up]"
---

# Architecture decision records

An ADR captures one decision: the situation that forced it, the options, the choice, and
what it costs. It exists so the next person can tell the difference between a considered
tradeoff and an accident.

## Before writing

Search `docs/decisions/` first. If an ADR already covers this, you are either restating it,
which needs no new file, or contradicting it, which needs a superseding record and human
approval.

## Write one

```bash
./scripts/new-adr.sh "Use PostgreSQL as the primary datastore"
```

That copies `templates/adr.md` to the next number and opens the slot. Fill it in:

- **Context.** The forces at play: the requirement, the constraint, the load, the deadline.
  Written so it makes sense to someone who was not in the room. No solution here.
- **Options.** At least two that were genuinely viable, each with what it would have cost.
  A single option means this is not a decision, it is a note.
- **Decision.** One sentence, active voice, present tense. "We use X."
- **Rationale.** Why this option beat the others against the context above.
- **Consequences.** What becomes easy, what becomes hard, what you now have to operate,
  monitor, or pay for. Include the bad ones, especially the bad ones.
- **Revisit when.** The condition that should make someone reopen this. A load threshold,
  a cost, a date, a vendor change.

## Status lifecycle

`proposed` while it is being reviewed, `accepted` once a human agrees, `superseded by NNNN`
when a later record replaces it, `deprecated` when the decision no longer applies and
nothing replaced it.

Never edit the decision or rationale of an accepted ADR. Records are immutable so history
stays honest. To change course, write a new ADR that references the old one, and set the
old one's status to `superseded by NNNN`. Fixing a typo is fine.

Update `docs/decisions/README.md` in the same change so the index stays current.

## What deserves one

Yes: deployment shape, datastore, communication style, authentication model, framework,
public interface conventions, tenancy model, anything that constrains later decisions,
and any decision to take on significant technical debt on purpose.

No: library choices you could swap in an afternoon, naming conventions, file layout,
anything already covered by a rule in `.claude/rules/`.

If you cannot name a second option that a competent engineer would have picked, it is
probably not an ADR.

## Consulting them

Before proposing an architectural change, grep `docs/decisions/` for the area you are
about to touch. An accepted ADR is binding. Contradicting one without saying so is the
fastest way to lose a team's trust in this system.
