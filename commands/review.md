---
description: Review before merge. Five-axis review: correctness, readability, architecture, security, performance. Approve when the change improves overall code health, even if not perfect.
---

You are entering the **Review** phase. Implementation is verified. Now check it before merge.

## Required reading

- The `code-review` skill — invoke it now
- The spec at `docs/specs/YYYY-MM-DD-<feature>.md`
- The plan at `docs/plans/YYYY-MM-DD-<feature>.md`
- `PROJECT_CONTEXT.md` for stack-specific concerns

## Self-review is a workflow violation

If you wrote the code, **don't review it.** Either:

- Spawn the `code-reviewer` agent (Agent tool, `subagent_type: code-reviewer`)
- For security-touching changes, spawn `security-auditor`
- For coverage-uncertain changes, spawn `test-engineer`

In the 9-gate governance flow, this is gate G6 — the `cto-agent` reviews `lead-engineer-agent`'s work. Same principle: fresh eyes only.

## Five-axis pass

For every changed file, score:

1. **Correctness** — does it do the thing? do tests honestly prove it?
2. **Readability** — would a teammate understand this in 6 months?
3. **Architecture** — does it fit the codebase, or fight it?
4. **Security** — does it open doors we don't want open?
5. **Performance** — does it hold up under realistic load?

## Output format

```
REVIEW: <feature>

## Blockers (must fix before merge)
- [correctness] file:line — <issue> → <suggestion>

## Majors (strong asks)
- [architecture] file:line — <issue> → <suggestion>

## Nits (optional)
- [readability] file:line — <issue> → <suggestion>

## Verdict
APPROVED | APPROVED-WITH-NITS | CHANGES-REQUESTED
```

## Approval standard

Approve when the change *improves overall code health*, even if not perfect.

- Don't block because it isn't how *you'd* have written it.
- Block because the codebase would be worse with this merged.
- Block on real correctness, real security, real architecture problems — not stylistic preferences.

## Red flags

| Thought | Reality |
|---|---|
| "Looks fine to me" | That's not a review. Run the five axes. |
| "The author is senior, probably correct" | Reputation isn't review. Read the diff. |
| "Tests pass, ship it" | Read the tests. Do they actually prove the change? |
| "I don't understand this part" | Then it isn't readable. That's a finding. |

## Hand off

If APPROVED or APPROVED-WITH-NITS: run `/ship`.
If CHANGES-REQUESTED: hand back to the implementer with the blocker list. After fix, re-run `/review`.
