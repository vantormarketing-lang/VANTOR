-- Add advanced web development, SQL and REST API lessons.
begin;
insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites,updated_at) values ('web-03-html-tables-media','web-html','HTML المتقدم: الجداول والوسائط وإمكانية الوصول','أنشئ جداول ووسائط مدمجة بصورة دلالية، واكتب بدائل نصية وعناوين وتسميات تجعل المحتوى أوضح وأسهل استخدامًا.','## لماذا نحتاج HTML دلاليًا؟

HTML لا يحدد شكل الصفحة فقط؛ بل يصف معنى المحتوى وعلاقته ببعضه. عندما تستخدم العنصر المناسب، يستطيع المتصفح وأدوات المساعدة فهم البنية، ويصبح CSS وJavaScript أسهل في الصيانة.

## 1. الجداول للبيانات الجدولية

استخدم الجدول عندما تكون لديك بيانات تقارن صفوفًا وأعمدة، وليس لبناء تخطيط الصفحة.

```html
<table>
  <caption>نتائج تجريبية للمواد</caption>
  <thead>
    <tr><th scope="col">المادة</th><th scope="col">الدرجة</th></tr>
  </thead>
  <tbody>
    <tr><th scope="row">الرياضيات</th><td>88</td></tr>
    <tr><th scope="row">العلوم</th><td>92</td></tr>
  </tbody>
</table>
```

- `caption` يشرح موضوع الجدول.
- `thead` و`tbody` يفصلان رأس الجدول عن بياناته.
- `th` يحدد خلية عنوان، و`scope` يوضح هل العنوان لعمود أم صف.
- لا تستخدم جدولًا لمجرد ترتيب بطاقات؛ استخدم Grid أو Flexbox.

## 2. الصور والوسائط

```html
<figure>
  <img src="diagram.png" alt="مخطط يوضح اتصال المتصفح بالخادم">
  <figcaption>رحلة طلب صفحة ويب.</figcaption>
</figure>
```

اكتب alt يصف غرض الصورة في سياق الصفحة. إذا كانت الصورة زخرفية بحتة ولا تضيف معلومة، يمكن أن يكون alt فارغًا. لا تكتب "صورة" فقط، ولا تكرر النص المجاور دون فائدة.

للفيديو استخدم controls حتى يستطيع المستخدم تشغيله وإيقافه. وفّر ترجمة أو وصفًا نصيًا عند الحاجة. لا تجعل تشغيل الصوت تلقائيًا مفاجئًا.

## 3. الوصول وإمكانية الاستخدام

- اجعل لكل حقل نموذج label مرتبطًا به.
- استخدم زرًا حقيقيًا للأفعال ورابطًا للتنقل.
- تأكد أن ترتيب Tab منطقي وأن مؤشر التركيز ظاهر.
- لا تعتمد على اللون وحده لشرح النجاح أو الخطأ.
- استخدم العناوين بترتيب منطقي دون اختيار h2 لمجرد حجمه.
- لا تضف ARIA إذا كان عنصر HTML الأصلي يحقق المعنى بالفعل.

## 4. اختبار عملي

أنشئ صفحة تقرير بها عنوان رئيسي، فقرة تمهيدية، جدول درجات تجريبية، صورة توضيحية مع alt، ورابط للانتقال إلى قسم الملاحظات. اختبرها دون CSS أولًا حتى تتأكد أن المعنى واضح.

## أخطاء شائعة

1. استخدام جدول لتقسيم الصفحة إلى أعمدة.
2. ترك الصور المهمة دون نص بديل.
3. وضع نصوص مرئية لا ترتبط بعناصر النموذج.
4. استخدام div قابل للنقر بدل button.
5. الاعتماد على حجم الخط وحده بدل عناصر العناوين.

## تحدي الدرس

أضف جدولًا به ثلاثة صفوف، واجعل لكل عمود عنوانًا، ثم أضف صورة توضيحية مع وصف بديل دقيق. اختبر التنقل بلوحة المفاتيح، واكتب ثلاثة تحسينات لإمكانية الوصول.

## معيار الإتقان

تستطيع اختيار العنصر وفق معنى المحتوى، وتشرح كيف تساعد الدلالات والبدائل النصية المستخدم والمتصفح وأدوات المساعدة.',35,3,true,ARRAY['بناء جدول بعناوين وصفوف دلالية','إضافة صورة وصوت وفيديو مع بدائل مناسبة','تحسين الوصول بلوحة المفاتيح وقارئات الشاشة'],ARRAY[]::text[],now()) on conflict (id) do nothing;
insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites,updated_at) values ('web-04-html-architecture','web-html','تنظيم صفحات HTML والتنقل وبنية المشروع','قسّم الموقع إلى صفحات وأقسام مترابطة، واستخدم روابط نسبية وعناصر تنقل واضحة وبيانات وصفية أساسية.','## من صفحة واحدة إلى موقع منظم

الموقع الصغير قد يحتوي الصفحة الرئيسية وصفحة الدروس وصفحة تواصل. ابدأ بهيكل واضح قبل إضافة CSS أو JavaScript.

```text
site/
  index.html
  lessons/
    index.html
  contact/
    index.html
  assets/
    images/
    styles/
```

## 1. المسارات النسبية

من `index.html` إلى صفحة الدروس داخل مجلد lessons:
```html
<a href="lessons/index.html">الدروس</a>
```

ومن صفحة lessons إلى ملف صورة في assets:
```html
<img src="../assets/images/course.png" alt="غلاف الكورس">
```

النقطتان `../` تعنيان الرجوع مجلدًا واحدًا. اختبر الروابط بعد نقل الصفحة إلى مجلدها النهائي، لأن المسار الذي يعمل من مكان قد يفشل من مكان آخر.

## 2. بنية الصفحة

```html
<header>
  <a href="../index.html">اسم الموقع</a>
  <nav aria-label="التنقل الرئيسي">
    <a href="../index.html">الرئيسية</a>
    <a href="index.html" aria-current="page">الدروس</a>
  </nav>
</header>
<main>
  <h1>الدروس</h1>
  <section aria-labelledby="beginner-title">
    <h2 id="beginner-title">المستوى التأسيسي</h2>
    <p>ابدأ بالمفاهيم الأساسية.</p>
  </section>
</main>
<footer><p>محتوى تعليمي تجريبي.</p></footer>
```

استخدم `aria-current="page"` لتحديد رابط الصفحة الحالية عند الحاجة. لا تكرر أكثر من main واحد في الصفحة.

## 3. البيانات الوصفية

داخل head أضف charset وviewport وعنوانًا فريدًا ووصفًا مختصرًا عند الحاجة. العنوان يجب أن يصف الصفحة نفسها، لا أن يكون عامًا في كل الصفحات.

## 4. مشروع مصغر: موقع أكاديمية

أنشئ ثلاث صفحات مترابطة:
- الرئيسية: تعريف موجز وروابط المسارات.
- المسارات: قائمة بمسارات HTML وCSS وJavaScript.
- تواصل: نموذج تجريبي لا يرسل بيانات إلى خادم.

اجعل كل صفحة تحتوي عنوانًا رئيسيًا واحدًا واضحًا، وتنقلًا ثابتًا، وروابط تعمل من جميع الصفحات.

## قائمة الاختبار

- افتح كل رابط من الصفحة التي يوجد فيها.
- اختبر رابط العودة للرئيسية من المجلدات الداخلية.
- تحقق من عدم وجود معرف id مكرر في الصفحة.
- افتح الصفحة دون CSS: هل تظل البنية مفهومة؟
- راجع العنوان واللغة واتجاه النص.

## معيار الإتقان

تستطيع تنظيم موقع متعدد الصفحات، وتكتب مسارات صحيحة، وتبني تنقلًا يمكن فهمه واستخدامه دون الاعتماد على التصميم المرئي.',35,4,true,ARRAY['تنظيم ملفات الموقع وروابطه','إنشاء تنقل داخلي وبين الصفحات','إضافة metadata وعناوين واضحة'],ARRAY[]::text[],now()) on conflict (id) do nothing;
insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites,updated_at) values ('web-05-css-flexbox-components','web-css','CSS Flexbox وبناء مكونات واجهة قابلة لإعادة الاستخدام','استخدم Flexbox لمحاذاة العناصر، وافهم المحورين والالتفاف والفجوات، ثم أنشئ أنماط مكونات قابلة للتوسع.','## متى تستخدم Flexbox؟

Flexbox مناسب لتوزيع العناصر في اتجاه واحد: صف أو عمود. استخدم Grid عندما تحتاج شبكة صفوف وأعمدة في الوقت نفسه.

```css
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
}
```

## 1. المحوران

- `flex-direction: row` يجعل المحور الرئيسي أفقيًا في اتجاه الكتابة الافتراضي.
- `column` يجعل المحور الرئيسي رأسيًا.
- `justify-content` يوزع العناصر على المحور الرئيسي.
- `align-items` يحاذي العناصر على المحور المتقاطع.
- `align-content` يؤثر في توزيع عدة أسطر عند وجود مساحة مناسبة.

لا تحفظ الخاصية بمعزل عن اتجاه المحور؛ غيّر flex-direction ولاحظ كيف تتغير نتيجة المحاذاة.

## 2. الالتفاف والمسافات

```css
.cards {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}
.card {
  flex: 1 1 240px;
  min-width: 0;
}
```

القيمة الأولى في flex هي grow، والثانية shrink، والثالثة basis. هذا المثال يسمح للبطاقات بالنمو والتقلص مع أساس تقريبي 240px.

## 3. مكونات قابلة لإعادة الاستخدام

بدل كتابة ألوان ومسافات مختلفة لكل بطاقة، استخدم متغيرات وأسماء مكونات:
```css
:root {
  --space-md: 1rem;
  --radius-card: 14px;
  --surface-card: #241c35;
  --text-main: #f7f2ff;
}
.card {
  padding: var(--space-md);
  border-radius: var(--radius-card);
  background: var(--surface-card);
  color: var(--text-main);
}
.card__title { margin: 0 0 .5rem; }
.card--featured { outline: 2px solid #d6b56d; }
```

استخدم اسمًا يصف دور العنصر. لا تجعل المحددات طويلة ومتداخلة إلى درجة يصعب تعديلها.

## 4. تحدي RTL

أنشئ شريطًا يحتوي شعارًا وروابط وزر إجراء. اختبره في اتجاه RTL وLTR. استخدم خصائص منطقية مثل `margin-inline-start` و`padding-inline` بدل افتراض اليمين واليسار في كل حالة.

## اختبارات

1. شاشة عريضة: هل تبقى العناصر متباعدة؟
2. شاشة ضيقة: هل تلتف دون تداخل؟
3. عنوان طويل: هل يخرج من البطاقة؟
4. تكبير النص: هل يظل المحتوى قابلًا للقراءة؟
5. لوحة المفاتيح: هل يظهر focus بوضوح؟

## معيار الإتقان

تختار Flexbox عندما يكون التوزيع أحادي المحور، وتشرح المحاذاة والالتفاف، وتبني مكونات متناسقة دون تكرار غير ضروري.',40,3,true,ARRAY['شرح المحور الرئيسي والمتقاطع','استخدام flex-wrap وgap والمحاذاة','بناء مكونات CSS قابلة لإعادة الاستخدام'],ARRAY[]::text[],now()) on conflict (id) do nothing;
insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites,updated_at) values ('web-06-css-responsive-themes','web-css','التصميم المتجاوب والثيمات والحالات البصرية','ابنِ واجهة تتكيف مع أحجام الشاشات، واستخدم media queries وخصائص CSS المنطقية وحالات التفاعل.','## التصميم المتجاوب يبدأ بالمحتوى

لا تصمم لشاشة هاتف واحدة فقط. ابدأ بتخطيط مرن، ثم أضف نقطة توقف عندما يصبح المحتوى مزدحمًا أو يصعب استخدامه.

```css
.page {
  width: min(100% - 2rem, 1100px);
  margin-inline: auto;
}
.layout {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
}
@media (min-width: 760px) {
  .layout { grid-template-columns: 2fr 1fr; }
}
```

لا توجد قيمة breakpoint سحرية. اخترها بناءً على اللحظة التي يحتاج فيها المحتوى إلى تخطيط مختلف.

## 1. الصور والنصوص المرنة

```css
img, video { max-width: 100%; height: auto; }
.card { min-width: 0; overflow-wrap: anywhere; }
```

اختبر النصوص الطويلة والروابط غير المنقسمة. تجنب ارتفاعًا ثابتًا للبطاقات التي تحتوي نصًا متغيرًا.

## 2. خصائص منطقية للغات متعددة الاتجاه

استخدم `padding-inline` و`margin-block` و`border-inline-start`. هذه الخصائص تتبع اتجاه الكتابة وتساعدك على دعم العربية والإنجليزية دون مضاعفة قواعد CSS.

## 3. حالات التفاعل

```css
.button:hover { filter: brightness(1.08); }
.button:focus-visible { outline: 3px solid #e4c47a; outline-offset: 3px; }
.button:disabled { opacity: .55; cursor: not-allowed; }
```

لا تجعل hover الوسيلة الوحيدة لإظهار معلومة، لأن شاشات اللمس لا تعتمد عليه. حافظ على مؤشر تركيز مرئي.

## 4. الحركة واحترام تفضيلات المستخدم

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    scroll-behavior: auto !important;
    animation-duration: .01ms !important;
    transition-duration: .01ms !important;
  }
}
```

استخدم الحركة لدعم الفهم لا لإجبار المستخدم على متابعة مؤثرات طويلة.

## مشروع

أنشئ صفحة مسارات فيها شريط علوي وبطاقات ومساحة جانبية. اجعلها عمودًا واحدًا على الهاتف وعمودين أو ثلاثة حسب المساحة. أضف حالات hover وfocus وdisabled، ثم اختبر RTL وLTR وتفضيل تقليل الحركة.

## معيار الإتقان

تستطيع شرح سبب نقطة التوقف، وتمنع التمرير الأفقي غير المقصود، وتراعي اتجاه اللغة وإمكانية الوصول وحالات التفاعل.',40,4,true,ARRAY['كتابة media queries حسب الحاجة','استخدام CSS logical properties','تصميم حالات hover وfocus وdisabled'],ARRAY[]::text[],now()) on conflict (id) do nothing;
insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites,updated_at) values ('web-08-js-storage-modules','web-js','JavaScript: التخزين المحلي وتنظيم الحالة','احفظ إعدادات وبيانات تدريبية في localStorage، وتحقق من JSON، وافصل منطق البيانات عن عرض الصفحة.','## لماذا نحتاج تخزينًا في المتصفح؟

المتغيرات تختفي عند إعادة تحميل الصفحة. يمكن استخدام localStorage لحفظ إعدادات بسيطة أو بيانات تدريبية غير حساسة. لا تستخدمه لحفظ كلمات المرور أو مفاتيح سرية أو بيانات شخصية حساسة؛ المستخدم يستطيع فحص بيانات المتصفح وتعديلها.

## 1. قراءة وكتابة JSON

```javascript
const KEY = "doma-demo-settings";
const defaults = { theme: "dark", compact: false };

function loadSettings() {
  try {
    const raw = localStorage.getItem(KEY);
    if (!raw) return defaults;
    const parsed = JSON.parse(raw);
    return {
      theme: parsed.theme === "light" ? "light" : "dark",
      compact: parsed.compact === true
    };
  } catch {
    return defaults;
  }
}

function saveSettings(settings) {
  localStorage.setItem(KEY, JSON.stringify(settings));
}
```

JSON.parse قد يرمي خطأ إذا كانت البيانات غير صالحة؛ لذلك نستخدم try/catch. لا تثق في القيم المخزنة: تحقق من النوع والقيم المسموحة بعد القراءة.

## 2. افصل الحالة عن العرض

اجعل لديك state واضحة، ودالة render تقرأ الحالة وتحدّث الواجهة. لا تكرر تغيير النصوص في أماكن كثيرة لأن الواجهة قد تصبح غير متزامنة مع البيانات.

```javascript
const state = { tasks: [] };

function addTask(title) {
  const cleanTitle = title.trim();
  if (!cleanTitle) return false;
  state.tasks.push({ id: crypto.randomUUID(), title: cleanTitle, done: false });
  return true;
}
```

هذا نموذج تعليمي. إذا كانت البيئة لا تدعم crypto.randomUUID، استخدم معرفًا من الخادم أو آلية مناسبة؛ لا تعتمد على عنوان المهمة وحده كمعرف فريد.

## 3. تحديث آمن للواجهة

استخدم createElement وtextContent عند عرض نص أدخله المستخدم. لا تمرر نص المستخدم إلى innerHTML؛ لأن ذلك قد يفسح مجالًا لحقن HTML غير مرغوب.

## 4. حدود التخزين

- localStorage متزامن ومناسب لكمية صغيرة.
- IndexedDB أفضل لبيانات أكبر أو بنية أكثر تعقيدًا.
- التخزين المحلي ليس نسخة احتياطية ولا مزامنة بين الأجهزة.
- امسح بيانات التدريب عند الحاجة من واجهة واضحة، ولا تمسح بيانات المستخدم دون طلب صريح.

## تحدي

أنشئ قائمة مهام تحفظ الحالة بعد إعادة التحميل. اختبر JSON تالفًا، ومهمة بعنوان فارغ، وبيانات مخزنة من إصدار قديم. أضف زر مسح تجريبي مع تأكيد واضح.

## معيار الإتقان

تستطيع حفظ واسترجاع بيانات غير حساسة، والتحقق منها، وشرح حدود التخزين المحلي، وفصل منطق الحالة عن DOM.',45,4,true,ARRAY['شرح حدود localStorage','استخدام JSON.stringify وJSON.parse بأمان','تنظيم الحالة ودوال العرض'],ARRAY[]::text[],now()) on conflict (id) do nothing;
insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites,updated_at) values ('web-09-js-testing-modules','web-js','JavaScript: تقسيم الكود والاختبار ومعالجة الأخطاء','قسّم الوظائف إلى وحدات صغيرة، واختبر المنطق بالحالات العادية والحدّية، وافهم try/catch وواجهات الوحدات.','## لماذا نقسم البرنامج؟

عندما تخلط قراءة المدخلات والحساب وتحديث الصفحة والتخزين في دالة واحدة، يصبح التعديل والاختبار أصعب. اجعل كل دالة مسؤولة عن مهمة مفهومة.

```javascript
export function isValidScore(value) {
  return Number.isFinite(value) && value >= 0 && value <= 100;
}

export function getResult(score) {
  if (!isValidScore(score)) return "Invalid";
  return score >= 50 ? "Pass" : "Try again";
}
```

ثم يمكن استيراد الوظائف في ملف آخر باستخدام import. في المتصفح، استخدم script type="module" عند تشغيل الوحدات.

## 1. اختبر السلوك المتوقع

اكتب جدول حالات قبل الاختبار:

| المدخل | المتوقع |
|---:|---|
| 85 | Pass |
| 50 | Pass |
| 49 | Try again |
| 0 | Try again |
| 100 | Pass |
| -1 | Invalid |
| 101 | Invalid |
| NaN | Invalid |

اختبار الحدود مهم لأن الأخطاء كثيرًا ما تظهر عند المساواة مع الحد أو تجاوزه بقيمة واحدة.

## 2. اختبار يدوي صغير

```javascript
import { getResult } from "./results.js";

const cases = [
  [85, "Pass"],
  [49, "Try again"],
  [101, "Invalid"]
];

for (const [input, expected] of cases) {
  const actual = getResult(input);
  console.assert(actual === expected, { input, expected, actual });
}
```

console.assert أداة بسيطة للتدريب، وليست بديلًا عن إطار اختبار متكامل في مشروع كبير.

## 3. معالجة الأخطاء

استخدم try/catch عندما تتعامل مع عملية قد تفشل مثل JSON.parse أو طلب شبكة أو قراءة تخزين. لا تبتلع الخطأ بصمت. أظهر رسالة للمستخدم، وسجل التفاصيل المناسبة للمطور دون كشف أسرار.

## 4. لا تخلط الأخطاء

- Syntax Error: صياغة غير صحيحة تمنع التحليل.
- Reference Error: استخدام اسم غير معروف.
- Type Error: عملية غير مناسبة لنوع القيمة.
- Network Error: فشل الاتصال أو الطلب.
- Validation Error: المدخل لا يطابق قواعد التطبيق.

## مشروع مصغر

أعد تنظيم تطبيق المهام إلى:
- tasks.js: إضافة وإكمال وحذف المهام.
- storage.js: القراءة والكتابة والتحقق من البيانات.
- ui.js: إنشاء العناصر وتحديث DOM.
- app.js: ربط الأحداث واستدعاء الوحدات.

اختبر قائمة فارغة، وعنوانًا فارغًا، ومعرفًا غير موجود، وتخزينًا تالفًا.

## معيار الإتقان

تستطيع تقسيم الكود إلى وحدات واضحة، وتكتب حالات اختبار قابلة للتكرار، وتتعامل مع الأخطاء دون إخفائها أو كشف معلومات حساسة.',45,5,true,ARRAY['تقسيم المنطق إلى دوال ووحدات','اختبار المدخلات والحالات الحدّية','معالجة الأخطاء برسائل مفهومة'],ARRAY[]::text[],now()) on conflict (id) do nothing;
insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites,updated_at) values ('backend-09-sql-joins-aggregation','backend-foundations','SQL: ربط الجداول والتجميع والتقارير','استخدم JOIN وGROUP BY والدوال التجميعية لبناء تقارير صحيحة من جداول مترابطة.','## لماذا نربط الجداول؟

غالبًا لا نخزن كل شيء في جدول واحد. قد يكون لدينا students وcourses وenrollments. جدول enrollments يربط الطالب بالكورس بمفاتيح خارجية.

```sql
SELECT s.full_name, c.title
FROM enrollments e
JOIN students s ON s.id = e.student_id
JOIN courses c ON c.id = e.course_id;
```

## 1. INNER JOIN وLEFT JOIN

INNER JOIN يعرض الصفوف التي لها تطابق في الجدولين. LEFT JOIN يحتفظ بكل صفوف الجدول الأيسر حتى لو لم يجد تطابقًا في الجدول الأيمن؛ عندها تكون أعمدة الطرف الآخر NULL.

```sql
SELECT s.full_name, e.course_id
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id;
```

إذا أردت الطلاب الذين ليس لديهم تسجيل:
```sql
SELECT s.id, s.full_name
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id
WHERE e.id IS NULL;
```

## 2. التجميع

```sql
SELECT course_id, COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY course_id
ORDER BY enrollment_count DESC;
```

WHERE يرشح الصفوف قبل التجميع، أما HAVING فيرشح المجموعات بعد GROUP BY.

```sql
SELECT course_id, COUNT(*) AS total
FROM enrollments
GROUP BY course_id
HAVING COUNT(*) >= 5;
```

## 3. تجنب أخطاء العد

إذا ربطت جدولًا بعلاقة واحد إلى متعدد، قد يتكرر صف الطالب بعدد تسجيلاته. COUNT(*) يعد الصفوف الناتجة، وليس عدد الطلاب الفريدين. استخدم COUNT(DISTINCT student_id) عندما يكون هذا هو السؤال.

## 4. نشاط عملي

أنشئ ثلاثة جداول ببيانات وهمية، ثم أجب:
1. ما أسماء الطلاب والكورسات التي سجلوا بها؟
2. ما الكورسات التي لا يوجد بها تسجيل؟
3. كم تسجيلًا لكل كورس؟
4. من الطلاب الذين لم يسجلوا في أي كورس؟

## معيار الإتقان

تختار نوع JOIN حسب المطلوب، وتشرح أثر العلاقة على عدد الصفوف، وتستخدم التجميع دون خلط WHERE وHAVING.',45,9,true,ARRAY['التمييز بين INNER JOIN وLEFT JOIN','استخدام GROUP BY وHAVING','تجنب تضاعف الصفوف في العلاقات'],ARRAY[]::text[],now()) on conflict (id) do nothing;
insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites,updated_at) values ('backend-10-sql-transactions-indexes','backend-foundations','SQL: المعاملات والفهارس وسلامة الأداء','افهم ACID واستخدم المعاملات للعمليات المترابطة، وتعرف متى تساعد الفهارس ومتى تكون كلفتها غير مناسبة.','## لماذا نحتاج المعاملات؟

تخيل تحويل رصيد بين حسابين: يجب خصم المبلغ من حساب وإضافته إلى الآخر. إذا نجحت خطوة وفشلت الأخرى تصبح البيانات غير متسقة. المعاملة تجعل مجموعة التغييرات وحدة واحدة.

```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
-- راجع النتيجة في بيئة التدريب
COMMIT;
```

إذا اكتشفت خطأ قبل اعتماد التغييرات استخدم ROLLBACK بدل COMMIT. تدرب على ذلك في قاعدة محلية ببيانات وهمية فقط.

## 1. خصائص ACID

- Atomicity: إما أن تنجح المعاملة كلها أو لا يعتمد أي جزء منها.
- Consistency: تحافظ المعاملة على القيود وصحة البيانات.
- Isolation: تتحكم قاعدة البيانات في تداخل المعاملات المتزامنة.
- Durability: بعد COMMIT تبقى النتيجة محفوظة وفق ضمانات النظام.

التفاصيل الدقيقة لمستويات العزل تختلف حسب قاعدة البيانات وإعداداتها.

## 2. القيود قبل الفهارس

استخدم PRIMARY KEY وFOREIGN KEY وNOT NULL وUNIQUE وCHECK للتعبير عن قواعد البيانات. لا تعتمد على واجهة المستخدم وحدها للتحقق؛ يجب أن تحمي قاعدة البيانات نفسها من القيم غير الصحيحة.

## 3. ما الفهرس؟

الفهرس بنية إضافية تساعد قاعدة البيانات في العثور على الصفوف دون فحص الجدول كله في بعض الاستعلامات. مثال:
```sql
CREATE INDEX idx_lessons_level
ON lessons(level);
```

الفهرس ليس مجانيًا:
- يستهلك مساحة.
- يزيد تكلفة INSERT وUPDATE وDELETE لأن الفهرس يحتاج تحديثًا.
- قد لا يفيد عمودًا قليل التميّز أو استعلامًا لا يستخدمه.
- لا تنشئ فهارس عشوائية؛ افحص الاستعلام وخطة التنفيذ.

## 4. نشاط

على قاعدة تدريب:
1. أنشئ جدولًا به قيد CHECK.
2. جرّب قيمة تخالف القيد ولاحظ رفضها.
3. نفّذ تعديلين داخل معاملة ثم ROLLBACK.
4. أنشئ فهرسًا على عمود يستخدم في البحث.
5. قارن خطة التنفيذ قبل الفهرس وبعده إن كانت الأداة توفر EXPLAIN.

## معيار الإتقان

تشرح متى تستخدم المعاملة، ولماذا تحمي القيود البيانات، وتوازن بين فائدة الفهرس وكلفة تحديثه.',45,10,true,ARRAY['شرح خصائص ACID بصورة عملية','استخدام BEGIN وCOMMIT وROLLBACK','شرح فائدة الفهرس وتكلفته'],ARRAY[]::text[],now()) on conflict (id) do nothing;
insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites,updated_at) values ('backend-05-api-crud-pagination','backend-web','REST API: عمليات CRUD والبحث وتقسيم النتائج','صمم مسارات API واضحة للقراءة والإنشاء والتعديل والحذف، مع التصفية والترقيم والتحقق من المدخلات.','## صمم حول المورد

في REST نسمّي المورد غالبًا باسم جمع:
- GET /api/lessons
- GET /api/lessons/42
- POST /api/lessons
- PATCH /api/lessons/42
- DELETE /api/lessons/42

لا تجعل أسماء المسارات تصف أفعالًا عشوائية إذا كان HTTP method يوضح الفعل بالفعل.

## 1. عقد الطلب والاستجابة

مثال طلب إنشاء:
```http
POST /api/lessons
Content-Type: application/json
```
```json
{ "title": "HTML Basics", "level": "A1" }
```

قد تعيد الخدمة 201 Created مع المورد الذي تم إنشاؤه. عند فشل التحقق يمكن إرجاع 400 أو 422 حسب تصميم العقد. عند عدم وجود المورد يكون 404 مناسبًا.

## 2. التصفية والترقيم

```http
GET /api/lessons?level=A1&page=2&limit=20
```

يجب تحديد حد أقصى للـ limit حتى لا يطلب العميل آلاف الصفوف دفعة واحدة. أعد معلومات pagination مثل total أو next cursor إذا كان العقد يحتاجها.

## 3. التحقق في الخادم

تحقق من:
- نوع title وأنه غير فارغ.
- أن level من القيم المسموح بها.
- أن المستخدم لديه صلاحية إنشاء الدرس.
- أن القيم لا تتجاوز حدود الطول والحجم.

التحقق في المتصفح لتحسين تجربة الاستخدام، لكنه لا يغني عن تحقق الخادم لأن أي عميل يستطيع إرسال طلب مباشر.

## 4. اتساق الاستجابات

اجعل شكل الخطأ متسقًا:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "راجع البيانات المدخلة",
    "fields": { "title": "هذا الحقل مطلوب" }
  }
}
```

لا ترجع stack trace أو تفاصيل قاعدة البيانات للمستخدم النهائي.

## تحدي

صمم API لإدارة الدروس يتضمن list وdetails وcreate وupdate وdelete. اكتب لكل مسار method وURL والطلب المتوقع ورمز النجاح وحالتين للفشل.

## معيار الإتقان

تستطيع بناء عقد API مفهوم ومتسق، وتطبق pagination والتحقق والصلاحيات على الخادم، وتفصل رسائل المستخدم عن التفاصيل الداخلية.',45,5,true,ARRAY['تصميم موارد ومسارات REST','اختيار HTTP methods ورموز الحالة','تنفيذ pagination وfiltering بمبادئ آمنة'],ARRAY[]::text[],now()) on conflict (id) do nothing;
insert into public.programming_lessons (id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites,updated_at) values ('backend-06-api-auth-errors','backend-web','API: المصادقة والصلاحيات والأخطاء والاختبارات','فرّق بين المصادقة والتفويض، وتعامل مع انتهاء الجلسة والأخطاء، واختبر واجهة API في حالات النجاح والفشل.','## المصادقة ليست التفويض

- Authentication: من المستخدم؟
- Authorization: ما الذي يسمح لهذا المستخدم بفعله؟

وجود جلسة صالحة لا يعني أن المستخدم يستطيع تعديل كل درس أو رؤية بيانات كل طالب.

## 1. تحقق من الصلاحية في كل طلب

عند طلب تعديل مورد:
1. تحقق من الجلسة أو الرمز.
2. استخرج هوية المستخدم من مصدر موثوق على الخادم.
3. اقرأ المورد.
4. تحقق من الدور أو الملكية أو الإذن المطلوب.
5. نفذ العملية بعد نجاح الفحص فقط.

لا تعتمد على role يرسله المتصفح في body. ولا تضع مفاتيح سرية في JavaScript الذي يصل إلى المستخدم.

## 2. رموز حالة مفيدة

- 200: نجح الطلب وأعيدت بيانات.
- 201: تم إنشاء مورد.
- 204: نجح الطلب دون محتوى استجابة.
- 400: الطلب غير صالح.
- 401: لا توجد مصادقة صالحة.
- 403: الهوية معروفة لكن العملية غير مسموحة.
- 404: المورد غير موجود أو لا ينبغي كشف وجوده وفق سياسة النظام.
- 409: تعارض مع الحالة الحالية.
- 429: تجاوز حد الطلبات.
- 500: خطأ داخلي عام.

اختر الرموز بما يتفق مع عقد API ولا تكشف تفاصيل خاصة.

## 3. اختبارات API

أنشئ مجموعة اختبارات تشمل:
- طلب GET صحيح.
- مورد غير موجود.
- طلب بلا جلسة.
- مستخدم عادي يحاول عملية إدارية.
- body ناقص أو نوع خاطئ.
- طلبات متكررة تتجاوز الحد.
- خطأ مؤقت من قاعدة البيانات.

اختبر كذلك أن المستخدم لا يستطيع تغيير معرف المالك أو الدور بإرسال حقول إضافية.

## 4. حماية البيانات

استخدم HTTPS في الإنتاج، وحدد CORS لمصادر موثوقة، ولا تسجل كلمات مرور أو رموز وصول. خزّن الأسرار في إعدادات الخادم، ودوّرها عند الاشتباه في كشفها.

## معيار الإتقان

تستطيع شرح الفرق بين 401 و403، وتطبق التحقق على الخادم لكل عملية، وتكتب اختبارات تغطي المستخدم المصرح وغير المصرح والحالات الحدّية.',45,6,true,ARRAY['التمييز بين Authentication وAuthorization','حماية المسارات والتحقق من الملكية','اختبار حالات API المختلفة'],ARRAY[]::text[],now()) on conflict (id) do nothing;
commit;