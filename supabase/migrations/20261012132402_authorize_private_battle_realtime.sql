CREATE OR REPLACE FUNCTION public.doma_is_battle_participant(p_room_code text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog','public'
AS $function$
  SELECT auth.uid() IS NOT NULL
     AND EXISTS (
       SELECT 1
         FROM public.doma_battle_sessions s
        WHERE s.room_code=upper(trim(coalesce(p_room_code,'')))
          AND s.status IN ('waiting','started','finished')
          AND auth.uid() IN (s.host_id,s.guest_id)
     );
$function$;

REVOKE ALL ON FUNCTION public.doma_is_battle_participant(text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.doma_is_battle_participant(text) TO authenticated;

DROP POLICY IF EXISTS "doma battle participants receive private broadcasts" ON realtime.messages;
CREATE POLICY "doma battle participants receive private broadcasts"
ON realtime.messages
FOR SELECT TO authenticated
USING (
  extension IN ('broadcast','presence')
  AND public.doma_is_battle_participant(
    substring((SELECT realtime.topic()) from '^doma-academy-battle-(DOMA-[A-Z0-9]{4}-[A-Z0-9]{2})$')
  )
);

DROP POLICY IF EXISTS "doma battle participants send private broadcasts" ON realtime.messages;
CREATE POLICY "doma battle participants send private broadcasts"
ON realtime.messages
FOR INSERT TO authenticated
WITH CHECK (
  extension IN ('broadcast','presence')
  AND public.doma_is_battle_participant(
    substring((SELECT realtime.topic()) from '^doma-academy-battle-(DOMA-[A-Z0-9]{4}-[A-Z0-9]{2})$')
  )
);