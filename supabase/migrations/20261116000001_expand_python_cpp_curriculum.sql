-- Extend Python beyond the introductory module and add a dedicated C++ track.
insert into public.programming_tracks (id,title,subtitle,description,sort_order,published)
values ('cpp','C++ Programming','من الأساسيات إلى البرمجة الكائنية','تعلم C++ خطوة بخطوة مع أمثلة عملية وتمارين واختبارات ومشاريع.',11,true)
on conflict (id) do nothing;

insert into public.programming_modules (id,track_id,title,description,sort_order,published,level,prerequisites)
values
('python-intermediate','python','Python: المستوى المتوسط والمتقدم','توسّع في هياكل البيانات والنصوص والملفات والاستثناءات والوحدات والبرمجة الكائنية.',2,true,'intermediate',ARRAY['python-foundations']::text[]),
('cpp-foundations','cpp','أساسيات C++ من الصفر','ابدأ كتابة C++ وتعلّم الأنواع والشروط والحلقات والدوال والمصفوفات والمراجع والأصناف.',1,true,'beginner',ARRAY['cs-start-here']::text[])
on conflict (id) do nothing;

insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites)
values
('python-09-collections','python-intermediate','القوائم والقواميس والمجموعات','تعامل مع مجموعات البيانات واختر البنية المناسبة لكل مشكلة.','# القوائم والقواميس والمجموعات

## هدف الدرس
تخزن أكثر من قيمة، وتضيف وتحذف وتبحث، وتختار بنية البيانات المناسبة.

## 1. List
القائمة تحفظ عناصر بترتيب ويمكن تعديلها:
```python
names = ["Mona", "Omar", "Ali"]
names.append("Sara")
print(names[0])
```
الفهرسة تبدأ من صفر.

## 2. Dictionary
القاموس يربط مفتاحًا بقيمة:
```python
student = {"name": "Mona", "score": 92}
print(student["name"])
student["score"] = 95
```
استخدمه عندما تكون البيانات لها أسماء أو خصائص.

## 3. Set
المجموعة تحتفظ بعناصر فريدة:
```python
unique_scores = {80, 90, 80}
print(unique_scores)
```
القيمة 80 لا تتكرر داخل المجموعة.

## 4. الاختيار
- List: عناصر مرتبة وقد تتكرر.
- Dictionary: مفاتيح وقيم.
- Set: عناصر فريدة دون الاعتماد على ترتيبها.

## 5. المرور على البيانات
استخدم for لقراءة العناصر. ومع القاموس يمكنك استخدام `items()` للحصول على المفتاح والقيمة.

## تدريب
أنشئ قائمة درجات، وقاموسًا لطالب، ومجموعة تحتوي الدرجات الفريدة.

## خلاصة
اختيار بنية البيانات المناسبة يجعل الكود أوضح وأسهل في التطوير.',20,1,true,ARRAY['القوائم والقواميس والمجموعات']::text[],ARRAY[]::text[]),
('python-10-strings','python-intermediate','معالجة النصوص Strings','ابحث داخل النصوص ونسّقها واقسمها ونظّف المدخلات.','# معالجة النصوص Strings

## هدف الدرس
تتعامل مع النصوص كبيانات، وتستخدم الدوال الشائعة لتنظيفها وتحليلها.

## 1. النص سلسلة أحرف
```python
message = "  Hello DOMA  "
print(len(message))
```
الدالة len تحسب عدد الأحرف، بما فيها المسافات.

## 2. التنظيف
```python
clean = message.strip()
print(clean.lower())
```
strip تزيل المسافات من الطرفين، وlower تحول الحروف الإنجليزية إلى صغيرة.

## 3. البحث والاستبدال
```python
text = "I learn Python"
print(text.find("Python"))
print(text.replace("Python", "coding"))
```
find تعيد موضع النص أو -1 إذا لم تجده.

## 4. التقسيم والدمج
```python
words = "red,green,blue".split(",")
joined = " | ".join(words)
print(joined)
```

## 5. f-strings
```python
name = "Mona"
score = 95
print(f"{name} scored {score}")
```
تسمح f-string بإدخال قيم المتغيرات داخل النص.

## تدريب
نظّف اسمًا به مسافات زائدة، واجعل الحروف صغيرة، ثم اطبع رسالة باستخدام f-string.

## خلاصة
النصوص بيانات يمكن تنظيفها والبحث فيها وتقسيمها ودمجها.',18,2,true,ARRAY['معالجة النصوص Strings']::text[],ARRAY[]::text[]),
('python-11-files','python-intermediate','قراءة الملفات وكتابتها','احفظ البيانات النصية في ملفات وافتحها بطريقة آمنة باستخدام with.','# قراءة الملفات وكتابتها

## هدف الدرس
تقرأ ملفًا نصيًا وتكتب فيه وتفهم أوضاع الفتح وإدارة الملف.

## 1. لماذا الملفات؟
المتغيرات تعيش أثناء تشغيل البرنامج غالبًا. الملفات تسمح بحفظ البيانات لاستخدامها لاحقًا.

## 2. الكتابة
```python
with open("notes.txt", "w", encoding="utf-8") as file:
    file.write("My first note")
```
الوضع w ينشئ الملف أو يستبدل محتواه السابق.

## 3. الإضافة
الوضع a يضيف إلى نهاية الملف بدل استبدال المحتوى:
```python
with open("notes.txt", "a", encoding="utf-8") as file:
    file.write("\\nAnother note")
```

## 4. القراءة
```python
with open("notes.txt", "r", encoding="utf-8") as file:
    content = file.read()
print(content)
```

## 5. لماذا with؟
تغلق الملف تلقائيًا عند انتهاء الكتلة، حتى إذا حدث استثناء. استخدم encoding="utf-8" للنصوص متعددة اللغات.

## 6. تعامل مع الملفات بحذر
تأكد من المسار، ولا تستخدم وضع w على ملف مهم قبل التأكد؛ لأنه يستبدل المحتوى.

## تدريب
اكتب ملاحظة إلى ملف ثم اقرأها واطبعها.

## خلاصة
استخدم with لإدارة الملفات، واختر r للقراءة وw للكتابة وa للإضافة.',20,3,true,ARRAY['قراءة الملفات وكتابتها']::text[],ARRAY[]::text[]),
('python-12-exceptions','python-intermediate','التعامل مع الاستثناءات Exceptions','استخدم try وexcept لمعالجة المدخلات غير الصحيحة والأخطاء المتوقعة.','# التعامل مع الاستثناءات Exceptions

## هدف الدرس
تتعامل مع أخطاء متوقعة بطريقة واضحة بدل توقف البرنامج دون تفسير.

## 1. ما الاستثناء؟
هو حدث أثناء التنفيذ يوقف المسار الطبيعي، مثل تحويل نص غير رقمي إلى عدد أو القسمة على صفر.

## 2. try وexcept
```python
try:
    age = int("14")
    print(age)
except ValueError:
    print("Please enter a whole number")
```
يضع try العملية التي قد تفشل، ويحدد except نوع الخطأ الذي يمكن التعامل معه.

## 3. أكثر من نوع
يمكن إضافة except لأنواع مختلفة عند وجود معالجة مناسبة لكل نوع. لا تلتقط كل الأخطاء دون سبب.

## 4. else وfinally
else تعمل إذا لم يحدث استثناء. finally تعمل في النهاية سواء حدث استثناء أم لا.

## 5. رسائل مفيدة
اعرض للمستخدم رسالة مفهومة، ولا تكشف تفاصيل تقنية أو بيانات خاصة. أثناء التطوير يمكنك تسجيل معلومات تشخيصية مناسبة.

## تدريب
حوّل نصًا إلى عدد، وتعامل مع ValueError برسالة واضحة.

## خلاصة
استخدم الاستثناءات للحالات المتوقعة، وحدد نوع الخطأ الذي تعالجه، ولا تخفِ الأخطاء بلا تفسير.',20,4,true,ARRAY['التعامل مع الاستثناءات Exceptions']::text[],ARRAY[]::text[]),
('python-13-modules','python-intermediate','الوحدات Modules وتنظيم الكود','قسّم البرنامج إلى ملفات واستورد الدوال واستخدم المكتبات القياسية.','# الوحدات Modules وتنظيم الكود

## هدف الدرس
تستخدم import لتنظيم البرنامج وإعادة استخدام الكود.

## 1. ما Module؟
الوحدة ملف Python يحتوي دوالًا أو متغيرات أو أصنافًا يمكن استيرادها في ملف آخر.

## 2. استيراد مكتبة
```python
import math
print(math.sqrt(81))
```
المكتبة القياسية math توفر عمليات رياضية جاهزة.

## 3. استيراد عنصر محدد
```python
from math import pi
print(pi)
```

## 4. وحدة من مشروعك
يمكن إنشاء ملف helpers.py يحتوي دالة، ثم استيرادها في main.py:
```python
from helpers import greet
greet("Mona")
```
يجب أن يكون الملفان في مسار يستطيع Python الوصول إليه.

## 5. أسماء واضحة
تجنب تسمية ملفك باسم مكتبة قياسية مثل math.py أو random.py حتى لا يحدث تعارض عند الاستيراد.

## تدريب
استخدم math.sqrt لحساب الجذر التربيعي لعدد.

## خلاصة
الوحدات تجعل الكود قابلًا لإعادة الاستخدام والتنظيم، والاستيراد يربط الملفات والمكتبات.',18,5,true,ARRAY['الوحدات Modules وتنظيم الكود']::text[],ARRAY[]::text[]),
('python-14-oop','python-intermediate','البرمجة الكائنية OOP','افهم الأصناف والكائنات والخصائص والدوال داخل الصنف.','# البرمجة الكائنية OOP

## هدف الدرس
تنشئ class وتكوّن objects وتفهم الخصائص والطرق.

## 1. الصنف والكائن
الصنف Class قالب يصف نوعًا من الكائنات. الكائن Object نسخة فعلية من الصنف.

## 2. أول Class
```python
class Student:
    def __init__(self, name, score):
        self.name = name
        self.score = score

    def introduce(self):
        print(f"{self.name}: {self.score}")
```
__init__ تهيئ الكائن عند إنشائه، وself تشير إلى الكائن الحالي.

## 3. إنشاء كائن
```python
student = Student("Mona", 95)
student.introduce()
```

## 4. الخصائص والطرق
الخاصية Attribute بيانات داخل الكائن. الطريقة Method دالة مرتبطة بالصنف.

## 5. متى نستخدم OOP؟
عندما يمثل البرنامج كيانات لها بيانات وسلوك، مثل طالب أو كتاب أو طلب. لا تحتاج OOP لكل برنامج صغير؛ اختر الأسلوب الأبسط للمشكلة.

## تدريب
أنشئ class باسم Book يحتوي title وauthor، وطريقة تعرضهما.

## خلاصة
OOP تنظم البيانات والسلوك في أصناف وكائنات، وتساعد في بناء برامج أكبر عندما تكون مناسبة.',22,6,true,ARRAY['البرمجة الكائنية OOP']::text[],ARRAY[]::text[]),
('cpp-01-first-program','cpp-foundations','أول برنامج C++ وفهم بنية الملف','اكتب برنامج C++ بسيطًا وافهم main وinclude والطباعة.','# أول برنامج C++ وفهم بنية الملف

## هدف الدرس
تتعرف على بنية برنامج C++ وتشغّل أول مثال.

## 1. ملف المصدر
غالبًا تحفظ كود C++ في ملف امتداده .cpp.

## 2. أول برنامج
```cpp
#include <iostream>
using namespace std;

int main() {
    cout << "Hello, DOMA!" << endl;
    return 0;
}
```

## 3. شرح الأجزاء
- `#include <iostream>` يتيح أدوات الإدخال والإخراج.
- `int main()` نقطة بدء البرنامج.
- الأقواس المعقوفة تحدد جسم الدالة.
- `cout` يرسل النص إلى الإخراج.
- `;` تنهي التعليمة.
- `return 0` يشير إلى انتهاء طبيعي للبرنامج.

## 4. الترجمة والتشغيل
يحتاج C++ إلى Compiler يحوّل المصدر إلى برنامج قابل للتنفيذ. تختلف الأوامر حسب نظام التشغيل والمترجم وإعداد المشروع.

## 5. أخطاء شائعة
نسيان ; أو قوس أو كتابة اسم cout بطريقة مختلفة قد يؤدي إلى خطأ ترجمة.

## تدريب
غيّر رسالة الترحيب وأضف سطرًا ثانيًا.

## خلاصة
افهم بنية main والأقواس والفواصل المنقوطة قبل التوسع في اللغة.',18,1,true,ARRAY['أول برنامج C++ وفهم بنية الملف']::text[],ARRAY[]::text[]),
('cpp-02-variables-types','cpp-foundations','المتغيرات وأنواع البيانات في C++','عرّف المتغيرات واختر int وdouble وchar وstring وbool.','# المتغيرات وأنواع البيانات في C++

## هدف الدرس
تعلن متغيرًا بنوع مناسب وتستخدمه في العمليات والطباعة.

## 1. التصريح عن متغير
في C++ تحدد نوع المتغير عند تعريفه:
```cpp
int age = 14;
double price = 12.5;
char grade = ''A'';
bool isActive = true;
```

## 2. النصوص
لاستخدام string أضف:
```cpp
#include <string>
string studentName = "Mona";
```

## 3. لماذا الأنواع؟
النوع يحدد شكل القيمة والعمليات المناسبة لها. int للأعداد الصحيحة، وdouble للأعداد العشرية، وchar لحرف واحد، وbool للصواب والخطأ.

## 4. الثوابت
استخدم const للقيمة التي لا تريد تغييرها:
```cpp
const double TAX_RATE = 0.14;
```

## 5. الطباعة
استخدم cout لعرض القيم. ويمكن تمرير عدة أجزاء باستخدام <<.

## تدريب
عرّف اسم طالب وعمره ودرجته واطبعها.

## خلاصة
C++ لغة ذات أنواع ثابتة نسبيًا؛ حدد النوع المناسب عند تعريف المتغير.',20,2,true,ARRAY['المتغيرات وأنواع البيانات في C++']::text[],ARRAY[]::text[]),
('cpp-03-conditions-loops','cpp-foundations','الشروط والحلقات في C++','استخدم if وelse وfor وwhile للتحكم في مسار البرنامج.','# الشروط والحلقات في C++

## هدف الدرس
تختار مسار التنفيذ وتكرر التعليمات.

## 1. الشرط if
```cpp
int score = 85;
if (score >= 50) {
    cout << "Pass" << endl;
} else {
    cout << "Review" << endl;
}
```
الأقواس المعقوفة تحدد كتلة كل فرع.

## 2. else if
يمكن فحص أكثر من حالة بالترتيب:
```cpp
if (score >= 90) {
    cout << "Excellent";
} else if (score >= 50) {
    cout << "Pass";
} else {
    cout << "Review";
}
```

## 3. for
تستخدم عندما يكون عدد التكرارات معروفًا:
```cpp
for (int i = 1; i <= 3; i++) {
    cout << i << endl;
}
```

## 4. while
تستمر طالما الشرط صحيح. تأكد من تحديث المتغير حتى لا تصبح الحلقة غير منتهية.

## 5. المقارنات والمنطق
استخدم == للمقارنة، و!= للاختلاف، و&& للشرطين معًا، و|| لأحد الشرطين.

## تدريب
اطبع الأعداد من 1 إلى 5، وحدد لكل عدد هل هو زوجي أم فردي.

## خلاصة
الشروط تختار المسار والحلقات تكرر التنفيذ. راجع الحدود وتأكد من توقف الحلقة.',22,3,true,ARRAY['الشروط والحلقات في C++']::text[],ARRAY[]::text[]),
('cpp-04-functions-arrays','cpp-foundations','الدوال والمصفوفات في C++','قسّم البرنامج إلى دوال وتعامل مع مجموعة عناصر متجانسة.','# الدوال والمصفوفات في C++

## هدف الدرس
تنشئ دالة تستقبل قيمًا وتعيد نتيجة، وتخزن عناصر متشابهة في مصفوفة.

## 1. الدالة
```cpp
int add(int a, int b) {
    return a + b;
}
```
نوع الإرجاع int، والاسم add، والوسيطان a وb.

## 2. استدعاء الدالة
```cpp
int total = add(4, 6);
cout << total;
```

## 3. المصفوفة
```cpp
int scores[3] = {70, 80, 90};
cout << scores[0];
```
الفهرسة تبدأ من صفر، وحجم المصفوفة الثابتة محدد عند تعريفها.

## 4. المرور على العناصر
استخدم حلقة for للوصول إلى كل عنصر. لا تستخدم فهرسًا خارج حدود المصفوفة.

## 5. لماذا الدوال؟
تقلل تكرار الكود وتجعل كل جزء مسؤولًا عن مهمة محددة، وتسهل الاختبار.

## تدريب
اكتب دالة تعيد مجموع عددين، ثم مصفوفة من ثلاث درجات واطبع مجموعها.

## خلاصة
الدوال تقسم المهام، والمصفوفات تحفظ مجموعة من القيم المتشابهة.',22,4,true,ARRAY['الدوال والمصفوفات في C++']::text[],ARRAY[]::text[]),
('cpp-05-references-pointers','cpp-foundations','المراجع والمؤشرات ومقدمة الذاكرة','افهم العناوين والمراجع والمؤشرات بصورة تأسيسية وآمنة.','# المراجع والمؤشرات ومقدمة الذاكرة

## هدف الدرس
تفهم الفرق بين المتغير وقيمته وعنوانه، وتتعرف على reference وpointer.

## 1. المتغير في الذاكرة
كل متغير له قيمة ويشغل مساحة في الذاكرة أثناء وجوده. يمكن استخدام عامل & للحصول على عنوان متغير.

## 2. Reference
المرجع اسم بديل لمتغير موجود:
```cpp
int score = 90;
int& scoreRef = score;
scoreRef = 95;
cout << score;
```
تغيير المرجع يغير المتغير الأصلي.

## 3. Pointer
المؤشر متغير يمكنه تخزين عنوان متغير:
```cpp
int score = 90;
int* scorePtr = &score;
cout << *scorePtr;
```
النجمة في التعريف تشير إلى نوع مؤشر، وفي التعبير *scorePtr للوصول إلى القيمة المشار إليها.

## 4. nullptr
إذا لم يشِر المؤشر إلى كائن، يمكن تهيئته بـ nullptr. لا تحاول الوصول إلى قيمة عبر مؤشر فارغ.

## 5. قواعد آمنة
لا تستخدم مؤشرًا قبل تهيئته، ولا تحتفظ بعنوان متغير انتهى عمره، ولا تصل إلى الذاكرة خارج حدود الكائن. في البرامج الحديثة فضّل الأدوات القياسية الآمنة مثل std::vector وsmart pointers عندما تتعلمها.

## تدريب
اكتب مثالًا يعرّف score ومرجعًا له، ثم غيّر القيمة عبر المرجع.

## خلاصة
المراجع أسماء بديلة، والمؤشرات تخزن عناوين. افهم عمر الكائن وحدود الذاكرة قبل استخدام المؤشرات.',22,5,true,ARRAY['المراجع والمؤشرات ومقدمة الذاكرة']::text[],ARRAY[]::text[]),
('cpp-06-classes-objects','cpp-foundations','الأصناف والكائنات في C++','أنشئ class بخصائص ودوال وتعرّف على public وprivate.','# الأصناف والكائنات في C++

## هدف الدرس
تنشئ صنفًا يضم بيانات وسلوكًا وتكوّن كائنًا منه.

## 1. Class
```cpp
class Student {
public:
    string name;
    int score;

    void introduce() {
        cout << name << ": " << score << endl;
    }
};
```
الصنف قالب يجمع البيانات والدوال.

## 2. إنشاء كائن
```cpp
Student first;
first.name = "Mona";
first.score = 95;
first.introduce();
```

## 3. public وprivate
public يسمح بالوصول من خارج الصنف. private يحمي التفاصيل الداخلية ويجعل الوصول إليها من خلال دوال الصنف.

## 4. Constructor
دالة البناء تهيئ الكائن عند إنشائه:
```cpp
Student(string n, int s) {
    name = n;
    score = s;
}
```

## 5. التغليف Encapsulation
اجعل البيانات الحساسة private، ووفر دوالًا واضحة لقراءتها أو تحديثها مع التحقق من صحة القيم.

## تدريب
أنشئ class Book يحتوي title وauthor ودالة تعرض بيانات الكتاب.

## خلاصة
الأصناف تنظم البيانات والسلوك. استخدم التغليف لحماية حالة الكائن.',22,6,true,ARRAY['الأصناف والكائنات في C++']::text[],ARRAY[]::text[])
on conflict (id) do nothing;
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('python-09-collections','إدارة درجات الطلاب','أنشئ قائمة scores من 70 و85 و70، أضف 95، ثم أنشئ مجموعة unique_scores من القائمة واطبع عدد القيم الفريدة.','scores = [70, 85, 70]
# أضف درجة
# أنشئ المجموعة واطبع عدد العناصر
','python',true,'[]'::jsonb,'["استخدم append لإضافة عنصر.","حوّل القائمة إلى set.","استخدم len لمعرفة عدد العناصر."]'::jsonb,'scores = [70, 85, 70]
scores.append(95)
unique_scores = set(scores)
print(len(unique_scores))','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('python-09-collections','اختبار: القوائم والقواميس والمجموعات',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'أي بنية تربط مفتاحًا بقيمة؟','["List","Dictionary","Set"]'::jsonb,1,'القاموس يخزن أزواج المفتاح والقيمة.',1
from public.programming_quizzes z
where z.lesson_id='python-09-collections'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='أي بنية تربط مفتاحًا بقيمة؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما أول فهرس في قائمة Python؟','["0","1","-1"]'::jsonb,0,'الفهرسة المعتادة تبدأ من صفر.',2
from public.programming_quizzes z
where z.lesson_id='python-09-collections'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما أول فهرس في قائمة Python؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما ميزة Set الأساسية؟','["تسمح بتكرار كل العناصر","تحتفظ بعناصر فريدة","تخزن أزواج مفتاح وقيمة"]'::jsonb,1,'المجموعة تمنع تكرار القيمة نفسها.',3
from public.programming_quizzes z
where z.lesson_id='python-09-collections'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما ميزة Set الأساسية؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('python-10-strings','تنظيف رسالة مستخدم','نظّف النص ''  DOMA STUDENT  '' باستخدام strip ثم lower، واطبع user: متبوعًا بالنص.','raw_name = "  DOMA STUDENT  "
# نظّف النص واطبعه
','python',true,'[]'::jsonb,'["ابدأ بـ strip لإزالة المسافات الطرفية.","استخدم lower لتحويل الحروف.","استخدم f-string أو print مع فاصلة."]'::jsonb,'raw_name = "  DOMA STUDENT  "
clean_name = raw_name.strip().lower()
print(f"user: {clean_name}")','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('python-10-strings','اختبار: معالجة النصوص Strings',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما وظيفة strip()؟','["إزالة المسافات الطرفية","عكس النص","تحويل النص إلى رقم"]'::jsonb,0,'strip تزيل المسافات من بداية النص ونهايته.',1
from public.programming_quizzes z
where z.lesson_id='python-10-strings'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما وظيفة strip()؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما الذي تفعله split('','')؟','["تقسم النص عند الفاصلة","تحذف النص كله","تطبع النص"]'::jsonb,0,'split تقسم النص إلى قائمة من الأجزاء.',2
from public.programming_quizzes z
where z.lesson_id='python-10-strings'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما الذي تفعله split('','')؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما فائدة f-string؟','["إدراج قيم داخل نص","إنشاء مجلد","تشغيل الطرفية"]'::jsonb,0,'f-string تسمح بإدراج قيم المتغيرات داخل النص.',3
from public.programming_quizzes z
where z.lesson_id='python-10-strings'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما فائدة f-string؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('python-11-files','حفظ وقراءة ملاحظة','اكتب برنامجًا يفتح notes.txt بوضع الكتابة، يكتب DOMA Academy، ثم يفتح الملف للقراءة ويطبع المحتوى.','with open("notes.txt", "w", encoding="utf-8") as file:
    # اكتب النص
    pass

# افتح الملف للقراءة واطبع محتواه
','python',true,'[]'::jsonb,'["استخدم write للكتابة.","استخدم الوضع r للقراءة.","with يغلق الملف تلقائيًا."]'::jsonb,'with open("notes.txt", "w", encoding="utf-8") as file:
    file.write("DOMA Academy")

with open("notes.txt", "r", encoding="utf-8") as file:
    content = file.read()
print(content)','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('python-11-files','اختبار: قراءة الملفات وكتابتها',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'أي وضع يفتح الملف للقراءة؟','["r","w","a"]'::jsonb,0,'الوضع r مخصص للقراءة.',1
from public.programming_quizzes z
where z.lesson_id='python-11-files'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='أي وضع يفتح الملف للقراءة؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'أي وضع يضيف محتوى إلى نهاية الملف؟','["w","a","r"]'::jsonb,1,'الوضع a يضيف ولا يستبدل المحتوى السابق.',2
from public.programming_quizzes z
where z.lesson_id='python-11-files'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='أي وضع يضيف محتوى إلى نهاية الملف؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما فائدة with open؟','["إدارة إغلاق الملف تلقائيًا","حذف الملف","تغيير امتداده"]'::jsonb,0,'with ينهي إدارة الملف ويغلقه تلقائيًا.',3
from public.programming_quizzes z
where z.lesson_id='python-11-files'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما فائدة with open؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('python-12-exceptions','تحويل آمن إلى عدد','حاول تحويل النص user_input إلى عدد صحيح داخل try، واطبع Number: عند النجاح، أو Invalid number عند حدوث ValueError.','user_input = "25"
try:
    # حوّل النص واطبع العدد
    pass
except ValueError:
    # اطبع رسالة مفهومة
    pass
','python',true,'[]'::jsonb,'["ضع int داخل try.","التقط ValueError تحديدًا.","استخدم رسالة واضحة للمستخدم."]'::jsonb,'user_input = "25"
try:
    number = int(user_input)
    print("Number:", number)
except ValueError:
    print("Invalid number")','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('python-12-exceptions','اختبار: التعامل مع الاستثناءات Exceptions',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'أي كتلة تحتوي العملية التي قد تفشل؟','["try","except","finally"]'::jsonb,0,'try تحتوي العملية التي نريد مراقبة احتمال فشلها.',1
from public.programming_quizzes z
where z.lesson_id='python-12-exceptions'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='أي كتلة تحتوي العملية التي قد تفشل؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما الاستثناء الشائع عند تحويل نص غير رقمي باستخدام int؟','["ValueError","IndexError","KeyError"]'::jsonb,0,'ValueError يحدث عندما تكون القيمة غير مناسبة للتحويل.',2
from public.programming_quizzes z
where z.lesson_id='python-12-exceptions'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما الاستثناء الشائع عند تحويل نص غير رقمي باستخدام int؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'متى تعمل finally؟','["في النهاية سواء حدث استثناء أم لا","فقط عند النجاح","فقط عند فشل الاتصال"]'::jsonb,0,'finally تعمل في نهاية بنية try/except.',3
from public.programming_quizzes z
where z.lesson_id='python-12-exceptions'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='متى تعمل finally؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('python-13-modules','استخدم مكتبة math','استورد math، واحسب الجذر التربيعي للعدد 144، واطبع Square root: 12.0.','import math
number = 144
# احسب الجذر واطبعه
','python',true,'[]'::jsonb,'["استخدم math.sqrt(number).","خزّن النتيجة في متغير.","اطبع النتيجة بعنوان واضح."]'::jsonb,'import math
number = 144
root = math.sqrt(number)
print("Square root:", root)','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('python-13-modules','اختبار: الوحدات Modules وتنظيم الكود',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما وظيفة import؟','["استيراد وحدة أو مكتبة","حذف ملف","إنشاء متغير تلقائيًا"]'::jsonb,0,'import يتيح استخدام وحدات Python.',1
from public.programming_quizzes z
where z.lesson_id='python-13-modules'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما وظيفة import؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'أي مكتبة توفر sqrt؟','["math","json","path"]'::jsonb,0,'الدالة sqrt متاحة في وحدة math.',2
from public.programming_quizzes z
where z.lesson_id='python-13-modules'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='أي مكتبة توفر sqrt؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'لماذا نتجنب تسمية ملفنا random.py؟','["حتى لا يتعارض مع مكتبة قياسية","لأن الامتداد ممنوع","لأن Python لا تقرأ الملفات"]'::jsonb,0,'اسم الملف قد يحجب المكتبة القياسية عند الاستيراد.',3
from public.programming_quizzes z
where z.lesson_id='python-13-modules'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='لماذا نتجنب تسمية ملفنا random.py؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('python-14-oop','صنف Book','أنشئ class Book يستقبل title وauthor، ثم أضف method اسمها describe تطبع العنوان والمؤلف. أنشئ كائنًا واستدعِ الطريقة.','class Book:
    def __init__(self, title, author):
        # خزّن القيم
        pass

    def describe(self):
        # اطبع البيانات
        pass

# أنشئ كائنًا واستدعِ describe
','python',true,'[]'::jsonb,'["استخدم self.title وself.author.","الطريقة method تُعرّف داخل class.","أنشئ كائنًا بكتابة Book(title, author)."]'::jsonb,'class Book:
    def __init__(self, title, author):
        self.title = title
        self.author = author

    def describe(self):
        print(f"{self.title} by {self.author}")

book = Book("Python Basics", "DOMA")
book.describe()','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('python-14-oop','اختبار: البرمجة الكائنية OOP',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما الذي يمثله Class؟','["قالب لإنشاء كائنات","ملف صورة","رسالة خطأ"]'::jsonb,0,'الصنف يحدد خصائص وسلوك الكائنات.',1
from public.programming_quizzes z
where z.lesson_id='python-14-oop'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما الذي يمثله Class؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما دور self؟','["الإشارة إلى الكائن الحالي","استيراد مكتبة","إغلاق الملف"]'::jsonb,0,'self تشير إلى نسخة الكائن التي تعمل عليها الطريقة.',2
from public.programming_quizzes z
where z.lesson_id='python-14-oop'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما دور self؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما الفرق بين Attribute وMethod؟','["الخاصية بيانات والطريقة سلوك/دالة","كلاهما ملف","الخاصية أمر طرفية"]'::jsonb,0,'الخاصية تخزن بيانات، والطريقة تنفذ سلوكًا.',3
from public.programming_quizzes z
where z.lesson_id='python-14-oop'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما الفرق بين Attribute وMethod؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cpp-01-first-program','رسالتان في C++','اكتب برنامج C++ يطبع سطرين: Hello, DOMA! وI am learning C++.','#include <iostream>
using namespace std;

int main() {
    // اكتب سطري الطباعة
    return 0;
}
','cpp',true,'[]'::jsonb,'["استخدم cout للطباعة.","استخدم endl للانتقال إلى سطر جديد.","لا تنسَ ; في نهاية كل تعليمة."]'::jsonb,'#include <iostream>
using namespace std;

int main() {
    cout << "Hello, DOMA!" << endl;
    cout << "I am learning C++" << endl;
    return 0;
}','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cpp-01-first-program','اختبار: أول برنامج C++ وفهم بنية الملف',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما نقطة بدء البرنامج المعتادة في C++؟','["main","start","print"]'::jsonb,0,'الدالة main هي نقطة بدء التنفيذ.',1
from public.programming_quizzes z
where z.lesson_id='cpp-01-first-program'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما نقطة بدء البرنامج المعتادة في C++؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما وظيفة iostream؟','["أدوات الإدخال والإخراج","تنسيق الصور","إدارة قواعد البيانات"]'::jsonb,0,'iostream توفر cin وcout.',2
from public.programming_quizzes z
where z.lesson_id='cpp-01-first-program'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما وظيفة iostream؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما الرمز الذي ينهي معظم تعليمات C++؟','[";"," : ","#"]'::jsonb,0,'الفاصلة المنقوطة تنهي معظم التعليمات.',3
from public.programming_quizzes z
where z.lesson_id='cpp-01-first-program'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما الرمز الذي ينهي معظم تعليمات C++؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cpp-02-variables-types','بيانات طالب في C++','عرّف age كـ int وscore كـ double وstudentName كـ string، ثم اطبع القيم.','#include <iostream>
#include <string>
using namespace std;

int main() {
    // عرّف المتغيرات واطبعها
    return 0;
}
','cpp',true,'[]'::jsonb,'["استخدم string للنص.","استخدم int للعمر.","استخدم double للدرجة العشرية."]'::jsonb,'#include <iostream>
#include <string>
using namespace std;

int main() {
    string studentName = "Mona";
    int age = 14;
    double score = 92.5;
    cout << studentName << " " << age << " " << score << endl;
    return 0;
}','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cpp-02-variables-types','اختبار: المتغيرات وأنواع البيانات في C++',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'أي نوع يناسب عددًا صحيحًا؟','["int","double","char"]'::jsonb,0,'int للأعداد الصحيحة.',1
from public.programming_quizzes z
where z.lesson_id='cpp-02-variables-types'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='أي نوع يناسب عددًا صحيحًا؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'أي نوع يناسب قيمة عشرية؟','["bool","double","char"]'::jsonb,1,'double يخزن أعدادًا عشرية.',2
from public.programming_quizzes z
where z.lesson_id='cpp-02-variables-types'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='أي نوع يناسب قيمة عشرية؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما فائدة const؟','["تعريف قيمة ثابتة لا تتغير","قراءة ملف","إنشاء حلقة"]'::jsonb,0,'const يمنع إعادة إسناد قيمة المتغير.',3
from public.programming_quizzes z
where z.lesson_id='cpp-02-variables-types'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما فائدة const؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cpp-03-conditions-loops','تصنيف الأعداد في C++','استخدم for للمرور على الأعداد من 1 إلى 5، واطبع Even أو Odd لكل عدد باستخدام % وif.','#include <iostream>
using namespace std;

int main() {
    // اكتب الحلقة والشرط
    return 0;
}
','cpp',true,'[]'::jsonb,'["استخدم for مع i من 1 إلى 5.","باقي القسمة على 2 يساوي صفرًا للعدد الزوجي.","استخدم else للحالة الأخرى."]'::jsonb,'#include <iostream>
using namespace std;

int main() {
    for (int i = 1; i <= 5; i++) {
        if (i % 2 == 0) cout << i << " Even" << endl;
        else cout << i << " Odd" << endl;
    }
    return 0;
}','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cpp-03-conditions-loops','اختبار: الشروط والحلقات في C++',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما عامل المقارنة للمساواة؟','["=","==","!="]'::jsonb,1,'== يقارن قيمتين.',1
from public.programming_quizzes z
where z.lesson_id='cpp-03-conditions-loops'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما عامل المقارنة للمساواة؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما فائدة for؟','["تكرار مجموعة تعليمات","تعريف نص فقط","إنهاء البرنامج"]'::jsonb,0,'for حلقة تكرار.',2
from public.programming_quizzes z
where z.lesson_id='cpp-03-conditions-loops'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما فائدة for؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ماذا يجب التأكد منه في while؟','["وجود طريقة تجعل الشرط يتوقف","عدم وجود شرط","حذف المتغير"]'::jsonb,0,'تحديث الحالة يمنع الحلقة غير المنتهية.',3
from public.programming_quizzes z
where z.lesson_id='cpp-03-conditions-loops'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ماذا يجب التأكد منه في while؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cpp-04-functions-arrays','دالة مجموع ومصفوفة درجات','اكتب دالة add تعيد مجموع عددين. ثم أنشئ مصفوفة من 3 درجات واجمع عناصرها باستخدام حلقة.','#include <iostream>
using namespace std;

int add(int a, int b) {
    // أعد المجموع
}

int main() {
    int scores[3] = {70, 80, 90};
    // اجمع العناصر واطبع النتيجة
    return 0;
}
','cpp',true,'[]'::jsonb,'["الدالة add تعيد a + b.","ابدأ total بصفر.","مر على الفهارس 0 و1 و2."]'::jsonb,'#include <iostream>
using namespace std;

int add(int a, int b) { return a + b; }

int main() {
    int scores[3] = {70, 80, 90};
    int total = 0;
    for (int i = 0; i < 3; i++) total = add(total, scores[i]);
    cout << total << endl;
    return 0;
}','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cpp-04-functions-arrays','اختبار: الدوال والمصفوفات في C++',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما الذي تعيده return؟','["قيمة من الدالة","اسم الملف","رسالة طرفية"]'::jsonb,0,'return تعيد نتيجة الدالة.',1
from public.programming_quizzes z
where z.lesson_id='cpp-04-functions-arrays'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما الذي تعيده return؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما أول فهرس في المصفوفة؟','["0","1","3"]'::jsonb,0,'فهرسة المصفوفة تبدأ من صفر.',2
from public.programming_quizzes z
where z.lesson_id='cpp-04-functions-arrays'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما أول فهرس في المصفوفة؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'لماذا نستخدم الدوال؟','["تقسيم المهام وإعادة الاستخدام","زيادة الأخطاء","إلغاء المتغيرات"]'::jsonb,0,'الدوال تجعل الكود منظمًا وقابلًا لإعادة الاستخدام.',3
from public.programming_quizzes z
where z.lesson_id='cpp-04-functions-arrays'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='لماذا نستخدم الدوال؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cpp-05-references-pointers','استخدم Reference','عرّف int score = 80، وأنشئ int& scoreRef = score، ثم غيّر القيمة إلى 95 عبر المرجع واطبع score.','#include <iostream>
using namespace std;

int main() {
    int score = 80;
    // أنشئ مرجعًا وغيّر القيمة
    return 0;
}
','cpp',true,'[]'::jsonb,'["اكتب int& قبل اسم المرجع.","اجعل المرجع يشير إلى score.","غيّر scoreRef ثم اطبع score."]'::jsonb,'#include <iostream>
using namespace std;

int main() {
    int score = 80;
    int& scoreRef = score;
    scoreRef = 95;
    cout << score << endl;
    return 0;
}','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cpp-05-references-pointers','اختبار: المراجع والمؤشرات ومقدمة الذاكرة',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما الذي يخزنه Pointer؟','["عنوان ذاكرة","نص فقط","نتيجة اختبار"]'::jsonb,0,'المؤشر يخزن عنوانًا.',1
from public.programming_quizzes z
where z.lesson_id='cpp-05-references-pointers'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما الذي يخزنه Pointer؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ماذا يعني nullptr؟','["مؤشر لا يشير إلى كائن","قيمة 100","نهاية الحلقة"]'::jsonb,0,'nullptr يمثل مؤشرًا فارغًا.',2
from public.programming_quizzes z
where z.lesson_id='cpp-05-references-pointers'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ماذا يعني nullptr؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما الذي يحدث عند تعديل Reference؟','["يتغير المتغير الأصلي","ينشأ ملف جديد","يُحذف البرنامج"]'::jsonb,0,'المرجع اسم آخر لنفس المتغير.',3
from public.programming_quizzes z
where z.lesson_id='cpp-05-references-pointers'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما الذي يحدث عند تعديل Reference؟');
insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cpp-06-classes-objects','صنف Student','أنشئ class Student يحتوي name وscore ودالة introduce تطبع البيانات. أنشئ كائنًا واطبع بياناته.','#include <iostream>
#include <string>
using namespace std;

class Student {
public:
    string name;
    int score;
    // أضف الدالة
};

int main() {
    // أنشئ كائنًا واستدع الدالة
    return 0;
}
','cpp',true,'[]'::jsonb,'["عرّف الدالة داخل class.","أنشئ كائنًا من Student.","استدعِ introduce باستخدام النقطة."]'::jsonb,'#include <iostream>
#include <string>
using namespace std;

class Student {
public:
    string name;
    int score;
    void introduce() { cout << name << ": " << score << endl; }
};

int main() {
    Student first;
    first.name = "Mona";
    first.score = 95;
    first.introduce();
    return 0;
}','[{"criterion":"صحة الحل","weight":60},{"criterion":"وضوح وتنظيم الكود","weight":40}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;
insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cpp-06-classes-objects','اختبار: الأصناف والكائنات في C++',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما الذي يجمعه Class؟','["بيانات وسلوك","ملفات النظام فقط","أوامر Terminal"]'::jsonb,0,'الصنف يجمع الخصائص والطرق.',1
from public.programming_quizzes z
where z.lesson_id='cpp-06-classes-objects'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما الذي يجمعه Class؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما معنى private؟','["إخفاء العضو عن الوصول المباشر من خارج الصنف","السماح بالوصول العام","طباعة القيمة"]'::jsonb,0,'private يحد الوصول المباشر إلى أعضاء الصنف.',2
from public.programming_quizzes z
where z.lesson_id='cpp-06-classes-objects'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما معنى private؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select z.id,'ما وظيفة Constructor؟','["تهيئة الكائن عند إنشائه","حذف الملف","ترجمة HTML"]'::jsonb,0,'دالة البناء تجهز حالة الكائن.',3
from public.programming_quizzes z
where z.lesson_id='cpp-06-classes-objects'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=z.id and old.prompt='ما وظيفة Constructor؟');
