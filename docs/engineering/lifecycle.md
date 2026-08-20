# The lifecycle

Eighteen phases, numbered 0 to 17, from an idea to a system running in production and
being changed safely.
This is the reference. The routing table in CLAUDE.md is the short version.

Phases are a sequence, not a ceremony. Skip what a change does not need, and say which
phases you skipped and why. A one-line bug fix goes 7, 8, 9, 15. A new payments
integration goes through all of them.

Three rules hold across every phase:

1. **Every phase produces a written artifact.** If nothing was written, the phase did not
   happen, and the next session will not know what was decided.
2. **Exit criteria are checked before moving on.** Not met means not finished. Moving on
   with an open question is how a wrong assumption reaches production.
3. **A gate means stop and ask a human.** Not "mention it and proceed".

---

## Phase 0: Idea

**Purpose** Capture what someone wants before it evaporates.
**Input** A sentence.
**Output** A line in `docs/project/STATE.md`, or a note in `docs/product/`.
**Owner** Main session.
**Exit** The idea is written down somewhere a stranger could find it.
**Ask** Nothing yet.

## Phase 1: Product discovery

**Purpose** Establish the problem, the user, and what success means, before any solution.
**Input** The idea.
**Output** `docs/product/brief.md`.
**Owner** `/discovery`.
**Validation** The problem statement names a user and a cost. Success has a number.
**Exit** The brief contains no technology choices, and the riskiest assumption is named.
**Ask** Scope, target user, budget, deadline, compliance. Never guess at these.
**Assume** Nothing that a user or a budget owner decides.

## Phase 2: Requirements

**Purpose** Make the desired behavior testable and surface the constraints that shape the
architecture.
**Input** The brief.
**Output** `docs/product/requirements.md`.
**Owner** `/discovery`.
**Validation** Every functional requirement has given/when/then acceptance criteria. Volume,
latency, availability, consistency, data sensitivity, and retention all have values.
**Exit** No open question remains that would change the shape of the system.
**Ask** Any missing non-functional value that has a legal, financial, or contractual answer.
**Assume** Reversible internal choices, marked `ASSUMPTION:` in the document.

## Phase 3: Architecture

**Purpose** Make the decisions that are expensive to reverse, and only those.
**Input** Requirements.
**Output** `docs/architecture/overview.md`, ADRs in `docs/decisions/`.
**Owner** `/architecture`, using its decision framework.
**Validation** Every departure from the default shape cites the requirement that forced it.
Every component owns one thing and its own data. No cycles.
**Exit** The overview and the ADRs are written, and the ADRs are ready for review.
**Gate** Yes. A human approves the architecture before design work starts.

## Phase 4: Architecture review

**Purpose** Have someone who was not in the reasoning try to break it.
**Input** Requirements, overview, ADRs.
**Output** Findings, and the resolution of each.
**Owner** `architecture-reviewer` agent.
**Validation** Blocking findings are resolved or explicitly accepted in an ADR.
**Exit** No unresolved blocking finding. Disagreements are recorded, not dropped.

## Phase 5: Technical design

**Purpose** Make the expensive mistakes on paper, one feature at a time.
**Input** A requirement, the architecture, and the existing code.
**Output** `docs/architecture/designs/<feature>.md`.
**Owner** `/design`.
**Validation** The contract is complete. Every external call has a timeout and a stated
failure behavior. The migration is expand and contract. Authorization is per resource.
**Exit** Someone else could implement it without asking a question.
**Skip when** The diff fits in one sentence.

## Phase 6: Implementation planning

**Purpose** Turn the design into ordered, verifiable, resumable work.
**Input** The design.
**Output** `docs/project/plans/<feature>.md`.
**Owner** `/plan`.
**Validation** Every task names files and a check. The tree is green after every task. The
riskiest work is first. Rollback and out-of-scope are written down.
**Exit** The plan can be handed to a fresh session with no other context.

## Phase 7: Incremental implementation

**Purpose** Build it, one verified task at a time.
**Input** The plan.
**Output** Code, tests, a ticked plan, an updated state file, commits.
**Owner** `/implement`, in the main session.
**Validation** Each task ends with its check passing and the output shown.
**Exit** Every task is done or explicitly dropped with a reason.
**Gate** At every checkpoint the plan marks, and at every gate in CLAUDE.md.
**Stop and ask** After two genuinely different failed attempts at the same problem.

## Phase 8: Automated testing

**Purpose** Confidence that survives the next change.
**Input** The implementation and the design's test approach.
**Output** Tests at the right levels, running in the pipeline.
**Owner** `/implement`, guided by `skills/implement/testing-strategy.md`.
**Validation** Behavior is tested, not implementation. Every named edge case is covered.
Every bug fix has a regression test. Nothing is skipped, sleeping, or order-dependent.
**Exit** `./scripts/verify.sh` passes and the suite is deterministic.

## Phase 9: Code review

**Purpose** An independent read by something that did not write the code.
**Input** The diff, the plan, the out-of-scope list.
**Output** Ranked findings with failure scenarios.
**Owner** `code-reviewer` agent via `/review`.
**Validation** Every blocking finding is fixed. Every other finding gets an explicit
decision.
**Exit** No open blocking finding.

## Phase 10: Security review

**Purpose** Find the paths an attacker takes.
**Input** The diff or component, the data it handles, who can reach it.
**Output** Findings classified as blocking or not, each with an exploit condition.
**Owner** `security-reviewer` agent via `/security-review`.
**Validation** Blocking findings are fixed. Non-blocking ones have an owner and a date.
**Exit** No open blocking finding.
**Required for** Anything touching auth, secrets, cryptography, user input, external
requests, payments, or personal data. Optional elsewhere.

## Phase 11: Performance review

**Purpose** Confirm the change meets its budget, by measurement.
**Input** The latency and throughput targets from the requirements.
**Output** Before and after measurements, findings ranked by measured impact.
**Owner** `/performance-review`.
**Validation** Measured at realistic volume and concurrency. A regression guard exists for
whatever mattered.
**Exit** Within budget, or the gap is accepted in writing.
**Required for** Hot paths, new queries, new external calls, and any stated target.

## Phase 12: Integration validation

**Purpose** Prove the parts work together, not just individually.
**Input** The deployed change in a staging environment.
**Output** Passing integration and contract tests, plus the end-to-end check from the plan.
**Owner** Main session.
**Validation** Contract tests pass against the real dependency versions. The migration has
been applied to a realistic copy of the data and timed.
**Exit** The full path works in an environment that resembles production.

## Phase 13: Deployment preparation

**Purpose** Make the release reversible before it is irreversible.
**Input** A validated change.
**Output** A release plan: the commit, the migration order, the rollback command with its
duration, the signals to watch, and the baseline for each.
**Owner** `/release`.
**Exit** The rollback has been tested, not just written.

## Phase 14: Production readiness

**Purpose** Decide, in writing, whether this can ship.
**Input** Everything above.
**Output** `docs/operations/readiness/<name>-<date>.md` with a GO, CONDITIONAL GO, or NO-GO.
**Owner** `production-readiness-reviewer` agent via `/production-readiness`.
**Validation** Every item has evidence or a fail. Conditional items have owners and dates.
**Exit** A verdict, with a name against it.
**Gate** Yes.

## Phase 15: Deployment

**Purpose** Ship it and watch it.
**Input** The release plan and an approved verdict.
**Output** A release record, and a healthy system.
**Owner** `/release`.
**Validation** The intended behavior is confirmed in production directly. Error rate,
latency, and the background workers are within their normal bands.
**Exit** Verified, or rolled back.
**Gate** Yes, always, explicitly, immediately before deploying.

## Phase 16: Monitoring and operations

**Purpose** Know when it breaks, and know what to do.
**Input** A running system.
**Output** Alerts that fire on real problems, runbooks in `docs/operations/runbooks/`,
incident notes in `docs/operations/incidents/`.
**Owner** `/operate`.
**Validation** Every alert maps to a runbook entry. Every incident produces actions with
owners.
**Exit** Continuous. This phase does not end.
**Gate** Production data modification, resource deletion, and restores, even during an
incident. Especially during an incident.

## Phase 17: Post-deployment iteration

**Purpose** Feed reality back into the top of the loop.
**Input** Usage data, incidents, feedback, the measured value of what shipped.
**Output** An updated `docs/project/STATE.md`, new or superseded ADRs, the next set of
requirements.
**Owner** `/project-state`, then back to the appropriate phase.
**Validation** The success metric from the brief was actually measured. Say so if it was
not met.
**Exit** The next piece of work has a phase and an owner.

---

## Ask, assume, or stop

**Ask** when the answer is a product judgement, is expensive, is hard to reverse, or
involves money, personal data, authentication, or authorization. Ask in batches, with
options, not one question at a time.

**Assume** when the choice is cheap, reversible, and internal. Record it as `ASSUMPTION:`
in the phase document and move on. An agent that asks about everything is as unusable as
one that asks about nothing.

**Stop** at the gates in CLAUDE.md, at the checkpoints a plan marks, when two different
attempts at the same problem have failed, and when a phase's exit criteria cannot be met
with what you know.
