# Integrations policy

Enterprises layer tools on top of git: a wiki, a ticket tracker, a chat tool. Which ones
(if any) varies per adopter. This is the policy for deciding, per tool, whether the repo
stays the source of truth, what a mirror looks like, and what mechanism reaches it.
`/adopt` records intent per repo in `docs/project/integrations.md`. This file is the
framework it applies; `docs/engineering/mcp.md` is the mechanical how-to for adding a
live connection once a team decides it wants one.

## The rule

Repo is exclusive source of truth for anything Claude authors: ADRs, plans, designs,
state. External tools may be read for context, or receive a one-way mirror out. Nothing
is ever dual-authored or bidirectionally synced — two systems editing the same fact
drift apart the moment either side is edited outside the sync, and the drift compounds
silently. Pick one direction per artifact type and keep it.

Prefer a CLI over a standing MCP server wherever one exists, for the same reason
`docs/engineering/mcp.md` already gives: an MCP server's tool schema costs context on
every turn whether it's used or not, while a CLI invoked through Bash costs nothing
until called. Reserve MCP for what a CLI can't do: a session with enough back-and-forth
that Bash round-trips become the bottleneck, or a per-user OAuth audit trail a shared
CLI credential can't provide.

Anything that leaves the machine is approval-gated per `CLAUDE.md`, regardless of
mechanism.

## Per-tool policy

| Tool | Repo is source of truth | Mirror direction | Default mechanism | MCP fallback, when | Consuming skills |
| --- | --- | --- | --- | --- | --- |
| Confluence/Notion | Yes, for anything Claude authors | One-way repo→wiki; human-run export or CI job, never Claude-triggered push | `acli` (or equivalent), read-only via Bash, scoped `allowed-tools` | Only if the team already runs an MCP-based workflow for other Atlassian access | `/discovery`, `/architecture`, `/design` may read existing pages for context |
| Jira/Linear | Yes, for the plan itself; Jira owns ticket status/assignment | Repo doesn't push; issue key referenced in the plan/`STATE.md`, not synced | `acli`/`jira-cli`, read by default; write case-by-case, scoped credential, record the decision as an ADR | Sessions doing enough back-and-forth ticket work that CLI round-trips are the bottleneck, or per-user OAuth audit trail is required | `/plan`, `/project-state` may read; `/implement` may write only if that team adopted it |
| Slack/Teams | N/A — notification channel, not a doc store | Outbound only, narrow incoming webhook via `curl`/a script from CI | Webhook script | Never — no viable bidirectional Slack MCP as of 2026 | `/release`, `/operate` |
| External ADR tool | No exception — [ADR 0001](../decisions/0001-record-architecture-decisions.md) already settles this | If mirrored, one-way repo→tool, informational only, never authored there | Not connected | Not connected | none |

## Why this shape

- **Docs-as-code, not wiki-as-code.** Git stays durable, versioned, greppable by agents,
  and PR-reviewable. A wiki is a good read surface for people who won't open the repo,
  never the place something is authored.
- **One-way sync only.** Bidirectional sync between two systems drifts within a quarter
  unless every field has an explicit owner. Simpler to never build it: pick a direction,
  keep it.
- **CLI first.** Official CLIs exist for the categories that matter most (`acli` for the
  Atlassian suite, alongside `gh`, `aws`, `psql`, `kubectl` already named in mcp.md). A
  CLI is auditable, already permissioned, and free until invoked. An MCP server is a
  standing cost and a live credential in every session, used or not.
