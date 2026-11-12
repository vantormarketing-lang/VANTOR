#!/usr/bin/env bash
# Build a current-production-state baseline from a schema-only dump.
# This script changes files in the working tree only. It never connects to Supabase.
set -euo pipefail

DUMP=""
VERSION=""
BUCKETS=""
SEED=0
DRY=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dump) DUMP="${2:?missing value for --dump}"; shift 2 ;;
    --version) VERSION="${2:?missing value for --version}"; shift 2 ;;
    --buckets) BUCKETS="${2:?missing value for --buckets}"; shift 2 ;;
    --with-seed) SEED=1; shift ;;
    --dry-run) DRY=1; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

[[ -n "$DUMP" && -f "$DUMP" ]] || { echo "A readable --dump schema.sql file is required." >&2; exit 2; }
[[ "$VERSION" =~ ^[0-9]{14}$ ]] || { echo "--version must be a 14-digit production migration version." >&2; exit 2; }
[[ -n "$BUCKETS" && -f "$BUCKETS" ]] || { echo "A reviewed --buckets SQL file is required; refusing to omit payment-proofs." >&2; exit 2; }

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MIG="$ROOT/supabase/migrations"
LEGACY="$ROOT/supabase/migrations_legacy"
EXTRAS="$ROOT/supabase/baseline/baseline_extras.sql"
OUT="$MIG/${VERSION}_baseline.sql"
SEED_SOURCE="$ROOT/supabase/snapshots/programming_curriculum_snapshot.sql"
SEED_OUT="$ROOT/supabase/seed.sql"
TMP=""

cleanup() {
  [ -z "$TMP" ] || rm -f "$TMP"
}
trap cleanup EXIT

[[ -d "$MIG" ]] || { echo "Missing active migrations directory: $MIG" >&2; exit 1; }
[[ -f "$EXTRAS" ]] || { echo "Missing extras file: $EXTRAS" >&2; exit 1; }
[[ ! -e "$OUT" ]] || { echo "Refusing to overwrite existing baseline: $OUT" >&2; exit 1; }
if [ "$SEED" -eq 1 ]; then
  [[ -f "$SEED_SOURCE" ]] || { echo "Missing curriculum snapshot: $SEED_SOURCE" >&2; exit 1; }
  [[ ! -e "$SEED_OUT" ]] || { echo "Refusing to overwrite existing seed: $SEED_OUT" >&2; exit 1; }
fi

SECRET_RE='eyJ[A-Za-z0-9_-]{20,}|sb_secret_[A-Za-z0-9_-]{12,}|service_role_key|SUPABASE_SERVICE_ROLE_KEY|-----BEGIN [A-Z ]*PRIVATE KEY'
echo "== 1/5 Validate schema dump, bucket export, and extras =="
for file in "$DUMP" "$BUCKETS" "$EXTRAS"; do
  if grep -Eiq "$SECRET_RE" "$file"; then
    echo "ABORT: recognizable secret material found in $file" >&2
    grep -Ein "$SECRET_RE" "$file" | cut -c1-140 >&2 || true
    exit 1
  fi
done
if grep -Eiq '^[[:space:]]*(COPY .* FROM stdin|INSERT INTO )' "$DUMP"; then
  echo "ABORT: dump contains row-data statements; schema-only export required." >&2
  exit 1
fi
if ! grep -q 'PAYMENT_PROOFS_BUCKET_PLACEHOLDER' "$EXTRAS"; then
  echo "ABORT: extras file has no payment-proofs insertion placeholder." >&2
  exit 1
fi
if ! grep -Eiq 'insert[[:space:]]+into[[:space:]]+storage\.buckets' "$BUCKETS"; then
  echo "ABORT: bucket export does not contain an INSERT into storage.buckets." >&2
  exit 1
fi
if grep -Eiq 'cron\.schedule|net\.http_post' "$DUMP" "$BUCKETS"; then
  echo "WARNING: review cron/http statements for embedded credentials before proceeding."
fi

echo "== 2/5 Select historical migrations at or below $VERSION =="
OLD=()
for path in "$MIG"/*.sql; do
  [ -e "$path" ] || continue
  file="$(basename "$path")"
  version="${file%%_*}"
  if [[ "$version" =~ ^[0-9]{14}$ ]] && [[ "$version" -le "$VERSION" ]]; then
    OLD+=("$file")
  fi
done
if [ "${#OLD[@]}" -eq 0 ]; then
  echo "ABORT: no historical migration files found at or below the baseline version." >&2
  exit 1
fi
if [ -e "$LEGACY" ]; then
  for file in "${OLD[@]}"; do
    [[ ! -e "$LEGACY/$file" ]] || { echo "ABORT: legacy destination already exists: $file" >&2; exit 1; }
  done
fi

echo "${#OLD[@]} historical migration file(s) will move to supabase/migrations_legacy/:"
printf '  %s\n' "${OLD[@]}"
echo "Newer migrations will remain active."
echo "Baseline output: $OUT"
if [ "$SEED" -eq 1 ]; then echo "Seed output: $SEED_OUT"; fi
if [ "$DRY" -eq 1 ]; then
  echo "DRY RUN: no files changed."
  exit 0
fi

echo "== 3/5 Assemble baseline in a temporary file =="
TMP="$(mktemp "$MIG/.baseline.XXXXXX")"
{
  echo "-- Current-production-state baseline at migration version $VERSION."
  echo "-- Generated from a reviewed schema-only dump. Historical migrations are reference-only."
  echo
  cat "$DUMP"
  echo
  echo "-- ===== Objects not fully represented by the schema-only dump ====="
  awk -v bucket_file="$BUCKETS" '
    /PAYMENT_PROOFS_BUCKET_PLACEHOLDER/ {
      while ((getline line < bucket_file) > 0) print line
      close(bucket_file)
      next
    }
    { print }
  ' "$EXTRAS"
} > "$TMP"

# A final check on the assembled migration before moving any historical files.
if grep -Eiq "$SECRET_RE" "$TMP" ||
   grep -Eiq '^[[:space:]]*(COPY .* FROM stdin|INSERT INTO )' "$TMP"; then
  echo "ABORT: assembled baseline failed the secret/data checks." >&2
  exit 1
fi

echo "== 4/5 Move superseded migrations and install baseline =="
mkdir -p "$LEGACY"
for file in "${OLD[@]}"; do
  mv "$MIG/$file" "$LEGACY/$file"
done
mv "$TMP" "$OUT"
TMP=""

if [ "$SEED" -eq 1 ]; then
  cp "$SEED_SOURCE" "$SEED_OUT"
fi

echo "== 5/5 Complete =="
echo "Baseline created: $OUT"
echo "Legacy migrations moved: ${#OLD[@]}"
echo "No database or migration ledger was changed."
echo "Next: run a clean local reset and verify-baseline.sh; do not repair the production ledger yet."
