-- Full-stack capstone: lesson, manually reviewed exercise, and project brief.
-- Idempotent content seed. No student progress, submissions, or quiz attempts are modified.

insert into public.programming_lessons
(id,module_id,title,summary,content_md,duration_minutes,sort_order,published)
values (
'capstone-09-fullstack-learning-platform','project-foundations',
'مشروع التخرج المتكامل: منصة تعليمية Full‑Stack',
'اجمع HTML وCSS وJavaScript وREST API وSQL وSupabase في تطبيق آمن مع تسجيل دخول وصلاحيات واختبارات.',
$lesson$
# مشروع التخرج: منصة تعليمية متكاملة Full‑Stack

## الهدف
ابنِ تطبيقًا عربيًا لإدارة الدروس والمهام يجمع واجهة HTML/CSS/JavaScript مع REST API وقاعدة بيانات SQL. سيشاهد الزائر الدروس المنشورة، بينما يستطيع المستخدم المسجل إنشاء مهامه وتحديثها ومشاهدة مهامه هو فقط.

## 1. قسّم النظام إلى طبقات
- **Frontend:** HTML دلالي، CSS متجاوب يدعم RTL، وJavaScript لإدارة التفاعل.
- **API:** طلبات HTTP وبيانات JSON ورسائل أخطاء موحدة.
- **Database:** جداول وعلاقات ومفاتيح وقيود وفهارس.
- **Security:** تسجيل دخول، صلاحيات على مستوى الصفوف، وحماية الأسرار.
افصل واجهة العرض عن طلبات الشبكة وعن إدارة الحالة.

## 2. المتطلبات
وظيفيًا: عرض الدروس، البحث فيها، تسجيل الدخول، إضافة مهمة، تغيير حالتها، وحذفها.
تقنيًا: دعم الهاتف والحاسوب ولوحة المفاتيح، وإظهار التحميل والنجاح والخطأ والنتائج الفارغة.
أمنيًا: لا يثق الخادم في بيانات المتصفح، ولا يستطيع المستخدم الوصول إلى سجلات مستخدم آخر، ولا توجد مفاتيح إدارية في ملفات الواجهة.

ارسم تدفق الاستخدام: فتح الصفحة ← تحميل الدروس ← تسجيل الدخول ← تحميل المهام الخاصة بالمستخدم ← إنشاء/تحديث مهمة ← تأكيد النتيجة من الخادم.

## 3. قاعدة البيانات
صمّم جداول profiles وcourses وlessons وtasks. يحتوي tasks على id وuser_id وtitle وis_done وcreated_at. اجعل user_id مفتاحًا خارجيًا إلى هوية المستخدم. أضف قيودًا تمنع العنوان الفارغ وتحدد طوله، واجعل حالة المهمة منطقية واضحة. أضف فهرسًا على user_id مع created_at إذا كانت الاستعلامات تعرض مهام كل مستخدم بترتيب زمني.

مثال SQL تعليمي:
```sql
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 120),
  is_done boolean not null default false,
  created_at timestamptz not null default now()
);
create index tasks_user_created_idx
  on public.tasks (user_id, created_at desc);
```
راجع المخطط الحالي قبل إنشاء أي جدول في مشروع قائم، واستخدم migrations قابلة للمراجعة.

## 4. الواجهة
أنشئ header وnav وmain وsection وform. أضف قائمة دروس، حقل بحث، نموذج مهمة، ومنطقة رسائل حالة. اربط كل input بعنصر label، وأظهر تركيز لوحة المفاتيح. استخدم dir="rtl" للنص العربي، واختبر عناوين طويلة وشاشة بعرض 360px.
في CSS استخدم متغيرات للألوان والمسافات وGrid أو Flexbox. لا تجعل اللون وحده يوضح حالة المهمة؛ أضف نصًا واضحًا. اجعل الأزرار ذات أسماء مفهومة.

## 5. تنظيم JavaScript
هيكل مقترح:
```text
src/
  api/client.js
  api/tasks.js
  state/tasks-store.js
  ui/render-tasks.js
  ui/form-handlers.js
  app.js
index.html
styles.css
README.md
```
اجعل client.js مسؤولًا عن fetch وتحليل الاستجابة ومعالجة الأخطاء. واجعل tasks.js يحتوي listTasks وcreateTask وupdateTask وdeleteTask. لا تخلط كود DOM بطلبات الشبكة.

مثال:
```js
async function requestJson(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      ...options.headers
    }
  });
  const body = await response.json().catch(() => null);
  if (!response.ok) {
    throw new Error(body?.message || `HTTP ${response.status}`);
  }
  return body;
}
```
اعرض نص المستخدم باستخدام textContent، ولا تمرره إلى innerHTML. تحقق من المدخل في الواجهة لتحسين التجربة، ثم أعد التحقق في الخادم وقاعدة البيانات.

## 6. عقد REST API
وثّق المسارات قبل البرمجة:
- GET /api/lessons: الدروس المنشورة، 200.
- GET /api/tasks: مهام المستخدم الحالي، 200.
- POST /api/tasks: إنشاء مهمة، 201.
- PATCH /api/tasks/:id: تحديث مهمة يملكها المستخدم، 200.
- DELETE /api/tasks/:id: حذف مهمة يملكها المستخدم، 204.

استخدم 400 للمدخل غير الصالح، 401 عند غياب تسجيل الدخول، 403 عند عدم امتلاك الإذن، 404 للسجل غير الموجود، و500 لخطأ غير متوقع. لا تعرض stack traces أو أسرارًا في رسالة الخطأ.

## 7. المصادقة وRLS
المصادقة تحدد هوية المستخدم، والتفويض يحدد ما يسمح له بفعله. استخدم مزودًا مثل Supabase Auth، وفعّل Row Level Security على جدول المهام. اجعل سياسات القراءة والإضافة والتعديل والحذف تتحقق من أن auth.uid() يساوي user_id، وتأكد في سياسة التعديل من الصف القديم والجديد.
لا تعتمد على إخفاء زر في الواجهة. لا تضع service_role أو أي مفتاح إداري في JavaScript الذي يصل للمتصفح. المفتاح العام المخصص للعميل لا يغني عن RLS. اسمح بقراءة المحتوى المنشور فقط للزوار، واقصر التعديل على الأدوار المخولة.

اختبر بحسابين تجريبيين: أنشئ مهمة بالحساب الأول، ثم حاول قراءتها أو تعديلها بالحساب الثاني. يجب أن تمنع قاعدة البيانات الوصول، حتى لو أرسل المستخدم طلب HTTP يدويًا.

## 8. حالات التشغيل
لكل طلب نفّذ الحالات التالية: قبل الطلب، تحميل مع منع الإرسال المتكرر، نجاح وتحديث العرض بعد تأكيد الخادم، وفشل برسالة مفهومة وإعادة محاولة عند الحاجة. اختبر انقطاع الشبكة، وانتهاء الجلسة، والاستجابة غير المتوقعة، والقائمة الفارغة. لا تعرض نجاحًا قبل استجابة مؤكدة.

## 9. الاختبارات
اختبر تحميل الدروس دون تسجيل دخول، ورفض عنوان فارغ أو أطول من 120 حرفًا، وإنشاء مهمة وتحديثها ثم إعادة تحميل الصفحة، ومحاولة الوصول إلى سجل حساب آخر، وانتهاء الجلسة، وفشل الشبكة. اختبر لوحة المفاتيح والهواتف والحاسوب. افصل اختبارات الوحدات لدوال التحقق عن اختبارات التكامل مع API وقاعدة البيانات.

## 10. النشر والتسليم
لا ترفع .env أو مفاتيح خاصة إلى Git. طبّق migrations على بيئة اختبار أولًا، وراجع RLS والسياسات والفهارس، ثم اختبر نسخة الإنتاج بحسابات تجريبية. أرفق README يشرح الإعداد والتشغيل وبنية الملفات ومخطط البيانات وعقد API والاختبارات. لا تضع بيانات شخصية في لقطات الشاشة.

## معيار النجاح
يكتمل المشروع عندما تعمل الواجهة مع API حقيقي، وتُحفظ المهام في قاعدة البيانات، وتبقى بيانات المستخدمين معزولة، وتنجح اختبارات النجاح والفشل، ويستطيع شخص آخر تشغيل المشروع من README فقط.
**تحدٍ إضافي:** أضف pagination لقائمة الدروس، ثم debounce للبحث، وقارن بين البحث محليًا والبحث من الخادم.
$lesson$,
100,10,true
)
on conflict (id) do update set
title=excluded.title, summary=excluded.summary, content_md=excluded.content_md,
duration_minutes=excluded.duration_minutes, sort_order=excluded.sort_order,
published=true, updated_at=now();

insert into public.programming_exercises
(lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values (
'capstone-09-fullstack-learning-platform',
'تحدي المشروع: ابنِ منصة المهام التعليمية المتصلة بقاعدة بيانات',
$instructions$نفّذ نسخة أولى من منصة تعليمية عربية. المطلوب: صفحة HTML دلالية RTL، وCSS متجاوب، وJavaScript مقسم إلى طبقات، وجدول tasks مرتبط بهوية المستخدم، وعقد API لمسارات GET وPOST وPATCH وDELETE، ومصادقة وسياسة RLS، واختبارات بحسابين منفصلين، وREADME. لا تضع مفاتيح إدارية في كود المتصفح. استخدم بيانات تجريبية فقط. التقييم يدوي وفق المعايير.$instructions$,
$starter$index.html
styles.css
src/app.js
src/api/client.js
src/api/tasks.js
database/schema.sql
database/policies.sql
docs/api-contract.md
tests/test-plan.md
README.md

ابدأ بصفحة ثابتة، ثم أضف التفاعل، ثم الاتصال بالخدمة، ثم اختبر الصلاحيات.$starter$,
'javascript',true,
'[{"name":"واجهة الصفحة","expected":"HTML دلالي RTL وتسميات واضحة وتصميم متجاوب"},{"name":"CRUD","expected":"إنشاء وقراءة وتحديث وحذف المهام من خلال API"},{"name":"التحقق","expected":"رفض العنوان الفارغ أو الأطول من 120 حرفًا في الواجهة والخادم"},{"name":"ملكية السجل","expected":"لا يستطيع حساب قراءة أو تعديل سجل حساب آخر"},{"name":"الأخطاء","expected":"رسائل واضحة لحالات 400 و401 و403 و404 و500 وانقطاع الشبكة"},{"name":"التوثيق","expected":"README وعقد API وخطة اختبار قابلة لإعادة التنفيذ"}]'::jsonb,
'["اكتب شكل JSON لكل مسار قبل تنفيذ الواجهة.","افصل دوال الشبكة عن دوال DOM.","اختبر RLS بحسابين؛ إخفاء السجلات في الواجهة لا يكفي.","استخدم textContent للنصوص القادمة من المستخدم.","لا تضع service_role أو أي سر في ملفات JavaScript العامة."]'::jsonb,
$solution$// نقطة بداية: أضف تهيئة الجلسة ودوال CRUD ومعالجة حالات الواجهة.
async function requestJson(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      ...options.headers
    }
  });
  const body = await response.json().catch(() => null);
  if (!response.ok) {
    throw new Error(body?.message || `HTTP ${response.status}`);
  }
  return body;
}
// TODO: listTasks(), createTask(), updateTask(), deleteTask()
$solution$,
'[{"weight":15,"criterion":"HTML وCSS","description":"واجهة دلالية متجاوبة تدعم RTL وإمكانية الوصول."},{"weight":20,"criterion":"JavaScript","description":"فصل الملفات ودوال الشبكة والتحقق والتعامل مع الحالات."},{"weight":20,"criterion":"SQL","description":"جداول وعلاقات وقيود وفهارس مناسبة."},{"weight":20,"criterion":"API","description":"عقد واضح وعمليات CRUD ورموز HTTP صحيحة."},{"weight":20,"criterion":"الأمان","description":"مصادقة وRLS واختبار عزل حسابين."},{"weight":5,"criterion":"التوثيق","description":"README وخطة اختبار ونتائج قابلة لإعادة التنفيذ."}]'::jsonb,
'manual'
)
on conflict (lesson_id) do update set
title=excluded.title, instructions=excluded.instructions, starter_code=excluded.starter_code,
language=excluded.language, is_published=true, test_cases=excluded.test_cases,
hints=excluded.hints, solution_code=excluded.solution_code, rubric=excluded.rubric,
grading_mode='manual', updated_at=now();

insert into public.programming_projects
(track_id,title,brief,requirements,is_published,sort_order,starter_files,rubric,estimated_hours,difficulty)
select
'real-world-projects',
'مشروع تخرج Full‑Stack: منصة تعليمية لإدارة الدروس والمهام',
'ابنِ تطبيقًا عربيًا متكاملًا يبدأ من واجهة HTML/CSS/JavaScript، ويتصل بواجهة REST API وقاعدة SQL، مع تسجيل دخول وRLS وعزل بيانات المستخدمين واختبارات وتوثيق.',
'["تحليل المتطلبات وتقسيم النظام إلى Frontend وAPI وDatabase وSecurity.","إنشاء واجهة RTL دلالية ومتجاوبة تعرض الدروس وتدير المهام.","تصميم جداول profiles وcourses وlessons وtasks مع المفاتيح والعلاقات والقيود والفهارس.","تنفيذ وتوثيق GET وPOST وPATCH وDELETE مع JSON ورموز HTTP واضحة.","فصل JavaScript إلى طبقة API وحالة وعرض ومعالجة التحميل والأخطاء.","تطبيق المصادقة وRLS والتحقق من ملكية السجل.","اختبار النجاح والفشل والمدخلات الحدية والوصول بين حسابين.","إعداد README ومخطط البيانات وعقد API وخطة الاختبار وتعليمات النشر دون أسرار."]'::jsonb,
true,2,
'{"index.html":"هيكل HTML5 عربي دلالي مع قائمة الدروس والمهام.","styles.css":"متغيرات CSS وتخطيط متجاوب ودعم RTL.","src/app.js":"نقطة تشغيل التطبيق وربط الأحداث.","src/api/client.js":"عميل HTTP وتحليل الاستجابات والأخطاء.","src/api/tasks.js":"دوال CRUD للمهام.","database/schema.sql":"جداول وعلاقات وقيود وفهارس.","database/policies.sql":"سياسات RLS للمستخدمين.","docs/api-contract.md":"عقد API وأمثلة JSON.","tests/test-plan.md":"حالات اختبار يدوية.","README.md":"الإعداد والتشغيل والتوثيق."}'::jsonb,
'[{"weight":15,"criterion":"Frontend","description":"واجهة دلالية متجاوبة تدعم RTL وإمكانية الوصول."},{"weight":20,"criterion":"Database","description":"جداول وعلاقات وقيود وفهارس صحيحة."},{"weight":20,"criterion":"API","description":"CRUD وعقد واضح ومعالجة أخطاء."},{"weight":20,"criterion":"JavaScript","description":"فصل الطبقات وإدارة الحالة والتحقق."},{"weight":20,"criterion":"Security","description":"مصادقة وRLS وعزل بيانات الحسابات."},{"weight":5,"criterion":"Delivery","description":"README واختبارات وتعليمات نشر."}]'::jsonb,
12,'advanced'
where not exists (
  select 1 from public.programming_projects
  where title='مشروع تخرج Full‑Stack: منصة تعليمية لإدارة الدروس والمهام'
);
