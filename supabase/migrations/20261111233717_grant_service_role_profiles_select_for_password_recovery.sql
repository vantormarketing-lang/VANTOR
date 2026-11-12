-- Permit trusted server-side recovery to look up the student's profile.
grant select on table public.profiles to service_role;