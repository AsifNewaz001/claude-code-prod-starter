# claude-code-prod-starter

A Claude Code plugin for engineering teams adopting **Opus 4.7** on production-grade work. Six persona agents under a 9-gate governance flow, plus context literacy, model-selection guidance, and a 5-doc onboarding path.

Built so a new engineer can install the plugin, copy a few templates, fill in `PROJECT_CONTEXT.md`, and ship their first feature through a structured review flow on day one.

---

## TL;DR — install + first day

```
# In Claude Code:
/plugin marketplace add github:<your-username>/claude-code-prod-starter
/plugin install claude-code-prod-starter
```

Then in your project:

```bash
PLUGIN=~/.claude/plugins/claude-code-prod-starter
cp $PLUGIN/templates/{CLAUDE.md,AGENTS.md,PROJECT_CONTEXT.md,HANDOFF.md} ./
mkdir -p docs/decision-log
cp $PLUGIN/templates/docs/{governance-plan.md,agent-budgets.md} ./docs/
echo '!docs/agent-runs.log' >> .gitignore
```

Fill in `PROJECT_CONTEXT.md`. Then run `/autopilot` to ship your first feature through 9 gates of review.

Full walkthrough: **[`docs/onboarding/02-first-day.md`](docs/onboarding/02-first-day.md)**.

---

## Why this plugin exists

Most engineering teams adopting Opus 4.7 on real codebases hit the same five problems in their first month:

1. **Vibe-coding** — features ship without PRDs, design contracts, or test coverage. SEV-1s slip through.
2. **Token waste** — long sessions blow through budgets because nobody understands `/compact`, subagent context isolation, or the 5-min cache TTL.
3. **Wrong model picks** — engineers default to Opus 4.7 for everything (10x cost) or Haiku for everything (10x bugs).
4. **No persona separation** — the same Claude that wrote the code reviews it. Bugs invisible to the author stay invisible.
5. **Onboarding chaos** — every new teammate learns Claude Code's vocabulary (agents vs skills vs commands vs hooks vs plugins) the hard way.

This plugin solves all five with: a 9-gate flow (problem 1+4), context-management literacy (2), a model-selection skill (3), and a 5-doc onboarding path (5).

---

## What ships in the plugin

### Agents (6 personas)

| Agent | Role | Model | Gates |
|---|---|---|---|
| **design-agent** | Visual contract before requirements; final visual parity at close | opus | G1 (open), G9 (close) |
| **cpo-agent** | Requirements PRD + UAT | sonnet | G2, G8 |
| **cto-agent** | Architecture + post-build adversarial review | opus | G3, G6 |
| **cbo-agent** | Copy / CTA / localization / brand voice | sonnet | G4 |
| **lead-engineer-agent** | Implements the CTO task list verbatim | sonnet | G5 |
| **lead-qa-agent** | 3-layer adversarial QA | sonnet | G7 |

### Commands

- **`/autopilot`** — Orchestrator. Reads `HANDOFF.md`, spawns the 6 personas in order, captures telemetry, commits per gate, updates `HANDOFF.md`.

### Skills

- **`karpathy-guidelines`** — Andrej Karpathy's 4 LLM-coding rules (think → simplify → surgical → goal-driven).
- **`context-management`** — When/how to `/compact`, subagent budgets, cache TTL, DCP concepts.
- **`model-selection`** — Opus 4.7 / Sonnet 4.6 / Haiku 4.5 decision matrix.
- **`claude-code-primer`** — Agents vs skills vs commands vs hooks vs plugins; vocabulary cheat-sheet.

### Onboarding docs

`docs/onboarding/` ships 5 short docs (5-8 min each):

1. **`01-claude-code-primer.md`** — what Claude Code is, what it isn't, the 5 primitives
2. **`02-first-day.md`** — install → scaffold → first `/autopilot` → first PR
3. **`03-model-selection.md`** — when Opus 4.7 vs Sonnet 4.6 vs Haiku 4.5
4. **`04-context-management.md`** — auto-compaction, `/compact`, subagent bundles, cache TTL
5. **`05-pitfalls.md`** — 12 common mistakes engineers make adopting Claude Code

### Templates

`templates/` ships files the consumer copies into their own repo:

- `CLAUDE.md` — always-loaded project guardrails (Karpathy + project entry points)
- `AGENTS.md` — workflow + brand voice + the 6 agents declared
- `PROJECT_CONTEXT.md` — fill-in template (stack, verify command, tenancy, residency, etc.)
- `HANDOFF.md` — empty seed for `/autopilot`'s sprint state
- `docs/governance-plan.md` — the 9-gate flow itself
- `docs/agent-budgets.md` — per-gate token targets + telemetry format

### Examples

`examples/` ships filled-in references:

- `brand-x-PROJECT_CONTEXT.md` — full multi-country e-commerce config (BD/AU/CA/RU on Postgres+Next.js)
- `solo-prototype-PROJECT_CONTEXT.md` — minimal config for a single-engineer side project

---

## The 9-gate flow at a glance

```
G1 design  →  G2 cpo  →  G3 cto  →  G4 cbo  →  G5 lead-eng
                                                     ↓
                                              G6 cto post-build
                                                     ↓
                                              G7 lead-qa  →  G8 cpo UAT  →  G9 design final
```

Each gate produces a Decision Record (`docs/decision-log/DR-YYYY-MM-DD-<feature>-g<N>-<role>.md`), capped at 10 lines. Each gate ends with a parseable verdict block:

```
<verdict>APPROVED|CONDITIONAL|REJECTED</verdict>
<sev>0|1|2|3</sev>
<conditions>none|<numbered list>|inline-fixed-at-<SHA></conditions>
<next>hand-off-target-or-block-reason</next>
```

`REJECTED` routes back. `CONDITIONAL` advances with conditions tracked. `APPROVED` advances unconditionally.

Full flow: **[`templates/docs/governance-plan.md`](templates/docs/governance-plan.md)**

---

## Recommended reading order

For a new engineer onboarding to Claude Code with this plugin:

1. `docs/onboarding/01-claude-code-primer.md` — vocabulary
2. `docs/onboarding/02-first-day.md` — hands-on walkthrough
3. `docs/onboarding/03-model-selection.md` — daily decision
4. `docs/onboarding/04-context-management.md` — token discipline
5. `docs/onboarding/05-pitfalls.md` — what NOT to do
6. The plugin's 4 skills (load automatically when relevant)
7. Your project's filled-in `PROJECT_CONTEXT.md` and `AGENTS.md`

Total reading: about 35 minutes. After that, run `/autopilot` and learn by shipping.

---

## What this plugin is opinionated about (and why)

- **9 gates, no skipping.** Six adversarial reviewers in a fixed order catches more SEV-1s than any single human reviewer.
- **Decoupled from any specific stack.** Tenancy, residency, currency, locale list — all live in `PROJECT_CONTEXT.md`. The agents themselves don't assume your stack.
- **Self-review is forbidden.** The persona that wrote the code never reviews it. CTO at G6 reviews Lead Eng at G5. Hard rule.
- **Tests ship in the same commit as code.** Never "tests later."
- **DR ≤ 10 lines.** Edit code, don't document it. Decision records are summaries, not narratives.
- **Model picks are deliberate.** Opus 4.7 only on the highest-blast-radius gates (G1/G3/G6/G9). Sonnet 4.6 elsewhere.
- **`/autopilot` push to feature branches only, never main.** The user opens / merges PRs.

---

## What this plugin is NOT

- Not a guarantee against bugs. Six adversarial reviewers catch more than zero, but not all.
- Not a replacement for a senior engineer's judgment. The agents reflect *patterns*; humans calibrate them.
- Not free. A typical sprint costs $4-6 in API tokens at the default model split. (Cheaper than a single SEV-1 incident.)
- Not for trivial work. A typo fix doesn't need 9 gates. Use judgment.
- Not for spike branches. Spikes are exploration; gates are review. Different tools.

---

## Trade-off

Adopting this plugin means:

- More tokens per feature (~600-900k across all 9 gates is normal).
- Fewer features per week.
- Better catch rate on SEV-1s.
- Better onboarding for new teammates.
- Better institutional memory (every decision logged).

Worth it for systems with real production users, money, or compliance exposure. Overkill for solo prototypes (use the abbreviated 3-gate flow instead — see `examples/solo-prototype-PROJECT_CONTEXT.md`).

---

## Customization

The agents reference `PROJECT_CONTEXT.md` and `AGENTS.md` by relative path. To use different filenames, search-replace the path in the agent files.

The 9-gate numbering is opinionated. If your team uses a different gate count, edit the `<gates>` block in each agent's `.md` file. The verdict block format is what `/autopilot` parses — don't change that.

The 6 agents have opinions baked in:
- design-agent rejects desktop-first specs
- cpo-agent enforces RICE > 5 by default
- cto-agent rejects tenancy violations and over-threshold infra adds
- cbo-agent forbids exclamation marks and competitor names
- lead-engineer-agent implements verbatim — no improv
- lead-qa-agent treats every PR as buggy until proven otherwise

If any opinion doesn't match your team, edit the `<rules>` block. The opinions are the value — adjust them, don't delete them.

---

## Files in this repo

```
claude-code-prod-starter/
├── .claude-plugin/plugin.json
├── agents/                       # 6 persona agents
│   ├── design-agent.md
│   ├── cpo-agent.md
│   ├── cto-agent.md
│   ├── cbo-agent.md
│   ├── lead-engineer-agent.md
│   └── lead-qa-agent.md
├── commands/
│   └── autopilot.md              # /autopilot orchestrator
├── skills/                       # 4 skills, all project-agnostic
│   ├── karpathy-guidelines/SKILL.md
│   ├── context-management/SKILL.md
│   ├── model-selection/SKILL.md
│   └── claude-code-primer/SKILL.md
├── templates/                    # consumer copies these into their repo
│   ├── CLAUDE.md
│   ├── AGENTS.md
│   ├── PROJECT_CONTEXT.md
│   ├── HANDOFF.md
│   └── docs/
│       ├── governance-plan.md
│       └── agent-budgets.md
├── docs/onboarding/              # 5 short docs (5-8 min each)
│   ├── 01-claude-code-primer.md
│   ├── 02-first-day.md
│   ├── 03-model-selection.md
│   ├── 04-context-management.md
│   └── 05-pitfalls.md
├── examples/
│   ├── brand-x-PROJECT_CONTEXT.md
│   └── solo-prototype-PROJECT_CONTEXT.md
└── README.md
```

---

## Credits

- Inspired by [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) — the original Karpathy-guidelines CLAUDE.md/skill packaging.
- Context-management concepts ported from [Opencode-DCP/opencode-dynamic-context-pruning](https://github.com/Opencode-DCP/opencode-dynamic-context-pruning) — runtime DCP for OpenCode (different tool; concepts apply).
- Forked out of a multi-country DTC storefront where the 9-gate flow shipped two production sprints. Decoupled here so any project can adopt it.

---

## License

MIT — fork, adapt, share.
