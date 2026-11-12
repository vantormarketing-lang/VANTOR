CREATE OR REPLACE FUNCTION public.doma_submit_battle_answer(
  p_room_code text,
  p_question_index integer,
  p_question_id uuid,
  p_answer text,
  p_time_remaining_ms integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public'
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
$function$;

REVOKE ALL ON FUNCTION public.doma_submit_battle_answer(text,integer,uuid,text,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.doma_submit_battle_answer(text,integer,uuid,text,integer) TO authenticated;