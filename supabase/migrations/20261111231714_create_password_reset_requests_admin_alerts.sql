create table if not exists public.password_reset_requests (
  id uuid primary key default gen_random_uuid(),
  phone text not null,
  student_id uuid references public.profiles(id) on delete set null,
  status text not null default 'pending'
    check (status in ('pending','contacted','completed','dismissed')),
  created_at timestamptz not null default now(),
  handled_at timestamptz,
  handled_by uuid references public.profiles(id) on delete set null
);

create index if not exists password_reset_requests_status_created_idx
  on public.password_reset_requests(status, created_at desc);

create or replace function public.doma_is_admin()
returns boolean language sql stable security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and lower(role) = 'admin'
  );
$$;

revoke all on function public.doma_is_admin() from public, anon;
grant execute on function public.doma_is_admin() to authenticated;

alter table public.password_reset_requests enable row level security;
revoke all on public.password_reset_requests from anon, public;
grant select, update on public.password_reset_requests to authenticated;

drop policy if exists "password reset requests admin read" on public.password_reset_requests;
create policy "password reset requests admin read"
  on public.password_reset_requests for select to authenticated
  using (public.doma_is_admin());

drop policy if exists "password reset requests admin update" on public.password_reset_requests;
create policy "password reset requests admin update"
  on public.password_reset_requests for update to authenticated
  using (public.doma_is_admin()) with check (public.doma_is_admin());

do $$
begin
  if not exists (select 1 from pg_publication_tables
    where pubname='supabase_realtime' and schemaname='public'
      and tablename='password_reset_requests') then
    alter publication supabase_realtime add table public.password_reset_requests;
  end if;
end $$;
