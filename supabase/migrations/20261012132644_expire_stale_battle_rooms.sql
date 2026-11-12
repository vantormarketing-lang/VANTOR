CREATE OR REPLACE FUNCTION public.doma_create_battle_session(p_room_code text, p_quiz_id uuid, p_grade_id uuid, p_question_ids uuid[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_role text;
  v_quiz_grade uuid;
  v_quiz_free boolean;
  v_quiz_published boolean;
  v_question_count integer;
  v_room text := upper(trim(coalesce(p_room_code,'')));
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;

  -- Prune old sessions when a new room is created; historical match rows are kept.
  DELETE FROM public.doma_battle_sessions
   WHERE (status IN ('finished','cancelled') AND created_at < now()-interval '30 days')
      OR (status='waiting' AND created_at < now()-interval '1 day')
      OR (status='started' AND created_at < now()-interval '1 day');
  IF length(v_room)<4 OR length(v_room)>64 THEN RAISE EXCEPTION 'Invalid Battle room code'; END IF;
  IF p_quiz_id IS NULL OR p_grade_id IS NULL THEN RAISE EXCEPTION 'Choose a valid quiz and grade'; END IF;
  IF coalesce(cardinality(p_question_ids),0) NOT BETWEEN 2 AND 20 THEN
    RAISE EXCEPTION 'Battle must contain 2 to 20 questions';
  END IF;
  IF (SELECT count(DISTINCT qid) FROM unnest(p_question_ids) AS qid) <> cardinality(p_question_ids) THEN
    RAISE EXCEPTION 'Battle question list contains duplicates';
  END IF;

  SELECT lower(coalesce(p.role,'')) INTO v_role FROM public.profiles p WHERE p.id=v_uid;
  IF v_role <> 'student' THEN RAISE EXCEPTION 'Only student accounts can host a Battle'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.grades g WHERE g.id=p_grade_id AND g.is_active=true
  ) THEN RAISE EXCEPTION 'Selected grade is not active'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.profiles p WHERE p.id=v_uid AND p.grade_id=p_grade_id
  ) AND NOT EXISTS (
    SELECT 1 FROM public.subscriptions s WHERE s.student_id=v_uid AND s.grade_id=p_grade_id
      AND lower(trim(coalesce(s.status,'')))='active' AND s.expires_at>now()
  ) THEN RAISE EXCEPTION 'You do not have access to the selected grade'; END IF;

  SELECT q.grade_id,q.is_free,q.is_published
    INTO v_quiz_grade,v_quiz_free,v_quiz_published
    FROM public.quizzes q WHERE q.id=p_quiz_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle quiz not found'; END IF;
  IF v_quiz_grade IS DISTINCT FROM p_grade_id THEN RAISE EXCEPTION 'Battle quiz does not belong to the selected grade'; END IF;
  IF NOT coalesce(v_quiz_published,false) THEN RAISE EXCEPTION 'Battle quiz is not published'; END IF;
  IF NOT coalesce(v_quiz_free,false) AND NOT EXISTS (
    SELECT 1 FROM public.subscriptions s WHERE s.student_id=v_uid AND s.grade_id=p_grade_id
      AND lower(trim(coalesce(s.status,'')))='active' AND s.expires_at>now()
  ) THEN RAISE EXCEPTION 'An active subscription is required for this Battle quiz'; END IF;

  SELECT count(*)::integer INTO v_question_count
    FROM public.quiz_questions q
   WHERE q.quiz_id=p_quiz_id AND q.id=ANY(p_question_ids);
  IF v_question_count <> cardinality(p_question_ids) THEN
    RAISE EXCEPTION 'One or more Battle questions do not belong to the selected quiz';
  END IF;

  INSERT INTO public.doma_battle_sessions(room_code,quiz_id,grade_id,host_id,question_ids,status)
  VALUES(v_room,p_quiz_id,p_grade_id,v_uid,p_question_ids,'waiting');

  RETURN jsonb_build_object('ok',true,'room_code',v_room,'host_id',v_uid,'status','waiting',
    'question_count',cardinality(p_question_ids));
END;
$function$;

CREATE OR REPLACE FUNCTION public.doma_join_battle_session(p_room_code text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_session public.doma_battle_sessions%rowtype;
  v_role text;
  v_quiz_free boolean;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  SELECT lower(coalesce(p.role,'')) INTO v_role FROM public.profiles p WHERE p.id=v_uid;
  IF v_role <> 'student' THEN RAISE EXCEPTION 'Only student accounts can join a Battle'; END IF;

  SELECT * INTO v_session FROM public.doma_battle_sessions
   WHERE room_code=upper(trim(coalesce(p_room_code,''))) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle room not found or expired'; END IF;
  IF v_session.created_at < now()-interval '15 minutes' THEN
    RAISE EXCEPTION 'This Battle room has expired. Create a new room.';
  END IF;
  IF v_session.status <> 'waiting' OR v_session.guest_id IS NOT NULL THEN
    RAISE EXCEPTION 'This Battle room is no longer accepting players';
  END IF;
  IF v_session.host_id=v_uid THEN RAISE EXCEPTION 'You cannot join your own Battle room'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.grades g WHERE g.id=v_session.grade_id AND g.is_active=true) THEN
    RAISE EXCEPTION 'Selected grade is not active';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles p WHERE p.id=v_uid AND p.grade_id=v_session.grade_id
  ) AND NOT EXISTS (
    SELECT 1 FROM public.subscriptions s WHERE s.student_id=v_uid AND s.grade_id=v_session.grade_id
      AND lower(trim(coalesce(s.status,'')))='active' AND s.expires_at>now()
  ) THEN RAISE EXCEPTION 'You do not have access to this grade'; END IF;

  SELECT q.is_free INTO v_quiz_free FROM public.quizzes q
   WHERE q.id=v_session.quiz_id AND q.is_published=true AND q.grade_id=v_session.grade_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle quiz is no longer available'; END IF;
  IF NOT coalesce(v_quiz_free,false) AND NOT EXISTS (
    SELECT 1 FROM public.subscriptions s WHERE s.student_id=v_uid AND s.grade_id=v_session.grade_id
      AND lower(trim(coalesce(s.status,'')))='active' AND s.expires_at>now()
  ) THEN RAISE EXCEPTION 'An active subscription is required for this Battle quiz'; END IF;

  UPDATE public.doma_battle_sessions SET guest_id=v_uid
   WHERE room_code=v_session.room_code AND status='waiting' AND guest_id IS NULL;
  IF NOT FOUND THEN RAISE EXCEPTION 'This Battle room was joined by another player'; END IF;
  RETURN jsonb_build_object('ok',true,'room_code',v_session.room_code,'host_id',v_session.host_id,
    'guest_id',v_uid,'quiz_id',v_session.quiz_id,'grade_id',v_session.grade_id,
    'question_count',cardinality(v_session.question_ids),'status','waiting');
END;
$function$;

CREATE OR REPLACE FUNCTION public.doma_start_battle_session(p_room_code text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_session public.doma_battle_sessions%rowtype;
  v_quiz_free boolean;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  SELECT * INTO v_session FROM public.doma_battle_sessions
   WHERE room_code=upper(trim(coalesce(p_room_code,''))) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle room not found'; END IF;
  IF v_session.created_at < now()-interval '15 minutes' THEN
    RAISE EXCEPTION 'This Battle room has expired. Create a new room.';
  END IF;
  IF v_session.host_id<>v_uid THEN RAISE EXCEPTION 'Only the room host can start this Battle'; END IF;
  IF v_session.status<>'waiting' OR v_session.guest_id IS NULL THEN
    RAISE EXCEPTION 'A second player must join before the Battle starts';
  END IF;
  SELECT q.is_free INTO v_quiz_free FROM public.quizzes q
   WHERE q.id=v_session.quiz_id AND q.is_published=true AND q.grade_id=v_session.grade_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle quiz is no longer available'; END IF;
  UPDATE public.doma_battle_sessions
     SET status='started',current_question_index=0,
         question_deadline=clock_timestamp()+interval '20 seconds',started_at=now()
   WHERE room_code=v_session.room_code
  RETURNING * INTO v_session;
  RETURN jsonb_build_object('ok',true,'question_index',v_session.current_question_index,
    'question_deadline',v_session.question_deadline,'host_score',v_session.host_score,
    'guest_score',v_session.guest_score,'question_ids',v_session.question_ids);
END;
$function$;

REVOKE ALL ON FUNCTION public.doma_create_battle_session(text,uuid,uuid,uuid[]) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.doma_create_battle_session(text,uuid,uuid,uuid[]) TO authenticated;
REVOKE ALL ON FUNCTION public.doma_join_battle_session(text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.doma_join_battle_session(text) TO authenticated;
REVOKE ALL ON FUNCTION public.doma_start_battle_session(text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.doma_start_battle_session(text) TO authenticated;