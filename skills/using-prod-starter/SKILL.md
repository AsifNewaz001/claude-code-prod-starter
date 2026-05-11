---
name: using-prod-starter
description: Dispatcher for the claude-code-prod-starter plugin. Use at the start of every session to discover which skill, persona agent, specialist agent, or slash command applies to the current task. This meta-skill governs how all other primitives in this plugin are discovered and invoked.
license: MIT
---

# Using claude-code-prod-starter

This plugin is a complete production engineering kit for Claude Code: an auto-orchestrator + governance flow + SDLC skills + reusable specialists + lifecycle commands. This dispatcher routes any incoming task to the right primitive.

## DEFAULT: when in doubt, run `/go`

**`/go <user's request>`** is the auto-orchestrator. It detects intent, picks light vs full mode, runs the right flow, spawns specialist agents at the right moments, and pauses only at meaningful checkpoints (spec, plan, ship). It IS the noob-friendly entry point.

If a user types something that sounds like a build/fix/review task and they haven't picked a specific command, run `/go`. Don't make them learn the lifecycle commands first.

The other commands (`/spec`, `/plan`, `/build`, etc.) are still there for power users who want surgical control. But `/go` is the default.

## CRITICAL: `/go` ≠ `/autopilot`

These are DIFFERENT commands. Don't conflate them. Don't assume the user meant the heavier one when they said the lighter word.

| | `/go` | `/autopilot` |
|---|---|---|
| Flow | 6-step light cycle (spec → plan → build → test → review → ship) | 9-gate governance flow |
| Agents spawned | 1-3 specialists (code-reviewer + sometimes security-auditor / test-engineer) | 6 PM-style personas (design, cpo, cto, cbo, lead-engineer, lead-qa) |
| Token cost | ~50-200k per feature | ~600-900k per run (~$4-6) |
| Time | 5-15 min | 30-60 min |
| When to use | 90% of feature work, bug fixes, reviews | High-blast-radius only — auth, payments, multi-tenant, regulated |

**If the user asks for "autopilot" but their request sounds like a routine feature/fix:** STOP and ask: *"You said autopilot — did you mean the full 9-gate flow (heavy, expensive, ~$4-6)? Or the lighter `/go` flow (quick, ~50-200k tokens)?"* Wait for explicit answer. Don't spawn the cpo-agent on autopilot if they wanted /go.

Conversely if the user asks for "/go" but the request is clearly high-blast-radius (payment integration, auth refactor, schema migration), `/go` will detect this internally and route to `/autopilot` with confirmation.

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
    ├── User typed /go ────────────────────────→ /go orchestrator (DEFAULT)
    ├── Project missing PROJECT_CONTEXT.md? ───→ auto-context skill
    ├── Vague idea, unclear scope? ────────────→ /spec (or just /go and let it route)
    ├── Have a spec, need a plan? ─────────────→ /plan
    ├── About to write production code? ───────→ test-driven-development (always)
    │   └── Multi-step build? ────────────────→ /build
    ├── Something broken / unexpected output? ─→ systematic-debugging
    ├── Implementation done, ready to claim? ──→ verification-before-completion (always)
    ├── Reviewing finished code? ──────────────→ code-review skill, or code-reviewer agent
    │   ├── Security concerns? ───────────────→ security-auditor agent
    │   └── Test coverage concerns? ──────────→ test-engineer agent
    ├── Long session, context filling up? ─────→ /compress (or context-management skill)
    ├── Token spend high? ─────────────────────→ token-discipline skill
    ├── Picking which model? ──────────────────→ model-selection
    ├── Authoring a new skill for this plugin? ─→ writing-skills
    ├── New to Claude Code / confused? ────────→ claude-code-primer or /diagnose
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

## Two workflow modes

Pick one per task, not per project.

**Light mode (default for most work):**

```
/spec → /plan → /build → /test → /review → /code-simplify → /ship
```

No persona agents. No `PROJECT_CONTEXT.md` required. Closest to the addyosmani/agent-skills pattern. Use for the 90% of work that doesn't need committee review.

**Full mode (high blast radius):**

```
/autopilot
```

Spawns the 6 persona agents through 9 gates. Each gate produces a Decision Record. Self-review forbidden. Use for auth, payments, multi-tenant changes, regulated data — anything where a senior engineer would want a structured review before it ships.

**Rule of thumb:** if you'd want a review meeting before it ships, run `/autopilot`. Otherwise the lifecycle commands.

## Slash commands

| Command | Phase | Mode | Key principle |
|---|---|---|---|
| `/go` | Auto-orchestrate | both | **DEFAULT.** One sentence to PR. Routes intent, picks mode, runs the flow. |
| `/diagnose` | Inspect | — | Show what's installed, what's active, what `/go <X>` would do |
| `/spec` | Define | light | Spec before code |
| `/plan` | Plan | light | Atomic, testable tasks |
| `/build` | Build | light | TDD, one slice at a time |
| `/test` | Verify | light | Tests are proof |
| `/review` | Review | light | Five-axis quality gate |
| `/code-simplify` | Simplify | light | Clarity over cleverness, no behavior change |
| `/compress` | Context | both | Surgical context compression (structured `/compact` wrapper) |
| `/ship` | Ship | light | Faster is safer |
| `/autopilot` | Full flow | full | 9-gate governance, end to end |

## Skill list (this plugin)

Process skills:
- `using-prod-starter` — this dispatcher
- `karpathy-guidelines` — anti-overcomplication, surgical edits, surface assumptions
- `test-driven-development` — red-green-refactor, no production code without a failing test
- `systematic-debugging` — reproduce → bisect → fix → regression test
- `verification-before-completion` — never claim done without evidence
- `code-review` — five-axis review before merge
- `code-simplification` — reduce complexity without changing behavior
- `token-discipline` — reduce token spend on tool dumps, subagent spawns, and stale context
- `auto-context` — auto-generate PROJECT_CONTEXT.md from manifests (used by /go)
- `writing-skills` — authoring a new skill for this plugin
- `worktree-workflow` — git worktrees for parallel agent work

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

## Token discipline hooks (auto-enforced)

The plugin ships six hooks that fire automatically — you don't invoke them:

| Hook | Fires when | Effect |
|---|---|---|
| `bash-output-discipline` | Bash output >200 lines or >10k chars | Reminder with targeted-command suggestions |
| `subagent-discipline` | Agent spawn prompt >2000 chars | Tight-bundle pattern injection |
| `token-telemetry` | Every tool call | TSV log to `docs/agent-runs.log` for analysis |
| `auto-compact-suggest` | Session tokens cross 75k/150k | Suggests `/compact <focus>` at threshold |
| `dedup-tracker` | After Read/Grep/Glob | Records hash to `~/.claude/dedup-cache/<session>.log` |
| `dedup-advisor` | Before Read/Grep/Glob | Warns if same call was made already this session |

If you see one of these reminders, take it seriously. They mark the highest-leverage token-leak moments.

The plugin also ships `/compress`, a slash command that wraps `/compact` with a structured focus template (closer to OpenCode-DCP's range-mode compress than blind `/compact`).

For deeper guidance, invoke the `token-discipline` skill.

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
