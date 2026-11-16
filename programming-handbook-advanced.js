/* DOMA Programming Handbook — extended reference */
(function(){
'use strict';
if(document.getElementById('doma-handbook-advanced'))return;
var style=document.createElement('style');
style.id='doma-handbook-advanced-style';
style.textContent=`
#doma-handbook-advanced .guide-card{position:relative}
#doma-handbook-advanced pre{direction:ltr;text-align:left;white-space:pre-wrap;overflow:auto;padding:13px;border-radius:12px;background:#090b10;border:1px solid rgba(220,184,120,.2);color:#e8d7b9;font:13px/1.75 ui-monospace,Consolas,monospace}
#doma-handbook-advanced .check-answer{margin-top:8px;cursor:pointer}
#doma-handbook-advanced .answer{display:none;margin-top:9px;padding:10px;border-radius:10px;background:rgba(75,210,139,.08);border:1px solid rgba(75,210,139,.22);color:#d9edda;line-height:1.8}
#doma-handbook-advanced .answer.show{display:block}
#doma-handbook-advanced .roadmap{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:10px}
#doma-handbook-advanced .roadmap>div{padding:13px;border-radius:13px;background:rgba(255,255,255,.04);border:1px solid rgba(220,184,120,.2)}
#doma-handbook-advanced .roadmap b{color:#edcc8c}
`;
document.head.appendChild(style);
var host=document.createElement('div');host.id='doma-handbook-advanced';
host.innerHTML=`
<section class="panel" id="roadmap"><h2>6. خريطة التعلّم: من أول سطر إلى مشروع كامل</h2>
<p class="muted">اتبع الترتيب التالي. لا تنتقل لموضوع جديد لمجرد أنك شاهدت الشرح؛ انتقل عندما تستطيع تنفيذ تمرين صغير بنفسك وشرح فكرته.</p>
<div class="roadmap">
<div><b>المرحلة 1 · الأساسيات</b><p>الملفات، لوحة المفاتيح، المتغيرات، أنواع البيانات، الإدخال والإخراج.</p><small>المخرج: برنامج يحسب نتيجة بسيطة.</small></div>
<div><b>المرحلة 2 · التفكير المنطقي</b><p>الشروط، الحلقات، تقسيم المشكلة، المخططات والخوارزميات.</p><small>المخرج: حل مشكلة بخطوات واضحة.</small></div>
<div><b>المرحلة 3 · بناء البرامج</b><p>الدوال، القوائم، النصوص، الملفات، تنظيم الكود.</p><small>المخرج: برنامج متعدد الوظائف.</small></div>
<div><b>المرحلة 4 · الاختبار والتصحيح</b><p>حالات الاختبار، الأخطاء الشائعة، تتبع القيم، مراجعة الحل.</p><small>المخرج: برنامج يمكن الوثوق بنتائجه.</small></div>
<div><b>المرحلة 5 · الويب والأدوات</b><p>HTML وCSS وJavaScript وGit وGitHub وواجهات API.</p><small>المخرج: موقع تفاعلي محفوظ بإصدارات.</small></div>
<div><b>المرحلة 6 · المشاريع</b><p>تخطيط، تنفيذ، اختبار، توثيق، ثم تحسين تدريجي.</p><small>المخرج: مشروع نهائي تقدر تشرحه.</small></div>
</div></section>
<section class="panel" id="web-basics"><h2>7. مرجع الويب: HTML وCSS وJavaScript</h2><div class="two">
<article class="guide-card"><h3>HTML · هيكل الصفحة</h3><p>HTML يحدد معنى ومكونات الصفحة: عنوان، فقرة، رابط، صورة، نموذج.</p><pre>&lt;h1&gt;My first page&lt;/h1&gt;
&lt;p&gt;I am learning web development.&lt;/p&gt;
&lt;button type="button"&gt;Start&lt;/button&gt;</pre><p>استخدم العنصر المناسب لمعناه، وأضف وصفًا بديلًا للصور ووسوم label للحقول.</p></article>
<article class="guide-card"><h3>CSS · شكل الصفحة</h3><p>CSS يتحكم في الألوان والمسافات والتخطيط واستجابة الصفحة للشاشات.</p><pre>.card {
  padding: 16px;
  border-radius: 12px;
  display: grid;
  gap: 10px;
}</pre><p>ابدأ بتصميم بسيط، ثم اختبره على شاشة هاتف وشاشة كبيرة.</p></article>
<article class="guide-card"><h3>JavaScript · السلوك</h3><p>JavaScript يضيف التفاعل ويستجيب لأحداث المستخدم.</p><pre>const button = document.querySelector('button');
button.addEventListener('click', () =&gt; {
  alert('Hello!');
});</pre><p>لا تعتمد على JavaScript وحده للتحقق من البيانات الحساسة؛ تحقق منها في الخادم أيضًا.</p></article>
<article class="guide-card"><h3>كيف تعمل معًا؟</h3><p>HTML يبني الهيكل، CSS ينسّق المظهر، وJavaScript يضيف السلوك. افصل الملفات عندما يكبر المشروع لتسهيل الصيانة.</p><p><b>تذكّر:</b> لا تضع كلمات مرور أو مفاتيح سرية داخل ملفات الواجهة العامة.</p></article>
</div></section>
<section class="panel" id="python-cpp"><h2>8. مرجع Python وC++</h2><div class="two">
<article class="guide-card"><h3>Python · مثال دالة واختبار</h3><pre>def average(numbers):
    if not numbers:
        return 0
    return sum(numbers) / len(numbers)

assert average([2, 4, 6]) == 4
assert average([]) == 0</pre><p>الدالة تستقبل قائمة، وتعالج الحالة الفارغة، ثم تحسب المتوسط. اختبر الحالة العادية والحالة الحدّية.</p></article>
<article class="guide-card"><h3>C++ · مثال متجه ودالة</h3><pre>#include &lt;iostream&gt;
#include &lt;vector&gt;
using namespace std;

int total(const vector&lt;int&gt;&amp; values) {
    int result = 0;
    for (int value : values) result += value;
    return result;
}

int main() {
    cout &lt;&lt; total({2, 4, 6});
}</pre><p>استخدم المراجع الثابتة عند قراءة حاوية دون الحاجة لنسخها، وفضّل إدارة الموارد الآمنة بدل إدارة الذاكرة يدويًا بلا داعٍ.</p></article>
</div><h3>قواعد مراجعة الكود</h3><ul><li>سمِّ المتغيرات والدوال بأسماء توضح الغرض.</li><li>اجعل كل دالة مسؤولة عن مهمة محددة قدر الإمكان.</li><li>تجنب تكرار الكود؛ استخرج الجزء المتكرر في دالة.</li><li>تحقق من المدخلات وحدود القوائم والقيم الفارغة.</li><li>في C++، انتبه لعمر الكائنات والمراجع والمؤشرات، ولا تستخدم مرجعًا بعد انتهاء عمر العنصر.</li></ul></section>
<section class="panel" id="git-basics"><h2>9. Git وGitHub: حفظ تاريخ مشروعك</h2><p class="muted">Git يتتبع تغييرات ملفات المشروع على جهازك. GitHub يستضيف مستودعات Git ويسهّل التعاون ومراجعة التغييرات.</p>
<pre>git init
git status
git add .
git commit -m "Add first version"
git log --oneline</pre>
<div class="two"><article class="guide-card"><h3>تسلسل العمل المعتاد</h3><ol><li>افحص الملفات باستخدام <code>git status</code>.</li><li>أضف التغييرات المقصودة فقط.</li><li>أنشئ commit برسالة تصف التغيير.</li><li>راجع السجل قبل مشاركة التحديث.</li><li>ارفع التغييرات إلى المستودع البعيد عند الاستعداد.</li></ol></article><article class="guide-card"><h3>تجنب هذه الأخطاء</h3><ul><li>لا ترفع كلمات مرور أو مفاتيح API.</li><li>لا تستخدم <code>git add .</code> دون مراجعة الملفات الحساسة.</li><li>اكتب رسائل commit واضحة.</li><li>اختبر التغيير قبل دمجه في الفرع الرئيسي.</li></ul></article></div></section>
<section class="panel" id="testing"><h2>10. الاختبار: كيف تعرف أن الحل صحيح؟</h2><div class="two">
<article class="guide-card"><h3>ثلاث فئات من الاختبارات</h3><ul><li><b>حالة عادية:</b> مدخل متوقع وشائع.</li><li><b>حالة حدّية:</b> صفر، قائمة فارغة، أصغر أو أكبر قيمة.</li><li><b>مدخل غير صالح:</b> نوع بيانات أو صيغة غير متوقعة.</li></ul></article>
<article class="guide-card"><h3>مثال جدول اختبار</h3><ul><li>المدخل: درجات 80 و90 و70 — المتوقع: متوسط 80.</li><li>المدخل: قائمة فارغة — المتوقع: معالجة واضحة دون انهيار.</li><li>المدخل: نص بدل رقم — المتوقع: رسالة توضح المطلوب.</li></ul></article>
</div><p class="muted">الاختبار لا يثبت أن البرنامج خالٍ من كل الأخطاء، لكنه يكشف كثيرًا من المشكلات قبل أن تصل للمستخدم.</p></section>
<section class="panel" id="project-method"><h2>11. طريقة تنفيذ أي مشروع</h2><ol class="steps"><li><b>افهم المطلوب:</b> اكتب المشكلة في جملة وحدد من سيستخدم البرنامج.</li><li><b>حدد المدخلات والمخرجات:</b> ما البيانات التي تدخل؟ وما النتيجة المطلوبة؟</li><li><b>قسّم العمل:</b> حوّل المشروع إلى مهام صغيرة يمكن اختبارها.</li><li><b>ابدأ بنسخة صغيرة:</b> أنجز الوظيفة الأساسية أولًا قبل الزخارف.</li><li><b>اختبر كل جزء:</b> جرّب الحالات العادية والحدّية وغير الصالحة.</li><li><b>وثّق المشروع:</b> اكتب طريقة التشغيل، والميزات، وما الذي تعلمته.</li><li><b>حسّن بعد التشغيل:</b> أصلح المشاكل ثم أضف ميزة واحدة في كل مرة.</li></ol>
<h3>أفكار مشاريع متدرجة</h3><div class="two"><article class="guide-card"><h3>مبتدئ</h3><p>آلة حاسبة، محول وحدات، اختبار أسئلة، قائمة مهام بسيطة.</p></article><article class="guide-card"><h3>متوسط</h3><p>متعقب مصروفات، مدير مكتبة، لعبة تخمين، لوحة درجات مع حفظ ملف.</p></article><article class="guide-card"><h3>متقدم</h3><p>موقع متعدد الصفحات، تطبيق إدارة مهام بواجهة API، نظام تقارير واختبارات آلية.</p></article></div></section>
<section class="panel" id="self-check"><h2>12. اختبر فهمك</h2><p class="muted">حاول الإجابة قبل فتح الحل. هذه مراجعة ذاتية وليست امتحانًا رسميًا.</p>
<div class="guide-card"><h3>السؤال 1: ما الفرق بين = و == في Python؟</h3><button class="check-answer" type="button" data-answer="a1">إظهار الإجابة</button><div class="answer" id="a1">= لإسناد قيمة إلى متغير، أما == لمقارنة قيمتين وإرجاع True أو False.</div></div>
<div class="guide-card"><h3>السؤال 2: لماذا نختبر الحالة الفارغة؟</h3><button class="check-answer" type="button" data-answer="a2">إظهار الإجابة</button><div class="answer" id="a2">لأنها حالة حدّية قد تسبب قسمة على صفر أو الوصول إلى عنصر غير موجود أو نتيجة غير متوقعة.</div></div>
<div class="guide-card"><h3>السؤال 3: ما فائدة Git commit؟</h3><button class="check-answer" type="button" data-answer="a3">إظهار الإجابة</button><div class="answer" id="a3">يسجل لقطة من التغييرات مع رسالة، فتستطيع مراجعة تاريخ المشروع وفهم كيف تطور.</div></div>
<div class="guide-card"><h3>السؤال 4: ما دور HTML وCSS وJavaScript؟</h3><button class="check-answer" type="button" data-answer="a4">إظهار الإجابة</button><div class="answer" id="a4">HTML للهيكل والمحتوى، CSS للمظهر والتخطيط، وJavaScript للتفاعل والسلوك.</div></div>
</section>`;
var footer=document.querySelector('main.handbook footer');
if(footer)footer.parentNode.insertBefore(host,footer);else document.querySelector('main.handbook').appendChild(host);
host.addEventListener('click',function(e){var b=e.target.closest('[data-answer]');if(!b)return;var a=document.getElementById(b.getAttribute('data-answer'));if(!a)return;var show=!a.classList.contains('show');a.classList.toggle('show',show);b.textContent=show?'إخفاء الإجابة':'إظهار الإجابة';});
var nav=document.querySelector('.hero .nav');if(nav){[['roadmap','خريطة التعلّم'],['web-basics','الويب'],['python-cpp','Python وC++'],['git-basics','Git'],['testing','الاختبار'],['project-method','المشاريع'],['self-check','اختبر نفسك']].forEach(function(x){var a=document.createElement('a');a.href='#'+x[0];a.textContent=x[1];nav.appendChild(a);});}
})();
