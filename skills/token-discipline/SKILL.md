---
name: token-discipline
description: Reduce token spend without sacrificing quality. Use whenever a session gets long, a tool dump is huge, a subagent spawn prompt is bloated, or you're about to run /loop or /autopilot. Pairs with the plugin's three discipline hooks (bash-output-discipline, subagent-discipline, token-telemetry).
license: MIT
---

# Token Discipline

## Overview

Token spend on Claude Code is dominated by four levers:

1. **Tool output bloat** — pasting 5000 lines of `git diff` into context when 50 lines would do.
2. **Subagent spawn prompts** — "read AGENTS.md and figure it out" beats a 2000-char tight bundle by zero. The reverse beats it 5×.
3. **Wrong model picks** — Opus for a Sonnet task is a 5× overspend; Haiku for an Opus task is bug-shipping.
4. **Stale context that should have been compacted** — auto-compaction is reactive and lossy; deliberate `/compact` at phase boundaries is sharp.

The plugin's hooks enforce levers 1 and 2 by injecting reminders. This skill codifies the practices and the verification checks.

## When to use

- Session length > 5 turns
- A Bash command just returned >200 lines
- About to spawn any subagent (`Agent` tool)
- About to start `/autopilot` or `/loop`
- Context indicator shows >50% full
- After a debugging loop closes

## Iron rules

### 1. Pre-flight before every subagent spawn

The plugin's `subagent-discipline` hook fires automatically and reminds you. Don't ignore it. Tight bundle pattern:

```
Read on demand:
- PROJECT_CONTEXT.md
- docs/decision-log/<latest gate's DR>

Build SHA: <sha>
Files changed: <git diff --stat snippet, ≤10 lines>
Prior gate conditions: <numbered list, ≤5 items>

Your budget: <N> tokens. Self-monitor. End with verdict block.
```

Target: spawn prompt under 2000 chars. Anything over 5000 chars is a smell.

### 2. Targeted commands, not full dumps

The plugin's `bash-output-discipline` hook fires when output exceeds 200 lines or 10000 chars. Don't ignore it. Replace:

| Don't | Do |
|---|---|
| `cat path/to/big-file.log` | `grep ERROR path/to/big-file.log \| head -50` |
| `ls -R` | `find . -name '*.tsx' -maxdepth 3` |
| `git diff main` | `git diff --stat main` (then drill into specific files) |
| `npm test` (full output) | `npm test 2>&1 \| tail -30` |
| `find . -name foo` from repo root | scope with explicit subdirs |

### 3. Compact at phase boundaries, not on paranoia

Run `/compact` after a phase ends — debugging loop closed, requirements gathered, gate complete. Do NOT run it after every turn (cache miss compounds).

### 4. Pick the right model

Opus 4.7 only on highest-blast-radius tasks. Sonnet 4.6 for everyday code. Haiku 4.5 for lookups and one-shot edits. See `model-selection` skill for the decision matrix.

## The plugin hooks (what they do)

| Hook | Trigger | Action |
|---|---|---|
| `bash-output-discipline` | After any Bash call | If output >200 lines or >10k chars, injects a reminder with concrete suggestions for next time. |
| `subagent-discipline` | Before any Agent spawn | If prompt >2000 chars, injects the tight-bundle pattern. >5000 chars: stronger nag. |
| `token-telemetry` | After every tool call | Logs a TSV line to `docs/agent-runs.log`: timestamp, session, tool, approx in/out tokens, cwd. Pure measurement, no Claude-visible output. |
| `auto-compact-suggest` | After every tool call | Sums session tokens from telemetry log. Suggests `/compact <focus>` at 75k tokens (soft) and 150k tokens (hard). Fires at most once per threshold per session. |
| `dedup-tracker` | After Read/Grep/Glob | Records a hash of the tool_input to `~/.claude/dedup-cache/<session>.log`. Cache trimmed to last 100 calls. |
| `dedup-advisor` | Before Read/Grep/Glob | Hashes the incoming tool_input and checks the dedup cache. If matched within last 50 calls, warns Claude that the same call was already made — proceed only if the file/state likely changed. |

## The /compress slash command

`/compress` wraps `/compact` with a structured focus template. Closer to OpenCode-DCP's range-mode compress than blind `/compact`. Tells the model exactly what to keep (load-bearing decisions, current spec/plan) and what to drop (large tool outputs, completed exploration paths).

Usage example:

```
/compress
```

Then the command tells Claude to construct a focus argument like:

```
/compact focus on G3 architecture decisions and the task list; drop G1 design exploration and large grep dumps
```

## Reading the telemetry

```bash
# Top tools by output token count for a session:
sort -k4 -n -r docs/agent-runs.log | head -20

# Total tokens for today:
awk -F'\t' -v today=$(date -u +%Y-%m-%d) '$1 ~ today {input+=$4; output+=$5} END {print "in:", input, "out:", output}' docs/agent-runs.log

# Heaviest single tool calls:
sort -k5 -n -r docs/agent-runs.log | head -10
```

After a long session, look at the heaviest entries. If most tokens are in Bash with raw `cat`/`ls`, you have a discipline gap. If most are in subagent spawns, your bundles are bloated.

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "I'll just `cat` the file to see it" | Big files dump big tokens. Use `grep` / `head` / `sed -n 'X,Yp'`. |
| "I'll paste this whole error log so the agent has context" | The agent doesn't need 1000 lines. Quote the error message + file path. |
| "The bundle is fine, I'll add one more doc reference" | Each "one more" doubles. Reference by path, not by paste. |
| "I'll run `/compact` after every turn to be safe" | Cache miss compounds. Compact at phase boundaries only. |
| "Opus for everything, just to be safe" | Wastes tokens at scale. Match model to task. |
| "I'll measure tokens later" | Later doesn't come. Look at `docs/agent-runs.log` after each long session. |

## Common rationalizations to push back on

- *"This Bash output is huge, but I need all of it."* — You almost certainly don't. Identify what you're looking for, then `grep` for it.
- *"The subagent should have all the context I have."* — They get fresh context. They don't pay for yours. Send the *delta*.
- *"Telemetry is overkill for solo work."* — It takes one `awk` line to read. The discipline you can't measure is the discipline you don't have.

## What this skill does NOT promise

- **No magic 65% savings.** Real savings are: ~70-85% from light vs full mode, ~2-3× from right model picks, ~20-30% from tight bundles, ~10-15% from output discipline, ~10-20% from auto-compact-suggest + dedup-advisor. Compose with discipline; without discipline, the hooks just ping you.
- **No payload-level compression.** Claude Code's plugin API can't modify what gets sent to the LLM. Hooks can warn and inject system messages — they cannot rewrite tool result streams or drop ranges from the conversation history. For OpenCode-DCP's range/message compression at the API layer, you'd need OpenCode + DCP itself; this plugin's `dedup-advisor` and `auto-compact-suggest` are the closest approximations Claude Code allows.
- **No Windows-native hook execution** in this version. Hooks are bash-only. Windows users need WSL or Git Bash.

## DCP gap analysis

| OpenCode-DCP capability | This plugin | Why the gap |
|---|---|---|
| `compress` tool the model invokes when work closes | `/compress` slash command (user-invoked) | Claude Code can't expose custom tools to the model via plugin |
| Range-mode payload compression with placeholders | `/compress` → wraps `/compact` (broad, lossy) | Claude Code hooks can't modify the API request |
| Message-mode surgical compression | None | Same reason — no payload modification surface |
| Automatic dedup of identical tool calls in payload | `dedup-advisor` warns BEFORE re-run | Hooks fire around tool calls, not on the API payload |
| Error-input purge after N turns | None | Same — no payload modification |
| Auto-trigger compress on task-completion signals | `auto-compact-suggest` (token-threshold based) | We can suggest, the model can't auto-run `/compact` as a tool |

The plugin lands ~30-50% of DCP's effect through advisory hooks. The remaining 50-70% requires harness-level support that Claude Code doesn't expose today.

## Verification

- After a session: `wc -l docs/agent-runs.log` shows entries logged.
- A spot-check: `grep -c "Bash" docs/agent-runs.log` should match your rough sense of how many Bash calls you made.
- For any subagent spawn you initiated: prompt was under 2000 chars (or you justified going over).
- For any Bash output >200 lines you produced: you saw the hook reminder and adjusted next call.
