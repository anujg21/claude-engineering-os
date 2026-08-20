# Architecture

- `principles.md` the standing position on how systems should be shaped. Read it, disagree
  with it, and edit it. This is the main customization point of the whole system.
- `overview.md` how this specific system is built. Created by `/architecture` from
  `templates/architecture-overview.md`. It does not exist yet because no system exists yet.
- `designs/` one technical design per feature, created by `/design`.

The overview describes the current state, not the history. When the design changes, update
the overview and write an ADR explaining why. The overview answers "what is it", the ADRs
answer "why is it that", and the two together are what an agent reads before proposing a
change.

Diagrams are Mermaid in markdown, so they are diffable, greppable, and readable by an agent.
Image files are not.
