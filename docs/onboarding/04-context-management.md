# 04 — Context management

**Read time: 8 minutes.**

Claude Code has a finite context window. Token math is real. Bad context discipline = slow, expensive, error-prone work. Good context discipline = a 9-gate sprint runs end-to-end without a single auto-compaction.

## Why this matters more than people think

Engineers used to short Claude.ai chats often don't realize:

- Long Claude Code sessions can blow through 200k+ tokens.
- The prompt cache has a 5-minute TTL — sleep too long, pay full price.
- Subagents have their own context windows; sloppy spawn prompts blow the parent's budget AND the child's.
- Auto-compaction is reactive and lossy; manual compaction is cheaper and cleaner.

This doc gives you the playbook so you can run long deep work without surprise.

## Three layers of context discipline

### Layer 1 — Auto-compaction (Claude Code does this for you)

When context approaches the limit, Claude Code automatically summarizes prior messages. You don't need to do anything for this. But:

- It kicks in late (when context is ~85% full).
- It summarizes broadly — fine-grained tool output is lost.
- The cache invalidates.

Better: trigger compaction yourself, deliberately, at phase boundaries.

### Layer 2 — Manual `/compact` (you trigger it)

When to run `/compact`:

- **After a debugging loop closes.** The 50 tool calls that found the bug are dead weight for the fix; compact them.
- **At a phase boundary.** Finished requirements, switching to implementation? Compact requirements.
- **Before a long subagent spawn.** Context 60%+ full and about to spawn a 100k-token subagent? Compact first.

How:

```
/compact
```

Or with focus:

```
/compact focus on the schema decision; drop the test-iteration noise
```

After `/compact`, the cache is invalidated for the compressed prefix. You pay one cache miss; subsequent turns are cheaper.

### Layer 3 — Tight context bundles for subagents (highest leverage)

Subagents have their own context window. The parent does NOT pay for the child's context. But the parent DOES pay for the prompt it sends to spawn the child.

Two failure modes:

- **Bloated spawn prompts**: "Read AGENTS.md, governance plan, all decision records, RFC, design system, ..." — re-fetches 5–15k tokens per gate.
- **Vague spawn prompts**: child agent burns 40% of its budget figuring out the task.

The fix: build a context bundle, three parts:

**1. Static refs** (link by absolute path; child reads on demand):

```
Read these on demand:
- PROJECT_CONTEXT.md
- docs/agent-budgets.md (your gate budget: 60k tokens)
- docs/decision-log/DR-YYYY-MM-DD-<feature>-g3-cto.md (your G3 task list)
```

**2. Dynamic context** (paste verbatim; only the delta the child needs):

```
Build SHA: 4da2e37
Files changed: <git diff --stat output, 5-10 lines>
Conditions from prior gate (paste from verdict block): <numbered list>
```

**3. Budget reminder + verdict format**:

```
Your G6 budget: 60k tokens. Self-monitor; surface if blowing past.
End your reply with: <verdict>...</verdict><sev>...</sev>
```

A spawn prompt under 2000 tokens that sets up the child correctly beats a 10k-token "read everything" dump every time.

## The 5-minute prompt cache TTL

Anthropic's prompt cache is keyed on exact prefix match and lives **5 minutes**. After 5 minutes idle, the next turn pays the full prefix cost (cache miss).

What this means:

- **Stay active**: don't pause for 5+ minutes between turns if you can avoid it.
- **For `ScheduleWakeup` / `/loop`**: pick delays under 270s (cache stays warm) OR over 1200s (one cache miss buys a long wait). 300-1200s is the worst zone.
- **Subagents inherit cache only via prompt content**, not tool history. A subagent at minute 4 of the parent session pays for its own prompt prefix on first turn.
- **If you're going to stop for lunch**, the cache is dead by the time you're back. Your next turn pays full prefix.

## Cache vs prune tradeoff

OpenCode DCP measured ~85% cache hit with active pruning vs ~90% without. The 5% cache loss buys significant token savings.

In Claude Code:

- **Short sessions** (<10 minutes): don't proactively `/compact` — let the cache work.
- **Long sessions** (30+ minutes): proactive `/compact` at phase boundaries pays off.
- **Recurring workflows** (`/autopilot`): the per-gate context-bundle pattern IS dynamic pruning — only the delta passes to the next gate.

## Quick checklist

When context feels heavy:

- [ ] Did I just finish a phase? → `/compact`
- [ ] Am I about to spawn a subagent? → write a tight bundle
- [ ] Have I been idle >5 minutes? → assume cache is cold
- [ ] Am I re-running the same grep? → stop; the answer is already in this session
- [ ] Is the verify command output in context multiple times? → `/compact` to deduplicate

## Anti-patterns

- **Pasting 500 lines of error log into a turn.** Quote the error message, link the file path. That's enough.
- **Telling a subagent "read AGENTS.md and figure it out."** They burn 5k tokens on context they don't need.
- **Calling `/compact` after every turn out of paranoia.** Cache miss compounds.
- **Running `/loop 5m` and assuming each iteration is cached.** 5 minutes = cache TTL boundary; expect a cache miss every iteration.
- **Spawning a subagent with the parent's full context.** They don't need it; pass only the delta.

## Concepts ported from OpenCode DCP

OpenCode's Dynamic Context Pruning plugin (different tool, different SDK — can't run in Claude Code) implements automated context management. The concepts apply universally:

| DCP concept | Apply in Claude Code |
|---|---|
| Compress closed conversation spans | Run `/compact` at phase boundaries |
| Deduplicate repeated tool calls | Notice when you grep the same thing twice; remember |
| Purge errored tool inputs after N turns | Mention errors briefly, don't re-paste |
| Protected tools (write/edit/todo never pruned) | Claude Code does this for you in auto-compaction |
| Range vs message compression mode | `/compact` ≈ range; targeted edits ≈ message |

## When you blow the budget anyway

If `/autopilot` runs out of context mid-gate:

1. The orchestrator commits a `WIP: G<N> <feature>` marker.
2. Updates `HANDOFF.md` with where it stopped.
3. Next `/autopilot` run reads the WIP marker and resumes — does NOT restart the gate.

This is the resume protocol. If you see WIP markers piling up, your context bundles are too bloated. Tighten them.

## Reading next

- `05-pitfalls.md` — common mistakes that compound context bloat
- `context-management` skill (in this plugin) — same content in skill form
- `commands/autopilot.md` — see the context-bundle pattern in production
