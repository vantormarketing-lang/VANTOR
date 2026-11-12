-- Targeted hardening for student-facing SECURITY DEFINER RPCs.
-- Keep authenticated student/admin flows working while removing anonymous RPC access.

CREATE OR REPLACE FUNCTION public.doma_get_question_bank(p_quiz_ids uuid[])
RETURNS TABLE(id uuid, quiz_id uuid, question text, options jsonb, points integer, sort_order integer)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF coalesce(cardinality(p_quiz_ids), 0) > 100 THEN
    RAISE EXCEPTION 'Request too large';
  END IF;

  RETURN QUERY
  SELECT qq.id, qq.quiz_id, qq.question, qq.options, qq.points, qq.sort_order
  FROM public.quiz_questions AS qq
  JOIN public.quizzes AS q ON q.id = qq.quiz_id
  WHERE q.id = ANY(coalesce(p_quiz_ids, ARRAY[]::uuid[]))
    AND (
      public.doma_is_staff()
      OR (
        q.is_published = true
        AND (
          q.is_free = true
          OR EXISTS (
            SELECT 1
            FROM public.subscriptions AS s
            WHERE s.student_id = auth.uid()
              AND s.grade_id = q.grade_id
              AND lower(trim(coalesce(s.status, ''))) = 'active'
              AND s.expires_at > now()
          )
        )
      )
    )
  ORDER BY qq.sort_order ASC, qq.id;
END;
$function$;

CREATE OR REPLACE FUNCTION public.doma_quiz_start_gate(p_quiz_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  q record;
  cfg record;
  used integer := 0;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'Not authenticated');
  END IF;

  SELECT id, grade_id, is_free, is_published
    INTO q
  FROM public.quizzes
  WHERE id = p_quiz_id;

  IF NOT FOUND OR q.id IS NULL THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'Quiz unavailable');
  END IF;

  IF NOT public.doma_is_staff() THEN
    IF NOT q.is_published THEN
      RETURN jsonb_build_object('allowed', false, 'reason', 'Quiz unavailable');
    END IF;

    IF NOT coalesce(q.is_free, false) AND NOT EXISTS (
      SELECT 1
      FROM public.subscriptions s
      WHERE s.student_id = v_uid
        AND s.grade_id = q.grade_id
        AND lower(trim(coalesce(s.status, ''))) = 'active'
        AND s.expires_at > now()
    ) THEN
      RETURN jsonb_build_object('allowed', false, 'reason', 'Active subscription required');
    END IF;
  END IF;

  SELECT shuffle_questions, shuffle_options, attempts_limit, time_limit_minutes, pass_percent, show_review
    INTO cfg
  FROM public.quiz_pro_settings
  WHERE quiz_id = p_quiz_id;

  IF NOT FOUND THEN
    cfg.shuffle_questions := false;
    cfg.shuffle_options := false;
    cfg.attempts_limit := 0;
    cfg.time_limit_minutes := 20;
    cfg.pass_percent := 50;
    cfg.show_review := true;
  END IF;

  IF coalesce(cfg.attempts_limit, 0) > 0 THEN
    SELECT count(*) INTO used
    FROM public.quiz_attempts
    WHERE student_id = v_uid AND quiz_id = p_quiz_id;

    IF used >= cfg.attempts_limit THEN
      RETURN jsonb_build_object(
        'allowed', false,
        'reason', 'Attempt limit reached',
        'attempts_used', used,
        'attempts_limit', cfg.attempts_limit
      );
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'allowed', true,
    'attempts_used', used,
    'attempts_limit', cfg.attempts_limit,
    'shuffle_questions', cfg.shuffle_questions,
    'shuffle_options', cfg.shuffle_options,
    'time_limit_minutes', cfg.time_limit_minutes,
    'pass_percent', cfg.pass_percent,
    'show_review', cfg.show_review
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.doma_battle_leaderboard(p_grade_id uuid, p_limit integer DEFAULT 20)
RETURNS TABLE(student_id uuid, full_name text, matches bigint, wins bigint, draws bigint, losses bigint, points bigint)
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
      RAISE EXCEPTION 'Select your school grade to view the leaderboard';
    END IF;

    IF NOT EXISTS (
      SELECT 1
      FROM public.profiles p
      WHERE p.id = v_uid AND p.grade_id = v_grade_id
    ) AND NOT EXISTS (
      SELECT 1
      FROM public.subscriptions s
      WHERE s.student_id = v_uid
        AND s.grade_id = v_grade_id
        AND lower(trim(coalesce(s.status, ''))) = 'active'
        AND s.expires_at > now()
    ) THEN
      RAISE EXCEPTION 'You cannot view another grade leaderboard';
    END IF;
  END IF;

  RETURN QUERY
  WITH players AS (
    SELECT b.grade_id, b.player1_id AS student_id, b.player1_score AS score, b.winner_id
    FROM public.battle_matches b
    WHERE (v_grade_id IS NULL OR b.grade_id = v_grade_id)
    UNION ALL
    SELECT b.grade_id, b.player2_id AS student_id, b.player2_score AS score, b.winner_id
    FROM public.battle_matches b
    WHERE (v_grade_id IS NULL OR b.grade_id = v_grade_id)
  )
  SELECT
    p.student_id,
    coalesce(pr.full_name, 'Student') AS full_name,
    count(*)::bigint AS matches,
    count(*) FILTER (WHERE p.winner_id = p.student_id)::bigint AS wins,
    count(*) FILTER (WHERE p.winner_id IS NULL)::bigint AS draws,
    count(*) FILTER (WHERE p.winner_id IS NOT NULL AND p.winner_id <> p.student_id)::bigint AS losses,
    coalesce(sum(p.score), 0)::bigint AS points
  FROM players p
  LEFT JOIN public.profiles pr ON pr.id = p.student_id
  GROUP BY p.student_id, pr.full_name
  ORDER BY wins DESC, points DESC, matches DESC, full_name ASC
  LIMIT greatest(1, least(coalesce(p_limit, 20), 100));
END;
$function$;

CREATE OR REPLACE FUNCTION public.doma_record_battle(
  p_room_code text,
  p_quiz_id uuid,
  p_quiz_title text,
  p_grade_id uuid,
  p_player1_id uuid,
  p_player1_name text,
  p_player1_score integer,
  p_player2_id uuid,
  p_player2_name text,
  p_player2_score integer,
  p_winner_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_id uuid;
  v_winner uuid;
  v_room_code text := upper(trim(coalesce(p_room_code, '')));
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF length(v_room_code) < 4 OR length(v_room_code) > 64 THEN
    RAISE EXCEPTION 'Invalid Battle room code';
  END IF;

  IF p_player1_id IS NULL OR p_player2_id IS NULL OR p_player1_id = p_player2_id THEN
    RAISE EXCEPTION 'A Battle needs two different students';
  END IF;

  IF auth.uid() <> p_player1_id AND auth.uid() <> p_player2_id THEN
    RAISE EXCEPTION 'You are not a participant in this Battle';
  END IF;

  IF coalesce(p_player1_score, 0) < 0 OR coalesce(p_player2_score, 0) < 0 THEN
    RAISE EXCEPTION 'Battle scores cannot be negative';
  END IF;

  v_winner := CASE
    WHEN coalesce(p_player1_score, 0) > coalesce(p_player2_score, 0) THEN p_player1_id
    WHEN coalesce(p_player2_score, 0) > coalesce(p_player1_score, 0) THEN p_player2_id
    ELSE NULL
  END;

  INSERT INTO public.battle_matches(
    room_code, quiz_id, quiz_title, grade_id,
    player1_id, player1_name, player1_score,
    player2_id, player2_name, player2_score, winner_id
  ) VALUES (
    v_room_code, p_quiz_id, coalesce(nullif(trim(p_quiz_title), ''), 'Quiz'), p_grade_id,
    p_player1_id, coalesce(nullif(trim(p_player1_name), ''), 'Player 1'), greatest(coalesce(p_player1_score, 0), 0),
    p_player2_id, coalesce(nullif(trim(p_player2_name), ''), 'Player 2'), greatest(coalesce(p_player2_score, 0), 0), v_winner
  )
  ON CONFLICT (room_code) DO UPDATE SET
    quiz_id = EXCLUDED.quiz_id,
    quiz_title = EXCLUDED.quiz_title,
    grade_id = EXCLUDED.grade_id,
    player1_id = EXCLUDED.player1_id,
    player1_name = EXCLUDED.player1_name,
    player1_score = EXCLUDED.player1_score,
    player2_id = EXCLUDED.player2_id,
    player2_name = EXCLUDED.player2_name,
    player2_score = EXCLUDED.player2_score,
    winner_id = EXCLUDED.winner_id
  WHERE
    (public.battle_matches.player1_id = auth.uid() OR public.battle_matches.player2_id = auth.uid())
    AND public.battle_matches.player1_id = EXCLUDED.player1_id
    AND public.battle_matches.player2_id = EXCLUDED.player2_id
  RETURNING id INTO v_id;

  IF v_id IS NULL THEN
    RAISE EXCEPTION 'This room code already belongs to another Battle or its participants differ';
  END IF;

  RETURN jsonb_build_object('ok', true, 'id', v_id);
END;
$function$;

-- Student-facing RPCs should require a signed-in account.
REVOKE EXECUTE ON FUNCTION public.doma_battle_history(uuid, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_battle_history(uuid, integer) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.doma_battle_leaderboard(uuid, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_battle_leaderboard(uuid, integer) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.doma_get_question_bank(uuid[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_get_question_bank(uuid[]) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.doma_quiz_start_gate(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_quiz_start_gate(uuid) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.doma_record_battle(text, uuid, text, uuid, uuid, text, integer, uuid, text, integer, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_record_battle(text, uuid, text, uuid, uuid, text, integer, uuid, text, integer, uuid) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.doma_check_staff() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_check_staff() TO authenticated;

-- These are trigger/event-trigger entry points; direct API execution is unnecessary.
REVOKE EXECUTE ON FUNCTION public.handle_new_student() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;
