---
description: Simplify recently changed code without changing behavior. Reduce nesting, split long functions, kill duplication, kill dead code. Tests stay green throughout. Stop when "would a new teammate understand this faster?" — yes.
---

You are entering a **simplification pass**. No new features. No behavior changes. Make the code easier to read.

## Required reading

- The `code-simplification` skill — invoke it now
- The `karpathy-guidelines` skill — surgical, simple
- `PROJECT_CONTEXT.md` for stack conventions
- The recent diff (or specified scope) you're simplifying

## Process

1. **Identify the target.** Recent changes (last 1–3 commits) unless the user specified a path or function.
2. **Understand before touching.** Read callers. Read tests. Know what the code does and why.
3. **Look for these specific smells:**
   - Deep nesting → guard clauses or extracted helpers
   - Long functions → split by responsibility (one thing each)
   - Nested ternaries → if/else
   - Generic names (`data`, `process`, `handle`) → descriptive names
   - Duplicated logic → shared function
   - Dead code → delete
4. **Apply changes incrementally.** One smell at a time.
5. **Run the verify command after each change.** If tests fail, revert that change and reconsider.
6. **Stop when the test "would a new teammate understand this faster?" is yes.** Don't simplify for the sake of it.

## Iron rules

- **Behavior must not change.** All existing tests pass after every change. If a test breaks, you broke behavior — revert.
- **No new features. No "while I was here" additions.**
- **No new abstractions** unless they directly remove duplication that exists right now. Speculative abstraction is anti-simplification.
- **No reformatting code you didn't otherwise touch.** Stay surgical.

## Red flags

| Thought | Reality |
|---|---|
| "I'll add a helper class while I'm here" | That's a new abstraction, not a simplification. Stop. |
| "This naming is fine, just looks weird" | Name confusion is the most common source of bugs. Rename it. |
| "I'll fix this comment too" | If the comment was wrong, the code was confusing. Fix the code, then remove the comment. |
| "I'll extract this even though it's used once" | Single-use extractions usually make code harder to read, not easier. Inline it instead. |
| "I'll remove this `try/except`" | Don't, until you've checked what callers expect. Removing error handling can change behavior. |

## Output

After each change, state:

```
SIMPLIFIED: <one-line description>
- Verify: <green | red>
- Diff size: ~<N> lines
```

When done:

```
SIMPLIFICATION PASS COMPLETE

Changes:
1. <description> (file:line)
2. ...

Verify: green
Total diff: <N> lines across <M> files
Behavior change: none
```

## Hand off

Run `/review` next. A simplification pass is still a code change — it gets reviewed.
