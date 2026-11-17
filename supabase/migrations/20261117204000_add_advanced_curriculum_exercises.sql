-- Add reviewed manual exercises for the ten advanced HTML, CSS, JavaScript, SQL and API lessons.
-- These remain manual because the current editor does not provide verified automatic runners for all these formats.
INSERT INTO public.programming_exercises (id,lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode) VALUES ('b3d1f4a2-7c11-4a90-8d21-000000000301'::uuid,'web-03-html-tables-media','تطبيق: تقرير HTML بجدول وصورة بديلة','أنشئ صفحة تقرير بها جدول من ثلاثة صفوف وعنوان جدول، واستخدم th مع scope، وأضف صورة توضيحية بنص alt يصف محتواها. اختبر التنقل بلوحة المفاتيح وتأكد أن الجدول للبيانات لا للتخطيط.','<table>
  <!-- أضف caption وthead وtbody -->
</table>
<figure>
  <!-- أضف صورة مع alt مناسب وfigcaption -->
</figure>','html',true,'[]'::jsonb,'["caption يصف الجدول.","استخدم scope=col لعناوين الأعمدة وscope=row لعناوين الصفوف.","اكتب alt يصف ما تقدمه الصورة في سياق التقرير."]'::jsonb,'<table>
  <caption>درجات تدريبية</caption>
  <thead><tr><th scope="col">المادة</th><th scope="col">الدرجة</th></tr></thead>
  <tbody>
    <tr><th scope="row">الرياضيات</th><td>88</td></tr>
    <tr><th scope="row">العلوم</th><td>92</td></tr>
    <tr><th scope="row">اللغة</th><td>85</td></tr>
  </tbody>
</table>
<figure><img src="chart.png" alt="مخطط أعمدة يقارن درجات ثلاث مواد"><figcaption>مقارنة الدرجات.</figcaption></figure>','[{"weight":30,"criterion":"صحة البنية أو تصميم الحل"},{"weight":25,"criterion":"تنفيذ المتطلبات الأساسية"},{"weight":25,"criterion":"التحقق من الحالات والحدود"},{"weight":20,"criterion":"وضوح الشرح والتسليم"}]'::jsonb,'manual') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.programming_exercises (id,lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode) VALUES ('b3d1f4a2-7c11-4a90-8d21-000000000302'::uuid,'web-04-html-architecture','تطبيق: موقع من ثلاث صفحات','أنشئ index.html وصفحة lessons/index.html وصفحة contact/index.html. أضف تنقلًا بين الصفحات باستخدام روابط نسبية، واجعل لكل صفحة عنوانًا رئيسيًا وtitle مختلفًا. تأكد من أن رابط العودة للرئيسية يعمل من الصفحات الداخلية.','<!-- index.html -->
<header><a href="index.html">الرئيسية</a></header>
<nav>
  <!-- أضف روابط المسارات والتواصل -->
</nav>
<main><h1>...</h1></main>','html',true,'[]'::jsonb,'["الرابط من الصفحة الداخلية يحتاج ../ للرجوع إلى المجلد الأب.","استخدم title مختلفًا لكل صفحة.","اختبر كل رابط من موضعه الحقيقي."]'::jsonb,'<header><a href="../index.html">الرئيسية</a></header>
<nav aria-label="التنقل الرئيسي">
  <a href="../index.html">الرئيسية</a>
  <a href="../lessons/index.html">المسارات</a>
  <a href="../contact/index.html">تواصل</a>
</nav>
<main><h1>المسارات التعليمية</h1><p>اختر مسارك وابدأ التعلم.</p></main>','[{"weight":30,"criterion":"صحة البنية أو تصميم الحل"},{"weight":25,"criterion":"تنفيذ المتطلبات الأساسية"},{"weight":25,"criterion":"التحقق من الحالات والحدود"},{"weight":20,"criterion":"وضوح الشرح والتسليم"}]'::jsonb,'manual') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.programming_exercises (id,lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode) VALUES ('b3d1f4a2-7c11-4a90-8d21-000000000303'::uuid,'web-05-css-flexbox-components','تطبيق: شريط تنقل مرن','نسّق شريط تنقل يحتوي شعارًا وثلاثة روابط وزر إجراء. استخدم Flexbox وgap وflex-wrap، وأضف حالات focus-visible وhover. اختبر النصوص الطويلة واتجاه RTL.',' .toolbar {
  /* display, align-items, justify-content, gap */
}
.toolbar a:focus-visible {
  /* مؤشر تركيز واضح */
}','css',true,'[]'::jsonb,'["Flexbox يوزع العناصر على محور رئيسي واحد.","استخدم flex-wrap حتى لا يحدث تداخل.","لا تزل outline دون بديل مرئي."]'::jsonb,'.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
}
.toolbar a:focus-visible {
  outline: 3px solid #d6b56d;
  outline-offset: 3px;
}
.toolbar__links { display: flex; gap: .75rem; flex-wrap: wrap; }','[{"weight":30,"criterion":"صحة البنية أو تصميم الحل"},{"weight":25,"criterion":"تنفيذ المتطلبات الأساسية"},{"weight":25,"criterion":"التحقق من الحالات والحدود"},{"weight":20,"criterion":"وضوح الشرح والتسليم"}]'::jsonb,'manual') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.programming_exercises (id,lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode) VALUES ('b3d1f4a2-7c11-4a90-8d21-000000000304'::uuid,'web-06-css-responsive-themes','تطبيق: صفحة متجاوبة تدعم RTL','أنشئ تخطيطًا به محتوى رئيسي وشريط جانبي. اجعله عمودًا واحدًا على الهاتف وعمودين عند اتساع الشاشة. استخدم خصائص منطقية، واجعل الصور والنصوص الطويلة لا تسبب تمريرًا أفقيًا.','* { box-sizing: border-box; }
.layout {
  /* Grid عمود واحد افتراضيًا */
}
@media (min-width: 760px) {
  /* عمودان */
}','css',true,'[]'::jsonb,'["ابدأ بعمود واحد ثم أضف media query.","min-width:0 يساعد العناصر الشبكية على الانكماش.","استخدم margin-inline وpadding-inline بدل left/right."]'::jsonb,'* { box-sizing: border-box; }
.layout {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
}
.layout__main, .layout__aside { min-width: 0; }
img { max-width: 100%; height: auto; }
@media (min-width: 760px) {
  .layout { grid-template-columns: minmax(0, 2fr) minmax(220px, 1fr); }
}','[{"weight":30,"criterion":"صحة البنية أو تصميم الحل"},{"weight":25,"criterion":"تنفيذ المتطلبات الأساسية"},{"weight":25,"criterion":"التحقق من الحالات والحدود"},{"weight":20,"criterion":"وضوح الشرح والتسليم"}]'::jsonb,'manual') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.programming_exercises (id,lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode) VALUES ('b3d1f4a2-7c11-4a90-8d21-000000000305'::uuid,'web-08-js-storage-modules','تطبيق: حفظ إعدادات الواجهة محليًا','اكتب دالتين loadSettings وsaveSettings. اقرأ JSON من localStorage مع try/catch، وتحقق أن theme إما light أو dark وأن compact قيمة منطقية. لا تحفظ أي بيانات حساسة.','const KEY = "demo-settings";
const defaults = { theme: "dark", compact: false };
function loadSettings() {
  // اقرأ وتحقق من البيانات
}
function saveSettings(settings) {
  // احفظ JSON
}','javascript',true,'[]'::jsonb,'["JSON.parse قد يفشل؛ ضعه داخل try/catch.","لا تثق في القيم بعد قراءتها من التخزين.","استخدم JSON.stringify عند الحفظ."]'::jsonb,'const KEY = "demo-settings";
const defaults = { theme: "dark", compact: false };
function loadSettings() {
  try {
    const raw = localStorage.getItem(KEY);
    if (!raw) return defaults;
    const value = JSON.parse(raw);
    return {
      theme: value.theme === "light" ? "light" : "dark",
      compact: value.compact === true
    };
  } catch {
    return defaults;
  }
}
function saveSettings(settings) {
  localStorage.setItem(KEY, JSON.stringify(settings));
}','[{"weight":30,"criterion":"صحة البنية أو تصميم الحل"},{"weight":25,"criterion":"تنفيذ المتطلبات الأساسية"},{"weight":25,"criterion":"التحقق من الحالات والحدود"},{"weight":20,"criterion":"وضوح الشرح والتسليم"}]'::jsonb,'manual') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.programming_exercises (id,lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode) VALUES ('b3d1f4a2-7c11-4a90-8d21-000000000306'::uuid,'web-09-js-testing-modules','تطبيق: اختبر دالة نتيجة الدرجة','اكتب isValidScore وgetResult ثم اختبر 85 و50 و49 و0 و100 و-1 و101 وNaN. استخدم console.assert أو جدول نتائج، واشرح لماذا نختبر القيم الحدّية.','function isValidScore(value) {
  // تحقق من رقم بين 0 و100
}
function getResult(score) {
  // Invalid / Pass / Try again
}
// أضف حالات اختبار','javascript',true,'[]'::jsonb,'["Number.isFinite يرفض NaN والقيم غير الرقمية.","اختبر 49 و50 لأنهما على جانبي حد النجاح.","اجعل الاختبار يقارن الناتج الفعلي بالمتوقع."]'::jsonb,'function isValidScore(value) {
  return Number.isFinite(value) && value >= 0 && value <= 100;
}
function getResult(score) {
  if (!isValidScore(score)) return "Invalid";
  return score >= 50 ? "Pass" : "Try again";
}
const cases = [[85,"Pass"],[50,"Pass"],[49,"Try again"],[0,"Try again"],[100,"Pass"],[-1,"Invalid"],[101,"Invalid"],[NaN,"Invalid"]];
for (const [input, expected] of cases) {
  console.assert(getResult(input) === expected, { input, expected, actual: getResult(input) });
}','[{"weight":30,"criterion":"صحة البنية أو تصميم الحل"},{"weight":25,"criterion":"تنفيذ المتطلبات الأساسية"},{"weight":25,"criterion":"التحقق من الحالات والحدود"},{"weight":20,"criterion":"وضوح الشرح والتسليم"}]'::jsonb,'manual') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.programming_exercises (id,lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode) VALUES ('b3d1f4a2-7c11-4a90-8d21-000000000307'::uuid,'backend-09-sql-joins-aggregation','تطبيق: تقرير تسجيلات الكورسات','باستخدام students وcourses وenrollments، اكتب استعلامًا يعرض اسم الطالب واسم الكورس، ثم استعلامًا يعرض عدد التسجيلات لكل كورس. أضف استعلامًا يعرض الطلاب الذين لا يملكون تسجيلًا.','-- 1) Join students, enrollments, courses
-- 2) Count enrollments per course
-- 3) Find students without enrollments','sql',true,'[]'::jsonb,'["اربط كل مفتاح أجنبي بالمفتاح الأساسي المقابل.","استخدم LEFT JOIN للاحتفاظ بكل الكورسات أو الطلاب.","GROUP BY يتضمن الأعمدة غير التجميعية المختارة."]'::jsonb,'SELECT s.full_name, c.title
FROM enrollments e
JOIN students s ON s.id = e.student_id
JOIN courses c ON c.id = e.course_id;

SELECT c.title, COUNT(e.id) AS total
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.id
GROUP BY c.id, c.title;

SELECT s.id, s.full_name
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id
WHERE e.id IS NULL;','[{"weight":30,"criterion":"صحة البنية أو تصميم الحل"},{"weight":25,"criterion":"تنفيذ المتطلبات الأساسية"},{"weight":25,"criterion":"التحقق من الحالات والحدود"},{"weight":20,"criterion":"وضوح الشرح والتسليم"}]'::jsonb,'manual') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.programming_exercises (id,lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode) VALUES ('b3d1f4a2-7c11-4a90-8d21-000000000308'::uuid,'backend-10-sql-transactions-indexes','تطبيق: تجربة معاملة وفهرس','في قاعدة تدريب ببيانات وهمية، ابدأ معاملة وعدّل سجلين ثم نفّذ ROLLBACK وتحقق من رجوع القيم. بعد ذلك أنشئ فهرسًا على عمود تستخدمه في البحث واشرح فائدته وتكلفته. لا تستخدم قاعدة إنتاج.','BEGIN;
-- عدّل سجلين تجريبيين
-- راجع النتائج
ROLLBACK;

-- أنشئ فهرسًا في بيئة التدريب','sql',true,'[]'::jsonb,'["ROLLBACK يلغي تغييرات المعاملة قبل اعتمادها.","نفذ التدريب على بيانات وهمية فقط.","الفهرس يحسن بعض عمليات البحث لكنه يستهلك مساحة ويزيد كلفة الكتابة."]'::jsonb,'BEGIN;
UPDATE accounts SET balance = balance - 10 WHERE id = 1;
UPDATE accounts SET balance = balance + 10 WHERE id = 2;
SELECT id, balance FROM accounts WHERE id IN (1, 2);
ROLLBACK;

CREATE INDEX idx_lessons_level ON lessons(level);','[{"weight":30,"criterion":"صحة البنية أو تصميم الحل"},{"weight":25,"criterion":"تنفيذ المتطلبات الأساسية"},{"weight":25,"criterion":"التحقق من الحالات والحدود"},{"weight":20,"criterion":"وضوح الشرح والتسليم"}]'::jsonb,'manual') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.programming_exercises (id,lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode) VALUES ('b3d1f4a2-7c11-4a90-8d21-000000000309'::uuid,'backend-05-api-crud-pagination','تطبيق: صمم عقد API لإدارة الدروس','صمم جدولًا للمسارات التالية: قراءة القائمة، قراءة عنصر، إنشاء، تعديل جزئي، حذف. لكل مسار اكتب method وURL ورمز النجاح وحالة فشل. أضف query params للتصفية والترقيم وحدد حدًا أقصى للصفحات.','routes = [
  # TODO: GET list
  # TODO: GET details
  # TODO: POST create
  # TODO: PATCH update
  # TODO: DELETE remove
]
for route in routes:
  print(route)','text',true,'[]'::jsonb,'["استخدم اسم مورد جمع مثل lessons.","POST للإنشاء وPATCH للتعديل الجزئي.","حدد 400 أو 422 عند فشل التحقق حسب عقدك."]'::jsonb,'routes = [
  {"method":"GET","url":"/api/lessons?page=1&limit=20","success":200,"failure":400},
  {"method":"GET","url":"/api/lessons/42","success":200,"failure":404},
  {"method":"POST","url":"/api/lessons","success":201,"failure":422},
  {"method":"PATCH","url":"/api/lessons/42","success":200,"failure":404},
  {"method":"DELETE","url":"/api/lessons/42","success":204,"failure":404}
]
for route in routes:
  print(route)','[{"weight":30,"criterion":"صحة البنية أو تصميم الحل"},{"weight":25,"criterion":"تنفيذ المتطلبات الأساسية"},{"weight":25,"criterion":"التحقق من الحالات والحدود"},{"weight":20,"criterion":"وضوح الشرح والتسليم"}]'::jsonb,'manual') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.programming_exercises (id,lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode) VALUES ('b3d1f4a2-7c11-4a90-8d21-000000000310'::uuid,'backend-06-api-auth-errors','تطبيق: اختبر مصادقة API وصلاحياتها','اكتب حالات اختبار لواجهة API: طلب صحيح، طلب بلا جلسة، مستخدم مسجل لا يملك الصلاحية، مورد غير موجود، ومدخل غير صالح. حدد رمز الحالة والنتيجة المتوقعة لكل حالة.','cases = [
  # TODO: Add five API test cases
]
for case in cases:
  print(case)','text',true,'[]'::jsonb,'["401 تعني أن المصادقة غير صالحة أو غائبة.","403 تعني أن المستخدم معروف لكن العملية غير مسموحة.","لا تكشف stack trace أو أسرارًا في رسالة الخطأ."]'::jsonb,'cases = [
  {"case":"valid session and permission","status":200,"expected":"data returned"},
  {"case":"missing session","status":401,"expected":"authentication required"},
  {"case":"signed in without permission","status":403,"expected":"operation denied"},
  {"case":"resource missing","status":404,"expected":"not found"},
  {"case":"invalid input","status":422,"expected":"validation error"}
]
for case in cases:
  print(case)','[{"weight":30,"criterion":"صحة البنية أو تصميم الحل"},{"weight":25,"criterion":"تنفيذ المتطلبات الأساسية"},{"weight":25,"criterion":"التحقق من الحالات والحدود"},{"weight":20,"criterion":"وضوح الشرح والتسليم"}]'::jsonb,'manual') ON CONFLICT (id) DO NOTHING;
