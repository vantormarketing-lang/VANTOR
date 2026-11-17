-- Deepen the weakest published backend and developer-workflow lessons.
-- Existing lesson IDs, quiz records, student progress and submission IDs remain intact.
begin;

-- Lesson content updates were moved to a dedicated base64-safe migration.

-- Replace generic backend exercises with executable, lesson-aligned tasks.
update public.programming_exercises
set title='تحدّي عملي: اقرأ سجل طالب عبر منطق API',
 instructions='## المطلوب
اكتب برنامج Python يقرأ رقم طالب من الإدخال، ثم يبحث عنه في قائمة بيانات تدريبية.

## شروط النجاح
- إذا كان الطالب موجودًا اطبع Status: 200 ثم اسمه وصفه.
- إذا لم يكن موجودًا اطبع Status: 404 فقط.
- لا تستخدم رقم الطالب ثابتًا داخل الحل؛ اقرأه من input().
- لا تغيّر القائمة الأصلية.

## الإدخال
سطر واحد يحتوي رقم الطالب.',
 starter_code='students = [\n    {"id": 1, "name": "Mona", "grade": 2},\n    {"id": 2, "name": "Omar", "grade": 3}\n]\n\nstudent_id = int(input())\n# ابحث عن الطالب ثم اطبع Status والبيانات أو 404\n',
 language='python',grading_mode='stdout',
 hints='["استخدم next مع generator expression أو حلقة for للبحث عن id.","جهّز نتيجة افتراضية None قبل البحث أو استخدم next(..., None).","اختبر رقمًا موجودًا ورقمًا غير موجود."]'::jsonb,
 rubric='[{"weight":50,"criterion":"صحة البحث ورمز الحالة"},{"weight":25,"criterion":"قراءة الإدخال والتعامل مع عدم وجود السجل"},{"weight":25,"criterion":"وضوح المخرجات وتنظيم الكود"}]'::jsonb,
 solution_code='students = [{"id": 1, "name": "Mona", "grade": 2}, {"id": 2, "name": "Omar", "grade": 3}]\nstudent_id = int(input())\nstudent = next((item for item in students if item["id"] == student_id), None)\nif student is None:\n    print("Status: 404")\nelse:\n    print("Status: 200")\n    print("Student:", student["name"])\n    print("Grade:", student["grade"])',
 updated_at=now()
where lesson_id='backend-01-http-web';

update public.programming_exercises
set title='تحدّي عملي: وجّه طلب REST إلى المورد الصحيح',
 instructions='## المطلوب
اكتب برنامج Python يحاكي جزءًا صغيرًا من API للمهام.

اقرأ سطرين: Method ثم Path.
- GET /api/tasks يعرض عدد المهام.
- GET /api/tasks/2 يعرض عنوان المهمة ذات الرقم 2.
- أي مسار أو Method غير مدعوم يعرض Status: 404 أو Status: 405 حسب الحالة.

## شروط النجاح
- افصل بين Method وPath.
- استخدم قائمة مهام من كائنات.
- لا تخلط بين قراءة القائمة وقراءة مورد واحد.
- اطبع مخرجات ثابتة يسهل اختبارها.',
 starter_code='tasks = [\n    {"id": 1, "title": "Read HTML"},\n    {"id": 2, "title": "Review lesson"}\n]\n\nmethod = input().strip().upper()\npath = input().strip()\n# وجّه الطلب إلى المورد المناسب\n',
 language='python',grading_mode='stdout',
 hints='["ابدأ بفحص Method قبل المسار.","استخدم if للمسار الكامل، ويمكنك استخدام split لاستخراج رقم المورد.","أعد 405 عندما يكون المسار معروفًا لكن Method غير مدعوم."]'::jsonb,
 rubric='[{"weight":45,"criterion":"توجيه المسار والطريقة بصورة صحيحة"},{"weight":30,"criterion":"إرجاع رمز الحالة المناسب"},{"weight":25,"criterion":"وضوح المخرجات والتعامل مع المسارات غير المعروفة"}]'::jsonb,
 solution_code='tasks = [{"id": 1, "title": "Read HTML"}, {"id": 2, "title": "Review lesson"}]\nmethod = input().strip().upper()\npath = input().strip()\nif path == "/api/tasks":\n    if method == "GET":\n        print("Status: 200")\n        print("Tasks:", len(tasks))\n    else:\n        print("Status: 405")\nelif path.startswith("/api/tasks/"):\n    if method != "GET":\n        print("Status: 405")\n    else:\n        try:\n            task_id = int(path.rsplit("/", 1)[1])\n        except ValueError:\n            task_id = -1\n        task = next((item for item in tasks if item["id"] == task_id), None)\n        if task is None:\n            print("Status: 404")\n        else:\n            print("Status: 200")\n            print("Task:", task["title"])\nelse:\n    print("Status: 404")',
 updated_at=now()
where lesson_id='backend-02-rest-json';

update public.programming_exercises
set title='تحدّي عملي: حاكِ استعلام SELECT باستخدام WHERE',
 instructions='## المطلوب
لديك قائمة طلاب تدريبية. اقرأ رقم الصف الدراسي من الإدخال، ثم اطبع أسماء الطلاب في هذا الصف مرتبة أبجديًا وعدد النتائج.

## شروط النجاح
- استخدم شرطًا يعادل WHERE grade = selected_grade.
- رتّب الأسماء قبل الطباعة.
- اطبع Results: N في النهاية.
- يجب أن يعمل الحل مع أكثر من قيمة إدخال.',
 starter_code='students = [\n    {"name": "Mona", "grade": 2},\n    {"name": "Omar", "grade": 3},\n    {"name": "Laila", "grade": 2}\n]\n\nselected_grade = int(input())\n# صفِّ الطلاب ورتب أسماء النتائج\n',
 language='python',grading_mode='stdout',
 hints='["أنشئ قائمة أسماء باستخدام list comprehension وشرط grade.","استخدم sort() أو sorted() لترتيب النتائج.","اطبع كل اسم في سطر ثم عدد النتائج."]'::jsonb,
 rubric='[{"weight":45,"criterion":"صحة التصفية حسب الصف"},{"weight":30,"criterion":"ترتيب النتائج أبجديًا"},{"weight":25,"criterion":"تنسيق المخرجات وعدّ النتائج"}]'::jsonb,
 solution_code='students = [{"name": "Mona", "grade": 2}, {"name": "Omar", "grade": 3}, {"name": "Laila", "grade": 2}]\nselected_grade = int(input())\nresults = sorted([student["name"] for student in students if student["grade"] == selected_grade])\nfor name in results:\n    print(name)\nprint("Results:", len(results))',
 updated_at=now()
where lesson_id='backend-03-databases-sql';

update public.programming_exercises
set title='تحدّي عملي: طبّق مبدأ أقل صلاحية',
 instructions='## المطلوب
اكتب برنامجًا يحاكي قرار صلاحية على الخادم. اقرأ الدور ثم العملية من الإدخال.

الأدوار:
- student: read_own فقط.
- teacher: read_own وreview_submissions.
- admin: read_own وreview_submissions وmanage_membership.

## شروط النجاح
- اطبع Allowed إذا كانت العملية ضمن صلاحيات الدور.
- اطبع Denied خلاف ذلك.
- أي دور غير معروف يحصل على Denied.
- لا تعتبر مجرد معرفة اسم الدور كافية؛ افحص العملية المطلوبة.',
 starter_code='permissions = {\n    "student": {"read_own"},\n    "teacher": {"read_own", "review_submissions"},\n    "admin": {"read_own", "review_submissions", "manage_membership"}\n}\n\nrole = input().strip()\naction = input().strip()\n# افحص الصلاحية واطبع Allowed أو Denied\n',
 language='python',grading_mode='stdout',
 hints='["استخدم permissions.get(role, set()) حتى يكون الدور المجهول بلا صلاحيات.","تحقق من وجود action داخل مجموعة الصلاحيات.","في نظام حقيقي يجب أن يأتي الدور من مصدر موثوق على الخادم."]'::jsonb,
 rubric='[{"weight":50,"criterion":"صحة قرار السماح والمنع"},{"weight":25,"criterion":"التعامل مع الدور المجهول"},{"weight":25,"criterion":"تطبيق مبدأ أقل صلاحية"}]'::jsonb,
 solution_code='permissions = {"student": {"read_own"}, "teacher": {"read_own", "review_submissions"}, "admin": {"read_own", "review_submissions", "manage_membership"}}\nrole = input().strip()\naction = input().strip()\nallowed = permissions.get(role, set())\nprint("Allowed" if action in allowed else "Denied")',
 updated_at=now()
where lesson_id='backend-04-auth-security';

-- Replace generic workflow practice with authentic reviewable tasks.
update public.programming_exercises
set title='مهمة عملية: أنشئ سجل Git منظمًا',
 instructions='## المطلوب
في مجلد تدريب جديد:
1. أنشئ README يشرح اسم المشروع وهدفه.
2. ابدأ مستودع Git محليًا.
3. افحص الحالة باستخدام git status.
4. جهّز README فقط وأنشئ commit برسالة واضحة.
5. أضف ملف notes.txt وأنشئ commit ثانيًا.
6. اعرض السجل باستخدام git log --oneline.

## التسليم
اكتب الأوامر التي نفذتها بالترتيب، وانسخ ناتج status قبل أول commit وبعده، ثم اشرح الفرق بين Working Directory وStaging Area وCommit.

## تنبيه
استخدم مجلد تدريب لا يحتوي على ملفات شخصية أو أسرار. لا تستخدم أوامر حذف أو reset.',
 starter_code='# 1) اكتب هدف المشروع\n# 2) دوّن أوامر Git التي نفذتها\n# 3) أرفق ملخص git status وgit log\n',
 hints='["ابدأ بـ git status قبل تجهيز أي ملف.","استخدم git add README.md لتجهيز ملف محدد.","راجع git status قبل كل commit."]'::jsonb,
 rubric='[{"weight":35,"criterion":"تسلسل أوامر Git صحيح"},{"weight":25,"criterion":"وجود لقطتي Commit برسائل مفهومة"},{"weight":25,"criterion":"شرح Working Directory وStaging وCommit"},{"weight":15,"criterion":"عدم تضمين أسرار أو ملفات غير مقصودة"}]'::jsonb,
 updated_at=now()
where lesson_id='workflow-01-git-basics';

update public.programming_exercises
set title='مهمة عملية: جهّز Pull Request قابلًا للمراجعة',
 instructions='## المطلوب
تخيل أنك أضفت بطاقة ملف شخصي إلى مشروع تدريبي.
- أنشئ فرعًا باسم feature/profile-card.
- نفّذ تعديلًا صغيرًا على README يشرح الميزة.
- أنشئ Commit برسالة تصف التغيير.
- اكتب وصف Pull Request يوضح المشكلة والحل والاختبارات.
- اذكر الملفات التي يجب أن يراجعها زميلك.

## التسليم
اكتب وصف PR منظمًا بهذه العناوين: الهدف، التغييرات، الاختبارات، ملاحظات للمراجع.

## معيار التفكير
اذكر كيف ستتعامل مع تعارض إذا عدّل شخص آخر نفس الجزء من الملف.',
 starter_code='# الهدف:\n\n# التغييرات:\n\n# الاختبارات:\n\n# ملاحظات للمراجع:\n',
 hints='["اجعل اسم الفرع يصف الميزة لا اسم الشخص.","اشرح لماذا التغيير مطلوب وليس فقط ما الملفات التي عدلتها.","لا تدمج التغيير قبل قراءة diff وتشغيل الاختبارات."]'::jsonb,
 rubric='[{"weight":25,"criterion":"اسم فرع مناسب وتسلسل عمل مفهوم"},{"weight":35,"criterion":"وصف PR يشرح الهدف والتغييرات"},{"weight":25,"criterion":"اختبارات ومراجعة واضحة"},{"weight":15,"criterion":"خطة منطقية لحل التعارض"}]'::jsonb,
 updated_at=now()
where lesson_id='workflow-02-branches-github';

update public.programming_exercises
set title='تحدّي عملي: اختبر حساب السعر بعد الخصم',
 instructions='## المطلوب
اكتب برنامج Python يقرأ السعر ثم نسبة الخصم، ويطبع السعر النهائي بمنزلتين عشريتين.

## قواعد التحقق
- السعر لا يقل عن صفر.
- نسبة الخصم بين 0 و100 شاملًا.
- إذا كانت القيم غير صالحة اطبع Invalid input.
- لا تقرّب النتيجة قبل إجراء الحساب.

## اختبر الحالات
السعر العادي، خصم صفر، خصم 100%، وخصم أكبر من 100%.',
 starter_code='price = float(input())\ndiscount = float(input())\n# تحقق من المدخلات واحسب السعر النهائي\n',
 language='python',grading_mode='unit_tests',
 hints='["تحقق من السعر ونسبة الخصم قبل الحساب.","السعر النهائي = السعر × (1 - نسبة الخصم / 100).","استخدم format(value, \".2f\") أو f-string لمنزلتين عشريتين."]'::jsonb,
 rubric='[{"weight":45,"criterion":"صحة معادلة الخصم"},{"weight":30,"criterion":"التحقق من الحدود والقيم غير الصالحة"},{"weight":25,"criterion":"تنسيق الناتج إلى منزلتين"}]'::jsonb,
 solution_code='price = float(input())\ndiscount = float(input())\nif price < 0 or not 0 <= discount <= 100:\n    print("Invalid input")\nelse:\n    final = price * (1 - discount / 100)\n    print(f"{final:.2f}")',
 updated_at=now()
where lesson_id='workflow-03-testing-quality';

update public.programming_exercises
set title='مشروع عملي: ابنِ قائمة مهام قابلة للاختبار',
 instructions='## المطلوب
ابنِ تطبيق قائمة مهام باستخدام HTML وCSS وJavaScript.

## الوظائف الأساسية
- إضافة مهمة بعنوان غير فارغ.
- عرض المهام في قائمة.
- تغيير حالة المهمة إلى مكتملة أو غير مكتملة.
- حذف مهمة.
- إظهار رسالة واضحة عندما تكون القائمة فارغة.

## التسليم
أرسل رابط المستودع أو ملفات المشروع، وأرفق README يتضمن طريقة التشغيل والميزات والاختبارات.

## اختبارات مطلوبة
جرّب إدخالًا فارغًا، ومهمتين، وإكمال مهمة، وحذف آخر مهمة، واستخدام الواجهة على شاشة هاتف.',
 starter_code='// ابدأ بتمثيل المهام في مصفوفة من الكائنات\nconst tasks = [];\n\nfunction addTask(title) {\n  // نظّف المدخل وتحقق منه ثم أضف كائن المهمة\n}\n',
 language='javascript',grading_mode='manual',
 hints='["ابدأ بنموذج البيانات قبل تنسيق الواجهة.","استخدم id ثابتًا لكل مهمة ولا تعتمد على index وحده.","قسّم العمل إلى addTask وtoggleTask وdeleteTask وrenderTasks."]'::jsonb,
 rubric='[{"weight":30,"criterion":"إضافة المهام وعرضها بصورة صحيحة"},{"weight":20,"criterion":"تغيير حالة المهمة وحذفها"},{"weight":15,"criterion":"التحقق من المدخلات والحالة الفارغة"},{"weight":15,"criterion":"تصميم متجاوب وسهل الاستخدام"},{"weight":20,"criterion":"اختبارات وREADME واضحان"}]'::jsonb,
 updated_at=now()
where lesson_id='project-01-plan-build-ship';

-- Add private automated cases for the four executable backend exercises.
insert into private.programming_exercise_tests(exercise_id,test_cases,updated_at)
select e.id, v.test_cases::jsonb, now()
from public.programming_exercises e
join (values
 ('backend-01-http-web', '[{"label":"existing student","stdin":"2\n","expected_output":"Status: 200\nStudent: Omar\nGrade: 3"},{"label":"missing student","stdin":"99\n","expected_output":"Status: 404"}]'),
 ('backend-02-rest-json', '[{"label":"list collection","stdin":"GET\n/api/tasks\n","expected_output":"Status: 200\nTasks: 2"},{"label":"read item","stdin":"GET\n/api/tasks/2\n","expected_output":"Status: 200\nTask: Review lesson"},{"label":"unsupported method","stdin":"POST\n/api/tasks/2\n","expected_output":"Status: 405"}]'),
 ('backend-03-databases-sql', '[{"label":"grade two","stdin":"2\n","expected_output":"Laila\nMona\nResults: 2"},{"label":"grade three","stdin":"3\n","expected_output":"Omar\nResults: 1"}]'),
 ('backend-04-auth-security', '[{"label":"student cannot manage membership","stdin":"student\nmanage_membership\n","expected_output":"Denied"},{"label":"teacher can review","stdin":"teacher\nreview_submissions\n","expected_output":"Allowed"},{"label":"unknown role denied","stdin":"guest\nread_own\n","expected_output":"Denied"}]'),
 ('workflow-03-testing-quality', '[{"label":"standard discount","stdin":"1000\n15\n","expected_output":"850.00"},{"label":"zero discount","stdin":"100\n0\n","expected_output":"100.00"},{"label":"full discount","stdin":"100\n100\n","expected_output":"0.00"},{"label":"invalid discount","stdin":"100\n120\n","expected_output":"Invalid input"}]')
) as v(lesson_id,test_cases) on true
where e.lesson_id=v.lesson_id
on conflict (exercise_id) do update
set test_cases=excluded.test_cases,updated_at=now();

commit;
