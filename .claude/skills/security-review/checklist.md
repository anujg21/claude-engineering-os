# Security control catalogue

The single authoritative list for this system. Rules in `.claude/rules/security-sensitive.md`
are the subset you should know while writing code; this is what gets checked at review.

Work the sections that the change touches.

## Identity and authentication

- Passwords hashed with Argon2id or bcrypt at current parameters, never a bare hash.
- Multi-factor available for privileged accounts; step-up authentication before sensitive
  operations.
- Session identifiers are random, long, regenerated on privilege change, and invalidated on
  logout and password change.
- Tokens are short-lived, audience-scoped, and revocable. Refresh material lives server side.
- JWT verification pins the algorithm; `none` and algorithm confusion are rejected.
  Expiry, issuer, and audience are all checked.
- Login, reset, and enumeration paths are rate limited and give identical responses whether
  or not the account exists. Reset tokens are single use and expire.
- Credential comparison is constant time.

## Authorization

- Deny by default. Access requires an explicit grant.
- Authorization is checked on the resource, in the handler, not only on the route.
- Object identifiers from the client are always resolved and ownership verified. This is
  the most common real vulnerability in application code.
- Tenant isolation is enforced in the query, not by a filter the caller can influence.
- Privileged operations are unreachable by role escalation through a mass-assigned field.
- Server-side enforcement of anything the UI hides.

## Input handling and injection

- SQL and any other query language uses parameterized statements. No string concatenation,
  including for identifiers; allowlist those.
- No shell invocation with user input. If a subprocess is unavoidable, pass an argument
  vector, never a shell string.
- Path handling resolves and confirms the result is inside the intended directory. Reject
  traversal rather than stripping it.
- Templates escape by default; any raw or unsafe rendering of user data is justified in a
  comment or removed.
- Deserialization of untrusted data uses a safe format and a schema. No native object
  deserialization of external input.
- XML parsers have external entity resolution disabled.
- Size, length, depth, and count limits on every input, including nested structures,
  uploads, and pagination parameters.
- Regular expressions on untrusted input cannot backtrack catastrophically.

## Output and browser controls

- Contextual escaping for HTML, attributes, JavaScript, and URLs.
- Content Security Policy without `unsafe-inline`, and framing denied where not needed.
- Cookies: `HttpOnly`, `Secure`, and `SameSite` set deliberately.
- State-changing requests are protected against cross-site request forgery by token or by
  a `SameSite` strategy that actually covers the flows in use.
- CORS allowlists specific origins. Never reflect the origin header with credentials enabled.
- Redirects to user-supplied URLs are allowlisted.

## Outbound requests

- Any fetch of a user-supplied URL validates the scheme and resolves the host, blocking
  private ranges, loopback, and cloud metadata addresses, and re-checks after redirects.
- Outbound calls have timeouts, size limits, and no automatic credential attachment.
- Certificate verification is never disabled.

## Secrets and cryptography

- No secrets in code, config files, logs, error messages, test fixtures, container images,
  build arguments, or git history.
- Secrets come from a manager or the environment, are rotatable, and are scoped per
  environment.
- Only vetted library primitives. No custom cipher, mode, or protocol.
- TLS everywhere, including internal traffic where the network is not trusted.
- Randomness for anything security-relevant comes from a cryptographic source.
- Encryption at rest for sensitive fields, with a documented key rotation path.

## Data protection and privacy

- Every field's classification is known. Personal and regulated data has a retention rule
  and a working deletion path.
- Data minimization: not collected unless it is used.
- Logs, traces, error reports, and analytics carry identifiers, never payloads with
  personal data.
- Backups are encrypted and their restore path is tested.
- Exports and reports respect the same authorization as the interactive path.

## Availability and abuse

- Rate limits per account and per source on every public endpoint, with a bound on
  expensive operations specifically.
- Pagination and result limits on every list.
- Bounded concurrency and queue depth. No unbounded worker fan-out.
- Bot and abuse controls on registration, invitation, and anything that sends mail or costs
  money per call.

## Dependencies and supply chain

- Lockfiles committed, versions pinned, builds reproducible.
- Automated vulnerability scanning in the pipeline, with a policy for what blocks.
- New dependencies checked for maintenance, ownership, and transitive weight.
- Build and deploy identities are least privilege and short lived; forked pull requests
  never run with production credentials.

## Logging and audit

- Every authentication and authorization outcome is audited with actor, action, resource,
  source, and time.
- Audit records are append-only and readable by the people who need them during an incident.
- Alerting exists for repeated authorization failure, privilege change, and credential use
  from a new source.

## Infrastructure

- Least privilege on every identity, human and machine. No long-lived static keys where
  federation is available.
- Network paths default closed. Datastores are not publicly reachable.
- Images run as non-root with a read-only filesystem where possible.
- Environments are isolated: separate credentials, separate state, separate data.
- Production access is audited, and production data is not copied into other environments.
