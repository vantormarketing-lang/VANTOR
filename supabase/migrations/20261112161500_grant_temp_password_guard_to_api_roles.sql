-- Allow the PostgREST API roles to execute the password-change guard.
-- The guard only rejects requests carrying must_change_password=true.
GRANT EXECUTE ON FUNCTION public.doma_guard_temp_password() TO anon, authenticated;
