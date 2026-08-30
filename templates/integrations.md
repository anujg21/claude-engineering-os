# Integrations

External tools this repo is wired to, if any. Framework and per-tool policy:
`docs/engineering/integrations.md`. Live access (credentials, `.mcp.json`) is set up
separately, per `docs/engineering/mcp.md` — this file records intent, not connections.

| Tool | Purpose | Direction | Mechanism | Owner |
| --- | --- | --- | --- | --- |
| Jira | Tickets | Repo doesn't push; issue keys referenced in plans | `acli`, read-only | Platform team |
