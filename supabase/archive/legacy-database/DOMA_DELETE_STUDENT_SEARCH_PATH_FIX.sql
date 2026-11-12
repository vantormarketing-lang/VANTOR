-- Applied to live Supabase to pin the privileged account-deletion helper's search path.
-- Its existing explicit staff and student-target checks are unchanged.
ALTER FUNCTION public.doma_delete_student(uuid)
SET search_path TO pg_catalog, public, auth;
