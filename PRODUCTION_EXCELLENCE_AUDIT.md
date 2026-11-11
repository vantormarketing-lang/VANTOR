# DOMA Production Excellence — Initial Audit

**Audit date:** 2026-11-11  
**Repository:** `vantormarketing-lang/VANTOR`  
**Production Supabase project:** `VANTOR` (`dtptxhkcogpoleftguas`)  
**Working branch:** `production-excellence/phase-1-audit`

## Scope and safety boundary

This is a source/configuration and read-only Supabase metadata review. No deployed website was opened, no student/admin login was attempted, no production data was changed, and no database migration or deployment was applied. The owner will perform the live-site checks.

## Existing foundations found in the repository

- A shared Purple + Champagne Gold glassmorphism stylesheet already exists at `doma-platform-purple-gold-glass.css`.
- Separate student and admin PWA manifests/service workers already exist.
- The student service worker normalizes app-shell routes, excludes sensitive query parameters, and limits runtime caching to safe same-origin static assets.
- The admin service worker fetches the admin HTML from the network and caches only allowlisted shell assets.
- The repository already has two GitHub Actions validation workflows and a substantial platform-specific static validation script.
- Homework attachments are intended to remain private; the student UI is checked against public-URL access and the admin UI uses short-lived signed URLs.
- The English course pages A1–C2 and Kids course runtime are already present.

These are source-level observations, not proof that the deployed experience currently behaves correctly.

## Read-only Supabase advisor findings

The Supabase project reports an active/healthy status. Its advisors returned the following items for review:

### Security

- Three tables have RLS enabled but no policies: `public.doma_battle_session_answers`, `public.doma_battle_sessions`, and `public.subscription_renewal_history`. A read-only privilege check found no direct table privileges for `anon` or `authenticated`; the tables are effectively closed to client roles. Do not add broad policies just to silence the advisor.
- The advisor reports 62 SECURITY DEFINER functions executable by the `authenticated` role. A read-only screening found no `anon` execution grants; all 62 have an explicit function `search_path` and an auth/user/staff guard pattern in their bodies. This is an encouraging first pass, not a substitute for manual review of each function's authorization logic and callable inputs.

### Performance

- Two foreign keys are reported without covering indexes:
  - `programming_course_payment_requests.reviewed_by`
  - `programming_lesson_progress.lesson_id`
- Four programming-course RLS policies were identified: student progress SELECT and staff ALL policies on lessons, modules, and tracks. Their direct `auth.uid()` calls can use the scalar-subquery form `(select auth.uid())`.
- Read-only index inspection confirmed that `programming_course_payment_requests.reviewed_by` has no index. `programming_lesson_progress` has a composite primary key beginning with `user_id`, but no leading index on `lesson_id`; the composite key does not efficiently cover lookups by `lesson_id` alone.
- The advisor also lists unused indexes. Do not drop indexes based on a single advisor snapshot; first review query patterns and sufficient usage history.

## Changes made on the working branch

- Added `scripts/validate-production-safety.mjs` and wired it into `.github/workflows/validate-platform.yml`. It checks browser-facing secrets, server-side session validation, student/admin PWA caching boundaries, private homework attachment links, security headers, admin theme/cache version alignment, grade-approval persistence verification, and the prepared programming migration.
- Fixed the admin PWA's stale theme cache reference: the HTML loaded `doma-glass-v70`, while the service worker cached `doma-glass-v65`. The worker cache and registration were advanced to v71 and its theme asset URL now matches v70.
- Hardened grade-subscription approval feedback: the admin now verifies the persisted request status is `approved` before displaying success, matching the existing English-course approval pattern.
- Added `mrfluent-course-workspace.js` to the A1–C2 course pages: each lesson now has a separate lesson route, and the lesson workspace includes a pointer/touch whiteboard, pen colors, eraser, undo, clear, and local notes saved per level/lesson on the current device.
- Added the lesson workspace to the student PWA shell, aligned the asset URL, and advanced the student worker/manifest/registration version from v236 to v237.
- Added CI checks for the six course-page integrations and JavaScript syntax. These are static checks; the lesson route and drawing experience still require the owner's live browser check.
- Added `supabase/migrations/20261111010000_optimize_programming_rls_and_fk_indexes.sql` with two non-destructive FK indexes and the four scalar-subquery RLS policy optimizations. The migration is committed to this branch only and has **not** been applied to Supabase production.
- Confirmed the existing grade, English-course, and Kids receipt flows enforce a 5 MB file limit and use private payment-proof storage paths.

These checks are static source checks only. They do not contact the deployed site or database. The migration file is a reviewed proposal until explicitly applied to the intended database.

## Next implementation sequence

1. **Auth and signup:** the current student signup uses a phone-derived alias email. If Supabase email confirmation is enabled, signup can create an Auth user without a session; the UI explicitly reports that email confirmation must be disabled for this alias-based flow. The project Auth setting must be confirmed by the owner before changing this design or enabling SMS OTP.
2. **Subscriptions and receipts:** client-side code already enforces 5 MB receipts and uses the private `payment-proofs` bucket. Grade approval now verifies persisted status. Live receipt upload, approval, expiry, and entitlement checks remain owner-tested.
3. **Student learning:** the English A1–C2 and Kids runtimes already exist. Review the dashboard and lesson routing against the approved UI decisions; change only gaps confirmed in source review or by the owner.
4. **Admin operations:** staff startup verifies the signed-in profile and restricts access to `admin` / `teacher`; approval flows should continue to verify persisted results.
5. **PWA and performance:** admin theme/cache versions are aligned; retain separate app identities and network-only admin HTML. Run the prepared SQL migration only after review and approval.
6. **Security hardening:** manually inspect the 62 SECURITY DEFINER function bodies and Storage policies; the three RLS-closed tables should remain closed unless a documented client workflow requires access.
7. **Live acceptance:** the owner tests signup, subscriptions, receipt upload, student lessons, admin approvals, and installed PWAs. Static CI is not a substitute for these checks.

## Acceptance rules

- No unreviewed changes to production database policies, functions, data, or secrets.
- No deployment or merge to `main` without review.
- The owner performs live-site login, subscription, receipt, lesson, and mobile/PWA checks.
- Static CI results are reported separately from live-site verification.
