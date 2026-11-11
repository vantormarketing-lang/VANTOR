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

- Three tables have RLS enabled but no policies: `public.doma_battle_session_answers`, `public.doma_battle_sessions`, and `public.subscription_renewal_history`.
- The advisor reports 62 SECURITY DEFINER functions executable by the `authenticated` role. This is a warning to review, not proof that all 62 functions are exploitable: each function body and its authorization checks must be inspected before changing grants or security mode.

### Performance

- Two foreign keys are reported without covering indexes:
  - `programming_course_payment_requests.reviewed_by`
  - `programming_lesson_progress.lesson_id`
- Four RLS policies are reported as repeatedly evaluating auth/current-setting functions per row. Review the policies and consider the documented `(select auth.uid())` / `(select auth.<function>())` form where appropriate.
- The advisor also lists unused indexes. Do not drop indexes based on a single advisor snapshot; first review query patterns and sufficient usage history.

## Changes made on the working branch

- Added `scripts/validate-production-safety.mjs` with static checks for browser-exposed Supabase secret literals, server-side session validation in the Cloudflare code runner, student/admin PWA caching boundaries, private homework attachment links, and baseline response headers.
- Added the new static safety script to `.github/workflows/validate-platform.yml`.

These checks are static source checks only. They do not contact the deployed site or database.

## Next implementation sequence

1. **Complete Phase 1 source review:** inspect the reported SECURITY DEFINER function bodies, table policies, Storage policies, Cloudflare Pages Functions, and current GitHub Actions results. Do not change production permissions until the intended access model is confirmed.
2. **Auth and signup:** trace the existing signup, verification, session restoration, and profile creation paths; change only a confirmed defect.
3. **Subscriptions and receipts:** trace grade, English-course, and Kids request flows, file validation, private storage, approval, expiry, and entitlement checks.
4. **Student learning:** review the student dashboard and lesson routing against the approved UI decisions; then implement any confirmed gaps in a separate change set.
5. **Admin operations:** review staff authorization and the admin request/student workflows before UI or RPC changes.
6. **PWA and performance:** preserve the current separate app identities and caching boundaries; measure and optimize only identified bottlenecks.
7. **Security hardening:** address each advisor finding with function-by-function and policy-by-policy review, then run advisors again.

## Acceptance rules

- No unreviewed changes to production database policies, functions, data, or secrets.
- No deployment or merge to `main` without review.
- The owner performs live-site login, subscription, receipt, lesson, and mobile/PWA checks.
- Static CI results are reported separately from live-site verification.
