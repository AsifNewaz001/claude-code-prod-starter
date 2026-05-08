# Changelog

All notable changes to this plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] — 2026-05-08

**Type your idea. Get a shipped PR.** Major repositioning around `/go` — the auto-orchestrator that makes the plugin noob-friendly out of the box. After install, the user types one sentence; the plugin runs the full SDLC. Power users still get surgical control via the lifecycle commands.

### Added

- **`/go` command** — the new default entry point. Reads the user's request, auto-bootstraps `PROJECT_CONTEXT.md` if missing, detects intent (FEATURE / DEBUG / REVIEW / SIMPLIFY / EXPLAIN), detects blast radius (auth/payment/migration → high), picks light or full mode, runs the appropriate flow, spawns specialist agents at the right moments, and pauses only at three human-in-the-loop checkpoints (spec, plan, ship). Inlines the lifecycle commands so the user doesn't have to type them.

- **`auto-context` skill** — auto-generates a minimal `PROJECT_CONTEXT.md` from manifest files (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, etc.). Detects stack and verify command. Leaves residency / brand / project-type as TODOs for the user to fill. Used by `/go` so noobs don't hit the missing-context-file wall on first use.

- **`/diagnose` command** — read-only transparency tool. Shows plugin version, active hooks, available agents/skills/commands, current project state, recent token telemetry, and (if you pass a request) what `/go` would do. For when you're confused about what the plugin is set up to do.

### Changed

- **`README.md`** — major rewrite with viral positioning. Leads with the demo (`/go add dark mode` → PR in 8 min), comparison table vs Codex/Cursor/Gemini/Aider, two-mode framing (light default for `/go`, full for `/autopilot`), realistic savings math, and a clear "what this is NOT" section. Counts updated: skills 13→14, commands 9→11.

- **`skills/using-prod-starter/SKILL.md`** — `/go` is now featured as the DEFAULT entry point at the top of the dispatcher. Slash command table reorganized with `/go` first. Skill discovery flowchart updated to route to `/go` for ambiguous requests. Skill list updated with `auto-context`.

- **`plugin.json`** — bumped to **2.0.0**. Description rewritten around the "type your idea, get a PR" pitch.

### Why 2.0.0 (not 1.5.0)

The plugin's positioning has shifted. v1.x was "the plugin you install if you're already advanced enough to know which slash command to type." v2.0 is "the plugin you install when you want Claude Code to feel like magic, even if you've never written a slash command." That's a major shift in target audience and default UX, even though the under-the-hood machinery (skills, agents, hooks) is mostly unchanged.

Major version reflects:
- New default user experience (`/go` is the entry point, not `/autopilot` or `/spec`)
- New mandatory bootstrap path (`auto-context` removes the manual `PROJECT_CONTEXT.md` requirement for light mode)
- New positioning vs other AI coding tools (comparison table, "viral" pitch)

### Migration from v1.4.0

No breaking changes for existing users. All v1.x commands, skills, agents, hooks still work exactly as before.

What's new for existing users:
- Try `/go fix the X bug` instead of running `/spec` → `/plan` → `/build` manually.
- Try `/diagnose` to see everything the plugin has loaded.

What's new for noobs (the new target audience):
- Install. Restart. Type `/go <anything>`. The plugin handles the rest.

### Roadmap signals (not in this release)

- True payload-level compression equivalent to OpenCode-DCP — requires Anthropic to expand Claude Code's plugin API.
- Native tool-result deduplication in the API request — same blocker.
- Custom tools the model can invoke (e.g. a `compress` tool model picks autonomously) — same blocker.
- Multi-harness sync (`.codex-plugin/`, `.cursor-plugin/`) — buildable but deferred.

For workloads where token cost dominates, OpenCode + DCP remains a better fit. This plugin's value is workflow + governance + auto-orchestration, with token discipline as a strong supporting feature.

## [1.4.0] — 2026-05-08

OpenCode-DCP approximations. Three new hooks and one new slash command bring the plugin closer to DCP's behavior, within Claude Code's plugin-API limits.

### Added

- **`hooks/auto-compact-suggest.sh`** (PostToolUse, all tools) — sums session tokens from the telemetry log. Suggests `/compact <focus>` at 75k tokens (soft) and 150k tokens (hard). Fires at most once per threshold per session. Closest equivalent to DCP's auto-trigger on task completion.
- **`hooks/dedup-tracker.sh`** (PostToolUse on Read/Grep/Glob) — hashes tool_input and records it to `~/.claude/dedup-cache/<session>.log`. Cache trimmed to last 100 calls. Pure side effect, no Claude-visible output.
- **`hooks/dedup-advisor.sh`** (PreToolUse on Read/Grep/Glob) — hashes incoming tool_input and checks the dedup cache. If matched within the last 50 entries of the same tool name, warns Claude that the same call was already made. Closest equivalent to DCP's tool-result dedup.
- **`commands/compress.md`** — slash command that wraps `/compact` with a structured focus template (load-bearing decisions to keep, large outputs to drop, phase-completion marker). Closer to DCP's range-mode compress than blind `/compact`.

### Changed

- **`hooks/hooks.json`** — registers three new hooks across PostToolUse and PreToolUse.
- **`skills/token-discipline/SKILL.md`** — expanded "plugin hooks" table to six entries. New "DCP gap analysis" table documenting which DCP capabilities this plugin approximates and which require harness-level support.
- **`skills/using-prod-starter/SKILL.md`** — dispatcher's hook table expanded; slash command table now lists `/compress`.
- **`README.md`** — "Token discipline" section expanded with the three new hooks, the `/compress` command, audit recipes, and an honest DCP comparison table. Counts updated: hooks 4→7, slash commands 8→9.
- **`plugin.json`** — version 1.3.0 → 1.4.0.

### Honest scope (the DCP gap)

| OpenCode-DCP capability | This plugin | Why the gap |
|---|---|---|
| `compress` tool the model invokes when work closes | `/compress` slash command (user-invoked) | Claude Code can't expose custom tools to the model via plugin |
| Range-mode payload compression with placeholders | `/compress` → wraps `/compact` (broad, lossy) | Claude Code hooks can't modify the API request |
| Message-mode surgical compression | None | Same — no payload modification surface |
| Automatic dedup of identical tool calls in payload | `dedup-advisor` warns BEFORE re-run | Hooks fire around tool calls, not on the API payload |
| Error-input purge after N turns | None | Same — no payload modification |
| Auto-trigger compress on task completion | `auto-compact-suggest` (token-threshold based) | Model can't auto-run `/compact` as a tool |

Realistic savings stack with v1.4.0:
- Light vs full mode: ~70-85% on non-governance work
- Right model picks: 2-3× on routine code
- Tight subagent bundles (nudged by hook): 50-70% per spawn
- Output discipline (nudged by hook): 10-15% in heavy debug
- Auto-compact-suggest + `/compress` discipline: 10-20% in long sessions
- Dedup-advisor (skip identical re-reads): 5-10% in exploration-heavy work

Compose with discipline: 35-55% in practice. ~30-50% of DCP's effect. The remaining 50-70% of DCP's effect requires Claude Code to expand its plugin API.

### Migration

No breaking changes. Existing v1.3.0 installs gain three hook files and one command. The dedup cache lives at `~/.claude/dedup-cache/` (one log per session, auto-trimmed). The auto-compact marker lives at `${TMPDIR:-/tmp}/cc-prod-starter/`.

Windows users: hooks remain bash-only. Use WSL or Git Bash.

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
