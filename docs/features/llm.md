# Feature: Provide AI paper recommendations for users

## Goal

This feature should provide a logged in user with paper recommendations among the published arxiv papers. The recommendations should be based on the user's favourite (bookmarked) papers and followed authors, and possibly the familiarity of the llm used by the user. Later, I may want to expand this to also take into account some user input, such as research interests, research plan, etc.

The recommendations should be provided by an llm. The site should allow the user to provide an api key or some other login credentials, or use an llm anonymously.

## User-visible behavior

- The user page should allow the user to connect with an llm (api key, oauth, or some other method). If the user does not wish to associate with a particular account, it should be possible to use anonymously.
- There should be a screen listing recommended, similar to the author or recent screen.
- Possibly, it should be possible to tell the llm how good the recommendation is, so that it can improve.

## Work plan

### Phase 1: Understand the existing system

Before changing code:

1. Inspect the relevant parts of the repository.
2. Identify:
  - models and database structures involved;
  - controllers, services, queries, decorators/presenters, policies, jobs, etc. that participate in the current flow;
  - Inertia/Vue pages and components involved;
  - relevant routes;
  - relevant tests;
  - analogous features elsewhere in the application.
3. Trace the existing data flow from the user action through Rails to the frontend and back where applicable.
4. Note repository conventions that should govern the implementation.
5. Identify any ambiguities, risks, migration concerns, backwards-compatibility issues, or likely edge cases.

Do not make changes yet unless a tiny exploratory change is genuinely necessary.

### Phase 2: Produce an implementation plan

Give me a concise implementation plan before making substantial changes.

The plan should include:

- the intended architecture;

- files or areas likely to change;

- database/schema changes, if any;

- backend changes;

- frontend changes;

- tests to add or modify;

- important edge cases;

- anything you explicitly intend not to change.

Prefer the smallest design that fits naturally into the existing codebase.

If there are several plausible designs, compare them briefly and choose the one that best matches existing repository patterns. Do not redesign the application merely because another architecture would be cleaner in isolation.

Then proceed with the implementation without waiting for further confirmation unless you encounter a genuinely blocking ambiguity that cannot be resolved from the repository.

### Phase 3: Implement vertically

Implement the feature in coherent vertical slices rather than making a large speculative rewrite.

For each slice:
- make the smallest complete set of changes;
- run the most relevant focused tests;
- fix failures before expanding the scope;
- inspect unexpected failures rather than merely changing tests to make them pass.

Where appropriate, work in this order:

- data model / migration;

- domain or service logic;

- request/controller layer;

- presentation/decorator/serialization layer;

- Inertia/Vue frontend;

- focused tests;

- system/integration tests.

Adapt this order if the repository structure suggests something better.

### Phase 4: Testing and verification

Use the repository's existing test commands and conventions.

Run focused tests during implementation, then run the broader relevant test set once the feature is complete.

At minimum, verify:
- the normal successful path;
- validation and error behavior;
- authorization/permissions if relevant;
- empty and boundary cases;
- persistence and reload behavior;
- request/response or Inertia props;
- frontend behavior where applicable;
- regressions in closely related existing behavior.

Do not weaken existing assertions simply to make the suite green.

If a test fails because of an existing unrelated problem, distinguish that clearly from failures caused by your changes.

### Phase 5: Review the completed diff

After implementation, review your own changes as if you were reviewing a pull request.

Check specifically for:

- unnecessary complexity;

- duplicated logic;

- violations of existing repository conventions;

- missing validation or authorization;

- N+1 queries or avoidable database work;

- incorrect transaction boundaries;

- migration safety issues;

- stale or inconsistent frontend state;

- incomplete test coverage;

- dead code;

- accidental unrelated changes.

Fix issues you find.

Then run the relevant tests again.

### Final response

At the end, give me a compact summary containing:
- what was implemented;
- the main design decisions;
- important files changed;
- tests run and their results;
- any remaining concerns, limitations, or follow-up work.

Do not give me a long narrative of every command you ran.

## Implementation Notes

Recommendations use RubyLLM's provider-neutral chat and structured-output API.
OpenAI and Gemini are supported. Set `OPENAI_API_KEY` and/or `GEMINI_API_KEY` in
the server environment to offer that provider through the site's account. This
is the "anonymous" connection: the user does not supply a key, but the site's
provider account incurs the API usage. `OPENAI_RECOMMENDATIONS_MODEL` defaults
to `gpt-4o-mini`; `GEMINI_RECOMMENDATIONS_MODEL` defaults to
`gemini-2.5-flash`. Restart the server after changing these environment
variables. Each configured model must support structured output.

Users choose a primary provider and either the site connection or their own
key on their profile. Personal keys are stored separately per provider in
`llm_connections`, encrypted with a key derived from the application's Rails
secret, and never serialized to the browser. The migration copies existing
OpenAI ciphertext into that table; the old column is retained temporarily for
staged cleanup, and rolling back the migration restores the current OpenAI
key ciphertext. A personal-mode user needs a personal key for each provider
they want to use. There is no silent fallback to another provider or billing
account. OAuth and local/no-key models are not implemented.

Every published local paper whose primary category is followed by the user is
eligible, including the existing archive on a user's first run. Bookmarked,
hidden, and previously considered papers are excluded. The page processes all
pending papers in batches of 80; progress and recommendations persist after
each successful batch, so an interrupted run can resume. A failed model request
leaves that batch pending. Bookmarks and followed authors guide ranking, but do
not limit which category papers are considered. Model output is checked against
the current batch before it is saved.

The considered-paper set remains global per user, not per provider or model.
Changing the primary provider therefore considers only papers that user has
not yet considered. Each saved recommendation records the provider and model
that produced it; older recommendations are labelled OpenAI with an unknown
model. On the recommendations page, a user may request one saved second
opinion for a recommended paper from each other available provider. This
assesses only that paper, saves a separate score and reason, and never changes
the primary recommendation or considered-paper set. The other provider must
have a key available under the user's chosen connection mode. Second opinions
are rate limited and are not automatically requested for the entire archive.
Scores from a single-paper assessment and a batch ranking are not calibrated
against each other.

Large categories can require many API requests and the page must stay open for
uninterrupted processing. Feedback and free-form research interests remain
future extensions.
