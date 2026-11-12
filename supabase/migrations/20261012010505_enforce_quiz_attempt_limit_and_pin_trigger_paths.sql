-- Enforce quiz attempt limits in the submission RPC itself, not just in a UI/start gate.
-- Lock the quiz row to serialize concurrent submissions for the same quiz.
CREATE OR REPLACE FUNCTION public.doma_submit_quiz(p_quiz_id uuid, p_answers jsonb)
RETURNS TABLE(
  attempt_id uuid,
  score numeric,
  total_points integer,
  percentage integer,
  submitted_at timestamp with time zone,
  certificate_created_at timestamp with time zone
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  q_grade uuid;
  q_free boolean;
  q_published boolean;
  q record;
  v_score numeric := 0;
  v_total integer := 0;
  v_selected text;
  v_attempt uuid;
  v_submitted timestamptz;
  v_cert uuid;
  v_cert_time timestamptz;
  v_attempts_limit integer := 0;
  v_attempts_used integer := 0;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  SELECT grade_id, is_free, is_published
    INTO q_grade, q_free, q_published
  FROM public.quizzes
  WHERE id = p_quiz_id
  FOR UPDATE;

  IF q_grade IS NULL THEN
    RAISE EXCEPTION 'Quiz not found';
  END IF;

  IF NOT public.doma_is_staff() THEN
    IF NOT q_published THEN
      RAISE EXCEPTION 'Quiz is not published';
    END IF;

    IF NOT coalesce(q_free, false) AND NOT EXISTS (
      SELECT 1
      FROM public.subscriptions s
      WHERE s.student_id = auth.uid()
        AND s.grade_id = q_grade
        AND lower(trim(coalesce(s.status, ''))) = 'active'
        AND s.expires_at > now()
    ) THEN
      RAISE EXCEPTION 'Active subscription required';
    END IF;

    SELECT coalesce(qps.attempts_limit, 0)
      INTO v_attempts_limit
    FROM public.quiz_pro_settings qps
    WHERE qps.quiz_id = p_quiz_id;

    IF NOT FOUND THEN
      v_attempts_limit := 0;
    END IF;

    IF v_attempts_limit > 0 THEN
      SELECT count(*)::integer
        INTO v_attempts_used
      FROM public.quiz_attempts qa
      WHERE qa.student_id = auth.uid()
        AND qa.quiz_id = p_quiz_id;

      IF v_attempts_used >= v_attempts_limit THEN
        RAISE EXCEPTION 'Attempt limit reached';
      END IF;
    END IF;
  END IF;

  IF jsonb_typeof(coalesce(p_answers, '{}'::jsonb)) <> 'object' THEN
    RAISE EXCEPTION 'Answers must be a JSON object';
  END IF;

  FOR q IN
    SELECT id, points, correct_answer
    FROM public.quiz_questions
    WHERE quiz_id = p_quiz_id
    ORDER BY sort_order, id
  LOOP
    v_total := v_total + coalesce(q.points, 1);
    v_selected := p_answers ->> q.id::text;
    IF v_selected IS NOT NULL
       AND q.correct_answer IS NOT NULL
       AND v_selected = q.correct_answer THEN
      v_score := v_score + coalesce(q.points, 1);
    END IF;
  END LOOP;

  INSERT INTO public.quiz_attempts(
    quiz_id, student_id, score, total_points, answers, submitted_at
  )
  VALUES(
    p_quiz_id, auth.uid(), v_score, v_total, coalesce(p_answers, '{}'::jsonb), now()
  )
  RETURNING id INTO v_attempt;

  SELECT qa.submitted_at
    INTO v_submitted
  FROM public.quiz_attempts qa
  WHERE qa.id = v_attempt;

  INSERT INTO public.student_activity(student_id, activity_type, entity_id, metadata)
  VALUES(
    auth.uid(), 'quiz_submit', p_quiz_id,
    jsonb_build_object('score', v_score, 'total_points', v_total)
  );

  BEGIN
    v_cert := public.doma_issue_certificate_if_eligible(auth.uid(), q_grade);
    IF v_cert IS NOT NULL THEN
      SELECT issued_at INTO v_cert_time
      FROM public.certificates
      WHERE id = v_cert;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    v_cert := NULL;
    v_cert_time := NULL;
  END;

  RETURN QUERY
  SELECT
    v_attempt,
    v_score,
    v_total,
    CASE WHEN v_total = 0 THEN 0 ELSE round(v_score / v_total * 100)::integer END,
    v_submitted,
    v_cert_time;
END;
$function$;

-- Pin the search_path for timestamp trigger functions highlighted by the linter.
ALTER FUNCTION public.doma_touch_updated_at() SET search_path TO 'pg_catalog', 'public';
ALTER FUNCTION public.doma_daily_words_touch_updated_at() SET search_path TO 'pg_catalog', 'public';
