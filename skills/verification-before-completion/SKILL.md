---
name: verification-before-completion
description: Never claim a task is done without evidence. Use before reporting any task complete — the verify command must be green, the feature must work in its real runtime, and no regressions must be introduced. "Seems right" is never enough.
license: MIT
---

# Verification Before Completion

## Overview

A task is not complete because you finished writing code. A task is complete when there is *evidence* that the change works:
- The verify command (declared in `PROJECT_CONTEXT.md`) is green.
- The feature behaves correctly in its real runtime — not just in your head.
- No existing tests broke.
- No new lints, type errors, or build failures appeared.

Reporting "done" without these is the single most common AI failure mode. Don't do it.

## When to use

- Before reporting any task complete to the user
- Before handing off to the next gate / agent / reviewer
- Before opening a PR
- Before merging anything
- After any "small fix" — these are exactly where verification gets skipped

## The verification checklist

Run through this every time. Don't skip steps because the change "feels small."

### 1. Verify command is green

```
<verify-command from PROJECT_CONTEXT.md>
```

- All tests pass.
- Type check / lint / build pass.
- No new warnings introduced.

If the verify command was red *before* your change, say so explicitly — don't pretend it's your fault, but also don't pretend it's done.

### 2. Feature works in its real runtime

For backend changes: hit the real endpoint, query the real DB, run the real job.

For frontend changes: open the dev server, click through the change, watch it in a browser. Type checking and unit tests confirm code correctness, not feature correctness. **If you can't open a browser, say so explicitly.**

For CLI changes: run the command. Read the output.

For library changes: write a tiny consumer that uses it. Run that.

### 3. No regressions

- The full test suite ran, not just the new tests.
- Adjacent features still work — at minimum, the golden path of any feature you touched.
- For shared utilities, search for callers and confirm at least the most common path still works.

### 4. Tests cover the change

- The new behavior has a passing test that exercises it.
- That test would fail on the old code.
- Edge cases are covered, not just the golden path.

### 5. The diff matches the request

- Every changed line traces to the user's request.
- No "while I was here" cleanup outside the asked scope.
- Imports cleaned only if you added them.
- Comments added only where the *why* is non-obvious.

## What to write when reporting completion

```
Done. Verified:
- Verify command: green (`<command>`).
- Tested in <runtime>: <one-line evidence — "endpoint returned 200 with the new field", "browser shows the new badge on the cart item", etc>.
- New tests: <N> passing. Existing tests: all <M> green.
- Diff scope: <files touched>, <approx LOC>.
```

If any item is missing, say so explicitly: *"Could not verify in browser — no dev server in this environment."* That's honest. *"Looks right"* is not.

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "It compiles, so it works" | Compiling proves syntax. It doesn't prove behavior. |
| "Tests pass, so the feature works" | Tests prove what they assert. They don't prove the feature is right. Run it. |
| "The change is small, no need to verify" | Small changes are where unverified bugs hide. |
| "I'll let CI catch it" | CI is the last line of defense, not the first. Verify locally. |
| "It worked when I tried it earlier" | Earlier was a different context. Verify against the current diff. |
| "The user can test it" | The user expects it to work when they get it. Don't outsource your verification. |

## Common rationalizations to push back on

- *"The verify command takes too long to run."* — Run it anyway. Optimize the test suite separately if it's a real problem.
- *"I made a one-line change, I don't need to retest."* — One-line changes are where retesting catches the most surprises.
- *"This is just refactoring, no behavior change."* — Refactoring is *exactly* when behavior changes silently. Verify.

## Verification (of this skill)

- You ran the verify command. You read its output. It is green (or you've said exactly why it isn't).
- You exercised the feature in its real runtime, or stated that you couldn't.
- You can list the evidence you used to claim "done."
