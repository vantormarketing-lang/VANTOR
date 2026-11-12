DROP POLICY IF EXISTS "Allow public message inserts" ON public.messages;
CREATE POLICY "Allow public message inserts"
ON public.messages FOR INSERT TO anon
WITH CHECK (
  char_length(btrim(coalesce(name,''))) BETWEEN 2 AND 120
  AND char_length(btrim(coalesce(message,''))) BETWEEN 10 AND 3000
  AND (email IS NULL OR (
    char_length(btrim(email)) BETWEEN 5 AND 254
    AND btrim(email) ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+[.][A-Z]{2,}$'
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
    AND btrim(email) ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+[.][A-Z]{2,}$'
  ))
  AND (notes IS NULL OR char_length(notes) <= 3000)
  AND total >= 0 AND total < 10000000
  AND jsonb_typeof(items) = 'array'
  AND jsonb_array_length(items) BETWEEN 1 AND 40
  AND (created_at IS NULL OR created_at <= now() + interval '5 minutes')
);