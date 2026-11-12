create table if not exists public.mrfluent_kids_learning_activities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  activity_type text not null check (activity_type in ('review','mission','project','handwriting','portfolio')),
  activity_key text not null check (length(activity_key) between 1 and 180),
  status text not null default 'active' check (status in ('active','completed','paused')),
  payload jsonb not null default '{}'::jsonb
    check (jsonb_typeof(payload) = 'object' and octet_length(payload::text) <= 16000),
  due_at timestamptz,
  review_interval_days integer not null default 0 check (review_interval_days between 0 and 365),
  review_repetitions integer not null default 0 check (review_repetitions between 0 and 50),
  review_last_result boolean,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint mrfluent_kids_learning_activities_user_type_key_unique unique (user_id, activity_type, activity_key)
);
create index if not exists mrfluent_kids_learning_activities_due_idx on public.mrfluent_kids_learning_activities (user_id, activity_type, due_at) where status = 'active';
create index if not exists mrfluent_kids_learning_activities_created_idx on public.mrfluent_kids_learning_activities (user_id, created_at desc);
alter table public.mrfluent_kids_learning_activities enable row level security;
revoke all on table public.mrfluent_kids_learning_activities from anon, public;
grant select, insert, update, delete on table public.mrfluent_kids_learning_activities to authenticated;
drop policy if exists "kids learning activities select own" on public.mrfluent_kids_learning_activities;
create policy "kids learning activities select own" on public.mrfluent_kids_learning_activities for select to authenticated using ((select auth.uid()) = user_id);
drop policy if exists "kids learning activities insert own" on public.mrfluent_kids_learning_activities;
create policy "kids learning activities insert own" on public.mrfluent_kids_learning_activities for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists "kids learning activities update own" on public.mrfluent_kids_learning_activities;
create policy "kids learning activities update own" on public.mrfluent_kids_learning_activities for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
drop policy if exists "kids learning activities delete own" on public.mrfluent_kids_learning_activities;
create policy "kids learning activities delete own" on public.mrfluent_kids_learning_activities for delete to authenticated using ((select auth.uid()) = user_id);
