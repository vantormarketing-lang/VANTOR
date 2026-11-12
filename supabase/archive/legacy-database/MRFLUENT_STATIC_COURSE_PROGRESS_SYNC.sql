-- Deploy once through Supabase SQL Editor / migrations.
-- Records completion from the standalone static Mr. Fluent A1-C2 lesson pages.
-- Authorization is derived from auth.uid(), the active course subscription, and the server-side placement.
CREATE OR REPLACE FUNCTION public.mrfluent_complete_static_english_lesson(
  p_level_code text,
  p_unit_number integer,
  p_sort_order integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $function$
DECLARE
  v_student uuid := auth.uid();
  v_level text := upper(trim(coalesce(p_level_code, '')));
  v_current_level text;
  v_lesson_id uuid;
  v_total integer;
  v_done integer;
  v_level_index integer;
  v_current_index integer;
  v_next text;
BEGIN
  IF v_student IS NULL THEN
    RAISE EXCEPTION 'Please log in first.';
  END IF;
  IF v_level NOT IN ('A1','A2','B1','B2','C1','C2')
     OR p_unit_number IS NULL OR p_unit_number NOT BETWEEN 1 AND 4
     OR p_sort_order IS NULL OR p_sort_order NOT BETWEEN 1 AND 3 THEN
    RAISE EXCEPTION 'Invalid Mr. Fluent lesson position.';
  END IF;
  IF NOT public.mrfluent_english_has_active_subscription() THEN
    RAISE EXCEPTION 'Active English Course subscription required.';
  END IF;
  SELECT current_level_code INTO v_current_level
    FROM public.mrfluent_english_placements
   WHERE student_id = v_student FOR UPDATE;
  IF v_current_level IS NULL THEN
    RAISE EXCEPTION 'Complete the placement test first.';
  END IF;
  SELECT count(*) INTO v_total
    FROM public.mrfluent_english_lessons le
    JOIN public.mrfluent_english_units u ON u.id = le.unit_id
    JOIN public.mrfluent_english_levels l ON l.id = u.level_id
   WHERE l.code = v_level AND l.is_published = true;
  IF v_total <> 12 THEN
    RAISE EXCEPTION 'This course level is not configured for its 12-lesson student page.';
  END IF;
  v_level_index := array_position(ARRAY['A1','A2','B1','B2','C1','C2']::text[], v_level);
  v_current_index := array_position(ARRAY['A1','A2','B1','B2','C1','C2']::text[], upper(v_current_level));
  IF upper(v_current_level) <> v_level THEN
    SELECT count(*) INTO v_done
      FROM public.mrfluent_english_lesson_progress p
      JOIN public.mrfluent_english_lessons le ON le.id = p.lesson_id
      JOIN public.mrfluent_english_units u ON u.id = le.unit_id
      JOIN public.mrfluent_english_levels l ON l.id = u.level_id
     WHERE p.student_id = v_student AND l.code = v_level AND l.is_published = true;
    IF v_current_index IS NOT NULL AND v_level_index IS NOT NULL
       AND v_level_index < v_current_index AND v_done >= v_total THEN
      RETURN jsonb_build_object(
        'ok', true, 'completed_count', v_done, 'lesson_count', v_total,
        'current_level_code', upper(v_current_level), 'level_completed', true,
        'already_completed', true
      );
    END IF;
    RAISE EXCEPTION 'This lesson is not in your current level.';
  END IF;
  SELECT le.id INTO v_lesson_id
    FROM public.mrfluent_english_lessons le
    JOIN public.mrfluent_english_units u ON u.id = le.unit_id
    JOIN public.mrfluent_english_levels l ON l.id = u.level_id
   WHERE l.code = v_level AND l.is_published = true
     AND u.unit_number = p_unit_number AND le.sort_order = p_sort_order
   ORDER BY le.id LIMIT 1;
  IF v_lesson_id IS NULL THEN
    RAISE EXCEPTION 'Lesson position was not found for the current level.';
  END IF;
  INSERT INTO public.mrfluent_english_lesson_progress(student_id, lesson_id)
  VALUES (v_student, v_lesson_id)
  ON CONFLICT (student_id, lesson_id) DO NOTHING;
  SELECT count(*) INTO v_done
    FROM public.mrfluent_english_lesson_progress p
    JOIN public.mrfluent_english_lessons le ON le.id = p.lesson_id
    JOIN public.mrfluent_english_units u ON u.id = le.unit_id
    JOIN public.mrfluent_english_levels l ON l.id = u.level_id
   WHERE p.student_id = v_student AND l.code = v_level AND l.is_published = true;
  v_next := CASE v_level
    WHEN 'A1' THEN 'A2' WHEN 'A2' THEN 'B1' WHEN 'B1' THEN 'B2'
    WHEN 'B2' THEN 'C1' WHEN 'C1' THEN 'C2' ELSE 'C2' END;
  IF v_done >= v_total AND v_level <> 'C2' THEN
    UPDATE public.mrfluent_english_placements
       SET current_level_code = v_next, updated_at = now()
     WHERE student_id = v_student;
  ELSE
    v_next := v_level;
  END IF;
  RETURN jsonb_build_object(
    'ok', true, 'completed_count', v_done, 'lesson_count', v_total,
    'current_level_code', v_next, 'level_completed', (v_done >= v_total)
  );
END;
$function$;
REVOKE ALL ON FUNCTION public.mrfluent_complete_static_english_lesson(text, integer, integer) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.mrfluent_complete_static_english_lesson(text, integer, integer) FROM anon;
GRANT EXECUTE ON FUNCTION public.mrfluent_complete_static_english_lesson(text, integer, integer) TO authenticated;