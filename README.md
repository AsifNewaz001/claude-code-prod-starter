# claude-code-prod-starter

> **Type your idea. Get a shipped PR.**

The Claude Code plugin that orchestrates 9 agents, 14 skills, and 11 commands automatically — so you don't have to know any of them.

```
$ claude
> /go add a dark mode toggle to my settings page

✓ Bootstrapped PROJECT_CONTEXT.md (Next.js + pnpm)
✓ Intent: FEATURE. Blast radius: low. Mode: light.
✓ Spec: docs/specs/2026-05-08-dark-mode.md (12 ACs) — approve? y
✓ Plan: 4 tasks, 6 files — approve? y
✓ Build task 1/4: ThemeContext + tests
✓ Build task 2/4: Toggle component + tests
✓ Build task 3/4: persistLocalStorage + tests
✓ Build task 4/4: integrate into Settings page + tests
✓ Verify: green (12 new tests, 0 regressions)
✓ Review: APPROVED-WITH-NITS
✓ Open PR? y

✓ Dark mode shipped.
  PR: https://github.com/.../pull/47
  Diff: 6 files, +183 / -8
  Tokens: 47k (vs ~230k naive)
  Time: 8 minutes
```

One sentence in. PR out.

---

## Install (one command)

```bash
git clone https://github.com/AsifNewaz001/claude-code-prod-starter.git ~/.claude/plugins/claude-code-prod-starter
```

Restart Claude Code. Done.

That's it. No `npm install`, no marketplace dance, no SSH config drama.

Optional: add aliases to your shell:

```bash
# ~/.zshrc
alias install-prod-starter='git clone https://github.com/AsifNewaz001/claude-code-prod-starter.git ~/.claude/plugins/claude-code-prod-starter && echo "✓ Restart Claude Code now."'
alias update-prod-starter='cd ~/.claude/plugins/claude-code-prod-starter && git pull && cd - && echo "✓ Restart Claude Code now."'
```

---

## What you get

- **`/go <one sentence>`** — the auto-orchestrator. Runs the full SDLC end-to-end, spawns specialist agents at the right moments, pauses only at meaningful checkpoints (spec, plan, ship). Your default command.
- **9 agents** — 6 PM-style personas (design, cpo, cto, cbo, lead-engineer, lead-qa) for governance + 3 reusable specialists (code-reviewer, security-auditor, test-engineer) for ad-hoc use.
- **14 skills** — TDD, debugging, verification, code review, code simplification, token discipline, context management, model selection, Karpathy guidelines, auto-context, writing skills, worktree workflow, primer + dispatcher.
- **11 commands** — `/go`, `/diagnose`, `/spec`, `/plan`, `/build`, `/test`, `/review`, `/code-simplify`, `/compress`, `/ship`, `/autopilot`.
- **7 hooks** — auto-load dispatcher, output discipline, subagent discipline, telemetry, auto-compact suggest, dedup tracker, dedup advisor.
- **Templates + 5-doc onboarding path** — copy once per project for full mode (`/autopilot`); not needed for light mode.

---

## Why this exists

Claude Code is powerful. But the user has to know:

- Which slash command to type (`/spec`? `/plan`? `/autopilot`?)
- Which agent to spawn (and when)
- Which skill applies to which task
- How to write tight subagent context bundles
- When to `/compact`
- Which model to pick

That's a learning curve. Most users never climb it. They use Claude Code at 20% of its capability and quietly switch to Cursor or stay on ChatGPT.

**This plugin removes the learning curve.** The user types one sentence. The plugin does the rest. Claude Code becomes the most powerful coding tool you've used — without you having to learn anything.

---

## How it compares

What this plugin gives Claude Code that other AI coding tools don't ship with:

| | Claude Code + this plugin | GitHub Copilot / Codex | Cursor | Gemini CLI | Aider |
|---|---|---|---|---|---|
| One sentence → full PR | ✅ `/go` | ❌ autocomplete | ⚠️ with prompting | ⚠️ | ⚠️ |
| Auto-orchestrates spec → plan → build → test → review | ✅ | ❌ | ❌ | ❌ | ❌ |
| Reusable persona agents for governance | ✅ 6 personas | ❌ | ❌ | ❌ | ❌ |
| Reusable specialist agents (code review, security, tests) | ✅ 3 specialists | ⚠️ Copilot review | ❌ | ❌ | ❌ |
| TDD enforced via skills | ✅ | ❌ | ❌ | ❌ | ⚠️ |
| Five-axis code review built-in | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| Token-discipline hooks (output / subagent / dedup / auto-compact) | ✅ 6 hooks | ❌ | ❌ | ❌ | ❌ |
| Auto-bootstraps project context from manifests | ✅ `auto-context` | ❌ | ❌ | ❌ | ❌ |
| Free | ✅ | ⚠️ paid | ⚠️ paid | ✅ | ✅ |
| Works with any editor | ✅ Claude Code is a CLI | ⚠️ IDE-locked | ❌ Cursor only | ✅ | ✅ |
| Open source plugin | ✅ MIT | ❌ | ❌ | ❌ | ✅ |

---

## The 30-second tour

### `/go` — the default

```
> /go fix the bug where the cart doesn't update after I remove an item
```

The plugin:
1. Detects intent: DEBUG
2. Detects blast radius: low (no auth/payment/migration touched)
3. Picks mode: light
4. Runs `systematic-debugging` skill — reproduces the bug, isolates the cause
5. Writes a regression test FIRST (Prove-It pattern)
6. Writes the fix
7. Runs verify command (your project's test suite)
8. Spawns `code-reviewer` agent for five-axis review
9. Pauses, asks: "Open PR?"

### `/diagnose` — see what's active

```
> /diagnose
```

Shows: plugin version, active hooks, available agents/skills/commands, current project state, recent token telemetry, and (if you pass a request) what `/go` would do for it. Read-only. Useful when you're confused.

### `/autopilot` — full 9-gate governance

```
> /autopilot
```

For high-blast-radius work (auth flows, payment paths, multi-tenant, regulated data). Spawns the 6 PM-style persona agents through 9 gates, each producing a Decision Record. Self-review forbidden. ~600-900k tokens, ~$4-6 per sprint.

`/go` will route to `/autopilot` automatically when it detects high blast radius. You can also invoke it directly.

### Token discipline — built-in

The plugin's hooks fire automatically:

- Bash output >200 lines? → reminder with targeted-command suggestions
- Agent spawn prompt >2000 chars? → tight-bundle pattern injected
- Read/Grep/Glob the same thing twice? → dedup warning
- Session passes 75k tokens? → suggests `/compact <focus>`

Plus `/compress` for surgical compaction with a structured focus template.

After a long session:

```bash
sort -k5 -n -r docs/agent-runs.log | head -10  # heaviest tool calls
```

That tells you where your tokens went. Measurement is the prerequisite for tuning.

---

## Two modes — pick what fits

### Light mode (default for `/go`)

No templates. No `PROJECT_CONTEXT.md` config. Just install and type `/go`.

```
/go → /spec → /plan → /build → /test → /review → /ship
```

`/go` runs this for you, pausing only at spec/plan/ship approvals. Three keystrokes. One PR.

### Full mode (`/autopilot`)

For high-stakes work. Six persona agents through 9 gates. Decision records, verdict blocks, self-review forbidden. `/go` routes here automatically when it detects auth/payments/migrations/multi-tenant changes.

```bash
# One-time setup if you want full mode:
PLUGIN=~/.claude/plugins/claude-code-prod-starter
cp $PLUGIN/templates/{CLAUDE.md,AGENTS.md,PROJECT_CONTEXT.md,HANDOFF.md} ./
mkdir -p docs/decision-log
cp $PLUGIN/templates/docs/{governance-plan.md,agent-budgets.md} ./docs/
```

Then fill `PROJECT_CONTEXT.md` (15 min) and commit. After that, `/autopilot` works.

`/go` will auto-bootstrap a minimal `PROJECT_CONTEXT.md` for light mode without needing this step.

---

## What this plugin is opinionated about

- **9 gates, no skipping** (full mode). Six adversarial reviewers in fixed order catches more SEV-1s than any single human reviewer.
- **Self-review is forbidden.** The agent that wrote the code never reviews it. CTO at G6 reviews Lead Eng at G5. Hard rule.
- **Tests ship in the same commit as code.** Never "tests later."
- **No production code without a failing test first.** TDD is non-negotiable for behavior changes.
- **Surgical changes only.** Touch only what the request requires.
- **Decision Records ≤ 10 lines.** Edit code, don't document it.
- **Model picks are deliberate.** Opus 4.7 only on highest-blast-radius gates. Sonnet 4.6 elsewhere.
- **`/autopilot` pushes to feature branches only, never main.** Humans open and merge PRs.

---

## What this plugin is NOT

- Not a guarantee against bugs. Six adversarial reviewers catch more than zero, but not all.
- Not a replacement for senior engineering judgment. The agents reflect patterns; humans calibrate them.
- Not free in tokens. Light mode: ~50-200k per feature. Full mode: ~600-900k. The hooks reduce both.
- Not for trivial work. A typo fix doesn't need 9 gates.
- Not for spike branches. Spikes are exploration; gates are review. Different tools.

---

## What's inside (the 30-second technical tour)

- **`/go`** — auto-orchestrator. Reads the user's request, detects intent (FEATURE / DEBUG / REVIEW / SIMPLIFY / EXPLAIN), detects blast radius (auth/payment/migration → high), picks light or full mode, inlines the lifecycle commands, spawns specialist agents at the right moments, pauses only at three checkpoints (spec, plan, ship).

- **6 persona agents** — design, cpo, cto, cbo, lead-engineer, lead-qa. Each owns one or two of the 9 governance gates. Spawned by `/autopilot`.

- **3 specialist agents** — code-reviewer (five-axis review), security-auditor (OWASP-aligned), test-engineer (coverage audit + Prove-It). Spawned by `/go` based on what's being changed.

- **14 skills** — process skills (TDD, debugging, verification, code review, code simplification, token discipline, worktree workflow, writing skills) + knowledge skills (Karpathy guidelines, context management, model selection, Claude Code primer) + bootstrap helpers (auto-context, using-prod-starter dispatcher).

- **11 commands** — auto-orchestration (`/go`, `/diagnose`, `/autopilot`), lifecycle (`/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship`), helpers (`/code-simplify`, `/compress`).

- **7 hooks** — `SessionStart` auto-loads the dispatcher; `PostToolUse Bash` warns on huge dumps; `PostToolUse all` logs telemetry + suggests `/compact` at thresholds; `PostToolUse Read|Grep|Glob` records dedup hashes; `PreToolUse Agent` warns on bloated spawn prompts; `PreToolUse Read|Grep|Glob` warns on duplicate calls.

- **Templates** — `CLAUDE.md`, `AGENTS.md`, `PROJECT_CONTEXT.md`, `HANDOFF.md`, `docs/governance-plan.md`, `docs/agent-budgets.md`. Copy once for full mode; not needed for light mode (`auto-context` skill handles it).

- **5 onboarding docs** — primer, first day, model selection, context management, pitfalls. ~35 minutes total reading.

---

## Realistic savings

Compared to naive Claude Code use (always Opus, no compaction, bloated subagent prompts, full tool dumps):

| Lever | Savings | Source |
|---|---|---|
| Light vs full mode | 70-85% on non-governance work | `/go` picks light when blast radius is low |
| Right model picks | 2-3× on routine code | `model-selection` skill |
| Tight subagent bundles | 50-70% per spawn | `subagent-discipline` hook |
| Output discipline | 10-15% in heavy debug | `bash-output-discipline` hook |
| Auto-compact + `/compress` | 10-20% in long sessions | `auto-compact-suggest` hook |
| Dedup advisor | 5-10% in exploration-heavy work | `dedup-advisor` hook |

Compose with discipline: **35-55% in practice**. ~30-50% of OpenCode-DCP's effect. Real, not magical. For deeper compression you'd need an external proxy.

---

## Recommended reading order

For a new engineer onboarding to Claude Code with this plugin:

1. Just type `/go` and try one feature. (Fastest path.)
2. `docs/onboarding/01-claude-code-primer.md` — vocabulary
3. `docs/onboarding/02-first-day.md` — hands-on walkthrough
4. `docs/onboarding/03-model-selection.md`
5. `docs/onboarding/04-context-management.md`
6. `docs/onboarding/05-pitfalls.md`

About 35 minutes total. After that, you know more about Claude Code than 95% of users.

---

## Multi-harness use

Built for Claude Code first. The root `AGENTS.md` mirrors the most important rules for harnesses that don't auto-load skills (Codex CLI, Cursor agents). Skills, agents, and commands are plain Markdown — readable by any harness that supports them.

For full functionality on non-Claude-Code harnesses, invoke skills manually rather than relying on the SessionStart hook.

---

## Files in this repo

```
claude-code-prod-starter/
├── .claude-plugin/                 # plugin metadata + marketplace listing
├── .github/                        # PR template
├── hooks/                          # SessionStart + 6 token-discipline hooks
├── agents/                         # 6 personas + 3 specialists
├── commands/                       # /go, /diagnose, /autopilot, /spec → /ship, /compress, /code-simplify
├── skills/                         # 14 SKILL.md per directory
├── templates/                      # CLAUDE.md, AGENTS.md, PROJECT_CONTEXT.md, HANDOFF.md, docs/
├── docs/onboarding/                # 5 short docs
├── examples/                       # filled-in PROJECT_CONTEXT.md references
├── AGENTS.md                       # multi-harness entry point
├── CONTRIBUTING.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

---

## Credits + influences

- Inspired by [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) — the original Karpathy-guidelines skill packaging.
- Skill / hook / dispatcher patterns adapted from [obra/superpowers](https://github.com/obra/superpowers) and [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills).
- Token-discipline approximations inspired by [Opencode-DCP](https://github.com/Opencode-DCP/opencode-dynamic-context-pruning) — runtime context pruning for OpenCode.
- Multi-provider routing patterns inspired by [9router](https://github.com/decolua/9router).
- Forked out of a multi-country DTC storefront where the 9-gate flow shipped two production sprints. Decoupled here so any project can adopt it.

---

## Contributing

See **[CONTRIBUTING.md](CONTRIBUTING.md)**. Open an issue before any non-trivial PR. Read the contribution checklist. Match existing format.

---

## License

MIT — fork, adapt, share. See [LICENSE](LICENSE).

---

> If this plugin saved you a SEV-1 or saved you tokens you can measure, **star the repo** and tell one teammate. That's how this becomes the default Claude Code experience.
