create table if not exists public.mrfluent_kids_journey_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  level_code text not null check (level_code in ('A1','A2','B1','B2','C1','C2')),
  checkpoint_keys text[] not null default '{}'::text[],
  words_seen text[] not null default '{}'::text[],
  stars integer not null default 0 check (stars >= 0 and stars <= 100),
  badges text[] not null default '{}'::text[],
  updated_at timestamptz not null default now(),
  primary key (user_id, level_code)
);
alter table public.mrfluent_kids_journey_progress enable row level security;
drop policy if exists "Kids journey progress read own" on public.mrfluent_kids_journey_progress;
drop policy if exists "Kids journey progress insert own" on public.mrfluent_kids_journey_progress;
drop policy if exists "Kids journey progress update own" on public.mrfluent_kids_journey_progress;
create policy "Kids journey progress read own"
  on public.mrfluent_kids_journey_progress for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "Kids journey progress insert own"
  on public.mrfluent_kids_journey_progress for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Kids journey progress update own"
  on public.mrfluent_kids_journey_progress for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
revoke all on public.mrfluent_kids_journey_progress from anon, public;
grant select, insert, update on public.mrfluent_kids_journey_progress to authenticated;
grant all on public.mrfluent_kids_journey_progress to service_role;
