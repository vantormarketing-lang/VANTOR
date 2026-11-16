-- Complete the web, tooling, backend and project workflow paths.
-- Additive only: preserve existing tracks, lessons and student progress.

insert into public.programming_tracks (id,title,subtitle,description,sort_order,published)
values
('web-development','Web Development','HTML وCSS وJavaScript من الصفر','ابنِ صفحات ومواقع تفاعلية وافهم كيف يعمل الويب.',12,true),
('developer-workflow','Developer Tools & Workflow','Git وGitHub والاختبار وإدارة المشاريع','تعلم أدوات المطور وتنظيم العمل ومراجعة التغييرات.',13,true),
('backend-foundations','Backend & APIs','HTTP وواجهات API وقواعد البيانات وأساسيات الأمان','افهم ما يحدث خلف واجهة الموقع وكيف تتواصل التطبيقات مع البيانات.',14,true)
on conflict (id) do nothing;

insert into public.programming_modules (id,track_id,title,description,sort_order,published,level,prerequisites)
values
('web-html','web-development','HTML وبناء الصفحات','بنية المستند والعناصر الدلالية والروابط والصور والنماذج.',1,true,'beginner',ARRAY['cs-start-here']::text[]),
('web-css','web-development','CSS والتصميم المتجاوب','الألوان والمسافات والتخطيط وFlexbox وGrid والشاشات المختلفة.',2,true,'beginner',ARRAY['web-html']::text[]),
('web-js','web-development','JavaScript والتفاعل','المتغيرات والدوال وDOM والأحداث والبيانات غير المتزامنة.',3,true,'beginner',ARRAY['python-foundations']::text[]),
('workflow-foundations','developer-workflow','أدوات المطور وإدارة الإصدارات','Git وGitHub والاختبارات وقراءة التوثيق والعمل المنظم.',1,true,'beginner',ARRAY['cs-start-here']::text[]),
('backend-web','backend-foundations','كيف يعمل الويب من الخلف؟','HTTP وJSON وREST وقواعد البيانات ومبادئ حماية التطبيقات.',1,true,'beginner',ARRAY['web-js']::text[])
on conflict (id) do nothing;

insert into public.programming_lessons
(id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites)
values
('web-01-html-structure','web-html','أول صفحة HTML وبنية المستند','أنشئ صفحة HTML صحيحة وافهم دور العناصر الأساسية.','# أول صفحة HTML وبنية المستند

## هدف الدرس
تكتب صفحة ويب بسيطة وتفهم كيف يقرأ المتصفح عناصرها.

## 1. ما HTML؟
HTML لغة ترميز تصف بنية المحتوى: العناوين والفقرات والروابط والصور والقوائم. هيكل الصفحة ليس مسؤولًا وحده عن الألوان أو التفاعل.

## 2. الهيكل الأساسي
```html
<!doctype html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>صفحتي الأولى</title>
</head>
<body>
  <h1>مرحبًا!</h1>
  <p>أنا أتعلم تطوير الويب.</p>
</body>
</html>
```

## 3. فهم العناصر
- `<!doctype html>` يحدد مستند HTML حديثًا.
- `html` يحتوي المستند.
- `head` بيانات الصفحة وإعداداتها.
- `title` عنوان علامة التبويب.
- `body` المحتوى الظاهر.
- `h1` عنوان رئيسي و`p` فقرة.

## 4. العناصر المتداخلة
ضع العنصر داخل العنصر الذي يحتويه، وأغلق العناصر بالترتيب الصحيح. لا تترك وسومًا مفتوحة دون سبب.

## 5. افتح الصفحة
احفظ الملف باسم `index.html` ثم افتحه في المتصفح. عند التعديل احفظ وأعد تحميل الصفحة.

## تطبيق
أنشئ صفحة بعنوان DOMA، وعنوانًا رئيسيًا وفقرة تعرف فيها بنفسك ورابطًا إلى موقع تعليمي موثوق.

## خلاصة
HTML تصف معنى المحتوى وبنيته. ابدأ بهيكل صحيح ثم أضف العناصر تدريجيًا.',18,1,true,ARRAY['إنشاء مستند HTML صحيح','تمييز head عن body','استخدام العناوين والفقرات والروابط']::text[],ARRAY[]::text[]),

('web-02-semantic-forms','web-html','العناصر الدلالية والنماذج','استخدم عناصر ذات معنى وأنشئ نموذجًا واضحًا مع تسميات وحقول مناسبة.','# العناصر الدلالية والنماذج

## لماذا الدلالة مهمة؟
العنصر الدلالي يوضح وظيفة المحتوى للمتصفح وأدوات المساعدة والمطورين. استخدم `header` للرأس و`nav` للتنقل و`main` للمحتوى الأساسي و`section` لقسم و`footer` للتذييل.

## نموذج بسيط
```html
<form>
  <label for="student-name">اسم الطالب</label>
  <input id="student-name" name="studentName" type="text" required>

  <label for="student-email">البريد الإلكتروني</label>
  <input id="student-email" name="email" type="email" required>

  <button type="submit">إرسال</button>
</form>
```

## اربط Label بالحقل
يجب أن تتطابق قيمة `for` مع `id` للحقل. هذا يجعل الضغط على التسمية يركز الحقل ويساعد قارئات الشاشة.

## أنواع الحقول
استخدم `email` للبريد و`number` للأرقام و`password` لكلمات المرور و`checkbox` للاختيار. اختر النوع وفق البيانات المطلوبة.

## تحقق أساسي
الخاصية `required` تطلب إدخال قيمة، لكن تحقق المتصفح لا يغني عن التحقق على الخادم عند إرسال بيانات حقيقية.

## تطبيق
أنشئ نموذج تسجيل تجريبيًا للاسم والبريد والصف الدراسي، مع Label لكل حقل وزر إرسال.

## خلاصة
العناصر الدلالية والنماذج الواضحة تجعل الصفحة أسهل في الاستخدام والفهم.',18,2,true,ARRAY['استخدام العناصر الدلالية','إنشاء نموذج HTML','ربط Label بالحقول']::text[],ARRAY['web-01-html-structure']::text[]),

('web-03-css-foundations','web-css','أساسيات CSS وتنسيق الصفحة','اربط ملف CSS بصفحة HTML واستخدم المحددات والألوان والمسافات.','# أساسيات CSS وتنسيق الصفحة

## ما CSS؟
CSS تصف طريقة عرض عناصر HTML: اللون والخط والحجم والمسافات والحدود والتخطيط.

## ربط ملف التنسيق
داخل `head`:
```html
<link rel="stylesheet" href="style.css">
```

## أول قواعد CSS
```css
body {
  font-family: Arial, sans-serif;
  margin: 0;
  line-height: 1.7;
  background: #171222;
  color: #f7eddf;
}

h1 {
  color: #e3c17c;
  text-align: center;
}

.card {
  padding: 20px;
  margin: 16px;
  border-radius: 14px;
}
```

## المحددات
- `p` يختار كل عناصر الفقرة.
- `.card` يختار العناصر ذات class باسم card.
- `#main` يختار العنصر ذي id باسم main.

## نموذج الصندوق
كل عنصر يتكون بصريًا من content وpadding وborder وmargin. استخدم غالبًا:
```css
* { box-sizing: border-box; }
```
لتسهيل حساب الأبعاد.

## التدرج في التعديل
غيّر خاصية واحدة، احفظ، راقب النتيجة، ثم انتقل للتالية. افحص أدوات المطور في المتصفح لمعرفة القاعدة المؤثرة.

## تطبيق
نسّق بطاقة تحتوي عنوانًا ووصفًا وزرًا، مع مسافات وحدود وألوان متناسقة.

## خلاصة
CSS تحول البنية إلى واجهة. افهم المحددات ونموذج الصندوق قبل التخطيطات المعقدة.',20,1,true,ARRAY['ربط CSS بصفحة HTML','كتابة المحددات والقواعد','فهم نموذج الصندوق']::text[],ARRAY['web-01-html-structure']::text[]),

('web-04-responsive-layout','web-css','Flexbox وGrid والتصميم المتجاوب','رتب العناصر في صفوف وأعمدة واجعل التصميم مناسبًا للهاتف والحاسوب.','# Flexbox وGrid والتصميم المتجاوب

## Flexbox
مناسب لترتيب عناصر في اتجاه واحد:
```css
.cards {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  align-items: stretch;
}
```

## CSS Grid
مناسب لتخطيط صفوف وأعمدة:
```css
.cards {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
}
```

## Media Queries
غيّر عدد الأعمدة عندما تضيق الشاشة:
```css
@media (max-width: 700px) {
  .cards {
    grid-template-columns: 1fr;
  }
}
```

## مبادئ الهاتف أولًا
ابدأ بتخطيط بسيط يناسب الشاشة الصغيرة، ثم أضف تحسينات للشاشات الأوسع. تجنب عرضًا ثابتًا يجبر المستخدم على التمرير أفقيًا.

## اختبر بنفسك
استخدم أدوات المطور في المتصفح لتجربة عرض الهاتف واللوحي والحاسوب. افحص التفاف النص والأزرار والصور.

## تطبيق
أنشئ شبكة من ثلاث بطاقات على الشاشة الواسعة، وتتحول إلى عمود واحد على الهاتف.

## خلاصة
Flexbox لمحور واحد، وGrid للشبكات، وMedia Queries للتكيف مع أحجام الشاشات.',20,2,true,ARRAY['استخدام Flexbox','بناء شبكة Grid','كتابة Media Query']::text[],ARRAY['web-03-css-foundations']::text[]),

('web-05-javascript-basics','web-js','أساسيات JavaScript في المتصفح','اكتب المتغيرات والدوال والشروط والحلقات واربط JavaScript بالصفحة.','# أساسيات JavaScript في المتصفح

## دور JavaScript
تضيف السلوك والتفاعل إلى صفحات الويب. يمكنها الاستجابة للنقر، وتحديث المحتوى، والتحقق المبدئي من المدخلات.

## ربط الملف
```html
<script src="app.js" defer></script>
```
استخدام `defer` يجعل المتصفح ينفذ الملف بعد تحليل HTML.

## المتغيرات والدوال
```javascript
const studentName = "Mona";
let score = 85;

function getResult(value) {
  if (value >= 50) {
    return "Pass";
  }
  return "Try again";
}

console.log(studentName, getResult(score));
```

## const وlet
استخدم `const` عندما لا تعيد إسناد المتغير، و`let` عندما تتغير قيمته. تجنب `var` في الأمثلة الحديثة للمبتدئين.

## المصفوفات والحلقات
```javascript
const topics = ["HTML", "CSS", "JavaScript"];
for (const topic of topics) {
  console.log(topic);
}
```

## أنواع البيانات
تعرف على String وNumber وBoolean وArray وObject وnull وundefined. استخدم `typeof` لفحص أنواع كثيرة من القيم.

## تطبيق
اكتب دالة تحول درجة إلى Pass أو Try again، ثم اطبع النتيجة لثلاث درجات مختلفة.

## خلاصة
تعلم المتغيرات والدوال والشروط أولًا، ثم استخدمها لإضافة سلوك لصفحاتك.',20,1,true,ARRAY['تعريف المتغيرات والدوال','استخدام الشروط والحلقات','تمييز أنواع البيانات الأساسية']::text[],ARRAY['python-foundations']::text[]),

('web-06-dom-events','web-js','DOM والأحداث والتفاعل مع المستخدم','حدد عناصر الصفحة وعدّل النصوص واستجب للنقر وإرسال النماذج.','# DOM والأحداث والتفاعل مع المستخدم

## ما DOM؟
يمثل المتصفح مستند HTML كشجرة من العناصر. تتيح JavaScript الوصول إلى هذه العناصر وتعديلها.

## تحديد عنصر
```javascript
const title = document.querySelector("#page-title");
title.textContent = "أهلًا بك";
```

## الاستجابة للنقر
```html
<button id="show-message">اعرض رسالة</button>
<p id="message"></p>
```
```javascript
const button = document.querySelector("#show-message");
const message = document.querySelector("#message");

button.addEventListener("click", () => {
  message.textContent = "أحسنت! الزر يعمل.";
});
```

## أحداث شائعة
click للنقر، input لتغير قيمة حقل، submit لإرسال نموذج، change لتغير اختيار.

## التعامل مع النموذج
عند الاستماع إلى submit، قد تحتاج إلى `event.preventDefault()` لمنع إعادة تحميل الصفحة أثناء معالجة تدريب محلي. لا تستخدم هذا وحده لإرسال بيانات حقيقية أو حمايتها.

## سلامة عرض النص
استخدم `textContent` للنص الذي أدخله المستخدم. لا تضع نصًا غير موثوق مباشرة في `innerHTML`؛ فقد يؤدي ذلك إلى إدخال HTML غير مقصود.

## تطبيق
أنشئ زرًا يزيد عدادًا ظاهرًا على الصفحة في كل مرة يتم الضغط عليه.

## خلاصة
DOM يتيح الوصول إلى الصفحة، وEvents تربط تصرف المستخدم بالكود.',20,2,true,ARRAY['استخدام querySelector','الاستماع إلى الأحداث','تحديث محتوى DOM بأمان']::text[],ARRAY['web-05-javascript-basics']::text[]),

('web-07-async-fetch-json','web-js','JSON وFetch والعمليات غير المتزامنة','افهم JSON وPromise وasync/await وكيف تتعامل مع استجابة API.','# JSON وFetch والعمليات غير المتزامنة

## ما JSON؟
صيغة نصية لتبادل البيانات. تشبه كائن JavaScript لكنها نص مستقل:
```json
{
  "name": "Mona",
  "score": 95,
  "active": true
}
```

## تحويل JSON
```javascript
const student = { name: "Mona", score: 95 };
const text = JSON.stringify(student);
const parsed = JSON.parse(text);
console.log(parsed.name);
```

## Fetch
```javascript
async function loadData() {
  try {
    const response = await fetch("/api/example");
    if (!response.ok) {
      throw new Error("Request failed: " + response.status);
    }
    const data = await response.json();
    console.log(data);
  } catch (error) {
    console.error("تعذر تحميل البيانات:", error);
  }
}
```

## لماذا await؟
الشبكة قد تستغرق وقتًا. `await` تنتظر نتيجة Promise داخل دالة async دون تجميد واجهة المستخدم.

## افحص الاستجابة
لا تفترض أن كل طلب نجح. افحص status، وتعامل مع انقطاع الشبكة والبيانات غير المتوقعة وحالات التحميل.

## ملاحظة أمان
لا تضع مفاتيح سرية أو كلمات مرور داخل JavaScript الذي يصل إلى المتصفح. أي قيمة في كود الواجهة يمكن للمستخدم رؤيتها.

## تطبيق
اكتب دالة async تجلب بيانات من API تدريبي عام، وتعرض رسالة واضحة عند الفشل.

## خلاصة
JSON شكل بيانات، وFetch يرسل الطلبات، وasync/await يجعل التعامل مع النتائج أوضح.',22,3,true,ARRAY['قراءة JSON','استخدام Fetch وasync/await','معالجة أخطاء الشبكة']::text[],ARRAY['web-06-dom-events']::text[]),

('workflow-01-git-basics','workflow-foundations','Git: حفظ تاريخ تغييرات المشروع','افهم المستودع واللقطات والفروع واستخدم أوامر Git الأساسية بأمان.','# Git: حفظ تاريخ تغييرات المشروع

## ما Git؟
نظام Version Control يسجل تغييرات الملفات حتى تستطيع مراجعة تاريخ المشروع والرجوع إلى نسخة سابقة.

## مفاهيم أساسية
- Repository: مجلد يتتبع Git تغييراته.
- Commit: لقطة موصوفة لحالة الملفات.
- Branch: خط عمل مستقل للتغييرات.
- Remote: مستودع بعيد مثل مستودع GitHub.

## دورة عمل أساسية
```bash
git status
git add index.html
git commit -m "Add homepage"
```
الأمر الأول يعرض الحالة، والثاني يجهز الملف للّقطة، والثالث يسجلها.

## اقرأ الحالة قبل التغيير
استخدم `git status` كثيرًا لتعرف الملفات المعدلة وما تم تجهيزه. لا تنفذ أمرًا لا تفهم أثره على ملفاتك.

## رسائل Commit
اكتب رسالة قصيرة تصف التغيير، مثل `Fix lesson navigation` أو `Add responsive cards`.

## تطبيق
أنشئ مجلد تدريب، ابدأ مستودع Git محليًا، أضف ملف README، وسجل أول commit.

## خلاصة
Git يحفظ تاريخ العمل. افحص الحالة، جهز التغييرات المقصودة، ثم سجلها برسالة واضحة.',18,1,true,ARRAY['شرح Repository وCommit وBranch','استخدام status وadd وcommit','كتابة رسالة commit واضحة']::text[],ARRAY['cs-13-project-structure']::text[]),

('workflow-02-branches-github','workflow-foundations','الفروع وGitHub وPull Requests','استخدم فرعًا للتطوير وافهم Push وPull وPull Request ومراجعة التغيير.','# الفروع وGitHub وPull Requests

## لماذا نستخدم Branch؟
يسمح لك بتطوير ميزة دون تغيير الفرع الرئيسي مباشرة. بعد الانتهاء تراجع التغييرات وتدمجها وفق سياسة المشروع.

## أوامر مفيدة
```bash
git switch -c feature/profile-card
git status
git push -u origin feature/profile-card
```
هذه أمثلة تعليمية؛ تأكد من إعداد remote والصلاحيات قبل الدفع.

## GitHub
منصة لاستضافة المستودعات والتعاون. يمكن رفع فرع ثم فتح Pull Request لشرح التغيير ومراجعته قبل الدمج.

## Pull Request
اكتب ما الذي تغير ولماذا، وكيف اختبرته. راجع الملفات المتغيرة وتأكد من عدم تضمين أسرار أو ملفات غير لازمة.

## تعارض الدمج
قد يعدل شخصان الأسطر نفسها. اقرأ التعارض وافهم النسختين، ثم احتفظ بالحل الصحيح واختبره. لا تحذف علامات التعارض دون مراجعة المحتوى.

## تطبيق
أنشئ فرعًا لميزة صغيرة، عدّل README، ثم اكتب وصف Pull Request يشرح التغيير والاختبار.

## خلاصة
الفرع مساحة عمل، وPull Request مساحة مراجعة. لا تدمج تغييرًا لا تفهمه.',20,2,true,ARRAY['إنشاء فرع','شرح Push وPull Request','فهم تعارضات الدمج']::text[],ARRAY['workflow-01-git-basics']::text[]),

('workflow-03-testing-quality','workflow-foundations','جودة الكود والاختبارات والمراجعة','راجع قابلية القراءة واختبر الحالات المهمة واستخدم قائمة مراجعة قبل تسليم المشروع.','# جودة الكود والاختبارات والمراجعة

## الكود الجيد
ليس مجرد كود يعمل؛ يجب أن يكون مفهومًا ومنظمًا وقابلًا للتعديل. استخدم أسماء واضحة ودوال صغيرة وتجنب التكرار غير الضروري.

## أنواع الاختبارات
- Unit Test يختبر وحدة صغيرة مثل دالة.
- Integration Test يختبر تفاعل أكثر من جزء.
- Manual Test يتحقق من تجربة الاستخدام يدويًا.

## مثال Python
```python
def add(a, b):
    return a + b

assert add(2, 3) == 5
assert add(-1, 1) == 0
```

## قائمة مراجعة
1. هل يعمل المثال الأساسي؟
2. هل اختبرت القيم الحدية؟
3. هل أسماء المتغيرات مفهومة؟
4. هل أزلت رسائل التشخيص المؤقتة؟
5. هل توجد تعليمات تشغيل؟
6. هل أزلت أي أسرار أو بيانات شخصية؟

## مراجعة التغيير
اقرأ الفرق بين النسخة القديمة والجديدة. اسأل هل كل تعديل مطلوب؟ وهل يمكن أن يؤثر على وظيفة أخرى؟

## تطبيق
اكتب دالة خصم سعر، واختبر السعر العادي والصفر والقيمة السالبة، ثم أضف شرحًا لقرارك حول المدخل غير الصحيح.

## خلاصة
الاختبار والمراجعة جزء من البرمجة، وليسا خطوة شكلية بعد الانتهاء.',20,3,true,ARRAY['التمييز بين أنواع الاختبارات','كتابة Assertions','استخدام قائمة مراجعة']::text[],ARRAY['workflow-01-git-basics']::text[]),

('backend-01-http-web','backend-web','كيف يعمل الويب: HTTP والعميل والخادم','افهم المتصفح والخادم والطلب والاستجابة ورموز الحالة.','# كيف يعمل الويب: HTTP والعميل والخادم

## الصورة العامة
المتصفح Client يرسل طلبًا إلى Server. الخادم يعالج الطلب ويرسل Response. قد يحتوي الرد HTML أو JSON أو صورة أو رمز حالة.

## أجزاء الطلب
يتضمن HTTP method مثل GET أو POST، ومسارًا، وHeaders، وقد يحتوي Body.

## أشهر الطرق
- GET لقراءة مورد.
- POST لإرسال بيانات أو إنشاء مورد.
- PUT أو PATCH لتحديث مورد.
- DELETE لحذف مورد وفق صلاحيات النظام.

## رموز الحالة
- 200 نجاح.
- 201 تم الإنشاء.
- 400 طلب غير صالح.
- 401 يحتاج إلى مصادقة.
- 403 ممنوع.
- 404 غير موجود.
- 500 خطأ داخلي في الخادم.

## مثال تصوري
عند فتح صفحة، يطلب المتصفح موردًا. وعند إرسال نموذج، قد يرسل POST إلى مسار API. الخادم يتحقق من البيانات والصلاحيات قبل تنفيذ العملية.

## لا تثق بالواجهة وحدها
إخفاء زر في المتصفح لا يحمي العملية. يجب أن يتحقق الخادم من هوية المستخدم وصلاحيته لكل طلب حساس.

## تطبيق
ارسم تسلسلًا من أربع خطوات لطلب GET: المتصفح، الطلب، الخادم، الاستجابة. اكتب معنى ثلاثة رموز حالة.

## خلاصة
HTTP يحدد طريقة تبادل الطلبات والاستجابات بين العميل والخادم.',18,1,true,ARRAY['شرح Client وServer','تمييز HTTP methods','فهم رموز الحالة']::text[],ARRAY['web-07-async-fetch-json']::text[]),

('backend-02-rest-json','backend-web','تصميم API وREST وبيانات JSON','افهم الموارد والمسارات وصيغ JSON والتعامل مع أخطاء API.','# تصميم API وREST وبيانات JSON

## ما API؟
واجهة تسمح لبرنامج بالتعامل مع وظائف أو بيانات برنامج آخر من خلال عقد واضح للطلبات والاستجابات.

## الموارد والمسارات
يمكن تمثيل الطلاب كمورد:
- GET /api/students لقراءة القائمة.
- GET /api/students/12 لقراءة طالب.
- POST /api/students لإنشاء سجل وفق صلاحيات الخادم.

## استجابة JSON
```json
{
  "id": 12,
  "name": "Mona",
  "active": true
}
```

## تصميم واضح
استخدم أسماء موارد مفهومة، ورموز حالة صحيحة، ورسائل خطأ لا تكشف تفاصيل داخلية حساسة. وثّق الحقول المطلوبة وأنواعها.

## التحقق من البيانات
لا تفترض أن العميل أرسل JSON صحيحًا. تحقق من النوع والطول والقيم المسموح بها على الخادم، وأعد خطأ مناسبًا عند الفشل.

## تطبيق
صمم وصف API تدريبي لإدارة مهام: مسارات قراءة المهام وإضافة مهمة وتحديث حالتها، مع مثال JSON.

## خلاصة
API عقد بين أنظمة. صممه حول الموارد، ووثّق البيانات، وتحقق من المدخلات.',20,2,true,ARRAY['شرح API وREST','تصميم مسارات موارد','كتابة JSON صحيح']::text[],ARRAY['backend-01-http-web']::text[]),

('backend-03-databases-sql','backend-web','قواعد البيانات وSQL للمبتدئين','افهم الجداول والصفوف والمفاتيح واكتب استعلامات قراءة وإضافة وتحديث تدريبية.','# قواعد البيانات وSQL للمبتدئين

## ما قاعدة البيانات؟
نظام منظم لحفظ البيانات واسترجاعها. في قاعدة علائقية، تخزن البيانات في جداول تتكون من صفوف وأعمدة.

## مثال جدول Students
| id | name | grade |
|---|---|---|
| 1 | Mona | 2 |
| 2 | Omar | 3 |

## قراءة البيانات
```sql
SELECT name, grade
FROM students
WHERE grade = 2
ORDER BY name;
```

## إضافة وتحديث
```sql
INSERT INTO students (name, grade)
VALUES (''Sara'', 1);

UPDATE students
SET grade = 2
WHERE id = 3;
```

## المفاتيح
Primary Key يميز كل صف. Foreign Key يربط سجلًا بسجل في جدول آخر.

## قواعد مهمة
استخدم WHERE عند تحديث أو حذف صفوف محددة، واختبر الاستعلامات على بيانات تدريبية. لا تنفذ أوامر تعديل على قاعدة حقيقية دون نسخة احتياطية ومراجعة وصلاحية واضحة.

## تطبيق
صمم جدول Tasks يحوي id وtitle وcompleted، واكتب استعلامًا يعرض المهام غير المكتملة.

## خلاصة
SQL لغة للتعامل مع البيانات. ابدأ بالقراءة، وافهم المفاتيح والعلاقات قبل التعديلات.',22,3,true,ARRAY['شرح الجدول والصف والمفتاح','كتابة SELECT وWHERE','فهم INSERT وUPDATE']::text[],ARRAY['backend-02-rest-json']::text[]),

('backend-04-auth-security','backend-web','المصادقة والصلاحيات وحماية البيانات','افهم Authentication وAuthorization ومبادئ حماية حسابات المستخدمين.','# المصادقة والصلاحيات وحماية البيانات

## Authentication وAuthorization
Authentication: من أنت؟ Authorization: ما الذي يسمح لك بفعله؟ نجاح تسجيل الدخول لا يعني امتلاك صلاحية المدير.

## قواعد أساسية
- لا تخزن كلمات المرور كنص واضح.
- استخدم نظام مصادقة موثوقًا بدل اختراع نظام خاص.
- تحقق من الصلاحيات على الخادم في كل عملية حساسة.
- لا تضع مفاتيح سرية في كود الواجهة أو مستودع عام.
- اجمع أقل قدر لازم من بيانات المستخدم.

## جلسات الدخول
الجلسة أو الرمز يثبت هوية المستخدم للطلبات اللاحقة. يجب التعامل معه وفق إعدادات آمنة، وتجنب طباعته في السجلات أو مشاركته.

## التحقق من المدخلات
تحقق من الأنواع والأطوال والقيم المسموح بها. استخدم استعلامات مُعلمة Parameterized Queries بدل تركيب SQL من نصوص المستخدم.

## أخطاء شائعة
إخفاء زر المدير ليس حماية. والاعتماد على قيمة role أرسلها المتصفح ليس تحققًا. يجب قراءة الصلاحية من مصدر موثوق على الخادم.

## الخصوصية
لا تعرض بيانات طالب لآخر، ولا تسجل معلومات حساسة دون حاجة. استخدم بيانات وهمية أثناء التعلم والاختبار.

## تطبيق
اكتب قائمة تحقق من خمس نقاط لحماية نموذج تسجيل تجريبي، واشرح الفرق بين المصادقة والصلاحيات.

## خلاصة
الأمان جزء من التصميم من البداية. تحقق على الخادم، واحمِ الأسرار، وقلل البيانات.',22,4,true,ARRAY['تمييز المصادقة عن الصلاحيات','شرح التحقق على الخادم','ذكر قواعد حماية البيانات']::text[],ARRAY['backend-03-databases-sql']::text[]),

('project-01-plan-build-ship','workflow-foundations','مشروع التخرج: خطط وابنِ واختبر وسلّم','اجمع مهاراتك في مشروع ويب صغير بخطة واضحة واختبارات وتعليمات تشغيل.','# مشروع التخرج: خطط وابنِ واختبر وسلّم

## فكرة المشروع
أنشئ تطبيق قائمة مهام تعليمية. يجب أن يعرض المهام، ويسمح بإضافة مهمة وتغيير حالتها وحذفها من بيانات تدريبية محلية.

## المرحلة 1: التخطيط
اكتب المشكلة التي يحلها التطبيق، وحدد المستخدم، والوظائف الأساسية، وما لن تنفذه في النسخة الأولى.

## المرحلة 2: التصميم
ارسم تخطيطًا بسيطًا للشاشة. حدد حالات الواجهة: قائمة فارغة، قائمة بها مهام، تحميل، وخطأ.

## المرحلة 3: التنفيذ
ابدأ بـ HTML للبنية، وCSS للتصميم المتجاوب، وJavaScript للتفاعل. قسّم الكود إلى دوال صغيرة ذات أسماء واضحة.

## المرحلة 4: الاختبار
اختبر إضافة مهمة، وإكمالها، وحذفها، وإدخال نص فارغ، واستخدام التطبيق على شاشة صغيرة.

## المرحلة 5: التصحيح
سجل الخطأ وطريقة إعادة ظهوره، وحدد السبب، ثم أصلحه واختبر الحالة التي فشلت والحالات القريبة منها.

## المرحلة 6: التسليم
اكتب README يشرح الفكرة والميزات وطريقة التشغيل والاختبارات وما تعلمته. لا تضع أسرارًا أو بيانات شخصية في المشروع.

## معايير التقييم
- صحة الوظائف الأساسية.
- تنظيم الكود ووضوح الأسماء.
- سهولة الاستخدام والتصميم المتجاوب.
- جودة الاختبارات ومعالجة الحالات غير المتوقعة.
- توثيق واضح للمشروع.

## خلاصة
المبرمج لا يكتب كودًا فقط؛ يخطط ويبني ويختبر ويوثق ويحسن.',30,4,true,ARRAY['تخطيط مشروع متكامل','تنفيذ واجهة تفاعلية','اختبار وتوثيق المشروع']::text[],ARRAY['web-04-responsive-layout','web-07-async-fetch-json','workflow-03-testing-quality']::text[])
on conflict (id) do nothing;

-- Create a practical exercise and a three-question checkpoint for every new lesson.
insert into public.programming_exercises
(lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
select l.id,
       'تطبيق عملي: ' || l.title,
       'نفّذ بنفسك ما تعلمته في درس "' || l.title || '". اكتب الحل في مساحة التدريب، ثم راجع النتيجة وقارنها بأهداف الدرس. اشرح باختصار سبب اختيارك للحل.',
       case
         when l.id like 'web-0%' then '<!-- اكتب HTML هنا -->' 
         when l.id like 'workflow-%' then '# اكتب ملاحظاتك وأوامر Git التدريبية هنا' 
         when l.id like 'backend-%' then '-- اكتب استعلام SQL أو مثال JSON هنا'
         else '// اكتب الحل هنا'
       end,
       case when l.id in ('web-01-html-structure','web-02-semantic-forms') then 'html'
            when l.id in ('web-03-css-foundations','web-04-responsive-layout') then 'css'
            when l.id like 'web-%' then 'javascript'
            when l.id like 'workflow-%' then 'text'
            when l.id like 'backend-%' then 'sql'
            else 'javascript' end,
       true,'[]'::jsonb,
       jsonb_build_array('قسّم المطلوب إلى خطوات صغيرة.','راجع مثال الدرس قبل كتابة الحل.','اختبر حالة عادية وحالة حدّية.'),
       case
         when l.id='web-01-html-structure' then '<!doctype html><html lang="ar" dir="rtl"><head><meta charset="UTF-8"><title>DOMA</title></head><body><h1>مرحبًا</h1><p>أتعلم HTML.</p></body></html>'
         when l.id='web-02-semantic-forms' then '<form><label for="name">الاسم</label><input id="name" name="name" required><button type="submit">إرسال</button></form>'
         when l.id='web-03-css-foundations' then 'body { font-family: Arial, sans-serif; margin: 0; } .card { padding: 20px; border-radius: 12px; }'
         when l.id='web-04-responsive-layout' then '.cards { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px; } @media (max-width: 700px) { .cards { grid-template-columns: 1fr; } }'
         when l.id='web-05-javascript-basics' then 'function getResult(score) { return score >= 50 ? "Pass" : "Try again"; } console.log(getResult(85));'
         when l.id='web-06-dom-events' then 'document.querySelector("#btn").addEventListener("click", () => { document.querySelector("#message").textContent = "أحسنت"; });'
         when l.id='web-07-async-fetch-json' then 'async function load() { try { const r = await fetch("/api/example"); if (!r.ok) throw new Error("Request failed"); console.log(await r.json()); } catch (e) { console.error(e); } }'
         when l.id='workflow-01-git-basics' then 'git status\ngit add README.md\ngit commit -m "Add project README"'
         when l.id='workflow-02-branches-github' then 'git switch -c feature/my-change\ngit status\n# اكتب وصف Pull Request واضحًا'
         when l.id='workflow-03-testing-quality' then 'def add(a, b):\n    return a + b\n\nassert add(2, 3) == 5'
         when l.id='backend-01-http-web' then 'GET /api/tasks HTTP/1.1\nAccept: application/json'
         when l.id='backend-02-rest-json' then '{"id":1,"title":"Learn APIs","completed":false}'
         when l.id='backend-03-databases-sql' then 'SELECT id, title FROM tasks WHERE completed = false;'
         when l.id='backend-04-auth-security' then '-- تحقق من الهوية والصلاحية على الخادم قبل تنفيذ العملية'
         else 'ابدأ بكتابة خطة المشروع ثم نفّذ واختبر الوظائف الأساسية.'
       end,
       '[{"criterion":"صحة الفكرة والحل","weight":40},{"criterion":"وضوح وتنظيم العمل","weight":30},{"criterion":"الاختبار والتفسير","weight":30}]'::jsonb,
       'manual'
from public.programming_lessons l
where l.id in (
'web-01-html-structure','web-02-semantic-forms','web-03-css-foundations','web-04-responsive-layout',
'web-05-javascript-basics','web-06-dom-events','web-07-async-fetch-json',
'workflow-01-git-basics','workflow-02-branches-github','workflow-03-testing-quality',
'backend-01-http-web','backend-02-rest-json','backend-03-databases-sql','backend-04-auth-security',
'project-01-plan-build-ship'
)
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
select l.id,'اختبار: ' || l.title,70,true
from public.programming_lessons l
where l.id in (
'web-01-html-structure','web-02-semantic-forms','web-03-css-foundations','web-04-responsive-layout',
'web-05-javascript-basics','web-06-dom-events','web-07-async-fetch-json',
'workflow-01-git-basics','workflow-02-branches-github','workflow-03-testing-quality',
'backend-01-http-web','backend-02-rest-json','backend-03-databases-sql','backend-04-auth-security',
'project-01-plan-build-ship'
)
on conflict (lesson_id) do nothing;

insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select q.id, x.prompt, x.options::jsonb, x.correct_index, x.explanation, x.sort_order
from public.programming_quizzes q
join (values
('web-01-html-structure','ما وظيفة HTML؟','["وصف بنية المحتوى","إدارة قاعدة البيانات","تشغيل الخادم"]',0,'HTML تصف بنية عناصر الصفحة.',1),
('web-01-html-structure','أين يظهر المحتوى المرئي غالبًا؟','["body","head","title"]',0,'body يحتوي محتوى الصفحة.',2),
('web-01-html-structure','ما الامتداد الشائع لصفحة HTML؟','[".html",".py",".sql"]',0,'ملفات HTML تستخدم امتداد html.',3),
('web-02-semantic-forms','لماذا نربط label بالحقل؟','["لتسهيل الاستخدام والوصول","لتغيير لون الصفحة","لتشغيل JavaScript"]',0,'الربط يساعد المستخدم وقارئ الشاشة.',1),
('web-02-semantic-forms','أي عنصر يمثل المحتوى الأساسي؟','["main","footer","small"]',0,'main يحدد المحتوى الرئيسي.',2),
('web-02-semantic-forms','هل required يغني عن تحقق الخادم؟','["لا","نعم دائمًا","فقط على الهاتف"]',0,'يجب التحقق من البيانات على الخادم.',3),
('web-03-css-foundations','ما وظيفة CSS؟','["تنسيق العرض","تخزين البيانات","إدارة المستخدمين"]',0,'CSS تتحكم في المظهر والتخطيط.',1),
('web-03-css-foundations','أي محدد يختار class باسم card؟','[".card","#card","card()"]',0,'النقطة تستخدم لمحدد class.',2),
('web-03-css-foundations','ما أجزاء نموذج الصندوق؟','["المحتوى والحشو والحد والهامش","العنوان والرابط فقط","الخادم والعميل"]',0,'Box Model يتكون من content وpadding وborder وmargin.',3),
('web-04-responsive-layout','متى يكون Flexbox مناسبًا؟','["ترتيب بمحور واحد","إدارة قاعدة البيانات","تشفير كلمة المرور"]',0,'Flexbox مناسب لترتيب أحادي المحور.',1),
('web-04-responsive-layout','ما فائدة Media Query؟','["تغيير التنسيق حسب خصائص الشاشة","إنشاء جدول SQL","إرسال بريد"]',0,'تسمح بتطبيق قواعد عند شروط عرض محددة.',2),
('web-04-responsive-layout','ما المقصود بالتصميم المتجاوب؟','["واجهة تتكيف مع أحجام الشاشات","واجهة بلون واحد","صفحة بلا صور"]',0,'التخطيط يتكيف مع الهاتف والحاسوب.',3),
('web-05-javascript-basics','متى نستخدم const؟','["عندما لا نحتاج إعادة إسناد المتغير","لتعريف HTML","لإرسال طلب HTTP فقط"]',0,'const يمنع إعادة إسناد الربط.',1),
('web-05-javascript-basics','ما قيمة getResult(85) في المثال؟','["Pass","Try again","undefined"]',0,'85 أكبر من أو يساوي 50.',2),
('web-05-javascript-basics','أي دالة تعرض رسالة في Console؟','["console.log","document.title()","alertHTML"]',0,'console.log تعرض قيمة في وحدة التحكم.',3),
('web-06-dom-events','ما الذي يعيده querySelector؟','["أول عنصر يطابق المحدد","كل ملفات المشروع","استجابة API"]',0,'querySelector يعيد أول عنصر مطابق.',1),
('web-06-dom-events','أي طريقة تضيف مستمع حدث؟','["addEventListener","appendStyle","newEvent"]',0,'addEventListener تربط معالجًا بحدث.',2),
('web-06-dom-events','لماذا نفضل textContent لنص المستخدم؟','["لتجنب تفسيره كـHTML","لأنه يرسل البيانات للخادم","لأنه يغير CSS"]',0,'textContent يعرض النص دون تفسيره كعلامات HTML.',3),
('web-07-async-fetch-json','ما وظيفة JSON؟','["تبادل البيانات بصيغة نصية","تنسيق الخطوط","إدارة الفروع"]',0,'JSON صيغة شائعة لتبادل البيانات.',1),
('web-07-async-fetch-json','ماذا يجب فحصه بعد fetch؟','["response.ok أو status","لون زر الإرسال","اسم ملف CSS"]',0,'يجب التحقق من نجاح استجابة HTTP.',2),
('web-07-async-fetch-json','أين تحفظ مفاتيح API السرية؟','["على الخادم في إعداد آمن","داخل JavaScript العام","في عنوان الصفحة"]',0,'كود المتصفح مكشوف للمستخدم.',3),
('workflow-01-git-basics','ما وظيفة git status؟','["عرض حالة الملفات","حذف المستودع","نشر الموقع"]',0,'يعرض التغييرات وحالة staging.',1),
('workflow-01-git-basics','ما وظيفة commit؟','["تسجيل لقطة من التغييرات","فتح المتصفح","إنشاء قاعدة بيانات"]',0,'commit يسجل حالة الملفات المجهزة.',2),
('workflow-01-git-basics','ما الذي يفعله git add؟','["يجهز التغييرات للـcommit","يرسل بريدًا","يشغل Python"]',0,'add يضيف التغييرات إلى staging area.',3),
('workflow-02-branches-github','لماذا ننشئ Branch؟','["لتطوير تغيير بشكل مستقل","لتغيير كلمة مرور المستخدم","لضغط الصور"]',0,'الفروع تفصل خطوط العمل.',1),
('workflow-02-branches-github','ما الغرض من Pull Request؟','["مراجعة التغييرات قبل الدمج","حذف تاريخ المشروع","تشغيل قاعدة البيانات"]',0,'PR يتيح النقاش والمراجعة قبل الدمج.',2),
('workflow-02-branches-github','ماذا تفعل عند وجود تعارض؟','["تفهم النسختين وتحل التعارض ثم تختبر","تحذف كل الملفات","تتجاهل الاختبار"]',0,'يجب اختيار النتيجة الصحيحة وفحصها.',3),
('workflow-03-testing-quality','ما اختبار Unit؟','["اختبار وحدة صغيرة","اختبار الموقع كله يدويًا فقط","اختبار سرعة الإنترنت"]',0,'Unit test يختبر جزءًا صغيرًا معزولًا.',1),
('workflow-03-testing-quality','لماذا نختبر القيم الحدية؟','["لكشف أخطاء الحدود والاستثناءات","لتغيير التصميم","لزيادة حجم الملف"]',0,'الحالات الحدية تكشف افتراضات خاطئة.',2),
('workflow-03-testing-quality','ما الذي يجب إزالته قبل التسليم؟','["رسائل DEBUG غير المطلوبة والأسرار","التوثيق","الاختبارات"]',0,'أزل التشخيص المؤقت ولا تشارك الأسرار.',3),
('backend-01-http-web','ما معنى 404؟','["المورد غير موجود","نجاح الإنشاء","مصادقة ناجحة"]',0,'404 تعني Not Found.',1),
('backend-01-http-web','ما الاستخدام المعتاد لـGET؟','["قراءة مورد","حذف كل البيانات","تغيير CSS"]',0,'GET تطلب قراءة مورد.',2),
('backend-01-http-web','من يجب أن يتحقق من صلاحية العملية الحساسة؟','["الخادم","زر الواجهة فقط","عنوان الصفحة"]',0,'التحقق يجب أن يتم على الخادم.',3),
('backend-02-rest-json','ما API؟','["واجهة تواصل بين البرامج","نوع خط","مجلد صور"]',0,'API عقد يسمح للأنظمة بالتفاعل.',1),
('backend-02-rest-json','أي صيغة شائعة لبيانات API؟','["JSON","MP3","CSS"]',0,'JSON شائعة لتمثيل البيانات.',2),
('backend-02-rest-json','أين يجب التحقق من المدخلات؟','["على الخادم أيضًا","في CSS","في اسم الزر فقط"]',0,'لا تثق بمدخلات العميل.',3),
('backend-03-databases-sql','ما وظيفة Primary Key؟','["تمييز كل صف","تلوين الجدول","تسجيل الخروج"]',0,'المفتاح الأساسي يحدد الصف.',1),
('backend-03-databases-sql','أي عبارة تقرأ بيانات؟','["SELECT","PAINT","RENDER"]',0,'SELECT تسترجع البيانات.',2),
('backend-03-databases-sql','لماذا نستخدم WHERE في UPDATE؟','["لتحديد الصفوف المقصودة","لتغيير الخط","لإنشاء صفحة"]',0,'WHERE تحدد السجلات التي تتأثر.',3),
('backend-04-auth-security','ما الفرق بين Authentication وAuthorization؟','["الهوية مقابل الصلاحية","HTML مقابل CSS","ملف مقابل مجلد"]',0,'الأولى تثبت الهوية والثانية تحدد المسموح.',1),
('backend-04-auth-security','هل إخفاء زر المدير كافٍ للحماية؟','["لا، يجب تحقق الخادم","نعم دائمًا","فقط على الهاتف"]',0,'واجهة المستخدم ليست حدًا أمنيًا.',2),
('backend-04-auth-security','أين يجب حفظ الأسرار؟','["في إعدادات خادم آمنة","داخل كود الواجهة","داخل README العام"]',0,'الأسرار لا توضع في كود المتصفح أو المستودع العام.',3),
('project-01-plan-build-ship','ما أول خطوة مفيدة قبل البرمجة؟','["تحديد المشكلة والمتطلبات","كتابة كل الكود دفعة واحدة","نشر دون اختبار"]',0,'التخطيط يحدد الهدف والنطاق.',1),
('project-01-plan-build-ship','ماذا تختبر قبل التسليم؟','["الوظائف والحالات الحدية والشاشات","اللون فقط","اسم المجلد فقط"]',0,'يجب اختبار الوظائف والحالات المختلفة.',2),
('project-01-plan-build-ship','ما الذي يقدمه README؟','["شرح المشروع وطريقة تشغيله","كلمة مرور قاعدة البيانات","رمز جلسة المستخدم"]',0,'README يوثق الفكرة والتشغيل والاختبارات.',3)
) as x(lesson_id,prompt,options,correct_index,explanation,sort_order)
on x.lesson_id = q.lesson_id
where not exists (
  select 1 from public.programming_quiz_questions old
  where old.quiz_id=q.id and old.prompt=x.prompt
);

-- Publish only after all lesson records, exercises and checkpoints exist.
