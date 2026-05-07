---
description: Define what to build. Write a one-pager spec before any code — objective, users, acceptance criteria, scope cuts, open questions. Saves to docs/specs/YYYY-MM-DD-<feature>.md.
---

You are entering the **Define** phase of the SDLC. No code yet.

## Your job

Turn the user's idea into a one-pager spec the team can build from. The spec is the shared contract between user, agent, and reviewers.

## Required reading

- `PROJECT_CONTEXT.md` — stack, tenancy, residency, verify command
- `AGENTS.md` — workflow + brand voice
- The `karpathy-guidelines` skill — surface assumptions, simplicity first

## The spec format

Save to `docs/specs/YYYY-MM-DD-<feature-name>.md`. Keep it under 300 lines. Sections:

```markdown
# <Feature> spec

## Problem
1–2 sentences. What's broken / missing? Who hurts? How much?

## Users
Who is this for? Be specific (role, geography, frequency of use).

## Goal
What does success look like — in plain language?

## Non-goals
What this is NOT. Cuts the scope explicitly. The 3–5 most likely scope creep candidates.

## Acceptance criteria
Bullet list. Each one must be testable. "User can X" / "System rejects Y" / "Latency P95 < Z ms".

## Constraints
Stack, security, residency, performance, cost ceilings — anything from PROJECT_CONTEXT.md that bites.

## Open questions
Things you couldn't answer alone. Tag with [BLOCKING] if implementation can't start without an answer.

## Estimated complexity
S / M / L. One sentence on why.
```

## Process

1. Read `PROJECT_CONTEXT.md` and the user's request.
2. Surface your assumptions inline. Don't fill ambiguity silently:

   ```
   ASSUMPTIONS:
   1. <thing about scope>
   2. <thing about constraint>
   → Correct me now or I proceed with these.
   ```

3. Ask 1–3 clarifying questions if the request is vague. One at a time.
4. Draft the spec.
5. Show it to the user. Get explicit approval.
6. Save it. Commit it.
7. Suggest `/plan` next.

## Hard rule

Do NOT proceed to `/plan` or any code until the user approves the spec. "Looks fine" is approval. Silence is not.

## When to skip /spec

- Single-line fixes, typo corrections, lint rule additions.
- Pure config changes with one possible interpretation.
- Bug fixes where the bug report itself is the spec — go straight to `systematic-debugging`.
