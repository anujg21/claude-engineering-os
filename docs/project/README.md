# Project

The long-running memory. This directory exists because conversation history does not
survive: sessions end, context compacts, and weeks pass between working days.

- `STATE.md` the canonical current state. The only file that must always be true.
  Loaded automatically at the start of every session by a hook, truncated to 60 lines,
  which is why it must stay short.
- `HANDOFF.md` the baton between sessions: what you were mid-way through, what already
  failed, and the next concrete command. Overwritten each time, not appended to.
- `plans/` one implementation plan per feature, from `templates/implementation-plan.md`.
  Ticked off as work happens.

## Why one state file

Any fact that lives in two places will differ within a week, and then neither copy gets
trusted. `STATE.md` holds status and points at everything else. Requirements live in
`docs/product/`, reasoning lives in `docs/decisions/`, task detail lives in `plans/`.

## Keeping it honest

Update it in the same action as the work, not in a weekly batch. Never record a status you
have not verified: "deployed" means you checked, not that the pipeline went green. Delete
anything that is true but no longer load-bearing. Git holds the history; this file holds the
present.
