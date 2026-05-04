# PROJECT_CONTEXT.md — solo prototype example

The minimal-viable config for a single-engineer side project. Reference for what each section should look like when you don't need multi-tenancy, residency, or i18n.

---

## Project name + one-line description

Habit Tracker — single-user iOS-style web app for tracking daily habits.

## Stack

Next.js 15 (App Router) + Postgres on Neon + Tailwind. No auth (single-user, localhost-only for now). No payments. No i18n.

## Repository layout

- `app/` — Next.js App Router pages + components
- `lib/` — db client, helpers
- `db/migrations/` — SQL migration files
- `docs/decision-log/` — DRs

## Tenancy

> Single-tenant. No multi-tenancy/country-scoping. Section deleted.

## Data residency

> Single-region. Section deleted.

## Cost

- **Hard threshold:** $20/month delta on any infra add (it's a side project, not a startup).

## Verify command

```
pnpm typecheck && pnpm lint && pnpm test
```

## Migration tool

`pnpm db:migrate` runs `db/migrations/NNNN_<name>.sql` files in order. Each migration uses `BEGIN/COMMIT` + `IF NOT EXISTS` for idempotent replay. Forward-only.

## Sprint scope discipline

No `ALTER TABLE` outside the sprint that owns the schema. If I'm building feature X, I don't refactor unrelated tables.

## Design system

> No design system yet. Section deleted. (Add later if styling drifts.)

## Inline-style restriction

No `style={{` in production code. Use Tailwind classes. Detected manually in code review until I add a lint rule.

## i18n / copy authority

> English only. Section deleted.

## Env file path(s)

- `.env.example`

## Decision-log path

`docs/decision-log/`. Filename: `DR-YYYY-MM-DD-<feature>-g<N>-<role>.md`. Hard limit: 10 lines per DR.

## Telemetry log

> Optional for solo work. Section deleted. (Add when I start running `/autopilot` on every sprint.)

---

## Notes

For a solo prototype, the 9-gate flow is overkill on most features. I run abbreviated 3-gate flow (G3 cto + G5 lead-eng + G6 cto post-build) by default. I escalate to full 9-gate only when the feature has user-facing surface area or touches data persistence.

The cto-agent and lead-engineer-agent are still useful at small scale — they catch the bugs I'd ship to myself if I worked alone.
