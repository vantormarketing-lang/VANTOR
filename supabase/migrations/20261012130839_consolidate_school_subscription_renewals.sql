-- Consolidate duplicate active school-grade subscriptions without losing paid duration.
UPDATE public.subscriptions s
SET status='expired'
WHERE s.status='active' AND s.expires_at<=now();

DO $consolidate_school_subscriptions$
DECLARE
  grp record;
BEGIN
  FOR grp IN
    SELECT student_id,
           grade_id,
           (array_agg(id ORDER BY starts_at, created_at, id))[1] AS keep_id,
           min(starts_at) AS first_start,
           sum(expires_at-starts_at) AS paid_duration,
           (array_agg(plan ORDER BY created_at DESC, id DESC))[1] AS latest_plan,
           (array_agg(amount ORDER BY created_at DESC, id DESC))[1] AS latest_amount
      FROM public.subscriptions
     WHERE status='active' AND expires_at>now()
     GROUP BY student_id,grade_id
    HAVING count(*)>1
  LOOP
    UPDATE public.subscriptions
       SET status='cancelled'
     WHERE student_id=grp.student_id
       AND grade_id=grp.grade_id
       AND status='active'
       AND id<>grp.keep_id;

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
  ON public.subscriptions(student_id,grade_id)
  WHERE status='active';

CREATE OR REPLACE FUNCTION public.doma_approve_subscription_request(
  p_request_id uuid,
  p_note text DEFAULT NULL::text
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public'
AS $function$
DECLARE
  r public.subscription_requests%rowtype;
  s public.subscriptions%rowtype;
  v_start timestamptz := now();
  v_expiry timestamptz;
  v_days integer;
  v_id uuid;
  v_status text;
BEGIN
  IF NOT public.doma_is_staff() THEN
    RAISE EXCEPTION 'Staff access required';
  END IF;

  SELECT * INTO r
    FROM public.subscription_requests
   WHERE id=p_request_id
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Subscription request not found';
  END IF;
  IF r.student_id IS NULL OR r.grade_id IS NULL THEN
    RAISE EXCEPTION 'Subscription request is missing a student or grade';
  END IF;

  -- Serialize approvals for the same student + grade to prevent double grants.
  PERFORM pg_advisory_xact_lock(hashtextextended(r.student_id::text || ':' || r.grade_id::text,0));

  UPDATE public.subscriptions
     SET status='expired'
   WHERE student_id=r.student_id
     AND grade_id=r.grade_id
     AND status='active'
     AND expires_at<=now();

  v_status := lower(trim(coalesce(r.status,'')));

  -- Re-approving the same still-active request is idempotent: do not add time twice.
  SELECT * INTO s
    FROM public.subscriptions
   WHERE request_id=r.id
   ORDER BY created_at DESC
   LIMIT 1
   FOR UPDATE;

  IF FOUND THEN
    IF s.status='active' AND s.expires_at>now() THEN
      UPDATE public.subscription_requests
         SET status='approved',
             admin_note=coalesce(p_note,admin_note),
             reviewed_by=coalesce(reviewed_by,auth.uid()),
             reviewed_at=coalesce(reviewed_at,now())
       WHERE id=r.id;

      UPDATE public.profiles
         SET grade_id=r.grade_id,
             phone=coalesce(nullif(trim(r.student_phone),''),phone),
             updated_at=now()
       WHERE id=r.student_id;
      RETURN s.id;
    END IF;

    IF v_status='approved' AND s.status='cancelled' THEN
      SELECT * INTO s
        FROM public.subscriptions
       WHERE student_id=r.student_id
         AND grade_id=r.grade_id
         AND status='active'
         AND expires_at>now()
       ORDER BY expires_at DESC,created_at DESC
       LIMIT 1
       FOR UPDATE;
      IF FOUND THEN
        RETURN s.id;
      END IF;
      RAISE EXCEPTION 'This approved request is no longer active; review it before restoring access.';
    END IF;

    IF v_status='approved' AND s.expires_at<=now() THEN
      RAISE EXCEPTION 'This request was approved before, but its subscription has expired.';
    END IF;
    IF v_status='rejected' THEN
      RAISE EXCEPTION 'This request is already rejected';
    END IF;
  END IF;

  IF v_status='rejected' THEN
    RAISE EXCEPTION 'This request is already rejected';
  END IF;

  -- An older approved request with a missing link may reuse current access, but
  -- it must not grant extra time a second time.
  IF v_status='approved' THEN
    SELECT * INTO s
      FROM public.subscriptions
     WHERE student_id=r.student_id
       AND grade_id=r.grade_id
       AND status='active'
       AND expires_at>now()
     ORDER BY expires_at DESC,created_at DESC
     LIMIT 1
     FOR UPDATE;

    IF FOUND THEN
      UPDATE public.profiles
         SET grade_id=r.grade_id,
             phone=coalesce(nullif(trim(r.student_phone),''),phone),
             updated_at=now()
       WHERE id=r.student_id;
      RETURN s.id;
    END IF;

    IF coalesce(r.reviewed_at,r.created_at)>=now()-interval '60 days' THEN
      v_days := CASE WHEN lower(trim(coalesce(r.plan,'')))='annual' THEN 365 ELSE 30 END;
      v_expiry := now()+make_interval(days=>v_days);
      INSERT INTO public.subscriptions(student_id,grade_id,plan,amount,starts_at,expires_at,status,request_id)
      VALUES(r.student_id,r.grade_id,r.plan,r.amount,now(),v_expiry,'active',r.id)
      RETURNING id INTO v_id;

      UPDATE public.profiles
         SET grade_id=r.grade_id,
             phone=coalesce(nullif(trim(r.student_phone),''),phone),
             updated_at=now()
       WHERE id=r.student_id;
      RETURN v_id;
    END IF;
    RAISE EXCEPTION 'This request is already approved, but no current subscription exists';
  END IF;

  IF v_status<>'pending' THEN
    RAISE EXCEPTION 'This request has an invalid status: %',coalesce(r.status,'NULL');
  END IF;

  v_days := CASE WHEN lower(trim(coalesce(r.plan,'')))='annual' THEN 365 ELSE 30 END;

  SELECT * INTO s
    FROM public.subscriptions
   WHERE student_id=r.student_id
     AND grade_id=r.grade_id
     AND status='active'
     AND expires_at>now()
   ORDER BY expires_at DESC,created_at DESC
   LIMIT 1
   FOR UPDATE;

  IF FOUND THEN
    -- This is a new approved payment: extend existing access instead of creating
    -- another overlapping active row.
    v_expiry := greatest(s.expires_at,now())+make_interval(days=>v_days);
    UPDATE public.subscriptions
       SET expires_at=v_expiry,
           plan=r.plan,
           amount=r.amount
     WHERE id=s.id;

    UPDATE public.subscription_requests
       SET status='approved',
           admin_note=p_note,
           reviewed_by=auth.uid(),
           reviewed_at=now()
     WHERE id=r.id;

    UPDATE public.profiles
       SET grade_id=r.grade_id,
           phone=coalesce(nullif(trim(r.student_phone),''),phone),
           updated_at=now()
     WHERE id=r.student_id;

    BEGIN
      INSERT INTO public.notifications(student_id,title,message)
      VALUES(
        r.student_id,
        'Subscription renewed',
        'Your ' || r.plan || ' subscription for ' ||
        coalesce((SELECT name FROM public.grades WHERE id=r.grade_id),'your selected grade') ||
        ' has been extended until ' || to_char(v_expiry,'YYYY-MM-DD') || '.'
      );
    EXCEPTION WHEN undefined_table OR undefined_column THEN
      NULL;
    END;
    RETURN s.id;
  END IF;

  v_expiry := v_start+make_interval(days=>v_days);
  INSERT INTO public.subscriptions(student_id,grade_id,plan,amount,starts_at,expires_at,status,request_id)
  VALUES(r.student_id,r.grade_id,r.plan,r.amount,v_start,v_expiry,'active',r.id)
  RETURNING id INTO v_id;

  UPDATE public.subscription_requests
     SET status='approved',
         admin_note=p_note,
         reviewed_by=auth.uid(),
         reviewed_at=now()
   WHERE id=r.id;

  UPDATE public.profiles
     SET grade_id=r.grade_id,
         phone=coalesce(nullif(trim(r.student_phone),''),phone),
         updated_at=now()
   WHERE id=r.student_id;

  BEGIN
    INSERT INTO public.notifications(student_id,title,message)
    VALUES(
      r.student_id,
      'Subscription approved',
      'Your ' || r.plan || ' subscription for ' ||
      coalesce((SELECT name FROM public.grades WHERE id=r.grade_id),'your selected grade') ||
      ' is now active until ' || to_char(v_expiry,'YYYY-MM-DD') || '.'
    );
  EXCEPTION WHEN undefined_table OR undefined_column THEN
    NULL;
  END;

  RETURN v_id;
END;
$function$;