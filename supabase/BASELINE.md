# Production database baseline runbook

## Goal

The tracked migration history starts at `20261012010341` and assumes core application objects already exist. A fresh database therefore cannot be rebuilt from the current migration directory alone.

The chosen strategy is a **current-production-state baseline**. The baseline is a schema-only snapshot of production at a recorded migration version. Historical migrations at or below that version become reference-only files under `supabase/migrations_legacy/`; migrations newer than that version remain executable and run after the baseline.

Do not prepend a current production dump and replay the full historical migration sequence. That can replay changes over objects already present.

## Safety rules

- Steps 1–4 below are read-only. Do not apply migrations, run `migration repair`, `db push`, or `db reset` against production.
- Do not commit `prod-schema.sql`, `buckets.sql`, database data, credentials, or secret values.
- Never use the partial Schema Visualizer export as a baseline. It is not a complete schema dump.
- Never run `supabase db reset` against production.
- Do not run the build script until the schema dump, ledger version, bucket row, extras, and migration inventory have been reviewed.
- The build script moves only migration files whose 14-digit version is less than or equal to the selected baseline version. Newer migrations remain in `supabase/migrations/`.

## 1. Record the production migration version (read-only)

Run in the Supabase SQL editor:

```sql
select max(version) as latest_applied_version
from supabase_migrations.schema_migrations;
```

At the time this runbook was prepared, the observed latest version was `20261112215507`. Re-run the query immediately before building; do not assume this value is still current.

**Important:** production currently has two repository migrations newer than the observed ledger version:
- `20261113000100_lock_student_quiz_rpc_execute_grants.sql`
- `20261113000200_enable_rls_password_reset_ip_limits.sql`

For the safest first baseline, export the current production state at the existing ledger version and leave these newer migrations in `supabase/migrations/`. They will run after the baseline on a fresh local rebuild. Do not apply the RLS migration early and then accidentally move the earlier pending migration into legacy. If the team deliberately chooses to apply pending migrations to production before the dump, apply them in ascending version order, re-read the ledger, and use the new maximum version.

## 2. Export schema only (read-only)

From the repository root, with the intended Supabase project linked. Supabase CLI v3 uses `--remote` for the linked hosted database; `--linked` is deprecated in v3 and removed in v4:

```bash
supabase db dump --remote -f supabase/baseline/prod-schema.sql
```

Use the schema-only default; do not add data flags. The generated dump is ignored by Git. The build script rejects common row-data statements and recognizable secret patterns, but that is a safety net, not a substitute for reviewing the dump.

## 3. Export the payment-proofs bucket row (read-only)

Run in the production SQL editor and save the single returned SQL statement locally as `supabase/baseline/buckets.sql`:

```sql
select format(
  'insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types) values (%L,%L,%L,%L,%L) on conflict (id) do update set name=excluded.name, public=excluded.public, file_size_limit=excluded.file_size_limit, allowed_mime_types=excluded.allowed_mime_types;',
  id, name, public, file_size_limit, allowed_mime_types
)
from storage.buckets
where id = 'payment-proofs';
```

The observed production row is private, has a 5 MB limit, and allows PDF plus common image formats. Use the exact query output, not a hand-written approximation.

## 4. Review objects outside the schema dump (read-only)

Run these queries in production and compare the results with `supabase/baseline/baseline_extras.sql` and `supabase/baseline/verify-baseline-extras.sql`:

```sql
select jobname, schedule, command from cron.job order by jobname;
select pubname, schemaname, tablename
from pg_publication_tables
where pubname = 'supabase_realtime'
order by schemaname, tablename;
select rolname, rolconfig from pg_roles where rolname = 'authenticator';
select extname, extversion
from pg_extension
where extname in ('pg_cron', 'pgcrypto', 'uuid-ossp');
select id, name, public, file_size_limit, allowed_mime_types
from storage.buckets
where id in ('payment-proofs', 'homework-submissions')
order by id;
```

The currently observed non-schema objects include:
- `cron.job`: `doma-student-reminders-daily`, schedule `0 7 * * *`, command `select public.doma_generate_all_student_reminders();`
- `authenticator` role setting: `pgrst.db_pre_request=public.doma_guard_temp_password`
- six `supabase_realtime` members: `mrfluent_english_course_requests`, `mrfluent_english_course_subscriptions`, `password_reset_requests`, `profiles`, `subscription_requests`, and `subscriptions`
- private buckets `homework-submissions` and `payment-proofs`

Review every cron command for embedded credentials before committing anything. Never copy secrets into the baseline.

## 5. Build the baseline on a branch

Use the exact version from step 1:

```bash
bash supabase/baseline/build-baseline.sh \
  --dump supabase/baseline/prod-schema.sql \
  --version <latest_applied_version> \
  --buckets supabase/baseline/buckets.sql \
  --with-seed --dry-run

bash supabase/baseline/build-baseline.sh \
  --dump supabase/baseline/prod-schema.sql \
  --version <latest_applied_version> \
  --buckets supabase/baseline/buckets.sql \
  --with-seed
```

The first command must be reviewed before running the second. It should list the historical migration files that will move and identify the baseline filename. Do not run this on `main`; use a review branch.

The generated baseline is `supabase/migrations/<version>_baseline.sql`. Historical files are moved to `supabase/migrations_legacy/` for reference only. Newer migration files remain in the active directory.

## 6. Verify on a clean local Supabase stack

This step is local only:

```bash
supabase start
supabase db reset
supabase/baseline/verify-baseline.sh supabase/baseline/prod-schema.sql
```

Then run `supabase/baseline/verify-baseline-extras.sql` against the local database and confirm it returns successfully. The schema diff compares dump-visible schema DDL; the extras check separately verifies the cron job, role setting, Realtime membership, extensions, and bucket rows that a schema-only dump does not fully represent.

Expected schema verification result:

```
OK: local schema matches the production schema dump.
```

Review any difference manually. Extension-owned definitions and harmless dump formatting may differ; unexplained differences in `public`, `private`, `storage`, RLS policies, grants, functions, or triggers are blockers. Do not proceed while any meaningful difference remains.

The hidden exercise tests in `private.programming_exercise_tests` are data and must not be copied into Git or the seed.

## 7. Reconcile the production migration ledger — gated

**Do not run this step until step 6 passes and the branch has been reviewed.** Prefer a disposable Supabase branch or isolated copy first.

The exact command list must be generated from the final migration inventory, not copied blindly. The intended operation is:
1. Mark every superseded historical version at or below the baseline version as reverted.
2. Mark the baseline version as applied.
3. Leave every migration newer than the baseline version in the ledger as pending until it is intentionally applied.

Then inspect:

```bash
supabase migration list
```

Local and remote columns must be understood and aligned. `migration repair` edits ledger records only; it does not create, modify, or verify schema objects. Never use it to hide a mismatch.

## 8. Merge and CI

Only after local rebuild and extras verification pass:
- merge the reviewed baseline branch;
- enable the Database rebuild workflow;
- ensure CI runs `supabase db reset`, `supabase db lint`, and the RLS/extras checks on changes under `supabase/`.

## After the baseline

- New schema changes go in new files under `supabase/migrations/` with versions later than the baseline.
- Keep `supabase/migrations_legacy/` as reference history; never replay it.
- Update the root README and `supabase/README.md` to describe the verified baseline.
- Update static validators to locate the programming performance migration in either the active or legacy directory after the squash.
- Keep generated schema dumps and bucket export files local and ignored.
