-- Expand curriculum metadata and exercise/project assessment structure.
alter table public.programming_modules
  add column if not exists level text not null default 'beginner',
  add column if not exists prerequisites text[] not null default '{}';

alter table public.programming_lessons
  add column if not exists learning_objectives text[] not null default '{}',
  add column if not exists prerequisites text[] not null default '{}';

alter table public.programming_exercises
  add column if not exists test_cases jsonb not null default '[]'::jsonb,
  add column if not exists hints jsonb not null default '[]'::jsonb,
  add column if not exists solution_code text not null default '',
  add column if not exists rubric jsonb not null default '[]'::jsonb,
  add column if not exists grading_mode text not null default 'manual';

alter table public.programming_projects
  add column if not exists starter_files jsonb not null default '{}'::jsonb,
  add column if not exists rubric jsonb not null default '[]'::jsonb,
  add column if not exists estimated_hours integer not null default 2,
  add column if not exists difficulty text not null default 'beginner';

do $$
begin
  if not exists (select 1 from pg_constraint where conname='programming_modules_level_check') then
    alter table public.programming_modules
      add constraint programming_modules_level_check
      check (level in ('beginner','intermediate','advanced'));
  end if;
  if not exists (select 1 from pg_constraint where conname='programming_exercises_grading_mode_check') then
    alter table public.programming_exercises
      add constraint programming_exercises_grading_mode_check
      check (grading_mode in ('manual','stdout','unit_tests'));
  end if;
  if not exists (select 1 from pg_constraint where conname='programming_projects_difficulty_check') then
    alter table public.programming_projects
      add constraint programming_projects_difficulty_check
      check (difficulty in ('beginner','intermediate','advanced'));
  end if;
  if not exists (select 1 from pg_constraint where conname='programming_projects_estimated_hours_check') then
    alter table public.programming_projects
      add constraint programming_projects_estimated_hours_check
      check (estimated_hours between 1 and 200);
  end if;
end $$;

create index if not exists programming_modules_track_level_order_idx
  on public.programming_modules(track_id, level, sort_order);
create index if not exists programming_lessons_module_order_idx
  on public.programming_lessons(module_id, sort_order);
