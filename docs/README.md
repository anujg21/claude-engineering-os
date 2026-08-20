# Documentation

Knowledge lives here. Behavior lives in `.claude/skills/`. The split matters: knowledge is
read on demand by whoever needs it, procedures are loaded by the agent that runs them.

| Directory | Holds | Written by |
| --- | --- | --- |
| `product/` | The brief and the requirements. What we are building and why. | `/discovery` |
| `architecture/` | The overview, the principles, and per-feature designs. How it is built. | `/architecture`, `/design` |
| `decisions/` | ADRs. Why it is built that way. Immutable once accepted. | `/adr` |
| `engineering/` | The lifecycle, principles, definition of done, MCP policy, and the design notes for this system itself. | Humans, mostly |
| `security/` | The threat model and the security posture of this system. | `/security-review` |
| `operations/` | Runbooks, incident notes, readiness reports. | `/operate`, `/production-readiness` |
| `project/` | Current state, plans, handoffs. The long-running memory. | `/project-state`, `/plan` |

## The rule that keeps this useful

Each fact has exactly one home. The requirement lives in `product/requirements.md` and is
referenced everywhere else by number. The reasoning behind a decision lives in one ADR and
is linked, never restated. Current status lives only in `project/STATE.md`.

Two copies of a fact become two different facts within a month, and then neither is trusted.
When you are tempted to repeat something, link to it instead.
