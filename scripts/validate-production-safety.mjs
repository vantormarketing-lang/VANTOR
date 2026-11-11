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
function check(condition, message) {
  if (condition) checks.push(message);
  else errors.push(message);
}

const browserFiles = [
  'index.html', 'admin.html', 'programming.html',
  'MR_FLUENT_KIDS_A1.html',
  'MR_FLUENT_A1_COURSE.html', 'MR_FLUENT_A2_COURSE.html',
  'MR_FLUENT_B1_COURSE.html', 'MR_FLUENT_B2_COURSE.html',
  'MR_FLUENT_C1_COURSE.html', 'MR_FLUENT_C2_COURSE.html',
  'doma-mrfluent-kids-runtime.js', 'mf-kids-learning-experiences.js'
];
let browserSecretsFound = false;
for (const path of browserFiles) {
  const source = read(path);
  if (!source) continue;
  if (/sb_secret_[A-Za-z0-9_-]{16,}/.test(source) ||
      /SUPABASE_SERVICE_ROLE_KEY\s*[:=]\s*['"][^'"]+['"]/.test(source)) {
    browserSecretsFound = true;
    errors.push(`${path}: a Supabase secret/service-role key literal must never be shipped to the browser`);
  }
}
check(!browserSecretsFound, 'Browser-facing files contain no recognizable Supabase secret-key literals');

const runner = read('functions/api/code-run.js');
check(
  runner.includes('env.SUPABASE_SERVICE_ROLE_KEY') &&
  runner.includes('/auth/v1/user') &&
  runner.includes('Authorization: `Bearer ${accessToken}`') &&
  runner.includes('accessToken.length > 8192'),
  'Cloudflare code runner keeps privileged configuration server-side and validates the Supabase user session'
);

const studentWorker = read('sw.js');
check(
  ['function normalizeShellUrl', 'function hasSensitiveQuery',
   'function isSafeSameOriginUrl', 'function isCacheableStaticAssetUrl',
   "cache: 'no-store'", 'rest\\/v1', 'auth\\/v1',
   'storage\\/v1', 'functions\\/v1'].every(part => studentWorker.includes(part)) &&
  !/caches\.match\s*\(\s*req\s*\)/.test(studentWorker),
  'Student PWA normalizes shell keys and excludes sensitive/dynamic API responses from caching'
);

const adminWorker = read('admin-sw.js');
check(
  /if\s*\(isAdminDocument\)\s*\{[\s\S]*?fetch\(req,\s*\{\s*cache:\s*['"]no-store['"]\s*\}\)/.test(adminWorker) &&
  /SHELL\.filter\(url\s*=>\s*url\s*!==\s*ADMIN_URL\)/.test(adminWorker) &&
  /if\s*\(SHELL\.includes\(req\.url\)\)/.test(adminWorker),
  'Admin PWA never caches the admin HTML and only caches allowlisted shell assets'
);

const student = read('index.html');
const admin = read('admin.html');
check(
  !/storage\.from\(\s*['"]homework-submissions['"]\s*\)\s*\.getPublicUrl\s*\(/.test(student) &&
  admin.includes('createSignedUrl(path,300)') &&
  admin.includes('data-doma-homework-attachment'),
  'Homework attachment access remains private and uses signed URLs'
);

const headers = read('_headers');
check(
  ['X-Content-Type-Options: nosniff',
   'Referrer-Policy: strict-origin-when-cross-origin',
   'X-Frame-Options: SAMEORIGIN',
   'Permissions-Policy: camera=(), microphone=(self), geolocation=()']
    .every(value => headers.includes(value)),
  'Baseline browser security response headers are present'
);

for (const message of checks) console.log('PASS', message);
if (errors.length) {
  for (const message of errors) console.error('FAIL', message);
  process.exitCode = 1;
} else {
  console.log(`\nProduction safety validation passed (${checks.length} checks).`);
}
