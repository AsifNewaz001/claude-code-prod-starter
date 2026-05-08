# claude-code-prod-starter

A production-grade Claude Code plugin for engineering teams adopting **Opus 4.7** on real codebases.

You get: governance flow + SDLC skills + reusable specialists + auto-loading dispatcher. New engineer to first shipped feature in a day, with structured review at every step.

---

## What's in the box

```
   DEFINE        PLAN         BUILD         VERIFY        REVIEW         SHIP
  ┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐
  │ Spec │ →  │ Plan │ →  │ Code │ →  │ Test │ →  │ QA   │ →  │ Live │
  └──────┘    └──────┘    └──────┘    └──────┘    └──────┘    └──────┘
  /spec       /plan       /build      /test       /review     /ship

                         OR run all 9 gates with /autopilot
```

| | Count | What |
|---|---|---|
| **Persona agents** | 6 | design, cpo, cto, cbo, lead-engineer, lead-qa — drive the 9-gate governance flow |
| **Specialist agents** | 3 | code-reviewer, security-auditor, test-engineer — reusable, ad-hoc, no flow |
| **Skills** | 13 | TDD, debugging, verification, code review, code simplification, token discipline, writing skills, worktree workflow, Karpathy guidelines, context management, model selection, primer + 1 dispatcher |
| **Slash commands** | 9 | `/spec`, `/plan`, `/build`, `/test`, `/review`, `/code-simplify`, `/compress`, `/ship` (lifecycle) + `/autopilot` (full 9-gate flow) |
| **Hooks** | 7 | SessionStart (dispatcher) + 6 token-discipline hooks (bash-output, subagent-prompt, telemetry, auto-compact-suggest, dedup-tracker, dedup-advisor) |
| **Templates** | 6 | CLAUDE.md, AGENTS.md, PROJECT_CONTEXT.md, HANDOFF.md, governance-plan.md, agent-budgets.md |
| **Onboarding docs** | 5 | 5–8 min each — primer, first day, model selection, context management, pitfalls |

---

## Two modes — pick what fits

This plugin ships both a **light mode** (addy-style SDLC commands, no governance) and a **full mode** (9-gate persona-driven flow). Same install, different commands.

### Light mode — for everyday work

No templates to copy. No `PROJECT_CONTEXT.md` to fill in. Just install and use:

```
/spec  →  /plan  →  /build  →  /test  →  /review  →  /code-simplify  →  /ship
```

Plus three specialist agents you spawn ad-hoc:

- `code-reviewer` — five-axis review before merge
- `security-auditor` — OWASP-aligned audit when auth/payments/uploads touched
- `test-engineer` — coverage audit + regression test design

This is the **addyosmani/agent-skills** pattern, baked in. Use it for the 90% of work that doesn't need committee review.

### Full mode — for high-blast-radius work

Copy the templates. Fill `PROJECT_CONTEXT.md` (one-time, ~15 min). Then:

```
/autopilot
```

Spawns the 6 persona agents through 9 gates. Each gate produces a Decision Record. Self-review forbidden. Use it for auth flows, payment paths, multi-tenant changes, anything regulated.

**Rule of thumb:** if a senior engineer would want a structured review meeting before this ships, run full mode. Otherwise light mode.

---

## Install

### Option A: Manual clone (most reliable)

Works regardless of SSH config. In your terminal:

```bash
git clone https://github.com/AsifNewaz001/claude-code-prod-starter.git ~/.claude/plugins/claude-code-prod-starter
```

Then restart Claude Code. The plugin files end up exactly where Claude Code looks for them.

### Option B: `/plugin install` (uses marketplace UI)

In Claude Code, type these at the prompt (not as a chat message):

```
/plugin marketplace add AsifNewaz001/claude-code-prod-starter
/plugin install claude-code-prod-starter@claude-code-prod-starter
```

When the install scope menu appears, pick **"Install for you (user scope)"** so the plugin is available across all your projects.

> **SSH `Permission denied (publickey)` error?**
> Claude Code's plugin install defaults to SSH cloning. If your SSH keys aren't loaded in the context Claude Code runs in, the install fails *even if `git push` works in your normal terminal*. Two fixes:
>
> 1. **Easiest**: use Option A (manual clone) above.
> 2. **Or**: force the marketplace to HTTPS:
>    ```
>    /plugin marketplace remove claude-code-prod-starter
>    /plugin marketplace add https://github.com/AsifNewaz001/claude-code-prod-starter.git
>    /plugin install claude-code-prod-starter@claude-code-prod-starter
>    ```
>    The HTTPS fix doesn't always stick because the plugin's marketplace.json may still resolve to SSH for the actual clone. If it fails, fall back to Option A.

**After install, restart Claude Code** (`/quit`, then `claude` again). Plugin agents, skills, and slash commands only register on session start.

### Verify install

In a fresh session, type `/` at the prompt — autocomplete should show `/spec`, `/plan`, `/build`, `/test`, `/review`, `/code-simplify`, `/ship`, `/autopilot`. Or:

```bash
ls ~/.claude/plugins/claude-code-prod-starter/
# Should list: agents/ commands/ skills/ hooks/ templates/ docs/
```

### Hook prerequisite

The SessionStart hook auto-loads the dispatcher (`using-prod-starter`) on every new session. Need `jq` installed (`brew install jq` on macOS, `apt-get install jq` on Linux). Without it, skills still work but you'll have to invoke them manually via the `Skill` tool.

---

## First day in your project

```bash
PLUGIN=~/.claude/plugins/claude-code-prod-starter
cp $PLUGIN/templates/{CLAUDE.md,AGENTS.md,PROJECT_CONTEXT.md,HANDOFF.md} ./
mkdir -p docs/decision-log
cp $PLUGIN/templates/docs/{governance-plan.md,agent-budgets.md} ./docs/
echo '!docs/agent-runs.log' >> .gitignore
```

Fill in `PROJECT_CONTEXT.md` (stack, verify command, residency rules). Then either:

- Run `/autopilot` to ship a feature through all 9 gates, OR
- Run `/spec` → `/plan` → `/build` → `/test` → `/review` → `/ship` for lighter governance

Full walkthrough: **[`docs/onboarding/02-first-day.md`](docs/onboarding/02-first-day.md)**.

---

## Why this plugin exists

Most teams adopting Opus 4.7 on real code hit the same five problems in their first month:

1. **Vibe-coding** — features ship without specs, design contracts, or tests. SEV-1s slip through.
2. **Token waste** — long sessions blow budgets because nobody understands `/compact`, subagent isolation, or cache TTL.
3. **Wrong model picks** — Opus 4.7 for everything (10× cost) or Haiku for everything (10× bugs).
4. **No persona separation** — the same Claude that wrote the code reviews it. Bugs invisible to the author stay invisible.
5. **Onboarding chaos** — every new teammate learns Claude Code's vocabulary the hard way.

This plugin solves all five: 9-gate flow (problems 1+4), context-management skill (2), model-selection skill (3), 5-doc onboarding path (5), and a dispatcher that auto-loads on every session.

---

## Auto-triggering — how it actually works

When you start a session, the SessionStart hook injects the `using-prod-starter` dispatcher skill into Claude's context. The dispatcher tells Claude what's available and when to use it:

- *"User wants to add a feature"* → invoke `test-driven-development`, suggest `/spec` if scope is unclear
- *"User says 'this is broken'"* → invoke `systematic-debugging`
- *"Code is written, ready to claim done"* → invoke `verification-before-completion`
- *"User wants the full review flow"* → run `/autopilot`

You don't have to remember which skill to use. Claude routes itself.

If you want to override — *"don't use TDD on this prototype"* — say so. User instructions always beat the dispatcher.

---

## The 7 slash commands

| Command | Phase | What it does |
|---|---|---|
| `/spec` | Define | Write a one-pager spec before code. Saves to `docs/specs/`. |
| `/plan` | Plan | Break the spec into atomic, testable tasks. Saves to `docs/plans/`. |
| `/build` | Build | Work the plan one task at a time, TDD throughout. |
| `/test` | Verify | Run verify command + exercise feature in real runtime + edge case audit. |
| `/review` | Review | Five-axis review (correctness, readability, architecture, security, performance). |
| `/code-simplify` | Simplify | Reduce nesting, kill duplication, improve names — no behavior change. |
| `/ship` | Ship | Pre-merge checks + commit hygiene + PR description + deploy notes. |
| `/autopilot` | Full flow | Run all 9 governance gates end-to-end. Spawns the 6 persona agents. |

Use the lifecycle commands for everyday work. Use `/autopilot` when blast radius is high (auth, payments, multi-tenant, regulated data).

---

## The 6 persona agents (governance flow)

| Agent | Role | Model | Gates |
|---|---|---|---|
| **design-agent** | Visual contract before requirements; final visual parity at close | opus | G1, G9 |
| **cpo-agent** | Requirements PRD + UAT | sonnet | G2, G8 |
| **cto-agent** | Architecture + post-build adversarial review | opus | G3, G6 |
| **cbo-agent** | Copy / CTA / localization / brand voice | sonnet | G4 |
| **lead-engineer-agent** | Implements the CTO task list verbatim | sonnet | G5 |
| **lead-qa-agent** | 3-layer adversarial QA | sonnet | G7 |

```
G1 design  →  G2 cpo  →  G3 cto  →  G4 cbo  →  G5 lead-eng
                                                     ↓
                                              G6 cto post-build
                                                     ↓
                                              G7 lead-qa  →  G8 cpo UAT  →  G9 design final
```

Each gate produces a Decision Record (`docs/decision-log/DR-YYYY-MM-DD-<feature>-g<N>-<role>.md`), capped at 10 lines. Each ends with a parseable verdict block:

```
<verdict>APPROVED|CONDITIONAL|REJECTED</verdict>
<sev>0|1|2|3</sev>
<conditions>none|<numbered list>|inline-fixed-at-<SHA></conditions>
<next>hand-off-target-or-block-reason</next>
```

`REJECTED` routes back. `CONDITIONAL` advances with conditions tracked. `APPROVED` advances unconditionally.

Full flow: **[`templates/docs/governance-plan.md`](templates/docs/governance-plan.md)**.

---

## The 3 specialist agents (reusable, no flow)

These are task-focused. No persona, no gate ownership. Spawn ad-hoc.

| Agent | When to use |
|---|---|
| **code-reviewer** | Before merging any change. Five-axis review. |
| **security-auditor** | Auth, payments, file uploads, external input — anything OWASP-relevant. |
| **test-engineer** | Coverage uncertain, bug needs a regression test, suite is shallow / flaky. |

```
# In Claude:
"Spawn the code-reviewer agent on this PR."
"Spawn the security-auditor on the new login endpoint."
"Spawn the test-engineer to audit coverage of the cart module."
```

---

## The 10 skills

**Process skills (engineering workflows)**

| Skill | What |
|---|---|
| `using-prod-starter` | The dispatcher. Loaded automatically by the SessionStart hook. |
| `karpathy-guidelines` | Andrej Karpathy's 4 LLM-coding rules: think → simplify → surgical → goal-driven. |
| `test-driven-development` | Failing test first. Tests ship in the same commit. |
| `systematic-debugging` | Reproduce, isolate, bisect, fix the cause, regression test. |
| `verification-before-completion` | Never claim done without evidence. |
| `code-review` | Five-axis review before merge. |
| `code-simplification` | Reduce complexity without changing behavior. |
| `token-discipline` | Reduce token spend on tool dumps, subagent spawns, stale context. Pairs with the 3 discipline hooks. |
| `writing-skills` | Author or edit a skill for this plugin. |
| `worktree-workflow` | Git worktrees for parallel agent work and safe `/autopilot` runs. |

**Knowledge skills (Claude Code literacy)**

| Skill | What |
|---|---|
| `context-management` | When/how to `/compact`, subagent budgets, cache TTL. |
| `model-selection` | Opus 4.7 / Sonnet 4.6 / Haiku 4.5 decision matrix. |
| `claude-code-primer` | Agents vs skills vs commands vs hooks vs plugins. |

---

## Token discipline (built-in hooks + DCP approximations)

The plugin ships six hooks that auto-fire to keep token spend in check:

| Hook | Fires when | What it does |
|---|---|---|
| `bash-output-discipline` | Bash output >200 lines or >10k chars | Reminder with targeted-command suggestions |
| `subagent-discipline` | Agent spawn prompt >2000 chars | Injects tight-bundle pattern |
| `token-telemetry` | Every tool call | TSV log to `docs/agent-runs.log` |
| `auto-compact-suggest` | Session tokens cross 75k / 150k | Suggests `/compact <focus>` |
| `dedup-tracker` | After Read/Grep/Glob | Records call hash to per-session cache |
| `dedup-advisor` | Before Read/Grep/Glob | Warns if you already ran the exact same call |

Plus `/compress` — a slash command that wraps `/compact` with a structured focus template, telling Claude exactly what to keep and what to drop. Closer to OpenCode-DCP's range-mode compress than blind `/compact`.

### Auditing your token spend

After a long session:

```bash
# Total tokens today:
awk -F'\t' -v today=$(date -u +%Y-%m-%d) '$1 ~ today {input+=$4; output+=$5} END {print "in:", input, "out:", output}' docs/agent-runs.log

# Heaviest single tool calls:
sort -k5 -n -r docs/agent-runs.log | head -10

# Tool count per session:
awk -F'\t' '{print $2}' docs/agent-runs.log | sort | uniq -c | sort -rn
```

### Honest scope vs OpenCode-DCP

DCP modifies the API request payload — it can compress ranges, dedupe tool results, and purge errored inputs at the wire. Claude Code's plugin API can't do that. The plugin's hooks can only **warn** and **advise**.

| OpenCode-DCP | This plugin's approximation |
|---|---|
| `compress` tool the model invokes | `/compress` slash command (user-invoked) |
| Range-mode payload compression | `/compress` → `/compact <focus>` (broader, lossier) |
| Automatic tool-result dedup | `dedup-advisor` warns BEFORE re-run |
| Auto-trigger on task completion | `auto-compact-suggest` fires at token thresholds |
| Error-input purge in payload | None — gap |

The hooks land ~30-50% of DCP's effect. The remaining 50-70% requires Claude Code to expand its plugin API. For workloads where token cost dominates, OpenCode + DCP is a better fit; this plugin's value is workflow + governance, not payload compression.

---

## Multi-harness use

This plugin is built for Claude Code first. The `AGENTS.md` at the repo root mirrors the most important rules for harnesses that don't auto-load skills (Codex CLI, Cursor agents).

If you want full functionality on a non-Claude-Code harness, you'll need to invoke skills manually rather than relying on the SessionStart hook. The skills, agents, and commands are all plain Markdown — read them directly if your harness can't auto-discover.

---

## What this plugin is opinionated about

- **9 gates, no skipping.** Six adversarial reviewers in fixed order catches more SEV-1s than any single human reviewer.
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
- Not a replacement for a senior engineer's judgment. The agents reflect patterns; humans calibrate them.
- Not free. A typical full-flow sprint costs $4–6 in API tokens at the default model split. Cheaper than a single SEV-1.
- Not for trivial work. A typo fix doesn't need 9 gates. Use judgment — or `/spec` → `/build` for lighter-weight changes.
- Not for spike branches. Spikes are exploration; gates are review. Different tools.

---

## Trade-offs (honest)

Adopting this plugin means:

- **More tokens per feature.** ~600–900k across the 9 gates is normal.
- **Fewer features per week.** The flow takes longer than vibe-coding.
- **Better catch rate on SEV-1s.** The whole point.
- **Better onboarding for new teammates.** Vocabulary + workflow shipped together.
- **Better institutional memory.** Every decision logged in `docs/decision-log/`.

Worth it for systems with real users, money, or compliance exposure. Overkill for solo prototypes — use the abbreviated 3-gate flow in `examples/solo-prototype-PROJECT_CONTEXT.md`.

---

## Recommended reading order

For a new engineer onboarding to Claude Code with this plugin:

1. `docs/onboarding/01-claude-code-primer.md` — vocabulary
2. `docs/onboarding/02-first-day.md` — hands-on walkthrough
3. `docs/onboarding/03-model-selection.md` — daily decision
4. `docs/onboarding/04-context-management.md` — token discipline
5. `docs/onboarding/05-pitfalls.md` — what NOT to do
6. The dispatcher (`skills/using-prod-starter/SKILL.md`) — loads automatically anyway
7. Your project's filled-in `PROJECT_CONTEXT.md` and `AGENTS.md`

About 35 minutes total. After that, run `/autopilot` and learn by shipping.

---

## Files in this repo

```
claude-code-prod-starter/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── .github/
│   └── PULL_REQUEST_TEMPLATE.md
├── hooks/
│   ├── hooks.json
│   └── session-start.sh
├── agents/
│   ├── design-agent.md            # persona — gates G1, G9
│   ├── cpo-agent.md               # persona — gates G2, G8
│   ├── cto-agent.md               # persona — gates G3, G6
│   ├── cbo-agent.md               # persona — gate G4
│   ├── lead-engineer-agent.md     # persona — gate G5
│   ├── lead-qa-agent.md           # persona — gate G7
│   ├── code-reviewer.md           # specialist
│   ├── security-auditor.md        # specialist
│   └── test-engineer.md           # specialist
├── commands/
│   ├── autopilot.md               # /autopilot — full 9-gate flow
│   ├── spec.md                    # /spec — define
│   ├── plan.md                    # /plan — plan
│   ├── build.md                   # /build — build
│   ├── test.md                    # /test — verify
│   ├── review.md                  # /review — review
│   ├── code-simplify.md           # /code-simplify — refactor for clarity
│   └── ship.md                    # /ship — ship
├── skills/
│   ├── using-prod-starter/        # dispatcher (auto-loaded by hook)
│   ├── karpathy-guidelines/
│   ├── test-driven-development/
│   ├── systematic-debugging/
│   ├── verification-before-completion/
│   ├── code-review/
│   ├── code-simplification/
│   ├── writing-skills/
│   ├── worktree-workflow/
│   ├── context-management/
│   ├── model-selection/
│   └── claude-code-primer/
├── templates/
│   ├── CLAUDE.md
│   ├── AGENTS.md
│   ├── PROJECT_CONTEXT.md
│   ├── HANDOFF.md
│   └── docs/
│       ├── governance-plan.md
│       └── agent-budgets.md
├── docs/onboarding/               # 5 short docs
│   ├── 01-claude-code-primer.md
│   ├── 02-first-day.md
│   ├── 03-model-selection.md
│   ├── 04-context-management.md
│   └── 05-pitfalls.md
├── examples/
│   ├── brand-x-PROJECT_CONTEXT.md
│   └── solo-prototype-PROJECT_CONTEXT.md
├── AGENTS.md                      # multi-harness entry point
├── CONTRIBUTING.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

---

## Credits + influences

- Inspired by [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) — the original Karpathy-guidelines skill packaging.
- Skill / hook / dispatcher patterns adapted from [obra/superpowers](https://github.com/obra/superpowers) and [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills).
- Context-management concepts from [Opencode-DCP/opencode-dynamic-context-pruning](https://github.com/Opencode-DCP/opencode-dynamic-context-pruning).
- Forked out of a multi-country DTC storefront where the 9-gate flow shipped two production sprints. Decoupled here so any project can adopt it.

---

## Contributing

See **[CONTRIBUTING.md](CONTRIBUTING.md)**. Open an issue before any non-trivial PR. Read the contribution checklist. Match existing format.

---

## License

MIT — fork, adapt, share. See [LICENSE](LICENSE).
