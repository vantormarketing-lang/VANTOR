-- Keep the password-reset rate-limit table inaccessible to API roles.
-- The SECURITY DEFINER function is owned by the table owner (postgres), so it
-- can continue managing rate-limit rows without granting direct table access.
alter table private.password_reset_ip_limits
  enable row level security;

revoke all privileges
  on table private.password_reset_ip_limits
  from public, anon, authenticated;
