# Production database and migration reconciliation — 2026-11-19

## Current production snapshot
- Project: `dtptxhkcogpoleftguas`
- PostgreSQL: 17.6.1.166
- Latest inventory: `supabase/baselines/production-schema-inventory-2026-11-19-after-reconciliation.json`
- Snapshot is metadata-only: columns, defaults, constraints, indexes, RLS flags, policies, function signatures/hashes, and migration history. It contains no student/payment rows.
- Snapshot totals: 93 tables, 202 policies, 90 functions, 117 migration versions.

## Migration ledger reconciliation
- Repository contains 176 migration files.
- Production migration history contains 117 versions.
- No production-only migration versions remain without a source file in the repository.
- 59 repository migration files remain unrecorded in production. All 59 are dated 2026-11-17 and are curriculum/content updates.
- The 13 production-only migration records found in the first audit were recovered from `supabase_migrations.schema_migrations.statements` and restored as exact SQL files under `supabase/migrations/`.
- Exact/semantic duplicate groups identified and retained as immutable history:
  - `20261112215442` and `20261112170000` — exact same SQL.
  - `20261112215507` and `20261112170500` — exact same SQL.
  - `20261116020333` and `20261116010000` — exact same SQL.
  - `20261116174028` and `20261116000000` — exact same SQL.
  - `20261116174219` and `20261116000001` — exact same SQL.
  - `20261116174654` and `20261116000002` — exact same SQL.
  - `20261116175109` and `20261116000003` — exact same SQL.
  - `20261112141258` and `20261112161500` — same GRANT operation; later file adds explanatory comments.
- Historical files and migration rows were not deleted. Rewriting or deleting already-applied migrations would make future reconciliation less reliable.

## Versions reconciled after live-state verification
The following 18 local migration versions were added to the production migration ledger without replaying their SQL, because their exact statements or resulting live state were verified:
- `20261112161500`, `20261112170000`, `20261112170500`, `20261113000100`
- `20261116000000`, `20261116000001`, `20261116000002`, `20261116000003`, `20261116010000`
- `20261117090000`, `20261117090100`, `20261117090200`, `20261117090300`, `20261117090400`, `20261117090500`
- `20261113000200`, `20261119010000`, `20261119020000`

The migration-history inserts use `created_by` markers such as `verified_live_schema_reconciliation`; this documents that the existing live state was checked instead of re-running the migration. The original SQL is stored in the `statements` column.

## Security migrations applied and verified
- `20261113000200`: enabled RLS on `private.password_reset_ip_limits` and revoked direct table privileges from public/anon/authenticated. The existing IP limiter is SECURITY DEFINER, owned by postgres, and continues to manage the private table.
- `20261119010000`: created the phone-digest rate-limit table and service-role-only RPC `public.doma_allow_password_reset_phone(text)`. RLS is enabled; direct API-role table access is revoked.
- `20261119020000`: created service-role-only `public.doma_refund_assistant_quota(uuid)`, sharing the consume RPC's UTC-day advisory lock.
- Verification confirmed both new RPCs exist and their EXECUTE grants are limited to postgres/service_role.

## Programming curriculum merge — verified live state
- 5 canonical tracks are published: Computer Science, Programming Languages, Web Development, Databases/Backend, and Projects/AI/Modern Technology.
- 17 canonical modules are assigned to those tracks, plus a separate `cs-daily-challenges` module.
- 21 daily-challenge lessons are assigned to that separate module, which is unpublished in the normal module list.
- The graduation capstone lesson is assigned to `project-foundations`.
- 8 legacy track rows remain in the database but are unpublished; they were not deleted.
- Current totals: 13 track rows, 18 modules, 146 lessons (125 published), 146 exercises, 114 quizzes, and 566 quiz questions.
- The live database shows all 146 lessons and 106 exercises updated during 2026-11-17. This is strong evidence that the remaining curriculum content batch was applied manually, but it is not sufficient by itself to mark every remaining migration as applied. Those 59 files still need a content-by-content comparison before their history can be repaired.

## Remaining migration work
- 59 curriculum migrations dated 2026-11-17 remain unrecorded. Do not replay them as a batch: many update lesson/exercise text and could overwrite newer live content.
- Compare each migration's target rows and expected final content with the live rows; only then record the exact version as already applied or apply a genuinely missing change.
- The 59-file set starts at `20261117090600_restore_original_seeded_lesson_content.sql` and ends at `20261117220000_add_fullstack_capstone_project.sql`.

## Security advisor findings after the security migrations
- The new phone limiter and quota refund RPCs are not flagged for anon/authenticated execution.
- Supabase still reports an anon-executable SECURITY DEFINER function: `public.doma_guard_temp_password()`. It is intentionally granted to API roles by a migration, but its body and intended public call path should be reviewed before changing that grant.
- Supabase also reports 69 authenticated-executable SECURITY DEFINER functions, 9 RLS-enabled tables with no policies, and leaked-password protection disabled. These need separate function-by-function and table-access review; do not apply a blanket revoke/policy.
- RLS-enabled private tables without policies may be intentional when no API roles have table privileges. Verify grants before changing them.

## Not completed
- No legacy assets were deleted; a complete reference scan and review is still required.
- This inventory is a schema metadata snapshot, not a full SQL dump or a restore-tested baseline.
- No live Cloudflare browser smoke test was performed. GitHub commits do not prove `https://doma1.pages.dev/` is updated.
