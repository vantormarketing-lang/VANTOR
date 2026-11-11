#!/usr/bin/env node
/**
 * DOMA production safety guardrails.
 * Static checks only: this script never contacts the deployed website or database.
 */
import { existsSync, readFileSync } from 'node:fs';

const root = process.cwd();
const errors = [];
const checks = [];

function read(path) {
  const full = `${root}/${path}`;
  if (!existsSync(full)) {
    errors.push(`Missing required file: ${path}`);
    return '';
  }
  return readFileSync(full, 'utf8');
}
function pass(message) { checks.push(message); }
function fail(message) { errors.push(message); }

const browserFiles = [
  'index.html',
  'admin.html',
  'programming.html',
  'MR_FLUENT_KIDS_A1.html',
  'MR_FLUENT_A1_COURSE.html',
  'MR_FLUENT_A2_COURSE.html',
  'MR_FLUENT_B1_COURSE.html',
  'MR_FLUENT_B2_COURSE.html',
  'MR_FLUENT_C1_COURSE.html',
  'MR_FLUENT_C2_COURSE.html',
  'doma-mrfluent-kids-runtime.js',
  'mf-kids-learning-experiences.js'
];

for (const path of browserFiles) {
  const source = read(path);
  if (!source) continue;
  if (/sb_secret_[A-Za-z0-9_-]{16,}/.test(source)) {
    fail(`${path}: a Supabase secret key-like value must never be shipped to the browser`);
  }
  if (/SUPABASE_SERVICE_ROLE_KEY\s*[:=]\s*['"][^'"]+['"]/.test(source)) {
    fail(`${path}: a hard-coded service-role key must never be shipped to the browser`);
  }
}
pass('Browser-facing files contain no recognizable Supabase secret-key literals');

const runner = read('functions/api/code-run.js');
for (const required of [
  'env.SUPABASE_SERVICE_ROLE_KEY',
  '/auth/v1/user',
  'Authorization: `Bearer ${accessToken}`',
  'accessToken.length > 8192'
]) {
  if (!runner.includes(required)) fail(`functions/api/code-run.js: missing server-side auth/config safeguard: ${required}`);
}
pass('Cloudflare code runner keeps privileged configuration server-side and validates the Supabase user session');

const studentWorker = read('sw.js');
for (const required of [
  'function normalizeShellUrl',
  'function hasSensitiveQuery',
  'function isSafeSameOriginUrl',
  'function isCacheableStaticAssetUrl',
  'cache: \'no-store\''
]) {
  if (!studentWorker.includes(required)) fail(`sw.js: missing safe-cache invariant: ${required}`);
}
if (/caches\.match\s*\(\s*req\s*\)/.test(studentWorker)) {
  fail('sw.js: a global cache lookup can return stale or cross-user dynamic responses');
}
if (!/rest\\\/v1\|auth\\\/v1\|storage\\\/v1\|functions\\\/v1/.test(studentWorker)) {
  fail('sw.js: API routes must be excluded from runtime cache eligibility');
}
pass('Student PWA uses normalized shell keys and excludes sensitive/dynamic API responses from caching');

const adminWorker = read('admin-sw.js');
if (!/if\s*\(isAdminDocument\)\s*\{[\s\S]*?fetch\(req,\s*\{\s*cache:\s*['"]no-store['"]\s*\}\)/.test(adminWorker)) {
  fail('admin-sw.js: admin document navigations must always be fetched from the network without cache');
}
if (!/SHELL\.filter\(url\s*=>\s*url\s*!==\s*ADMIN_URL\)/.test(adminWorker)) {
  fail('admin-sw.js: the admin HTML document must not be precached');
}
if (!/if\s*\(SHELL\.includes\(req\.url\)\)/.test(adminWorker)) {
  fail('admin-sw.js: runtime cache writes must be restricted to the explicit shell allowlist');
}
pass('Admin PWA never caches the admin HTML and only caches allowlisted shell assets');

const student = read('index.html');
const admin = read('admin.html');
if (/storage\.from\(\s*['"]homework-submissions['"]\s*\)\s*\.getPublicUrl\s*\(/.test(student)) {
  fail('index.html: private homework attachments must not use public storage URLs');
}
if (!admin.includes('createSignedUrl(path,300)') || !admin.includes('data-doma-homework-attachment')) {
  fail('admin.html: private homework attachments must be opened through short-lived signed URLs');
}
pass('Homework attachment access remains private and uses signed URLs');

const headers = read('_headers');
for (const required of [
  'X-Content-Type-Options: nosniff',
  'Referrer-Policy: strict-origin-when-cross-origin',
  'X-Frame-Options: SAMEORIGIN',
  'Permissions-Policy: camera=(), microphone=(self), geolocation=()'
]) {
  if (!headers.includes(required)) fail(`_headers: missing browser security header: ${required}`);
}
pass('Baseline browser security response headers are present');

for (const message of checks) console.log('PASS', message);
if (errors.length) {
  for (const message of errors) console.error('FAIL', message);
  process.exitCode = 1;
} else {
  console.log(`\\nProduction safety validation passed (${checks.length} checks).`);
}
