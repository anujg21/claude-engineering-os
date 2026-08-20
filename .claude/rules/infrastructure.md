---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/Dockerfile*"
  - "**/docker-compose*.{yml,yaml}"
  - "**/k8s/**"
  - "**/kubernetes/**"
  - "**/helm/**"
  - "**/.github/workflows/*.{yml,yaml}"
  - "**/*.tfstate"
---

# Infrastructure and pipeline rules

Infrastructure is code that can delete a company. It gets the same review as application
code, plus a plan you can read before it runs.

## Declarative infrastructure

- Everything is in version control and applied from the pipeline. A change made in a
  console is a change that will be lost and will surprise someone at 3am.
- State is remote, locked, encrypted, and never committed.
- Plan before apply, always, and read the plan. Deletions and replacements in a plan are
  a stop-and-ask, not a scroll-past.
- Separate state and credentials per environment. A single credential that can reach
  both staging and production makes staging a production risk.
- Tag every resource with owner, environment, and cost centre.

## Containers

- Pin the base image by digest, not by a moving tag. Rebuild to pick up patches.
- Multi-stage builds. Build tooling never ships in the runtime image.
- Run as a non-root user, read-only root filesystem, no capabilities you cannot justify.
- No secrets in image layers, build args, or environment defaults baked at build time.
- Declare resource requests and limits, and a health check that reflects real readiness
  rather than process liveness.

## Pipelines

- The pipeline is the only path to production. No local deploys.
- Least privilege for the pipeline identity, short-lived credentials, scoped per
  environment. Prefer OIDC federation over stored keys.
- Never echo secrets, and never let a fork's pull request run with production credentials.
- Required stages before deploy: build, unit and integration tests, dependency
  vulnerability scan, secret scan, infrastructure plan. A failure blocks; it does not warn.
- Deploys are reversible: versioned artifacts, a documented rollback command, and a
  health gate that stops a bad rollout automatically.

## Operational baseline

Anything reachable from the internet needs, before it is exposed: authentication, a rate
limit, TLS with a current configuration, request logging without sensitive fields, an
alert on error rate and latency, and a runbook in `docs/operations/runbooks/`.
