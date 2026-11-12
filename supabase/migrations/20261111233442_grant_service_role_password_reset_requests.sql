-- Permit the trusted server-side password recovery endpoint to access reset requests.
grant select, insert, update, delete on table public.password_reset_requests to service_role;