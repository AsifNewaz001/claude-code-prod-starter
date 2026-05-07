---
name: worktree-workflow
description: Use git worktrees to isolate parallel work, long-running feature branches, and agent-driven changes. Use when you're about to start a multi-commit feature, when running multiple Claude sessions on the same repo, when running /autopilot autonomously, or when an experiment might need to be thrown away cleanly.
license: MIT
---

# Worktree Workflow

## Overview

A git worktree is a second working directory backed by the same repo. Different branch checked out, fully separate files, shared `.git`. You can run multiple Claude Code sessions in parallel without them stepping on each other's changes.

For agent-driven work — especially anything autonomous — worktrees are the difference between "the agent broke my main branch" and "the agent's branch is right there if I want to merge it."

## When to use

- Multi-commit feature work that's not ready for `main`
- Running `/autopilot` or another long-running orchestrator
- Running multiple Claude sessions in parallel on the same repo
- Risky experiments where the cheap option is to delete the worktree
- Any time you don't want uncommitted state on `main`

## When NOT to use

- One-line fixes on a tracked branch
- Trivial doc / config edits
- When you don't have admin rights to create new directories near the repo

## The workflow

### 1. Create the worktree

```bash
# From the main repo:
git worktree add -b feat/<feature-name> ../<repo>-<feature-name>
cd ../<repo>-<feature-name>
```

This creates a new branch `feat/<feature-name>` checked out in a sibling directory. The original repo is untouched.

### 2. Work the worktree like a normal repo

- Run your editor, run `claude`, run tests — everything works.
- Commits land on the worktree's branch.
- Push to remote with `git push -u origin feat/<feature-name>`.

### 3. Merge or discard

When the work is good:

```bash
# From the main repo:
cd ../<repo>
git checkout main
git merge feat/<feature-name>
# or open a PR if the project uses GitHub flow
```

When the work is bad — throw it away with no regret:

```bash
# From anywhere:
git worktree remove ../<repo>-<feature-name>
git branch -D feat/<feature-name>
```

The original repo is unchanged. The experiment never touched `main`.

### 4. Clean up worktrees you've finished with

```bash
git worktree list                  # see all worktrees
git worktree remove <path>         # remove an unused worktree
git worktree prune                 # clean up worktree refs to deleted directories
```

## Naming conventions

- **Worktree directory:** `<repo>-<feature-or-task>` next to the main repo, NOT inside it.
- **Branch:** `feat/<feature>`, `fix/<bug>`, `chore/<task>`, or whatever the project uses (`PROJECT_CONTEXT.md`).

Avoid worktree directories *inside* the main repo — git will get confused.

## Multi-session pattern

Open one Claude Code session per worktree. Each session has its own current directory and its own branch. They share git history but nothing else.

Use this when you want one agent on a feature, another on a bug fix, and a third running `/autopilot` on a backlog item — all at once.

## The `/autopilot` + worktree pairing

When running `/autopilot` autonomously (especially scheduled or unattended):

1. Always launch from a worktree, not `main`.
2. Set the worktree branch to `auto/<date>-<topic>`.
3. If the run goes badly, delete the worktree. No cleanup of `main` needed.

This is what makes long autonomous runs safe.

## Red flags

| Thought | Reality |
|---|---|
| "I'll just stash my changes and switch branches" | Stashing across long sessions is a footgun. Use a worktree. |
| "Worktrees are too much setup" | Two commands. Use them. |
| "I'll work on main, just be careful" | "Be careful" is how `main` gets dirty commits. |
| "I don't need to clean up worktrees" | Old worktrees confuse `git status` and `git worktree list`. Prune them. |

## Common rationalizations

- *"Branches and worktrees are the same."* — Branches are pointers; worktrees are working directories. You can have many branches without many worktrees, but you need a worktree per parallel working directory.
- *"I'll just delete the directory."* — `rm -rf` on a worktree leaves git refs pointing at nothing. Use `git worktree remove`.

## Verification

- The worktree exists at the expected path: `git worktree list` shows it.
- The worktree's branch is the one you intended.
- Changes in the worktree don't appear in the main repo's working directory.
- After deletion: `git worktree list` no longer shows it; `git branch` no longer lists the branch (if you `-D`'d it).
