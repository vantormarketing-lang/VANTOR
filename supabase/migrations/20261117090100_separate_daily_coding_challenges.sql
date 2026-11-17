-- Keep daily coding challenges separate from the foundational lesson sequence.
-- Lesson IDs remain unchanged so progress, quizzes, and submissions stay attached.
begin;

do $$
begin
  if (select count(*) from public.programming_lessons where id like 'daily-challenge-%') <> 21 then
    raise exception 'Expected 21 daily challenge lessons; refusing to move an unexpected set';
  end if;
end $$;

insert into public.programming_modules
(id,track_id,title,description,sort_order,published,level,prerequisites)
values
('cs-daily-challenges','computer-science','تحديات التفكير البرمجي اليومية',
 'تدريبات قصيرة متدرجة لتطبيق التفكير المنطقي والخوارزميات على مسائل متنوعة. هذه التحديات مكملة للدروس الأساسية وليست بديلًا عنها.',
 3,true,'beginner',ARRAY['cs-start-here']::text[])
on conflict (id) do update set
 track_id=excluded.track_id,
 title=excluded.title,
 description=excluded.description,
 sort_order=excluded.sort_order,
 published=excluded.published,
 level=excluded.level,
 prerequisites=excluded.prerequisites,
 updated_at=now();

with ranked as (
 select id,
   row_number() over(order by
     (regexp_match(id,'daily-challenge-([0-9]+)-'))[1]::int,
     case when id like '%-beginner' then 1
          when id like '%-intermediate' then 2 else 3 end
   ) as new_order
 from public.programming_lessons
 where id like 'daily-challenge-%'
)
update public.programming_lessons l
set module_id='cs-daily-challenges',
    sort_order=ranked.new_order,
    updated_at=now()
from ranked
where ranked.id=l.id;

commit;
