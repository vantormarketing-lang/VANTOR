-- Limit public catalog reads to active items and harden anonymous submissions.
-- Existing content and historic orders/messages/testimonials are preserved.

DROP POLICY IF EXISTS "Allow public client reads" ON public.clients;

DROP POLICY IF EXISTS "Allow public offer reads" ON public.offers;
CREATE POLICY "Allow public offer reads"
ON public.offers FOR SELECT TO anon
USING (lower(trim(coalesce(status,''))) = 'active');

DROP POLICY IF EXISTS "Allow public project reads" ON public.projects;
CREATE POLICY "Allow public project reads"
ON public.projects FOR SELECT TO anon
USING (lower(trim(coalesce(status,''))) = 'active');

DROP POLICY IF EXISTS "Allow public service reads" ON public.services;
CREATE POLICY "Allow public service reads"
ON public.services FOR SELECT TO anon
USING (lower(trim(coalesce(status,''))) = 'active');

DROP POLICY IF EXISTS "Allow public message inserts" ON public.messages;
CREATE POLICY "Allow public message inserts"
ON public.messages FOR INSERT TO anon
WITH CHECK (
  char_length(btrim(coalesce(name,''))) BETWEEN 2 AND 120
  AND char_length(btrim(coalesce(message,''))) BETWEEN 10 AND 3000
  AND (email IS NULL OR (
    char_length(btrim(email)) BETWEEN 5 AND 254
    AND btrim(email) ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
  ))
  AND (phone IS NULL OR char_length(btrim(phone)) <= 40)
  AND coalesce(is_read,false) = false
  AND (created_at IS NULL OR created_at <= now() + interval '5 minutes')
);

DROP POLICY IF EXISTS "VANTOR public can create orders" ON public.orders;
CREATE POLICY "VANTOR public can create orders"
ON public.orders FOR INSERT TO anon, authenticated
WITH CHECK (
  status = 'New'
  AND char_length(btrim(coalesce(order_id,''))) BETWEEN 3 AND 100
  AND char_length(btrim(coalesce(customer_name,''))) BETWEEN 2 AND 120
  AND char_length(btrim(coalesce(phone,''))) BETWEEN 5 AND 40
  AND char_length(btrim(coalesce(address,''))) BETWEEN 3 AND 1000
  AND (email IS NULL OR (
    char_length(btrim(email)) BETWEEN 5 AND 254
    AND btrim(email) ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
  ))
  AND (notes IS NULL OR char_length(notes) <= 3000)
  AND total >= 0 AND total < 10000000
  AND jsonb_typeof(items) = 'array'
  AND jsonb_array_length(items) BETWEEN 1 AND 40
  AND (created_at IS NULL OR created_at <= now() + interval '5 minutes')
);

ALTER TABLE public.testimonials ALTER COLUMN status SET DEFAULT 'Pending';

DROP POLICY IF EXISTS "Allow public testimonial reads" ON public.testimonials;
CREATE POLICY "Allow public testimonial reads"
ON public.testimonials FOR SELECT TO anon
USING (lower(trim(coalesce(status,''))) = 'active');

DROP POLICY IF EXISTS "Allow public testimonial inserts" ON public.testimonials;
CREATE POLICY "Allow public testimonial inserts"
ON public.testimonials FOR INSERT TO anon
WITH CHECK (
  lower(trim(coalesce(status,''))) = 'pending'
  AND char_length(btrim(coalesce(name,''))) BETWEEN 2 AND 120
  AND char_length(btrim(coalesce(nullif(message,''),nullif(text,''),''))) BETWEEN 10 AND 2000
  AND rating BETWEEN 1 AND 5
  AND (image IS NULL OR char_length(image) <= 2000)
  AND (created_at IS NULL OR created_at <= now() + interval '5 minutes')
);

DROP POLICY IF EXISTS "quiz_pro_settings_authenticated_read" ON public.quiz_pro_settings;
CREATE POLICY "quiz_pro_settings_authenticated_read"
ON public.quiz_pro_settings FOR SELECT TO authenticated
USING (
  public.doma_is_staff()
  OR EXISTS (
    SELECT 1
    FROM public.quizzes q
    WHERE q.id = quiz_pro_settings.quiz_id
      AND q.is_published = true
      AND (
        coalesce(q.is_free,false) = true
        OR EXISTS (
          SELECT 1 FROM public.subscriptions s
          WHERE s.student_id = (SELECT auth.uid())
            AND s.grade_id = q.grade_id
            AND lower(trim(coalesce(s.status,''))) = 'active'
            AND s.expires_at > now()
        )
      )
  )
);

DROP POLICY IF EXISTS "doma own review insert" ON public.reviews;
CREATE POLICY "doma own review insert"
ON public.reviews FOR INSERT TO authenticated
WITH CHECK (
  (SELECT auth.uid()) = student_id
  AND is_published = false
  AND rating BETWEEN 1 AND 5
  AND char_length(btrim(review_text)) BETWEEN 10 AND 3000
);
