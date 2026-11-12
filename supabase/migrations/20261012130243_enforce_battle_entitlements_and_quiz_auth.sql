CREATE OR REPLACE FUNCTION public.doma_record_battle(
  p_room_code text, p_quiz_id uuid, p_quiz_title text, p_grade_id uuid,
  p_player1_id uuid, p_player1_name text, p_player1_score integer,
  p_player2_id uuid, p_player2_name text, p_player2_score integer,
  p_winner_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $function$
DECLARE
  v_id uuid;
  v_existing public.battle_matches%rowtype;
  v_winner uuid;
  v_room_code text := upper(trim(coalesce(p_room_code, '')));
  v_quiz_grade uuid;
  v_quiz_published boolean;
  v_quiz_free boolean;
  v_total_points integer;
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
  IF p_grade_id IS NULL OR p_quiz_id IS NULL THEN
    RAISE EXCEPTION 'A valid grade and quiz are required to save a Battle';
  END IF;

  SELECT q.grade_id, q.is_published, q.is_free
    INTO v_quiz_grade, v_quiz_published, v_quiz_free
    FROM public.quizzes q WHERE q.id = p_quiz_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle quiz not found'; END IF;
  IF v_quiz_grade IS DISTINCT FROM p_grade_id THEN
    RAISE EXCEPTION 'Battle quiz does not belong to the selected grade';
  END IF;
  IF NOT coalesce(v_quiz_published, false) THEN
    RAISE EXCEPTION 'Battle quiz is not published';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.grades g WHERE g.id=p_grade_id AND g.is_active=true) THEN
    RAISE EXCEPTION 'Battle grade is not active';
  END IF;

  IF NOT public.doma_is_staff() THEN
    IF NOT coalesce(v_quiz_free, false) AND NOT EXISTS (
      SELECT 1 FROM public.subscriptions s
       WHERE s.student_id = auth.uid()
         AND s.grade_id = p_grade_id
         AND lower(trim(coalesce(s.status, ''))) = 'active'
         AND s.expires_at > now()
    ) THEN
      RAISE EXCEPTION 'An active subscription is required to record a Battle';
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM public.profiles p
       WHERE p.id = p_player1_id AND p.role = 'student'
         AND (p.grade_id = p_grade_id OR EXISTS (
           SELECT 1 FROM public.subscriptions s
            WHERE s.student_id = p.id AND s.grade_id = p_grade_id
              AND lower(trim(coalesce(s.status, ''))) = 'active' AND s.expires_at > now()
         ))
         AND (coalesce(v_quiz_free,false) OR EXISTS (
           SELECT 1 FROM public.subscriptions s
            WHERE s.student_id = p.id AND s.grade_id = p_grade_id
              AND lower(trim(coalesce(s.status, ''))) = 'active' AND s.expires_at > now()
         ))
    ) OR NOT EXISTS (
      SELECT 1 FROM public.profiles p
       WHERE p.id = p_player2_id AND p.role = 'student'
         AND (p.grade_id = p_grade_id OR EXISTS (
           SELECT 1 FROM public.subscriptions s
            WHERE s.student_id = p.id AND s.grade_id = p_grade_id
              AND lower(trim(coalesce(s.status, ''))) = 'active' AND s.expires_at > now()
         ))
         AND (coalesce(v_quiz_free,false) OR EXISTS (
           SELECT 1 FROM public.subscriptions s
            WHERE s.student_id = p.id AND s.grade_id = p_grade_id
              AND lower(trim(coalesce(s.status, ''))) = 'active' AND s.expires_at > now()
         ))
    ) THEN
      RAISE EXCEPTION 'Both Battle participants must be eligible students for the selected grade and quiz';
    END IF;
  END IF;

  IF coalesce(p_player1_score, 0) < 0 OR coalesce(p_player2_score, 0) < 0 THEN
    RAISE EXCEPTION 'Battle scores cannot be negative';
  END IF;
  SELECT coalesce(sum(coalesce(qq.points, 1)), 0)::integer
    INTO v_total_points
    FROM public.quiz_questions qq WHERE qq.quiz_id = p_quiz_id;
  IF v_total_points <= 0 THEN RAISE EXCEPTION 'Battle quiz has no scored questions'; END IF;
  IF coalesce(p_player1_score, 0) > v_total_points OR coalesce(p_player2_score, 0) > v_total_points THEN
    RAISE EXCEPTION 'Battle score exceeds the quiz maximum';
  END IF;

  v_winner := CASE
    WHEN coalesce(p_player1_score,0) > coalesce(p_player2_score,0) THEN p_player1_id
    WHEN coalesce(p_player2_score,0) > coalesce(p_player1_score,0) THEN p_player2_id
    ELSE NULL
  END;

  INSERT INTO public.battle_matches(
    room_code,quiz_id,quiz_title,grade_id,
    player1_id,player1_name,player1_score,
    player2_id,player2_name,player2_score,winner_id
  ) VALUES (
    v_room_code,p_quiz_id,coalesce(nullif(trim(p_quiz_title),''),'Quiz'),p_grade_id,
    p_player1_id,coalesce(nullif(trim(p_player1_name),''),'Player 1'),coalesce(p_player1_score,0),
    p_player2_id,coalesce(nullif(trim(p_player2_name),''),'Player 2'),coalesce(p_player2_score,0),v_winner
  )
  ON CONFLICT (room_code) DO NOTHING
  RETURNING id INTO v_id;

  IF v_id IS NOT NULL THEN
    RETURN jsonb_build_object('ok',true,'id',v_id,'already_recorded',false);
  END IF;

  SELECT * INTO v_existing FROM public.battle_matches WHERE room_code=v_room_code;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle result could not be saved. Please retry.'; END IF;
  IF v_existing.player1_id <> p_player1_id
     OR v_existing.player2_id <> p_player2_id
     OR (auth.uid() <> v_existing.player1_id AND auth.uid() <> v_existing.player2_id) THEN
    RAISE EXCEPTION 'This room code already belongs to another Battle or its participants differ';
  END IF;
  RETURN jsonb_build_object('ok',true,'id',v_existing.id,'already_recorded',true);
END;
$function$;
REVOKE ALL ON FUNCTION public.doma_record_battle(text,uuid,text,uuid,uuid,text,integer,uuid,text,integer,uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.doma_record_battle(text,uuid,text,uuid,uuid,text,integer,uuid,text,integer,uuid) FROM anon;
GRANT EXECUTE ON FUNCTION public.doma_record_battle(text,uuid,text,uuid,uuid,text,integer,uuid,text,integer,uuid) TO authenticated;

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

  SELECT grade_id, is_free, is_published
    INTO q_grade, q_free, q_published
    FROM public.quizzes
   WHERE id = p_quiz_id;
  IF q_grade IS NULL THEN RAISE EXCEPTION 'Quiz not found'; END IF;

  IF NOT public.doma_is_staff() THEN
    IF NOT q_published THEN RAISE EXCEPTION 'Quiz is not published'; END IF;
    IF NOT coalesce(q_free,false) AND NOT EXISTS (
      SELECT 1 FROM public.subscriptions s
       WHERE s.student_id=auth.uid()
         AND s.grade_id=q_grade
         AND lower(trim(coalesce(s.status,'')))='active'
         AND s.expires_at>now()
    ) THEN
      RAISE EXCEPTION 'Active subscription required';
    END IF;
  END IF;

  RETURN QUERY
  SELECT qq.id,qq.quiz_id,qq.question,qq.options,qq.points,qq.sort_order
    FROM public.quiz_questions qq
   WHERE qq.quiz_id=p_quiz_id
   ORDER BY qq.sort_order,qq.id;
END;
$function$;
REVOKE ALL ON FUNCTION public.doma_get_quiz_questions(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.doma_get_quiz_questions(uuid) FROM anon;
GRANT EXECUTE ON FUNCTION public.doma_get_quiz_questions(uuid) TO authenticated;