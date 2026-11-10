-- Independent Programming Academy subscription and payment workflow.
create table if not exists public.programming_course_payment_requests (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references auth.users(id) on delete cascade,
  amount numeric(10,2) not null default 100 check (amount = 100),
  sender_phone text not null,
  proof_path text not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  admin_note text,
  reviewed_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);
create unique index if not exists programming_one_pending_payment_per_student
  on public.programming_course_payment_requests(student_id) where status='pending';
create table if not exists public.programming_course_subscriptions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references auth.users(id) on delete cascade,
  amount numeric(10,2) not null default 100 check (amount = 100),
  starts_at timestamptz not null default now(),
  expires_at timestamptz not null,
  status text not null default 'active' check (status in ('active','expired','cancelled')),
  request_id uuid not null unique references public.programming_course_payment_requests(id) on delete restrict,
  created_at timestamptz not null default now(),
  check (expires_at > starts_at)
);
create index if not exists programming_course_subscriptions_student_expiry
  on public.programming_course_subscriptions(student_id, status, expires_at desc);
alter table public.programming_course_payment_requests enable row level security;
alter table public.programming_course_subscriptions enable row level security;
drop policy if exists "Programming payment requests own or staff read" on public.programming_course_payment_requests;
create policy "Programming payment requests own or staff read" on public.programming_course_payment_requests for select to authenticated using (student_id = (select auth.uid()) or public.mrfluent_english_is_staff());
drop policy if exists "Programming subscriptions own or staff read" on public.programming_course_subscriptions;
create policy "Programming subscriptions own or staff read" on public.programming_course_subscriptions for select to authenticated using (student_id = (select auth.uid()) or public.mrfluent_english_is_staff());
grant select on public.programming_course_payment_requests, public.programming_course_subscriptions to authenticated;
create or replace function public.programming_create_payment_request(p_sender_phone text,p_proof_path text) returns uuid language plpgsql security definer set search_path='' as $function$
declare v_id uuid;
begin
 if auth.uid() is null then raise exception 'Please sign in before requesting Programming Academy access.'; end if;
 if nullif(btrim(p_sender_phone),'') is null or length(btrim(p_sender_phone))<5 then raise exception 'Enter a valid Mobile Cash sender number.'; end if;
 if p_proof_path is null or p_proof_path not like auth.uid()::text||'/programming/%' then raise exception 'Receipt path does not belong to this Programming Academy request.'; end if;
 if not exists(select 1 from storage.objects o where o.bucket_id='payment-proofs' and o.name=p_proof_path) then raise exception 'Uploaded payment receipt was not found.'; end if;
 if not exists(select 1 from public.profiles p where p.id=auth.uid()) then raise exception 'Student profile not found.'; end if;
 if exists(select 1 from public.programming_course_subscriptions s where s.student_id=auth.uid() and s.status='active' and s.starts_at<=now() and s.expires_at>now()) then raise exception 'Programming Academy access is already active.'; end if;
 if exists(select 1 from public.programming_course_payment_requests r where r.student_id=auth.uid() and r.status='pending') then raise exception 'A Programming Academy payment request is already pending.'; end if;
 insert into public.programming_course_payment_requests(student_id,amount,sender_phone,proof_path,status) values(auth.uid(),100,btrim(p_sender_phone),p_proof_path,'pending') returning id into v_id;
 return v_id;
end;$function$;
create or replace function public.programming_admin_list_payment_requests() returns table(id uuid,student_id uuid,student_name text,student_phone text,amount numeric,sender_phone text,proof_path text,status text,created_at timestamptz) language plpgsql stable security definer set search_path='' as $function$
begin
 if not public.mrfluent_english_is_staff() then raise exception 'Admin or teacher access required.'; end if;
 return query select r.id,r.student_id,coalesce(p.full_name,''),coalesce(p.phone,''),r.amount,r.sender_phone,r.proof_path,r.status,r.created_at from public.programming_course_payment_requests r left join public.profiles p on p.id=r.student_id order by case when r.status='pending' then 0 else 1 end,r.created_at desc;
end;$function$;
create or replace function public.programming_approve_payment_request(p_request_id uuid,p_note text default 'Payment verified by admin.') returns jsonb language plpgsql security definer set search_path='' as $function$
declare v_req public.programming_course_payment_requests%rowtype; v_sub public.programming_course_subscriptions%rowtype; v_start timestamptz;
begin
 if not public.mrfluent_english_is_staff() then raise exception 'Admin or teacher access required.'; end if;
 select * into v_req from public.programming_course_payment_requests where id=p_request_id for update;
 if not found then raise exception 'Programming Academy payment request not found.'; end if;
 if v_req.status='approved' then select * into v_sub from public.programming_course_subscriptions where request_id=v_req.id; return jsonb_build_object('ok',true,'already_approved',true,'subscription_id',v_sub.id,'starts_at',v_sub.starts_at,'expires_at',v_sub.expires_at,'student_id',v_req.student_id,'amount',v_sub.amount); end if;
 if v_req.status<>'pending' then raise exception 'This request has already been rejected.'; end if;
 select greatest(now(),coalesce(max(s.expires_at),now())) into v_start from public.programming_course_subscriptions s where s.student_id=v_req.student_id and s.status='active' and s.expires_at>now();
 insert into public.programming_course_subscriptions(student_id,amount,starts_at,expires_at,status,request_id) values(v_req.student_id,100,v_start,v_start+interval '30 days','active',v_req.id) returning * into v_sub;
 update public.programming_course_payment_requests set status='approved',admin_note=nullif(btrim(coalesce(p_note,'')),''),reviewed_by=auth.uid(),reviewed_at=now() where id=v_req.id;
 return jsonb_build_object('ok',true,'subscription_id',v_sub.id,'starts_at',v_sub.starts_at,'expires_at',v_sub.expires_at,'student_id',v_req.student_id,'amount',100);
end;$function$;
create or replace function public.programming_reject_payment_request(p_request_id uuid,p_note text default 'Payment receipt could not be verified.') returns jsonb language plpgsql security definer set search_path='' as $function$
declare v_req public.programming_course_payment_requests%rowtype;
begin
 if not public.mrfluent_english_is_staff() then raise exception 'Admin or teacher access required.'; end if;
 select * into v_req from public.programming_course_payment_requests where id=p_request_id for update;
 if not found then raise exception 'Programming Academy payment request not found.'; end if;
 if v_req.status<>'pending' then raise exception 'This request has already been reviewed.'; end if;
 update public.programming_course_payment_requests set status='rejected',admin_note=nullif(btrim(coalesce(p_note,'')),''),reviewed_by=auth.uid(),reviewed_at=now() where id=v_req.id;
 return jsonb_build_object('ok',true,'request_id',v_req.id,'student_id',v_req.student_id,'status','rejected');
end;$function$;
revoke all on function public.programming_create_payment_request(text,text) from public,anon;
revoke all on function public.programming_admin_list_payment_requests() from public,anon;
revoke all on function public.programming_approve_payment_request(uuid,text) from public,anon;
revoke all on function public.programming_reject_payment_request(uuid,text) from public,anon;
grant execute on function public.programming_create_payment_request(text,text) to authenticated;
grant execute on function public.programming_admin_list_payment_requests() to authenticated;
grant execute on function public.programming_approve_payment_request(uuid,text) to authenticated;
grant execute on function public.programming_reject_payment_request(uuid,text) to authenticated;
