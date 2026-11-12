CREATE OR REPLACE FUNCTION public.doma_student_leaderboard(p_grade_id uuid, p_limit integer DEFAULT 10)
RETURNS TABLE(student_id uuid, full_name text, xp bigint, level_name text)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_grade_id uuid := p_grade_id;
  v_is_staff boolean := public.doma_is_staff();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF NOT v_is_staff THEN
    IF v_grade_id IS NULL THEN
      SELECT s.grade_id INTO v_grade_id
      FROM public.subscriptions s
      WHERE s.student_id = v_uid
        AND lower(trim(coalesce(s.status, ''))) = 'active'
        AND s.expires_at > now()
      ORDER BY s.expires_at DESC
      LIMIT 1;

      IF v_grade_id IS NULL THEN
        SELECT p.grade_id INTO v_grade_id
        FROM public.profiles p
        WHERE p.id = v_uid;
      END IF;
    END IF;

    IF v_grade_id IS NULL THEN
      RAISE EXCEPTION 'A school grade is required to view the leaderboard';
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = v_uid AND p.grade_id = v_grade_id
    ) AND NOT EXISTS (
      SELECT 1 FROM public.subscriptions s
      WHERE s.student_id = v_uid
        AND s.grade_id = v_grade_id
        AND lower(trim(coalesce(s.status, ''))) = 'active'
        AND s.expires_at > now()
    ) THEN
      RAISE EXCEPTION 'You cannot view another grade leaderboard';
    END IF;
  END IF;

  RETURN QUERY
  WITH students AS (
    SELECT p.id, coalesce(nullif(trim(p.full_name), ''), 'Student') AS full_name
    FROM public.profiles p
    WHERE p.role = 'student'
      AND (v_grade_id IS NULL OR p.grade_id = v_grade_id)
  ),
  lesson_xp AS (
    SELECT lp.student_id, count(*)::bigint * 20 AS xp
    FROM public.lesson_progress lp
    JOIN public.lessons l ON l.id = lp.lesson_id
    JOIN students s ON s.id = lp.student_id
    WHERE lp.completed = true
      AND (v_grade_id IS NULL OR l.grade_id = v_grade_id)
    GROUP BY lp.student_id
  ),
  quiz_best AS (
    SELECT qa.student_id, qa.quiz_id,
           max(CASE WHEN qa.total_points > 0
                    THEN least(100, greatest(0, round((qa.score / qa.total_points) * 100)))
                    ELSE 0 END)::bigint AS best_percent
    FROM public.quiz_attempts qa
    JOIN public.quizzes q ON q.id = qa.quiz_id
    JOIN students s ON s.id = qa.student_id
    WHERE (v_grade_id IS NULL OR q.grade_id = v_grade_id)
    GROUP BY qa.student_id, qa.quiz_id
  ),
  quiz_xp AS (
    SELECT student_id, coalesce(sum(best_percent), 0)::bigint AS xp
    FROM quiz_best
    GROUP BY student_id
  ),
  homework_xp AS (
    SELECT hs.student_id, count(*)::bigint * 20 AS xp
    FROM public.homework_submissions hs
    JOIN public.homework h ON h.id = hs.homework_id
    JOIN students s ON s.id = hs.student_id
    WHERE (v_grade_id IS NULL OR h.grade_id = v_grade_id)
    GROUP BY hs.student_id
  ),
  cert_xp AS (
    SELECT c.student_id, count(*)::bigint * 100 AS xp
    FROM public.certificates c
    JOIN students s ON s.id = c.student_id
    GROUP BY c.student_id
  ),
  sub_xp AS (
    SELECT DISTINCT s.student_id, 50::bigint AS xp
    FROM public.subscriptions s
    JOIN students st ON st.id = s.student_id
    WHERE lower(trim(coalesce(s.status, ''))) = 'active'
      AND s.expires_at > now()
      AND (v_grade_id IS NULL OR s.grade_id = v_grade_id)
  ),
  totals AS (
    SELECT st.id AS student_id, st.full_name,
      coalesce(l.xp, 0) + coalesce(q.xp, 0) + coalesce(h.xp, 0) +
      coalesce(c.xp, 0) + coalesce(sb.xp, 0) AS xp
    FROM students st
    LEFT JOIN lesson_xp l ON l.student_id = st.id
    LEFT JOIN quiz_xp q ON q.student_id = st.id
    LEFT JOIN homework_xp h ON h.student_id = st.id
    LEFT JOIN cert_xp c ON c.student_id = st.id
    LEFT JOIN sub_xp sb ON sb.student_id = st.id
  )
  SELECT t.student_id, t.full_name, t.xp,
    CASE
      WHEN t.xp >= 2200 THEN 'Legend'
      WHEN t.xp >= 1400 THEN 'Master'
      WHEN t.xp >= 900 THEN 'Expert'
      WHEN t.xp >= 500 THEN 'Achiever'
      WHEN t.xp >= 200 THEN 'Learner'
      ELSE 'Starter'
    END AS level_name
  FROM totals t
  ORDER BY t.xp DESC, t.full_name ASC
  LIMIT greatest(1, least(coalesce(p_limit, 10), 50));
END;
$function$;
