-- Rebuild the first Python lesson with the verified teaching content and activity data.
begin;
update public.programming_lessons
set title=$lesson_title$أول برنامج لك بلغة Python$lesson_title$,
    summary=$lesson_summary$شغّل أول برنامج Python، وافهم print وترتيب التنفيذ والتعليقات، ثم عدّل البرنامج بنفسك.$lesson_summary$,
    content_md=$lesson_content$
# أول برنامج لك بلغة Python

## ماذا ستتعلم؟
بنهاية الدرس ستكون قادرًا على:
- شرح معنى لغة Python ومتى نستخدمها.
- كتابة أمر يعرض نصًا أو رقمًا باستخدام `print()`.
- التمييز بين النصوص والأرقام عند الطباعة.
- توقع ترتيب تنفيذ الأوامر وقراءة الناتج.
- كتابة تعليق مفيد واكتشاف أخطاء الأقواس والاقتباس وحالة الأحرف.

## 1. ما لغة Python؟
Python لغة برمجة عامة الاستخدام. نكتب بها تعليمات يقرأها المفسّر وينفذها. تُستخدم في تطبيقات الويب، وتحليل البيانات، والأتمتة، والذكاء الاصطناعي، والتعليم. ميزتها للمبتدئ أن صياغتها غالبًا واضحة وقريبة من اللغة المقروءة. لكن اختيار اللغة يعتمد على المشكلة التي نريد حلها.

## 2. أول أمر: print()
الدالة `print()` تعرض قيمة في نافذة الإخراج:

```python
print("Hello, DOMA!")
```

الناتج:
```text
Hello, DOMA!
```

`print` اسم الدالة، والقوسان `()` يحتويان على القيمة، وعلامتا الاقتباس تحددان أن القيمة نص (string). جرّب تغيير النص ثم شغّل البرنامج ولاحظ اختلاف الناتج.

## 3. النصوص والأرقام والتعبيرات
```python
print("Learning Python")
print(2026)
print(7 + 5)
```

الناتج:
```text
Learning Python
2026
12
```

السطر الأول يعرض نصًا، والثاني عددًا صحيحًا، والثالث يحسب التعبير ثم يعرض الناتج. قارن:
```python
print("7 + 5")
print(7 + 5)
```
الأول يعرض الأحرف كما كُتبت، والثاني ينفذ عملية الجمع. الاقتباس هو ما يصنع الفرق.

## 4. ترتيب تنفيذ الأوامر
في البرنامج البسيط تُنفذ الأسطر بالترتيب من أعلى إلى أسفل:
```python
print("Start")
print(3 * 4)
print("Finish")
```
الناتج هو Start ثم 12 ثم Finish. ينفذ المفسّر السطر التالي بعد الانتهاء من السابق. لاحقًا ستتعلم الشروط والحلقات، وهي أدوات تغيّر مسار التنفيذ.

## 5. التعليقات
التعليق ملاحظة للمبرمج ويبدأ في Python بالرمز `#`:
```python
# Display the academy welcome message
print("Welcome to DOMA")
```
التعليق لا ينفذ ولا يظهر في الإخراج. استخدمه لشرح سبب قرار غير واضح، لا لتكرار ما يقوله الكود حرفيًا.

## 6. أخطاء شائعة وكيف تقرؤها
- **نسيان علامة الاقتباس:** `print("Hello)` يسبب خطأ لأن النص لم يُغلق.
- **نسيان القوس:** `print("Hello"` لا يحتوي على قوس إغلاق.
- **حالة الأحرف:** `Print("Hello")` ليست مثل `print("Hello")`؛ Python حساسة لحالة الأحرف.
- **نص دون اقتباس:** `print(Hello)` يجعل Python تبحث عن اسم متغير اسمه Hello؛ إن لم يكن معرّفًا يظهر خطأ.

اقرأ نوع الخطأ ورقم السطر، ثم افحص الأقواس والاقتباسات وتهجئة أسماء الدوال. غيّر سببًا واحدًا في كل مرة ثم أعد التشغيل.

## 7. حلّل المثال
```python
print("My first program")
print(10 + 2)
# The final line prints a message
print("I did it!")
```
توقّع عدد الأسطر قبل التشغيل. لاحظ أن التعليق لا يظهر ضمن الإخراج.

## تدريب موجّه
1. شغّل المثال دون تغيير.
2. غيّر الجملة الأولى إلى عنوان من اختيارك.
3. غيّر العملية الحسابية إلى عملية ضرب.
4. أضف سطرًا رابعًا يعرض رسالة تشجيع.
5. أضف تعليقًا يوضح هدف البرنامج.

## تحدّي الدرس
أنشئ بطاقة تعريف نصية من ثلاثة أسطر: اسم مشروعك، جملة تصف هدفه، وناتج عملية حسابية. استخدم `print()` في كل سطر، واجعل التعليق يشرح هدف البرنامج.

## ملخص سريع
- `print()` تعرض القيم.
- الاقتباسات تجعل القيمة نصًا، أما التعبير الحسابي خارج الاقتباسات فيُحسب.
- تنفذ الأسطر البسيطة بالترتيب.
- التعليقات تبدأ بـ `#` ولا تظهر في الناتج.
- رسالة الخطأ تساعدك على تحديد السطر والمشكلة.

**قاعدة الممارسة:** توقّع الناتج أولًا، شغّل الكود، ثم غيّر شيئًا واحدًا ولاحظ الفرق.
$lesson_content$,
    duration_minutes=12,
    published=true,
    updated_at=now()
where id='python-01-first-program';

update public.programming_exercises e
set title=x.title,instructions=x.instructions,starter_code=x.starter_code,language=x.language,
    is_published=x.is_published,test_cases=x.test_cases,hints=x.hints,solution_code=x.solution_code,
    rubric=x.rubric,grading_mode=x.grading_mode,updated_at=now()
from jsonb_to_record($exercise${"id":"03ae1982-b011-44a4-9c96-c248edeba507","hints":["راجع الأقواس وعلامات الاقتباس في كل استدعاء لـ print().","ضع العملية 8 * 5 داخل print() حتى يحسبها Python بدل كتابة الناتج مباشرة.","التعليق يبدأ بالرمز # ويمكن وضعه في سطر مستقل."],"title":"تحدّي: بطاقة الترحيب الأولى","rubric":[],"language":"python","lesson_id":"python-01-first-program","created_at":"2026-11-11T00:31:10.732957+00:00","test_cases":[{"label":"عنوان الترحيب","contains":"Welcome to DOMA"},{"label":"اسم المسار","contains":"Python Programming"},{"label":"ناتج العملية الحسابية","contains":"40"}],"updated_at":"2026-11-12T01:46:08.226749+00:00","grading_mode":"stdout","instructions":"\n## هدف التدريب\nاكتب برنامج Python يعرض بطاقة ترحيب من ثلاثة أسطر باستخدام `print()`.\n\n## المطلوب\n1. اطبع العنوان `Welcome to DOMA`.\n2. اطبع اسم المسار `Python Programming`.\n3. اطبع ناتج العملية الحسابية `8 * 5` في السطر الثالث (اكتب العملية داخل print، ولا تكتب الناتج يدويًا).\n4. أضف تعليقًا يبدأ بـ `#` يشرح هدف البرنامج.\n\n## طريقة العمل\nابدأ من كود البداية وعدّل عليه، ثم شغّل «اختبر الحل». اقرأ نتيجة كل فحص، وأصلح الخطأ، وبعد نجاح الفحوصات أرسل الحل للمراجعة.\n\n## معايير النجاح\n- ظهور العنوان واسم المسار.\n- حساب العملية داخل Python وظهور الناتج الصحيح.\n- وجود تعليق صالح لا يسبب أي مخرجات إضافية.\n","is_published":true,"starter_code":"# TODO: Print the welcome title\nprint(\"Welcome to DOMA\")\n\n# TODO: Print the course name\n\n# TODO: Print the result of 8 * 5\n","solution_code":"# Welcome card for a new Python learner\\nprint(\"Welcome to DOMA\")\\nprint(\"Python Programming\")\\nprint(8 * 5)"}$exercise$::jsonb) as x(
 id uuid,lesson_id text,title text,instructions text,starter_code text,language text,
 is_published boolean,test_cases jsonb,hints jsonb,solution_code text,rubric jsonb,grading_mode text
)
where e.id=x.id and e.lesson_id=x.lesson_id;

delete from public.programming_quiz_questions where quiz_id='4be8e9c0-c777-451e-be41-e1d6a7578a86'::uuid;
insert into public.programming_quiz_questions(id,quiz_id,prompt,options,correct_index,explanation,sort_order)
select x.id,x.quiz_id,x.prompt,x.options,x.correct_index,x.explanation,x.sort_order
from jsonb_to_recordset($questions$[{"id":"21b00eec-7ed7-4cd7-9c74-8893e96b057b","prompt":"ما الوظيفة الأساسية للدالة print()؟","options":["قراءة قيمة من المستخدم","عرض قيمة في نافذة الإخراج","حفظ ملف Python","إنشاء حلقة تكرار"],"quiz_id":"4be8e9c0-c777-451e-be41-e1d6a7578a86","sort_order":1,"explanation":"print() تعرض القيمة التي تمررها إليها. قراءة إدخال المستخدم تتم بدالة مختلفة سنتعلمها لاحقًا.","correct_index":1},{"id":"08cef53b-2113-44a7-8049-8ac3ea897254","prompt":"ما الناتج الدقيق للأمر print(7 + 5)؟","options":["7 + 5","75","12","خطأ دائمًا"],"quiz_id":"4be8e9c0-c777-451e-be41-e1d6a7578a86","sort_order":2,"explanation":"التعبير الحسابي خارج علامات الاقتباس يُحسب أولًا؛ لذلك 7 + 5 تساوي 12.","correct_index":2},{"id":"f53ccc55-5d31-45d8-849a-a75bf744ce59","prompt":"ما الفرق بين print(\"7 + 5\") و print(7 + 5)؟","options":["لا يوجد فرق","الأول يحسب والثاني يعرض نصًا","الأول يعرض النص كما هو والثاني يحسب الجمع","كلاهما يطبع 12"],"quiz_id":"4be8e9c0-c777-451e-be41-e1d6a7578a86","sort_order":3,"explanation":"علامتا الاقتباس تجعل ما بداخلهما نصًا حرفيًا. من دون الاقتباس يتعامل Python مع + كعملية جمع.","correct_index":2},{"id":"57e5dcc0-d776-4168-ab1e-88f14f731338","prompt":"ما ترتيب المخرجات عند تشغيل: print(\"A\") ثم print(\"B\")؟","options":["B ثم A","A ثم B","A فقط","B فقط"],"quiz_id":"4be8e9c0-c777-451e-be41-e1d6a7578a86","sort_order":4,"explanation":"في هذا المثال لا توجد شروط أو حلقات تغيّر المسار؛ لذلك ينفذ Python السطر الأول ثم الثاني.","correct_index":1},{"id":"c91b8a03-97e7-453a-9648-5a211a86bcfd","prompt":"أي مثال يمثل تعليقًا في Python؟","options":["// note","<!-- note -->","# note","** note"],"quiz_id":"4be8e9c0-c777-451e-be41-e1d6a7578a86","sort_order":5,"explanation":"في Python يبدأ تعليق السطر الواحد بالرمز #. الرموز الأخرى تخص لغات أو صيغًا مختلفة.","correct_index":2},{"id":"3b6c46cb-1cf3-4c07-8b3a-745948eadd6a","prompt":"صح أم خطأ: الأمر Print(\"Hi\") مطابق تمامًا للأمر print(\"Hi\").","options":["صح","خطأ"],"quiz_id":"4be8e9c0-c777-451e-be41-e1d6a7578a86","sort_order":6,"explanation":"الإجابة خطأ؛ Python حساسة لحالة الأحرف، واسم الدالة المدمجة هو print بحروف صغيرة.","correct_index":1},{"id":"211f80ec-8047-47bb-9f01-9e0c54fe47c7","prompt":"أي مثال قد يسبب SyntaxError بسبب عدم إغلاق النص؟","options":["print(\"Hello\")","print(2026)","print(\"Hello)","print(2 + 3)"],"quiz_id":"4be8e9c0-c777-451e-be41-e1d6a7578a86","sort_order":7,"explanation":"في الخيار الثالث بدأ النص بعلامة اقتباس مزدوجة ولم تُغلق قبل نهاية السطر، لذلك لا يستطيع المفسّر تحليل التعليمة.","correct_index":2},{"id":"097126e4-e54f-4750-a356-d84d93b56b65","prompt":"ما الناتج بالترتيب؟ print(\"Start\") ثم print(2 * 3) ثم print(\"End\")","options":["Start ثم 6 ثم End","6 ثم Start ثم End","Start ثم 23 ثم End","End ثم 6 ثم Start"],"quiz_id":"4be8e9c0-c777-451e-be41-e1d6a7578a86","sort_order":8,"explanation":"تُنفذ الأسطر بالترتيب. السطر الثاني يحسب 2 × 3 فيعرض 6، ثم ينفذ السطر الأخير.","correct_index":0}]$questions$::jsonb) as x(
 id uuid,quiz_id uuid,prompt text,options jsonb,correct_index integer,explanation text,sort_order integer
);
commit;