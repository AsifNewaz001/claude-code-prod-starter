---
name: code-simplification
description: Simplifies code without changing behavior. Use when code works but is harder to read, maintain, or extend than it should be. Use after a feature lands and the implementation feels heavier than necessary. Use during code review when readability is flagged. Goal is not fewer lines — it's code a new teammate understands faster.
license: MIT
---

# Code Simplification

## Overview

Simplify code by reducing complexity while preserving exact behavior. The goal is not fewer lines — it's code that is easier to read, modify, and debug.

Every simplification passes one test: *"Would a new team member understand this faster than the original?"* If yes, keep. If no or unsure, revert.

## When to use

- A feature is working and tests pass, but the implementation feels heavier than it needs to be
- Code review flagged readability or complexity
- You're staring at deeply nested logic or 100-line functions
- Code was written under time pressure and now you have time
- Related logic is scattered across files and hard to follow
- A merge introduced duplication or inconsistency

## When NOT to use

- Code is already clean — don't simplify for the sake of it
- You don't understand what the code does yet — comprehend before simplifying
- The code is performance-critical and "simpler" would be measurably slower
- You're about to rewrite the module entirely — simplifying throwaway code wastes effort

## The five principles

### 1. Behavior must not change

Every existing test passes after every change. If a test breaks, you broke behavior — revert the change. Don't "fix" the test to match the new behavior.

### 2. Make changes incrementally

One smell at a time. Run the verify command between every change. Commit between every change if it stands on its own.

A 200-line "simplification" PR is unreviewable and probably broke something silently.

### 3. Names matter more than structure

The fastest simplification is renaming. `processData()` → `validateAndStoreOrder()` makes the next reader's job easier than any structural refactor.

Generic names to hunt for and replace: `data`, `info`, `process`, `handle`, `manager`, `helper`, `util`, `temp`, `result`, `value`.

### 4. Inline before extract

Premature extraction makes code harder, not easier. Default rules:

- Used once → inline.
- Used twice → look at it; might still be inline.
- Used three+ times → extract.

The "rule of three" exists because two uses are often coincidence and one extracted helper for two callers locks in the wrong shape.

### 5. Delete fearlessly, but verify

Dead code is the easiest win. But "I think this is unused" is not enough — grep the whole repo first.

- Unused imports: delete after confirming.
- Unused functions: grep callers, check exports, then delete.
- Commented-out code: delete (git remembers).
- "Just in case" branches: delete unless they handle a real edge case in a real test.

## The smell catalog

| Smell | Fix |
|---|---|
| Deep nesting (>3 levels) | Guard clauses + early returns |
| Long function (>50 lines) | Split by responsibility |
| Nested ternaries | `if/else` or `switch` |
| Generic name | Descriptive name |
| Duplicated logic across 3+ places | Shared function |
| Dead code | Delete (after grep) |
| `if (x) return true; else return false` | `return x` |
| Repeated null checks | Early return or default value |
| `try/catch` swallowing the error | Either handle it meaningfully or remove |
| Comments explaining *what* the code does | Rename until the comment is unnecessary |

## The work loop

```
1. Pick one smell from the recently changed code.
2. Apply the fix.
3. Run the verify command.
4. If green: commit (or stage). If red: revert this change.
5. Repeat until "would a new teammate understand this faster?" is yes.
6. Stop.
```

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "I'll add a helper class while I'm here" | That's a new abstraction, not a simplification. |
| "I'll restructure this entire module" | That's a rewrite, not a simplification. Different skill. |
| "This is just my preference" | If it isn't measurably better for the next reader, don't change it. |
| "I'll squash all simplifications into one commit" | Unreviewable. Keep them separable. |
| "Tests pass, this is fine" | Run the *full* test suite, not just the unit tests near the change. |

## Common rationalizations

- *"I'll generalize this for future use cases."* — YAGNI. Generalize when the third caller arrives, not before.
- *"This pattern is in the rest of the codebase, I should match it."* — Sometimes. But if the pattern is the smell, you can be the start of the fix. Flag it for the team.
- *"The existing names are fine."* — If you had to read the function body to know what the function does, the name isn't fine.

## Verification

- Verify command green after every change.
- Behavior unchanged: full test suite passes.
- Diff is reviewable — not a 500-line dump.
- Each commit (or section of the diff) stands on its own and could be reverted independently.
- A new teammate would, demonstrably, understand the new code faster.
