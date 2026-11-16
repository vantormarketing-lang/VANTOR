-- Deepen Python and C++ with debugging, testing, packaging, STL and projects.
-- Additive inserts preserve existing lesson history and student progress.

insert into public.programming_lessons
(id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites)
values
('python-15-debugging-workflow','python-intermediate','تصحيح أخطاء Python بطريقة منهجية','تعلم قراءة Traceback وتحديد السطر والسبب وإصلاح المشكلة ثم إعادة الاختبار.',$md$# تصحيح أخطاء Python بطريقة منهجية

## هدف الدرس
بدل تغيير الكود عشوائيًا، ستتعلم طريقة ثابتة لفهم الخطأ وإصلاحه.

## 1. اقرأ Traceback من الأسفل
غالبًا يعرض Traceback نوع الخطأ ورسالة توضح السبب، ثم مسار الاستدعاءات. ابدأ بآخر سطر لمعرفة نوع الخطأ، ثم ارجع إلى آخر سطر من كودك يظهر في التتبع.

## 2. مثال SyntaxError
```python
print("Hello"
```
القوس غير مغلق. أصلحه ثم شغّل البرنامج مرة أخرى.

## 3. مثال NameError
```python
student_name = "Mona"
print(studentname)
```
الاسم المستخدم مختلف عن الاسم الذي عرّفته. راجع الإملاء وحالة الأحرف.

## 4. مثال TypeError
```python
age = "14"
next_year = int(age) + 1
print(next_year)
```
حوّل النص إلى عدد قبل إجراء العملية الحسابية.

## 5. استراتيجية التصحيح
1. أعد إنتاج الخطأ بنفس الخطوات.
2. اقرأ نوع الخطأ والرسالة ورقم السطر.
3. افحص القيم والأنواع قبل السطر المتسبب.
4. غيّر سببًا واحدًا في كل مرة.
5. أعد تشغيل المثال والحالات المرتبطة به.
6. اكتب ملاحظة قصيرة عن السبب والحل.

## 6. أدوات مفيدة
استخدم `print()` مؤقتًا لمراقبة القيم، أو المصحح Debugger لتتبع التنفيذ خطوة بخطوة. احذف رسائل التشخيص المؤقتة بعد الانتهاء.

## تطبيق
في مثال NameError السابق، أصلح الاسم. ثم غيّر قيمة age إلى نص غير رقمي، ولاحظ الخطأ الجديد، وتعامل معه باستخدام try/except.

## خلاصة
رسالة الخطأ دليل. حدد موضع المشكلة وسببها، ثم أصلح واختبر بدل التخمين.$md$,22,7,true,ARRAY['قراءة Traceback','تمييز أخطاء الصياغة والأسماء والأنواع','اتباع خطوات تصحيح قابلة للتكرار']::text[],ARRAY['python-08-functions']::text[]),

('python-16-testing-functions','اختبار برامج Python والتحقق من النتائج','اكتب اختبارات للحالات العادية والحدية وتأكد أن تعديلك لم يكسر سلوكًا سابقًا.',$md$# اختبار برامج Python والتحقق من النتائج

## لماذا نختبر؟
قد يعمل البرنامج مع مثال واحد ويفشل مع مدخل آخر. الاختبارات تحول توقعاتك إلى فحوص يمكن تكرارها.

## 1. اختبر دالة صغيرة
```python
def is_pass(score):
    return score >= 50

assert is_pass(80) is True
assert is_pass(20) is False
assert is_pass(50) is True
```
إذا لم يتحقق شرط assert، يتوقف الاختبار ويظهر موضع الفشل.

## 2. اختبر الحالات المختلفة
- قيمة عادية مثل 75.
- الحد الفاصل مثل 50.
- قيمة أقل من الحد.
- قيمة غير متوقعة مثل نص بدل رقم.

## 3. اختبر المدخلات غير الصحيحة
حدد هل يجب رفض القيمة برسالة واضحة أو تحويلها وفق قواعد البرنامج. لا تجعل البرنامج يقبل كل شيء دون تحقق.

## 4. افصل المنطق عن الإدخال والإخراج
اجعل دالة الحساب تستقبل قيمًا وتعيد نتيجة. اجعل قراءة input والطباعة في جزء منفصل؛ هكذا يسهل اختبار الدالة.

## 5. اختبار يدوي وقائمة مراجعة
اكتب المدخل والنتيجة المتوقعة والنتيجة الفعلية. عند فشل اختبار، أصلح السبب ثم أعد تشغيل الاختبارات كلها.

## تطبيق
اكتب دالة تحسب متوسط قائمة درجات. اختبر قائمة عادية، وقائمة عنصر واحد، وقائمة فارغة، وحدد السلوك المناسب للقائمة الفارغة.

## خلاصة
الاختبار ليس لإثبات أن البرنامج يعمل مرة واحدة؛ بل للتحقق من الحالات التي تتوقعها ومنع رجوع الأخطاء.$md$,20,8,true,ARRAY['كتابة assert','اختبار الحالات الحدية','فصل منطق البرنامج لتسهيل اختباره']::text[],ARRAY['python-15-debugging-workflow']::text[]),

('python-17-venv-packages','بيئات Python الافتراضية والحزم','افهم pip وvenv وكيف تعزل اعتماديات كل مشروع وتوثق طريقة تشغيله.',$md$# بيئات Python الافتراضية والحزم

## ما الحزمة؟
Package كود جاهز يعيد استخدامه مشروعك. Python يحتوي مكتبات قياسية، ويمكن تثبيت حزم إضافية عند الحاجة.

## 1. ما pip؟
أداة لإدارة حزم Python. قبل تثبيت أي حزمة، تحقق من اسمها ومصدرها واحتياج مشروعك إليها.

## 2. البيئة الافتراضية
تسمح لكل مشروع بامتلاك اعتمادياته دون خلطها بمشاريع أخرى.

## 3. إنشاء بيئة
على أنظمة كثيرة:
```bash
python -m venv .venv
```
التفعيل يختلف حسب النظام:
```bash
# Linux / macOS
source .venv/bin/activate

# Windows PowerShell
.venv\\Scripts\\Activate.ps1
```

## 4. تثبيت حزمة
بعد تفعيل البيئة:
```bash
python -m pip install requests
```
استخدم `python -m pip` لتتأكد أن pip تابع لنفس مفسر Python الذي تشغّل به المشروع.

## 5. توثيق الاعتماديات
```bash
python -m pip freeze > requirements.txt
```
وعلى جهاز آخر يمكن تثبيتها من الملف:
```bash
python -m pip install -r requirements.txt
```

## 6. عادات مهمة
لا ترفع مجلد .venv إلى Git. أضفه إلى .gitignore. لا تثبت حزمة مجهولة لمجرد أن رسالة عشوائية طلبت ذلك.

## تطبيق
أنشئ بيئة افتراضية لمشروع تجريبي، وثبّت حزمة موثوقة تحتاجها، ثم أنشئ requirements.txt.

## خلاصة
البيئة الافتراضية تعزل المشروع، وpip يدير الحزم، وrequirements.txt يوثق ما يحتاجه التشغيل.$md$,22,9,true,ARRAY['شرح pip وvenv','إنشاء بيئة افتراضية','توثيق الاعتماديات']::text[],ARRAY['python-13-modules']::text[]),

('python-18-cli-project','مشروع Python عملي: مدير مهام نصي','ابنِ برنامجًا صغيرًا يعمل من الطرفية ويستخدم الدوال والقوائم والملفات والتحقق من المدخلات.',$md$# مشروع Python عملي: مدير مهام نصي

## هدف المشروع
ستبني مدير مهام بسيطًا في الطرفية. استخدم بيانات تدريبية فقط.

## المتطلبات
1. عرض قائمة المهام.
2. إضافة مهمة جديدة.
3. وضع علامة إكمال على مهمة.
4. حفظ المهام في ملف JSON.
5. التعامل مع الملف غير الموجود أو الفارغ.
6. رفض إدخال فارغ أو رقم مهمة غير صالح.

## تصميم الحل
قسّم البرنامج إلى دوال:
- `load_tasks()` لقراءة البيانات.
- `save_tasks(tasks)` لحفظها.
- `show_tasks(tasks)` لعرض القائمة.
- `add_task(tasks)` لإضافة مهمة.
- `complete_task(tasks)` لتحديث الحالة.
- `main()` لتشغيل القائمة.

## مثال JSON
```json
[
  {"title": "Practice Python", "done": false},
  {"title": "Review loops", "done": true}
]
```

## خطوات البناء
ابدأ بعرض قائمة ثابتة. ثم أضف الإضافة، وبعدها الإكمال، ثم الحفظ والقراءة. اختبر كل خطوة قبل الانتقال.

## معالجة الأخطاء
استخدم try/except عند قراءة JSON أو تحويل إدخال المستخدم إلى رقم. لا تستخدم except عامًّا لإخفاء كل الأخطاء؛ تعامل مع أنواع الاستثناءات المتوقعة.

## معايير النجاح
- تعمل الخيارات الأساسية.
- لا ينهار البرنامج عند ملف غير موجود.
- المدخلات غير الصحيحة تعطي رسالة مفهومة.
- الكود مقسم إلى دوال وأسماؤه واضحة.
- يوجد README يشرح التشغيل.

## تحدي إضافي
أضف تاريخ إنشاء المهمة أو خيار حذف مهمة بعد تأكيد واضح.

## خلاصة
المشروع يجمع الدوال والقوائم والملفات والاستثناءات والتصحيح في تطبيق واحد.$md$,30,10,true,ARRAY['تقسيم التطبيق إلى دوال','قراءة وكتابة JSON','التحقق من المدخلات ومعالجة الأخطاء']::text[],ARRAY['python-16-testing-functions','python-17-venv-packages']::text[]),

('cpp-07-strings-vectors','النصوص وVector ومكتبة STL في C++','استخدم string وvector وخوارزميات STL للتعامل الآمن والمنظم مع مجموعات البيانات.',$md$# النصوص وVector ومكتبة STL في C++

## ما STL؟
المكتبة القياسية في C++ توفر حاويات وخوارزميات جاهزة بدل بناء كل شيء من الصفر.

## 1. النصوص
```cpp
#include <iostream>
#include <string>
using namespace std;

int main() {
    string name = "Mona";
    cout << name.size() << endl;
}
```
استخدم string بدل مصفوفة أحرف يدوية في أغلب تطبيقات المبتدئين.

## 2. Vector
vector حاوية يتغير حجمها:
```cpp
#include <vector>
vector<int> scores = {80, 90, 100};
scores.push_back(95);
cout << scores.size();
```

## 3. المرور على العناصر
```cpp
for (int score : scores) {
    cout << score << endl;
}
```

## 4. خوارزميات جاهزة
```cpp
#include <algorithm>
sort(scores.begin(), scores.end());
```
تأكد من تضمين المكتبة المناسبة وفهم ترتيب العناصر قبل استخدام الخوارزمية.

## 5. حدود الوصول
استخدم فهرسًا ضمن المجال من صفر إلى size ناقص واحد. عند التعلم يمكنك استخدام `at()` لأنها تتحقق من الفهرس وترمي استثناء عند خروجه عن الحدود.

## تطبيق
أنشئ vector لخمسة أرقام، أضف رقمًا، رتب القيم، ثم اطبعها واحسب مجموعها.

## خلاصة
string وvector وخوارزميات STL أدوات أساسية لبناء برامج C++ أوضح وأكثر مرونة.$md$,22,7,true,ARRAY['استخدام string وvector','المرور على عناصر vector','استخدام sort وفهم حدود الفهرسة']::text[],ARRAY['cpp-04-functions-arrays']::text[]),

('cpp-08-memory-safety','فهم الذاكرة والمؤشرات وإدارة الموارد بأمان','عمّق فهمك للمراجع والمؤشرات والنطاق وتجنب الوصول غير الصحيح للذاكرة.',$md$# فهم الذاكرة والمؤشرات وإدارة الموارد بأمان

## 1. المتغير والعنوان
كل متغير له قيمة ومكان في الذاكرة أثناء تشغيل البرنامج. العامل `&` يمكنه الحصول على عنوان متغير، و`*` يستخدم مع المؤشر للوصول إلى القيمة التي يشير إليها.

## 2. مثال تعليمي
```cpp
int score = 90;
int* scorePtr = &score;
cout << *scorePtr << endl;
```
المؤشر scorePtr يحمل عنوان score، وفك الإشارة يعرض القيمة الموجودة هناك.

## 3. nullptr
قد لا يشير المؤشر إلى كائن صالح. استخدم nullptr لتمثيل عدم وجود هدف، وتحقق من المؤشر قبل فك الإشارة.

## 4. المراجع
المرجع اسم بديل لكائن موجود:
```cpp
int original = 10;
int& alias = original;
alias = 20;
cout << original;
```

## 5. تجنب الأخطاء
- لا تستخدم مؤشرًا غير مهيأ.
- لا تفك إشارة nullptr.
- لا تستخدم عنوان كائن انتهى عمره.
- لا تصل إلى عنصر خارج حدود الحاوية.
- لا تحرر المورد مرتين.

## 6. إدارة الموارد الحديثة
فضّل الحاويات مثل vector وstring والمؤشرات الذكية مثل unique_ptr عند الحاجة بدل إدارة الذاكرة يدويًا. مبدأ RAII يربط عمر المورد بعمر الكائن.

## تطبيق
اكتب دالة تستقبل vector<int> بالمرجع الثابت const reference وتعيد مجموع العناصر. اشرح لماذا لا نحتاج نسخ القائمة.

## خلاصة
المؤشرات قوية لكنها تتطلب الانتباه للعمر والصلاحية. فضّل أدوات C++ الحديثة التي تدير الموارد تلقائيًا.$md$,24,8,true,ARRAY['شرح المؤشر والمرجع','فهم nullptr وعمر الكائن','ذكر ممارسات إدارة الموارد الحديثة']::text[],ARRAY['cpp-05-references-pointers','cpp-07-strings-vectors']::text[]),

('cpp-09-classes-design','تصميم الأصناف وواجهات الاستخدام في C++','نظّم البيانات والسلوك داخل class واستخدم public وprivate والباني ودوال الأعضاء.',$md$# تصميم الأصناف وواجهات الاستخدام في C++

## 1. التغليف Encapsulation
اجعل البيانات الداخلية private، ووفّر دوالًا عامة تتحقق من القيم قبل تعديلها. هذا يمنع تغيير الحالة بطريقة غير صحيحة.

## 2. مثال Class
```cpp
#include <iostream>
#include <string>
using namespace std;

class Student {
private:
    string name;
    int score;

public:
    Student(string studentName, int studentScore)
        : name(studentName), score(studentScore) {}

    bool passed() const {
        return score >= 50;
    }

    void print() const {
        cout << name << ": " << score << endl;
    }
};
```

## 3. إنشاء كائن
```cpp
Student learner("Mona", 85);
learner.print();
```

## 4. const correctness
استخدم const مع الدوال التي لا تغير حالة الكائن. هذا يوضح نية الدالة ويساعد المترجم في اكتشاف الاستخدام غير المناسب.

## 5. Composition
يمكن أن يحتوي كائن على كائن آخر. غالبًا يكون تركيب كائنات صغيرة أوضح من بناء وراثة عميقة.

## تطبيق
أنشئ class باسم Book يحتوي عنوانًا وسنة نشر خاصة، وبانيًا ودالة تعرض بيانات الكتاب.

## خلاصة
الصنف الجيد يخفي تفاصيله الداخلية ويقدم واجهة واضحة وصغيرة.$md$,22,9,true,ARRAY['استخدام public وprivate','كتابة constructor','شرح التغليف وconst methods']::text[],ARRAY['cpp-06-classes-objects']::text[]),

('cpp-10-debugging-project','تصحيح أخطاء C++ ومشروع Grade Analyzer','اقرأ أخطاء المترجم واختبر الحدود وابنِ برنامجًا يحلل مجموعة درجات.',$md$# تصحيح أخطاء C++ ومشروع Grade Analyzer

## 1. أخطاء الترجمة
المترجم قد يعرض رسالة طويلة بسبب خطأ واحد مبكر. اقرأ أول خطأ مفيد في ملفك، ثم أصلح السبب وأعد الترجمة.

## 2. أمثلة شائعة
- نسيان الفاصلة المنقوطة.
- نسيان تضمين مكتبة.
- عدم تطابق نوع القيمة مع نوع المتغير.
- اختلاف اسم المتغير بين التعريف والاستخدام.
- أقواس معقوفة غير متوازنة.

## 3. أخطاء وقت التشغيل والمنطق
قد يترجم البرنامج لكنه يعطي نتيجة خاطئة. اختبر قائمة فارغة، وقيمة واحدة، والحدود مثل 0 و100، وأي مدخل خارج المجال.

## 4. مشروع Grade Analyzer
اكتب برنامجًا يستقبل مجموعة درجات تدريبية، ثم:
1. يحسب العدد والمتوسط.
2. يعرض أعلى وأقل درجة.
3. يصنف كل درجة إلى ناجح أو يحتاج مراجعة.
4. يرفض الدرجة خارج المجال من 0 إلى 100.
5. يعرض رسالة مناسبة إذا لم توجد درجات.

## 5. تصميم الحل
استخدم vector<int> لتخزين الدرجات، ودوال منفصلة للتحقق والحساب والطباعة. استخدم خوارزميات STL المناسبة بعد فهمها.

## 6. الاختبار
جرّب: لا توجد درجات، درجة واحدة، عدة درجات، 0، 100، ودرجة خارج المجال. اكتب النتيجة المتوقعة قبل التشغيل.

## معايير التقييم
صحة الحسابات، التحقق من المدخلات، وضوح تقسيم الدوال، عدم تجاوز حدود الحاوية، ورسائل مفهومة للمستخدم.

## خلاصة
مشروعك يثبت قدرتك على الجمع بين C++ وSTL والتصميم والاختبار وتصحيح الأخطاء.$md$,30,10,true,ARRAY['قراءة أخطاء الترجمة','اختبار الحالات الحدية','تنفيذ مشروع يستخدم vector والدوال']::text[],ARRAY['cpp-07-strings-vectors','cpp-09-classes-design']::text[])
on conflict (id) do nothing;

insert into public.programming_exercises
(lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
select l.id,'تطبيق عملي: ' || l.title,
'نفّذ المطلوب في درس "' || l.title || '". اكتب الحل بنفسك، ثم اختبر حالة عادية وحالة حدية، وسجّل ما تعلمته.',
case when l.id like 'python-%' then '# اكتب كود Python هنا' else '// اكتب كود C++ هنا' end,
case when l.id like 'python-%' then 'python' else 'cpp' end,
true,'[]'::jsonb,
jsonb_build_array('اقرأ المطلوب وحدد المدخلات والمخرجات.','قسّم الحل إلى خطوات أو دوال صغيرة.','اختبر حالة عادية وحالة حدية.'),
case
when l.id='python-15-debugging-workflow' then 'student_name = "Mona"\nprint(student_name)'
when l.id='python-16-testing-functions' then 'def average(values):\n    if not values:\n        return 0\n    return sum(values) / len(values)\n\nassert average([80, 100]) == 90'
when l.id='python-17-venv-packages' then 'python -m venv .venv\npython -m pip freeze > requirements.txt'
when l.id='python-18-cli-project' then 'import json\nfrom pathlib import Path\n\ndef load_tasks():\n    path = Path("tasks.json")\n    if not path.exists():\n        return []\n    return json.loads(path.read_text(encoding="utf-8"))\n'
when l.id='cpp-07-strings-vectors' then '#include <iostream>\n#include <vector>\n#include <algorithm>\nusing namespace std;\nint main() { vector<int> values = {5, 2, 8}; sort(values.begin(), values.end()); for (int v : values) cout << v << " "; }'
when l.id='cpp-08-memory-safety' then '#include <vector>\nusing namespace std;\nint total(const vector<int>& values) { int sum = 0; for (int value : values) sum += value; return sum; }'
when l.id='cpp-09-classes-design' then '#include <string>\nusing namespace std;\nclass Book { private: string title; public: Book(string value) : title(value) {} string getTitle() const { return title; } };'
else '#include <iostream>\n#include <vector>\nusing namespace std;\nint main() { vector<int> scores = {70, 80, 90}; }'
end,
'[{"criterion":"صحة الحل","weight":40},{"criterion":"وضوح وتنظيم الكود","weight":30},{"criterion":"الاختبار وشرح النتيجة","weight":30}]'::jsonb,
'manual'
from public.programming_lessons l
where l.id in ('python-15-debugging-workflow','python-16-testing-functions','python-17-venv-packages','python-18-cli-project','cpp-07-strings-vectors','cpp-08-memory-safety','cpp-09-classes-design','cpp-10-debugging-project')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
select l.id,'اختبار: ' || l.title,70,true
from public.programming_lessons l
where l.id in ('python-15-debugging-workflow','python-16-testing-functions','python-17-venv-packages','python-18-cli-project','cpp-07-strings-vectors','cpp-08-memory-safety','cpp-09-classes-design','cpp-10-debugging-project')
on conflict (lesson_id) do nothing;

insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select q.id,x.prompt,x.options::jsonb,x.correct_index,x.explanation,x.sort_order
from public.programming_quizzes q
join (values
('python-15-debugging-workflow','من أين تبدأ غالبًا قراءة Traceback؟','["من آخر سطر لمعرفة نوع الخطأ","من أول حرف في الملف","من اسم المجلد فقط"]',0,'آخر سطر غالبًا يوضح نوع الاستثناء ورسالة الخطأ.',1),
('python-15-debugging-workflow','ما أفضل طريقة لتصحيح الخطأ؟','["تحديد السبب وتغيير شيء واحد ثم إعادة الاختبار","حذف أجزاء عشوائية","تجاهل رسالة الخطأ"]',0,'التصحيح المنهجي يجعل السبب واضحًا.',2),
('python-15-debugging-workflow','متى تحذف print التشخيصية؟','["بعد انتهاء التصحيح إذا لم تعد مطلوبة","قبل تشغيل البرنامج","لا تحذفها أبدًا"]',0,'رسائل التشخيص المؤقتة تنظف بعد انتهاء المهمة.',3),
('python-16-testing-functions','لماذا نختبر القيمة الحدية؟','["للتأكد من سلوك البرنامج عند حدود القواعد","لتغيير اسم الملف","لزيادة سرعة الإنترنت"]',0,'الحدود تكشف أخطاء المقارنة والافتراضات.',1),
('python-16-testing-functions','ما وظيفة assert؟','["التحقق من شرط متوقع","تعريف مجلد","تثبيت حزمة"]',0,'assert يفشل عندما لا يتحقق الشرط.',2),
('python-16-testing-functions','لماذا نفصل الحساب عن input والطباعة؟','["لتسهيل إعادة استخدام واختبار الدالة","لمنع تشغيل البرنامج","لإخفاء النتائج"]',0,'الدوال المعزولة أسهل للاختبار.',3),
('python-17-venv-packages','ما فائدة venv؟','["عزل اعتماديات المشروع","حذف ملفات المشروع","تصميم صفحة ويب"]',0,'البيئة الافتراضية تفصل الحزم بين المشاريع.',1),
('python-17-venv-packages','كيف تثبت حزمة باستخدام Python الحالي؟','["python -m pip install package","git install package","html add package"]',0,'python -m pip يربط pip بالمفسر المختار.',2),
('python-17-venv-packages','ما فائدة requirements.txt؟','["توثيق الحزم المطلوبة","تخزين كلمات المرور","تشغيل المتصفح"]',0,'يساعد في إعادة تثبيت الاعتماديات.',3),
('python-18-cli-project','لماذا نقسم المشروع إلى دوال؟','["لتحديد مسؤولية كل جزء وتسهيل الاختبار","لزيادة تكرار الكود","لمنع حفظ الملفات"]',0,'كل دالة تؤدي مهمة واضحة.',1),
('python-18-cli-project','كيف نتعامل مع ملف JSON غير موجود؟','["نحدد سلوكًا افتراضيًا واضحًا مثل قائمة فارغة","نفترض أنه موجود دائمًا","نوقف الجهاز"]',0,'يجب التعامل مع غياب الملف المتوقع.',2),
('python-18-cli-project','ما فائدة try/except هنا؟','["التعامل مع أخطاء متوقعة مثل JSON غير صالح","إخفاء جميع الأخطاء بلا تمييز","تغيير لون الطرفية"]',0,'نعالج الاستثناءات التي نعرف كيف نتعامل معها.',3),
('cpp-07-strings-vectors','ما ميزة vector؟','["حاوية يتغير حجمها","نوع لون","أمر طرفية"]',0,'vector ينمو ويتقلص حسب الحاجة.',1),
('cpp-07-strings-vectors','ما فائدة sort؟','["ترتيب العناصر ضمن المجال المحدد","حذف المستودع","قراءة ملف JSON"]',0,'sort خوارزمية من المكتبة القياسية.',2),
('cpp-07-strings-vectors','ما النطاق الصحيح لفهرسة vector؟','["من صفر إلى size ناقص واحد","من واحد إلى size","أي رقم"]',0,'الفهرسة تبدأ من صفر.',3),
('cpp-08-memory-safety','ماذا يعني nullptr؟','["مؤشر لا يشير إلى كائن","قيمة نصية","حلقة لا نهائية"]',0,'nullptr يمثل مؤشرًا فارغًا.',1),
('cpp-08-memory-safety','ما فائدة const reference؟','["تمرير الكائن دون نسخه ومنع تعديله عبر المرجع","حذف الكائن","تحويله إلى نص"]',0,'المرجع الثابت يتجنب النسخ ويمنع التعديل من خلاله.',2),
('cpp-08-memory-safety','ما المقصود بـRAII؟','["ربط عمر المورد بعمر الكائن","تشغيل الكود من المتصفح","تنسيق النصوص"]',0,'RAII يجعل إدارة المورد مرتبطة بعمر الكائن.',3),
('cpp-09-classes-design','ما فائدة private؟','["إخفاء تفاصيل البيانات الداخلية","إظهار كل شيء للعامة","تعريف حلقة"]',0,'private يحد الوصول المباشر إلى أعضاء الصنف.',1),
('cpp-09-classes-design','ما وظيفة constructor؟','["تهيئة الكائن عند إنشائه","حذف المشروع","ترتيب الملفات"]',0,'الباني يهيئ حالة الكائن.',2),
('cpp-09-classes-design','متى نستخدم const في دالة عضو؟','["عندما لا تعدل حالة الكائن","عندما تحذف الكائن","عندما تغير كل الخصائص"]',0,'const يوضح أن الدالة لا تغير حالة الكائن.',3),
('cpp-10-debugging-project','ما أول خطوة عند ظهور أخطاء ترجمة كثيرة؟','["قراءة أول خطأ مفيد وإصلاح السبب المبكر","تغيير كل الأسطر","تجاهل المترجم"]',0,'خطأ مبكر قد يسبب رسائل لاحقة كثيرة.',1),
('cpp-10-debugging-project','ما الحالات التي يجب اختبارها في Grade Analyzer؟','["قائمة فارغة وحدود الدرجات ومدخل خارج المجال","حالة واحدة فقط","لون الشاشة"]',0,'الحالات الحدية والمدخلات غير الصحيحة أساسية.',2),
('cpp-10-debugging-project','لماذا نستخدم vector في المشروع؟','["لتخزين عدد متغير من الدرجات","لتغيير الخط","لتشغيل HTTP"]',0,'vector مناسب لمجموعة درجات يتغير حجمها.',3)
) as x(lesson_id,prompt,options,correct_index,explanation,sort_order)
on x.lesson_id=q.lesson_id
where not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=q.id and old.prompt=x.prompt);
