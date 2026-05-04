# 05 — Pitfalls

**Read time: 6 minutes.**

The mistakes engineers make when adopting Claude Code with Opus 4.7. Read this so you don't have to learn them by shipping bugs.

This extends the four Karpathy guidelines (think before coding, simplicity first, surgical changes, goal-driven execution) — those address Claude's *behavior*. This doc addresses **your** behavior as the operator.

## Pitfall 1 — Trusting the LLM's first draft

**What happens:** Claude produces 200 lines of code. Looks reasonable. You hit accept. Two days later you find it has a subtle off-by-one, a missing edge case, or invents a function that doesn't exist.

**Why:** Opus 4.7 is the most capable model out there. It's still fallible. Speed of generation can mask depth of reasoning.

**Fix:** Tests, always. The Karpathy "goal-driven execution" rule is non-negotiable. Every non-trivial change ships with a test that verifies it. The 9-gate flow's CTO post-build review (G6) and Lead QA (G7) exist precisely for this.

## Pitfall 2 — Letting context bloat compound

**What happens:** Your session is 4 hours old. You're at 80% context usage. Claude is slow, expensive, and starts misremembering decisions from earlier in the conversation.

**Why:** No pruning discipline. Tool outputs accumulate. The cache invalidates and rewarms repeatedly.

**Fix:** Read `04-context-management.md`. `/compact` at phase boundaries. Tight subagent bundles. If a session is 30+ minutes, you should have run `/compact` at least once.

## Pitfall 3 — Skipping `PROJECT_CONTEXT.md`

**What happens:** You install the plugin, run `/autopilot`, and the cto-agent says "STOP — PROJECT_CONTEXT.md missing." You skim it, fill in two fields, hit run again. cto-agent makes architectural decisions that don't match your stack.

**Why:** The agents are project-agnostic by design. They CANNOT make good decisions without project context. Half-filled `PROJECT_CONTEXT.md` is worse than empty — empty makes the agent stop; half-filled makes it guess.

**Fix:** Take 15 minutes on day one. Fill in every applicable section. Use `examples/brand-x-PROJECT_CONTEXT.md` as a reference. Delete sections that don't apply (e.g., data residency for a single-region SaaS). The agents detect missing sections and treat them as no-ops — they don't guess.

## Pitfall 4 — Running gates out of order

**What happens:** You skip G1 design "because there's no UI in this sprint" and go straight to G3 architecture. Six gates later, the design-agent's G9 final review rejects the work because there was no visual contract to compare against.

**Why:** The 9-gate flow is sequenced for a reason. G1 sets the visual contract that G7 (QA design layer) and G9 (final design parity) check against. Skipping G1 means those gates have nothing to verify.

**Fix:** Run gates in order. For backend-only sprints, G1 design-agent locks "zero visible regression after migration" as the visual contract — it's a 30-second gate but the contract matters.

## Pitfall 5 — Ignoring `REJECTED` verdicts

**What happens:** A gate returns `<verdict>REJECTED</verdict>` with conditions. You're tired. You manually edit the DR to say `APPROVED` and push to main.

**Why:** Pressure, fatigue, or miscalibration of severity. The agent flagged something for a reason.

**Fix:** Treat REJECTED as a hard stop. Either (a) fix inline and re-spawn the agent, (b) escalate to a human reviewer, or (c) document in the DR why you're consciously overriding (rare; usually wrong). Never silently flip the verdict.

## Pitfall 6 — Self-review by the same persona

**What happens:** Lead Engineer at G5 ships code, then the orchestrator (or you) tries to have lead-engineer-agent self-verify. Bugs get missed because the same context that wrote the bug doesn't see it.

**Why:** Hard rule: self-review is a workflow violation. The plugin's `AGENTS.md` codifies this. CTO at G6 reviews Lead Eng at G5 — never Lead Eng reviewing themselves.

**Fix:** Trust the persona separation. The orchestrator (`/autopilot`) enforces this automatically. If you're spawning agents manually, follow the same rule.

## Pitfall 7 — Inventing scope mid-flow

**What happens:** Lead Eng at G5 is implementing the CTO task list, sees an adjacent file that "could be cleaner," refactors it. The PR is now 40% scope creep. CTO at G6 rejects.

**Why:** Karpathy's "surgical changes" principle violated. The CTO's G3 task list IS the contract. Deviations need to be explicitly logged and approved.

**Fix:** Lead Eng implements the G3 task list verbatim. Spotted improvements get logged as a separate task in `HANDOFF.md` under "Out of scope (next sprint)." Never inline a refactor.

## Pitfall 8 — Trusting the first model match

**What happens:** You ask Claude (any model) to "use the latest API for X." It generates code with API calls that don't exist or were renamed. The code compiles, runs, but does the wrong thing.

**Why:** LLMs hallucinate APIs. Especially under pressure to be helpful.

**Fix:** For external APIs, always: (a) link the official docs, (b) tell Claude to read them, (c) verify with a quick `curl` or stub. The `mcp__pm-cowork__verify_no_hallucination` tool exists for cbo-agent to do this on copy claims.

## Pitfall 9 — Production prod role with BYPASSRLS

**What happens:** Your runtime database role has `BYPASSRLS=true`. All your `withCountry()` (or `withTenant()`) calls silently bypass the RLS policy. Cross-tenant leak in production. You don't notice until a customer reports seeing another tenant's data.

**Why:** Common on Neon / managed Postgres — the default `*_owner` role has BYPASSRLS. RLS lint can't see this; it's a runtime property of the database connection.

**Fix:** Audit your production `DATABASE_URL` role. Use a least-privilege app role (`tnj_app`, `app_user`, etc.) that does NOT have BYPASSRLS. Migrations stay on the owner role; the app uses the limited one. This plugin's `cto-agent` flags this in its hard rules.

## Pitfall 10 — Skipping the verify command

**What happens:** You commit code locally without running the verify command (`pnpm typecheck && pnpm lint && pnpm test`). Push to GitHub. CI fails. PR sits red for an hour while you fix it.

**Why:** Faith in Claude. "It looked right." Trust drift.

**Fix:** The plugin's `lead-engineer-agent` runs the verify command before every commit. If you're working without `/autopilot`, run it yourself. Make it a hook (`SessionEnd` hook can run verify; many teams do this).

## Pitfall 11 — Pushing to main directly

**What happens:** You give Claude write access to main. It pushes a commit. CI fails. Now main is broken for the whole team.

**Why:** Insufficient guardrail.

**Fix:** Claude Code's `/autopilot` is configured to push to feature branches only, never main. Verify your team's setting allows this. The user opens / merges PRs. Don't override.

## Pitfall 12 — Not capturing telemetry

**What happens:** Six sprints in, you don't know which gates are over budget, which agents are over-running, which model picks are working. You can't calibrate.

**Why:** Telemetry capture is a soft fault — easy to skip.

**Fix:** Every gate appends one row to `docs/agent-runs.log`. The orchestrator does this for you. If a gate is over budget 3 sprints in a row, raise its target. Calibration without data is guessing.

## What to read next

- The plugin's `AGENTS.md` (template) — codifies the workflow rules
- `karpathy-guidelines` skill — Claude's behavioral rules
- `commands/autopilot.md` — see the protections in production
