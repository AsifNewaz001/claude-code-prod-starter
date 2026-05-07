---
name: karpathy-guidelines
description: Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, reviewing, or refactoring code to avoid overcomplication, make surgical changes, surface assumptions, and define verifiable success criteria.
license: MIT
---

# Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "I'll just pick the most likely interpretation" | That's silent assumption. Surface it inline first. |
| "A little extra config flexibility won't hurt" | YAGNI. It hurts the next reader. Don't add it. |
| "While I'm here, let me clean up this file" | Out of scope. Leave it. |
| "I'll know it works when I see it" | "Seems right" is not done. Define the verify step. |
| "The user said move fast" | Fast is the result of discipline, not its absence. |
| "This abstraction will pay off later" | Later doesn't come. Inline it; abstract when you actually need it. |
| "I added error handling for safety" | If the error can't actually happen, the handler is noise. Delete it. |

## Common rationalizations to push back on

- *"The simpler version doesn't handle edge case X."* — Does X actually happen in this code path? If not, you're adding code for a phantom case. Cut it.
- *"This refactor makes the file cleaner."* — If the refactor wasn't requested and doesn't trace to the user's task, it's scope creep. File it as a follow-up; don't bundle it.
- *"It's faster to just guess and try."* — Faster for one turn. Slower across the conversation when the guess is wrong.
- *"The user will tell me if they want something different."* — They might. They might also accept your interpretation silently and find out it was wrong in production.

## Verification

- Before any non-trivial implementation: assumptions surfaced inline, in plain words.
- Diff size matches the request — every changed line traces to the user's ask.
- No new abstractions, configs, or error handlers without a concrete current need.
- Success criterion stated and verified — not "looks right," but "the test for X passes" or "the verify command is green."
