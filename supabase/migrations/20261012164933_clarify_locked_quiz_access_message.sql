DO $migration$
DECLARE fn record; def text;
BEGIN
 FOR fn IN SELECT p.oid,p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
           WHERE n.nspname='public' AND p.proname IN ('doma_get_quiz_questions','doma_quiz_start_gate','doma_submit_quiz')
 LOOP
   def:=pg_get_functiondef(fn.oid);
   def:=replace(def,'Active subscription required','Quiz is locked. Ask your teacher to mark it Free.');
   EXECUTE def;
 END LOOP;
END;
$migration$;