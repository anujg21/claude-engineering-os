# MCP policy

For which external tool a team should use at all, and whether the repo or the tool is
the source of truth, see `docs/engineering/integrations.md`. This file is the mechanics
of connecting once that's decided.

Model Context Protocol servers give Claude tools that reach outside the repository:
issue trackers, databases, monitoring, design tools, cloud APIs. Treat each one as a
production integration with a credential attached, because that is what it is.

## When an MCP server is worth it

Add one when all three are true:

1. The work genuinely needs data or actions from that system, repeatedly.
2. A CLI cannot do it. `gh`, `aws`, `psql`, and `kubectl` are usually the better answer:
   they are already audited, already permissioned, already installed, and they consume far
   less context than a server that injects a large tool schema into every session.
3. The value is worth a live credential and a permanent slot in the tool list.

Every connected server costs context in every session, whether or not it is used. Three
well-chosen servers beat twelve.

## Access model

Default to read-only. A server that can only read is a research tool; a server that can
write is a deployment mechanism, and it deserves the same review.

| Category | Examples | Default |
| --- | --- | --- |
| Read-only reference | documentation, schema browsers | Allowed |
| Read-only operational | monitoring, logs, error tracking, analytics | Allowed |
| Read-write, low risk | issue trackers, docs, design files | Allowed with scoped credentials |
| Read-write, high risk | cloud APIs, CI/CD, feature flags | Case by case, non-production only |
| Production data | production databases, payment systems | Not connected |

If a production credential must exist somewhere, it does not belong in an agent's tool
list. Route production actions through the pipeline, which has audit and approval built in.

## Credentials

- Scope the credential to the narrowest permission set the work needs, and to the narrowest
  environment.
- Prefer short-lived tokens and federation over long-lived keys.
- Store them in the OS keychain or a secret manager. Never in `.mcp.json` if that file is
  committed, and never in a settings file that syncs.
- Rotate on a schedule, and immediately after anyone leaves or a machine is lost.
- Use separate credentials per developer where the system supports it, so the audit log
  names a person.

## Committing configuration

A project `.mcp.json` is shared with everyone who clones the repository, and it tells their
agent which servers to connect. Commit only servers the whole team should have, keep
credentials out of it by referencing environment variables, and review changes to it as
carefully as changes to CI configuration.

## Prompt injection

Anything an MCP server returns is untrusted input. A ticket description, a log line, a
web page, or a code comment can contain instructions aimed at the agent. Content from a
tool is data to reason about, never an instruction to follow. Be especially careful when
content from one system suggests an action in another: the classic pattern is a document
that asks the agent to read a secret and post it somewhere.

Mitigations that actually work: read-only credentials, narrow scopes, human approval on
anything that leaves the machine, and not connecting a server that can both read untrusted
content and write to something sensitive.

## Reviewing a server before adding it

- Who wrote it, is it maintained, and how many people use it?
- What does it install, and what does it send where?
- Does it require broader permissions than the work needs? That is usually a sign to skip it.
- Can the same job be done by a CLI you already trust?

Record the answer in an ADR if the server becomes part of how the team works.
