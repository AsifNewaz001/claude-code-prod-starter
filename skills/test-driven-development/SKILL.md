---
name: test-driven-development
description: Drives development with a failing test first. Use when implementing any new logic, fixing any bug, or modifying behavior. Tests ship in the same commit as code — never "tests later."
license: MIT
---

# Test-Driven Development (TDD)

## Overview

Write the failing test first. Watch it fail. Write the minimum code that makes it pass. Then refactor.

If you didn't watch the test fail, you don't know if it tests the right thing. A test that passes against an empty function tests nothing.

## When to use

- Any new feature or behavior
- Any bug fix (reproduce the bug as a test first — the "Prove-It" pattern)
- Any refactor that could change observable behavior
- Any change that touches an acceptance criterion

**When NOT to use** (state this out loud, don't assume):
- Configuration-only changes (no logic)
- Documentation
- Pure styling / CSS-only edits
- Throwaway prototypes the user has explicitly labeled as such

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

If you wrote production code first by accident, delete it. Don't keep it as "reference." Don't squint at it while writing the test. Implement fresh from the test.

## Red-Green-Refactor

```
RED      Write the failing test.
         Run it. Confirm it fails for the RIGHT reason
         (not a syntax error, not a missing import).

GREEN    Write the minimum code that turns it green.
         Don't add anything the test doesn't require.

REFACTOR Clean up names, structure, duplication.
         Tests stay green throughout.
```

Each cycle is small (2–10 minutes). Commit at green if the increment makes sense on its own.

## The Prove-It pattern (for bug fixes)

1. Read the bug report. Identify the smallest reproducer.
2. Write a test that asserts the *correct* behavior.
3. Run it. Confirm it fails — that proves the bug exists.
4. Fix the code.
5. Run it. Confirm it passes — that proves the fix works.
6. Run the full suite. Confirm nothing else broke.

A bug fix without a regression test is a fix that can ship the same bug again next month.

## Tests ship in the same commit as code

Not "tests in a follow-up PR." Not "I'll add tests later." Same commit, every time. Reviewers and `git bisect` both depend on this.

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "Just this once, I'll skip TDD" | "Just this once" is how every codebase ends up untested. |
| "It's too small to need a test" | Small things break in big ways. Write the test. |
| "I'll add tests after I see it work" | You won't. Add them first. |
| "The test is hard to write" | That's a design smell. The hard test is telling you the code is hard to use. |
| "This is just a tweak to existing code" | Existing code is exactly where regressions live. |
| "I already know it works" | Knowing ≠ proving. The test proves it. |

## Common rationalizations to push back on

- *"Mocking the database is fine for these tests."* — Often it isn't. Integration tests against a real (test) DB catch migration breaks that mocked tests miss.
- *"I'll write one big test that covers it all."* — One big test fails for many reasons and tells you nothing. Prefer small, single-assertion tests.
- *"This test is flaky — let me retry it a few times."* — Flaky tests are bugs. Fix the test or the code, don't paper over it.

## Verification (this skill is "done" when…)

- A new failing test exists for the change you're about to make.
- That test fails for the *right* reason — not a typo, not a missing dependency.
- You've written the minimum code to turn it green.
- The full suite is green.
- The test and the code are staged for the same commit.
