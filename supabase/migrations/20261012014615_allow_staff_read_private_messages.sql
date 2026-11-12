DROP POLICY IF EXISTS "doma staff read messages" ON public.messages;
CREATE POLICY "doma staff read messages"
ON public.messages
FOR SELECT
TO authenticated
USING (public.doma_is_staff());
