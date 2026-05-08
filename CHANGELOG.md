# Changelog

All notable changes to this plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] — 2026-05-08

Token discipline hooks + skill. The plugin now actively nudges Claude toward better token discipline at the highest-leverage moments (bloated tool dumps, bloated subagent spawn prompts) and logs every tool call for post-session analysis.

### Added

- **`hooks/bash-output-discipline.sh`** (PostToolUse on Bash) — when a Bash command returns >200 lines or >10k chars, injects a system reminder with concrete suggestions (`grep` instead of `cat`, `--stat` before `git diff`, scoped `find` over `ls -R`).
- **`hooks/subagent-discipline.sh`** (PreToolUse on Agent) — when about to spawn a subagent with a >2000 char prompt, injects the tight-bundle pattern (static refs by path + dynamic delta + budget). Stronger nag at >5000 chars.
- **`hooks/token-telemetry.sh`** (PostToolUse on every tool) — appends a TSV line to `docs/agent-runs.log` per tool call: timestamp, session ID, tool name, approx input tokens, approx output tokens, cwd. Pure measurement; no Claude-visible output.
- **`skills/token-discipline/SKILL.md`** — codifies the practices the hooks enforce. Includes telemetry-reading recipes, red flags, and honest scope ("no magic 65% savings; without discipline the hooks just ping you").

### Changed

- **`hooks/hooks.json`** — added PostToolUse and PreToolUse entries for the three new hooks.
- **`skills/using-prod-starter/SKILL.md`** — added "Token discipline hooks (auto-enforced)" section so Claude treats hook reminders seriously. Skill list updated.
- **`README.md`** — new "Token discipline (built-in hooks)" section with telemetry-reading examples. Counts updated: skills 12→13, hooks 1→4.
- **`plugin.json`** — version 1.2.0 → 1.3.0. Description mentions the new hooks and skill.

### Honest scope

These hooks are **advisory**, not stream-rewriting. Claude Code's hook API can inject system messages but cannot modify the tool result the model already received. For RTK-style proxy compression of tool outputs, see external tools like 9router. The hooks here close the discipline gap, not the compression gap.

Realistic savings stack:
- Light vs full mode: ~70-85% on non-governance work
- Right model picks: 2-3× on routine code
- Tight subagent bundles (now nudged by hook): 50-70% per spawn
- Output discipline (now nudged by hook): 10-15% in heavy debug sessions

Compose with discipline and you land 30-50% in practice. 65% requires either external proxy compression or aggressive light-mode adoption.

### Migration

No breaking changes. Existing installs that pull `main` get the new hooks automatically. Three new files in `hooks/`, one new directory in `skills/`. The `docs/agent-runs.log` file is created per-project on first tool call (or in `~/.claude/agent-runs.log` if no `docs/` directory in cwd).

Windows users: hooks are bash-only. Use WSL or Git Bash for execution.

## [1.2.0] — 2026-05-08

Polish pass on the original 4 skills. Brings the whole skill library to one quality bar.

### Changed

- **`karpathy-guidelines`** — added Red Flags table, Common Rationalizations, Verification section. The 4 core rules (think → simplify → surgical → goal-driven) now have explicit anti-patterns and a verifiable "done" check.
- **`context-management`** — added Red Flags table, Common Rationalizations, Verification section. Existing Anti-patterns section retained. Adds explicit checks like "after `/compact`, the next turn's input token count is materially lower."
- **`model-selection`** — added Red Flags table, Common Rationalizations, Verification section. Existing Anti-patterns and "cost of picking wrong" sections retained. Verification includes "you can name the model you picked and why in one sentence."
- **`claude-code-primer`** — added Red Flags, Common Rationalizations, "When this skill applies", and Verification sections. Skill is now a process (vocabulary literacy with a test) not just reference content.

### Why

In v1.0.0 / v1.1.0 the new engineering skills (TDD, debugging, code-review, etc.) had Red Flags / Rationalizations / Verification sections that prevent agents from skipping the workflow mid-task. The original 4 skills didn't. This brings them to parity. The `writing-skills` skill itself prescribes this structure — now the original 4 follow their own rule.

### Migration

No breaking changes. All existing skill descriptions and frontmatter unchanged. The new sections are appended; agents using these skills will see strictly more guidance, never less.

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
