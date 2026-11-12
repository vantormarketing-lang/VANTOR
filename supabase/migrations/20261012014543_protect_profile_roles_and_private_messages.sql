CREATE OR REPLACE FUNCTION public.doma_is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = (SELECT auth.uid())
      AND lower(coalesce(p.role, '')) = 'admin'
  );
$$;

REVOKE ALL ON FUNCTION public.doma_is_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.doma_is_admin() TO authenticated;

CREATE OR REPLACE FUNCTION public.doma_prevent_unauthorized_role_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role
     AND NOT public.doma_is_admin() THEN
    RAISE EXCEPTION 'Only an admin can change account roles'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.doma_prevent_unauthorized_role_change() FROM PUBLIC;
DROP TRIGGER IF EXISTS doma_prevent_unauthorized_role_change ON public.profiles;
CREATE TRIGGER doma_prevent_unauthorized_role_change
BEFORE UPDATE OF role ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.doma_prevent_unauthorized_role_change();

DROP POLICY IF EXISTS "Allow public message reads" ON public.messages;
