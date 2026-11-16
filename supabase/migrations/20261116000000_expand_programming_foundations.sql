-- Expand beginner foundations: keyboard, files, terminal, debugging and testing.
insert into public.programming_lessons
(id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites)
values
('cs-09-files-and-folders','cs-start-here','تنظيم الملفات والمجلدات للمبرمج','افهم الملفات والامتدادات والمجلدات وكيف تنظم مشروعك قبل كتابة الكود.','# تنظيم الملفات والمجلدات للمبرمج

## هدف الدرس
تتعرف على الفرق بين الملف والمجلد والامتداد والمسار، وتنشئ مجلد مشروع منظمًا.

## 1. الملف والمجلد
الملف يحتوي بيانات مثل كود أو صورة أو مستند. المجلد يجمع ملفات ومجلدات أخرى. تنظيمها يجعل المشروع أسهل في الفهم والنقل والنسخ الاحتياطي.

## 2. امتداد الملف
الامتداد هو الجزء الأخير من الاسم بعد النقطة:
- `.py` ملف Python.
- `.html` صفحة HTML.
- `.css` تنسيق صفحة.
- `.js` كود JavaScript.
- `.txt` نص عادي.

لا تغيّر الامتداد لمجرد تغيير الاسم؛ امتداد الملف يجب أن يناسب محتواه.

## 3. المسار Path
المسار يوضح مكان الملف. المسار المطلق يبدأ من موقع معروف في الجهاز، والمسار النسبي يحدد مكان الملف نسبةً إلى المجلد الحالي.

## 4. هيكل مشروع بسيط
```text
my-first-project/
  README.md
  src/
    main.py
  assets/
```
ضع الكود في src، والملفات المساعدة في assets، واكتب وصف المشروع في README.

## 5. أسماء واضحة
استخدم أسماء مثل `calculator.py` و`student_records`. تجنب أسماء غامضة مثل `new2-final-last.py`، وتجنب الرموز الغريبة والمسافات غير الضرورية.

## تطبيق
أنشئ مجلدًا باسم `my-first-project`، وداخله مجلد `src` وملف `main.py`. اكتب برنامج Hello واحفظه.

## خلاصة
المشروع المنظم يبدأ بأسماء واضحة ومجلدات مفهومة وامتدادات صحيحة.',14,9,true,ARRAY['تنظيم الملفات والمجلدات للمبرمج']::text[],ARRAY[]::text[]),
('cs-10-keyboard-layout','cs-start-here','الكتابة على لوحة المفاتيح للمبرمج','تدرّب على تخطيط اللغة الإنجليزية والحروف الكبيرة والصغيرة والأرقام أثناء كتابة الكود.','# الكتابة على لوحة المفاتيح للمبرمج

## هدف الدرس
تكتب أسماء المتغيرات والكلمات البرمجية بدقة، وتتعامل مع اختلاف اللغة والحروف الكبيرة والصغيرة.

## 1. لغة الإدخال
يمكن أن يكون تخطيط لوحة المفاتيح عربيًا أو إنجليزيًا. قبل كتابة الكود، تأكد أن اللغة الإنجليزية مفعّلة؛ لأن الحروف العربية داخل تعليمة برمجية قد تسبب خطأ.

## 2. الحروف الكبيرة والصغيرة
في Python الأسماء حساسة لحالة الحرف:
```python
student = "Mona"
Student = "Ali"
print(student)
print(Student)
```
المتغيران مختلفان. اختر أسلوب تسمية واضحًا والتزم به.

## 3. كتابة أسماء مفهومة
استخدم `student_name` بدلًا من `student name`، واستخدم `total_price` بدلًا من `tp` عندما يكون الاسم الطويل أوضح.

## 4. التدريب على الدقة
اكتب السطر التالي ببطء، ثم قارنه بالمثال:
```python
user_name = "Omar"
score = 95
print(user_name, score)
```
راجع كل حرف، والشرطة السفلية، وعلامات الاقتباس، والأقواس.

## 5. إذا ظهر رمز مختلف
لا تفترض أن كل لوحة مفاتيح تضع الرمز في المكان نفسه. راجع تخطيط اللغة النشط، واستخدم خريطة لوحة المفاتيح في إعدادات النظام عند الحاجة.

## تدريب
اكتب ثلاثة متغيرات: اسم، عمر، ودرجة. اطبعها في سطر واحد. تأكد من أن أسماء المتغيرات مكتوبة بالإنجليزية.

## خلاصة
الدقة أهم من السرعة في البداية. راجع اللغة النشطة وحالة الأحرف وأسماء المتغيرات قبل التشغيل.',15,10,true,ARRAY['الكتابة على لوحة المفاتيح للمبرمج']::text[],ARRAY[]::text[]),
('cs-11-programming-symbols','cs-start-here','رموز البرمجة والأقواس وعلامات الترقيم','تعرف على وظيفة الأقواس والاقتباسات والفواصل والنقطتين وعلامات العمليات.','# رموز البرمجة والأقواس وعلامات الترقيم

## هدف الدرس
تميز الرموز الشائعة وتفهم دورها في بناء التعليمة البرمجية.

## 1. الأقواس
- `( )` تستخدم مع استدعاء الدوال وتجميع العمليات.
- `[ ]` تستخدم مع القوائم والفهارس.
- `{ }` تستخدم مع القواميس والمجموعات في Python، ومع الكتل في لغات أخرى.

## 2. علامات الاقتباس
النصوص توضع بين اقتباسين مستقيمين:
```python
name = "Laila"
city = ''Alexandria''
```
لا تخلط بين الاقتباس المستقيم والاقتباس الذكي المزخرف.

## 3. رموز مهمة
- `:` تبدأ كتلة if أو for أو def في Python.
- `,` تفصل بين عناصر أو وسائط.
- `.` للوصول إلى خاصية أو دالة، مثل `text.upper()`.
- `=` لإسناد قيمة.
- `==` لمقارنة قيمتين.
- `#` لبداية تعليق في Python.
- `+` و`-` و`*` و`/` عمليات حسابية.

## 4. مثال يجمع الرموز
```python
scores = [80, 90, 100]
average = sum(scores) / len(scores)
if average >= 90:
    print("Excellent!", average)
```
لاحظ الأقواس المربعة للقائمة، والأقواس العادية للدوال، والنقطتين بعد الشرط، والمسافة البادئة.

## 5. أخطاء شائعة
نسيان قوس إغلاق، أو كتابة `=` بدل `==` في شرط مقارنة، أو حذف النقطتين، أو استخدام اقتباس غير مستقيم.

## تدريب
اكتب قائمة من ثلاثة أرقام، واحسب مجموعها، ثم اطبع الناتج. أضف تعليقًا يشرح العملية.

## خلاصة
كل رمز له وظيفة. لا تحفظ شكله فقط؛ اربط الرمز بالمكان الذي تستخدمه فيه.',18,11,true,ARRAY['رموز البرمجة والأقواس وعلامات الترقيم']::text[],ARRAY[]::text[]),
('cs-12-code-editor-workflow','cs-start-here','استخدام محرر الكود وكتابة أول برنامج','تعرف على أجزاء محرر الكود وكيف تكتب وتحفظ وتشغّل وتراجع برنامجك.','# استخدام محرر الكود وكتابة أول برنامج

## هدف الدرس
تتعامل مع محرر الكود وتنفذ دورة العمل من كتابة البرنامج حتى مراجعة النتيجة.

## 1. ما محرر الكود؟
هو برنامج لكتابة الملفات البرمجية. قد يوفر تلوين الصياغة، وأرقام الأسطر، والإكمال التلقائي، والبحث، والتنبيهات.

## 2. دورة العمل
1. افتح ملفًا جديدًا أو مشروعًا موجودًا.
2. اختر اللغة المناسبة.
3. اكتب الكود.
4. احفظ الملف بالامتداد الصحيح.
5. شغّل البرنامج.
6. اقرأ النتيجة ورسائل الخطأ.
7. عدّل ثم أعد التشغيل.

## 3. أول برنامج
```python
print("Hello, DOMA!")
```
الدالة print تعرض النص في منطقة الإخراج.

## 4. التعليقات
التعليق يشرح الكود ولا يُنفذ:
```python
# This is a comment
print("Learning Python")
```

## 5. اختصارات مفيدة
- Ctrl + S للحفظ.
- Ctrl + Z للتراجع.
- Ctrl + F للبحث.
- Ctrl + Enter لتشغيل الكود في محرر DOMA.

## 6. لا تخلط بين المحرر والبرنامج
المحرر مكان كتابة الملف. المفسر أو بيئة التشغيل هي التي تنفذ التعليمات. قد يكونان داخل تطبيق واحد، لكن وظيفتهما مختلفة.

## تطبيق
اكتب برنامجًا يطبع اسمك ورسالة قصيرة في سطرين، ثم غيّر الرسالة واحفظ وشغّل مرة أخرى.

## خلاصة
اكتب، احفظ، شغّل، اقرأ النتيجة، ثم حسّن. هذه دورة العمل الأساسية للمبرمج.',16,12,true,ARRAY['استخدام محرر الكود وكتابة أول برنامج']::text[],ARRAY[]::text[]),
('cs-13-project-structure','cs-start-here','إنشاء مشروع صغير منظم','اجمع الملفات والكود والوصف في مشروع واحد يسهل تطويره ومشاركته.','# إنشاء مشروع صغير منظم

## هدف الدرس
تخطط لمشروع صغير وتفصل الكود عن وصف المشروع وملفاته المساعدة.

## 1. قبل كتابة الكود
اكتب هدف المشروع، ومن سيستخدمه، والمدخلات، والعمليات، والمخرجات. قسّم العمل إلى مهام صغيرة.

## 2. هيكل مقترح
```text
grade-calculator/
  README.md
  src/
    main.py
  tests/
```
يمكن أن يبدأ المشروع بملف واحد، ثم تقسّمه عندما يكبر.

## 3. ملف README
اكتب فيه اسم المشروع، وفكرته، وطريقة تشغيله، وما الذي تعلمته. لا تضع كلمات مرور أو بيانات خاصة في ملفات المشروع.

## 4. اكتب كودًا قابلًا للقراءة
استخدم أسماء واضحة، ودوال صغيرة عند الحاجة، وتعليقات تشرح السبب عندما لا يكون واضحًا من الكود.

## 5. راجع قبل المشاركة
تأكد من حفظ الملفات المطلوبة، وإزالة الملفات المؤقتة، وتجربة المشروع من البداية، وكتابة تعليمات تشغيل واضحة.

## تطبيق
صمم Grade Calculator يستقبل ثلاث درجات، ويحسب المتوسط، ويعرض Pass إذا كان المتوسط 50 أو أكثر.

## خلاصة
المشروع الجيد ليس كودًا فقط؛ إنه ملفات منظمة وتعليمات واضحة واختبارات تثبت أن الحل يعمل.',18,13,true,ARRAY['إنشاء مشروع صغير منظم']::text[],ARRAY[]::text[]),
('tools-05-terminal-basics','tools-foundations','ما هو Terminal وسطر الأوامر؟','افهم الطرفية والموجه والأوامر والمجلد الحالي والفرق بين الأوامر والبرامج.','# ما هو Terminal وسطر الأوامر؟

## هدف الدرس
تفهم وظيفة الطرفية، وتقرأ شكل الموجه، وتنفذ أوامر تدريبية بسيطة.

## 1. التعريف
Terminal تطبيق يتيح لك التعامل مع النظام بكتابة أوامر نصية. Command Line هو أسلوب التفاعل نفسه. تستخدمه للتنقل بين المجلدات وتشغيل الأدوات وإدارة المشاريع.

## 2. شكل الموجه
قد ترى شيئًا مثل:
```text
student@computer:~/project$
```
هذا يوضح اسم المستخدم والجهاز والمجلد الحالي، ثم علامة تنتظر الأمر. قد يختلف الشكل حسب النظام.

## 3. الأمر والوسائط
في `mkdir practice` الأمر هو mkdir والوسيط هو اسم المجلد practice. اكتب الأمر ثم اضغط Enter.

## 4. المجلد الحالي
الأوامر النسبية تعتمد على مكانك الحالي. لذلك تعرّف على المجلد الحالي قبل تنفيذ أمر متعلق بملف.

## 5. أوامر أساسية
- `pwd`: عرض المجلد الحالي في أنظمة Unix.
- `ls`: عرض محتويات المجلد في Unix.
- `dir`: عرض المحتويات في Windows.
- `cd`: الانتقال بين المجلدات.
- `mkdir`: إنشاء مجلد.
- `clear` أو `cls`: تنظيف الشاشة حسب النظام.

## 6. الأمان
افهم الأمر قبل تنفيذه، ولا تنسخ أوامر مجهولة. ابدأ بأوامر العرض والتنقل، ولا تستخدم أوامر حذف أو تغيير صلاحيات دون فهم أثرها.

## تدريب
افتح محاكاة Terminal في دليل المبرمج، واكتب help ثم pwd ثم ls.

## خلاصة
الطرفية وسيلة للتواصل مع النظام. اقرأ الموجه، وافهم الأمر ووسائطه، وتأكد من مكانك قبل العمل على الملفات.',16,5,true,ARRAY['ما هو Terminal وسطر الأوامر؟']::text[],ARRAY[]::text[]),
('tools-06-terminal-navigation','tools-foundations','التنقل بين المجلدات وإدارة الملفات','تدرب على pwd وls وcd وmkdir وtouch وقراءة الملفات دون تنفيذ أوامر مجهولة.','# التنقل بين المجلدات وإدارة الملفات

## هدف الدرس
تتنقل بين المجلدات وتتعرف على أوامر إنشاء الملفات وعرضها.

## 1. اعرف مكانك
في أنظمة Unix استخدم `pwd` لعرض المسار الحالي. في Windows يمكنك استخدام `cd` دون وسيط في Command Prompt لعرض المسار.

## 2. اعرض المحتويات
استخدم `ls` في Linux وmacOS، أو `dir` في Windows Command Prompt.

## 3. انتقل إلى مجلد
```bash
cd practice
cd ..
```
الأمر الأول يدخل إلى مجلد practice. والثاني يعود إلى المجلد الأعلى.

## 4. أنشئ مجلدًا وملفًا
```bash
mkdir practice
touch hello.py
```
touch متاح في أنظمة Unix. على Windows يمكن إنشاء ملف من محرر النصوص أو استخدام أوامر مناسبة للنظام.

## 5. اعرض ملفًا نصيًا
في Unix استخدم `cat hello.py`. في Windows Command Prompt استخدم `type hello.py`.

## 6. افهم رسائل النظام
رسالة مثل No such file or directory تعني أن المسار أو الاسم غير موجود. راجع التهجئة والمجلد الحالي بدل تكرار الأمر عشوائيًا.

## تدريب
في محاكاة دليل المبرمج أنشئ مجلد practice، ادخل إليه، وأنشئ hello.py.

## خلاصة
التنقل المنظم يبدأ بمعرفة مكانك، ثم عرض المحتويات، ثم تنفيذ أمر واحد واضح في كل مرة.',18,6,true,ARRAY['التنقل بين المجلدات وإدارة الملفات']::text[],ARRAY[]::text[]),
('tools-07-run-programs','tools-foundations','تشغيل البرامج من الطرفية','تعلم كيف تحفظ ملف Python وتشغله وتقرأ الناتج ورسائل التشغيل.','# تشغيل البرامج من الطرفية

## هدف الدرس
تفهم العلاقة بين الملف والمفسر والطرفية، وتشغّل برنامجًا محفوظًا.

## 1. احفظ الملف أولًا
أنشئ ملفًا باسم `hello.py` واكتب:
```python
print("Hello from the terminal!")
```
تأكد أن الامتداد .py وليس .txt.

## 2. افتح الطرفية في مجلد المشروع
انتقل إلى المجلد الذي يحتوي الملف. استخدم pwd أو dir/ls للتحقق من وجوده.

## 3. شغّل Python
في كثير من الأنظمة:
```bash
python hello.py
```
وقد تحتاج إلى:
```bash
python3 hello.py
```
على Windows قد يعمل الأمر `py hello.py` حسب التثبيت.

## 4. اقرأ النتيجة
إذا ظهر النص، فقد نُفذ البرنامج ووصل إلى أمر الطباعة. إذا ظهر أن الأمر غير معروف، فقد لا يكون Python مثبتًا أو غير مضاف إلى PATH، أو قد يختلف اسم الأمر في النظام.

## 5. لا تخلط بين الأخطاء
- ملف غير موجود: تحقق من المجلد والاسم.
- أمر Python غير معروف: تحقق من تثبيت بيئة Python وإعدادها.
- SyntaxError: راجع صياغة الكود.

## تدريب
استخدم محرر DOMA لتشغيل مثال Python، ثم اقرأ كيف سيُشغّل ملف محفوظ من الطرفية على جهازك.

## خلاصة
شغّل البرنامج من المجلد الصحيح، باستخدام أمر البيئة المناسبة، ثم اقرأ الناتج ورسائل الخطأ بعناية.',17,7,true,ARRAY['تشغيل البرامج من الطرفية']::text[],ARRAY[]::text[]),
('tools-08-understand-errors','tools-foundations','قراءة رسائل الخطأ وفهم أنواعها','ميّز أخطاء الصياغة والتشغيل والأسماء والأنواع والمنطق.','# قراءة رسائل الخطأ وفهم أنواعها

## هدف الدرس
تقرأ رسالة الخطأ وتحدد نوع المشكلة قبل تعديل الكود.

## 1. Syntax Error
يعني أن الكود لا يتبع قواعد اللغة. مثال:
```python
print("Hello"
```
هناك قوس إغلاق مفقود.

## 2. NameError
يشير غالبًا إلى استخدام اسم غير معرّف أو مكتوب بشكل مختلف:
```python
score = 90
print(scores)
```
اسم scores غير موجود؛ الاسم المعرّف هو score.

## 3. TypeError
يحدث عندما لا تناسب العملية نوع البيانات:
```python
age = 14
print("Age: " + str(age))
```
نحوّل الرقم إلى نص قبل دمجه مع النص.

## 4. IndentationError
يظهر عندما تكون المسافات البادئة غير صحيحة:
```python
if score >= 50:
    print("Pass")
```
يجب أن يكون جسم الشرط مزاحًا إلى الداخل.

## 5. IndexError وKeyError
IndexError عند طلب فهرس غير موجود في قائمة. KeyError عند طلب مفتاح غير موجود في قاموس.

## 6. Runtime Error
خطأ يحدث أثناء تشغيل البرنامج، مثل محاولة القسمة على صفر أو فتح ملف غير موجود.

## 7. Logic Error
البرنامج يعمل لكن النتيجة خاطئة. قد يكون الشرط معكوسًا أو المعادلة غير صحيحة. لا تظهر دائمًا رسالة خطأ.

## طريقة القراءة
ابدأ باسم الخطأ، ثم اقرأ الرسالة، ثم حدد الملف ورقم السطر، وافحص السطر وما حوله.

## خلاصة
اسم الخطأ يعطيك اتجاه البحث، لكنه ليس بديلًا عن فهم الكود والسياق.',19,8,true,ARRAY['قراءة رسائل الخطأ وفهم أنواعها']::text[],ARRAY[]::text[]),
('tools-09-debugging-workflow','tools-foundations','منهجية Debugging خطوة بخطوة','استخدم خطوات ثابتة لعزل الخطأ وتتبع القيم وإصلاح السبب وإعادة الاختبار.','# منهجية Debugging خطوة بخطوة

## هدف الدرس
تتبع المشكلة بطريقة منظمة بدل تعديل أسطر عشوائيًا.

## 1. أعد إنتاج المشكلة
شغّل البرنامج بنفس المدخلات التي تظهر معها المشكلة. إذا لم تستطع إعادة إنتاجها، اجمع معلومات أكثر عن الخطوات والمدخلات.

## 2. اقرأ أول رسالة خطأ
ابدأ بأول خطأ ظاهر؛ قد تكون بقية الرسائل نتائج متتابعة له. سجّل نوع الخطأ ورقم السطر.

## 3. قلّص نطاق البحث
قسّم البرنامج إلى أجزاء صغيرة. افحص المدخلات أولًا، ثم المعالجة، ثم المخرجات. اسأل: في أي مرحلة ظهرت القيمة غير المتوقعة؟

## 4. تتبع المتغيرات
يمكن استخدام print مؤقتًا:
```python
price = 12
quantity = 3
print("DEBUG price:", price)
print("DEBUG quantity:", quantity)
total = price * quantity
print("DEBUG total:", total)
```
في محرر يدعم Debugger، استخدم breakpoint وتابع التنفيذ خطوة بخطوة.

## 5. غيّر شيئًا واحدًا
لا تعدّل خمسة أشياء في نفس الوقت. غيّر سببًا واحدًا محتملًا، ثم شغّل الاختبار نفسه.

## 6. تحقق من الإصلاح
جرّب المدخل الذي كشف المشكلة، ثم جرّب مدخلات أخرى حتى تتأكد أن الحل لم يكسر حالة مختلفة.

## 7. أزل أدوات التشخيص المؤقتة
بعد فهم المشكلة، احذف رسائل DEBUG غير المطلوبة، واترك تعليقات مفيدة فقط.

## خلاصة
Debugging عملية بحث واختبار: أعد المشكلة، حدد موضعها، تتبع القيم، عدّل سببًا واحدًا، ثم تحقق من الإصلاح.',20,9,true,ARRAY['منهجية Debugging خطوة بخطوة']::text[],ARRAY[]::text[]),
('tools-10-test-cases','tools-foundations','كتابة Test Cases واختبار الحالات الحدّية','اختبر الحل بمدخلات عادية وحدّية وغير متوقعة وقارن الناتج بالنتيجة المتوقعة.','# كتابة Test Cases واختبار الحالات الحدّية

## هدف الدرس
تكتب حالات اختبار واضحة وتفهم الفرق بين الناتج الفعلي والمتوقع.

## 1. ما Test Case؟
حالة اختبار تتضمن مدخلات محددة ونتيجة متوقعة. نقارن النتيجة الفعلية بالمتوقعة لمعرفة هل الحل يعمل كما ينبغي.

## 2. اختبر أكثر من نوع
في برنامج يحسب متوسط درجات:
- حالة عادية: 70 و80.
- حد أدنى: 0 و0.
- حد النجاح: 50 و50.
- قيمة حدية: 49 و50.
- مدخل غير صالح: نص بدل رقم، إذا كان البرنامج يستقبل إدخالًا من المستخدم.

## 3. جدول اختبار
| المدخلات | المتوقع | الغرض |
|---|---|---|
| 70, 80 | 75 | حالة عادية |
| 0, 0 | 0 | الحد الأدنى |
| 50, 50 | 50 | حد النجاح |
| 49, 50 | 49.5 | قرب الحد |

## 4. Assertions
في Python يمكن استخدام assert للتحقق من نتيجة:
```python
def average(a, b):
    return (a + b) / 2

assert average(70, 80) == 75
assert average(0, 0) == 0
```
إذا فشل الشرط، يظهر خطأ يساعدك على معرفة أن النتيجة غير مطابقة.

## 5. الاختبار ليس إثباتًا مطلقًا
نجاح بعض الحالات لا يعني أن البرنامج خالٍ من كل الأخطاء. اختر حالات تغطي المسارات المهمة والحدود المتوقعة.

## تدريب
اكتب ثلاث حالات اختبار لدالة تجمع رقمين: أعداد موجبة، وجود صفر، وأعداد سالبة.

## خلاصة
خطط للمدخلات والنتائج المتوقعة قبل التشغيل. اختبر الحالة المعتادة والحدود والمدخلات غير المتوقعة.',19,10,true,ARRAY['كتابة Test Cases واختبار الحالات الحدّية']::text[],ARRAY[]::text[])
on conflict (id) do nothing;

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cs-09-files-and-folders','أنشئ هيكل مشروعك الأول','اكتب شجرة مجلدات لمشروع Python يحتوي ملف main.py ومجلد src وملف README.md. ثم اكتب سطر Python يطبع Hello, DOMA!','# اكتب سطر Python هنا
','python',true,'[]'::jsonb,'["ابدأ بمجلد رئيسي واحد.","ضع main.py داخل src.","استخدم print لعرض رسالة الترحيب."]'::jsonb,'print("Hello, DOMA!")','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cs-09-files-and-folders','اختبار: تنظيم الملفات والمجلدات للمبرمج',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'أي امتداد يُستخدم غالبًا لملف Python؟','[".py",".html",".css"]'::jsonb,0,'امتداد ملفات Python المعتاد هو .py.',1
from public.programming_quizzes qz
where qz.lesson_id='cs-09-files-and-folders'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='أي امتداد يُستخدم غالبًا لملف Python؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما وظيفة المجلد؟','["تنظيم وتجميع الملفات","تشغيل المعالج","تغيير لغة لوحة المفاتيح"]'::jsonb,0,'المجلد يجمع الملفات والمجلدات لتنظيم المشروع.',2
from public.programming_quizzes qz
where qz.lesson_id='cs-09-files-and-folders'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما وظيفة المجلد؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ماذا يوضح المسار Path؟','["مكان الملف","لون الكود","سرعة البرنامج"]'::jsonb,0,'المسار يحدد موقع الملف داخل نظام الملفات.',3
from public.programming_quizzes qz
where qz.lesson_id='cs-09-files-and-folders'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ماذا يوضح المسار Path؟');

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cs-10-keyboard-layout','اكتب بيانات طالب بدقة','اكتب متغيرات student_name وage وscore ثم اطبعها. استخدم اسمًا إنجليزيًا ونصًا بين اقتباسين.','student_name = "Mona"
age = 14
score = 92

# اطبع القيم الثلاث
','python',true,'[]'::jsonb,'["اكتب أسماء المتغيرات بالإنجليزية.","ضع النص بين علامتي اقتباس مستقيمتين.","استخدم print لعرض القيم."]'::jsonb,'student_name = "Mona"
age = 14
score = 92
print(student_name, age, score)','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cs-10-keyboard-layout','اختبار: الكتابة على لوحة المفاتيح للمبرمج',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'هل student وStudent اسمان متطابقان في Python؟','["نعم","لا","يعتمد على قيمة المتغير"]'::jsonb,1,'Python تفرق بين الحروف الكبيرة والصغيرة.',1
from public.programming_quizzes qz
where qz.lesson_id='cs-10-keyboard-layout'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='هل student وStudent اسمان متطابقان في Python؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما الاسم الأفضل لمتغير يخزن اسم الطالب؟','["student name","student_name","Student-Name"]'::jsonb,1,'الشرطة السفلية مناسبة داخل أسماء المتغيرات في Python.',2
from public.programming_quizzes qz
where qz.lesson_id='cs-10-keyboard-layout'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما الاسم الأفضل لمتغير يخزن اسم الطالب؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ماذا تفعل قبل كتابة الكود؟','["تتأكد من تخطيط اللغة الإنجليزية","تضغط كل المفاتيح","تغير امتداد الملف عشوائيًا"]'::jsonb,0,'تأكد من لغة الإدخال حتى لا تكتب أحرفًا غير مقصودة.',3
from public.programming_quizzes qz
where qz.lesson_id='cs-10-keyboard-layout'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ماذا تفعل قبل كتابة الكود؟');

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cs-11-programming-symbols','تدريب الرموز في Python','أنشئ قائمة scores من 70 و80 و90، واحسب المجموع باستخدام sum ثم اطبع Total: متبوعًا بالناتج.','scores = [70, 80, 90]
# احسب المجموع
# اطبع Total
','python',true,'[]'::jsonb,'["القائمة تستخدم [ ].","استخدم sum(scores) لحساب المجموع.","ضع النص بين اقتباسين مستقيمين."]'::jsonb,'scores = [70, 80, 90]
total = sum(scores)
print("Total:", total)','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cs-11-programming-symbols','اختبار: رموز البرمجة والأقواس وعلامات الترقيم',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'أي أقواس تُستخدم عادةً لإنشاء قائمة Python؟','["( )","[ ]","{ }"]'::jsonb,1,'القائمة في Python تُكتب بين أقواس مربعة.',1
from public.programming_quizzes qz
where qz.lesson_id='cs-11-programming-symbols'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='أي أقواس تُستخدم عادةً لإنشاء قائمة Python؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما الفرق بين = و ==؟','["لا فرق","= للإسناد و== للمقارنة","= للمقارنة و== للطباعة"]'::jsonb,1,'علامة واحدة تسند قيمة، وعلامتان تقارنان قيمتين.',2
from public.programming_quizzes qz
where qz.lesson_id='cs-11-programming-symbols'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما الفرق بين = و ==؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما الرمز الذي يبدأ التعليق في Python؟','["#",";","@"]'::jsonb,0,'يبدأ تعليق Python بالرمز #.',3
from public.programming_quizzes qz
where qz.lesson_id='cs-11-programming-symbols'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما الرمز الذي يبدأ التعليق في Python؟');

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cs-12-code-editor-workflow','أول برنامج من المحرر','اكتب برنامج Python يطبع سطرين: Welcome to DOMA وI can write code.','# اكتب أمرَي الطباعة هنا
','python',true,'[]'::jsonb,'["كل أمر print يطبع سطرًا.","النص يوضع بين اقتباسين.","احفظ الملف بامتداد .py."]'::jsonb,'print("Welcome to DOMA")
print("I can write code")','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cs-12-code-editor-workflow','اختبار: استخدام محرر الكود وكتابة أول برنامج',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما الاختصار الشائع لحفظ الملف؟','["Ctrl + S","Ctrl + P","Alt + F4"]'::jsonb,0,'Ctrl + S يحفظ الملف في معظم المحررات.',1
from public.programming_quizzes qz
where qz.lesson_id='cs-12-code-editor-workflow'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما الاختصار الشائع لحفظ الملف؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما وظيفة محرر الكود؟','["كتابة وتنظيم ملفات الكود","تغيير مكونات الكمبيوتر","توفير اتصال الإنترنت"]'::jsonb,0,'محرر الكود مخصص لكتابة ومراجعة الملفات البرمجية.',2
from public.programming_quizzes qz
where qz.lesson_id='cs-12-code-editor-workflow'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما وظيفة محرر الكود؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ماذا تفعل بعد تعديل الكود؟','["تتجاهل التعديل","تحفظ ثم تعيد التشغيل والاختبار","تحذف المشروع"]'::jsonb,1,'احفظ التعديل ثم شغّل البرنامج للتحقق من النتيجة.',3
from public.programming_quizzes qz
where qz.lesson_id='cs-12-code-editor-workflow'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ماذا تفعل بعد تعديل الكود؟');

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('cs-13-project-structure','مخطط Grade Calculator','اكتب برنامجًا يحسب متوسط الدرجات 70 و80 و90، ثم يطبع Average: 80.0 وPass. استخدم متغيرات وشرطًا.','grades = [70, 80, 90]
# احسب المتوسط
# اطبع المتوسط
# افحص النجاح
','python',true,'[]'::jsonb,'["المتوسط هو المجموع مقسومًا على عدد الدرجات.","استخدم len(grades) لمعرفة عدد القيم.","اختبر average >= 50."]'::jsonb,'grades = [70, 80, 90]
average = sum(grades) / len(grades)
print("Average:", average)
if average >= 50:
    print("Pass")
else:
    print("Review")','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('cs-13-project-structure','اختبار: إنشاء مشروع صغير منظم',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما فائدة README؟','["شرح المشروع وطريقة تشغيله","تشغيل المعالج","استبدال ملفات الكود"]'::jsonb,0,'README يقدم وصفًا وتعليمات للمشروع.',1
from public.programming_quizzes qz
where qz.lesson_id='cs-13-project-structure'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما فائدة README؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'لماذا نقسم المشروع إلى مجلدات؟','["لتنظيم الملفات","لجعل الكود أطول","لإخفاء الأخطاء"]'::jsonb,0,'التنظيم يجعل المشروع أسهل في التطوير والصيانة.',2
from public.programming_quizzes qz
where qz.lesson_id='cs-13-project-structure'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='لماذا نقسم المشروع إلى مجلدات؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما الذي يجب اختباره قبل تسليم المشروع؟','["حالة واحدة فقط","تشغيل المشروع من البداية وتجربة حالات مختلفة","اسم المجلد فقط"]'::jsonb,1,'اختبر المسار الأساسي والحالات المختلفة قبل التسليم.',3
from public.programming_quizzes qz
where qz.lesson_id='cs-13-project-structure'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما الذي يجب اختباره قبل تسليم المشروع؟');

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('tools-05-terminal-basics','اقرأ أوامر Terminal','اشرح باختصار وظيفة pwd وls وmkdir، ثم اكتب أمرًا ينشئ مجلدًا باسم practice.','# اكتب شرحك هنا
','python',true,'[]'::jsonb,'["pwd للمسار الحالي.","ls لعرض المحتويات.","mkdir لإنشاء مجلد."]'::jsonb,'pwd يعرض المجلد الحالي.
ls يعرض الملفات والمجلدات.
mkdir practice ينشئ مجلد practice.','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('tools-05-terminal-basics','اختبار: ما هو Terminal وسطر الأوامر؟',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما وظيفة Terminal؟','["إدخال أوامر نصية للنظام","تصميم الصور فقط","تخزين كلمات المرور"]'::jsonb,0,'الطرفية تسمح بإدخال أوامر نصية.',1
from public.programming_quizzes qz
where qz.lesson_id='tools-05-terminal-basics'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما وظيفة Terminal؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ماذا يفعل mkdir practice؟','["ينشئ مجلدًا باسم practice","يحذف المجلد","يشغّل Python"]'::jsonb,0,'mkdir اختصار لإنشاء مجلد.',2
from public.programming_quizzes qz
where qz.lesson_id='tools-05-terminal-basics'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ماذا يفعل mkdir practice؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'لماذا نتحقق من المجلد الحالي؟','["لأن الأوامر النسبية تعتمد عليه","لتغيير حجم الشاشة","لتسريع لوحة المفاتيح"]'::jsonb,0,'المجلد الحالي يحدد مكان تنفيذ الأوامر المتعلقة بالملفات.',3
from public.programming_quizzes qz
where qz.lesson_id='tools-05-terminal-basics'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='لماذا نتحقق من المجلد الحالي؟');

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('tools-06-terminal-navigation','خطوات تنظيم مجلد تدريب','اكتب تسلسل الأوامر الذي يعرض المسار، وينشئ مجلد practice، ويدخل إليه، ثم ينشئ ملف hello.py. وضّح أن touch يختلف توفره حسب النظام.','# اكتب الأوامر بالترتيب
','python',true,'[]'::jsonb,'["ابدأ بعرض المسار.","أنشئ المجلد قبل محاولة الدخول إليه.","touch مثال شائع في Linux وmacOS."]'::jsonb,'pwd
mkdir practice
cd practice
touch hello.py','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('tools-06-terminal-navigation','اختبار: التنقل بين المجلدات وإدارة الملفات',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما الأمر الذي يعرض محتويات مجلد في Linux؟','["ls","pwd","mkdir"]'::jsonb,0,'ls يعرض الملفات والمجلدات.',1
from public.programming_quizzes qz
where qz.lesson_id='tools-06-terminal-navigation'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما الأمر الذي يعرض محتويات مجلد في Linux؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما معنى cd ..؟','["الانتقال إلى المجلد الأعلى","إنشاء مجلد","عرض إصدار Python"]'::jsonb,0,'النقطتان تعنيان المجلد الأب.',2
from public.programming_quizzes qz
where qz.lesson_id='tools-06-terminal-navigation'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما معنى cd ..؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'إذا ظهر No such file or directory، ماذا تفحص؟','["اسم الملف والمسار والمجلد الحالي","لون نافذة الطرفية","حجم الخط"]'::jsonb,0,'غالبًا الاسم أو المسار غير صحيح أو غير موجود.',3
from public.programming_quizzes qz
where qz.lesson_id='tools-06-terminal-navigation'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='إذا ظهر No such file or directory، ماذا تفحص؟');

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('tools-07-run-programs','جهّز أمر تشغيل Python','لديك ملف اسمه app.py في مجلد المشروع. اكتب ثلاثة احتمالات شائعة لتشغيله حسب النظام: python وpython3 وpy.','# اكتب الأوامر هنا
','python',true,'[]'::jsonb,'["اسم الملف يأتي بعد أمر تشغيل Python.","قد يختلف اسم الأمر حسب نظام التشغيل.","تأكد أن الطرفية داخل مجلد الملف."]'::jsonb,'python app.py
python3 app.py
py app.py','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('tools-07-run-programs','اختبار: تشغيل البرامج من الطرفية',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما الذي يجب التأكد منه قبل تشغيل hello.py؟','["أن الملف محفوظ في المجلد الحالي","أن اسم الشاشة تغير","أن المتصفح مغلق"]'::jsonb,0,'يجب أن يكون الملف موجودًا في المجلد الذي تعمل منه أو تستخدم مساره.',1
from public.programming_quizzes qz
where qz.lesson_id='tools-07-run-programs'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما الذي يجب التأكد منه قبل تشغيل hello.py؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'أي أمر قد يشغّل ملف Python؟','["python hello.py","open hello.py in browser فقط","mkdir hello.py"]'::jsonb,0,'python متبوعًا باسم الملف هو صيغة تشغيل شائعة.',2
from public.programming_quizzes qz
where qz.lesson_id='tools-07-run-programs'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='أي أمر قد يشغّل ملف Python؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'إذا لم يتعرف النظام على python، ما الاحتمال؟','["Python غير مثبت أو غير مضاف للمسار أو الأمر مختلف","الملف يحتوي تعليقًا","الشاشة صغيرة"]'::jsonb,0,'قد تحتاج إلى تثبيت بيئة Python أو إعداد PATH أو استخدام اسم الأمر البديل.',3
from public.programming_quizzes qz
where qz.lesson_id='tools-07-run-programs'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='إذا لم يتعرف النظام على python، ما الاحتمال؟');

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('tools-08-understand-errors','صنّف رسائل الخطأ','صنّف الأمثلة: قوس ناقص، متغير غير معروف، جمع نص ورقم، مسافة بادئة خاطئة، ومعادلة تعطي نتيجة غير صحيحة.','# اكتب نوع كل مشكلة
','python',true,'[]'::jsonb,'["Syntax مرتبط بقواعد الكتابة.","NameError متعلق بالأسماء.","Logic Error قد لا يعرض رسالة خطأ."]'::jsonb,'قوس ناقص: SyntaxError
متغير غير معروف: NameError
عملية بين أنواع غير مناسبة: TypeError
مسافة بادئة خاطئة: IndentationError
نتيجة خاطئة مع استمرار التشغيل: Logic Error','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('tools-08-understand-errors','اختبار: قراءة رسائل الخطأ وفهم أنواعها',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'أي خطأ يرتبط غالبًا بقوس أو اقتباس مفقود؟','["SyntaxError","NameError","IndexError"]'::jsonb,0,'SyntaxError يعني أن صياغة الكود غير صحيحة.',1
from public.programming_quizzes qz
where qz.lesson_id='tools-08-understand-errors'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='أي خطأ يرتبط غالبًا بقوس أو اقتباس مفقود؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'الكود يعمل لكنه يعطي مجموعًا خاطئًا. ما نوع المشكلة؟','["Logic Error","SyntaxError دائمًا","IndentationError"]'::jsonb,0,'خطأ المنطق قد ينتج نتيجة غير صحيحة دون توقف البرنامج.',2
from public.programming_quizzes qz
where qz.lesson_id='tools-08-understand-errors'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='الكود يعمل لكنه يعطي مجموعًا خاطئًا. ما نوع المشكلة؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'أي خطأ يشير غالبًا إلى اسم متغير غير معروف؟','["NameError","TypeError","IndexError"]'::jsonb,0,'NameError يحدث عندما لا يستطيع Python العثور على الاسم.',3
from public.programming_quizzes qz
where qz.lesson_id='tools-08-understand-errors'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='أي خطأ يشير غالبًا إلى اسم متغير غير معروف؟');

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('tools-09-debugging-workflow','تتبّع خطأ في حساب الإجمالي','الكود التالي يعطي إجماليًا غير صحيح لأن quantity لم تُستخدم. أصلح الحساب وأضف رسائل DEBUG توضح السعر والكمية والإجمالي.','price = 20
quantity = 3
total = price  # أصلح هذا السطر
print("Total:", total)
','python',true,'[]'::jsonb,'["راجع العملية المطلوبة لحساب إجمالي السعر.","الإجمالي يساوي السعر مضروبًا في الكمية.","اطبع القيم قبل وبعد العملية."]'::jsonb,'price = 20
quantity = 3
print("DEBUG price:", price)
print("DEBUG quantity:", quantity)
total = price * quantity
print("DEBUG total:", total)
print("Total:", total)','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('tools-09-debugging-workflow','اختبار: منهجية Debugging خطوة بخطوة',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما أول خطوة جيدة عند تصحيح خطأ؟','["إعادة إنتاج المشكلة","حذف المشروع","تغيير عدة أسطر عشوائيًا"]'::jsonb,0,'إعادة إنتاج المشكلة تساعدك على معرفة الظروف التي تسببها.',1
from public.programming_quizzes qz
where qz.lesson_id='tools-09-debugging-workflow'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما أول خطوة جيدة عند تصحيح خطأ؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'لماذا نغيّر شيئًا واحدًا في كل مرة؟','["حتى نعرف أي تغيير أثر على النتيجة","لزيادة عدد الأسطر","لمنع حفظ الملف"]'::jsonb,0,'التغيير المنفرد يجعل معرفة السبب أسهل.',2
from public.programming_quizzes qz
where qz.lesson_id='tools-09-debugging-workflow'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='لماذا نغيّر شيئًا واحدًا في كل مرة؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ماذا تفعل بعد إصلاح الخطأ؟','["تعيد الاختبار بحالات مختلفة","تتوقف عن الاختبار","تحذف الاختبارات"]'::jsonb,0,'يجب التأكد أن الإصلاح حل المشكلة ولم يسبب مشكلة أخرى.',3
from public.programming_quizzes qz
where qz.lesson_id='tools-09-debugging-workflow'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ماذا تفعل بعد إصلاح الخطأ؟');

insert into public.programming_exercises (lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values ('tools-10-test-cases','اختبر دالة الجمع','اكتب دالة add(a, b) ثم أضف ثلاثة اختبارات باستخدام assert: 2+3=5، 0+7=7، و-2+2=0.','def add(a, b):
    # أكمل الدالة
    pass

# أضف اختبارات assert
','python',true,'[]'::jsonb,'["الدالة تعيد a + b.","استخدم assert للمقارنة بالنتيجة المتوقعة.","اختبر الصفر والأعداد السالبة أيضًا."]'::jsonb,'def add(a, b):
    return a + b

assert add(2, 3) == 5
assert add(0, 7) == 7
assert add(-2, 2) == 0
print("All tests passed")','[{"criterion":"وضوح الحل","weight":30},{"criterion":"صحة النتيجة","weight":50},{"criterion":"تنسيق الكود","weight":20}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values ('tools-10-test-cases','اختبار: كتابة Test Cases واختبار الحالات الحدّية',70,true)
on conflict (lesson_id) do nothing;
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ما الذي تحتويه Test Case؟','["مدخلات ونتيجة متوقعة","اسم المبرمج فقط","لون المحرر"]'::jsonb,0,'حالة الاختبار تحدد مدخلات ونتيجة متوقعة.',1
from public.programming_quizzes qz
where qz.lesson_id='tools-10-test-cases'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ما الذي تحتويه Test Case؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'لماذا نختبر القيم الحدّية؟','["لأن الأخطاء قد تظهر قرب الحدود","لأنها تجعل الكود أطول","لأنها تلغي الحاجة إلى الاختبار"]'::jsonb,0,'القيم الحدية تكشف أخطاء المقارنات والحسابات.',2
from public.programming_quizzes qz
where qz.lesson_id='tools-10-test-cases'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='لماذا نختبر القيم الحدّية؟');
insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select qz.id,'ماذا يفعل assert في Python؟','["يتحقق من صحة شرط","يطبع صورة","ينشئ مجلدًا"]'::jsonb,0,'assert يوقف التنفيذ بخطأ إذا كان الشرط غير صحيح.',3
from public.programming_quizzes qz
where qz.lesson_id='tools-10-test-cases'
and not exists(select 1 from public.programming_quiz_questions old where old.quiz_id=qz.id and old.prompt='ماذا يفعل assert في Python؟');
