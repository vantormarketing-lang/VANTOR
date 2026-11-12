-- Prevent students from asking the certificate RPC to act on another student.
CREATE OR REPLACE FUNCTION public.doma_issue_certificate_if_eligible(p_student_id uuid, p_grade_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  total_lessons integer;
  done_lessons integer;
  progress_pct integer;
  avg_quiz numeric;
  quiz_count integer;
  existing_id uuid;
  grade_name text;
  cert_id uuid;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF p_student_id IS NULL OR p_grade_id IS NULL THEN
    RETURN NULL;
  END IF;

  IF auth.uid() <> p_student_id AND NOT public.doma_is_staff() THEN
    RAISE EXCEPTION 'Access denied';
  END IF;

  SELECT count(*) INTO total_lessons
  FROM public.lessons
  WHERE grade_id = p_grade_id AND is_published = true;

  SELECT count(*) INTO done_lessons
  FROM public.lesson_progress lp
  JOIN public.lessons l ON l.id = lp.lesson_id
  WHERE lp.student_id = p_student_id
    AND l.grade_id = p_grade_id
    AND l.is_published = true
    AND lp.completed = true;

  IF total_lessons = 0 THEN RETURN NULL; END IF;

  progress_pct := floor(done_lessons::numeric / total_lessons::numeric * 100);
  IF progress_pct < 80 THEN RETURN NULL; END IF;

  WITH best AS (
    SELECT qa.quiz_id,
           max(CASE WHEN qa.total_points = 0 THEN 0 ELSE qa.score / qa.total_points * 100 END) AS best_pct
    FROM public.quiz_attempts qa
    JOIN public.quizzes q ON q.id = qa.quiz_id
    WHERE qa.student_id = p_student_id
      AND q.grade_id = p_grade_id
      AND q.is_published = true
    GROUP BY qa.quiz_id
  )
  SELECT coalesce(avg(best_pct), 0), count(*)
    INTO avg_quiz, quiz_count
  FROM best;

  IF quiz_count = 0 OR avg_quiz < 80 THEN RETURN NULL; END IF;

  SELECT id INTO existing_id
  FROM public.certificates
  WHERE student_id = p_student_id
    AND certificate_code LIKE 'DOMA-AUTO-%'
    AND title = 'DOMA ACADEMY — ' || coalesce(
      (SELECT name FROM public.grades WHERE id = p_grade_id), 'English'
    ) || ' Completion'
  LIMIT 1;

  IF existing_id IS NOT NULL THEN RETURN existing_id; END IF;

  SELECT name INTO grade_name FROM public.grades WHERE id = p_grade_id;

  INSERT INTO public.certificates(student_id, title, certificate_code)
  VALUES (
    p_student_id,
    'DOMA ACADEMY — ' || coalesce(grade_name, 'English') || ' Completion',
    'DOMA-AUTO-' || upper(replace(substr(gen_random_uuid()::text, 1, 13), '-', ''))
  )
  RETURNING id INTO cert_id;

  INSERT INTO public.notifications(student_id, title, message)
  VALUES (
    p_student_id,
    'Certificate earned',
    'You met the completion criteria for ' || coalesce(grade_name, 'your grade') ||
    '. Your DOMA ACADEMY certificate is available.'
  );

  RETURN cert_id;
END;
$function$;

-- Harden the legacy quiz-submit endpoint which is not called from the current
-- repository UI, but remains exposed as an authenticated RPC.
CREATE OR REPLACE FUNCTION public.submit_quiz_attempt(
  p_quiz_id uuid,
  p_student_id uuid,
  p_answers jsonb
)
RETURNS TABLE(score numeric, total_points integer, passed boolean)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  q record;
  q_grade uuid;
  q_free boolean;
  q_published boolean;
  v_score numeric := 0;
  v_total integer := 0;
  v_pass numeric := 50;
  v_answer text;
  v_attempts_limit integer := 0;
  v_attempts_used integer := 0;
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_student_id THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  SELECT grade_id, is_free, is_published, pass_percent
    INTO q_grade, q_free, q_published, v_pass
  FROM public.quizzes
  WHERE id = p_quiz_id
  FOR UPDATE;

  IF q_grade IS NULL THEN
    RAISE EXCEPTION 'Quiz not found';
  END IF;

  IF NOT q_published THEN
    RAISE EXCEPTION 'Exam is not available for this student';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = p_student_id AND p.grade_id = q_grade
  ) THEN
    RAISE EXCEPTION 'Exam is not available for this student';
  END IF;

  IF NOT coalesce(q_free, false) AND NOT EXISTS (
    SELECT 1
    FROM public.subscriptions s
    WHERE s.student_id = p_student_id
      AND s.grade_id = q_grade
      AND lower(trim(coalesce(s.status, ''))) = 'active'
      AND s.expires_at > now()
  ) THEN
    RAISE EXCEPTION 'Active subscription required';
  END IF;

  IF jsonb_typeof(coalesce(p_answers, '{}'::jsonb)) <> 'object' THEN
    RAISE EXCEPTION 'Answers must be a JSON object';
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
    WHERE qa.quiz_id = p_quiz_id
      AND qa.student_id = p_student_id;

    IF v_attempts_used >= v_attempts_limit THEN
      RAISE EXCEPTION 'Attempt limit reached';
    END IF;
  END IF;

  FOR q IN
    SELECT id, correct_answer, points
    FROM public.quiz_questions
    WHERE quiz_id = p_quiz_id
    ORDER BY sort_order, id
  LOOP
    v_total := v_total + coalesce(q.points, 1);
    v_answer := p_answers ->> q.id::text;
    IF v_answer IS NOT NULL AND v_answer = q.correct_answer THEN
      v_score := v_score + coalesce(q.points, 1);
    END IF;
  END LOOP;

  INSERT INTO public.quiz_attempts(quiz_id, student_id, score, total_points, answers)
  VALUES (p_quiz_id, p_student_id, v_score, v_total, coalesce(p_answers, '{}'::jsonb));

  RETURN QUERY
  SELECT
    v_score,
    v_total,
    (CASE WHEN v_total = 0 THEN false ELSE (v_score / v_total * 100) >= coalesce(v_pass, 50) END);
END;
$function$;
