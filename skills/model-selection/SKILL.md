---
name: model-selection
description: Use when picking which Claude model to invoke for a given task — Opus 4.7, Sonnet 4.6, or Haiku 4.5. Decision matrix with concrete examples, cost-per-task estimates, and when fast-mode helps. Picking the wrong model is daily and costly.
license: MIT
---

# Model selection — Opus 4.7 / Sonnet 4.6 / Haiku 4.5

The rule is not "always use the best model." The rule is: **match the model to the task's nature**. Wrong match = 10x cost (over-spec) or 10x slow / 10x bad output (under-spec).

## The three models

| Model | Strength | Weakness | Best for |
|---|---|---|---|
| **Opus 4.7** | Deepest reasoning. Longest sustained focus. Adversarial review. Complex synthesis across many files. | Slowest. Most expensive. Overkill for routine work. | Architecture decisions, post-build adversarial review, multi-file refactors with cross-cutting concerns, ambiguous research tasks |
| **Sonnet 4.6** | Fast and capable. The everyday workhorse. Great at code, decent at architecture. | Less deep than Opus on novel architectural problems. | Implementation, code review, test-writing, debugging, day-to-day coding |
| **Haiku 4.5** | Cheap and very fast. Great at single-shot tasks with clear inputs. | Misses nuance on complex multi-file work. | Quick lookups, single-file edits, summarization, lint-fix style cleanup, status-line scripts, hooks |

## Fast mode (Opus 4.6, accelerated)

Claude Code's `/fast` toggle is **Opus 4.6 with faster output**, not a downgrade. Use it when:

- You want Opus-quality output but the latency on Opus 4.7 is breaking your flow.
- You're in a back-and-forth loop where each turn is small.
- Note: `/fast` is only available on Opus 4.6, not 4.7.

If your task warrants Opus 4.7, leave fast mode off and pay the latency.

## The 9-gate flow's model picks (already encoded)

The plugin's 6 personas have models hardcoded. These are deliberate:

| Gate | Persona | Model | Why |
|---|---|---|---|
| G1 | design-agent | **opus** | Sets the visual contract everyone inherits — needs the deepest synthesis |
| G2 | cpo-agent | sonnet | Writing structured PRD from a known template |
| G3 | cto-agent | **opus** | Architecture across the whole stack — adversarial reasoning |
| G4 | cbo-agent | sonnet | Copy review against a known voice rubric |
| G5 | lead-engineer-agent | sonnet | Implementation against a clear task list |
| G6 | cto-agent | **opus** | Post-build adversarial review — catches what slipped past |
| G7 | lead-qa-agent | sonnet | 3-layer checklist — structured but voluminous |
| G8 | cpo-agent | sonnet | UAT walk-through |
| G9 | design-agent | **opus** | Final visual parity gate — the SOLE block on regressions |

The 4 opus-driven gates are the ones with the highest blast radius if wrong. Everything else is sonnet.

## When to override the gate's default model

Rarely. Examples:

- **Spike branches with no production exposure** — drop CTO gates from opus to sonnet to save tokens. Risk is acceptable because the spike won't ship.
- **Documentation-only sprint** — drop everything to haiku/sonnet. The 9-gate flow is overkill for prose.
- **Hotfix on a known small surface** — collapse to a 3-gate fast path (G3 architecture review + G5 impl + G6 post-build), all sonnet. Document the abbreviation in the DR.

## Cost-per-task estimates (rough, public pricing)

For a typical Sprint 19-style data sprint (838k total tokens across all 9 gates):

- All-opus (no model split): ~$10-12 per sprint
- Default split (opus G1/3/6/9 + sonnet rest): ~$4-6 per sprint
- All-sonnet (override): ~$1-2 per sprint
- All-haiku: ~$0.20 per sprint, but quality collapses

The default split is where you want to live. Don't over-optimize down — the SEV-1 you catch at G6 by paying for opus is worth $100k of avoided incident cost.

## Picking models OUTSIDE the gate flow

Decision flow when you're spawning your own subagent or running `/loop` or scheduling:

```
1. Is the task adversarial review or deep architectural reasoning?
   → Opus 4.7

2. Is the task multi-file refactoring with cross-cutting concerns?
   → Opus 4.7 (or Opus 4.6 fast mode if latency hurts)

3. Is the task implementation against a clear spec?
   → Sonnet 4.6

4. Is the task code review against a checklist?
   → Sonnet 4.6

5. Is the task a single-file edit, lookup, or summarization?
   → Haiku 4.5 (cheap and fast)

6. Is the task a status-line update, hook script, or any sub-second response?
   → Haiku 4.5

7. Are you uncertain which to pick?
   → Sonnet 4.6 (the safe default — capable enough for most things, not wasteful)
```

## The cost of picking wrong

- **Over-spec (using Opus 4.7 for a Haiku task):** you waste money and time. Tolerable for one-offs, painful at scale.
- **Under-spec (using Haiku 4.5 for an Opus task):** the output is wrong in subtle ways you may not catch. The bug ships. This is the dangerous failure mode.

When uncertain, err toward Sonnet, never Haiku.

## Anti-patterns

- "Always Opus 4.7" — burns budget; latency hurts flow on small tasks.
- "Always Haiku 4.5" — ships bugs you can't see.
- "Default to whatever the user has configured" — the user may have set Sonnet as default but the current task warrants Opus. Surface the choice.
- Spawning Opus subagents inside a Sonnet parent without budget consciousness — the child's tokens still cost real money even if they don't show up in the parent's context.

## Reference card (printable)

```
Opus 4.7      → architecture, adversarial review, complex synthesis
Opus 4.6 fast → same as 4.7 but faster latency
Sonnet 4.6    → implementation, everyday code, structured review (DEFAULT)
Haiku 4.5     → lookups, single-file edits, hooks, status lines
```

When in doubt: Sonnet 4.6.
