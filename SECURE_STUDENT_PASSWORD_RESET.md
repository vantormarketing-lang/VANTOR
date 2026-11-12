# Secure student password recovery

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
