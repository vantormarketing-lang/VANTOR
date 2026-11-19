
insert into public.programming_lessons
(id,module_id,title,summary,content_md,duration_minutes,sort_order,published,learning_objectives,prerequisites)
values
('capstone-05-python-task-manager','project-foundations','مشروع تطبيقي: مدير مهام باستخدام Python','ابنِ تطبيقًا نصيًا ينشئ المهام ويعرضها ويحدّث حالتها ويحفظها في ملف JSON.','## هدف المشروع
بناء مدير مهام صغير يعمل من الطرفية ويحفظ البيانات بين مرات التشغيل.

## المتطلبات
1. أنشئ قائمة مهام، وكل مهمة لها id وtitle وcompleted.
2. أضف وظيفة لإضافة مهمة مع رفض العنوان الفارغ.
3. أضف وظيفة لعرض المهام مع حالة كل مهمة.
4. أضف وظيفة لتغيير حالة المهمة إلى مكتملة.
5. احفظ البيانات في ملف JSON واقرأها عند بدء البرنامج.

## تقسيم مقترح
- data.py: تحميل البيانات وحفظها.
- tasks.py: وظائف الإضافة والعرض والتحديث.
- main.py: واجهة القائمة والتفاعل مع المستخدم.

## مثال على شكل البيانات
```python
tasks = [
    {"id": 1, "title": "Revise loops", "completed": False}
]
```

## اختبارات ضرورية
- إضافة عنوان صحيح.
- رفض عنوان فارغ أو مسافات فقط.
- عرض قائمة فارغة دون تعطل.
- تحديث مهمة موجودة.
- التعامل مع ملف بيانات غير موجود ببدء قائمة فارغة.

## معيار الإنجاز
يعمل البرنامج بعد إغلاقه وفتحه مرة أخرى دون فقد البيانات، وتكون الوظائف مقسمة إلى دوال واضحة.','55',5,true,array['تنظيم البيانات في قائمة من القواميس','كتابة دوال صغيرة قابلة للاختبار','قراءة وكتابة JSON','معالجة الحالات الفارغة والأخطاء'],array['python-18-cli-project']),
('capstone-06-web-portfolio','project-foundations','مشروع تطبيقي: موقع ملف أعمال متجاوب','أنشئ موقعًا يعرض نبذة ومشروعاتك ومهاراتك مع تصميم مناسب للهاتف.','## هدف المشروع
إنشاء موقع Portfolio بسيط بثلاثة أقسام: نبذة، مشروعات، وتواصل.

## المتطلبات
- استخدم HTML دلاليًا: header وmain وsection وfooter.
- أنشئ بطاقة لكل مشروع تحتوي الاسم والوصف والتقنيات.
- نسّق الصفحة باستخدام CSS Grid أو Flexbox.
- أضف قائمة تنقل وروابط واضحة.
- استخدم JavaScript للتحقق من نموذج تواصل تجريبي دون إرسال بيانات شخصية.
- اختبر العرض على شاشة ضيقة وأخرى واسعة.

## إمكانية الوصول
- أضف نصوصًا بديلة للصور.
- اربط label بكل input.
- حافظ على تباين جيد وإمكانية التنقل بلوحة المفاتيح.

## اختبارات
تأكد من عدم وجود تمرير أفقي غير مقصود على الهاتف، وأن الروابط تعمل، وأن النموذج يعرض رسالة واضحة عند نقص الحقول.','50',5,true,array['بناء صفحة HTML دلالية','تنفيذ تخطيط متجاوب','إضافة تفاعل بسيط وآمن','اختبار الوصول وتجربة الهاتف'],array['web-js-03-dom-events']),
('capstone-07-database-library','project-foundations','مشروع تطبيقي: قاعدة بيانات مكتبة','صمّم قاعدة بيانات صغيرة للكتب والأعضاء والاستعارات واكتب استعلامات تقارير أساسية.','## هدف المشروع
تصميم قاعدة بيانات علائقية لمكتبة تدريبية.

## الجداول
- books: book_id وtitle وauthor وavailable.
- members: member_id وdisplay_name.
- loans: loan_id وbook_id وmember_id وloan_date وreturn_date.

## العلاقات
كل استعارة ترتبط بكتاب واحد وعضو واحد. استخدم المفاتيح الأساسية والخارجية لمنع السجلات اليتيمة.

## استعلامات مطلوبة
1. عرض الكتب المتاحة.
2. عرض استعارات عضو محدد.
3. حساب عدد الاستعارات لكل كتاب.
4. عرض الاستعارات التي لم تسجل لها return_date.

## قواعد سلامة البيانات
لا تكرر معرف الكتاب، ولا تسمح باستعارة تشير إلى عضو أو كتاب غير موجود. استخدم بيانات تجريبية غير حقيقية فقط.

## معيار الإنجاز
تستطيع إنشاء الجداول وإضافة بيانات اختبار وتنفيذ الاستعلامات الأربعة وشرح نتيجة كل استعلام.','55',5,true,array['تصميم جداول مترابطة','استخدام المفاتيح الأساسية والخارجية','كتابة SELECT وJOIN وGROUP BY','التحقق من سلامة البيانات'],array['backend-04-sql-joins']),
('capstone-08-cpp-grade-analyzer','project-foundations','مشروع تطبيقي: محلل درجات باستخدام C++','استخدم vector والدوال والفئات لبناء برنامج يحلل مجموعة درجات ويعرض إحصاءات واضحة.','## هدف المشروع
بناء برنامج C++ يستقبل مجموعة درجات صحيحة من 0 إلى 100 ثم يحسب الإحصاءات.

## الوظائف
- قراءة عدد الدرجات والتحقق من أنه موجب.
- قراءة الدرجات والتحقق من النطاق.
- حساب المجموع والمتوسط.
- إيجاد أعلى وأقل درجة.
- حساب عدد الناجحين وفق حد نجاح معلن.
- عرض تقرير منسق.

## تصميم مقترح
أنشئ class باسم GradeReport يحتوي vector<int>، واجعل وظائف الإضافة والحساب والعرض واضحة. استخدم const في الدوال التي لا تغير البيانات.

## حالات الاختبار
- درجة واحدة.
- عدة درجات متساوية.
- درجات عند الحد الأدنى والأعلى.
- إدخال خارج النطاق.
- رفض عدد درجات يساوي صفرًا.

## معيار الإنجاز
لا توجد قيم غير صالحة في التقرير، والحسابات صحيحة، وكل وظيفة يمكن اختبارها منفردة.','55',5,true,array['استخدام vector لتخزين القيم','تقسيم البرنامج إلى دوال وفئة','التحقق من المدخلات','اختبار الحالات الحدّية'],array['cpp-10-debugging-project'])
on conflict (id) do nothing;

insert into public.programming_exercises
(lesson_id,title,instructions,starter_code,language,is_published,test_cases,hints,solution_code,rubric,grading_mode)
values
('capstone-05-python-task-manager','نفّذ وظائف مدير المهام','أكمل دالتي add_task وcomplete_task. ارفض العنوان الفارغ، وأعد نسخة محدثة من القائمة عند إكمال مهمة موجودة.','def add_task(tasks, title):
    # TODO: Clean title and reject empty values.
    return tasks

def complete_task(tasks, task_id):
    # TODO: Mark the matching task as completed.
    return tasks

items = []
items = add_task(items, "Revise Python")
items = complete_task(items, 1)
print(items)
','python',true,'[]'::jsonb,'["استخدم strip لإزالة المسافات من طرفي العنوان.","أعطِ كل مهمة id متزايدًا أو استخدم len(tasks)+1 في هذا التدريب.","ابحث عن المهمة ذات id المطابق قبل تحديث completed."]'::jsonb,'def add_task(tasks, title):
    clean = title.strip()
    if not clean:
        return tasks
    next_id = max([task["id"] for task in tasks], default=0) + 1
    return tasks + [{"id": next_id, "title": clean, "completed": False}]

def complete_task(tasks, task_id):
    updated = []
    for task in tasks:
        item = dict(task)
        if item["id"] == task_id:
            item["completed"] = True
        updated.append(item)
    return updated','[{"criterion":"رفض العنوان الفارغ","points":2},{"criterion":"إنشاء معرف فريد","points":2},{"criterion":"تحديث المهمة الصحيحة فقط","points":3},{"criterion":"عدم تعديل القائمة الأصلية مباشرة","points":1}]'::jsonb,'stdout'),
('capstone-06-web-portfolio','أنشئ بطاقة مشروع دلالية','اكتب HTML لبطاقة مشروع تحتوي عنوانًا ووصفًا ورابطًا. استخدم عناصر دلالية ونص رابط واضحًا.','<!-- TODO: Build a semantic project card -->
','html',true,'[]'::jsonb,'["ابدأ بعنصر article.","استخدم h2 للعنوان وp للوصف.","اجعل نص الرابط يوضح وجهته."]'::jsonb,'<article class="project-card">
  <h2>Study Planner</h2>
  <p>A small app for organizing study tasks.</p>
  <a href="#study-planner">View project details</a>
</article>','[{"criterion":"استخدام article","points":2},{"criterion":"وجود عنوان h2 ووصف","points":2},{"criterion":"رابط واضح","points":2}]'::jsonb,'manual'),
('capstone-07-database-library','اكتب استعلام تقرير الاستعارات','اكتب استعلام SQL يعرض عنوان الكتاب واسم العضو وتاريخ الاستعارة من الجداول books وmembers وloans، مع ربط المفاتيح الصحيحة.','-- TODO: SELECT book title, member name and loan date
','sql',true,'[]'::jsonb,'["اربط loans.book_id مع books.book_id.","اربط loans.member_id مع members.member_id.","استخدم أسماء مستعارة للأعمدة إذا احتجت."]'::jsonb,'select b.title, m.display_name, l.loan_date
from loans l
join books b on b.book_id = l.book_id
join members m on m.member_id = l.member_id;','[{"criterion":"ربط جدول الكتب بشكل صحيح","points":2},{"criterion":"ربط جدول الأعضاء بشكل صحيح","points":2},{"criterion":"اختيار الحقول المطلوبة","points":2}]'::jsonb,'manual'),
('capstone-08-cpp-grade-analyzer','احسب متوسط الدرجات','أكمل الدالة calculate_average. يجب أن تعيد 0.0 للقائمة الفارغة، وإلا تحسب المتوسط الحسابي.','#include <iostream>
#include <vector>
using namespace std;

double calculate_average(const vector<int>& grades) {
    // TODO
    return 0.0;
}

int main() {
    cout << calculate_average({80, 90, 70}) << endl;
}
','cpp',true,'[]'::jsonb,'["استخدم حلقة لجمع القيم.","تجنب القسمة على صفر.","حوّل المجموع إلى double قبل القسمة للحصول على متوسط عشري."]'::jsonb,'double calculate_average(const vector<int>& grades) {
    if (grades.empty()) return 0.0;
    int total = 0;
    for (int grade : grades) total += grade;
    return static_cast<double>(total) / grades.size();
}','[{"criterion":"معالجة القائمة الفارغة","points":2},{"criterion":"جمع كل القيم","points":2},{"criterion":"قسمة عشرية صحيحة","points":2}]'::jsonb,'manual')
on conflict (lesson_id) do nothing;

insert into public.programming_quizzes (lesson_id,title,pass_percent,is_published)
values
('capstone-05-python-task-manager','تقييم مشروع مدير المهام',70,true),
('capstone-06-web-portfolio','تقييم مشروع ملف الأعمال',70,true),
('capstone-07-database-library','تقييم مشروع قاعدة بيانات المكتبة',70,true),
('capstone-08-cpp-grade-analyzer','تقييم مشروع محلل الدرجات',70,true)
on conflict (lesson_id) do nothing;

insert into public.programming_quiz_questions (quiz_id,prompt,options,correct_index,explanation,sort_order)
select q.id, v.prompt, v.options::jsonb, v.correct_index, v.explanation, v.sort_order
from public.programming_quizzes q
join (values
('capstone-05-python-task-manager','ما فائدة حفظ المهام في JSON؟','["تشغيل واجهة رسومية","الاحتفاظ بالبيانات بعد إغلاق البرنامج","تسريع لوحة المفاتيح","تغيير نوع Python"]',1,'يسمح JSON بتخزين البيانات في ملف وإعادة قراءتها لاحقًا.',1),
('capstone-05-python-task-manager','لماذا نرفض عنوان المهمة الفارغ؟','["لمنع سجلات بلا معنى","لزيادة عدد الملفات","لإيقاف البرنامج دائمًا","لتحويل النص إلى رقم"]',0,'التحقق من المدخلات يحافظ على جودة البيانات.',2),
('capstone-05-python-task-manager','ما الاختبار المناسب لقائمة مهام فارغة؟','["افترض وجود عنصر أول","تأكد أن العرض لا يتعطل","احذف ملف البيانات","غيّر لغة النظام"]',1,'القائمة الفارغة حالة حدّية يجب التعامل معها بوضوح.',3),
('capstone-06-web-portfolio','أي عنصر دلالي مناسب لبطاقة مشروع مستقلة؟','["article","br","meta","title"]',0,'article مناسب لمحتوى مستقل يمكن فهمه منفصلًا.',1),
('capstone-06-web-portfolio','ما فائدة label المرتبط بحقل نموذج؟','["إخفاء الحقل","توضيح اسم الحقل وتحسين الوصول","تغيير لون الصفحة","تحميل صورة"]',1,'الوسم المرتبط يساعد المستخدمين وتقنيات المساعدة على فهم الحقل.',2),
('capstone-06-web-portfolio','كيف تختبر تجاوب الصفحة؟','["على شاشة واحدة فقط","على عروض شاشة مختلفة","بتغيير اسم الملف","بحذف CSS"]',1,'اختبر الهاتف والشاشات الأوسع واكتشف التمرير الأفقي غير المقصود.',3),
('capstone-07-database-library','ما وظيفة المفتاح الخارجي؟','["تغيير لون الجدول","ربط سجل بسجل موجود في جدول آخر","ترتيب النصوص أبجديًا","تشفير الصفحة"]',1,'المفتاح الخارجي يحافظ على صحة العلاقات بين الجداول.',1),
('capstone-07-database-library','أي JOIN يعرض الصفوف التي لها تطابق في الجدولين؟','["INNER JOIN","DROP JOIN","DELETE JOIN","ORDER JOIN"]',0,'INNER JOIN يعيد الصفوف التي تحقق شرط الربط في الجدولين.',2),
('capstone-07-database-library','لماذا نستخدم بيانات تجريبية؟','["لحماية خصوصية الأشخاص","لزيادة حجم قاعدة البيانات","لإلغاء الاختبارات","لجعل SQL أبطأ"]',0,'بيانات غير حقيقية تقلل مخاطر كشف معلومات شخصية أثناء التدريب.',3),
('capstone-08-cpp-grade-analyzer','لماذا يجب فحص vector الفارغ قبل حساب المتوسط؟','["لمنع القسمة على صفر","لزيادة الدقة دائمًا","لإضافة عناصر تلقائيًا","لمنع استخدام الدوال"]',0,'لا يمكن حساب متوسط بقسمة المجموع على عدد عناصر يساوي صفرًا.',1),
('capstone-08-cpp-grade-analyzer','ما فائدة const في دالة تقرأ vector؟','["تسمح بتغيير كل العناصر","توضح أن الدالة لا تعدّل البيانات عبر هذا المرجع","تحذف المتجه","تجعل البرنامج رسوميًا"]',1,'const يمنع التعديل عبر المرجع داخل الدالة ويعبّر عن نية القراءة فقط.',2),
('capstone-08-cpp-grade-analyzer','ما الاختبار الحدّي المفيد لمحلل الدرجات؟','["إدخال درجة 150","اختبار درجة 0 و100","عدم إدخال أي شيء دون معالجة","تغيير اسم البرنامج"]',1,'الحدان 0 و100 يختبران نطاق الدرجات المسموح.',3)
) as v(lesson_id,prompt,options,correct_index,explanation,sort_order)
on q.lesson_id=v.lesson_id
where not exists (
 select 1 from public.programming_quiz_questions old
 where old.quiz_id=q.id and old.sort_order=v.sort_order
);

