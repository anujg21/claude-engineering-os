# Engineering principles

Why the rules are what they are. Rules go in `.claude/rules/` where they load next to the
code. This file is for humans deciding whether a rule still makes sense.

## Correctness is not negotiable, everything else is a tradeoff

Speed, elegance, and coverage are all negotiable against each other. Producing a wrong
answer is not. A system that is slow and known to be correct can be fixed; a system that
is fast and quietly wrong destroys trust in every number it produces.

## Optimize for the reader, and the reader is a stranger

Code is read far more often than it is written, usually by someone without the context that
produced it, often under pressure. Prefer the obvious construction over the clever one.
If a solution needs a paragraph of explanation to be safe to change, it is the wrong solution.

## The simplest thing that could work, and no simpler

Complexity is paid for daily, in onboarding, debugging, and operations. Every abstraction,
dependency, service, and configuration option must earn its place against a real
requirement. "We might need it" is not one.

The opposite failure is real too: skipping a timeout, an index, or an authorization check
is not simplicity, it is an unpaid debt with a due date.

## Make the failure modes explicit

Most production incidents come from a path nobody thought about, not from the path everyone
reviewed. Design the failure behavior at the same time as the happy path. Slow is harder
than down, and partial failure is harder than both.

## Reversibility over prediction

You will be wrong about the future. Prefer decisions that are cheap to undo: a modular
monolith you can split, a schema change you can roll back, a feature behind a flag, a
vendor behind an interface you own. Where a decision cannot be made reversible, write an
ADR and slow down.

## Verification beats confidence

A belief that code works has no value. A check that runs and passes has value, and it keeps
having it after everyone forgets why the code is shaped this way. That is why every task in
this system names a check, and why the check is a script rather than a habit.

## Boundaries are the design

The parts of a system that survive are its interfaces. Get the contract and the ownership
of data right and the internals can be rewritten at leisure. Get them wrong and no amount
of clean code inside the boundary will save you.

## Feedback loops should be short

The gap between making a mistake and finding out is the single biggest driver of
engineering cost. Fast tests, small changes, progressive rollouts, and alerting that
catches a problem in minutes are all the same investment.

## Security is a property of the design

Controls added after the fact protect the paths someone remembered. Deciding the trust
boundaries, the authorization model, and the data classification during design is what
makes the rest of the controls consistent.

## Operations is part of the product

Something that cannot be observed, rolled back, or explained at 3am is not finished, no
matter how well it works on the happy path. The runbook, the alert, and the rollback are
deliverables, not follow-up work.

## Write the decision down

Decisions that live only in someone's memory get reversed by accident, usually by a person
who assumed the current shape was arbitrary. An ADR is cheap. Rediscovering why a
constraint exists, in production, is not.

## Leave the campsite tidy, not renovated

Fix the thing you touched. Note the rest. Opportunistic refactoring inside a feature change
hides the feature in the diff and makes the review useless. Both changes were probably
right; doing them together was not.
