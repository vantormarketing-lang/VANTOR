# Production database and migration audit — 2026-11-19

## Snapshot created
- Production project: `dtptxhkcogpoleftguas`
- PostgreSQL: 17.6
- Inventory: `supabase/baselines/production-schema-inventory-2026-11-19.json`
- Snapshot contains schema metadata only (no student/payment data): tables/columns/defaults/constraints/indexes, RLS flags, policies, function signatures and definition hashes, and migration history.
- Snapshot totals: 92 tables, 202 policies, 88 functions, 99 recorded migrations.

## Migration history drift
- Repository currently contains 163 migration files.
- Production records 99 migration versions.
- 77 repository migrations are not recorded in production.
- 13 production migration versions have no matching file in the repository:
  - 20261112141258
  - 20261112215442
  - 20261112215507
  - 20261116020333
  - 20261116174028
  - 20261116174219
  - 20261116174654
  - 20261116175109
  - 20261116180440
  - 20261116181406
  - 20261116182317
  - 20261116183050
  - 20261116193607
- Do not run the 77 pending files as a batch or rewrite the historical migrations until this drift is reconciled. Some pending changes appear to already exist in the live schema, so blindly rerunning them could overwrite live curriculum content or fail on pre-existing objects.
- Exact duplicate migration blobs: none detected. This does not rule out semantic overlap between different lesson-content migrations.

## Verified live-schema facts
- `public.profiles.is_suspended` already exists; no new migration is needed for that column.
- `private.doma_assistant_usage` and `public.doma_consume_assistant_quota(uuid)` exist.
- `public.doma_refund_assistant_quota(uuid)` does not exist yet.
- `private.password_reset_phone_limits` and `public.doma_allow_password_reset_phone(text)` do not exist yet.
- `private.password_reset_ip_limits` exists with RLS disabled. The repository has a pending migration `20261113000200_enable_rls_password_reset_ip_limits.sql`, but it was not applied during this audit. Supabase's security guidance says not to enable RLS blindly without checking the table's access path and policies.
- Programming curriculum currently has 13 track rows and 18 module rows. The five canonical tracks and 17 canonical modules expected by the reorganization migration are already present; one additional module, `cs-daily-challenges`, also exists.

## Old-file cleanup review
- Still present: `auth-photo-v95/`, `auth-photo-v96/`, `doma-leaf-book-icon.svg`, `mr-fluent-growth-chart-glass.svg`, `programming-academy-design20.css`, `programming-academy-neon-library.svg`, `programming-academy-botanical.svg`.
- `doma-m-a-selected-icon.png` is absent from the current repository tree.
- No files were deleted. A complete reference scan is still required before removing the remaining assets.

## Deployment verification
- This audit did not verify a live Cloudflare deployment.
- GitHub commits and GitHub Actions validation do not prove that `https://doma1.pages.dev/` has received the changes.

## Safe next sequence
1. Reconcile the 13 remote-only migration versions and 77 local-only versions against the live schema inventory.
2. Resolve the RLS-disabled password-reset table with an access-path review, then apply the intended hardening migration.
3. Confirm the two November 19 migrations against the live RPC definitions, then apply and verify them in chronological order.
4. Consolidate only genuinely overlapping, unapplied curriculum changes; preserve every migration already recorded in production.
5. Complete a repository-wide reference scan before deleting any legacy assets.
6. Run the Cloudflare production smoke test separately from GitHub Actions.
