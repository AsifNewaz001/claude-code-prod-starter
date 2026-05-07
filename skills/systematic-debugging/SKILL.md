---
name: systematic-debugging
description: Diagnoses bugs through reproduction, isolation, and bisection. Use when something is broken, output is unexpected, a test is failing, or behavior diverges from spec. Never patch a symptom you can't reproduce.
license: MIT
---

# Systematic Debugging

## Overview

Bugs are not solved by guessing. They are solved by:
1. Reproducing the bug reliably
2. Isolating the smallest input that triggers it
3. Bisecting the code to find the change that introduced it
4. Fixing the *cause*, not the symptom
5. Adding a regression test so it never returns

Anything else is hope, not engineering.

## When to use

- A test failed and you don't yet know why
- Production behavior differs from spec
- The user says "this used to work"
- Output is surprising — even if it didn't crash
- An intermittent / flaky failure

## The five-step loop

### 1. Reproduce

You cannot fix what you cannot trigger. Get a reliable repro before touching code.

- Capture the exact inputs, environment, and command.
- If it's flaky, run it 20× — record fail rate.
- If you can't repro locally, get the user to share their session, logs, or steps.

**No repro = no fix.** Stop and ask for more information rather than guess.

### 2. Isolate

Shrink the repro until removing one more thing makes the bug disappear.

- Strip inputs to the smallest that still fail.
- Comment out unrelated code paths.
- Pin dependencies to specific versions.
- The minimal repro is the one you can hold in your head.

### 3. Bisect

If the bug is "new," find the change that introduced it.

- `git bisect` between a known-good and known-bad commit.
- For multi-system bugs, bisect across services / configs / data, not just code.
- Read the diff at the breaking commit. Don't just read the commit message — messages lie, diffs don't.

### 4. Fix the cause

Once you know the change that broke it, ask: *why* did that change cause this?

- "It worked before X" is the symptom.
- "X assumed Y was always non-null, but Y can be null in case Z" is the cause.
- Patch the cause. Patching the symptom (a `try/except` swallowing the error) just hides the next variation of the same bug.

### 5. Regression test

Write a test that fails on the buggy code and passes on the fixed code. Same commit. This is non-negotiable — see `test-driven-development`.

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "Let me just try changing X" | That's guess-driven debugging. Repro first. |
| "It's flaky, ignore it" | Flaky tests are real bugs you haven't reproduced yet. |
| "I'll add a try/except and move on" | That's hiding the bug, not fixing it. Find the cause. |
| "It works on my machine" | Then your repro isn't capturing the user's environment. Get more data. |
| "The error message is wrong" | Error messages are clues. Trace where the error originates before disagreeing with it. |
| "I think it's a race condition" | Prove it. Race conditions can be reproduced with a stress loop. |

## Common rationalizations to push back on

- *"This is too complex to bisect."* — `git bisect run <test>` automates it. Bisecting 1000 commits takes ~10 steps.
- *"I'll fix it now and add the test later."* — You won't. The test is what proves the fix. Same commit.
- *"The cause is in someone else's code."* — Maybe. Confirm with a minimal repro before filing the bug elsewhere.

## When you're stuck

If you've spent 30+ minutes without progress:
1. Write down what you've tried, what failed, what you expected.
2. Ask the user (or another agent) to read it.
3. Often the act of writing it surfaces the wrong assumption.

## Verification

- You have a reliable repro (passes / fails on demand).
- You can name the *cause*, not just the symptom.
- A regression test fails before the fix, passes after.
- Full test suite is green.
- The fix and test are in the same commit.
