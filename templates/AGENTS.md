# AGENTS.md

Team playbook the agents read on every gate. Pairs with `PROJECT_CONTEXT.md` (project-specific) — this file is the workflow + brand.

## The 6 agents (orchestrator + 6 personas)

The orchestrator is **you** (Staff Engineer / human or top-level Claude). You do NOT act as any persona. You spawn them via the Agent tool with `subagent_type`.

| Persona | Role | Gates |
|---|---|---|
| design-agent | Visual contract + final visual parity | G1 (open), G9 (close) |
| cpo-agent | Requirements + UAT | G2 (requirements), G8 (UAT) |
| cto-agent | Architecture + post-build review | G3 (architecture + task list), G6 (post-build) |
| cbo-agent | Copy / CTA / i18n / brand voice | G4 |
| lead-engineer-agent | Implementation | G5 |
| lead-qa-agent | Adversarial QA (technical + design + business) | G7 |

This plugin ships **only** the cto-agent and lead-engineer-agent. The other 4 personas are project-specific (their content depends on your brand, design system, customer voice, regulatory context). Build them yourself or skip.

## Hard rules (the orchestrator enforces these)

1. **Self-review is a workflow violation.** No persona reviews its own output. CTO at G6 reviews Lead Eng G5 — not Lead Eng reviewing themselves.
2. **Gate order is fixed.** No skipping, no batching. G1 before G2 before G3, etc.
3. **Every gate produces a Decision Record (DR).** Hard limit: 10 lines. Path: `docs/decision-log/DR-YYYY-MM-DD-<feature>-g<N>-<role>.md`.
4. **Verdict block on every reply.** `<verdict>...</verdict><sev>...</sev><conditions>...</conditions><next>...</next>`.
5. **REJECTED at any gate routes back** to the prior owning gate. CONDITIONAL with met conditions advances. APPROVED advances unconditionally.
6. **Token budgets are soft targets** in `docs/agent-budgets.md`. Three consecutive over-runs at the same gate triggers a meta-task to debug.
7. **Tests ship in the same commit as code.** Never "tests later."
8. **Edit code, don't document it.** No-op gates produce no DR.

## Brand / voice

> **Project-specific. Define your brand here OR delete this section.**
>
> Example for Brand X:
> - Quince.com is the visual benchmark. Premium-but-honest, calm, unsentimental.
> - No exclamation marks. No "amazing / incredible / game-changing" copy.
> - Currency formatted per country: BDT (৳), AUD (A$), CAD (CA$), RUB (₽).

## Resume protocol (rate limit / API drop / mid-gate pause)

1. Commit any in-progress work with `WIP: G<N> <feature>` prefix.
2. Update `HANDOFF.md` top entry with: agent name, last spawn prompt, file paths touched, what was about to happen next.
3. The next orchestrator run reads the WIP marker and resumes — does NOT restart the gate.

## End-of-run (every session)

Update `HANDOFF.md` top entry with:
- Date (UTC) + latest commit SHA
- What shipped this run (feature × gates closed)
- Which gates are WIP and where they stopped
- Tree state (passing / failing checks)
- Next task for the next run (specific file paths, gate number, blockers)
- Anything needing human review

Commit and push the `HANDOFF.md` update as the **last** commit of the run.

## Style constraints

- Use UTC in `HANDOFF.md`.
- Write simple, human language. No corporate jargon. Lead with the conclusion.
- Currency in copy and math: per `PROJECT_CONTEXT.md`.
