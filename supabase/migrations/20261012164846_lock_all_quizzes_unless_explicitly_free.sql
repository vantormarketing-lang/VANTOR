DO $migration$
DECLARE fn record; def text; old_block text; new_block text;
BEGIN
 old_block := $old$IF NOT coalesce(q_free, false) AND NOT EXISTS (
      SELECT 1
        FROM public.subscriptions AS s
       WHERE s.student_id = auth.uid()
         AND s.grade_id = q_grade
         AND lower(trim(coalesce(s.status, ''))) = 'active'
         AND s.expires_at > now()
    ) THEN$old$;
 new_block := 'IF NOT coalesce(q_free, false) THEN';
 FOR fn IN SELECT p.oid,p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.proname='doma_get_quiz_questions'
 LOOP
  def:=pg_get_functiondef(fn.oid);
  IF position(old_block IN def)=0 THEN RAISE EXCEPTION 'Expected access condition not found in %',fn.proname; END IF;
  EXECUTE replace(def,old_block,new_block);
 END LOOP;

 old_block := $old$IF NOT coalesce(q_free, false) AND NOT EXISTS (
      SELECT 1
      FROM public.subscriptions s
      WHERE s.student_id = auth.uid()
        AND s.grade_id = q_grade
        AND lower(trim(coalesce(s.status, ''))) = 'active'
        AND s.expires_at > now()
    ) THEN$old$;
 FOR fn IN SELECT p.oid,p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.proname='doma_submit_quiz'
 LOOP
  def:=pg_get_functiondef(fn.oid);
  IF position(old_block IN def)=0 THEN RAISE EXCEPTION 'Expected access condition not found in %',fn.proname; END IF;
  EXECUTE replace(def,old_block,new_block);
 END LOOP;

 old_block := $old$IF NOT coalesce(q.is_free, false) AND NOT EXISTS (
      SELECT 1
      FROM public.subscriptions s
      WHERE s.student_id = v_uid
        AND s.grade_id = q.grade_id
        AND lower(trim(coalesce(s.status, ''))) = 'active'
        AND s.expires_at > now()
    ) THEN$old$;
 new_block := 'IF NOT coalesce(q.is_free, false) THEN';
 SELECT pg_get_functiondef(p.oid) INTO def FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.proname='doma_quiz_start_gate';
 IF def IS NULL OR position(old_block IN def)=0 THEN RAISE EXCEPTION 'Expected access condition not found in doma_quiz_start_gate'; END IF;
 EXECUTE replace(def,old_block,new_block);

 old_block := $old$AND (
      false
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
    )$old$;
 new_block := 'AND q.is_published = true AND q.is_free = true';
 SELECT pg_get_functiondef(p.oid) INTO def FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.proname='doma_get_question_bank';
 IF def IS NULL OR position(old_block IN def)=0 THEN RAISE EXCEPTION 'Expected access condition not found in doma_get_question_bank'; END IF;
 EXECUTE replace(def,old_block,new_block);
END;
$migration$;