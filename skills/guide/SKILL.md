---
name: guide
description: Help the user find the right skill or command in this system for what they are trying to do right now. Interviews them about their specific need, checks project state, and points to the exact next command with a reason. Does not do the work itself.
when_to_use: The user just ran /adopt and does not know what to do next, asks "what should I use", "what can this do", "which command do I need", "how do I start", or describes a need in plain language without naming a phase or a skill. Also use when a user seems to be forcing a skill that does not fit what they actually asked for.
argument-hint: "[optional: what you're trying to do]"
---

# Guide

This system has 15 skills and no obvious front door. Someone who just adopted it, or who
has not touched it in a month, should not have to read `docs/engineering/lifecycle.md` to
find the one command they need. That is this skill's only job: take a plain-language need,
ask enough to place it, and hand back the exact next command and why.

**Never do the work yourself.** Do not write the brief, the ADR, the design, or the code
from inside this skill. Recommend the skill that does, then stop, unless the user asks you
to invoke it for them.

## 1. Read state before asking anything

Read `docs/project/STATE.md`. It usually rules out most of the routing table by itself:
a project with no plan cannot be mid-implementation, a project with an open plan is
probably not starting discovery. Also check whether `docs/product/`, `docs/architecture/`,
and `docs/project/plans/` are empty or populated. Do not ask the user something the repo
already answers.

If an argument was passed, treat it as the answer to the first interview question and skip
straight to the follow-ups it implies.

## 2. Interview, briefly

Use `AskUserQuestion`. One round, two or three questions, never a form. The goal is to
place the request on the routing table, not to fully scope it, that is what the target
skill does. If state already narrowed it to one obvious phase, confirm in one question
instead of running the full interview.

Ask what you cannot infer from state or from what the user already said:

1. **What kind of thing is this?** A new idea with nothing written down yet. A feature to
   build on top of something that exists. A change to something already designed or
   planned. A check on work that is done or nearly done. Something broken right now.
   Not sure which, describing it is enough.
2. **Where does it stand?** Nothing written yet. A brief or requirements exist. A design or
   plan exists. Code exists and needs review, checking, or shipping. It is already live and
   something is wrong.
3. **Does it touch anything sensitive?** Only ask if it changes the recommendation, an
   answer of auth, secrets, payments, or personal data adds `/security-review` to the
   answer regardless of phase.

Push back once on an answer that would send someone to the wrong phase, the same way the
other skills push back on a vague requirement. If someone says "just write the code" for
something that changes an API contract or a schema, say what `/design` catches that going
straight to `/implement` would miss, and let them decide.

## 3. Match to the routing table

Use the table in `CLAUDE.md` and the phase detail in `docs/engineering/lifecycle.md` as the
source of truth, do not maintain a separate mental model of what each skill does. In short:

| What they described | Command |
| --- | --- |
| An idea, nothing written down | `/discovery` |
| Requirements exist, need a system shape and the expensive decisions recorded | `/architecture` |
| One decision to record, or "what did we decide about X" | `/adr` |
| A specific feature to design before touching code | `/design` |
| A design exists, need it broken into buildable, checkable steps | `/plan` |
| A plan exists, time to build | `/implement` |
| Code exists, want an independent read before it merges | `/review` |
| Touches auth, secrets, input, external calls, payments, or personal data | `/security-review` |
| Touches a hot path, a query, or has a stated latency or throughput target | `/performance-review` |
| About to expose this to real users or real money | `/production-readiness` |
| Ready to ship | `/release` |
| Something is broken in production, or a runbook is needed | `/operate` |
| Lost context, resuming after a gap, or ending a session | `/project-state` |
| Setting this system up in a repository for the first time | `/adopt` |
| Which external tools (Jira, Confluence, Slack) this repo is wired to | `/adopt` already asked this; check `docs/project/integrations.md`, or rerun `/adopt` if it adopted before this existed |

A one-line fix does not need the whole left column. Say so: point straight at
`/implement` then `/review`, and name which phases are being skipped and why, the same
rule `docs/engineering/lifecycle.md` gives for any change.

If the request does not fit this system at all, an operational question, a one-off script,
general Claude Code usage, say that plainly instead of forcing it onto the table.

## 4. Answer with a command, not a lecture

Give: the command, the one-sentence reason it fits what they described, and what it
produces. Skip the phase number and the full lifecycle explanation unless they ask for it.
If two phases are defensible, for example `/design` versus going straight to `/plan` for a
small, well-understood feature, say both and which one you would take, do not present a
menu of eighteen phases and ask them to choose.

If they wrote a longer description that already contains what a skill would ask for
anyway, for example a discovery interview, offer to invoke it directly instead of just
naming it.

## What not to do

- Do not re-explain the whole lifecycle when one phase answers the question.
- Do not ask more than one round of questions. If the second round would still be broad,
  that uncertainty belongs to the target skill's own interview, not to this one.
- Do not guess at product, security, or irreversible decisions to avoid asking. This skill
  routes, it does not decide.
- Do not skip `docs/project/STATE.md`. Asking a question the file already answers is the
  exact failure this skill exists to prevent.
