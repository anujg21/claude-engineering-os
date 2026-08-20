---
paths:
  - "**/auth/**"
  - "**/authn/**"
  - "**/authz/**"
  - "**/login/**"
  - "**/session*/**"
  - "**/crypto/**"
  - "**/middleware/**"
  - "**/*permission*"
  - "**/*password*"
  - "**/*token*"
---

# Rules for security-sensitive code

You are editing code on a trust boundary. The cost of a mistake here is not a bug, it is
an incident. Slow down, and prefer the boring, well-reviewed option.

- Never write your own cryptography, session format, or password hashing. Use the
  platform's vetted library with current parameters. Argon2id or bcrypt for passwords,
  never a bare hash, never a hash you invented.
- Authentication answers who; authorization answers whether. Do both, separately, and
  check authorization on every request including the ones that "can only" be reached
  by an admin.
- Deny by default. A new route, a new field, a new job is inaccessible until something
  explicitly grants access.
- Compare secrets with a constant-time function. Ordinary equality leaks length and
  prefix through timing.
- Tokens: short lived, scoped to the narrowest audience that works, revocable, and
  rotated on privilege change. Store refresh material server side.
- Never log, trace, or serialize into an error a credential, token, session id, or key.
  Redact at the point of construction, not in the log sink.
- Every authentication and authorization outcome, success and failure, is an audit event
  with actor, action, resource, source, and timestamp.
- Rate limit and lock out on repeated failure, keyed on the account as well as the source
  address. Responses must not reveal whether an account exists.
- Any change in this area needs `/security-review` before it merges, and a human approves
  changes to the trust boundary itself. See the approval gates in CLAUDE.md.

The full control catalogue is `.claude/skills/security-review/checklist.md`. These rules
are the subset you should not have to look up while writing the code.
