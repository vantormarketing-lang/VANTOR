-- Idempotent paid-grade subscription approvals and renewals.
-- Applied live by migrations consolidate_school_subscription_renewals and
-- make_subscription_renewals_idempotent.
-- Preserve all paid time while consolidating accidental overlapping memberships.
UPDATE public.subscriptions
SET status='expired'
WHERE status='active' AND expires_at<=now();

DO $consolidate_school_subscriptions$
DECLARE grp record;
BEGIN
  FOR grp IN
    SELECT student_id,grade_id,
           (array_agg(id ORDER BY starts_at,created_at,id))[1] keep_id,
           min(starts_at) first_start,
           sum(expires_at-starts_at) paid_duration,
           (array_agg(plan ORDER BY created_at DESC,id DESC))[1] latest_plan,
           (array_agg(amount ORDER BY created_at DESC,id DESC))[1] latest_amount
      FROM public.subscriptions
     WHERE status='active' AND expires_at>now()
     GROUP BY student_id,grade_id HAVING count(*)>1
  LOOP
    UPDATE public.subscriptions SET status='cancelled'
     WHERE student_id=grp.student_id AND grade_id=grp.grade_id
       AND status='active' AND id<>grp.keep_id;
    UPDATE public.subscriptions
       SET starts_at=grp.first_start,
           expires_at=grp.first_start+grp.paid_duration,
           plan=grp.latest_plan,
           amount=grp.latest_amount,
           status='active'
     WHERE id=grp.keep_id;
  END LOOP;
END
$consolidate_school_subscriptions$;

CREATE UNIQUE INDEX IF NOT EXISTS subscriptions_one_active_per_student_grade_uq
ON public.subscriptions(student_id,grade_id) WHERE status='active';

CREATE TABLE IF NOT EXISTS public.subscription_renewal_history (
  request_id uuid PRIMARY KEY REFERENCES public.subscription_requests(id) ON DELETE RESTRICT,
  subscription_id uuid NOT NULL REFERENCES public.subscriptions(id) ON DELETE RESTRICT,
  student_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  grade_id uuid NOT NULL REFERENCES public.grades(id) ON DELETE RESTRICT,
  plan text NOT NULL CHECK (plan IN ('monthly','annual')),
  amount numeric(10,2) NOT NULL CHECK (amount>=0),
  days_granted integer NOT NULL CHECK (days_granted IN (30,365)),
  recorded_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.subscription_renewal_history ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.subscription_renewal_history FROM PUBLIC,anon,authenticated;

INSERT INTO public.subscription_renewal_history(
  request_id,subscription_id,student_id,grade_id,plan,amount,days_granted,recorded_at
)
SELECT r.id,coalesce(active_sub.id,linked_sub.id),r.student_id,r.grade_id,
       CASE WHEN lower(trim(coalesce(r.plan,'')))='annual' THEN 'annual' ELSE 'monthly' END,
       r.amount,
       CASE WHEN lower(trim(coalesce(r.plan,'')))='annual' THEN 365 ELSE 30 END,
       coalesce(r.reviewed_at,r.created_at,now())
FROM public.subscription_requests r
LEFT JOIN LATERAL (
  SELECT s.id FROM public.subscriptions s
   WHERE s.student_id=r.student_id AND s.grade_id=r.grade_id
     AND s.status='active' AND s.expires_at>now()
   ORDER BY s.expires_at DESC,s.created_at DESC LIMIT 1
) active_sub ON true
LEFT JOIN LATERAL (
  SELECT s.id FROM public.subscriptions s
   WHERE s.request_id=r.id ORDER BY s.created_at DESC LIMIT 1
) linked_sub ON true
WHERE lower(trim(coalesce(r.status,'')))='approved'
  AND coalesce(active_sub.id,linked_sub.id) IS NOT NULL
ON CONFLICT(request_id) DO NOTHING;

CREATE OR REPLACE FUNCTION public.doma_approve_subscription_request(p_request_id uuid, p_note text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  r public.subscription_requests%rowtype;
  s public.subscriptions%rowtype;
  h public.subscription_renewal_history%rowtype;
  v_start timestamptz := now();
  v_expiry timestamptz;
  v_previous_expiry timestamptz;
  v_days integer;
  v_id uuid;
  v_status text;
BEGIN
  IF NOT public.doma_is_staff() THEN RAISE EXCEPTION 'Staff access required'; END IF;

  SELECT * INTO r FROM public.subscription_requests WHERE id=p_request_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Subscription request not found'; END IF;
  IF r.student_id IS NULL OR r.grade_id IS NULL THEN
    RAISE EXCEPTION 'Subscription request is missing a student or grade';
  END IF;

  -- Prevent parallel approvals for the same student/grade and serialise renewals.
  PERFORM pg_advisory_xact_lock(hashtextextended(r.student_id::text || ':' || r.grade_id::text,0));

  UPDATE public.subscriptions
     SET status='expired'
   WHERE student_id=r.student_id AND grade_id=r.grade_id
     AND status='active' AND expires_at<=now();

  v_status := lower(trim(coalesce(r.status,'')));
  v_days := CASE WHEN lower(trim(coalesce(r.plan,'')))='annual' THEN 365 ELSE 30 END;

  -- Ledger wins: a payment/request may only grant access once, even after expiry.
  SELECT * INTO h FROM public.subscription_renewal_history WHERE request_id=r.id;
  IF FOUND THEN
    UPDATE public.profiles
       SET grade_id=r.grade_id,
           phone=coalesce(nullif(trim(r.student_phone),''),phone),
           updated_at=now()
     WHERE id=r.student_id;
    RETURN h.subscription_id;
  END IF;

  IF v_status='rejected' THEN RAISE EXCEPTION 'This request is already rejected'; END IF;
  IF v_status NOT IN ('pending','approved') THEN
    RAISE EXCEPTION 'This request has an invalid status: %',coalesce(r.status,'NULL');
  END IF;

  -- Repair an already-approved legacy request without ever adding a second period.
  IF v_status='approved' THEN
    SELECT * INTO s FROM public.subscriptions
     WHERE student_id=r.student_id AND grade_id=r.grade_id
       AND status='active' AND expires_at>now()
     ORDER BY expires_at DESC,created_at DESC LIMIT 1 FOR UPDATE;
    IF FOUND THEN
      INSERT INTO public.subscription_renewal_history(
        request_id,subscription_id,student_id,grade_id,plan,amount,days_granted,recorded_at
      ) VALUES(r.id,s.id,r.student_id,r.grade_id,
        CASE WHEN lower(trim(coalesce(r.plan,'')))='annual' THEN 'annual' ELSE 'monthly' END,
        r.amount,v_days,coalesce(r.reviewed_at,r.created_at,now()))
      ON CONFLICT(request_id) DO NOTHING;
      UPDATE public.profiles
         SET grade_id=r.grade_id,
             phone=coalesce(nullif(trim(r.student_phone),''),phone),
             updated_at=now()
       WHERE id=r.student_id;
      RETURN s.id;
    END IF;

    -- A legacy approval with no surviving access can be restored only once;
    -- the inserted ledger guarantees later retries cannot grant a second period.
    IF coalesce(r.reviewed_at,r.created_at)>=now()-interval '60 days' THEN
      v_expiry:=now()+make_interval(days=>v_days);
      INSERT INTO public.subscriptions(
        student_id,grade_id,plan,amount,starts_at,expires_at,status,request_id
      ) VALUES(r.student_id,r.grade_id,r.plan,r.amount,now(),v_expiry,'active',r.id)
      RETURNING id INTO v_id;

      INSERT INTO public.subscription_renewal_history(
        request_id,subscription_id,student_id,grade_id,plan,amount,days_granted,recorded_at
      ) VALUES(r.id,v_id,r.student_id,r.grade_id,
        CASE WHEN lower(trim(coalesce(r.plan,'')))='annual' THEN 'annual' ELSE 'monthly' END,
        r.amount,v_days,coalesce(r.reviewed_at,r.created_at,now()))
      ON CONFLICT(request_id) DO NOTHING;

      UPDATE public.profiles
         SET grade_id=r.grade_id,
             phone=coalesce(nullif(trim(r.student_phone),''),phone),
             updated_at=now()
       WHERE id=r.student_id;
      RETURN v_id;
    END IF;
    RAISE EXCEPTION 'This request is already approved, but no current subscription exists';
  END IF;

  -- New approved payment: extend the current access window rather than overlap active rows.
  SELECT * INTO s FROM public.subscriptions
   WHERE student_id=r.student_id AND grade_id=r.grade_id
     AND status='active' AND expires_at>now()
   ORDER BY expires_at DESC,created_at DESC LIMIT 1 FOR UPDATE;

  IF FOUND THEN
    v_previous_expiry:=s.expires_at;
    v_expiry:=greatest(s.expires_at,now())+make_interval(days=>v_days);
    UPDATE public.subscriptions
       SET expires_at=v_expiry,plan=r.plan,amount=r.amount
     WHERE id=s.id;
    v_id:=s.id;

    UPDATE public.subscription_requests
       SET status='approved',admin_note=p_note,reviewed_by=auth.uid(),reviewed_at=now()
     WHERE id=r.id;

    INSERT INTO public.subscription_renewal_history(
      request_id,subscription_id,student_id,grade_id,plan,amount,days_granted,recorded_at
    ) VALUES(r.id,v_id,r.student_id,r.grade_id,
      CASE WHEN lower(trim(coalesce(r.plan,'')))='annual' THEN 'annual' ELSE 'monthly' END,
      r.amount,v_days,now());

    UPDATE public.profiles
       SET grade_id=r.grade_id,
           phone=coalesce(nullif(trim(r.student_phone),''),phone),
           updated_at=now()
     WHERE id=r.student_id;

    BEGIN
      INSERT INTO public.notifications(student_id,title,message)
      VALUES(r.student_id,'Subscription renewed',
        'Your '||r.plan||' subscription for '||
        coalesce((SELECT name FROM public.grades WHERE id=r.grade_id),'your selected grade')||
        ' has been extended until '||to_char(v_expiry,'YYYY-MM-DD')||'.');
    EXCEPTION WHEN undefined_table OR undefined_column THEN NULL;
    END;
    RETURN v_id;
  END IF;

  v_expiry:=v_start+make_interval(days=>v_days);
  INSERT INTO public.subscriptions(student_id,grade_id,plan,amount,starts_at,expires_at,status,request_id)
  VALUES(r.student_id,r.grade_id,r.plan,r.amount,v_start,v_expiry,'active',r.id)
  RETURNING id INTO v_id;

  UPDATE public.subscription_requests
     SET status='approved',admin_note=p_note,reviewed_by=auth.uid(),reviewed_at=now()
   WHERE id=r.id;

  INSERT INTO public.subscription_renewal_history(
    request_id,subscription_id,student_id,grade_id,plan,amount,days_granted,recorded_at
  ) VALUES(r.id,v_id,r.student_id,r.grade_id,
    CASE WHEN lower(trim(coalesce(r.plan,'')))='annual' THEN 'annual' ELSE 'monthly' END,
    r.amount,v_days,now());

  UPDATE public.profiles
     SET grade_id=r.grade_id,
         phone=coalesce(nullif(trim(r.student_phone),''),phone),
         updated_at=now()
   WHERE id=r.student_id;

  BEGIN
    INSERT INTO public.notifications(student_id,title,message)
    VALUES(r.student_id,'Subscription approved',
      'Your '||r.plan||' subscription for '||
      coalesce((SELECT name FROM public.grades WHERE id=r.grade_id),'your selected grade')||
      ' is now active until '||to_char(v_expiry,'YYYY-MM-DD')||'.');
  EXCEPTION WHEN undefined_table OR undefined_column THEN NULL;
  END;

  RETURN v_id;
END;
$function$

REVOKE ALL ON FUNCTION public.doma_approve_subscription_request(uuid,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.doma_approve_subscription_request(uuid,text) TO authenticated;

CREATE OR REPLACE FUNCTION public.doma_approve_subscription_request_v2(p_request_id uuid, p_note text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
BEGIN
  IF NOT public.doma_is_staff() THEN
    RAISE EXCEPTION 'Staff access required';
  END IF;
  RETURN public.doma_approve_subscription_request(p_request_id, p_note);
END;
$function$

REVOKE ALL ON FUNCTION public.doma_approve_subscription_request_v2(uuid,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.doma_approve_subscription_request_v2(uuid,text) TO authenticated;
