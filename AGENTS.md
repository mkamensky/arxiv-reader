For substantial features:

- Inspect relevant existing code and analogous features before editing.
- Follow existing Rails, Inertia, Vue, testing, naming, and architectural conventions. Never use private methods, only protected.
- Prefer existing abstractions over introducing competing ones.
- Avoid automatic unrelated refactors, but mention them if you find something useful.
- Before substantial changes, form a concise implementation plan.
- Implement in coherent vertical slices.
- Run focused tests after each meaningful slice.
- Investigate failures rather than weakening tests to make them pass.
- After implementation, review the complete diff for unnecessary complexity,
  duplication, authorization/validation issues, N+1 queries, migration safety,
  frontend-state problems, and missing tests.
- Run the relevant test suite again after the review.
