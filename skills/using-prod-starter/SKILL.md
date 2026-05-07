---
name: using-prod-starter
description: Dispatcher for the claude-code-prod-starter plugin. Use at the start of every session to discover which skill, persona agent, specialist agent, or slash command applies to the current task. This meta-skill governs how all other primitives in this plugin are discovered and invoked.
license: MIT
---

# Using claude-code-prod-starter

This plugin is a complete production engineering kit for Claude Code: governance flow + SDLC skills + reusable specialists + lifecycle commands. This dispatcher routes any incoming task to the right primitive.

## The Rule

**Invoke a relevant skill BEFORE responding or taking action.** Even a 1% chance a skill applies means invoke it. If it turns out wrong for the moment, drop it. The cost of skipping is much higher than the cost of checking.

## Instruction priority

1. **User's explicit instructions** (CLAUDE.md, AGENTS.md, PROJECT_CONTEXT.md, direct chat) — highest.
2. **This plugin's skills** — override default behavior where they conflict.
3. **Default system prompt** — lowest.

If `CLAUDE.md` says "skip TDD for prototypes" and the TDD skill says "always TDD", follow the user.

## How to access skills

In Claude Code, use the `Skill` tool. When invoked, the skill content loads — follow it directly. Never use `Read` on a SKILL.md file; that bypasses the activation contract.

## Skill discovery flowchart

```
Task arrives
    │
    ├── Vague idea, unclear scope? ────────────→ /spec or G1–G2 (design + cpo agents)
    ├── Have a spec, need a plan? ─────────────→ /plan or G3 (cto agent)
    ├── About to write production code? ───────→ test-driven-development (always)
    │   └── Multi-step build? ────────────────→ /build or G5 (lead-engineer agent)
    ├── Something broken / unexpected output? ─→ systematic-debugging
    ├── Implementation done, ready to claim? ──→ verification-before-completion (always)
    ├── Reviewing finished code? ──────────────→ code-review skill, or code-reviewer agent
    │   ├── Security concerns? ───────────────→ security-auditor agent
    │   └── Test coverage concerns? ──────────→ test-engineer agent
    ├── Long session, context filling up? ─────→ context-management
    ├── Picking which model? ──────────────────→ model-selection
    ├── Authoring a new skill for this plugin? ─→ writing-skills
    ├── New to Claude Code? ───────────────────→ claude-code-primer
    └── Production feature, full governance? ──→ /autopilot (the 9-gate flow)
```

## Persona agents (governance flow)

These are your *role-playing* agents. Each owns one or two gates. You spawn them with the `Agent` tool using `subagent_type`.

| Agent | Gates | Owns |
|---|---|---|
| `design-agent` | G1, G9 | Visual contract, final visual parity |
| `cpo-agent` | G2, G8 | Requirements PRD, UAT |
| `cto-agent` | G3, G6 | Architecture, post-build review |
| `cbo-agent` | G4 | Copy / CTA / i18n / brand voice |
| `lead-engineer-agent` | G5 | Implementation |
| `lead-qa-agent` | G7 | Adversarial QA |

Use these when running the full 9-gate flow via `/autopilot`. Don't act *as* a persona yourself — spawn the subagent.

## Specialist agents (reusable, no flow)

These are *task-focused* agents you call ad-hoc. No persona, no gate ownership.

| Agent | When to use |
|---|---|
| `code-reviewer` | Before merging any change. Five-axis review: correctness, readability, architecture, security, performance. |
| `security-auditor` | When the change touches auth, data flow, payments, file uploads, or external input. OWASP-aligned. |
| `test-engineer` | When test coverage is uncertain, when a bug needs reproduction-first, or when designing a test plan. |

## Slash commands

Lifecycle commands map to the SDLC. Each one activates the right skills automatically.

| Command | Phase | Key principle |
|---|---|---|
| `/spec` | Define | Spec before code |
| `/plan` | Plan | Atomic, testable tasks |
| `/build` | Build | TDD, one slice at a time |
| `/test` | Verify | Tests are proof |
| `/review` | Review | Five-axis quality gate |
| `/ship` | Ship | Faster is safer |
| `/autopilot` | Full flow | 9-gate governance, end to end |

## Skill list (this plugin)

Process skills:
- `using-prod-starter` — this dispatcher
- `karpathy-guidelines` — anti-overcomplication, surgical edits, surface assumptions
- `test-driven-development` — red-green-refactor, no production code without a failing test
- `systematic-debugging` — reproduce → bisect → fix → regression test
- `verification-before-completion` — never claim done without evidence
- `code-review` — five-axis review before merge
- `writing-skills` — authoring a new skill for this plugin

Knowledge skills:
- `context-management` — `/compact`, subagent budgets, cache TTL
- `model-selection` — Opus 4.7 / Sonnet 4.6 / Haiku 4.5 decision matrix
- `claude-code-primer` — agents vs skills vs commands vs hooks vs plugins

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "Just a quick fix, skip the skill" | Quick fixes are how regressions ship. Invoke the skill. |
| "I already know what TDD is" | Knowing ≠ doing. Invoke the skill anyway. |
| "Let me explore the code first" | The skill tells you HOW to explore. Invoke first. |
| "This is a one-line change" | One-line changes are where the worst bugs hide. Invoke the skill. |
| "I'll write tests after" | "After" never comes. Tests ship in the same commit. |
| "The user said be quick" | Quick is the result of discipline, not the absence of it. |

## Surface-and-ask discipline

Before any non-trivial implementation, surface your assumptions inline:

```
ASSUMPTIONS:
1. <thing about scope>
2. <thing about constraints>
3. <thing about success criteria>
→ Correct me now or I proceed with these.
```

Don't silently fill ambiguity. The single highest-leverage habit in this plugin.

## When PROJECT_CONTEXT.md is missing

The persona agents and `/autopilot` refuse to operate without `PROJECT_CONTEXT.md`. The specialist agents and lifecycle commands (`/spec`, `/plan`, etc.) work without it but are sharper with it. If it's missing, suggest the user copy `templates/PROJECT_CONTEXT.md` and fill it in — but don't block on it for one-off skill use.
