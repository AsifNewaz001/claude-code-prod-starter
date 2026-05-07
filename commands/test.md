---
description: Prove it works. Run the verify command, exercise the feature in its real runtime, and check coverage of edge cases. Tests are proof — "seems right" is never enough.
---

You are entering the **Verify** phase. Implementation is done. Prove it works.

## Required reading

- `PROJECT_CONTEXT.md` § Verify — the verify command
- The `verification-before-completion` skill — invoke it now
- The `test-driven-development` skill if coverage is suspect

## Process

### 1. Run the verify command

The exact command from `PROJECT_CONTEXT.md` § Verify. Read the output. State explicitly:

```
Verify command: <command>
Result: <green | red>
<output snippet if red>
```

If red, switch to `systematic-debugging` and diagnose. Don't proceed.

### 2. Exercise the feature in its real runtime

For backend: hit the real endpoint, query the real DB, run the real job.
For frontend: open the dev server, click through. **If you can't open a browser, say so explicitly.**
For CLI: run the command, read the output.
For library: write a tiny consumer.

State the evidence:

```
Tested in <runtime>: <one-line evidence>
```

### 3. Edge case audit

Walk through these:

- **Empty / null:** what happens with no input?
- **Boundary:** what happens at the limits (max length, max count, max value)?
- **Concurrent:** what happens under simultaneous use?
- **Failure:** what happens when a downstream dependency fails?
- **Adversarial:** what happens with malicious or malformed input?

For each, either confirm covered by an existing test, or add a new test, or call out as out-of-scope with a one-line justification.

### 4. Regression sweep

- Did the full test suite run? Output count: `<N passed, M failed, K skipped>`.
- Any tests skipped that shouldn't be?
- Any new warnings, deprecations, or lints introduced?

### 5. Sign off

Output:

```
VERIFICATION COMPLETE

Verify command: green (`<command>`)
Runtime test: <one line>
Edge cases: <covered / N gaps queued>
Suite: <N passed, M failed>

Ready for /review.
```

## Red flags

| Thought | Reality |
|---|---|
| "Tests pass, ship it" | Tests prove what they assert. Run the feature. |
| "I'll skip the runtime test, it's a small change" | Small changes are where unverified bugs hide. |
| "I'll cover edge cases later" | Later doesn't come. Add them now or queue them as follow-ups with explicit owners. |

## Hand off

If green: run `/review` next.
If red: invoke `systematic-debugging`. Don't try to fix without a repro.
