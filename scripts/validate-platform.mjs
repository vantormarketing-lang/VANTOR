import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const root = process.cwd();
const errors = [];
const checks = [];

function fail(message) { errors.push(message); }
function ok(message) { checks.push(message); }
function read(path) {
  const full = join(root, path);
  if (!existsSync(full)) {
    fail(`Missing required file: ${path}`);
    return '';
  }
  return readFileSync(full, 'utf8');
}

const htmlFiles = [
  'index.html',
  'admin.html',
  'MR_FLUENT_A1_COURSE.html',
  'MR_FLUENT_A2_COURSE.html',
  'MR_FLUENT_B1_COURSE.html',
  'MR_FLUENT_B2_COURSE.html',
  'MR_FLUENT_C1_COURSE.html',
  'MR_FLUENT_C2_COURSE.html'
];

for (const path of htmlFiles) {
  const source = read(path);
  if (!source) continue;

  let scriptCount = 0;
  for (const match of source.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script\s*>/gi)) {
    const attributes = match[1] || '';
    const code = match[2] || '';
    if (!code.trim()) continue;
    if (/\btype\s*=\s*["'](?:application\/json|application\/ld\+json|importmap)["']/i.test(attributes)) continue;
    if (/\btype\s*=\s*["']module["']/i.test(attributes)) continue;
    scriptCount++;
    try {
      // Compile without executing browser code.
      new Function(code);
    } catch (error) {
      fail(`${path}: inline script ${scriptCount}: ${error.message}`);
    }
  }
  ok(`${path}: checked ${scriptCount} inline JavaScript block(s)`);
}

for (const path of ['sw.js', 'admin-sw.js']) {
  const source = read(path);
  if (!source) continue;
  try { new Function(source); ok(`${path}: JavaScript syntax valid`); }
  catch (error) { fail(`${path}: ${error.message}`); }
}

for (const path of ['manifest.webmanifest', 'admin-manifest.webmanifest']) {
  const source = read(path);
  if (!source) continue;
  let manifest;
  try { manifest = JSON.parse(source); }
  catch (error) { fail(`${path}: invalid JSON: ${error.message}`); continue; }
  if (!manifest.name || !manifest.start_url || !manifest.scope || !Array.isArray(manifest.icons) || manifest.icons.length === 0) {
    fail(`${path}: missing required PWA fields or icons`);
    continue;
  }
  for (const icon of manifest.icons) {
    const relativePath = String(icon.src || '').split('?')[0].replace(/^\.\//, '');
    if (!relativePath || !existsSync(join(root, relativePath))) {
      fail(`${path}: icon asset not found: ${icon.src}`);
    }
  }
  ok(`${path}: valid JSON and icon assets exist`);
}

for (const level of ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']) {
  const path = `MR_FLUENT_${level}_COURSE.html`;
  const source = readFileSync(join(root, path), 'utf8');
  for (const required of [
    'mf-user-scoped-storage-v1',
    'assertStorageUser(user);',
    'mrfluent_complete_static_english_lesson',
    'syncCompletedLessonsToAccount(snapshot)'
  ]) {
    if (!source.includes(required)) fail(`${path}: missing progress/auth safety feature: ${required}`);
  }
}

const student = read('index.html');
if (/storage\.from\(\s*['"]homework-submissions['"]\s*\)\s*\.getPublicUrl\s*\(/.test(student)) {
  fail('index.html: homework attachments must not be exposed with getPublicUrl()');
}
if (!student.includes('storage://homework-submissions/')) {
  fail('index.html: private homework attachment marker is missing');
}

const admin = read('admin.html');
if (!admin.includes('createSignedUrl(path,300)') || !admin.includes('data-doma-homework-attachment')) {
  fail('admin.html: secure signed-link handling for private homework attachments is missing');
}

const battleRequirements = [
  'doma_create_battle_session',
  'doma_join_battle_session',
  'doma_start_battle_session',
  'doma_submit_battle_answer',
  'doma_advance_battle_session',
  'doma_record_battle',
  'config:{private:true',
  'await sb.realtime.setAuth();'
];
for (const feature of battleRequirements) {
  if (!student.includes(feature)) fail(`index.html: secure Battle feature is missing: ${feature}`);
}
if (/\.from\(\s*['"]quiz_questions['"]\s*\)\s*\.select\s*\(/.test(student)) {
  fail('index.html: student page must not query quiz_questions directly; use guarded RPCs');
}
const studentVersion = (student.match(/doma-student-v[0-9]+/g) || []).at(-1);
const sw = read('sw.js');
if (studentVersion && !sw.includes(studentVersion)) fail('sw.js: student PWA version does not match index.html');
const adminVersion = (admin.match(/doma-admin-v[0-9]+/g) || []).at(-1);
const adminSw = read('admin-sw.js');
if (adminVersion && !adminSw.includes(adminVersion)) fail('admin-sw.js: admin PWA version does not match admin.html');

for (const message of checks) console.log('PASS', message);
if (errors.length) {
  for (const message of errors) console.error('FAIL', message);
  process.exitCode = 1;
} else {
  console.log(`\nPlatform static validation passed (${checks.length} checks).`);
}
