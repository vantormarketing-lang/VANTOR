-- Private, server-authoritative Battle sessions and scoring.
-- Applied live via server_authoritative_battle_sessions and
-- use_server_clock_for_battle_scoring. Designed to be rerun safely.
CREATE TABLE IF NOT EXISTS public.doma_battle_sessions (
  room_code text PRIMARY KEY CHECK (room_code = upper(trim(room_code)) AND length(room_code) BETWEEN 4 AND 64),
  quiz_id uuid NOT NULL REFERENCES public.quizzes(id) ON DELETE RESTRICT,
  grade_id uuid NOT NULL REFERENCES public.grades(id) ON DELETE RESTRICT,
  host_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  guest_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  question_ids uuid[] NOT NULL,
  current_question_index integer NOT NULL DEFAULT -1 CHECK (current_question_index >= -1),
  host_score integer NOT NULL DEFAULT 0 CHECK (host_score >= 0),
  guest_score integer NOT NULL DEFAULT 0 CHECK (guest_score >= 0),
  status text NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting','started','finished','cancelled')),
  question_deadline timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  started_at timestamptz,
  finished_at timestamptz
);
CREATE TABLE IF NOT EXISTS public.doma_battle_session_answers (
  room_code text NOT NULL REFERENCES public.doma_battle_sessions(room_code) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  question_id uuid NOT NULL REFERENCES public.quiz_questions(id) ON DELETE RESTRICT,
  selected_answer text NOT NULL,
  is_correct boolean NOT NULL,
  points_awarded integer NOT NULL DEFAULT 0 CHECK (points_awarded >= 0),
  answered_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (room_code, student_id, question_id)
);
CREATE INDEX IF NOT EXISTS doma_battle_answers_room_question_idx
  ON public.doma_battle_session_answers(room_code, question_id);
ALTER TABLE public.doma_battle_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doma_battle_session_answers ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.doma_battle_sessions FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.doma_battle_session_answers FROM PUBLIC, anon, authenticated;

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
$function$

REVOKE ALL ON FUNCTION public.doma_create_battle_session(text,uuid,uuid,uuid[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_create_battle_session(text,uuid,uuid,uuid[]) TO authenticated;

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
$function$

REVOKE ALL ON FUNCTION public.doma_join_battle_session(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_join_battle_session(text) TO authenticated;

CREATE OR REPLACE FUNCTION public.doma_cancel_battle_session(p_room_code text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_session public.doma_battle_sessions%rowtype;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  SELECT * INTO v_session FROM public.doma_battle_sessions
   WHERE room_code=upper(trim(coalesce(p_room_code,''))) FOR UPDATE;
  IF NOT FOUND THEN RETURN jsonb_build_object('ok',true,'already_closed',true); END IF;
  IF v_uid=v_session.host_id AND v_session.status='waiting' THEN
    UPDATE public.doma_battle_sessions SET status='cancelled' WHERE room_code=v_session.room_code;
    RETURN jsonb_build_object('ok',true,'cancelled',true);
  END IF;
  IF v_uid=v_session.guest_id AND v_session.status='waiting' THEN
    UPDATE public.doma_battle_sessions SET guest_id=NULL WHERE room_code=v_session.room_code;
    RETURN jsonb_build_object('ok',true,'guest_removed',true);
  END IF;
  RAISE EXCEPTION 'This Battle can no longer be cancelled';
END;
$function$

REVOKE ALL ON FUNCTION public.doma_cancel_battle_session(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_cancel_battle_session(text) TO authenticated;

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
$function$

REVOKE ALL ON FUNCTION public.doma_start_battle_session(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_start_battle_session(text) TO authenticated;

CREATE OR REPLACE FUNCTION public.doma_submit_battle_answer(p_room_code text, p_question_index integer, p_question_id uuid, p_answer text, p_time_remaining_ms integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_session public.doma_battle_sessions%rowtype;
  v_question public.quiz_questions%rowtype;
  v_correct boolean;
  v_points integer;
  v_remaining integer;
  v_both_answered boolean;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  SELECT * INTO v_session FROM public.doma_battle_sessions
   WHERE room_code=upper(trim(coalesce(p_room_code,''))) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle room not found'; END IF;
  IF v_uid<>v_session.host_id AND v_uid IS DISTINCT FROM v_session.guest_id THEN
    RAISE EXCEPTION 'You are not a participant in this Battle';
  END IF;
  IF v_session.status<>'started' THEN RAISE EXCEPTION 'Battle is not accepting answers'; END IF;
  IF p_question_index IS DISTINCT FROM v_session.current_question_index
     OR p_question_index < 0
     OR p_question_index >= cardinality(v_session.question_ids)
     OR v_session.question_ids[p_question_index+1] IS DISTINCT FROM p_question_id THEN
    RAISE EXCEPTION 'This answer is for a different Battle question';
  END IF;
  IF clock_timestamp()>v_session.question_deadline THEN RAISE EXCEPTION 'Time for this question has expired'; END IF;
  IF nullif(trim(coalesce(p_answer,'')),'') IS NULL THEN RAISE EXCEPTION 'Choose an answer first'; END IF;
  IF EXISTS (SELECT 1 FROM public.doma_battle_session_answers a
     WHERE a.room_code=v_session.room_code AND a.student_id=v_uid AND a.question_id=p_question_id) THEN
    RAISE EXCEPTION 'You have already answered this question';
  END IF;

  SELECT * INTO v_question FROM public.quiz_questions q
   WHERE q.id=p_question_id AND q.quiz_id=v_session.quiz_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle question is no longer available'; END IF;
  IF jsonb_typeof(v_question.options)<>'array' OR NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements_text(v_question.options) opt(value)
     WHERE opt.value=p_answer
  ) THEN RAISE EXCEPTION 'Selected answer is not one of the available options'; END IF;

  v_correct := p_answer=v_question.correct_answer;
  -- Score speed on the server clock, not on a client-supplied timer value.
  v_remaining := least(greatest(
    floor(extract(epoch from (v_session.question_deadline-clock_timestamp()))*1000)::integer,0
  ),20000);
  v_points := CASE WHEN v_correct
    THEN round(coalesce(v_question.points,1)::numeric*(1+v_remaining::numeric/20000))::integer
    ELSE 0 END;

  INSERT INTO public.doma_battle_session_answers(room_code,student_id,question_id,selected_answer,is_correct,points_awarded)
  VALUES(v_session.room_code,v_uid,p_question_id,p_answer,v_correct,v_points);

  UPDATE public.doma_battle_sessions
     SET host_score=host_score+CASE WHEN v_uid=v_session.host_id THEN v_points ELSE 0 END,
         guest_score=guest_score+CASE WHEN v_uid=v_session.guest_id THEN v_points ELSE 0 END
   WHERE room_code=v_session.room_code
  RETURNING * INTO v_session;

  SELECT count(DISTINCT a.student_id)=2 INTO v_both_answered
    FROM public.doma_battle_session_answers a
   WHERE a.room_code=v_session.room_code
     AND a.question_id=p_question_id
     AND a.student_id IN (v_session.host_id,v_session.guest_id);

  RETURN jsonb_build_object(
    'ok',true,'correct',v_correct,'points',v_points,
    'player_id',v_uid,
    'player_score',CASE WHEN v_uid=v_session.host_id THEN v_session.host_score ELSE v_session.guest_score END,
    'host_score',v_session.host_score,'guest_score',v_session.guest_score,
    'question_index',v_session.current_question_index,'both_answered',coalesce(v_both_answered,false),
    'question_deadline',v_session.question_deadline
  );
END;
$function$

REVOKE ALL ON FUNCTION public.doma_submit_battle_answer(text,integer,uuid,text,integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_submit_battle_answer(text,integer,uuid,text,integer) TO authenticated;

CREATE OR REPLACE FUNCTION public.doma_advance_battle_session(p_room_code text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_session public.doma_battle_sessions%rowtype;
  v_answered integer;
  v_next integer;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  SELECT * INTO v_session FROM public.doma_battle_sessions
   WHERE room_code=upper(trim(coalesce(p_room_code,''))) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle room not found'; END IF;
  IF v_session.host_id<>v_uid THEN RAISE EXCEPTION 'Only the room host can advance the Battle'; END IF;
  IF v_session.status<>'started' THEN RAISE EXCEPTION 'Battle is not in progress'; END IF;

  SELECT count(DISTINCT a.student_id)::integer INTO v_answered
    FROM public.doma_battle_session_answers a
   WHERE a.room_code=v_session.room_code
     AND a.question_id=v_session.question_ids[v_session.current_question_index+1]
     AND a.student_id IN (v_session.host_id,v_session.guest_id);

  IF v_answered<2 AND clock_timestamp()<v_session.question_deadline THEN
    RAISE EXCEPTION 'Wait until both players answer or the question timer expires';
  END IF;

  v_next:=v_session.current_question_index+1;
  IF v_next>=cardinality(v_session.question_ids) THEN
    UPDATE public.doma_battle_sessions SET status='finished',finished_at=now(),question_deadline=NULL
     WHERE room_code=v_session.room_code RETURNING * INTO v_session;
    RETURN jsonb_build_object('ok',true,'finished',true,'host_score',v_session.host_score,
      'guest_score',v_session.guest_score,'question_index',v_session.current_question_index);
  END IF;

  UPDATE public.doma_battle_sessions
     SET current_question_index=v_next,question_deadline=clock_timestamp()+interval '20 seconds'
   WHERE room_code=v_session.room_code RETURNING * INTO v_session;
  RETURN jsonb_build_object('ok',true,'finished',false,'question_index',v_session.current_question_index,
    'question_deadline',v_session.question_deadline,'host_score',v_session.host_score,
    'guest_score',v_session.guest_score,'next_question_id',v_session.question_ids[v_next+1]);
END;
$function$

REVOKE ALL ON FUNCTION public.doma_advance_battle_session(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_advance_battle_session(text) TO authenticated;

CREATE OR REPLACE FUNCTION public.doma_record_battle(p_room_code text, p_quiz_id uuid, p_quiz_title text, p_grade_id uuid, p_player1_id uuid, p_player1_name text, p_player1_score integer, p_player2_id uuid, p_player2_name text, p_player2_score integer, p_winner_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid:=auth.uid();
  v_session public.doma_battle_sessions%rowtype;
  v_id uuid;
  v_existing public.battle_matches%rowtype;
  v_winner uuid;
  v_name1 text;
  v_name2 text;
  v_quiz_title text;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  SELECT * INTO v_session FROM public.doma_battle_sessions
   WHERE room_code=upper(trim(coalesce(p_room_code,''))) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Battle session not found; reload the app and create a new Battle'; END IF;
  IF v_uid<>v_session.host_id AND v_uid IS DISTINCT FROM v_session.guest_id THEN
    RAISE EXCEPTION 'You are not a participant in this Battle';
  END IF;
  IF v_session.status<>'finished' THEN RAISE EXCEPTION 'Battle has not been completed'; END IF;
  IF p_quiz_id IS DISTINCT FROM v_session.quiz_id OR p_grade_id IS DISTINCT FROM v_session.grade_id
     OR p_player1_id IS DISTINCT FROM v_session.host_id OR p_player2_id IS DISTINCT FROM v_session.guest_id THEN
    RAISE EXCEPTION 'Battle result does not match the recorded session';
  END IF;

  SELECT coalesce(nullif(trim(p.full_name),''),nullif(trim(p_player1_name),''),'Player 1')
    INTO v_name1 FROM public.profiles p WHERE p.id=v_session.host_id;
  SELECT coalesce(nullif(trim(p.full_name),''),nullif(trim(p_player2_name),''),'Player 2')
    INTO v_name2 FROM public.profiles p WHERE p.id=v_session.guest_id;
  SELECT q.title INTO v_quiz_title FROM public.quizzes q WHERE q.id=v_session.quiz_id;
  v_winner:=CASE WHEN v_session.host_score>v_session.guest_score THEN v_session.host_id
                 WHEN v_session.guest_score>v_session.host_score THEN v_session.guest_id ELSE NULL END;

  INSERT INTO public.battle_matches(
    room_code,quiz_id,quiz_title,grade_id,
    player1_id,player1_name,player1_score,player2_id,player2_name,player2_score,winner_id
  ) VALUES (
    v_session.room_code,v_session.quiz_id,coalesce(nullif(trim(v_quiz_title),''),coalesce(nullif(trim(p_quiz_title),''),'Quiz')),
    v_session.grade_id,v_session.host_id,v_name1,v_session.host_score,v_session.guest_id,v_name2,v_session.guest_score,v_winner
  )
  ON CONFLICT(room_code) DO NOTHING
  RETURNING id INTO v_id;

  IF v_id IS NOT NULL THEN
    RETURN jsonb_build_object('ok',true,'id',v_id,'already_recorded',false,
      'host_score',v_session.host_score,'guest_score',v_session.guest_score);
  END IF;

  SELECT * INTO v_existing FROM public.battle_matches WHERE room_code=v_session.room_code;
  IF NOT FOUND OR v_existing.player1_id IS DISTINCT FROM v_session.host_id
     OR v_existing.player2_id IS DISTINCT FROM v_session.guest_id
     OR v_existing.quiz_id IS DISTINCT FROM v_session.quiz_id
     OR v_existing.grade_id IS DISTINCT FROM v_session.grade_id
     OR v_existing.player1_score IS DISTINCT FROM v_session.host_score
     OR v_existing.player2_score IS DISTINCT FROM v_session.guest_score THEN
    RAISE EXCEPTION 'A conflicting Battle record already exists for this room';
  END IF;
  RETURN jsonb_build_object('ok',true,'id',v_existing.id,'already_recorded',true,
    'host_score',v_session.host_score,'guest_score',v_session.guest_score);
END;
$function$

REVOKE ALL ON FUNCTION public.doma_record_battle(text,uuid,text,uuid,uuid,text,integer,uuid,text,integer,uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_record_battle(text,uuid,text,uuid,uuid,text,integer,uuid,text,integer,uuid) TO authenticated;

