-- Protected runtime payloads for the six Mr. Fluent standalone course pages.
-- Keep lesson/runtime source out of this public repository; content rows are stored only in Supabase.
-- Run after the Mr. Fluent English Course schema and helper functions are installed.

create table if not exists public.mrfluent_course_runtime_payloads (
  level_id uuid primary key references public.mrfluent_english_levels(id) on delete cascade,
  level_code text not null unique check (level_code in ('A1','A2','B1','B2','C1','C2')),
  script_source text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint mrfluent_course_runtime_payloads_nonempty_source
    check (length(btrim(script_source)) > 0)
);

alter table public.mrfluent_course_runtime_payloads enable row level security;

revoke all on table public.mrfluent_course_runtime_payloads from anon, authenticated;
grant select (level_id, level_code, script_source, updated_at)
  on table public.mrfluent_course_runtime_payloads to authenticated;

drop policy if exists "mrfluent runtime only current paid level or staff"
  on public.mrfluent_course_runtime_payloads;

create policy "mrfluent runtime only current paid level or staff"
  on public.mrfluent_course_runtime_payloads
  for select
  to authenticated
  using (
    (select public.mrfluent_english_is_staff())
    or (
      (select public.mrfluent_english_has_active_subscription())
      and exists (
        select 1
        from public.mrfluent_english_placements p
        where p.student_id = (select auth.uid())
          and p.current_level_code = public.mrfluent_course_runtime_payloads.level_code
      )
      and exists (
        select 1
        from public.mrfluent_english_levels l
        where l.id = public.mrfluent_course_runtime_payloads.level_id
          and l.is_published = true
      )
    )
  );
