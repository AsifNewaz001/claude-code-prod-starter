# PROJECT_CONTEXT.md

This file is the consumer-side configuration the `cto-agent` and `lead-engineer-agent` read on every gate. Fill in every section that applies to your project. Sections you delete the agents will treat as no-ops.

---

## Project name + one-line description

> **Replace.** e.g. "Brand X — multi-country DTC storefront serving BD/RU/AU/CA."

## Stack

> **Replace.** Frameworks, primary database, search, storage, auth. The agents quote this when describing what they're reviewing.
>
> Example: "Next.js 15 (App Router) + Postgres on Neon + Typesense + Cloudflare R2. Auth via Clerk. Payment via per-country adapters."

## Repository layout

> **Replace.** Top-level directories the agents reference. Avoids them grep'ing the whole tree.
>
> Example:
> - `apps/storefront/` — customer-facing Next.js app
> - `apps/admin/` — backoffice Next.js app
> - `packages/db/` — schema + migrations + country-scoping helpers
> - `packages/shared/` — types, mocks, i18n
> - `packages/ui/` — design system components
> - `docs/` — RFCs, decision-log, sprint folders

## Tenancy

> **Required if your codebase is multi-tenant/country.** Delete this whole section if single-tenant/country.
>
> - **Tenant key column:** `country_id` (or `tenant_id`, `org_id`, etc.)
> - **Tenancy helper function:** `withCountry(country, fn)` — sets the session variable RLS reads from. Path: `packages/db/src/pool.ts`.
> - **Pattern enforcement lint:** `pnpm db:rls-lint` — runs at every commit. Must remain at the post-migration count.
> - **Cross-tenant/country test pattern:** `packages/db/__tests__/cross-tenant-leak.test.ts` — every new query path on a tenant/country-scoped table extends this.
> - **Defense-in-depth:** every SQL query on a tenant/country-scoped table includes an explicit `WHERE <tenant_key> = $1` predicate, even when RLS is in place. The runtime role may have BYPASSRLS; the explicit predicate works regardless.

## Data residency

> **Optional.** Only fill in if your project has cross-region rules (e.g., GDPR, Russia 152-FZ, India RBI).
>
> Example for Brand X:
> - RU customer/order data MUST stay on Yandex Cloud (Moscow region) per 152-FZ.
> - `withCountry('RU')` resolves `DATABASE_URL_RU`; `BD/AU/CA` resolve `DATABASE_URL`.
> - Schema parity asserted on first RU connection per process.
> - Unset `DATABASE_URL_RU` on RU deploy = `RU_DB_NOT_CONFIGURED` thrown at request time. No silent fallback.

## Cost

> **Required.** Threshold above which the CTO agent escalates to a PM council decision instead of approving inline.
>
> - **Hard threshold:** $200/month delta on any single infra add.
> - **Convention:** ROI calculation included in the architecture DR for any add above 50% of threshold.

## Verify command

> **Required.** The single command Lead Engineer runs before every commit. Must be green.
>
> Example: `pnpm typecheck && pnpm lint && pnpm ds:guard && pnpm test && pnpm db:rls-lint`
>
> Project-specific lints to mention: `ds:guard` (design system token compliance), `db:rls-lint` (country-scoping pattern), etc.

## Migration tool

> **Required if you have a migration system.** Tool name + numbering convention + idempotency pattern.
>
> Example: `pnpm db:migrate` runs `packages/db/migrations/NNNN_<name>.sql` files in order. Each migration uses `BEGIN/COMMIT` + `IF NOT EXISTS` + `ON CONFLICT DO NOTHING` for idempotent replay. Forward-only; no `.down.sql`.

## Sprint scope discipline

> **Required.** The rule that prevents schema drift mid-sprint.
>
> Example: "No `ALTER TABLE` outside the sprint that owns the schema. Sprint 18 cannot mutate `categories`; that's Sprint 19's scope."

## Design system

> **Required.** Path to the canonical design system spec.
>
> Example:
> - `docs/design-system.md` — palette (7 tokens), spacing (4/8/12/16/24/32/48/64/96/128), typography (6 roles), aspect ratios.
> - `pnpm ds:guard` — fails the build on inline styles, off-token colors, off-scale spacing.

## Inline-style restriction

> **Required.** The "no off-token styling" rule the Lead Engineer agent enforces.
>
> Example: "No `style={{` in production code. Detected by `pnpm ds:guard`."

## i18n / copy authority

> **Required.** Where copy lives and who owns it.
>
> Example: "CBO owns `packages/shared/src/i18n/<locale>/system.json`. Lead Engineer wires keys, never edits strings. Translation TODOs surface as `[TranslationTodo <locale>]` placeholders."

## Env file path(s)

> **Required.** Where new env vars get documented.
>
> Example: `apps/storefront/.env.example`, `apps/admin/.env.example`, `apps/backend/.env.example`.

## Decision-log path

> **Required.** Where DRs land. Default `docs/decision-log/`.
>
> Filename format: `DR-YYYY-MM-DD-<feature>-g<N>-<role>.md`. Hard limit: 10 lines per DR.

## Telemetry log

> **Optional.** If you track per-gate token usage.
>
> Path: `docs/agent-runs.log`. Format: `<ISO-time>|<sprint>|<gate>|<agent>|<model>|<total_tokens>|<tool_uses>|<duration_ms>|<verdict>`.

---

## Section the agents will skip if absent

If your project has no multi-country / multi-tenant, no data residency, no migrations, etc., simply delete the section. The agents detect missing sections and treat them as no-ops. They do NOT prompt you to fill them in.

The only **required** sections are: Stack, Verify command, Decision-log path. Without these the agents cannot operate.
