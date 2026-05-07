# AGENTS.md

This file is read by Codex CLI, Cursor agents, and other harnesses that look for `AGENTS.md`. It's the multi-harness equivalent of `CLAUDE.md`.

For Claude Code, the canonical entry point is the dispatcher skill (`skills/using-prod-starter/SKILL.md`) loaded via the SessionStart hook. This file mirrors the most important rules for agents that don't auto-load skills.

---

## What this plugin is

`claude-code-prod-starter` ships:

- **6 governance agents** (PM-style personas — design, cpo, cto, cbo, lead-engineer, lead-qa) under a 9-gate flow
- **3 specialist agents** (code-reviewer, security-auditor, test-engineer) — reusable, no flow
- **10 skills** — the dispatcher (`using-prod-starter`), 5 engineering skills (TDD, debugging, verification, code review, writing skills + worktree workflow), and 4 knowledge skills (Karpathy guidelines, context management, model selection, Claude Code primer)
- **7 commands** — `/autopilot` (full 9-gate flow) plus `/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship` (lifecycle phases)
- **Templates** for `CLAUDE.md`, `AGENTS.md`, `PROJECT_CONTEXT.md`, `HANDOFF.md`, plus `docs/governance-plan.md` and `docs/agent-budgets.md`
- **5-doc onboarding path** in `docs/onboarding/`

## How agents should use it

1. Read `PROJECT_CONTEXT.md` first. It declares the stack, the verify command, residency rules, cost ceilings.
2. Read this file (`AGENTS.md`) for workflow rules.
3. Read `CLAUDE.md` for behavioral guardrails (Karpathy guidelines).
4. For routine work, invoke the right skill via the harness's skill mechanism. For Claude Code, use the `Skill` tool.
5. For governed work, invoke `/autopilot` (full 9-gate flow) or a phase command (`/spec`, `/plan`, `/build`, etc.).

## The Iron Rules (always-on)

These apply to every agent and every harness:

1. **Surface assumptions.** Don't fill ambiguity silently. State your assumptions inline before non-trivial work.
2. **Tests ship in the same commit as code.** Never "tests later."
3. **No production code without a failing test first.** TDD is non-negotiable for behavior changes.
4. **Self-review is a workflow violation.** Don't review your own implementation. Spawn the `code-reviewer` agent or the `cto-agent` (gate G6).
5. **Don't act *as* a persona.** The orchestrator (you / the human / the top-level Claude) spawns the persona agents — does not roleplay them.
6. **Touch only what the request requires.** No "while I was here" cleanup. Surgical changes.
7. **Verify before claiming done.** Verify command green, feature tested in real runtime, no regressions.
8. **No card data on our servers.** Use payment provider iframes/redirects.
9. **Decision Records hard limit: 10 lines.** Edit code, don't document it.
10. **Verdict block on every governance gate.** Format: `<verdict>...</verdict><sev>...</sev><conditions>...</conditions><next>...</next>`.

## When `PROJECT_CONTEXT.md` is missing

Persona agents and `/autopilot` REFUSE to operate without it. Specialist agents and lifecycle commands work without it but are sharper with it. If missing, suggest the user copy `templates/PROJECT_CONTEXT.md` and fill it in.

## Brand / voice

> Project-specific. Define your brand here OR delete this section.

The persona agents (cbo, cpo, design) read `PROJECT_CONTEXT.md` § Brand for tone, copy rules, currency formats, and i18n conventions.

## Resume protocol

If a session is interrupted mid-gate (rate limit, API drop, manual stop):

1. Read `HANDOFF.md` — the top entry is the live baton.
2. Match the in-flight gate. Resume from the next sub-step, NOT from the start of the gate.
3. If the gate has no resume notes, re-run the gate cleanly.
4. Append a one-line resume entry to `HANDOFF.md` (`resumed at YYYY-MM-DD HH:MM UTC from G<N>`).

## File index

```
.claude-plugin/      → plugin metadata + marketplace listing
agents/              → persona + specialist agents (Markdown with YAML frontmatter)
commands/            → slash commands
hooks/               → SessionStart hook + dispatcher injection
skills/              → SKILL.md per directory
templates/           → CLAUDE.md, AGENTS.md, PROJECT_CONTEXT.md, HANDOFF.md, docs/
examples/            → filled-in PROJECT_CONTEXT.md references
docs/onboarding/     → 5-doc onboarding path
```

## Versioning

Semver. Bumped in `.claude-plugin/plugin.json`. CHANGELOG.md tracks user-visible changes.
