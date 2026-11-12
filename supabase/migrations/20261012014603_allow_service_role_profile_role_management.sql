CREATE OR REPLACE FUNCTION public.doma_prevent_unauthorized_role_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role
     AND coalesce(auth.role(), '') <> 'service_role'
     AND NOT public.doma_is_admin() THEN
    RAISE EXCEPTION 'Only an admin can change account roles'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.doma_prevent_unauthorized_role_change() FROM PUBLIC;
