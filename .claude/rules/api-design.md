---
paths:
  - "**/api/**"
  - "**/apis/**"
  - "**/routes/**"
  - "**/handlers/**"
  - "**/controllers/**"
  - "**/endpoints/**"
  - "**/*.proto"
  - "**/openapi*.{yaml,yml,json}"
  - "**/schema.graphql"
---

# API rules

An API is a contract with a stranger. Assume every field you expose will be depended on
by someone you cannot contact.

## Shape

- Resource nouns in paths, verbs in methods. Version in the path from the first release.
- Consistent casing across the whole surface. Pick one and never mix.
- Collections are always paginated, from day one. Return a stable cursor, not an offset,
  wherever ordering can shift.
- Return the created or updated resource, not a bare status code, unless the operation is
  genuinely fire and forget.

## Contract and compatibility

- Additive changes only on an existing version: new optional fields, new endpoints.
  Removing a field, narrowing a type, tightening validation, or changing a default is
  breaking, even when no test catches it.
- Define the contract in a schema (OpenAPI, protobuf, GraphQL SDL) and generate from it
  rather than writing it twice.
- Unknown fields in a request are rejected, not ignored, unless the API is explicitly
  extensible. Silent ignores hide client bugs for months.

## Validation and errors

- Validate at the boundary, once, before any business logic runs. Everything past the
  handler assumes valid input.
- One error format across the whole API: a stable machine-readable code, a human message,
  and a field path for validation errors. Clients branch on the code, never on the message.
- Error messages never leak internals: no stack traces, no SQL, no upstream hostnames,
  no hints about whether an account exists.
- Map to correct status codes. 400 for the client's mistake, 401 unauthenticated,
  403 authenticated but not permitted, 404 for absent or invisible, 409 for conflict,
  422 for semantic failure, 429 for rate limits, 5xx only when it is our fault.

## Behavior under load and failure

- Write endpoints that clients retry must be idempotent, keyed by a client-supplied
  idempotency key.
- Every endpoint has a documented timeout and a rate limit. Unbounded endpoints are
  outages waiting for traffic.
- Long operations return a job handle instead of holding the connection open.

## Authorization

- Authorize per resource inside the handler, not only per route. A route guard does not
  know whether this user owns this record.
- Never trust an identifier from the client to imply ownership. Look it up and check.
