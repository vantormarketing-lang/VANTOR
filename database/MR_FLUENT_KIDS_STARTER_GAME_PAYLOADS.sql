-- Interactive question payloads for the unpublished Kids game lessons.
-- They remain drafts until reviewed and published in Admin → Mr. Fluent Kids.
update public.mrfluent_kids_lessons l
set lesson_payload = l.lesson_payload || jsonb_build_object(
  'question','Which word rhymes with cat?',
  'options',jsonb_build_array(
    jsonb_build_object('label','hat','emoji','🎩'),
    jsonb_build_object('label','sun','emoji','☀️'),
    jsonb_build_object('label','dog','emoji','🐶')
  ),
  'correct_index',0
), updated_at=now()
from public.mrfluent_kids_units u
join public.mrfluent_kids_levels lv on lv.id=u.level_id
where l.unit_id=u.id and lv.code='K0' and u.sort_order=1 and l.sort_order=2;

update public.mrfluent_kids_lessons l
set lesson_payload = l.lesson_payload || jsonb_build_object(
  'question','Which phrase is correct?',
  'options',jsonb_build_array(
    jsonb_build_object('label','a apple','emoji','🍎'),
    jsonb_build_object('label','an apple','emoji','🍏'),
    jsonb_build_object('label','a banana','emoji','🍌')
  ),
  'correct_index',1
), updated_at=now()
from public.mrfluent_kids_units u
join public.mrfluent_kids_levels lv on lv.id=u.level_id
where l.unit_id=u.id and lv.code='P12' and u.sort_order=1 and l.sort_order=2;