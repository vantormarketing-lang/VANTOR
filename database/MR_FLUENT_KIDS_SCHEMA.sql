-- Mr. Fluent Kids schema. Applied to the connected Supabase project by migrations
-- mrfluent_kids_foundation and mrfluent_kids_access_guards.
-- All objects are separate from the adult A1-C2 course and use the mrfluent_kids_ prefix.

create table if not exists public.mrfluent_kids_tracks (
 id uuid primary key default gen_random_uuid(),
 code text not null unique check (code in ('START_ZERO','PRIMARY_SUPPORT')),
 title text not null, description text not null default '',
 price_egp numeric(10,2) null check (price_egp is null or price_egp >= 0),
 duration_days integer null check (duration_days is null or duration_days between 1 and 365),
 sort_order integer not null default 0, is_published boolean not null default true,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

alter table public.mrfluent_kids_tracks add column if not exists duration_days integer null check (duration_days is null or duration_days between 1 and 365);

create table if not exists public.mrfluent_kids_levels (
 id uuid primary key default gen_random_uuid(),
 track_id uuid not null references public.mrfluent_kids_tracks(id) on delete cascade,
 code text not null unique check (code in ('K0','K1','K2','K3','K4','K5','P12','P34','P56')),
 title text not null, description text not null default '',
 sort_order integer not null default 0, is_published boolean not null default true,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(track_id, sort_order)
);
create unique index if not exists mrfluent_kids_levels_id_track_unique on public.mrfluent_kids_levels(id,track_id);

create table if not exists public.mrfluent_kids_units (
 id uuid primary key default gen_random_uuid(),
 level_id uuid not null references public.mrfluent_kids_levels(id) on delete cascade,
 title text not null, description text not null default '',
 sort_order integer not null default 0, is_published boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(level_id, sort_order)
);

create table if not exists public.mrfluent_kids_lessons (
 id uuid primary key default gen_random_uuid(),
 unit_id uuid not null references public.mrfluent_kids_units(id) on delete cascade,
 title text not null, objective text not null default '',
 lesson_type text not null default 'learn' check (lesson_type in ('learn','game','review','quiz','story')),
 lesson_payload jsonb not null default '{}'::jsonb, illustration_url text null, audio_url text null,
 sort_order integer not null default 0, is_published boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(unit_id, sort_order)
);

create table if not exists public.mrfluent_kids_subscriptions (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 track_id uuid not null,
 level_id uuid not null,
 status text not null default 'active' check (status in ('active','expired','cancelled','paused')),
 starts_at timestamptz not null default now(), expires_at timestamptz not null,
 price_egp numeric(10,2) null check (price_egp is null or price_egp >= 0),
 created_by uuid null references auth.users(id) on delete set null,
 admin_note text not null default '',
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 foreign key (level_id,track_id) references public.mrfluent_kids_levels(id,track_id) on delete restrict
);

create table if not exists public.mrfluent_kids_enrollment_requests (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 track_id uuid not null,
 requested_level_id uuid not null,
 guardian_contact text not null, note text not null default '',
 status text not null default 'pending' check (status in ('pending','approved','rejected','cancelled')),
 admin_note text not null default '',
 reviewed_by uuid null references auth.users(id) on delete set null, reviewed_at timestamptz null,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 foreign key (requested_level_id,track_id) references public.mrfluent_kids_levels(id,track_id) on delete restrict
);

create table if not exists public.mrfluent_kids_placement_results (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 track_id uuid not null references public.mrfluent_kids_tracks(id) on delete restrict,
 recommended_level_id uuid not null references public.mrfluent_kids_levels(id) on delete restrict,
 score integer not null default 0 check (score >= 0),
 total_questions integer not null default 0 check (total_questions >= 0 and score <= total_questions),
 created_at timestamptz not null default now()
);

create table if not exists public.mrfluent_kids_progress (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 lesson_id uuid not null references public.mrfluent_kids_lessons(id) on delete cascade,
 status text not null default 'started' check (status in ('started','completed')),
 best_score integer not null default 0 check (best_score between 0 and 100),
 stars integer not null default 0 check (stars between 0 and 3),
 started_at timestamptz not null default now(), completed_at timestamptz null,
 updated_at timestamptz not null default now(), unique(user_id,lesson_id)
);

create index if not exists mrfluent_kids_levels_track_sort_idx on public.mrfluent_kids_levels(track_id,sort_order);
create index if not exists mrfluent_kids_units_level_sort_idx on public.mrfluent_kids_units(level_id,sort_order);
create index if not exists mrfluent_kids_lessons_unit_sort_idx on public.mrfluent_kids_lessons(unit_id,sort_order);
create index if not exists mrfluent_kids_subscriptions_active_idx on public.mrfluent_kids_subscriptions(user_id,status,starts_at,expires_at);
create index if not exists mrfluent_kids_requests_user_status_idx on public.mrfluent_kids_enrollment_requests(user_id,status,created_at desc);
create index if not exists mrfluent_kids_progress_user_idx on public.mrfluent_kids_progress(user_id,updated_at desc);

alter table public.mrfluent_kids_tracks enable row level security;
alter table public.mrfluent_kids_levels enable row level security;
alter table public.mrfluent_kids_units enable row level security;
alter table public.mrfluent_kids_lessons enable row level security;
alter table public.mrfluent_kids_subscriptions enable row level security;
alter table public.mrfluent_kids_enrollment_requests enable row level security;
alter table public.mrfluent_kids_placement_results enable row level security;
alter table public.mrfluent_kids_progress enable row level security;

drop policy if exists "kids published tracks are public" on public.mrfluent_kids_tracks;
create policy "kids published tracks are public" on public.mrfluent_kids_tracks
 for select to anon,authenticated using (is_published=true);
drop policy if exists "kids staff manage tracks" on public.mrfluent_kids_tracks;
create policy "kids staff manage tracks" on public.mrfluent_kids_tracks for all to authenticated
 using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "kids published levels are public" on public.mrfluent_kids_levels;
create policy "kids published levels are public" on public.mrfluent_kids_levels
 for select to anon,authenticated using (is_published=true);
drop policy if exists "kids staff manage levels" on public.mrfluent_kids_levels;
create policy "kids staff manage levels" on public.mrfluent_kids_levels for all to authenticated
 using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "kids units only for assigned active level" on public.mrfluent_kids_units;
create policy "kids units only for assigned active level" on public.mrfluent_kids_units for select to authenticated using (
 (select public.mrfluent_english_is_staff()) or (is_published=true and exists(
  select 1 from public.mrfluent_kids_levels lv
  join public.mrfluent_kids_subscriptions s on s.level_id=lv.id and s.track_id=lv.track_id
  where lv.id=mrfluent_kids_units.level_id and s.user_id=(select auth.uid())
   and s.status='active' and s.starts_at<=now() and s.expires_at>now()
 )));
drop policy if exists "kids staff manage units" on public.mrfluent_kids_units;
create policy "kids staff manage units" on public.mrfluent_kids_units for all to authenticated
 using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "kids lessons only for assigned active level" on public.mrfluent_kids_lessons;
create policy "kids lessons only for assigned active level" on public.mrfluent_kids_lessons for select to authenticated using (
 (select public.mrfluent_english_is_staff()) or (is_published=true and exists(
  select 1 from public.mrfluent_kids_units u
  join public.mrfluent_kids_levels lv on lv.id=u.level_id
  join public.mrfluent_kids_subscriptions s on s.level_id=lv.id and s.track_id=lv.track_id
  where u.id=mrfluent_kids_lessons.unit_id and u.is_published=true
   and s.user_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()
 )));
drop policy if exists "kids staff manage lessons" on public.mrfluent_kids_lessons;
create policy "kids staff manage lessons" on public.mrfluent_kids_lessons for all to authenticated
 using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "kids read own subscription or staff" on public.mrfluent_kids_subscriptions;
create policy "kids read own subscription or staff" on public.mrfluent_kids_subscriptions for select to authenticated
 using (user_id=(select auth.uid()) or (select public.mrfluent_english_is_staff()));
drop policy if exists "kids staff manage subscriptions" on public.mrfluent_kids_subscriptions;
create policy "kids staff manage subscriptions" on public.mrfluent_kids_subscriptions for all to authenticated
 using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "kids read own enrollment requests or staff" on public.mrfluent_kids_enrollment_requests;
create policy "kids read own enrollment requests or staff" on public.mrfluent_kids_enrollment_requests for select to authenticated
 using (user_id=(select auth.uid()) or (select public.mrfluent_english_is_staff()));
drop policy if exists "kids submit own pending enrollment request" on public.mrfluent_kids_enrollment_requests;
create policy "kids submit own pending enrollment request" on public.mrfluent_kids_enrollment_requests for insert to authenticated with check (
 user_id=(select auth.uid()) and status='pending' and reviewed_by is null and reviewed_at is null
 and exists(select 1 from public.mrfluent_kids_tracks t where t.id=mrfluent_kids_enrollment_requests.track_id and t.is_published=true)
 and exists(select 1 from public.mrfluent_kids_levels l where l.id=mrfluent_kids_enrollment_requests.requested_level_id
  and l.track_id=mrfluent_kids_enrollment_requests.track_id and l.is_published=true));
drop policy if exists "kids staff manage enrollment requests" on public.mrfluent_kids_enrollment_requests;
create policy "kids staff manage enrollment requests" on public.mrfluent_kids_enrollment_requests for all to authenticated
 using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "kids read own placement results or staff" on public.mrfluent_kids_placement_results;
create policy "kids read own placement results or staff" on public.mrfluent_kids_placement_results for select to authenticated
 using (user_id=(select auth.uid()) or (select public.mrfluent_english_is_staff()));
drop policy if exists "kids save own placement result" on public.mrfluent_kids_placement_results;
create policy "kids save own placement result" on public.mrfluent_kids_placement_results for insert to authenticated with check (
 user_id=(select auth.uid())
 and exists(select 1 from public.mrfluent_kids_tracks t where t.id=mrfluent_kids_placement_results.track_id and t.is_published=true)
 and exists(select 1 from public.mrfluent_kids_levels l where l.id=mrfluent_kids_placement_results.recommended_level_id
  and l.track_id=mrfluent_kids_placement_results.track_id and l.is_published=true));

drop policy if exists "kids read own progress or staff" on public.mrfluent_kids_progress;
create policy "kids read own progress or staff" on public.mrfluent_kids_progress for select to authenticated
 using (user_id=(select auth.uid()) or (select public.mrfluent_english_is_staff()));
drop policy if exists "kids create progress for accessible lessons" on public.mrfluent_kids_progress;
create policy "kids create progress for accessible lessons" on public.mrfluent_kids_progress for insert to authenticated with check (
 user_id=(select auth.uid()) and exists(
  select 1 from public.mrfluent_kids_lessons l join public.mrfluent_kids_units u on u.id=l.unit_id
  join public.mrfluent_kids_levels lv on lv.id=u.level_id
  join public.mrfluent_kids_subscriptions s on s.level_id=lv.id and s.track_id=lv.track_id
  where l.id=mrfluent_kids_progress.lesson_id and l.is_published=true and u.is_published=true
   and s.user_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()));
drop policy if exists "kids update own progress for accessible lessons" on public.mrfluent_kids_progress;
create policy "kids update own progress for accessible lessons" on public.mrfluent_kids_progress for update to authenticated
 using (user_id=(select auth.uid()) and exists(
  select 1 from public.mrfluent_kids_lessons l join public.mrfluent_kids_units u on u.id=l.unit_id
  join public.mrfluent_kids_levels lv on lv.id=u.level_id
  join public.mrfluent_kids_subscriptions s on s.level_id=lv.id and s.track_id=lv.track_id
  where l.id=mrfluent_kids_progress.lesson_id and l.is_published=true and u.is_published=true
   and s.user_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()))
 with check (user_id=(select auth.uid()) and exists(
  select 1 from public.mrfluent_kids_lessons l join public.mrfluent_kids_units u on u.id=l.unit_id
  join public.mrfluent_kids_levels lv on lv.id=u.level_id
  join public.mrfluent_kids_subscriptions s on s.level_id=lv.id and s.track_id=lv.track_id
  where l.id=mrfluent_kids_progress.lesson_id and l.is_published=true and u.is_published=true
   and s.user_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()));

grant select on public.mrfluent_kids_tracks,public.mrfluent_kids_levels to anon;
grant select,insert,update,delete on public.mrfluent_kids_tracks,public.mrfluent_kids_levels to authenticated;
grant select,insert,update,delete on public.mrfluent_kids_units,public.mrfluent_kids_lessons,
 public.mrfluent_kids_subscriptions,public.mrfluent_kids_enrollment_requests,
 public.mrfluent_kids_placement_results,public.mrfluent_kids_progress to authenticated;

insert into public.mrfluent_kids_tracks(code,title,description,sort_order,is_published) values
 ('START_ZERO','Start from Zero','Build English from listening and letter sounds to words, sentences and stories.',1,true),
 ('PRIMARY_SUPPORT','Primary School Support','Practice English skills in a pathway aligned to primary school stages.',2,true)
on conflict(code) do update set title=excluded.title,description=excluded.description,sort_order=excluded.sort_order,is_published=excluded.is_published;
insert into public.mrfluent_kids_levels(track_id,code,title,description,sort_order,is_published)
select t.id,v.code,v.title,v.description,v.sort_order,true from (values
 ('START_ZERO','K0','Little Ears','Sound awareness, rhyme and listening games.',1),
 ('START_ZERO','K1','ABC Friends','Uppercase and lowercase letters with letter sounds.',2),
 ('START_ZERO','K2','Tiny Word Builders','Short vowels and blending simple words.',3),
 ('START_ZERO','K3','Sound Teams','Common letter teams and sound patterns.',4),
 ('START_ZERO','K4','Sentence Builders','Decodable sentences and basic comprehension.',5),
 ('START_ZERO','K5','Story Adventures','Short stories, vocabulary and simple conversations.',6),
 ('PRIMARY_SUPPORT','P12','Primary 1–2','Foundations, useful vocabulary and short sentences.',1),
 ('PRIMARY_SUPPORT','P34','Primary 3–4','Reading, vocabulary and core grammar in context.',2),
 ('PRIMARY_SUPPORT','P56','Primary 5–6','Short texts, comprehension and guided writing.',3)
) as v(track_code,code,title,description,sort_order) join public.mrfluent_kids_tracks t on t.code=v.track_code
on conflict(code) do update set track_id=excluded.track_id,title=excluded.title,description=excluded.description,sort_order=excluded.sort_order,is_published=excluded.is_published;


create or replace function public.mrfluent_kids_approve_enrollment_request(
 p_request_id uuid,
 p_admin_note text default 'Approved by admin.'
) returns jsonb
language plpgsql security invoker
set search_path = pg_catalog, public
as $function$
declare
 v_request public.mrfluent_kids_enrollment_requests%rowtype;
 v_track public.mrfluent_kids_tracks%rowtype;
 v_expiry timestamptz;
 v_existing public.mrfluent_kids_subscriptions%rowtype;
begin
 if auth.uid() is null or not public.mrfluent_english_is_staff() then
  raise exception 'Staff access required.' using errcode='42501';
 end if;
 select * into v_request from public.mrfluent_kids_enrollment_requests where id=p_request_id for update;
 if not found then raise exception 'Kids registration request not found.' using errcode='P0002'; end if;
 if v_request.status <> 'pending' then raise exception 'This Kids registration request has already been reviewed.' using errcode='P0001'; end if;
 select * into v_track from public.mrfluent_kids_tracks where id=v_request.track_id and is_published=true;
 if not found then raise exception 'The selected Kids track is not published.' using errcode='P0001'; end if;
 if v_track.price_egp is null or v_track.duration_days is null then
  raise exception 'Set the Kids path price and duration in Admin before approving this request.' using errcode='P0001';
 end if;
 if not exists(select 1 from public.mrfluent_kids_levels l where l.id=v_request.requested_level_id and l.track_id=v_request.track_id and l.is_published=true) then
  raise exception 'The requested level is not published for this path.' using errcode='P0001';
 end if;
 if not exists(
  select 1 from public.mrfluent_kids_units u
  join public.mrfluent_kids_lessons l on l.unit_id=u.id
  where u.level_id=v_request.requested_level_id and u.is_published=true and l.is_published=true
 ) then
  raise exception 'Publish at least one reviewed unit and lesson for this Kids level before activating its subscription.' using errcode='P0001';
 end if;
 -- Only the Kids membership is changed; the A1-C2 course and school-grade subscriptions remain untouched.
 update public.mrfluent_kids_subscriptions set status='cancelled',updated_at=now()
 where user_id=v_request.user_id and status='active' and track_id<>v_request.track_id;
 select * into v_existing from public.mrfluent_kids_subscriptions
 where user_id=v_request.user_id and track_id=v_request.track_id and status='active' and expires_at>now()
 order by expires_at desc limit 1 for update;
 if found then
  update public.mrfluent_kids_subscriptions
  set level_id=v_request.requested_level_id,
      expires_at=greatest(v_existing.expires_at,now())+make_interval(days=>v_track.duration_days),
      price_egp=v_track.price_egp,
      admin_note=coalesce(nullif(trim(p_admin_note),''),admin_note),updated_at=now()
  where id=v_existing.id returning expires_at into v_expiry;
 else
  insert into public.mrfluent_kids_subscriptions(user_id,track_id,level_id,status,starts_at,expires_at,price_egp,created_by,admin_note)
  values(v_request.user_id,v_request.track_id,v_request.requested_level_id,'active',now(),
         now()+make_interval(days=>v_track.duration_days),v_track.price_egp,auth.uid(),
         coalesce(nullif(trim(p_admin_note),''),'Approved by admin.'))
  returning expires_at into v_expiry;
 end if;
 update public.mrfluent_kids_enrollment_requests
 set status='approved',admin_note=coalesce(nullif(trim(p_admin_note),''),'Approved by admin.'),
     reviewed_by=auth.uid(),reviewed_at=now(),updated_at=now()
 where id=p_request_id;
 return jsonb_build_object('ok',true,'request_id',p_request_id,'expires_at',v_expiry,
                           'price_egp',v_track.price_egp,'duration_days',v_track.duration_days);
end;
$function$;
revoke all on function public.mrfluent_kids_approve_enrollment_request(uuid,text) from public,anon;
grant execute on function public.mrfluent_kids_approve_enrollment_request(uuid,text) to authenticated;
