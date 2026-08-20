---
name: discovery
description: Turn a rough idea into a product brief and testable requirements. Interviews the user, separates the problem from the solution, and writes docs/product/brief.md and docs/product/requirements.md. Phases 0 to 2 of the lifecycle.
when_to_use: The user describes something they want to build in a sentence or two, asks to scope a new product or feature, or hands over a vague idea with no written requirements. Also use when an existing requirements document has open questions blocking design.
argument-hint: "[one-line idea, or path to existing notes]"
---

# Discovery

Input: an idea. Output: `docs/product/brief.md` and `docs/product/requirements.md`, and
a written list of what is still unknown.

The failure mode here is starting to design a solution before anyone has stated the
problem, the user, and how you would know it worked. Hold that line.

## 1. Understand before proposing

Read `docs/project/STATE.md` and anything already in `docs/product/`. If this is a feature
inside an existing product, read the architecture overview too, so requirements do not
contradict what exists.

## 2. Interview

Use `AskUserQuestion`. Ask in small batches, hardest question first. Do not ask what you
can read from the repository, and do not ask permission to think.

Cover, in this order:

1. **Problem.** Who has it, how do they handle it today, what does it cost them?
2. **User.** Who is the primary user, and who else is affected? Name one real person or
   role, not a segment.
3. **Success.** What measurable change means this worked? A number and a timeframe.
4. **Scope.** What is deliberately out of scope for the first release?
5. **Constraints.** Deadline, budget, team size and skills, existing systems it must live
   with, compliance or data residency obligations.
6. **Risk.** What would make this fail? What is the riskiest assumption?

Push on vague answers once. "Faster" becomes "p95 under 300ms", "users" becomes a role.
If the user genuinely does not know, that is an open question, not a blank to fill in.

## 3. Write the brief

Fill `templates/product-brief.md` into `docs/product/brief.md`. It answers why this exists
and what winning looks like. It contains no technology choices. If you find yourself
writing a database name, you are in the wrong document.

## 4. Write the requirements

Fill `templates/requirements.md` into `docs/product/requirements.md`.

Each functional requirement is a numbered, testable statement with acceptance criteria in
given/when/then form. "The system should be reliable" is not a requirement. "A submitted
order is retrievable within 1 second and survives a service restart" is.

Cover explicitly, because these are the ones that get skipped and then rewrite the
architecture later:

- Expected volume now and in 12 months, and peak versus average.
- Latency and availability targets, stated as numbers with a measurement window.
- Data sensitivity, retention, and deletion obligations.
- Who is allowed to do what, as roles and permissions.
- Failure behavior: what the user sees when a dependency is down.
- Every integration, and whether it is synchronous.

## 5. Close the loop

- Mark every assumption in the documents with `ASSUMPTION:` and every gap with `OPEN:`.
- List the open questions back to the user, ranked by how much design they block.
- Update `docs/project/STATE.md`: phase, documents produced, open questions.

## Exit criteria

Do not move to `/architecture` until:

- The problem statement fits in three sentences and names a user.
- Success has at least one number attached.
- Every functional requirement has acceptance criteria.
- Volume, latency, availability, and data sensitivity all have stated values, even if the
  value is a recorded assumption.
- No `OPEN:` item remains that would change the shape of the system.

## Ask versus assume

Ask about anything a user, a regulator, or a budget owner decides: scope cuts, target
users, compliance, spend, deadlines. Assume freely on anything reversible and internal,
write the assumption down, and move on. Never invent a number for a compliance or
retention requirement.
