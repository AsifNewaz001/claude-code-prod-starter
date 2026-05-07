---
description: Build incrementally. Work the approved plan one task at a time. TDD — failing test, minimal code, verify, commit, next.
---

You are entering the **Build** phase. The plan is approved. Now write code.

## Required reading

- The plan at `docs/plans/YYYY-MM-DD-<feature>.md`
- The `test-driven-development` skill — invoke it now
- The `karpathy-guidelines` skill — surgical, simple, scoped
- The `verification-before-completion` skill — invoke when claiming done

## The loop

For each task in the plan, in order:

```
1. Read the task. Confirm files, test, expected behavior.
2. Write the failing test.
3. Run it. Confirm it fails for the RIGHT reason.
4. Write the minimum code that turns it green.
5. Run the verify command. Confirm green.
6. Commit (test + code in the same commit).
7. Update plan: mark task done. Note anything surprising.
8. Next task.
```

## Iron rules

- **No production code without a failing test first.** If you wrote code first, delete it. Implement fresh from the test.
- **Tests ship in the same commit as code.** Never "tests later."
- **Touch only what the task requires.** No "while I was here" cleanup.
- **Stay surgical.** If the task takes you outside the planned files, stop and ask.

## When you hit something unplanned

If a task reveals a problem the plan didn't anticipate:

1. Stop. Don't improvise into adjacent code.
2. Describe the surprise in 2–3 sentences.
3. Propose: (a) update the plan and continue, (b) finish the current task as-is and queue a follow-up, or (c) abort the plan.
4. Wait for the user's decision.

## Commit cadence

One commit per green task. Commit message format:

```
<verb> <what> for <feature>

<one or two lines on why, if non-obvious>
```

Verbs: `add`, `update`, `fix`, `refactor`, `remove`, `test`. No `chore:` / `feat:` prefixes unless the project already uses them — match local style (`PROJECT_CONTEXT.md`).

## Verify before claiming done

When the last task is green, invoke `verification-before-completion`. Don't say "done" until:

- Verify command is green.
- Feature works in its real runtime (or you've said it can't be tested in this environment).
- No regressions in adjacent tests.
- Diff matches the plan.

## Hand off to /review

Once verified, run `/review` (or spawn the `code-reviewer` agent). Self-review is a workflow violation — get fresh eyes.
