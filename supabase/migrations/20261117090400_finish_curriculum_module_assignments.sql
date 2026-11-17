-- Keep the graduation capstone with the project track and keep unpublished
-- daily challenge records out of the published module list.
begin;
update public.programming_lessons
set module_id='project-foundations',sort_order=9,updated_at=now()
where id='project-01-plan-build-ship';
update public.programming_modules
set published=false,updated_at=now()
where id='cs-daily-challenges';
commit;