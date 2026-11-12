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

## Local rebuild status — 2026-11-13

**A clean rebuild from this repository is not currently verified and must not be described as reproducible.** The first tracked migration (`20261012010341`) alters existing application objects but the migration history does not establish the original schema for core tables such as `profiles`, `grades`, `lessons`, `quizzes`, `homework`, `subscription_requests`, and `school_subscriptions`. Those objects exist in production, but their original creation is not represented in the tracked migration sequence.

Until a reviewed baseline/squash is committed:

- Do not use `supabase db reset` as evidence that a fresh environment can be built.
- Do not add a CI reset step that is expected to pass; it will expose the missing baseline rather than validate a complete rebuild.
- Do not prepend a dump of the *current* production schema and then replay every historical migration unchanged. That would apply later changes on top of objects already present in the dump and can fail or change policy/function behavior.
- Do not run `supabase migration repair` merely to silence a mismatch. It changes migration history only; it does not create, modify, or validate schema objects.

The baseline strategy must be selected after reviewing a schema-only production export and the complete migration ledger:

1. Prefer a true pre-first-migration baseline if a reliable historical schema export exists; then retain and replay the ordered migrations.
2. Otherwise, use a reviewed current-state squash: capture the current schema, move superseded historical migrations out of the executable directory, and reconcile the production migration ledger only after comparing the dump with the live schema and planning rollback/recovery.
3. Include the Programming Academy payment/subscription schema and RPCs in the baseline, or reconstruct them at their dependency-correct point. The archived SQL references `programming_lessons`, `programming_modules`, `programming_tracks`, and `programming_lesson_progress`, so it cannot simply be moved ahead of the Programming Academy foundation migration. The code-runner migration that grants access to `programming_course_subscriptions` must remain after that table is created.
4. Verify from a clean local Supabase stack with `supabase start` and `supabase db reset`, then run the same reset in CI before treating staging rebuilds as supported.

Never use `db reset` on production. Do not use `db push` against production until the local migration list, production ledger, and current schema have been compared and reviewed.
