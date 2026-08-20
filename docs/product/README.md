# Product

What we are building, for whom, and how we will know it worked. No technology choices here.

- `brief.md` the problem, the user, success metrics, scope. From `templates/product-brief.md`.
- `requirements.md` numbered, testable functional requirements plus the non-functional
  values that decide the architecture. From `templates/requirements.md`.

Both are produced by `/discovery` and are the input to `/architecture`.

These files are empty until a project exists. That is deliberate: a template repository
that ships a fake product brief teaches people to skip the phase that produces the real one.

Requirements are referenced by number (`FR-3`) from designs, plans, and tests. When a
requirement changes, change it here and let the references stay valid.
