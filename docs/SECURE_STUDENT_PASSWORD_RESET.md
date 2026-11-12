# Secure student password recovery and reset

This document consolidates the student phone-recovery flow, admin-issued temporary passwords, Auth configuration, server environment requirements, and database session guard.

## Request flow

1. The student submits their Egyptian mobile number to `/api/student/request-password-reset`.
2. The Cloudflare Pages Function normalizes the phone number and uses Cloudflare's `CF-Connecting-IP` header as the server-controlled IP key.
3. The IP quota is **30 requests per 15-minute window**. A separate per-phone quota allows at most **3 requests per 15 minutes**.
4. A request is stored in `public.password_reset_requests`. Unknown numbers receive the same public success response to avoid account enumeration.
5. An administrator reviews the request and, when appropriate, issues a temporary password through the approved admin workflow.
6. The temporary-password flag is stored in Auth `app_metadata.must_change_password`, not editable `user_metadata`.
7. After signing in, the student must choose a new password through `/api/student/complete-password-reset`. The server verifies the bearer session, checks the app-metadata flag, updates the password through the Auth Admin API, and clears the flag.

## Database session guard

Migration `20261112030949_doma_guard_temporary_password_sessions.sql` defines `public.doma_guard_temp_password()` and configures:

```sql
alter role authenticator set pgrst.db_pre_request = 'public.doma_guard_temp_password';
notify pgrst, 'reload config';
```

The pre-request hook checks the verified JWT's `app_metadata.must_change_password` claim and rejects Supabase **Data API** requests while the temporary-password flag is true. The password-change endpoint uses the Auth API, so the student can still complete the required password change.

Important scope: `pgrst.db_pre_request` applies to PostgREST Data API requests. It does not automatically guard Realtime or Storage; those services need their own authorization policies.

## Rate limiting

The request endpoint uses two independent server-side limits:

- IP: 30 attempts per 15 minutes, tracked in `private.password_reset_ip_limits`.
- Phone: 3 attempts per 15 minutes, checked against recent reset requests.

The IP is read from `CF-Connecting-IP`; do not accept a caller-supplied IP value from the request body. The database RPC `doma_allow_password_reset_ip(text)` is executable only by `service_role`.

## Cloudflare configuration

The request and completion functions require:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Set these as server-side Cloudflare Pages environment variables for Production and Preview as appropriate. **Never expose the service-role key in HTML, browser JavaScript, public configuration, or Git.**

## Security notes

- Keep public responses generic; do not reveal whether a phone number belongs to a student.
- Do not log passwords, temporary passwords, bearer tokens, or service keys.
- Keep `must_change_password` in `app_metadata`; users can edit `user_metadata`.
- Review rate-limit behavior after changes to school/mobile-carrier network patterns.
- Verify both the normal student flow and the temporary-password blocked flow after deployment.

---

## Cloudflare deployment configuration and Auth redirect setup

The password-reset endpoints run as Cloudflare Pages Functions and require a server-only Supabase credential.

## Required Cloudflare environment variables

In Cloudflare Dashboard:

1. Open Workers & Pages and select the doma-academy Pages project.
2. Open Settings → Variables and Secrets.
3. Add the following for both Production and Preview environments:
   - SUPABASE_URL — https://dtptxhkcogpoleftguas.supabase.co
   - SUPABASE_SERVICE_ROLE_KEY — the Supabase project's server-side service-role key (or compatible Supabase secret key).
4. Save the settings and redeploy the latest production deployment.

Never put SUPABASE_SERVICE_ROLE_KEY in HTML, JavaScript shipped to browsers, GitHub, or a public environment variable. Do not send the key in chat.

## How the flow works

- Only a signed-in account whose profiles.role is exactly admin can call the admin reset endpoint.
- The endpoint verifies the selected account is a student, generates a cryptographically random 10-character temporary password, updates Supabase Auth, and sets the protected app_metadata.must_change_password flag.
- The temporary password is returned only in the immediate response. It is not written to the database or server logs.
- At the next sign-in, the student is held at the password-change screen until the new password is saved through the server endpoint.
- The login-page Forgot password? action opens a prefilled WhatsApp message. The administrator must verify the student's identity before issuing a temporary password.
- Student phone-recovery requests are routed to the support WhatsApp number `+20 100 652 5147` (`https://wa.me/201006525147`). This is a manual support channel, not an OTP verification service.

## Email recovery and redirect allow-list

- The admin login now includes **Forgot password?**. It sends a Supabase recovery email and opens a secure password-change form when the recovery link returns to `admin.html`.
- Student accounts that have a real email address can use the login-page **Forgot password?** link. The recovery link opens a secure password-change form on the student site.
- In Supabase Dashboard → Authentication → URL Configuration, add the production URLs to the Redirect URLs allow-list:
  - `https://doma-academy.pages.dev/`
  - `https://doma-academy.pages.dev/admin.html`
- Add equivalent preview/custom-domain URLs only if those environments are used. Keep the Site URL set to the primary production site.

## OTP note

Student accounts currently use internal .invalid email aliases with Supabase Email/Password Auth. That means SMS/WhatsApp OTP recovery cannot work until a real SMS/WhatsApp verification provider and a verified delivery flow are configured. The current WhatsApp path deliberately does not claim that an OTP was sent. For phone-only students, the flow opens a WhatsApp request; an administrator must verify the student before using the admin-only temporary-password reset action.
