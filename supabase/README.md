# Supabase database workflow

## Canonical migration source

**Only `supabase/migrations/` is the canonical, ordered schema-change source.** Every migration file is named with its database version followed by a descriptive name. The tracked history is reconstructed from the database migration ledger and should remain aligned with the production `supabase_migrations.schema_migrations` versions.

When adding a schema change:
1. Create a new timestamped migration file in `supabase/migrations/`.
2. Review the SQL, especially RLS, grants, SECURITY DEFINER functions, triggers, and storage policies.
3. Apply it to a development/staging database first.
4. Verify the intended behavior with SQL checks and the platform validators.
5. Apply to production only after review and backup/rollback planning.

Do not edit old applied migrations to change production behavior. Add a new forward migration instead.

## Reference-only SQL

- `supabase/archive/`: archived SQL kept for historical context; not replayed by Supabase CLI.
- `supabase/snapshots/`: point-in-time schema/RPC/content snapshots for inspection and recovery; not migrations.
- `database/`: legacy manually-run SQL scripts. These are reference-only and are not the canonical source. Before reusing any of them, locate the equivalent migration or create a reviewed new migration.

The repository root also has a README linking back to this policy.

## Local rebuilds

A local `supabase db reset` replays the ordered files in `supabase/migrations/`. It does not execute files in `archive/`, `snapshots/`, or `database/`.

Never use `db reset` on production. Do not use `db push` against production until the local migration list, production ledger, and current schema have been compared and reviewed.
