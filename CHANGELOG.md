# Changelog

All notable changes to this plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] — 2026-05-08

Light-mode parity with addyosmani/agent-skills + clearer two-mode framing.

### Added

- **`/code-simplify` command** — refactor for clarity without changing behavior. Reduces nesting, kills duplication, improves names.
- **`code-simplification` skill** — five-principle simplification process (behavior must not change, incremental, names matter most, inline before extract, delete fearlessly).

### Changed

- **README.md** — added "Two modes" section near the top making the light-mode (addy-style lifecycle commands) vs full-mode (9-gate persona flow) distinction explicit. Counts updated: skills 11→12, commands 7→8.
- **Dispatcher skill (`using-prod-starter`)** — added "Two workflow modes" section so Claude routes the right way per task. Skill list and command table both updated.
- **`plugin.json`** — version 1.0.0 → 1.1.0. Description now mentions both modes.

### Why

Initial v1.0.0 shipped both modes but buried the light-mode story under the 9-gate flow. Some users want the full governance; many just want the addyosmani-style SDLC commands. Same plugin now serves both clearly.

## [1.0.0] — 2026-05-08

First production-grade release. Complete restructure to match the bar set by addyosmani/agent-skills and obra/superpowers.

### Added

- **SessionStart hook** (`hooks/hooks.json` + `hooks/session-start.sh`) — auto-injects the dispatcher skill into every new session so Claude knows which skills, agents, and commands ship with the plugin.
- **Dispatcher meta-skill** (`skills/using-prod-starter/SKILL.md`) — routes any incoming task to the right primitive. Replaces ad-hoc skill discovery.
- **5 engineering skills**:
  - `test-driven-development` — failing test first; tests ship in the same commit
  - `systematic-debugging` — reproduce, isolate, bisect, fix the cause, regression test
  - `verification-before-completion` — never claim done without evidence
  - `code-review` — five-axis review (correctness, readability, architecture, security, performance)
  - `writing-skills` — author or edit a skill for this plugin
- **1 process skill**:
  - `worktree-workflow` — git worktrees for parallel agent work and safe `/autopilot` runs
- **6 lifecycle commands**: `/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship` (alongside the existing `/autopilot`).
- **3 reusable specialist agents**: `code-reviewer`, `security-auditor`, `test-engineer` — task-focused, no persona, no gate ownership. Use ad-hoc.
- **Root `AGENTS.md`** — multi-harness compatibility (Codex CLI, Cursor agents).
- **`CONTRIBUTING.md`** — what we accept, what we don't, the contribution checklist.
- **`CHANGELOG.md`** — this file.
- **`marketplace.json`** — plugin marketplace listing metadata.

### Changed

- **`plugin.json`** — added `version`, `homepage`, `repository`, `license`, `keywords`, structured `author`, `hooks` reference. Description rewritten to reflect the v1.0.0 scope.
- **README.md** — rewritten with phase-flow diagram, auto-trigger explanation, multi-harness section, and updated install instructions.
- Existing skills (`karpathy-guidelines`, `context-management`, `model-selection`, `claude-code-primer`) unchanged in behavior.

### Migration notes

- If you installed v0.3.0, reinstall the plugin to pick up the SessionStart hook and the new agents/skills/commands. Your existing `PROJECT_CONTEXT.md` and `HANDOFF.md` continue to work.
- The 6 persona agents and the `/autopilot` command are unchanged. The 9-gate flow is unchanged.
- The new specialist agents (`code-reviewer`, `security-auditor`, `test-engineer`) are *additions* — they don't replace the persona agents. Use them ad-hoc for non-governed work or escalations.

## [0.3.0] — 2026-05-04

Initial public release.

### Added

- 6 PM-style persona agents (design, cpo, cto, cbo, lead-engineer, lead-qa)
- 9-gate governance flow (`docs/governance-plan.md`)
- `/autopilot` orchestrator command
- 4 skills: `karpathy-guidelines`, `context-management`, `model-selection`, `claude-code-primer`
- 5-doc onboarding path under `docs/onboarding/`
- Templates: `CLAUDE.md`, `AGENTS.md`, `PROJECT_CONTEXT.md`, `HANDOFF.md`, `docs/governance-plan.md`, `docs/agent-budgets.md`
- 2 examples: `brand-x-PROJECT_CONTEXT.md`, `solo-prototype-PROJECT_CONTEXT.md`
