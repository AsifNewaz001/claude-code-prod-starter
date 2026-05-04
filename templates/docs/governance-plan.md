# Governance plan — 9-gate flow

The flow this plugin's agents operate within. Generic version; copy to `docs/governance-plan.md` in your repo and adapt.

## The 9 gates

For every feature:

| Gate | Owner | Output |
|---|---|---|
| G1 | design-agent | Visual contract — mobile-first spec, tokens, reference imagery + DR |
| G2 | cpo-agent | Requirements PRD + user journeys + visual ACs (inherits G1) + DR |
| G3 | cto-agent | Architecture decision + Lead Engineer task list (concrete todos) + DR |
| G4 | cbo-agent | Copy / CTA / i18n / brand voice review + DR |
| G5 | lead-engineer-agent | Implementation against G3 task list + tests + PR description + DR |
| G6 | cto-agent (post-build) | Verifies impl matches G3 + catches scale/security pre-QA + DR |
| G7 | lead-qa-agent | Validates 3 layers — technical, design adherence, business cases + DR |
| G8 | cpo-agent (UAT) | UAT report on running build + DR |
| G9 | design-agent (final) | Final visual parity vs G1 + mobile-first re-check + DR |

## Gate-closed criteria

A gate is closed when:
1. The decision-record file exists at `docs/decision-log/DR-YYYY-MM-DD-<feature>-g<N>-<agent>.md` (≤ 10 lines), AND
2. The agent's reply ends with `<verdict>APPROVED</verdict>` or `<verdict>CONDITIONAL</verdict>` with conditions noted as either `inline-fixed-at-<SHA>` or queued for follow-up.

`<verdict>REJECTED</verdict>` requires fix-then-respawn. The orchestrator either fixes inline + re-spawns the agent for re-approval, OR escalates to the user.

## Why the flow

- **Design first (G1).** The visual contract is the bar QA holds against. If you write requirements before design, requirements drift to fit code instead of code fitting requirements.
- **CTO twice (G3 + G6).** G3 prevents scope drift before code is written; G6 catches what slipped past CTO's own task list.
- **CPO twice (G2 + G8).** G2 owns "what should we build"; G8 owns "did the build deliver."
- **Design last (G9).** Visual regressions are the easiest to ship and hardest to catch. The opener should be the closer.
- **Lead QA after CTO post-build (G7 after G6).** Architecture issues bubble up first; QA focuses on design + business cases.

## When to invoke fewer gates

If your sprint is data-only (no UI):
- G1 design-agent still locks the visual contract for any UI that *consumes* the data ("zero visible regression after migration").
- G4 CBO can still review seed copy.
- All 9 gates apply unless explicitly excluded.

If your sprint is design-only (no schema):
- G3 CTO still reviews infra impact (CDN cache, image weight) and produces a Lead Eng task list for the implementation.
- All 9 gates apply.

In rare cases (typo fix, dependency bump), 3 gates is enough: G3 (CTO architecture review for surface area), G5 (Lead Eng implementation), G6 (CTO post-build). Document the abbreviation in the DR.
