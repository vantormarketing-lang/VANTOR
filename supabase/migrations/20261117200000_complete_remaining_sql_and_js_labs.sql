-- Complete the remaining SQL and JavaScript lesson expansions.
update public.programming_lessons set content_md=rtrim(content_md)||E'\n\n'||$last_0$## مختبر استعلامات: ابدأ صغيرًا ثم أضف شرطًا

افترض جدولًا اسمه `lessons` يحتوي id وtitle وlevel وpublished. ابدأ بعرض أعمدة محددة:
```sql
SELECT id, title
FROM lessons;
```
ثم أضف شرطًا:
```sql
SELECT id, title
FROM lessons
WHERE published = true
ORDER BY title ASC;
```
استخدم `LIMIT` عند استكشاف جدول كبير، ولا تستخدم `SELECT *` في كل استعلام دون حاجة.

### تحقق من النتيجة
قبل تشغيل الاستعلام، توقع عدد الصفوف والأعمدة. جرّب شرطًا لا يطابق أي صف، ثم قيمة غير موجودة، ولاحظ الفرق بين نتيجة فارغة وخطأ SQL.

### معيار الإتقان
تستطيع اختيار الأعمدة والصفوف المطلوبة، وترتيبها، وشرح كيف يؤثر WHERE وORDER BY وLIMIT في النتيجة.$last_0$,updated_at=now() where id='backend-03-sql-select' and published=true and content_md not like '%## مختبر استعلامات:%' and content_md not like '%## مختبر معاملات:%' and content_md not like '%## مختبر: اختر الحلقة المناسبة%';
update public.programming_lessons set content_md=rtrim(content_md)||E'\n\n'||$last_1$## مختبر معاملات: افهم أثر كل عملية

تدرّب في قاعدة بيانات محلية أو بيئة تجريبية ببيانات وهمية فقط. قبل UPDATE أو DELETE شغّل SELECT بنفس شرط WHERE لتعرف الصفوف التي ستتأثر.

```sql
BEGIN;
UPDATE tasks
SET completed = true
WHERE id = 12;
SELECT id, completed
FROM tasks
WHERE id = 12;
ROLLBACK;
```
في هذا المثال نراجع التغيير ثم نلغيه بالتراجع عن المعاملة. لا تستخدم المثال على بيانات إنتاج، ولا تنفذ تعديلًا واسعًا دون مراجعة الشرط.

### قواعد مهمة
- INSERT يضيف سجلًا ويجب احترام القيود.
- UPDATE يغيّر سجلات مطابقة للشرط.
- DELETE يزيل سجلات مطابقة للشرط.
- المعاملة تجمع تغييرات مترابطة وتتيح COMMIT أو ROLLBACK.
- المفاتيح والقيود تمنع حالات غير متسقة.

### معيار الإتقان
تستطيع تحديد السجلات المتأثرة قبل التعديل، وتشرح الفرق بين COMMIT وROLLBACK، وتستخدم بيئة تدريب عند تعلم عمليات الكتابة.$last_1$,updated_at=now() where id='backend-04-sql-insert-update-delete' and published=true and content_md not like '%## مختبر استعلامات:%' and content_md not like '%## مختبر معاملات:%' and content_md not like '%## مختبر: اختر الحلقة المناسبة%';
update public.programming_lessons set content_md=rtrim(content_md)||E'\n\n'||$last_2$## مختبر: اختر الحلقة المناسبة

استخدم `for` عندما يكون لديك عدد مرات أو نطاق واضح، و`for...of` للمرور على قيم مصفوفة، و`while` عندما يستمر التكرار ما دام شرط معين صحيحًا.

```javascript
const lessons = ["HTML", "CSS", "JavaScript"];
for (const lesson of lessons) {
  console.log(lesson);
}
```

### تجنب الحلقة غير المنتهية
إذا استخدمت while، تأكد أن هناك قيمة تتغير أو شرطًا يمكن أن يصبح false. اكتب قبل التشغيل: ما قيمة البداية؟ ما الذي يتغير؟ ما شرط التوقف؟ جرّب قائمة فارغة أيضًا.

### تحدٍ
احسب عدد الدرجات التي تساوي حد النجاح أو تتجاوزه، ثم اختبر مصفوفة فارغة ومصفوفة تحتوي عنصرًا واحدًا.

### معيار الإتقان
تستطيع شرح عدد مرات تنفيذ الحلقة، وتختار نوعًا مناسبًا، وتمنع التكرار غير المنتهي أو الوصول إلى عنصر غير موجود.$last_2$,updated_at=now() where id='web-11-js-loops' and published=true and content_md not like '%## مختبر استعلامات:%' and content_md not like '%## مختبر معاملات:%' and content_md not like '%## مختبر: اختر الحلقة المناسبة%';
