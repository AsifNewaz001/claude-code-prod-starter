# PROJECT_CONTEXT.md — Brand X filled-in example

This is the actual `PROJECT_CONTEXT.md` for Brand X (Bangladesh + Australia + Canada + Russia DTC storefront). Use it as a reference when filling in your own.

---

## Project name + one-line description

Brand X — multi-country DTC storefront serving BD/RU/AU/CA.

## Stack

Next.js 15 (App Router) + Postgres on Neon (BD/AU/CA) + Yandex Cloud Postgres (RU per 152-FZ) + Typesense + Cloudflare R2. Auth via Clerk (stub mode pre-launch). Payment per country: bKash/Nagad/SSLCommerz (BD), YooKassa (RU), Stripe + Afterpay (AU), Stripe + Interac (CA). Backend Medusa (deployed separately). Storefront talks Postgres directly via `withCountry()`; Medusa handles cart/checkout.

## Repository layout

- `apps/storefront/` — customer-facing Next.js app (one deploy per country: brand-x-bd/brand-x-au/brand-x-ca/brand-x-ru)
- `apps/admin/` — backoffice Next.js app
- `apps/backend/` — Medusa server
- `packages/db/` — schema + migrations + tenancy helpers (`withCountry`, `withRu`)
- `packages/shared/` — types, mocks, i18n, CMS section types
- `packages/ui/` — design system (Section, Heading, Card, Price, etc.)
- `packages/payments/`, `packages/shipping-*` — per-country adapter packages
- `docs/` — RFCs, decision-log, sprint folders

## Tenancy

- **Tenant key column:** `country_id` (`'BD' | 'AU' | 'CA' | 'RU'`).
- **Tenancy helper function:** `withCountry(country, fn)` at `packages/db/src/pool.ts:88`. Sets `app.country_id` session variable inside a transaction; RLS reads it.
- **Pattern enforcement lint:** `pnpm db:rls-lint` — verifies every country-scoped table has `ENABLE+FORCE RLS` + `country_isolation` policy + (where applicable) cross-table tenant trigger. Currently 59 migrations, 100% pass.
- **Cross-tenant test pattern:** `packages/db/__tests__/cross-tenant-leak.test.ts` — every new query path on a tenant-scoped table extends this.
- **Defense-in-depth:** every SQL query on a tenant-scoped table includes an explicit `WHERE country_id = $1` predicate, even when RLS is in place. The runtime role on Neon is `neondb_owner` which has `BYPASSRLS=true`, silently neutralizing FORCE RLS at the table layer. The explicit predicate is the only defense that survives that — REQUIRED on every query.

## Data residency

- RU customer/order/audit data MUST stay on Yandex Cloud (Moscow region, ru-central1) per 152-FZ.
- `withCountry('RU')` resolves `DATABASE_URL_RU`; `BD/AU/CA` resolve `DATABASE_URL`.
- RU connection asserts schema parity vs Neon on first connection per process (`assertSchemaParity` in `packages/db/src/version-guard.ts`).
- Unset `DATABASE_URL_RU` on RU deploy = `RU_DB_NOT_CONFIGURED` thrown at request time. No silent fallback across the residency boundary.
- Analytics adapters (GA4, Clarity, GrowthBook) have RU kill-switches default OFF; flip ON only after Legal sign-off + Yandex Cloud egress wired.

## Cost

- **Hard threshold:** $200/month delta on any single infra add.
- ROI calculation included in the architecture DR for any add above $100/month.

## Verify command

```
pnpm typecheck && pnpm lint && pnpm ds:guard && pnpm test && pnpm db:rls-lint
```

All must be green before any commit ships. Pre-existing CI startup_failure on the pipeline is tracked separately in HANDOFF.md.

## Migration tool

`pnpm db:migrate` runs `packages/db/migrations/NNNN_<name>.sql` files in order (currently at 0059). Each migration:
- Wraps in `BEGIN/COMMIT`
- Uses `IF NOT EXISTS` + `ON CONFLICT DO NOTHING`
- Forward-only (no `.down.sql`)
- Idempotent re-run = no-op
- Tenant tables get `ENABLE+FORCE RLS` + `country_isolation` policy

`pnpm db:migrate:ru` applies the same set to Yandex; CI `pnpm db:check-sync` enforces parity.

## Sprint scope discipline

No `ALTER TABLE` outside the sprint that owns the schema. Sprint 18 cannot mutate `categories`; that's Sprint 19. Sprint 19 cannot reach into Sprint 20's CMS write-path territory. `version` columns / optimistic locking only land in the sprint that ships the write endpoint.

## Design system

- `docs/design-system.md` — palette (7 tokens), spacing (4/8/12/16/24/32/48/64/96/128), typography (6 roles: display, heading-lg, heading-md, body, label, caption), aspect ratios.
- `pnpm ds:guard` — fails the build on `style={{`, off-token colors, off-scale spacing, hardcoded hex.
- Reference benchmark: Quince.com. Parity floor: 7.4/10.

## Inline-style restriction

No `style={{` in production code under `apps/storefront/src/` or `apps/admin/src/`. Detected by `pnpm ds:guard`.

## i18n / copy authority

- CBO owns `packages/shared/src/i18n/<locale>/system.json` for `<locale>` in `{en, en-AU, en-CA, bn-BD, ru-RU, fr-CA}`.
- Lead Engineer wires keys, never edits strings.
- Translation TODOs surface as `[TranslationTodo <locale>]` placeholders.
- BD seeds in English (Bangla translator workstream still open).
- RU seeds in English (Russian translator workstream still open).

## Env file path(s)

- `apps/storefront/.env.example`
- `apps/admin/.env.example`
- `apps/backend/.env.example`

Every new env var documented in the matching `.env.example` with one-line purpose comment.

## Decision-log path

`docs/decision-log/`. Filename: `DR-YYYY-MM-DD-<feature>-g<N>-<role>.md`. Hard limit: 10 lines per DR.

## Telemetry log

`docs/agent-runs.log` (gitignore exception in place). Format:

```
<ISO-time>|<sprint>|<gate>|<agent>|<model>|<total_tokens>|<tool_uses>|<duration_ms>|<verdict>
```

First weekly budget review: 2026-05-09.
