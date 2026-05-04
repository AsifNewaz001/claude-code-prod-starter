# CLAUDE.md

Project-level behavior contract. Always loaded into Claude Code's context. Pairs with `AGENTS.md` (workflow), `PROJECT_CONTEXT.md` (stack-specific config), and the `karpathy-guidelines` skill.

> **Rule of thumb:** If it's a behavior rule that should apply to *every* turn, put it here. If it's a workflow / role / brand rule, put it in `AGENTS.md`. If it's a stack/infra rule, put it in `PROJECT_CONTEXT.md`.

---

## Behavioral guardrails (Karpathy guidelines, always-loaded)

### 1. Think before coding

Don't assume. Don't hide confusion. Surface tradeoffs.

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity first

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

### 3. Surgical changes

Touch only what you must. Clean up only your own mess.

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- Every changed line should trace directly to the user's request.

### 4. Goal-driven execution

Define success criteria. Loop until verified.

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- For multi-step tasks, state a brief plan with verify steps.

---

## Project entry points (read these on first turn of every session)

The plugin's 6 persona agents and `/autopilot` command read these in order:

1. **`PROJECT_CONTEXT.md`** — stack, tenancy/country, verify command, file paths, residency rules, cost thresholds. Required.
2. **`AGENTS.md`** — workflow (the 9-gate flow), brand voice, hard rules. Required.
3. **`docs/agent-budgets.md`** — per-gate token budgets + telemetry format.
4. **`docs/governance-plan.md`** — the 9-gate flow itself, gate-by-gate.
5. **`HANDOFF.md`** — current state of the project (top entry is the live baton).

If any of these are missing, **stop and surface it**, don't guess.

---

## Code-level constraints (universal)

- **Test-first** for any new logic that has acceptance criteria.
- **Tests ship in the same commit as code.** Never "tests later."
- **Verify command (declared in `PROJECT_CONTEXT.md` § Verify) must be green** before any commit.
- **No card data on our servers**, ever. Use payment provider iframes/redirects.
- **No `any` type without inline comment justifying it.**
- **No off-token color / font / spacing** if the project ships a design system.
- **No `style={{` inline styles** in production code (or the project's equivalent restriction).

---

## When to ask vs when to act

Ask when:
- The request has multiple reasonable interpretations.
- A simpler approach exists and the user might prefer it.
- The change touches a file outside the obvious scope.
- The change crosses a tenant/country/security boundary.
- The verify command is currently red and the cause isn't obvious.

Act when:
- The request is unambiguous AND the change is local AND tests cover it.
- You're in a `/autopilot` loop with verdict-block parsing — follow the gate flow.

---

## Output discipline

- Decision records live in `docs/decision-log/` and are **≤ 10 lines hard limit**.
- Every gate ends with a parseable verdict block (see `AGENTS.md` § verdict format).
- Edit code, don't document it. No-op gates produce no DR.
- Shortest, sharpest output while landing the most code wins.

---

This file is project-agnostic. Project-specific rules live in `PROJECT_CONTEXT.md` and `AGENTS.md`. The agents in this plugin will refuse to operate if those files are missing.
