---
name: claude-code-primer
description: Primer on Claude Code's vocabulary and mental model — agents vs skills vs commands vs hooks vs plugins, when to use what, where files live, and how this plugin fits in. Triggers when you're new to Claude Code or onboarding a teammate.
license: MIT
---

# Claude Code primer

Claude Code is Anthropic's official CLI for Claude. It's an agentic coding tool — you talk to it, it reads files, runs commands, edits code, and ships work. This primer explains the vocabulary so you stop confusing agents with skills, plugins with commands, and the API with the CLI.

## What Claude Code is NOT

- **Not the Claude API** (formerly "Anthropic API"). The API is for building your own apps. Claude Code is a finished CLI you invoke from your terminal.
- **Not Claude.ai**. Claude.ai is the web chat. Claude Code reads/writes files on your machine.
- **Not Cursor / Windsurf**. Those are IDE forks with embedded LLMs. Claude Code is a CLI; works with any editor.
- **Not OpenCode**. Different tool, different plugin ecosystem.

## The five things you can configure

Claude Code's behavior is shaped by five distinct primitive types. Confusing them is the most common new-user mistake.

### 1. Agents (subagents)

A **subprocess of Claude** with its own context window, tool list, and model. You invoke them via the Agent tool with `subagent_type: "name"`.

- File location: `.claude/agents/<name>.md` (project) or `~/.claude/agents/<name>.md` (global) or shipped in a plugin
- Invoked via: `Agent({ subagent_type: "name", prompt: "..." })` — never directly by the user
- When to use: long-running adversarial review, parallel exploration, role-separated work (CTO reviewing CPO's PRD)
- Cost: each agent has its own context window — the parent doesn't pay for the child's, only for the prompt

This plugin ships 6 agents (cto, cpo, cbo, design, lead-engineer, lead-qa).

### 2. Skills

A **chunk of instructions** that Claude loads when relevant. Triggered by description match, not by you typing the name.

- File location: `.claude/skills/<name>/SKILL.md` (project) or `~/.claude/skills/<name>/SKILL.md` (global) or shipped in a plugin
- Invoked via: Skill tool, but Claude picks it automatically based on the description
- When to use: behavioral guidelines, domain expertise, technique knowledge that's broadly applicable
- Difference from agent: skill = instructions injected into THIS context. Agent = whole new context.

This plugin ships 4 skills (karpathy-guidelines, context-management, model-selection, claude-code-primer — this one).

### 3. Commands (slash commands)

A **prompt template** you invoke by typing `/<name>`. Loads its content as the next user turn.

- File location: `.claude/commands/<name>.md` (project) or `~/.claude/commands/<name>.md` (global) or shipped in a plugin
- Invoked via: typing `/name` (with optional args)
- When to use: repeated workflows you want a one-keystroke trigger for
- Difference from skill: command = YOU type a slash. Skill = Claude detects relevance.

This plugin ships 1 command (`/autopilot`).

### 4. Hooks

A **shell command** that runs on Claude Code lifecycle events (tool call, response, session end, etc.).

- File location: `~/.claude/settings.json` (user-global) or `.claude/settings.local.json` (project, gitignored) under the `hooks` key
- Invoked via: Claude Code runs them automatically on the configured event
- When to use: auto-format on file edit, run tests on save, reject commits with secrets, log telemetry
- Difference from agent/skill/command: hooks are SHELL, not prompts. They run outside the LLM.

This plugin ships zero hooks (too project-specific). Reference them in onboarding docs.

### 5. Plugins

A **bundle** of agents + skills + commands + hooks distributed as a git repo. One install, all the contents become available.

- File location: published as a git repo with `.claude-plugin/plugin.json`
- Invoked via: `/plugin marketplace add github:user/repo` then `/plugin install name`
- When to use: sharing configs across a team or across multiple projects
- This plugin IS one. You're reading content from it.

## The decision matrix

When you want to add a new behavior to Claude Code, pick the type:

```
Is it a SHELL command that should run on a lifecycle event (tool call, save)?
  → Hook

Is it a PROMPT TEMPLATE you want to invoke by typing /name?
  → Slash command

Is it a CHUNK OF INSTRUCTIONS Claude should load when relevant?
  → Skill

Is it a SUBPROCESS with its own context window doing role-separated work?
  → Agent

Is it any of the above, BUT you want to share it across multiple projects/teams?
  → Wrap it in a Plugin.
```

## Where files live (precedence order)

Claude Code reads from multiple locations. Higher in the list wins:

1. `.claude/settings.local.json` — project-local, gitignored, your personal config
2. `.claude/settings.json` — project-shared, committed
3. `~/.claude/settings.json` — your user-global config
4. Plugin-supplied agents/skills/commands — installed via `/plugin install`
5. Built-in agents/skills/commands shipped with Claude Code itself

For project files:
- `CLAUDE.md` (root) — always loaded into context (this plugin ships a template)
- `AGENTS.md` (root) — loaded by the 6 personas (this plugin ships a template)
- `PROJECT_CONTEXT.md` (root) — loaded by all 6 personas (this plugin ships a template)

## How this plugin fits in

Once you `/plugin install claude-code-prod-starter`:

- **Available globally as agents:** cto-agent, cpo-agent, cbo-agent, design-agent, lead-engineer-agent, lead-qa-agent
- **Available globally as a slash command:** `/autopilot`
- **Available globally as skills:** karpathy-guidelines, context-management, model-selection, claude-code-primer

Then in each project where you want to USE the plugin's workflow, you copy the templates:

```bash
PLUGIN=~/.claude/plugins/claude-code-prod-starter
cp $PLUGIN/templates/CLAUDE.md ./
cp $PLUGIN/templates/AGENTS.md ./
cp $PLUGIN/templates/PROJECT_CONTEXT.md ./
cp $PLUGIN/templates/HANDOFF.md ./
mkdir -p docs
cp $PLUGIN/templates/docs/governance-plan.md ./docs/
cp $PLUGIN/templates/docs/agent-budgets.md ./docs/
```

Then fill in `PROJECT_CONTEXT.md` with your stack specifics. The agents will read it on every spawn.

## Common mistakes

- **"I want to add a behavior rule, where do I put it?"** → If it should fire on every turn, CLAUDE.md. If it should fire when relevant, a skill. If it should fire on a specific user gesture, a command. If it should fire on a Claude Code event, a hook.
- **"Why can't I just type `cto-agent` and have it run?"** → Agents are spawned, not typed. The orchestrator (`/autopilot`, or you manually) calls the Agent tool.
- **"Why isn't my skill triggering?"** → Skills trigger on description match. If your description is vague, Claude won't find it. Check the description's first sentence — that's what gets matched.
- **"What's the difference between `/compact` and a skill that says 'compact context'?"** → `/compact` is a built-in slash command in Claude Code that actually mutates context. A skill can only suggest behavior; it can't run privileged commands itself.
- **"Why does my plugin work but Claude doesn't see the agents?"** → Restart Claude Code after `/plugin install`. The agent registry loads on session start.

## Recommended reading order for new engineers

After installing the plugin and copying templates:

1. This skill (you're here).
2. `karpathy-guidelines` skill — Claude's coding behavior.
3. `model-selection` skill — when to use Opus vs Sonnet vs Haiku.
4. `context-management` skill — how to not blow your token budget.
5. The plugin's onboarding docs in `docs/onboarding/` — first day, pitfalls, the 9-gate flow.
6. Your project's `PROJECT_CONTEXT.md` (you fill in) and `AGENTS.md` (workflow + brand).

## Vocabulary cheat-sheet

| Term | What it is | Where it lives | How invoked |
|---|---|---|---|
| Agent (subagent) | Subprocess with own context | `agents/<name>.md` | `Agent({subagent_type: "name", ...})` |
| Skill | Instructions chunk | `skills/<name>/SKILL.md` | Auto-triggered by Claude on relevance |
| Slash command | Prompt template | `commands/<name>.md` | User types `/name` |
| Hook | Shell command | `settings.json` `hooks:` | Lifecycle event |
| Plugin | Bundle of all the above | Git repo with `plugin.json` | `/plugin install` |
| MCP server | External tool provider | `settings.json` `mcpServers:` | Tools become available globally |
| Worktree | Isolated git checkout | `.git/worktrees/` | `git worktree add` |

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "Just call Claude Code 'the API'" | Different products. Claude Code = CLI. API = developer SDK. They behave differently. |
| "I'll add this rule to CLAUDE.md, AGENTS.md, AND the skill" | Pick one. Duplicating rules guarantees they diverge over time. |
| "I'll put this project-specific config in a skill" | Skills are project-agnostic. Project-specific stuff goes in CLAUDE.md / AGENTS.md / PROJECT_CONTEXT.md. |
| "I'll write a hook that calls the LLM" | Hooks are SHELL, not prompts. If you want LLM logic, write a slash command or skill. |
| "The agent didn't trigger, the system is broken" | First check the description's first sentence — that's what gets matched. Vague description = no trigger. |
| "I'll just type the agent name in the prompt" | Agents are spawned, not typed. They run via the Agent tool. Slash commands are what you type. |

## Common rationalizations to push back on

- *"I don't need to know the difference between skills and agents — they both add behavior."* — They cost differently. Agents have their own context window; skills inject into yours. Picking wrong wastes tokens.
- *"I'll figure out where to put this rule by trying things."* — The decision matrix above tells you. Use it. The wrong location means the rule fires at the wrong time (or never).
- *"My plugin's agents aren't loading, I'll re-run the install."* — First restart Claude Code. Agent registry loads on session start, not on install.
- *"This vocabulary is just trivia."* — It's the difference between debugging a hook problem in 2 minutes (you know it's shell) vs 2 hours (you thought it was an LLM call).

## When this skill applies

- A teammate asks "what's the difference between X and Y?" where X/Y are Claude Code primitives.
- You're about to add a behavior to Claude Code and aren't sure which primitive to use.
- Something isn't working and you suspect the wrong primitive was chosen.
- You're onboarding to Claude Code and the docs assume you already know the vocabulary.

## Verification

- You can name where any primitive lives, how it's invoked, and when to use it — without re-reading the docs.
- When picking where to add a new behavior, you state which primitive and why in one sentence.
- You can spot the wrong primitive in code review — e.g. "this should be a skill, not a hook" — with a one-sentence justification.
