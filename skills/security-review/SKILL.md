---
name: security-review
description: Security review of a change or a system, run in a fresh context against a control checklist. Classifies findings as blocking or non-blocking with exploit conditions. Phase 10 of the lifecycle.
when_to_use: Before merging anything that touches authentication, authorization, secrets, cryptography, user input, file handling, external requests, payments, or personal data. Also run before a first release and after adding a dependency with network access.
argument-hint: "[diff, component, or 'full system']"
---

# Security review

Threat-model the change, then check it against the control catalogue. The output is
findings with exploit conditions, not a list of categories that were considered.

## Dispatching (main session)

Delegate to the `security-reviewer` agent with the diff or component, the data it handles,
and who can reach it. Fix everything blocking before merge. Non-blocking findings get an
owner and a date, recorded in `docs/project/STATE.md`.

## Review procedure (reviewer)

**1. Map the attack surface.** Every entry point in scope: endpoints, forms, file uploads,
webhooks, queue consumers, CLI arguments, environment variables, and anything reachable
from another tenant. For each, ask who can reach it unauthenticated.

**2. Follow the data.** Where does untrusted input flow? Note every place it reaches an
interpreter (SQL, shell, template, deserializer, path, URL, HTML) or a decision (an
identifier used for lookup, a role, a price, a quantity). Those are the sinks that matter.

**3. Check the trust boundaries.** Authentication, authorization per resource, tenant
isolation, and privilege escalation paths. Test the negative case in your head: what does
user A see when they pass user B's identifier?

**4. Work the checklist.** `checklist.md` in this directory. Skip nothing, but spend time
proportional to what the change touches.

**5. Check the supply chain and the secrets.** New dependencies, their transitive weight
and maintenance, pinned versions, and anything in the diff that looks like a credential.

## Classification

**Blocking.** Fix before merge, no exceptions:

- Any path where untrusted input reaches an interpreter without parameterization or escaping.
- Missing or incorrect authorization on a resource, including horizontal access between
  tenants or users.
- Authentication that can be bypassed, replayed, or brute-forced without a limit.
- Secrets in code, config, logs, or version control history.
- Sensitive or personal data logged, exposed in an error, or transmitted unencrypted.
- Broken or homemade cryptography, or a hash without a salt and a work factor for passwords.
- Server-side request forgery reachable from user-supplied input.
- Insecure deserialization of untrusted data.
- A known-exploited vulnerability in a dependency on a reachable path.

**Non-blocking.** Real, with an owner and a date:

- Defense in depth that is missing but not the only control.
- Rate limits absent on a low-value endpoint.
- Verbose errors that leak implementation detail without leaking data.
- Dependency vulnerabilities on unreachable paths.
- Hardening: headers, cookie flags, stricter content security policy.

**Not a finding.** Theoretical issues with no reachable path, and anything that requires an
attacker to already have the access the attack would grant.

## Reporting

For each finding: the location, the vulnerability class, the exploit condition written
concretely ("an authenticated user changes `account_id` in the request and reads another
customer's invoices"), the impact, the fix, and the classification.

No finding without an exploit condition. Speculation inflates the report and trains people
to ignore it.

State the surface you covered and what you did not review, so nobody mistakes a partial
review for a clean bill of health.
