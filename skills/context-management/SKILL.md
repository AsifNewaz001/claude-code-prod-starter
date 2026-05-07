---
name: context-management
description: Use when context is filling up or when about to spawn subagents. Teaches when/how to /compact, why subagent budgets matter, how to write tight context bundles, and the prompt-cache TTL tradeoff. Critical for engineers running long /autopilot sessions or deep agentic work.
license: MIT
---

# Context management

Claude Code has a finite context window. Token math is real. Bad context discipline means slow, expensive, error-prone work. Good context discipline means you can run a 9-gate sprint end-to-end without a single auto-compaction.

## When this matters

- You're 5+ turns into a deep task.
- You just finished a debugging loop that produced lots of tool output.
- You're about to spawn a subagent (CTO, Lead Eng, etc.) — every byte you pass costs them context budget too.
- You're seeing "context is X% full" warnings.
- You're scheduling recurring work (`/loop`, `/schedule`, `ScheduleWakeup`).

## Three layers of context discipline

### Layer 1 — Auto-compaction (Claude Code does this for you)

Claude Code automatically compresses prior messages when the context approaches the limit. You don't have to do anything. But:

- Auto-compaction is reactive (kicks in late) and lossy (summarizes broadly).
- The summary loses fine-grained tool output, which can matter for debugging.
- You can do better by compacting *deliberately* when you finish a phase.

### Layer 2 — Manual `/compact` (you trigger it deliberately)

When to run `/compact`:

- **After a debugging loop closes.** The 50 tool calls that found the bug aren't load-bearing for the fix; compact them.
- **At a phase boundary.** Finished gathering requirements and about to switch to implementation? Compact the gathering phase.
- **Before a long subagent spawn.** If your context is 60%+ full and you're about to spawn a subagent that will take 100k tokens, compact first to give the parent breathing room.

How to run it: type `/compact` in the prompt. Optionally pass a focus: `/compact focus on the schema decision, drop the test output`.

After `/compact`, the prompt cache is invalidated for the compressed prefix. You pay a cache miss on the next turn but save tokens going forward.

### Layer 3 — Tight context bundles for subagents (the highest-leverage discipline)

Subagents have their own context window. The parent does NOT pay for the child's context. But the parent DOES pay for the prompt it sends to spawn the child. Two failure modes:

- **Bloated spawn prompts**: "Read AGENTS.md, governance plan, all decision records, RFC, design system, ..." — re-fetches 5–15k tokens per gate.
- **Vague spawn prompts**: child agent spends 40% of its budget figuring out what it's supposed to do.

The fix: build a **context bundle**, three parts:

1. **Static refs** (link by absolute path; child reads on demand, doesn't re-pay):
   ```
   Read these on demand:
   - PROJECT_CONTEXT.md
   - docs/agent-budgets.md (your gate budget: 60k tokens)
   - docs/decision-log/DR-YYYY-MM-DD-<feature>-g3-cto.md (your G3 task list)
   ```

2. **Dynamic context** (paste verbatim; the only delta the child needs):
   ```
   Build SHA: 4da2e37
   Files changed: <git diff --stat output, 5-10 lines>
   Conditions from prior gate: <numbered list>
   ```

3. **Budget reminder + verdict-block format** (so the child self-monitors):
   ```
   Your G6 budget: 60k tokens. Self-monitor; surface if blowing past.
   End your reply with the verdict block: <verdict>...</verdict>
   ```

A spawn prompt under 2000 tokens that sets up the child correctly beats a 10k-token "read everything" dump every time.

## Concepts ported from Opencode DCP (Dynamic Context Pruning)

The OpenCode DCP plugin doesn't run in Claude Code, but its concepts are universal:

| DCP concept | Apply in Claude Code |
|---|---|
| Compress closed conversation spans | Run `/compact` at phase boundaries |
| Deduplicate repeated tool calls | Notice when you're grep'ing for the same thing twice — read once, remember |
| Purge errored tool inputs after N turns | Mention errors briefly, don't re-paste large failed-input dumps |
| Protected tools (write/edit/todo never pruned) | Claude Code does this for you |
| Range vs message compression mode | `/compact` ≈ range mode; targeted edits in your replies ≈ message mode |

## The 5-minute prompt-cache TTL

Anthropic's prompt cache is keyed on exact prefix match and lives **5 minutes**. After 5 minutes idle, the next turn pays the full prefix cost (cache miss).

Implications:

- **Don't sleep more than 5 minutes** between Claude Code turns if you can avoid it.
- **For `ScheduleWakeup` / `/loop` recurring runs**: pick delays under 270s (cache stays warm) OR over 1200s (one cache miss buys a long wait). 300-1200s is the worst zone.
- **Subagent spawns inherit the cache only via prompt content**, not tool history. A subagent at minute 4 of the parent session pays for its own prompt prefix on first turn.

## Cache vs prune tradeoff

OpenCode DCP measured ~85% cache hit rate with active pruning vs ~90% without. The 5% cache loss buys significant token savings.

In Claude Code:

- For **short sessions** (<10 minutes), don't proactively `/compact` — let the cache work.
- For **long sessions** (30+ minutes), proactive `/compact` at phase boundaries pays off — fresh context is cheaper than stale cache hits on bloated context.
- For **recurring workflows** (`/autopilot`), the per-gate context-bundle pattern is itself a form of dynamic pruning — only the dynamic delta gets passed to the next gate.

## Quick checklist

When context feels heavy:

- [ ] Did I just finish a phase? → `/compact`
- [ ] Am I about to spawn a subagent? → write a tight bundle (static refs + dynamic delta + budget)
- [ ] Have I been here >5 minutes? → assume cache is cold; structure the next turn to rewarm
- [ ] Am I re-running the same grep? → stop; the answer is already in this session

## Anti-patterns

- Pasting 500 lines of error log into a turn. Quote the error message, link the file path, that's enough.
- Telling a subagent "read AGENTS.md and figure out what to do." They will read 5k tokens of context they don't need.
- Calling `/compact` after every turn out of paranoia. The cache miss compounds.
- Running `/loop 5m` and assuming each iteration is cached. 5 minutes = cache TTL boundary; expect cache miss every iteration.

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "I'll paste the whole file so the agent has context" | Pasting 5k tokens to save 30 seconds of read-on-demand is a bad trade. Link the path. |
| "I'll re-read this file just to be safe" | If you read it 3 turns ago and it didn't change, the answer is in this session. Stop. |
| "Compacting feels risky, I'll just keep going" | Auto-compaction will fire eventually, lossily. Compact deliberately at phase boundaries. |
| "The subagent should have all the context I have" | They get fresh context. They don't pay for yours. Send only the delta. |
| "I'll set `/loop` to 5 minutes — round number" | 300s is the worst delay. Either ≤270s (cache warm) or ≥1200s (one cache miss buys a long wait). |
| "The agent's prompt is fine, it's only 8k tokens" | 8k × N gates = N × 8k. Tight bundles compound. |

## Common rationalizations to push back on

- *"I'll figure out what the agent needs by trial and error."* — Trial and error costs tokens you can't get back. Spend 30 seconds writing a tight bundle instead.
- *"The cache probably hit, no need to optimize."* — Cache hits are visible in token counts. Check before assuming.
- *"`/compact` will lose important details."* — Auto-compaction loses MORE. Manual compact at phase boundaries with a focus argument is sharper.
- *"The session is already long, can't fix it now."* — Yes you can. Compact at the next phase boundary; subsequent turns get cheap again.

## Verification

- After running `/compact`: the next turn's input token count is materially lower than before.
- Subagent spawn prompts are under 2k tokens for routine gates, under 5k for complex ones.
- No `/loop` interval falls in the 300–1200s "worst zone" — it's either ≤270s or ≥1200s.
- When you finish a phase, you can name what you compacted and why — not just "everything before this turn."
