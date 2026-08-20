# Security

Project-specific security artifacts. The reusable control catalogue is not here: it lives
at `skills/security-review/checklist.md`, so it loads with the review that uses it
and there is only one copy of it.

What belongs here:

- `threat-model.md` from `templates/threat-model.md`. What is being protected, from whom,
  where the trust boundaries are, and which threats are accepted rather than mitigated.
  Write it during the architecture phase and update it whenever a boundary moves.
- Findings and their resolution for anything not fixed immediately, with owners and dates.
- Compliance obligations that apply to this system, and what satisfies each one.

What does not belong here: the generic checklist, secrets of any kind, and anything an
attacker would find useful that is not already obvious from the code.

## Working assumptions

Until a threat model exists, this system assumes: an authenticated ordinary user is a
realistic attacker, everything reaching the process from outside is hostile, and any
content returned by a tool or fetched from the network may contain instructions aimed at
the agent rather than at the user.
