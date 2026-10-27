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
  'MR_FLUENT_KIDS_A1.html',
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

const studentWorkerPolicy = read('sw.js');
if (!/function normalizeShellUrl\s*\(/.test(studentWorkerPolicy) ||
    !/SHELL_CACHE_URLS\s*=\s*\[\.\.\.new Set\(SHELL\.map\(normalizeShellUrl\)\)\]/.test(studentWorkerPolicy)) {
  fail('sw.js: duplicate student root/index/query routes must share normalized shell cache keys');
}
if (!/url\.origin\s*!==\s*self\.location\.origin/.test(studentWorkerPolicy)) {
  fail('sw.js: cross-origin requests must bypass the student service worker cache');
}
if (!/function isCacheableStaticAssetUrl\s*\(/.test(studentWorkerPolicy) ||
    !/[Cc]acheableStaticAssetUrl/.test(studentWorkerPolicy)) {
  fail('sw.js: runtime caching must use a static-asset allowlist');
}
if (/\bcaches\.match\s*\(\s*req\s*\)/.test(studentWorkerPolicy)) {
  fail('sw.js: global cache lookup can return stale or cross-user dynamic responses');
}
if (!/req\.mode\s*===\s*['"]navigate['"][\s\S]*?fetch\(req,\s*\{\s*cache:\s*['"]no-store['"]\s*\}\)/.test(studentWorkerPolicy)) {
  fail('sw.js: app shell navigations must be network-first so deployed changes appear promptly');
}
if (!/hasSensitiveQuery\s*\(/.test(studentWorkerPolicy)) {
  fail('sw.js: auth tokens and sensitive query parameters must be excluded from cache writes');
}
ok('sw.js: only safe same-origin static assets are cached; navigations refresh online and dynamic data is network-only');

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


const kidsA1 = read('MR_FLUENT_KIDS_A1.html');
for (const required of ['id="pictureQuiz"', 'function pictureQuizRenderQuestion()', 'pictureQuizIndex%pictureQuizDeck.length', 'pictureQuizSpeak(current.word)', 'Unlimited', 'items.concat(letters.filter']) {
  if (!kidsA1.includes(required)) fail('MR_FLUENT_KIDS_A1.html: missing infinite Look & Choose loop or broad A1 word pool: ' + required);
}
ok('MR_FLUENT_KIDS_A1.html: Look & Choose has an unlimited loop with an expanded picture-word pool');
for (const required of ['id="listenQuiz"', 'function listenQuizRenderQuestion()', 'listenQuizIndex%listenQuizDeck.length', 'listenQuizSpeak(current.word)', 'data-listen-answer', 'Unlimited']) {
  if (!kidsA1.includes(required)) fail('MR_FLUENT_KIDS_A1.html: missing endless Listen & Choose loop: ' + required);
}
ok('MR_FLUENT_KIDS_A1.html: Listen & Choose loops endlessly with audio and picture choices');
const kidsIndex = read('index.html');
const a1RenderStart = kidsIndex.indexOf('function renderAlphabet(){');
const a1RenderEnd = kidsIndex.indexOf('function renderA2()', a1RenderStart);
const a1Render = a1RenderStart >= 0 && a1RenderEnd > a1RenderStart ? kidsIndex.slice(a1RenderStart, a1RenderEnd) : '';
for (const required of ['id="mfkrA1LookQuiz"', 'id="mfkrA1ListenQuiz"', 'function mfkrA1DrawLook()', 'function mfkrA1DrawListen()', ' · Unlimited', 'data-a1-listen-answer']) {
  if (!a1Render.includes(required)) fail('index.html: active Kids A1 route is missing an endless activity: ' + required);
}
for (const forbidden of ['slice(0,10)', 'if(mfkrLookIndex>=mfkrLookDeck.length)', 'if(mfkrListenIndex>=mfkrListenDeck.length)']) {
  if (a1Render.includes(forbidden)) fail('index.html: finite question limit remains in active A1 route: ' + forbidden);
}
ok('index.html: active Kids A1 route has endless Look & Choose and Listen & Choose activities');
const student = read('index.html');

if (!student.includes('class="mf-kids-entry-price"') ||
    !student.includes('<strong>100 <small>EGP</small></strong>') ||
    !student.includes('aria-label="Kids course price: 100 Egyptian pounds per 30 days"')) {
  fail('index.html: homepage Kids course card must display its 100 EGP / 30 days price');
} else {
  ok('index.html: homepage Kids course card displays 100 EGP / 30 days');
}

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

const gradeGateStart = student.indexOf('async function checkActiveSubscription(){');
const gradeGateEnd = student.indexOf('function renderLockedScreen()', gradeGateStart);
const gradeGate = gradeGateStart >= 0 && gradeGateEnd > gradeGateStart
  ? student.slice(gradeGateStart, gradeGateEnd)
  : '';
if (!student.includes('window.domaSelectedGradeId=String(g.id);') ||
    !gradeGate.includes("const preferredGradeId=String(window.domaSelectedGradeId||currentGrade?.id||'');") ||
    !gradeGate.includes("validSubs.find(sub=>String(sub.grade_id)===preferredGradeId)") ||
    gradeGate.includes("find(s=>{") && gradeGate.includes("})||null;\n    if(!active)")) {
  fail('index.html: subscription navigation must preserve the explicitly selected grade');
} else {
  ok('index.html: selected-grade navigation regression guard is present');
}

const quizSecurity = read('database/SECURE_QUIZ_REVIEW_RPC.sql');
if (!quizSecurity.includes("Answer review is disabled for this quiz") ||
    !quizSecurity.includes("coalesce(qps.show_review, true)") ||
    !quizSecurity.includes("IF NOT v_is_staff THEN")) {
  fail('database/SECURE_QUIZ_REVIEW_RPC.sql: student review must enforce the Show Review setting while preserving staff access');
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
const studentInstallerVersions = [...new Set(
  [...student.matchAll(/mrfluent=installer-v([0-9]+)/g)].map(match => match[1])
)];
const sw = read('sw.js');
const studentCacheVersion = (sw.match(/const CACHE_NAME = ['"]mr-fluent-offline-student-v([0-9]+)['"]/) || [])[1];
if (studentInstallerVersions.length !== 1) {
  fail('index.html: student service-worker registration URLs must use one consistent version');
}
if (!studentCacheVersion) {
  fail('sw.js: student PWA cache version is missing or invalid');
} else if (studentInstallerVersions.length === 1 && studentCacheVersion !== studentInstallerVersions[0]) {
  fail('sw.js: student service-worker URL version must match the offline cache version');
}
const studentManifest = JSON.parse(read('manifest.webmanifest'));
const expectedStudentStartUrl = studentCacheVersion
  ? `./?doma-app=student&launch=v${studentCacheVersion}`
  : null;
if (!expectedStudentStartUrl || studentManifest.start_url !== expectedStudentStartUrl) {
  fail('manifest.webmanifest: student app launch URL must match the current student PWA cache version on the working site root');
}
if (studentManifest.id !== './?doma-app=student-pwa-v2') {
  fail('manifest.webmanifest: student PWA must use the clean v2 identity for a fresh desktop installation');
}
if (studentManifest.display !== 'standalone') {
  fail('manifest.webmanifest: student PWA must use standalone display mode');
}
const adminVersions = [...new Set(admin.match(/doma-admin-v[0-9]+/g) || [])];
const adminVersion = adminVersions.at(-1);
const adminSw = read('admin-sw.js');
if (adminVersions.length > 1) fail('admin.html: multiple Admin PWA cache versions are present');
if (adminVersion && !adminSw.includes(adminVersion)) fail('admin-sw.js: admin PWA version does not match admin.html');
if (adminVersion && !admin.includes('admin-sw.js?doma-admin=' + adminVersion.replace('doma-admin-', ''))) {
  fail('admin.html: service worker registration URL version does not match the Admin PWA version');
}
if (!admin.includes('const fallback=window.loadSection;') || !admin.includes('fallback!==route')) {
  fail('admin.html: core Admin section loaders must fall back to the original section dispatcher');
}

const responseHeaders = read('_headers');
for (const required of [
  'X-Content-Type-Options: nosniff',
  'Referrer-Policy: strict-origin-when-cross-origin',
  'X-Frame-Options: DENY',
  'Permissions-Policy: camera=(), microphone=(self), geolocation=()'
]) {
  if (!responseHeaders.includes(required)) fail('_headers: missing baseline browser security header: ' + required);
}
ok('_headers: baseline browser security headers are present');

const kidsForeignKeyIndexes = read('database/ADD_MISSING_KIDS_FOREIGN_KEY_INDEXES.sql');
const requiredKidsIndexNames = [
  'doma_fkidx_kids_enroll_req_level',
  'doma_fkidx_kids_enroll_req_reviewed',
  'doma_fkidx_kids_enroll_req_track',
  'doma_fkidx_kids_enroll_level_track',
  'doma_fkidx_kids_place_recommended',
  'doma_fkidx_kids_place_track',
  'doma_fkidx_kids_place_user',
  'doma_fkidx_kids_progress_lesson',
  'doma_fkidx_kids_subs_level_track',
  'doma_fkidx_kids_subs_created_by',
  'doma_fkidx_kids_subs_level',
  'doma_fkidx_kids_subs_track'
];
for (const indexName of requiredKidsIndexNames) {
  if (!kidsForeignKeyIndexes.includes('CREATE INDEX IF NOT EXISTS ' + indexName)) {
    fail('Kids foreign-key index script is missing idempotent index: ' + indexName);
  }
}
if ((kidsForeignKeyIndexes.match(/CREATE INDEX IF NOT EXISTS/g) || []).length !== 12) {
  fail('Kids foreign-key index script must contain exactly 12 non-destructive index additions');
}
if (/\b(?:DROP\s+INDEX|DROP\s+TABLE|DELETE\s+FROM|ALTER\s+POLICY)\b/i.test(kidsForeignKeyIndexes)) {
  fail('Kids foreign-key index script must not drop data or alter access policies');
}
ok('Kids foreign-key index script includes 12 idempotent, non-destructive index additions');

const lessonLoaderStart = admin.indexOf('async function loadLessons(){');
const lessonLoaderEnd = admin.indexOf('function lessonForm(title,x=null){', lessonLoaderStart);
const lessonLoader = lessonLoaderStart >= 0 && lessonLoaderEnd > lessonLoaderStart
  ? admin.slice(lessonLoaderStart, lessonLoaderEnd)
  : '';
if (!/const LESSONS_PAGE_SIZE\s*=\s*100/.test(admin) ||
    !/lessonsPage\s*\*\s*LESSONS_PAGE_SIZE/.test(lessonLoader) ||
    !/\.range\(from,\s*from\s*\+\s*LESSONS_PAGE_SIZE\s*-\s*1\)/.test(lessonLoader) ||
    !/count:\s*['"]exact['"]/.test(lessonLoader) ||
    !/id="lessonsPagination"/.test(admin)) {
  fail('admin.html: Lessons table must use server-side pagination with a count and page controls');
}
if (/\.range\(0,\s*1999\)/.test(lessonLoader) ||
    /select\([^)]*\b(?:description|content)\b[^)]*\)/s.test(lessonLoader)) {
  fail('admin.html: Lessons list must not fetch 2000 rows or full lesson content for table display');
}
ok('admin.html: Lessons list uses 100-row server-side pagination and avoids loading full lesson bodies');


const quizLoaderStart = admin.indexOf('async function loadQuizzes(){');
const quizLoaderEnd = admin.indexOf('function quizForm(title,x=null){', quizLoaderStart);
const quizLoader = quizLoaderStart >= 0 && quizLoaderEnd > quizLoaderStart
  ? admin.slice(quizLoaderStart, quizLoaderEnd)
  : '';
if (!/const DOMA_QUIZ_PAGE_SIZE\s*=\s*100/.test(admin) ||
    !/domaQuizListPage\s*\*\s*DOMA_QUIZ_PAGE_SIZE/.test(quizLoader) ||
    !/\.range\(from,from\+DOMA_QUIZ_PAGE_SIZE-1\)/.test(quizLoader) ||
    !/count:\s*['"]exact['"]/.test(quizLoader) ||
    !/id="quizzesPagination"/.test(admin)) {
  fail('admin.html: Quizzes list must use server-side pagination with count and page controls');
}
if (/\.range\(0,\s*1999\)/.test(quizLoader)) {
  fail('admin.html: Quizzes list must not request up to 2000 rows at once');
}
ok('admin.html: Quizzes list uses 100-row server-side pagination');

const homeworkLoaderStart = admin.indexOf('async function loadHomework(){');
const homeworkLoaderEnd = admin.indexOf('function homeworkForm(title,x=null){', homeworkLoaderStart);
const homeworkLoader = homeworkLoaderStart >= 0 && homeworkLoaderEnd > homeworkLoaderStart
  ? admin.slice(homeworkLoaderStart, homeworkLoaderEnd)
  : '';
const homeworkUpgradeStart = admin.indexOf('async function loadHomeworkUpgraded(){');
const homeworkUpgradeEnd = admin.indexOf('function homeworkFormUpgraded(title,x=null){', homeworkUpgradeStart);
const homeworkUpgrade = homeworkUpgradeStart >= 0 && homeworkUpgradeEnd > homeworkUpgradeStart
  ? admin.slice(homeworkUpgradeStart, homeworkUpgradeEnd)
  : '';
if (!/const DOMA_HOMEWORK_PAGE_SIZE\s*=\s*100/.test(admin) ||
    !/domaHomeworkListPage\s*\*\s*DOMA_HOMEWORK_PAGE_SIZE/.test(homeworkLoader) ||
    !/\.range\(from,from\+DOMA_HOMEWORK_PAGE_SIZE-1\)/.test(homeworkLoader) ||
    !/count:\s*['"]exact['"]/.test(homeworkLoader) ||
    !/id="homeworkPagination"/.test(admin)) {
  fail('admin.html: Homework list must use server-side pagination with count and page controls');
}
if (!/domaHomeworkListPage\s*\*\s*DOMA_HOMEWORK_PAGE_SIZE/.test(homeworkUpgrade) ||
    !/\.range\(from,from\+DOMA_HOMEWORK_PAGE_SIZE-1\)/.test(homeworkUpgrade) ||
    !/count:\s*['"]exact['"]/.test(homeworkUpgrade)) {
  fail('admin.html: Enhanced Homework loader must preserve server-side pagination');
}
if (/\.range\(0,\s*1999\)/.test(homeworkLoader) ||
    /db\.from\(['"]homework['"]\)\.select\(['"]\*['"]\)/.test(homeworkUpgrade)) {
  fail('admin.html: Homework list must not fetch 2000 rows or every database column');
}
ok('admin.html: both Homework entry paths use 100-row server-side pagination');

const adminHealthStart = admin.indexOf('async function refreshHealth(){');
const adminHealthEnd = admin.indexOf('function loadHomeworkUpgraded(){', adminHealthStart);
const adminHealthSource = adminHealthStart >= 0 && adminHealthEnd > adminHealthStart
  ? admin.slice(adminHealthStart, adminHealthEnd)
  : '';
if (/db\.from\(['"]homework['"]\)\.select\(['"]\*['"]\)/.test(adminHealthSource)) {
  fail('admin.html: content-health counter must not fetch every homework column');
}
ok('admin.html: content-health homework query uses a minimal field selection');



const dashboardStart = admin.indexOf('<section id="section-dashboard"');
const dashboardEnd = admin.indexOf('<section id="section-grades"', dashboardStart);
const dashboardMarkup = dashboardStart >= 0 && dashboardEnd > dashboardStart
  ? admin.slice(dashboardStart, dashboardEnd)
  : '';
if (!dashboardMarkup.includes('id="dashboardRecentRequests"')) {
  fail('admin.html: dashboard must expose the recent subscription requests panel');
}
for (const section of ['lessons','quizzes','homework','students','sales','course-sales','kids-course-sales']) {
  if (!dashboardMarkup.includes('data-quick-section="' + section + '"')) {
    fail('admin.html: dashboard quick action is missing for section ' + section);
  }
}
if (!admin.includes("event.target.closest('[data-quick-section]')")) {
  fail('admin.html: dashboard quick-action buttons must use the section navigation handler');
}
if (admin.includes('Run DOMA_ADMIN_DATA_CONSISTENCY_FIX_FINAL.sql in Supabase')) {
  fail('admin.html: dashboard should not prescribe a database patch for every RPC error');
}
const dashboardLoaderStart = admin.indexOf('async function loadDashboard(){');
const dashboardLoaderEnd = admin.indexOf('async function loadGradesTable(){', dashboardLoaderStart);
const dashboardLoader = dashboardLoaderStart >= 0 && dashboardLoaderEnd > dashboardLoaderStart
  ? admin.slice(dashboardLoaderStart, dashboardLoaderEnd)
  : '';
if (!dashboardLoader.includes("requests.slice().sort") ||
    !dashboardLoader.includes("slice(0,5)") ||
    !dashboardLoader.includes("esc(student)") ||
    !dashboardLoader.includes("esc(detail)")) {
  fail('admin.html: recent subscription requests must be limited to five and escape student-supplied text');
}
ok('admin.html: dashboard provides safe quick actions and a sanitized latest-five request summary');

for (const message of checks) console.log('PASS', message);
if (errors.length) {
  for (const message of errors) console.error('FAIL', message);
  process.exitCode = 1;
} else {
  console.log(`\nPlatform static validation passed (${checks.length} checks).`);
}
