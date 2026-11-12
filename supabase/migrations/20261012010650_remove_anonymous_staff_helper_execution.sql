-- Remove staff-only helper calls from policies that also apply to anonymous users.
-- Keep explicit authenticated staff read policies so admins/teachers retain access to unpublished rows.

DROP POLICY IF EXISTS daily_100_public_read ON public.daily_100;
CREATE POLICY daily_100_public_read
  ON public.daily_100
  FOR SELECT
  TO anon, authenticated
  USING (is_published = true);

DROP POLICY IF EXISTS daily_words_public_read ON public.daily_words;
CREATE POLICY daily_words_public_read
  ON public.daily_words
  FOR SELECT
  TO anon, authenticated
  USING (is_published = true AND day_date <= CURRENT_DATE);

DROP POLICY IF EXISTS "doma public published reviews" ON public.reviews;
CREATE POLICY "doma public published reviews"
  ON public.reviews
  FOR SELECT
  TO anon, authenticated
  USING (is_published = true);

DROP POLICY IF EXISTS doma_daily_100_staff_select ON public.daily_100;
CREATE POLICY doma_daily_100_staff_select
  ON public.daily_100
  FOR SELECT
  TO authenticated
  USING (public.doma_is_staff());

DROP POLICY IF EXISTS doma_staff_reviews_select ON public.reviews;
CREATE POLICY doma_staff_reviews_select
  ON public.reviews
  FOR SELECT
  TO authenticated
  USING (public.doma_is_staff());

DROP POLICY IF EXISTS mrfluent_english_levels_public_read ON public.mrfluent_english_levels;
CREATE POLICY mrfluent_english_levels_public_read
  ON public.mrfluent_english_levels
  FOR SELECT
  TO anon, authenticated
  USING (is_published = true);

-- These functions remain executable for authenticated RLS evaluation and staff RPCs,
-- but are no longer directly callable by anonymous API clients.
REVOKE EXECUTE ON FUNCTION public.doma_is_staff() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.doma_is_staff() TO authenticated;

REVOKE EXECUTE ON FUNCTION public.mrfluent_english_is_staff() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mrfluent_english_is_staff() TO authenticated;
