#!/usr/bin/env node
/**
 * Static migration safety checks.
 *
 * This deliberately does NOT claim to validate a live database or a clean
 * Supabase rebuild. A production schema baseline and migration-ledger
 * reconciliation are still pending.
 */
import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const migrationsDir = path.join(root, "supabase", "migrations");
const target = path.join(
  migrationsDir,
  "20261113000200_enable_rls_password_reset_ip_limits.sql",
);
let failed = false;

function fail(message) {
  console.error(`FAIL: ${message}`);
  failed = true;
}

if (!fs.existsSync(migrationsDir)) {
  fail("supabase/migrations directory is missing");
} else {
  const files = fs.readdirSync(migrationsDir)
    .filter((name) => name.endsWith(".sql"))
    .sort();

  if (files.length === 0) fail("no SQL migration files found");

  const versions = new Set();
  for (const file of files) {
    const match = /^(\d{14})_.+\.sql$/.exec(file);
    if (!match) {
      fail(`migration filename does not start with a 14-digit version: ${file}`);
      continue;
    }
    if (versions.has(match[1])) fail(`duplicate migration version: ${match[1]}`);
    versions.add(match[1]);
  }

  if (!failed) {
    console.log(`PASS: ${files.length} migration filenames use unique 14-digit versions`);
  }
}

if (!fs.existsSync(target)) {
  fail("password-reset IP rate-limit RLS migration is missing");
} else {
  const sql = fs.readFileSync(target, "utf8").toLowerCase().replace(/\s+/g, " ");
  const enableRls =
    /alter table private\.password_reset_ip_limits enable row level security\s*;/.test(sql);
  const revokeApiAccess =
    /revoke all privileges on table private\.password_reset_ip_limits from public, anon, authenticated\s*;/.test(sql);

  if (!enableRls) fail("RLS enable statement for private.password_reset_ip_limits is missing");
  if (!revokeApiAccess) fail("API-role privilege revoke for private.password_reset_ip_limits is missing");
  if (enableRls && revokeApiAccess) {
    console.log("PASS: password-reset IP limit migration enables RLS and revokes direct API-role privileges");
  }
}

const workflowDir = path.join(root, ".github", "workflows");
if (fs.existsSync(workflowDir)) {
  const workflows = fs.readdirSync(workflowDir).filter((name) => name.endsWith(".yml") || name.endsWith(".yaml"));
  for (const file of workflows) {
    const content = fs.readFileSync(path.join(workflowDir, file), "utf8");
    if (/\bsupabase\s+db\s+reset\b/i.test(content)) {
      fail(`${file} runs supabase db reset before a reviewed baseline is available`);
    }
  }
  if (!failed) {
    console.log("PASS: CI does not run an unverified Supabase database reset");
  }
}

if (failed) process.exit(1);
console.log("NOTE: these are static checks only; they do not validate production schema, migration-ledger alignment, or a clean database rebuild.");
