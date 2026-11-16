# DOMA Academy / VANTOR

This repository contains the DOMA learning platform, student-facing course pages, Cloudflare Pages Functions, and Supabase database migrations.

## Deployment

- Production branch: `main`
- Hosting: Cloudflare Pages
- Static site output: repository root
- Server-side API handlers: `functions/api/`

Keep server secrets in Cloudflare Pages environment variables only. Never put a Supabase service-role key in browser JavaScript, HTML, or committed files.

## Database source of truth

The canonical, ordered database change history is `supabase/migrations/`. Read [supabase/README.md](supabase/README.md) before changing the database.

**Rebuild limitation:** the tracked history currently lacks the initial schema baseline for legacy core tables. A clean `supabase db reset` is not yet verified; follow the rebuild-status section in `supabase/README.md` and do not assume a fresh staging database can be created from this repo today.

The `supabase/archive/`, `supabase/snapshots/`, and legacy `database/` SQL files are retained for historical reference. They are not automatically executed and must not be replayed against production as a batch.

## Validation

GitHub Actions runs the platform validators on pushes to `main`. A successful static validation does not replace testing the deployed site with real student, staff, and subscription states.

## Important Cloudflare environment variables

Set these in Cloudflare Pages for the environments that need them:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY` (only for server handlers that explicitly need it)
- `SUPABASE_SERVICE_ROLE_KEY` (server-side only; never expose it to the browser)
- `JUDGE0_URL` (for code execution)
- `JUDGE0_AUTH_TOKEN` and optional `JUDGE0_AUTH_HEADER` / `JUDGE0_AUTH_HOST` when required by the Judge0 provider

## Programming Academy AI study assistant

The Programming Academy tutor uses the Cloudflare Workers AI binding through the Pages Function at `/api/assistant`.

Cloudflare Pages setup (Production and Preview environments as needed):
1. Open the Pages project settings, then the target environment's Bindings.
2. Add a Workers AI binding with the variable name **AI**.
3. Redeploy the Pages project so the binding becomes available to Functions.

The Function also reads **SUPABASE_URL**, **SUPABASE_ANON_KEY**, and **SUPABASE_SERVICE_ROLE_KEY** from server-side Pages environment variables. The service-role key must remain server-side and must never be added to browser code.

The initial model is **@cf/zai-org/glm-4.7-flash**. The database-backed quota is 10 requests per student per UTC day and 150 requests across the platform per UTC day. Only authenticated students with an active Programming Academy subscription and DOMA staff can use the endpoint. The local rule-based tutor remains available as a fallback.

The student is informed before sending that the question and a short lesson excerpt are processed by Cloudflare; code is included only when the student selects code explanation or debugging. The Function does not log question or code content. A quota reservation is consumed before inference to protect the platform cap, so an inference-provider failure after reservation can still count as one request.

Workers AI's free daily Neurons allocation is a usage allowance, not a fixed number of questions; actual consumption depends on model and token use. Check Cloudflare's current pricing before enabling broad access.

The migration file in this branch is a code change only. **It has not been applied to Supabase production.** Review and apply it to a development/staging database first, then consider production only through the normal migration approval and backup process.
