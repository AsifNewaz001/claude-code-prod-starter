# 01 — Claude Code primer

**Read time: 5 minutes.**

This doc orients you to Claude Code's mental model. If you've used Cursor, Aider, GitHub Copilot, or Claude.ai before, your intuitions will mostly transfer — but Claude Code has unique primitives you should know.

## What Claude Code is

A **CLI tool** (and IDE extensions) that runs **Claude** in your terminal as an **agentic coding assistant**. You point it at a directory, it reads files, runs commands, edits code, and ships work.

```bash
# Install (if you haven't)
npm install -g @anthropic-ai/claude-code

# Run in your project
cd ~/my-project
claude
```

It uses Anthropic's API under the hood (you authenticate once). Everything else runs locally.

## What it gives you that other tools don't

1. **Subagents.** Spawn another Claude with its own context window for parallel work or role-separated review. The parent doesn't pay for the child's context.
2. **Plugins.** Install opinionated configurations across your team via `/plugin marketplace add github:...`. This file is part of one such plugin.
3. **Hooks.** Run shell commands on lifecycle events (file edit, tool call, session end). Lint-on-save, test-on-edit, log-everything.
4. **Slash commands.** User-authored prompt templates invoked by typing `/name`.
5. **Skills.** Self-contained instruction chunks Claude loads when relevant.
6. **Worktrees.** Each Claude Code session can run on its own git worktree (isolated branch checkout).

If you're coming from Cursor, the new things to learn are: **subagents, plugins, hooks**. The rest you already do mentally; Claude Code makes them first-class.

## The five primitives (cheat-sheet)

| Primitive | What it is | When to use |
|---|---|---|
| **Agent** | Subprocess with own context | Long adversarial review; role-separated work (CTO vs Lead Eng) |
| **Skill** | Instructions Claude loads on relevance | Behavioral guidelines, technique knowledge |
| **Command** | Slash-trigger prompt template | Repeated workflows you want one-keystroke access to |
| **Hook** | Shell command on lifecycle event | Auto-format, auto-test, security checks |
| **Plugin** | Bundle of all the above, installed via git | Sharing configs across team / projects |

## Where files live

Read precedence (top wins):

1. `.claude/settings.local.json` — your personal project config (gitignored)
2. `.claude/settings.json` — shared project config (committed)
3. `~/.claude/settings.json` — your user-global config
4. Plugin-supplied content (after `/plugin install`)
5. Claude Code built-ins

For project context:

- `CLAUDE.md` — always loaded; behavioral rules
- `AGENTS.md` — loaded by this plugin's 6 personas; workflow + brand
- `PROJECT_CONTEXT.md` — loaded by this plugin's 6 personas; stack specifics
- `HANDOFF.md` — loaded by `/autopilot`; sprint state

## How to think about token cost

Every turn costs:
- The context-window contents (re-billed each turn until cached)
- The new prompt you send (always billed)
- The tool calls and their results (billed once, kept in context)
- Any subagents you spawn (their tokens billed separately)

Two big levers:
- **Prompt cache** (5-min TTL): if you stay active, Anthropic caches your context prefix. Cache hit = ~10% of normal cost. Idle 5+ min = cache miss.
- **Subagent context isolation**: spawn agents for heavy work; their tokens don't bloat the parent.

See `04-context-management.md` for the deep version.

## Three commands to know on day one

| Command | What it does |
|---|---|
| `/help` | List built-in commands |
| `/compact` | Compress prior context into a summary (saves tokens) |
| `/cost` | Show token usage so far |

This plugin adds one more:

| Command | What it does |
|---|---|
| `/autopilot` | Run the 9-gate flow on the next backlog item |

## What to read next

- `02-first-day.md` — install the plugin, copy templates, run your first `/autopilot`
- `claude-code-primer` skill (in this plugin) — same vocabulary in skill form
- `karpathy-guidelines` skill — Claude's coding behavior rules
