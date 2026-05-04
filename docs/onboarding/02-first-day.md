# 02 — Your first day

**Read time: 8 minutes.** **Hands-on time: 30 minutes.**

This is the install → first `/autopilot` → first feature shipped walkthrough. Do it on a fresh side project, not on production.

## Prerequisites

- Claude Code installed: `npm install -g @anthropic-ai/claude-code` (or per platform)
- An Anthropic API key configured (Claude Code prompts you on first run)
- A git repo you control. Empty or with code, both fine.
- Postgres (only if your first feature touches a DB; not required for the walkthrough)

## Step 1 — Install the plugin (one minute)

In Claude Code, run:

```
/plugin marketplace add github:<your-username>/claude-code-prod-starter
/plugin install claude-code-prod-starter
```

Restart Claude Code (close the session, reopen). The plugin's agents, skills, and `/autopilot` command become globally available.

Verify:

```
/agents
```

You should see: `cto-agent`, `cpo-agent`, `cbo-agent`, `design-agent`, `lead-engineer-agent`, `lead-qa-agent`.

## Step 2 — Scaffold your project (five minutes)

In your project's root, create the four templates from this plugin:

```bash
PLUGIN=~/.claude/plugins/claude-code-prod-starter

cp $PLUGIN/templates/CLAUDE.md ./CLAUDE.md
cp $PLUGIN/templates/AGENTS.md ./AGENTS.md
cp $PLUGIN/templates/PROJECT_CONTEXT.md ./PROJECT_CONTEXT.md
cp $PLUGIN/templates/HANDOFF.md ./HANDOFF.md

mkdir -p docs/decision-log
cp $PLUGIN/templates/docs/governance-plan.md ./docs/
cp $PLUGIN/templates/docs/agent-budgets.md ./docs/
```

Then add a gitignore exception for the telemetry log (so it's tracked):

```bash
echo '!docs/agent-runs.log' >> .gitignore
```

## Step 3 — Fill in `PROJECT_CONTEXT.md` (10 minutes)

This is the most important step. The agents WILL refuse to operate if this file is empty or vague.

Open `PROJECT_CONTEXT.md` and fill in:

- **Project name + one-line description** (always required)
- **Stack** (always required)
- **Verify command** (always required) — the single command Lead Engineer runs before each commit. Example: `pnpm typecheck && pnpm lint && pnpm test`
- **Decision-log path** (always required) — usually `docs/decision-log/`

Optional sections (delete if not applicable):

- **Tenancy** (if multi-tenant or multi-country)
- **Data residency** (if you have GDPR / 152-FZ / RBI / HIPAA constraints)
- **Migration tool** (if you have a migration system)
- **Design system** (if you have one)
- **i18n / copy authority** (if you have multiple locales)

Use `examples/brand-x-PROJECT_CONTEXT.md` in the plugin as a reference for a complete multi-country e-commerce config. Use `examples/solo-prototype-PROJECT_CONTEXT.md` for a minimal one.

## Step 4 — Adapt `AGENTS.md` (five minutes)

Open `AGENTS.md`. Look for the `## Brand / voice` section. Fill in:

- Your visual benchmark URL (e.g. `https://stripe.com` for SaaS, `https://quince.com` for e-commerce)
- Your forbidden phrases (pick from defaults; add anything specific to your brand)
- Your currency formatting if relevant

Delete sections that don't apply.

## Step 5 — Decide your first feature

Pick something **small and contained**. Good first features:

- A new page (e.g., `/about` or `/pricing`)
- A new API endpoint with 2-3 fields
- A category-filter UI on an existing list page

Bad first features:

- "Refactor the auth system"
- "Migrate from Firebase to Supabase"
- Anything touching payments or user data on day one

Edit `HANDOFF.md`. Replace `<feature-name>` with your actual feature. Save.

## Step 6 — Run `/autopilot` (15 minutes — Claude does the work)

In Claude Code, type:

```
/autopilot
```

The orchestrator will:

1. Read `HANDOFF.md`, identify the next gate (G1 design-agent for a brand-new feature).
2. Verify your repo is green (`pnpm typecheck && pnpm lint && pnpm test` etc., per `PROJECT_CONTEXT.md` § Verify).
3. Spawn `design-agent` at G1 with a tight context bundle.
4. design-agent writes the visual contract → DR file → verdict block.
5. Orchestrator parses verdict, captures telemetry, commits, advances to G2.
6. ... continues through all 9 gates.

Each gate produces a Decision Record in `docs/decision-log/`. Each takes 30 seconds to 5 minutes depending on complexity.

You'll get prompts for:
- Approving destructive operations (commits, branches, etc.)
- Confirming when an agent's verdict is `CONDITIONAL` and asks "fix inline or escalate"

## Step 7 — Watch what happens

After the run, you should have:

- 9 DR files in `docs/decision-log/DR-YYYY-MM-DD-<feature>-g{1..9}-*.md`
- A feature branch with one commit per closed gate
- `HANDOFF.md` updated with what shipped + what's next
- `docs/agent-runs.log` with one telemetry row per gate
- A PR description ready to copy into GitHub

If a gate gets `REJECTED`, the orchestrator either fixes inline or escalates to you. Read the conditions, decide, give it a green-light or fix yourself.

## Step 8 — Open the PR (one minute)

```bash
git push origin <your-feature-branch>
gh pr create --title "<feature>" --body-file docs/sprint-N/<feature>/PR-description.md
```

Or use `/autopilot` again — it will ship the PR for you on the next run.

## What to do if it goes sideways

| Problem | Fix |
|---|---|
| Agent says "PROJECT_CONTEXT.md missing" | You skipped Step 3. Go back. |
| Agent says "verify command failed" | Run the verify command yourself; fix the underlying issue |
| Verdict is REJECTED with conditions | Read the conditions, fix, re-run `/autopilot` |
| `/autopilot` runs forever (no context-bundle discipline) | See `04-context-management.md` |
| Cost is way higher than expected | See `03-model-selection.md` |
| Lots of bugs slipping past | See `05-pitfalls.md` |

## What you've accomplished

After this walkthrough you have:

- A scaffolded project with the 9-gate workflow ready
- One feature shipped through 9 gates of review
- 9 decision records that document why every choice was made
- A telemetry baseline for future budget calibration
- The mental model to do this on every feature going forward

Now read `03-model-selection.md` for when to use which model, and `04-context-management.md` for not blowing your token budget on long sessions.
