---
name: code-review
description: Multi-axis code review before merge. Use when reviewing any change — your own, another agent's, or a human's — across five dimensions (correctness, readability, architecture, security, performance). Approve when the change improves overall code health, even if not perfect.
license: MIT
---

# Code Review

## Overview

Every change gets reviewed before merge. Review covers five axes:

1. **Correctness** — does it do the thing? are tests honest?
2. **Readability** — would a teammate understand this in 6 months?
3. **Architecture** — does this fit the codebase, or fight it?
4. **Security** — does this open a door we don't want open?
5. **Performance** — does this hold up under realistic load?

**The approval standard:** approve when the change *improves overall code health*, even if it isn't perfect. Perfect doesn't exist. Don't block because it isn't how *you'd* have written it. Block because the codebase would be worse with this merged.

## When to use

- Before merging any PR
- After any agent (including yourself) finishes an implementation
- After any bug fix — review the fix AND the regression test
- Before handing off across a governance gate (G6 in this plugin's flow)

## The five-axis pass

### 1. Correctness

- Does the diff actually solve the stated problem?
- Are tests proving the new behavior, or just exercising the code path?
- Are edge cases covered (empty, null, max, concurrent, partial failure)?
- Does the test fail on the old code? (If not, it tests nothing.)

### 2. Readability

- Names: do they say *what* the thing is, or *what file it lives in*?
- Functions: do they do one thing? would a 6-month-from-now-you understand?
- Comments: are they explaining the *why*, not the *what*?
- Dead code, commented-out blocks, debug prints: gone.

### 3. Architecture

- Does this fit the existing patterns, or is it a one-off?
- New dependencies: justified?
- New abstractions: earning their complexity, or speculative?
- Cross-module coupling: did we pull on one thread and unravel two?

### 4. Security

- Auth boundaries: any new endpoint that should require auth and doesn't?
- Input validation: at the system boundary, not just inside?
- Secrets: nothing in code, env, config, logs, or error messages?
- SQL / shell / template injection: parameterized everywhere?
- Authorization vs authentication: does this user actually have permission, not just a token?

For deeper coverage, dispatch the `security-auditor` agent.

### 5. Performance

- N+1 queries on any new code path?
- Unbounded loops, unbounded memory?
- Synchronous calls to slow things in hot paths?
- Caching: appropriate TTL, appropriate key, no stampede?

Don't optimize prematurely. Do flag obvious cliffs.

## Output format

For each finding, emit:

```
[axis] [severity: blocker | major | nit]
File: path/to/file.ext:line
Issue: <what's wrong, in one sentence>
Suggestion: <concrete change, or a question>
```

Group by severity. Blockers must be addressed. Majors are strong asks. Nits are optional.

End with one of:

```
APPROVED — <one-line summary>
APPROVED-WITH-NITS — <count> nits, no blockers
CHANGES-REQUESTED — <count> blockers, <count> majors
```

## What "improves overall code health" means

- Fewer rough edges than before.
- Less duplication.
- Better names.
- Test coverage didn't go down.
- The next change in this area is now *easier* to make, not harder.

If the diff is mid (not great, not bad) but the codebase is better with it merged, approve. The cost of perfection is shipping nothing.

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "Looks fine to me" | That's not a review. Run the five axes. |
| "I'd have done it differently" | That's not a review either. Is the codebase worse with this merged? |
| "The author is senior, probably correct" | Reputation isn't review. Read the diff. |
| "It's a small change" | Small changes are where security holes ship. |
| "Tests pass, ship it" | Passing tests prove the tests pass. They don't prove correctness. Read them. |
| "I don't understand this part" | Then it isn't readable. That's a finding. |

## Self-review is a workflow violation

Don't review your own implementation. The same brain that wrote the bug is least likely to see it. Spawn the `code-reviewer` agent (or the `cto-agent` at gate G6 in the governance flow). For solo work, sleep on it before re-reading.

## Common rationalizations to push back on

- *"It works, so it's fine."* — "Works" is one of five axes. Read the other four.
- *"Refactoring is out of scope for this PR."* — True. But if the PR makes future refactoring harder, flag it.
- *"This file is already a mess, my change matches."* — Don't fight cleanup PRs, but don't add to the mess on the way in.

## Verification

- You read every changed line.
- You ran the verify command yourself.
- You ran new tests against old code (mentally or actually) — they fail.
- You wrote findings grouped by severity and ended with a verdict line.
