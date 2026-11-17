-- Deepen the weakest published backend and developer-workflow lessons.
-- Existing lesson IDs, quiz records, student progress and submission IDs remain intact.
begin;

update public.programming_lessons set content_md=$lesson$
# كيف يعمل الويب: HTTP والعميل والخادم

## هدف الدرس
ستتتبع رحلة طلب حقيقي من المتصفح إلى الخادم ثم عودة الاستجابة، وتتعلم كيف تميّز بين نجاح الطلب وفشل الاتصال أو فشل العملية.

## 1. الأطراف المشاركة
- **Client:** البرنامج الذي يبدأ الطلب، مثل المتصفح أو تطبيق الهاتف.
- **Server:** يستقبل الطلب، يتحقق منه، ينفذ المنطق المسموح، ثم يعيد استجابة.
- **API:** نقطة الاتصال المنظمة بين العميل والخادم.
- **Database:** تخزن البيانات التي يحتاجها الخادم.

تخيّل أن تطبيق DOMA يريد عرض بيانات طالب. الواجهة لا ينبغي أن تتصل بقاعدة البيانات بصلاحيات المدير؛ بل ترسل طلبًا إلى API، والخادم يتحقق من هوية الطالب وما يحق له رؤيته.

## 2. مكونات طلب HTTP
يتكون الطلب عادة من:
1. **Method:** نوع العملية مثل GET أو POST.
2. **Path:** المورد المطلوب مثل /api/students/12.
3. **Headers:** معلومات مثل نوع المحتوى أو رمز الجلسة.
4. **Body:** بيانات مرسلة مع بعض الطلبات، مثل بيانات إنشاء مهمة.

مثال توضيحي:
```http
GET /api/students/12 HTTP/1.1
Host: academy.example
Accept: application/json
```

## 3. الاستجابة
تحتوي الاستجابة على Status Code وHeaders وBody. أمثلة:
- 200: الطلب نجح.
- 201: تم إنشاء مورد.
- 400: البيانات أو صيغة الطلب غير صحيحة.
- 401: لا توجد مصادقة صالحة.
- 403: المستخدم معروف لكنه لا يملك الصلاحية.
- 404: المورد غير موجود.
- 500: حدث خطأ غير متوقع في الخادم.

لا تخلط بين 401 و403: الأولى تتعلق بإثبات الهوية، والثانية تتعلق بالصلاحية.

## 4. اختيار Method مناسب
- GET لقراءة البيانات دون تغييرها.
- POST لإنشاء مورد أو تنفيذ عملية.
- PATCH لتحديث جزء من مورد.
- PUT لاستبدال مورد وفق تصميم API.
- DELETE لطلب حذف مورد بعد التحقق من الصلاحيات.

## 5. تتبع طلب في مثال مبسط
الكود التالي يحاكي استجابة خادم لطلب قراءة طالب. إنه نموذج تعليمي للمنطق، وليس خادمًا حقيقيًا:
```python
students = [
    {"id": 1, "name": "Mona", "grade": 2},
    {"id": 2, "name": "Omar", "grade": 3}
]

request = {"method": "GET", "student_id": 2}

student = next(
    (item for item in students if item["id"] == request["student_id"]),
    None
)

if request["method"] == "GET" and student is not None:
    response = {"status": 200, "body": student}
else:
    response = {"status": 404, "body": {"message": "Not found"}}

print("Status:", response["status"])
if response["status"] == 200:
    print("Student:", response["body"]["name"])
```

الناتج:
```text
Status: 200
Student: Omar
```

## 6. ماذا يحدث خطوة بخطوة؟
1. يحدد العميل المورد المطلوب.
2. يصل الطلب إلى المسار الصحيح في الخادم.
3. يتحقق الخادم من الجلسة والصلاحية والمدخلات.
4. يقرأ البيانات أو ينفذ العملية.
5. يعيد Status Code وبيانات مناسبة.
6. تعرض الواجهة النتيجة أو رسالة خطأ مفهومة.

## 7. أخطاء شائعة
- اعتبار كل استجابة 200 دليلًا على أن البيانات صحيحة؛ يجب أيضًا التحقق من محتوى الاستجابة.
- وضع كلمة مرور أو مفتاح سري في JavaScript المرسل للمتصفح.
- اعتبار إخفاء زر في الواجهة بديلًا عن فحص الصلاحية على الخادم.
- إعادة تفاصيل داخلية أو أسرار في رسالة الخطأ.
- استخدام POST لكل شيء دون تصميم واضح للموارد والعمليات.

## تدريب موجّه
اكتب طلب GET لقراءة مهمة واحدة، وحدد Method وPath وHeader المتوقع، ثم اكتب شكل استجابة ناجحة واستجابة 404.

## تحدي مستقل
صمم رحلة طلب لتحديث درجة طالب: ما المسار؟ ما البيانات التي سترسل؟ ما الذي يجب على الخادم التحقق منه قبل الحفظ؟ وما رمز الحالة المناسب عند النجاح؟

## خلاصة
HTTP هو اتفاق منظم بين العميل والخادم. افهم الطلب والاستجابة ورموز الحالة، واجعل التحقق من الهوية والصلاحيات على الخادم دائمًا.
$lesson$, summary='تتبّع طلب HTTP من المتصفح إلى الخادم، وافهم Methods وHeaders وBody ورموز الحالة والتحقق من الصلاحيات.', duration_minutes=35, updated_at=now()
where id='backend-01-http-web';

update public.programming_lessons set content_md=$lesson$
# تصميم API وREST وبيانات JSON

## هدف الدرس
ستحوّل احتياجًا من التطبيق إلى موارد ومسارات واضحة، وتبني استجابة JSON مفهومة، وتتعامل مع المدخلات غير الصحيحة بطريقة منظمة.

## 1. ما API؟
واجهة برمجية هي عقد يحدد كيف يطلب برنامج خدمة من برنامج آخر. العقد يوضح:
- المسار الذي يستقبل الطلب.
- نوع العملية المسموح بها.
- البيانات المطلوبة.
- شكل الاستجابة.
- رموز الحالة والأخطاء المحتملة.

## 2. صمّم حول الموارد
لنفترض أن لدينا تطبيق مهام. المورد الأساسي هو task:
- GET /api/tasks: قراءة قائمة المهام.
- GET /api/tasks/12: قراءة مهمة واحدة.
- POST /api/tasks: إنشاء مهمة.
- PATCH /api/tasks/12: تحديث جزء من المهمة.
- DELETE /api/tasks/12: طلب حذف المهمة.

اسم المورد غالبًا يكون اسمًا واضحًا، وتحدد Method طبيعة العملية.

## 3. JSON صيغة تبادل بيانات
```json
{
  "id": 12,
  "title": "Review lesson",
  "completed": false,
  "priority": 2
}
```

قواعد مهمة:
- أسماء الخصائص والنصوص بين علامتي اقتباس مزدوجتين.
- القيم المنطقية true وfalse دون اقتباس.
- لا تضع فاصلة بعد آخر خاصية.
- استخدم null عندما تكون القيمة غير متاحة وفق عقد البيانات.

## 4. مثال عملي على قراءة مورد
```python
import json

tasks = [
    {"id": 1, "title": "Read HTML", "completed": True},
    {"id": 2, "title": "Practice CSS", "completed": False}
]

task_id = 2
task = next((item for item in tasks if item["id"] == task_id), None)

if task is None:
    response = {"status": 404, "body": {"error": "Task not found"}}
else:
    response = {"status": 200, "body": task}

print("Status:", response["status"])
print(json.dumps(response["body"], ensure_ascii=False))
```

الناتج يتضمن Status: 200 وكائن المهمة الثانية بصيغة JSON.

## 5. التحقق من المدخلات
عند استقبال POST لا تفترض أن العميل أرسل بيانات صحيحة. تحقق من:
1. أن الجسم JSON صالح.
2. أن title نص وليس قيمة من نوع آخر.
3. أن النص ليس فارغًا بعد إزالة المسافات.
4. أن طول النص ضمن الحد المسموح.
5. أن المستخدم يملك صلاحية إنشاء المهمة.

أعد 400 عند وجود بيانات غير صالحة، ولا تحفظ سجلًا ناقصًا.

## 6. صمّم أخطاء ثابتة
يمكن أن تكون الاستجابة:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Title is required"
  }
}
```

لا ترسل Stack Trace أو أسماء جداول داخلية أو مفاتيح سرية إلى المستخدم.

## 7. كيف تختبر API؟
- جرّب المسار الصحيح.
- جرّب رقم مورد غير موجود.
- جرّب Method غير مسموح.
- جرّب جسمًا فارغًا أو نوع بيانات خاطئًا.
- جرّب مستخدمًا لا يملك الصلاحية.
- تأكد من أن شكل JSON ثابت في النجاح والخطأ.

## أخطاء شائعة
- وضع أفعال كثيرة داخل أسماء المسارات بدل استخدام HTTP Methods.
- إرجاع 200 مع رسالة خطأ داخلية بدل رمز مناسب.
- قبول كل الحقول التي يرسلها العميل دون قائمة مسموح بها.
- الاعتماد على تحقق الواجهة فقط.
- نسيان توثيق الحقول المطلوبة والاختيارية.

## تدريب موجّه
اكتب عقد API لإضافة مهمة: المسار، Method، مثال Body، الاستجابة الناجحة، وحالتين محتملتين للفشل.

## تحدي مستقل
صمّم API لإدارة دروس طالب. يجب أن تسمح بقراءة الدروس المتاحة وتحديث حالة إكمال درس واحد، مع منع الطالب من تعديل تقدم طالب آخر.

## خلاصة
API الجيدة عقد واضح حول الموارد. استخدم JSON منظمًا، ورموز حالة دقيقة، وتحقق من كل مدخل وصلاحية على الخادم.
$lesson$, summary='صمّم موارد ومسارات REST، واكتب JSON صحيحًا، وتحقق من المدخلات، واختبر حالات النجاح والأخطاء.', duration_minutes=35, updated_at=now()
where id='backend-02-rest-json';

update public.programming_lessons set content_md=$lesson$
# قواعد البيانات وSQL للمبتدئين

## هدف الدرس
ستفهم كيف تحفظ قاعدة البيانات السجلات، وتقرأ مجموعة محددة باستخدام SQL، وتربط الاستعلامات بعقد API دون خلط مسؤولية الواجهة بمسؤولية قاعدة البيانات.

## 1. النموذج العلائقي
الجدول يمثل نوعًا من البيانات، والصف يمثل سجلًا، والعمود يمثل خاصية:
| id | name | grade | active |
|---:|---|---:|---|
| 1 | Mona | 2 | true |
| 2 | Omar | 3 | true |
| 3 | Laila | 2 | false |

يجب أن يكون لكل جدول مفتاح أساسي يميز كل صف. وعند ربط جدول بآخر نستخدم مفتاحًا خارجيًا.

## 2. قراءة البيانات باستخدام SELECT
```sql
SELECT id, name, grade
FROM students
WHERE grade = 2
ORDER BY name;
```

- SELECT يحدد الأعمدة المطلوبة.
- FROM يحدد الجدول.
- WHERE يرشح الصفوف.
- ORDER BY يرتب النتائج.

إذا أردت عددًا محدودًا من النتائج أضف LIMIT.

## 3. شروط مهمة
```sql
SELECT name
FROM students
WHERE active = TRUE AND grade >= 2;
```

استخدم IS NULL لفحص القيم المفقودة؛ لا تستخدم = NULL. تذكر أن NULL ليست صفرًا وليست نصًا فارغًا.

## 4. الإضافة والتحديث والحذف
```sql
INSERT INTO students (name, grade, active)
VALUES ('Sara', 1, TRUE);

UPDATE students
SET grade = 2
WHERE id = 4;

DELETE FROM students
WHERE id = 4;
```

في أي تحديث أو حذف راجع شرط WHERE أولًا. في بيئة حقيقية استخدم معاملة ونسخة احتياطية وإجراءات مراجعة مناسبة. لا تجرب أوامر الحذف على بيانات حقيقية أثناء التعلم.

## 5. العلاقات
جدول courses يمكن أن يحتوي id وtitle، وجدول lessons يحتوي course_id كـFOREIGN KEY. هذا يمنع ربط درس بمسار غير موجود، ويساعد على تجنب تكرار معلومات المسار داخل كل درس.

## 6. محاكاة SELECT في Python
الكود التالي لا يشغّل SQL؛ بل يحاكي فكرة WHERE على بيانات تدريبية حتى تفهم منطق التصفية:
```python
students = [
    {"name": "Mona", "grade": 2},
    {"name": "Omar", "grade": 3},
    {"name": "Laila", "grade": 2}
]

selected_grade = 2
results = [
    student["name"]
    for student in students
    if student["grade"] == selected_grade
]
results.sort()

for name in results:
    print(name)
print("Results:", len(results))
```

الناتج:
```text
Laila
Mona
Results: 2
```

## 7. من SQL إلى API
لا ترسل المتصفح مباشرة إلى قاعدة البيانات بمفتاح إداري. الخادم يستقبل طلب API، يتحقق من المستخدم، ثم ينفذ استعلامًا محددًا بصلاحيات محدودة ويعيد النتيجة المناسبة.

## أخطاء شائعة
- نسيان WHERE في UPDATE أو DELETE.
- استخدام SELECT * عندما تحتاج عمودين فقط.
- مقارنة NULL باستخدام علامة =.
- تخزين قيم رقمية كنص دون سبب.
- بناء SQL بدمج نص المستخدم بدل الاستعلامات المعلّمة.

## تدريب موجّه
اكتب استعلامًا يعرض أسماء الطلاب في الصف الثاني مرتبة أبجديًا، ثم اشرح كيف سيتغير إذا أضفت شرط active = TRUE.

## تحدي مستقل
صمم جدولي courses وlessons، وحدد Primary Key وForeign Key، ثم اكتب استعلامًا يعرض كل درس مع عنوان المسار الذي ينتمي إليه.

## خلاصة
SQL تساعدك على قراءة البيانات وتنظيمها وتحديثها. افهم الجداول والمفاتيح، واستخدم شروطًا دقيقة، واجعل الخادم مسؤولًا عن الصلاحيات.
$lesson$, summary='تعلّم SELECT وWHERE وORDER BY والعلاقات بين الجداول، وافهم كيف يستخدم الخادم SQL بأمان.', duration_minutes=35, updated_at=now()
where id='backend-03-databases-sql';

update public.programming_lessons set content_md=$lesson$
# المصادقة والصلاحيات وحماية البيانات

## هدف الدرس
ستميّز بين إثبات الهوية وتحديد الصلاحيات، وتفهم كيف تمنع الوصول غير المسموح إلى بيانات الطلاب، ولماذا لا تكفي حماية الواجهة وحدها.

## 1. Authentication مقابل Authorization
- **Authentication:** من المستخدم؟ هل أثبت هويته بجلسة أو وسيلة موثوقة؟
- **Authorization:** ما العمليات والبيانات التي يسمح لهذا المستخدم بالوصول إليها؟

قد يكون الطالب مسجل الدخول بنجاح، لكنه لا يملك صلاحية مراجعة تسليمات زملائه أو تغيير اشتراكه.

## 2. مبدأ أقل صلاحية
امنح كل دور أقل مجموعة صلاحيات يحتاجها:
- الطالب: قراءة بياناته وتحديث تقدمه المسموح.
- المعلم: مراجعة الأعمال المخصصة له وفق سياسة المنصة.
- المدير: عمليات الإدارة التي يحتاجها فعلًا.

لا تجعل كل مستخدم مسجل الدخول مديرًا، ولا تعتمد على اسم دور يرسله المتصفح.

## 3. أين يجب فحص الصلاحية؟
يجب أن يتحقق الخادم أو قاعدة البيانات من:
1. هوية صاحب الطلب.
2. ملكية السجل أو نطاق الوصول.
3. الدور والصلاحية المطلوبة.
4. صحة البيانات قبل التعديل.
5. أن العملية لا تكشف بيانات مستخدم آخر.

إخفاء زر في HTML لا يمنع شخصًا من إرسال طلب مباشر إلى API. الحماية الحقيقية في قواعد الخادم وسياسات قاعدة البيانات.

## 4. مثال تعليمي لقواعد الصلاحيات
```python
permissions = {
    "student": {"read_own"},
    "teacher": {"read_own", "review_submissions"},
    "admin": {"read_own", "review_submissions", "manage_membership"}
}

def can_access(role, action):
    allowed_actions = permissions.get(role, set())
    return action in allowed_actions

print(can_access("student", "manage_membership"))
print(can_access("teacher", "review_submissions"))
```

الناتج:
```text
False
True
```

هذا المثال يشرح الفكرة فقط. في تطبيق حقيقي يجب أن تأتي هوية المستخدم ودوره من مصدر موثوق على الخادم، لا من قيمة يختارها المستخدم في محرر الصفحة.

## 5. حماية البيانات
- لا تخزن كلمات المرور كنص واضح؛ استخدم نظام مصادقة موثوقًا.
- لا تضع مفاتيح سرية في ملفات الواجهة أو مستودع عام.
- استخدم استعلامات معلّمة Parameterized Queries.
- اجمع أقل قدر لازم من بيانات الطالب.
- لا تعرض سجلات طالب لآخر.
- لا تكتب رموز الجلسات أو كلمات المرور في السجلات.
- استخدم HTTPS عند نقل البيانات.

## 6. Row Level Security
تسمح سياسات RLS بتحديد الصفوف التي يستطيع كل دور قراءتها أو تعديلها. يجب أن تربط السياسة المستخدم بالسجل الذي يملكه، وألا تكتفي بكونه authenticated.

## 7. أخطاء شائعة
- اعتبار تسجيل الدخول موافقة على كل العمليات.
- قراءة role من localStorage أو من طلب العميل دون تحقق.
- إتاحة كل صفوف الجدول لكل مستخدم مسجل.
- وضع service-role key في كود المتصفح.
- استخدام رسائل خطأ تكشف بيانات أو تفاصيل داخلية.

## تدريب موجّه
أنشئ جدولًا يوضح أدوار student وteacher وadmin، ثم اكتب ثلاث عمليات وحدد من يحق له تنفيذ كل واحدة مع السبب.

## تحدي مستقل
صمّم قاعدة وصول لجدول submissions: يستطيع الطالب قراءة تسليماته فقط، ويستطيع المعلم قراءة التسليمات التي كُلّف بمراجعتها، ويستطيع المدير إدارة السجلات وفق صلاحياته.

## خلاصة
الأمان يبدأ من تصميم البيانات والصلاحيات. أثبت الهوية أولًا، ثم افحص الإذن والملكية على الخادم، واحمِ الأسرار وخصوصية الطلاب.
$lesson$, summary='افهم Authentication وAuthorization وRLS ومبدأ أقل صلاحية وحماية بيانات الطلاب.', duration_minutes=35, updated_at=now()
where id='backend-04-auth-security';

update public.programming_lessons set content_md=$lesson$
# Git: حفظ تاريخ تغييرات المشروع

## هدف الدرس
ستنشئ مستودعًا محليًا، وتفهم دورة التعديل والتجهيز والحفظ، وتقرأ تاريخ المشروع دون فقد عملك.

## 1. ما المشكلة التي يحلها Git؟
عندما تعدّل ملفات كثيرة، يصبح من الصعب معرفة ما الذي تغير ومتى ولماذا. Git يسجل لقطات من التغييرات، ويتيح مقارنة النسخ والعمل على فروع منفصلة.

مصطلحات:
- Repository: مستودع يتتبع ملفات المشروع.
- Working Directory: الملفات التي تعمل عليها الآن.
- Staging Area: التغييرات التي اخترتها لتدخل في اللقطة التالية.
- Commit: لقطة محفوظة برسالة توضح الهدف.
- Branch: مسار تطوير مستقل.
- Remote: نسخة مستضافة مثل GitHub.

## 2. دورة العمل الأساسية
```bash
git status
git add README.md
git status
git commit -m "Add project introduction"
git log --oneline
```

اقرأ الأوامر:
1. status يعرض حالة الملفات.
2. add يجهز الملف المحدد.
3. status مرة أخرى للتأكد مما تم تجهيزه.
4. commit يحفظ اللقطة.
5. log يعرض سجل اللقطات.

## 3. لماذا نراجع Staging؟
قد يحتوي المجلد على ملفات مؤقتة أو بيانات لا تريد حفظها. جهّز الملفات المطلوبة فقط، وراجع الحالة قبل إنشاء commit. لا تستخدم أوامر حذف أو إعادة ضبط لا تفهم أثرها.

## 4. اكتب Commit صغيرًا وواضحًا
رسالة جيدة تصف التغيير: "Add lesson summary" أو "Fix mobile navigation". تجنب رسائل مثل "update" أو "final final" لأنها لا تشرح ما حدث.

## 5. افهم الفرق بين الملفات واللقطات
تعديل الملف لا يحفظ تلقائيًا في Git. تحتاج إلى add ثم commit. وإذا عدلت الملف بعد add، راجع status مرة أخرى لتعرف ما إذا كانت النسخة الجديدة تحتاج إلى تجهيز.

## 6. تطبيق عملي
أنشئ مجلدًا تدريبيًا يحتوي README.md وملفًا صغيرًا باسم notes.txt. ابدأ مستودعًا محليًا، ثم:
- افحص الحالة.
- جهّز README فقط.
- أنشئ commit أولًا.
- عدّل notes.txt.
- أنشئ commit ثانيًا.
- اعرض السجل وتأكد من وجود اللقطتين.

## أخطاء شائعة
- نسيان add قبل commit.
- تجهيز كل الملفات دون مراجعة.
- كتابة رسالة لا تشرح التغيير.
- الاعتقاد أن commit يرفع الملفات تلقائيًا إلى GitHub.
- وضع كلمات مرور أو ملفات شخصية داخل المستودع.

## تحدي مستقل
اكتب سجلًا من ثلاثة commits لمشروع صفحة شخصية: إنشاء الهيكل، إضافة المحتوى، ثم تحسين التنسيق. اكتب رسالة مناسبة لكل لقطة واشرح لماذا قسمت العمل.

## خلاصة
Git يمنحك تاريخًا واضحًا للمشروع. افحص status، جهّز التغييرات المقصودة، ثم احفظها برسالة مفهومة.
$lesson$, summary='افهم Repository وWorking Directory وStaging وCommit، ونفّذ دورة Git آمنة مع مراجعة الحالة.', duration_minutes=30, updated_at=now()
where id='workflow-01-git-basics';

update public.programming_lessons set content_md=$lesson$
# الفروع وGitHub وPull Requests

## هدف الدرس
ستستخدم فرعًا لتطوير ميزة منفصلة، وترفعه إلى GitHub، وتجهز Pull Request يشرح التغيير ويسهّل مراجعته.

## 1. لماذا نستخدم Branch؟
الفرع يسمح لك بتجربة تعديل دون العمل مباشرة على النسخة الرئيسية. يمكن أن يعمل أكثر من شخص على مهام مختلفة، ثم تُراجع التغييرات قبل دمجها.

## 2. دورة فرع بسيطة
```bash
git switch -c feature/profile-card
git status
```

أنشأ الأمر الأول فرعًا جديدًا وانتقل إليه. بعد تعديل الملفات، راجع الحالة ثم احفظ التغييرات باستخدام add وcommit.

## 3. ما دور GitHub؟
Git نظام لإدارة تاريخ الملفات، أما GitHub فهو منصة لاستضافة المستودعات والتعاون ومراجعة التغييرات وإدارة المشكلات وعمليات التحقق الآلية.

بعد إعداد Remote وصلاحياته، يمكن رفع الفرع:
```bash
git push -u origin feature/profile-card
```

لا تنفذ أمر push إلا على مستودع تملك صلاحية العمل عليه، وتأكد من الفرع والملفات قبل الرفع.

## 4. Pull Request
طلب الدمج ليس مجرد زر. هو وصف يجيب عن:
- ما المشكلة التي يحلها التغيير؟
- ما الذي تغير؟
- كيف اختبرت التغيير؟
- هل توجد صور أو ملاحظات تساعد المراجع؟
- هل توجد آثار جانبية أو نقاط تحتاج انتباهًا؟

راجع قائمة الملفات المتغيرة، ولا ترفع أسرارًا أو ملفات إعداد شخصية.

## 5. تعارض الدمج
يحدث التعارض عندما تتداخل تعديلات على الجزء نفسه من الملف. لا تحذف علامات التعارض بسرعة؛ اقرأ النسختين وافهم الهدف، واختر الحل الذي يحافظ على السلوك المطلوب، ثم شغّل الاختبارات.

## 6. مثال عملي
تعمل على صفحة بطاقة طالب:
1. أنشئ فرع feature/profile-card.
2. أضف بطاقة HTML وCSS.
3. شغّل فحص الصفحة على الهاتف والحاسوب.
4. احفظ commit برسالة واضحة.
5. ارفع الفرع.
6. اكتب Pull Request يوضح التغيير والاختبار.

## أخطاء شائعة
- العمل على main دون قصد.
- رفع ملفات غير مرتبطة بالمهمة.
- دمج PR دون قراءة التغييرات.
- حل التعارض بالاحتفاظ بنسخة عشوائية.
- اعتبار نجاح البناء دليلًا على صحة كل تفاصيل تجربة المستخدم.

## تدريب موجّه
اكتب وصف Pull Request لتغيير بطاقة الطالب، يتضمن المشكلة والحل والاختبارات والملفات المهمة.

## تحدي مستقل
تخيل أن مطورًا آخر عدّل نفس ملف CSS. اكتب خطوات آمنة لمراجعة التعارض، والتأكد من أن التنسيق القديم والجديد يعملان بعد الدمج.

## خلاصة
الفروع تعزل العمل، وPull Requests تجعل التغيير قابلًا للمراجعة. افحص الفرع والفرق والاختبارات قبل الدمج.
$lesson$, summary='أنشئ فرعًا، وافهم Remote وPush وPull Request، وتعلّم مراجعة التغييرات وحل التعارضات.', duration_minutes=30, updated_at=now()
where id='workflow-02-branches-github';

update public.programming_lessons set content_md=$lesson$
# جودة الكود والاختبارات والمراجعة

## هدف الدرس
ستكتب اختبارًا لدالة، وتختار حالات عادية وحدّية وغير صالحة، وتفهم كيف تساعد الاختبارات على منع رجوع الأخطاء بعد التعديل.

## 1. ما معنى جودة الكود؟
الكود الجيد لا يكتفي بإنتاج نتيجة صحيحة مرة واحدة. يجب أن يكون واضحًا، منظمًا، قابلًا للاختبار، ويحافظ على السلوك المتوقع عند التعديل.

## 2. مستويات الاختبار
- Unit Test: يختبر دالة أو جزءًا صغيرًا بمعزل.
- Integration Test: يختبر تفاعل أجزاء متعددة.
- End-to-End: يختبر رحلة مستخدم كاملة.
- Manual Test: يراجع سلوكًا أو تجربة لا يغطيها الاختبار الآلي بسهولة.

## 3. اكتب حالات اختبار متنوعة
لدالة حساب خصم، لا تختبر سعرًا عاديًا فقط:
- سعر 1000 وخصم 15%.
- خصم 0%.
- خصم 100%.
- سعر سالب.
- خصم أكبر من 100%.

الحالة الحدّية تكشف أخطاء لا تظهر في المثال المعتاد.

## 4. مثال Python باستخدام assert
```python
def final_price(price, discount):
    if price < 0 or not 0 <= discount <= 100:
        raise ValueError("Invalid input")
    return price * (1 - discount / 100)

assert final_price(1000, 15) == 850
assert final_price(100, 0) == 100
assert final_price(100, 100) == 0
print("All tests passed")
```

كل assert يتحقق من شرط. إذا فشل شرط يتوقف الاختبار ويظهر الخطأ بدل إعلان نجاح زائف.

## 5. دورة الاختبار والتصحيح
1. اكتب السلوك المتوقع قبل تعديل الكود.
2. شغّل الاختبار وشاهد النتيجة.
3. إذا فشل، حدد المدخل الذي كشف المشكلة.
4. أصلح السبب لا العرض فقط.
5. أعد الاختبار السابق واختبر حالات قريبة.
6. احتفظ بالاختبار حتى لا يعود الخطأ لاحقًا.

## 6. راجع التغيير
راجع أسماء المتغيرات، وتكرار الكود، وحدود المدخلات، ورسائل الخطأ، والأمان، وإمكانية الوصول. افحص الفرق بين النسخة السابقة والجديدة بدل قراءة الملف المعدل وحده.

## 7. أخطاء شائعة
- اختبار حالة واحدة فقط.
- كتابة اختبار يكرر نفس منطق الدالة فينتج الخطأ نفسه.
- حذف اختبار فاشل بدل فهم سببه.
- الاعتماد على الاختبار اليدوي وحده للمنطق المتكرر.
- تجاهل القيم الفارغة والصفر والسالب والحد الأعلى.

## تدريب موجّه
اكتب دالة تقبل سعرًا ونسبة خصم، ثم اختبر سعرًا طبيعيًا وصفرًا وخصم 100% ومدخلًا غير صالح.

## تحدي مستقل
اختر دالة من مشروع سابق، واكتب لها خمس حالات اختبار، ثم اشرح أي خطأ محتمل تكشفه كل حالة.

## خلاصة
الاختبار جزء من التصميم. اختبر الحالات العادية والحدّية وغير الصالحة، ثم أعد تشغيل الاختبارات بعد كل تعديل مهم.
$lesson$, summary='تعلّم Unit وIntegration وEnd-to-End Testing، واكتب اختبارات للحالات العادية والحدّية وغير الصالحة.', duration_minutes=35, updated_at=now()
where id='workflow-03-testing-quality';

update public.programming_lessons set content_md=$lesson$
# مشروع التخرج: خطط وابنِ واختبر وسلّم

## فكرة المشروع
ابنِ تطبيق قائمة مهام صغيرة يجمع ما تعلمته في HTML وCSS وJavaScript. يجب أن يستطيع المستخدم إضافة مهمة، وعرضها، وتغيير حالتها، وحذفها. ابدأ ببيانات محلية داخل المتصفح؛ لا تحتاج إلى حسابات أو بيانات شخصية.

## 1. حدد المشكلة والنطاق
اكتب وصفًا من سطرين للمشكلة، وحدد المستخدم والوظائف الأساسية. لا تبدأ بميزات كثيرة. النسخة الأولى تحتاج:
- إدخال عنوان مهمة.
- منع العنوان الفارغ.
- عرض قائمة المهام.
- تحديد المهمة كمكتملة.
- حذف المهمة.

## 2. صمم البيانات
يمكن تمثيل المهمة بكائن:
```javascript
const task = {
  id: 1,
  title: "Review lesson",
  completed: false
};
```

استخدم مصفوفة لتجميع المهام. اجعل لكل مهمة معرفًا ثابتًا حتى لا تعتمد على موضعها في القائمة.

## 3. خطط الواجهة
قسّم الصفحة إلى:
- عنوان يوضح وظيفة التطبيق.
- نموذج إدخال المهمة.
- رسالة تحقق عند وجود إدخال غير صالح.
- قائمة المهام.
- حالة فارغة عندما لا توجد مهام.

## 4. ابدأ بالتنفيذ تدريجيًا
```javascript
let tasks = [];

function addTask(title) {
  const cleanTitle = title.trim();
  if (!cleanTitle) return false;

  tasks.push({
    id: Date.now(),
    title: cleanTitle,
    completed: false
  });
  return true;
}

addTask("Build the first version");
console.log(tasks.length);
```

هذا مثال مصغر على إضافة مهمة إلى الحالة. في التطبيق الكامل ستضيف دوالًا منفصلة للعرض والتغيير والحذف.

## 5. اختبر الرحلة
- أضف مهمة صحيحة.
- حاول إضافة نص فارغ.
- أضف أكثر من مهمة.
- أكمل مهمة ثم ألغِ الإكمال.
- احذف مهمة.
- جرّب القائمة الفارغة.
- اختبر العرض على شاشة هاتف.

## 6. استخدم Git أثناء العمل
احفظ مراحل واضحة: هيكل أولي، إضافة الوظائف، ثم تحسين التصميم والاختبارات. لا تنتظر حتى نهاية المشروع لإنشاء أول commit.

## 7. جهّز التسليم
اكتب README يحتوي على:
- فكرة المشروع والميزات.
- طريقة تشغيله.
- التقنيات المستخدمة.
- الاختبارات التي أجريتها.
- صور أو رابط عرض إن توفر.
- ما تعلمته وما الذي ستطوره لاحقًا.

## معايير التقييم
- صحة الوظائف الأساسية: 30%.
- تنظيم الكود وتقسيمه: 20%.
- تجربة المستخدم والتصميم المتجاوب: 15%.
- الاختبارات ومعالجة الحالات الحدّية: 20%.
- README ووضوح التسليم: 15%.

## تحدي إضافي
أضف فلترًا لعرض كل المهام أو المكتملة أو غير المكتملة، ثم اكتب اختبارات للحالات الثلاث.

## خلاصة
المشروع الجيد يمر بالتخطيط والتصميم والتنفيذ والاختبار والتوثيق. سلّم عملًا يمكن لشخص آخر تشغيله وفهمه ومراجعته.
$lesson$, summary='مشروع متكامل لقائمة مهام: تخطيط البيانات والواجهة والتنفيذ والاختبار والتوثيق وGit.', duration_minutes=50, updated_at=now();

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
