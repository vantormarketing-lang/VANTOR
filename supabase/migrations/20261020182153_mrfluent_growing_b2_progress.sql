create table if not exists public.mrfluent_growing_b2_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  level_code text not null default 'B2' check (level_code = 'B2'),
  completed_words text[] not null default '{}'::text[],
  completed_activities text[] not null default '{}'::text[],
  best_quiz_score integer not null default 0 check (best_quiz_score between 0 and 8),
  quiz_attempts integer not null default 0 check (quiz_attempts >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, level_code)
);
alter table public.mrfluent_growing_b2_progress enable row level security;
revoke all on table public.mrfluent_growing_b2_progress from anon, public, authenticated;
grant select, insert, update on table public.mrfluent_growing_b2_progress to authenticated;
grant all on table public.mrfluent_growing_b2_progress to service_role;
drop policy if exists "students read own B2 progress" on public.mrfluent_growing_b2_progress;
create policy "students read own B2 progress"
  on public.mrfluent_growing_b2_progress for select to authenticated
  using ((select auth.uid()) = user_id);
drop policy if exists "students insert own B2 progress" on public.mrfluent_growing_b2_progress;
create policy "students insert own B2 progress"
  on public.mrfluent_growing_b2_progress for insert to authenticated
  with check ((select auth.uid()) = user_id);
drop policy if exists "students update own B2 progress" on public.mrfluent_growing_b2_progress;
create policy "students update own B2 progress"
  on public.mrfluent_growing_b2_progress for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);