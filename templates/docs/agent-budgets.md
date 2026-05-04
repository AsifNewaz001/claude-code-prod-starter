# Agent budgets

Soft token targets per gate. Over-runs are logged, not auto-fail. Three consecutive over-runs at the same gate = open a meta-task to debug.

## Targets

| Gate | Agent | Model | Target |
|---|---|---|---|
| G1 | design | opus | ≤ 60k |
| G2 | cpo | sonnet | ≤ 30k |
| G3 | cto | opus | ≤ 80k |
| G4 | cbo | sonnet | ≤ 25k |
| G5 | lead-eng | sonnet | ≤ 200k |
| G6 | cto | opus | ≤ 60k |
| G7 | lead-qa | sonnet | ≤ 80k |
| G8 | cpo | sonnet | ≤ 40k |
| G9 | design | opus | ≤ 40k |

## Telemetry capture

Append a single-line row to `docs/agent-runs.log` after every gate. Create the file (and a `.gitignore` exception for it) if it doesn't exist:

```
<ISO-time>|<sprint>|<gate>|<agent>|<model>|<total_tokens>|<tool_uses>|<duration_ms>|<verdict>
```

Source the numbers from the agent's `<usage>` block in the response. Verdict from the `<verdict>` block.

If you forget telemetry: it's a soft fault, log it next gate. Don't break flow.

## Calibration cadence

- **First 5 sprints:** weekly review (calibration unstable in early sprints).
- **After stable:** bi-weekly → monthly → quarterly.

Calibration means: read `docs/agent-runs.log`, identify gates consistently over-budget by >50%, raise their target in this file. The point is honest budgets, not aspirational ones.
