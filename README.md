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
