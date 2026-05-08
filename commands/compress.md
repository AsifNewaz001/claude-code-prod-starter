---
description: Surgical context compression. Wraps /compact with a structured focus template — names what just ended, what's load-bearing for the next phase, and what large outputs to drop. Closer to OpenCode-DCP's range-mode compress than blind /compact.
---

You are about to compress your context surgically. Don't run blind `/compact`. Run `/compact` with a focus argument that tells the model exactly what to keep and what to drop.

## Required reading

- The `context-management` skill — `/compact` mechanics, cache TTL
- The `token-discipline` skill — when to compress vs not
- Recent activity in this session — what phase just ended, what's queued next

## The structured focus pattern

Before compacting, identify three things:

1. **What just ended** — a phase, a debugging loop, a gate completion, a requirements gathering session
2. **What's load-bearing** — decisions that affect future turns, files you'll keep editing, the spec/plan you're working from
3. **What's safe to drop** — large tool outputs (full `git diff`, full `npm test`, large `cat`/`grep` dumps), failed exploration paths, redundant explanations

Then construct the focus argument:

```
/compact focus on <load-bearing items>; drop <safe-to-drop items>
```

## Examples

### After a debugging loop

```
/compact focus on the bug repro and the fix in src/auth/session.ts; drop the 50 grep dumps and stack traces
```

### After requirements gathering

```
/compact focus on the spec at docs/specs/2026-05-08-search-bar.md; drop the brainstorm tangents and competitor screenshots
```

### After a 9-gate sprint phase

```
/compact focus on G3 architecture decisions and the task list; drop G1 design exploration and G2 PRD draft iterations
```

### After a refactor

```
/compact focus on the current diff and the test results; drop the original code I read at the start
```

## When to use this instead of plain /compact

Use `/compress` when:
- You have multiple phases of work and want to keep one but drop others
- You've accumulated large tool dumps that aren't load-bearing
- You're approaching a context cliff and need to be surgical
- You want to tell the model what to keep, not just summarize broadly

Use plain `/compact` when:
- The whole session is uniformly stale
- You don't know what to keep
- You want Claude Code's default behavior

## When NOT to compress

- Mid-task. Finish the current step first. Compacting mid-flow loses working memory.
- After every turn. The cache miss compounds. Compress at phase boundaries.
- Within 5 minutes of a previous compress. The cache hasn't fully amortized.
- When the session is short. Compress costs a cache miss; payoff requires future turns.

## What this command does NOT do

- It does NOT modify the API request payload (Claude Code's plugin API can't do that — see DCP if you need that).
- It does NOT automatically dedupe tool calls in history (the `dedup-advisor` hook warns BEFORE re-running, but it can't strip prior duplicates).
- It does NOT replace the session transcript on disk. `/compact` only affects what the model sees on the next turn.

## Process

1. Survey the session: name the phase that just ended.
2. Survey forward: name what you'll do next.
3. Identify the three things (load-bearing, drop-safe, end-of-phase).
4. Construct the focus argument.
5. Run `/compact <focus>`.
6. The next turn pays a cache miss. Subsequent turns are cheaper.

## Verification

- The next API turn's input token count is materially lower than the previous turn.
- You can still answer "what was the spec?" or "what gate are we in?" — load-bearing context survived.
- You cannot answer "what was the exact stdout of `npm test` 30 turns ago?" — and that's correct; it shouldn't be load-bearing.
