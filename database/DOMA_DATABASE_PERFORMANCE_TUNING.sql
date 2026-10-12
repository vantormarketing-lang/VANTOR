-- DOMA database performance tuning (safe, non-destructive).
-- Applied to Supabase project dtptxhkcogpoleftguas using migration:
-- doma_database_performance_tuning
--
-- 1. Cache auth.uid()/auth.jwt() calls in RLS initplans without changing policy logic.
DO $doma_rls_tune$
DECLARE
  pol record;
  v_using text;
  v_check text;
  v_sql text;
BEGIN
  FOR pol IN
    SELECT schemaname, tablename, policyname, qual, with_check
      FROM pg_policies
     WHERE schemaname = 'public'
       AND (
         coalesce(qual, '') LIKE '%auth.uid()%' OR
         coalesce(with_check, '') LIKE '%auth.uid()%' OR
         coalesce(qual, '') LIKE '%auth.jwt()%' OR
         coalesce(with_check, '') LIKE '%auth.jwt()%'
       )
  LOOP
    v_using := pol.qual;
    v_check := pol.with_check;

    IF v_using IS NOT NULL THEN
      v_using := regexp_replace(v_using, '\([[:space:]]*SELECT[[:space:]]+auth\.uid\(\)[[:space:]]*\)', '__DOMA_AUTH_UID_WRAPPED__', 'gi');
      v_using := regexp_replace(v_using, '\([[:space:]]*SELECT[[:space:]]+auth\.jwt\(\)[[:space:]]*\)', '__DOMA_AUTH_JWT_WRAPPED__', 'gi');
      v_using := replace(v_using, 'auth.uid()', '(select auth.uid())');
      v_using := replace(v_using, 'auth.jwt()', '(select auth.jwt())');
      v_using := replace(v_using, '__DOMA_AUTH_UID_WRAPPED__', '(select auth.uid())');
      v_using := replace(v_using, '__DOMA_AUTH_JWT_WRAPPED__', '(select auth.jwt())');
    END IF;

    IF v_check IS NOT NULL THEN
      v_check := regexp_replace(v_check, '\([[:space:]]*SELECT[[:space:]]+auth\.uid\(\)[[:space:]]*\)', '__DOMA_AUTH_UID_WRAPPED__', 'gi');
      v_check := regexp_replace(v_check, '\([[:space:]]*SELECT[[:space:]]+auth\.jwt\(\)[[:space:]]*\)', '__DOMA_AUTH_JWT_WRAPPED__', 'gi');
      v_check := replace(v_check, 'auth.uid()', '(select auth.uid())');
      v_check := replace(v_check, 'auth.jwt()', '(select auth.jwt())');
      v_check := replace(v_check, '__DOMA_AUTH_UID_WRAPPED__', '(select auth.uid())');
      v_check := replace(v_check, '__DOMA_AUTH_JWT_WRAPPED__', '(select auth.jwt())');
    END IF;

    IF v_using IS DISTINCT FROM pol.qual OR v_check IS DISTINCT FROM pol.with_check THEN
      v_sql := format('ALTER POLICY %I ON %I.%I', pol.policyname, pol.schemaname, pol.tablename);
      IF pol.qual IS NOT NULL THEN
        v_sql := v_sql || format(' USING (%s)', v_using);
      END IF;
      IF pol.with_check IS NOT NULL THEN
        v_sql := v_sql || format(' WITH CHECK (%s)', v_check);
      END IF;
      EXECUTE v_sql;
    END IF;
  END LOOP;
END
$doma_rls_tune$;

-- 2. Add indexes only to public-schema foreign keys not already covered by a
-- valid index whose leading columns match the whole foreign-key column list.
DO $doma_fk_indexes$
DECLARE
  fk record;
  index_name text;
BEGIN
  FOR fk IN
    SELECT n.nspname AS schema_name,
           t.relname AS table_name,
           string_agg(format('%I', a.attname), ', ' ORDER BY k.ord) AS column_sql,
           string_agg(a.attname, '_' ORDER BY k.ord) AS column_key,
           c.conkey
      FROM pg_constraint c
      JOIN pg_class t ON t.oid = c.conrelid
      JOIN pg_namespace n ON n.oid = t.relnamespace
      JOIN LATERAL unnest(c.conkey) WITH ORDINALITY k(attnum, ord) ON true
      JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = k.attnum
     WHERE c.contype = 'f'
       AND n.nspname = 'public'
     GROUP BY n.nspname, t.relname, c.conkey, c.oid
    HAVING NOT EXISTS (
      SELECT 1
        FROM pg_index i
       WHERE i.indrelid = c.conrelid
         AND i.indisvalid
         AND i.indisready
         AND (SELECT array_agg(z.attnum ORDER BY z.ord)
                FROM unnest(i.indkey::int2[]) WITH ORDINALITY z(attnum, ord)
               WHERE z.ord <= cardinality(c.conkey)) = c.conkey
    )
  LOOP
    index_name := left('doma_fkidx_' || fk.table_name || '_' || fk.column_key, 62);
    EXECUTE format('CREATE INDEX IF NOT EXISTS %I ON %I.%I (%s)',
                   index_name, fk.schema_name, fk.table_name, fk.column_sql);
  END LOOP;
END
$doma_fk_indexes$;
