# 03 — Model selection

**Read time: 5 minutes.**

Picking the right model matters every day. Wrong pick = 10x cost (over-spec) or 10x bugs (under-spec). This doc is the decision matrix.

## The three models

| Model | What it's best at |
|---|---|
| **Opus 4.7** | Deepest reasoning. Adversarial review. Multi-file refactors with cross-cutting concerns. Architecture decisions. |
| **Sonnet 4.6** | The everyday workhorse. Implementation, code review, debugging, structured tasks. **Default when uncertain.** |
| **Haiku 4.5** | Cheap and very fast. Single-file edits, summarization, hooks, status lines, lookups. |

## Fast mode (Opus 4.6, accelerated)

`/fast` toggles **Opus 4.6 with accelerated output**. Not a downgrade — same model family, faster latency. Use when you want Opus quality but the latency on Opus 4.7 breaks your flow. Note: 4.7 doesn't support fast mode; only 4.6.

## The 9-gate flow's model picks (already encoded in this plugin)

The plugin's 6 personas have models hardcoded in their frontmatter:

| Gate | Persona | Model | Why |
|---|---|---|---|
| G1 | design-agent | **opus** | Sets the visual contract everyone inherits |
| G2 | cpo-agent | sonnet | Structured PRD writing |
| G3 | cto-agent | **opus** | Architecture across the whole stack |
| G4 | cbo-agent | sonnet | Copy review against a known rubric |
| G5 | lead-engineer-agent | sonnet | Implementation against a clear task list |
| G6 | cto-agent | **opus** | Post-build adversarial review |
| G7 | lead-qa-agent | sonnet | 3-layer checklist execution |
| G8 | cpo-agent | sonnet | UAT walkthrough |
| G9 | design-agent | **opus** | Final visual parity (sole block on regressions) |

The 4 opus gates are the highest-blast-radius decisions. Everything else is sonnet.

## Cost rough estimate per sprint (838k tokens, all 9 gates)

(Based on public pricing as of writing — check current rates.)

| Configuration | Approx cost |
|---|---|
| All Opus 4.7 (worst case) | $10–12 |
| Default split (4 opus + 5 sonnet, what this plugin does) | $4–6 |
| All Sonnet 4.6 (override) | $1–2 |
| All Haiku 4.5 (collapse) | $0.20 |

The default split is where you want to be. Don't optimize down — the SEV-1 you catch at G6 by paying Opus is worth $100k of avoided incident cost.

## Picking models OUTSIDE the gate flow

When you're spawning your own subagent, running `/loop`, or scheduling, follow this flow:

```
1. Adversarial review or deep architectural reasoning?
   → Opus 4.7

2. Multi-file refactor with cross-cutting concerns?
   → Opus 4.7 (or Opus 4.6 fast mode if latency hurts)

3. Implementation against a clear spec?
   → Sonnet 4.6

4. Code review against a checklist?
   → Sonnet 4.6

5. Single-file edit, lookup, or summarization?
   → Haiku 4.5

6. Status-line script, hook, or sub-second response?
   → Haiku 4.5

7. Uncertain?
   → Sonnet 4.6 (capable enough for most things, not wasteful)
```

## When to override the gate's default

Rarely, but valid cases:

- **Spike branches with no production exposure** — drop CTO gates from opus to sonnet. Risk acceptable; spike won't ship.
- **Documentation-only sprint** — drop everything to haiku/sonnet. The 9-gate flow is overkill for prose.
- **Hotfix on a known-tiny surface** — collapse to 3 gates (G3 architecture + G5 impl + G6 post-build), all sonnet. Document the abbreviation in the DR.

To override, edit the agent's frontmatter `model:` field temporarily, OR pass `model: "..."` in the Agent tool call.

## Anti-patterns

- **"Always Opus 4.7"** — burns budget; latency hurts flow on small tasks. Save it for the highest-blast-radius decisions.
- **"Always Haiku 4.5"** — ships bugs you can't see. The dangerous failure mode.
- **"Default to user config"** — your default may be Sonnet but THIS task warrants Opus. Surface the choice.
- **Spawning Opus subagents inside a Sonnet parent without budget consciousness** — the child's tokens still cost real money even if they don't show up in the parent's context.

## Reference card (printable)

```
Opus 4.7      → architecture, adversarial review, complex synthesis
Opus 4.6 fast → same as 4.7 but faster latency (use /fast)
Sonnet 4.6    → implementation, everyday code, structured review (DEFAULT)
Haiku 4.5     → lookups, single-file edits, hooks, status lines
```

When in doubt: **Sonnet 4.6**. Never Haiku for important work.

## What to read next

- `04-context-management.md` — don't blow your budget on long sessions
- `model-selection` skill (in this plugin) — same content in skill form
- `karpathy-guidelines` skill — Claude's behavioral rules (model-agnostic)
