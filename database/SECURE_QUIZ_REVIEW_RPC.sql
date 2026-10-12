-- Applied to Supabase project dtptxhkcogpoleftguas.
-- Enforces the per-quiz Show Review setting inside the database RPC.
-- Staff can still review any attempt; students can only review their own attempt
-- and only when show_review is enabled (defaults to true when no config row exists).
CREATE OR REPLACE FUNCTION public.doma_get_attempt_review(p_attempt_id uuid)
RETURNS TABLE(
  question_id uuid,
  question text,
  selected_answer text,
  correct_answer text,
  is_correct boolean,
  points integer
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  a public.quiz_attempts%rowtype;
  v_is_staff boolean;
  v_show_review boolean := true;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  SELECT *
    INTO a
    FROM public.quiz_attempts
   WHERE id = p_attempt_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Attempt not found';
  END IF;

  v_is_staff := public.doma_is_staff();

  IF a.student_id <> auth.uid() AND NOT v_is_staff THEN
    RAISE EXCEPTION 'Access denied';
  END IF;

  IF NOT v_is_staff THEN
    SELECT coalesce(qps.show_review, true)
      INTO v_show_review
      FROM public.quiz_pro_settings qps
     WHERE qps.quiz_id = a.quiz_id;

    IF NOT FOUND THEN
      v_show_review := true;
    END IF;

    IF NOT coalesce(v_show_review, true) THEN
      RAISE EXCEPTION 'Answer review is disabled for this quiz';
    END IF;
  END IF;

  RETURN QUERY
  SELECT
    qq.id,
    qq.question,
    a.answers ->> qq.id::text,
    qq.correct_answer,
    (a.answers ->> qq.id::text) IS NOT NULL
      AND qq.correct_answer IS NOT NULL
      AND (a.answers ->> qq.id::text) = qq.correct_answer,
    qq.points
  FROM public.quiz_questions qq
  WHERE qq.quiz_id = a.quiz_id
  ORDER BY qq.sort_order, qq.id;
END;
$function$;
