---
description: Show what the plugin is about to do. Transparency for noobs — call this anytime if you're confused about which agent/skill/command is active or what /go would do for your request.
---

You are in **diagnose mode**. The user wants to see what the plugin is currently set up to do, what's installed, what would happen if they ran `/go <something>`, and what state their project is in.

This is a READ-ONLY command. Make no changes to files, repo, or git state.

## What to show

### 1. Plugin version + install location

```
Plugin: claude-code-prod-starter <version>
Installed at: ~/.claude/plugins/claude-code-prod-starter
Last updated: <git log -1 --format=%cd of plugin repo>
```

### 2. Active hooks

List the hooks currently registered in `~/.claude/plugins/claude-code-prod-starter/hooks/hooks.json`:

```
SessionStart:
  - session-start.sh — auto-loads dispatcher
PostToolUse (Bash):
  - bash-output-discipline.sh
PostToolUse (all):
  - token-telemetry.sh
  - auto-compact-suggest.sh
PostToolUse (Read|Grep|Glob):
  - dedup-tracker.sh
PreToolUse (Agent):
  - subagent-discipline.sh
PreToolUse (Read|Grep|Glob):
  - dedup-advisor.sh
```

### 3. Available agents, skills, commands

Three lists, one line each:

```
Agents (9):
  Persona: design, cpo, cto, cbo, lead-engineer, lead-qa
  Specialist: code-reviewer, security-auditor, test-engineer

Skills (14):
  using-prod-starter, karpathy-guidelines, test-driven-development,
  systematic-debugging, verification-before-completion, code-review,
  code-simplification, token-discipline, auto-context, writing-skills,
  worktree-workflow, context-management, model-selection, claude-code-primer

Commands (10):
  /go (default), /spec, /plan, /build, /test, /review, /code-simplify,
  /compress, /ship, /autopilot, /diagnose
```

### 4. Project state

```
PROJECT_CONTEXT.md: <present | missing — /go will auto-bootstrap>
AGENTS.md: <present | missing>
HANDOFF.md: <present | missing>
docs/governance-plan.md: <present | missing>

Verify command: <from PROJECT_CONTEXT.md, or detected from manifests>
Last verified: <if telemetry available>

Branch: <current branch>
Working tree: <clean | N modified files>
Ahead/behind main: <X ahead, Y behind>
```

### 5. Token telemetry summary (if available)

```
docs/agent-runs.log: <N> entries, <M> sessions
Today's tokens: in=<X>, out=<Y>
Heaviest tool this week: <tool> (<approx tokens>)
```

If no log, state: `No telemetry yet — telemetry hook fires after first tool call in a project.`

### 6. What `/go <user's pending request>` would do

If the user invoked `/diagnose` with a request after it, predict:

```
/go "<user's request>"
  Intent: <FEATURE | DEBUG | REVIEW | SIMPLIFY | EXPLAIN | ASK>
  Blast radius: <high | low> — <reason>
  Mode: <full | light>
  Flow: <ordered list of steps>
  Estimated tokens: <range>
  Estimated cost: <range in USD>
  Estimated time: <range in minutes>
```

If no request was supplied, skip this section.

## Output format

Use plain ASCII tables / bullets. No emojis except the inherited `✓` / `⚠` / `✗`. Keep it under one screen if possible. Section headers with `##`.

## What this command does NOT do

- Does NOT modify any files.
- Does NOT run any tools beyond `git status`, `git log`, `cat`, and reads of plugin files.
- Does NOT spawn agents.
- Does NOT prompt the user (read-only — show, then exit).

## Verification

- Output lists the actual installed version (read from `~/.claude/plugins/claude-code-prod-starter/.claude-plugin/plugin.json`)
- Hook list matches `hooks/hooks.json`
- Project-state section reflects actual `git status` and file presence
- No file modifications made
- No agents spawned
