-- Remove exact duplicate permissive RLS policies. The retained policies have
-- the identical role, command, USING and WITH CHECK expressions.
DROP POLICY IF EXISTS daily_words_staff_delete ON public.daily_words;
DROP POLICY IF EXISTS "doma staff question bank" ON public.question_bank;
DROP POLICY IF EXISTS "doma staff activity read" ON public.student_activity;
