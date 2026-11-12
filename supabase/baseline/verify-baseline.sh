#!/usr/bin/env bash
# Local-only rebuild verification. Never points db reset at production.
set -euo pipefail

PROD_DUMP="${1:?Usage: bash supabase/baseline/verify-baseline.sh <production-schema.sql>}"
[[ -f "$PROD_DUMP" ]] || { echo "Production schema dump not found: $PROD_DUMP" >&2; exit 2; }
command -v supabase >/dev/null || { echo "Supabase CLI is required." >&2; exit 2; }

echo "Resetting the LOCAL Supabase database from the checked-out migrations..."
supabase db reset --local
echo "Exporting the LOCAL schema..."
supabase db dump --local -f /tmp/doma-local-schema.sql

normalize() {
  # Remove dump headers and session setup only. Preserve statement order.
  grep -Ev '^(--|SET |SELECT pg_catalog\.set_config)' "$1" | sed -E 's/[[:space:]]+$//' | grep -Ev '^$'
}

if diff -u <(normalize "$PROD_DUMP") <(normalize /tmp/doma-local-schema.sql) > /tmp/doma-schema.diff; then
  echo "OK: local schema matches the production schema dump."
else
  echo "DIFFERENCES found (first 100 lines):"
  head -100 /tmp/doma-schema.diff
  echo "Review every difference. This check does not cover role settings, cron jobs, Realtime membership, or bucket rows."
  exit 1
fi

echo "Next: run supabase/baseline/verify-baseline-extras.sql against the LOCAL database."
