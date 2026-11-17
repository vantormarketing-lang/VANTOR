-- Reorganize the existing programming curriculum under five canonical tracks.
-- Preserve every track/module/lesson ID and all student progress, quiz attempts,
-- exercise submissions, certificates, and other historical records.
begin;

do $$
begin
  if (select count(*) from public.programming_tracks where id in
    ('computer-science','programming-languages','web-development','databases-backend','real-world-projects')) <> 5 then
    raise exception 'Canonical programming tracks are missing';
  end if;
  if (select count(*) from public.programming_modules where id in
    ('cs-start-here','visual-first-projects','languages-overview','python-foundations','python-intermediate','cpp-foundations','web-foundations','web-html','web-css','web-js','backend-foundations','backend-web','tools-foundations','workflow-foundations','project-foundations','ai-foundations','mobile-foundations')) <> 17 then
    raise exception 'Expected programming modules are missing';
  end if;
end $$;

update public.programming_modules
set track_id = case
  when id in ('cs-start-here','visual-first-projects') then 'computer-science'
  when id in ('languages-overview','python-foundations','python-intermediate','cpp-foundations') then 'programming-languages'
  when id in ('web-foundations','web-html','web-css','web-js') then 'web-development'
  when id in ('backend-foundations','backend-web','tools-foundations','workflow-foundations') then 'databases-backend'
  when id in ('project-foundations','ai-foundations','mobile-foundations') then 'real-world-projects'
  else track_id end,
 sort_order = case id
  when 'cs-start-here' then 1 when 'visual-first-projects' then 2
  when 'languages-overview' then 1 when 'python-foundations' then 2 when 'python-intermediate' then 3 when 'cpp-foundations' then 4
  when 'web-foundations' then 1 when 'web-html' then 2 when 'web-css' then 3 when 'web-js' then 4
  when 'backend-foundations' then 1 when 'backend-web' then 2 when 'tools-foundations' then 3 when 'workflow-foundations' then 4
  when 'project-foundations' then 1 when 'ai-foundations' then 2 when 'mobile-foundations' then 3
  else sort_order end,
 title = case id
  when 'cs-start-here' then 'أساسيات علوم الكمبيوتر والتفكير البرمجي'
  when 'visual-first-projects' then 'التفكير المنطقي بالبرمجة المرئية'
  when 'languages-overview' then 'مدخل إلى لغات البرمجة'
  when 'python-foundations' then 'Python — المستوى التأسيسي'
  when 'python-intermediate' then 'Python — المستوى المتوسط والمتقدم'
  when 'cpp-foundations' then 'C++ — من الأساسيات إلى OOP'
  when 'web-foundations' then 'بناء الويب من الصفر إلى التفاعل'
  when 'web-html' then 'HTML — بناء المحتوى وهيكل الصفحة'
  when 'web-css' then 'CSS — التنسيق والتصميم المتجاوب'
  when 'web-js' then 'JavaScript — التفاعل والبيانات'
  when 'backend-foundations' then 'قواعد البيانات وSQL'
  when 'backend-web' then 'HTTP وREST وواجهات API'
  when 'tools-foundations' then 'بيئة التطوير والطرفية وتصحيح الأخطاء'
  when 'workflow-foundations' then 'Git وGitHub والاختبار وإدارة الإصدارات'
  when 'project-foundations' then 'من الفكرة إلى مشروع متكامل'
  when 'ai-foundations' then 'الذكاء الاصطناعي وتحليل البيانات'
  when 'mobile-foundations' then 'التقنيات الحديثة وتطبيقات الهاتف'
  else title end,
 description = case id
  when 'cs-start-here' then 'افهم الكمبيوتر والبيانات والخوارزميات، وتدرّب على تحليل المشكلات وتصميم الحل قبل كتابة الكود.'
  when 'visual-first-projects' then 'طبّق التسلسل والأحداث والشروط والتكرار بصريًا لبناء أساس منطقي يسهّل الانتقال إلى كتابة الكود.'
  when 'languages-overview' then 'افهم كيف تعمل لغات البرمجة وما المفاهيم المشتركة بينها، ثم انتقل إلى Python وبعدها C++ بتدرج واضح.'
  when 'python-foundations' then 'ابدأ من أول برنامج، ثم المتغيرات والأنواع والإدخال والعمليات والشروط والحلقات والدوال.'
  when 'python-intermediate' then 'تعمّق في هياكل البيانات والملفات والاستثناءات والوحدات وOOP والاختبار وبناء تطبيقات قابلة للصيانة.'
  when 'cpp-foundations' then 'تعلّم C++ بعد إتقان الأساسيات، مع فهم الذاكرة والمراجع والمؤشرات والأصناف وإدارة الموارد بأمان.'
  when 'web-foundations' then 'مسار عملي متكامل لبناء صفحات الويب باستخدام HTML وCSS وJavaScript.'
  when 'web-html' then 'ابنِ مستندات دلالية سهلة الاستخدام، مع الروابط والصور والنماذج وإتاحة الوصول.'
  when 'web-css' then 'أتقن نموذج الصندوق والتخطيطات المرنة والشبكات والتصميم المتجاوب.'
  when 'web-js' then 'استخدم JavaScript لمعالجة البيانات والتفاعل مع DOM والنماذج والاتصال بواجهات API.'
  when 'backend-foundations' then 'صمّم الجداول والعلاقات، واكتب استعلامات SQL للقراءة والإضافة والتحديث، وافهم سلامة البيانات.'
  when 'backend-web' then 'افهم HTTP وREST وJSON، وابنِ تدفقًا واضحًا بين الواجهة والخادم وواجهات API.'
  when 'tools-foundations' then 'جهّز بيئة التطوير، واستخدم الطرفية، وشغّل البرامج، واقرأ الأخطاء واعثر على أسبابها.'
  when 'workflow-foundations' then 'استخدم Git وGitHub والفروع ومراجعة التغييرات والاختبارات لتسليم عمل موثوق.'
  when 'project-foundations' then 'حوّل المتطلبات إلى خطة ومراحل تنفيذ واختبار وتوثيق، ثم اعرض النتيجة في ملف أعمال.'
  when 'ai-foundations' then 'افهم البيانات وتعلم الآلة وحدود النماذج، وتعلّم التحقق من النتائج والاستخدام المسؤول.'
  when 'mobile-foundations' then 'تعرّف على بنية تطبيقات الهاتف وتجربة المستخدم وDart وFlutter بوصفها امتدادًا للتقنيات الحديثة.'
  else description end,
 updated_at = now()
where id in ('cs-start-here','visual-first-projects','languages-overview','python-foundations','python-intermediate','cpp-foundations','web-foundations','web-html','web-css','web-js','backend-foundations','backend-web','tools-foundations','workflow-foundations','project-foundations','ai-foundations','mobile-foundations');

update public.programming_projects
set track_id = case track_id
  when 'ai-data' then 'real-world-projects'
  when 'developer-tools' then 'databases-backend'
  when 'mobile-development' then 'real-world-projects'
  when 'python' then 'programming-languages'
  when 'visual-programming' then 'computer-science'
  else track_id end;

update public.programming_tracks
set title = case id
  when 'computer-science' then 'Computer Science & Computational Thinking'
  when 'programming-languages' then 'Programming Languages: Python ثم C++'
  when 'web-development' then 'Web Development'
  when 'databases-backend' then 'Databases, Backend & Developer Tools'
  when 'real-world-projects' then 'Projects, AI & Modern Technology'
  else title end,
 subtitle = case id
  when 'computer-science' then 'التفكير المنطقي وحل المشكلات'
  when 'programming-languages' then 'ابدأ بـ Python ثم انتقل إلى C++'
  when 'web-development' then 'HTML وCSS وJavaScript'
  when 'databases-backend' then 'SQL وAPIs وGit والأمان'
  when 'real-world-projects' then 'مشاريع عملية وذكاء اصطناعي وتقنيات حديثة'
  else subtitle end,
 description = case id
  when 'computer-science' then 'ابدأ بفهم الكمبيوتر والبيانات والخوارزميات والتفكير المنطقي، ثم حوّل الحلول إلى خطوات واضحة قبل كتابة الكود.'
  when 'programming-languages' then 'تعلّم مفاهيم البرمجة المشتركة، ثم Python من الصفر إلى التطبيقات، وبعدها C++ لفهم أعمق للبرمجة والذاكرة وهياكل البيانات.'
  when 'web-development' then 'ابنِ مواقع حقيقية من الصفر: HTML للمحتوى، CSS للتصميم المتجاوب، وJavaScript للتفاعل والاتصال بالبيانات.'
  when 'databases-backend' then 'افهم قواعد البيانات وSQL وHTTP وREST وواجهات API، مع أدوات المطور وGit والاختبار والأمان.'
  when 'real-world-projects' then 'حوّل المعرفة إلى مشاريع متكاملة، وابنِ ملف أعمال، واستكشف الذكاء الاصطناعي وتطبيقات الهاتف والتقنيات الحديثة.'
  else description end,
 sort_order = case id
  when 'computer-science' then 1 when 'programming-languages' then 2
  when 'web-development' then 3 when 'databases-backend' then 4
  when 'real-world-projects' then 5 else sort_order end,
 published = case when id in
  ('computer-science','programming-languages','web-development','databases-backend','real-world-projects')
  then true else false end,
 updated_at = now();

commit;
