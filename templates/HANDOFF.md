# HANDOFF — YYYY-MM-DD | initial

> **First sprint pending.** This is the empty seed file. The `/autopilot` orchestrator will overwrite the top entry every run.

## Next task

The first feature for sprint 1 is: **<feature-name>**.

Spawn `design-agent` at G1 first to lock the visual contract. Then continue through the 9-gate flow in order: G2 cpo → G3 cto → G4 cbo → G5 lead-eng → G6 cto post-build → G7 lead-qa → G8 cpo UAT → G9 design final.

## Outstanding (pre-sprint setup)

- [ ] `PROJECT_CONTEXT.md` filled in (at minimum: stack, verify command, decision-log path)
- [ ] `AGENTS.md` brand voice section adapted
- [ ] Verify command runs green: `<paste your verify command from PROJECT_CONTEXT.md>`
- [ ] First feature scoped (one-sentence pitch) and added to backlog

## How `/autopilot` will use this file

The orchestrator reads this file's **top entry only** on each run. The format is:

```
# HANDOFF — YYYY-MM-DD | <one-line summary>

## What shipped this run
...

## Current state
...

## Next task for the next run
...

---

# HANDOFF — <previous-date> | ...
(older entries below the divider; orchestrator ignores them)
```

Stop conditions the orchestrator looks for in the top entry:

- **"Engineering complete"** / **"READY FOR LAUNCH"** / **"No further engineering sprints required"** → STOP, no agent spawn
- **`WIP: G<N> <feature>`** → resume from that gate, don't restart it
- Otherwise → continue with the gate listed under "Next task for the next run"
