---
description: Ship to production. Final pre-merge checks, commit hygiene, PR description, deploy notes. Faster is safer when discipline is in the loop.
---

You are entering the **Ship** phase. Review is approved. Now merge and deploy.

## Required reading

- `PROJECT_CONTEXT.md` for deploy command, branch policy, environments
- The review verdict from `/review`
- Recent CI status

## Pre-merge checklist

Don't ship until every box is true:

- [ ] Verify command green on the latest commit (re-run, don't trust earlier output)
- [ ] All review blockers addressed
- [ ] Spec and plan committed alongside the code (`docs/specs/...`, `docs/plans/...`)
- [ ] Tests in the same commit(s) as the code
- [ ] No `console.log`, `print(...)`, debugger, `TODO: remove` left in the diff
- [ ] No new env vars / secrets without doc updates
- [ ] CHANGELOG entry if the project keeps one
- [ ] Migration / data backfill considered if schemas changed

If any fail, stop and fix.

## Commit hygiene

Before merging, look at the commit log for this branch:

```
git log --oneline main..HEAD
```

Each commit should be one logical change with a clear message. If history is messy:

- Squash trivial fixups into the parent commit (`git rebase -i`).
- Keep test+code commits intact — don't squash them apart.
- Don't rewrite shared history.

Ask the user before squashing if there's any doubt. **Never force-push to `main`.**

## PR description

Use this template:

```markdown
## Summary
1–3 bullets. What changed and why.

## Testing
- Verify command output: <command, result>
- Runtime check: <one line>

## Linked
- Spec: docs/specs/YYYY-MM-DD-<feature>.md
- Plan: docs/plans/YYYY-MM-DD-<feature>.md

## Risk
- <one line on what could go wrong, blast radius, rollback plan>

## Deploy notes
- Migrations: <yes/no, command if yes>
- Feature flag: <yes/no, name if yes>
- Backfill: <yes/no>
```

## Deploy

Follow `PROJECT_CONTEXT.md` § Deploy. If unclear, ask.

After merge:
- Watch the deploy logs / CI for the first 5 minutes.
- Smoke-test the change in the deployed environment.
- If anything looks off, prepare to roll back — don't hesitate.

## Red flags

| Thought | Reality |
|---|---|
| "Reviewers said it's fine, I can ship now" | Re-run verify on the merged commit. CI lies less often than people, but it does lie. |
| "It's a small change, no need to monitor deploy" | Small changes are where the production-only bugs surface. |
| "I'll write the changelog later" | "Later" is the past tense of "never." Same commit. |
| "Force-push will fix it faster" | Force-push to a shared branch destroys history. Use a follow-up commit. |

## Hand off

After successful deploy:

- Update `HANDOFF.md` with current state (if using `/autopilot`).
- Close the spec / plan loop with a one-line "shipped on <date> at <SHA>".
- If using the 9-gate flow, advance to G9 (design final visual parity).
