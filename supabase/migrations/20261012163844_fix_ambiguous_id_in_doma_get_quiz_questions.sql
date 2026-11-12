CREATE OR REPLACE FUNCTION public.doma_get_quiz_questions(p_quiz_id uuid)
RETURNS TABLE(id uuid, quiz_id uuid, question text, options jsonb, points integer, sort_order integer)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  q_grade uuid;
  q_free boolean;
  q_published boolean;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  SELECT q.grade_id, q.is_free, q.is_published
    INTO q_grade, q_free, q_published
    FROM public.quizzes AS q
   WHERE q.id = p_quiz_id;

  IF q_grade IS NULL THEN
    RAISE EXCEPTION 'Quiz not found';
  END IF;

  IF NOT public.doma_is_staff() THEN
    IF NOT q_published THEN
      RAISE EXCEPTION 'Quiz is not published';
    END IF;
    IF NOT coalesce(q_free, false) AND NOT EXISTS (
      SELECT 1
        FROM public.subscriptions AS s
       WHERE s.student_id = auth.uid()
         AND s.grade_id = q_grade
         AND lower(trim(coalesce(s.status, ''))) = 'active'
         AND s.expires_at > now()
    ) THEN
      RAISE EXCEPTION 'Active subscription required';
    END IF;
  END IF;

  RETURN QUERY
  SELECT qq.id, qq.quiz_id, qq.question, qq.options, qq.points, qq.sort_order
    FROM public.quiz_questions AS qq
   WHERE qq.quiz_id = p_quiz_id
   ORDER BY qq.sort_order, qq.id;
END;
$function$;