---
description: Plan how to build it. Break the spec into atomic, testable tasks an enthusiastic junior engineer could follow without asking questions. Saves to docs/plans/YYYY-MM-DD-<feature>.md.
---

You are entering the **Plan** phase. The spec is approved. No code yet.

## Your job

Turn the approved spec into an implementation plan that's bite-sized enough that each task has one obvious next action and one obvious verification.

## Required reading

- The spec at `docs/specs/YYYY-MM-DD-<feature>.md`
- `PROJECT_CONTEXT.md` — stack + verify command
- The `karpathy-guidelines` skill
- The `test-driven-development` skill — every task includes its test

## Plan format

Save to `docs/plans/YYYY-MM-DD-<feature-name>.md`. Sections:

```markdown
# <Feature> plan

## Spec
Link to docs/specs/YYYY-MM-DD-<feature>.md

## File map
Which files get created / modified, and what each one is responsible for.
- path/to/new-file.ts — <one-line responsibility>
- path/to/modified-file.ts — <what changes>

## Task list

Each task is 2–10 minutes of focused work. Each one has:
- Files touched
- The failing test (write this first)
- The minimal code to pass
- Verify step

### Task 1: <name>
- Files: …
- Test: <describe the failing test>
- Code: <one sentence on the minimum implementation>
- Verify: <command + expected result>

### Task 2: <name>
…

## Out of scope
Bullet list of things the spec mentioned but this plan won't touch. Explain briefly why.

## Risks
The 1–3 things most likely to go sideways. What to watch for.
```

## Process

1. Read the spec. If anything in the spec is now unclear, stop and ask before planning.
2. Map the file structure first. Decompose by responsibility, not by layer.
3. Break into tasks. Each task ships working, testable software on its own.
4. Mark tasks that can be parallelized (different files, no shared state).
5. Show the plan to the user. Get approval.
6. Save it. Commit it.
7. Suggest `/build` next.

## Bite-sized rule

If a task description has the word "and" connecting two actions, split it.

- "Write the validator" — task.
- "Write the validator and add it to the form" — two tasks.

## Hard rule

Do NOT start coding until the user approves the plan. Show the file map and the task list. Wait.
