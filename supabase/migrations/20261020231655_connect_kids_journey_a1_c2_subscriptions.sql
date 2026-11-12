alter table public.mrfluent_kids_tracks drop constraint if exists mrfluent_kids_tracks_code_check;
alter table public.mrfluent_kids_tracks
  add constraint mrfluent_kids_tracks_code_check
  check (code in ('START_ZERO','PRIMARY_SUPPORT','KIDS_JOURNEY'));

alter table public.mrfluent_kids_levels drop constraint if exists mrfluent_kids_levels_code_check;
alter table public.mrfluent_kids_levels
  add constraint mrfluent_kids_levels_code_check
  check (code in ('K0','K1','K2','K3','K4','K5','P12','P34','P56','A1','B1','C1','A2','B2','C2'));

insert into public.mrfluent_kids_tracks
  (code,title,description,price_egp,duration_days,sort_order,is_published)
values
  ('KIDS_JOURNEY','Mr. Fluent Kids Journey (A1–C2)',
   'The six-level Mr. Fluent Kids learning journey displayed on the main DOMA Academy site. Each level has its own independent 30-day access request.',
   100,30,3,true)
on conflict (code) do update
set title=excluded.title,
    description=excluded.description,
    price_egp=100,
    duration_days=30,
    sort_order=3,
    is_published=true,
    updated_at=now();

insert into public.mrfluent_kids_levels
  (track_id,code,title,description,sort_order,is_published)
select t.id,v.code,v.title,v.description,v.sort_order,true
from public.mrfluent_kids_tracks t
cross join (values
  ('A1','My First ABC','Letters, sounds and first words',1),
  ('B1','My First Words','Useful words for daily life',2),
  ('C1','My First Sentences','Build sentences and follow stories',3),
  ('A2','Word Explorers','Vocabulary in everyday contexts',4),
  ('B2','Reading Builders','Read, understand and connect ideas',5),
  ('C2','Confident English','Advanced reading and communication',6)
) as v(code,title,description,sort_order)
where t.code='KIDS_JOURNEY'
on conflict (code) do update
set track_id=excluded.track_id,
    title=excluded.title,
    description=excluded.description,
    sort_order=excluded.sort_order,
    is_published=true,
    updated_at=now();

-- These published metadata rows tell the approval workflow that a matching static
-- A1–C2 level exists on index.html. Learning activities themselves remain in the
-- static Kids SPA; this does not expose the private DB curriculum to other students.
insert into public.mrfluent_kids_units(level_id,title,description,sort_order,is_published)
select l.id, l.code || ' static journey content',
       'Published static course content rendered in index.html?kids=' ||
       lower(l.code) || '.',
       0,true
from public.mrfluent_kids_levels l
join public.mrfluent_kids_tracks t on t.id=l.track_id
where t.code='KIDS_JOURNEY'
on conflict (level_id,sort_order) do update
set title=excluded.title,description=excluded.description,is_published=true,updated_at=now();

insert into public.mrfluent_kids_lessons(unit_id,title,objective,lesson_type,lesson_payload,sort_order,is_published)
select u.id, l.code || ' static lesson page',
       'The corresponding published interactive learning content is rendered from index.html.',
       'learn',
       jsonb_build_object('source','index.html','route',lower(l.code),'static_content',true),
       0,true
from public.mrfluent_kids_units u
join public.mrfluent_kids_levels l on l.id=u.level_id
join public.mrfluent_kids_tracks t on t.id=l.track_id
where t.code='KIDS_JOURNEY' and u.sort_order=0
on conflict (unit_id,sort_order) do update
set title=excluded.title,objective=excluded.objective,lesson_type=excluded.lesson_type,
    lesson_payload=excluded.lesson_payload,is_published=true,updated_at=now();
