-- DOMA Programming Academy: isolated curriculum and student progress.
create table if not exists public.programming_tracks (
 id text primary key, title text not null, subtitle text not null default '',
 description text not null default '', sort_order integer not null default 0,
 published boolean not null default true, created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.programming_modules (
 id text primary key, track_id text not null references public.programming_tracks(id) on delete cascade,
 title text not null, description text not null default '', sort_order integer not null default 0,
 published boolean not null default true, created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.programming_lessons (
 id text primary key, module_id text not null references public.programming_modules(id) on delete cascade,
 title text not null, summary text not null default '', content_md text not null default '',
 duration_minutes integer not null default 10 check (duration_minutes between 1 and 240),
 sort_order integer not null default 0, published boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.programming_lesson_progress (
 user_id uuid not null references auth.users(id) on delete cascade,
 lesson_id text not null references public.programming_lessons(id) on delete cascade,
 completed_at timestamptz not null default now(), primary key(user_id,lesson_id)
);
create index if not exists programming_modules_track_sort_idx on public.programming_modules(track_id,sort_order);
create index if not exists programming_lessons_module_sort_idx on public.programming_lessons(module_id,sort_order);
create index if not exists programming_progress_user_idx on public.programming_lesson_progress(user_id);
alter table public.programming_tracks enable row level security;
alter table public.programming_modules enable row level security;
alter table public.programming_lessons enable row level security;
alter table public.programming_lesson_progress enable row level security;
drop policy if exists "Published programming tracks are readable" on public.programming_tracks;
create policy "Published programming tracks are readable" on public.programming_tracks for select to anon,authenticated using(published=true);
drop policy if exists "Published programming modules are readable" on public.programming_modules;
create policy "Published programming modules are readable" on public.programming_modules for select to anon,authenticated using(published=true and exists(select 1 from public.programming_tracks t where t.id=track_id and t.published=true));
drop policy if exists "Published programming lessons are readable" on public.programming_lessons;
create policy "Published programming lessons are readable" on public.programming_lessons for select to anon,authenticated using(published=true and exists(select 1 from public.programming_modules m join public.programming_tracks t on t.id=m.track_id where m.id=module_id and m.published=true and t.published=true));
drop policy if exists "Students read own programming progress" on public.programming_lesson_progress;
create policy "Students read own programming progress" on public.programming_lesson_progress for select to authenticated using(user_id=auth.uid());
drop policy if exists "Students insert own programming progress" on public.programming_lesson_progress;
create policy "Students insert own programming progress" on public.programming_lesson_progress for insert to authenticated with check(user_id=auth.uid());
drop policy if exists "Students delete own programming progress" on public.programming_lesson_progress;
create policy "Students delete own programming progress" on public.programming_lesson_progress for delete to authenticated using(user_id=auth.uid());
drop policy if exists "Staff manage programming tracks" on public.programming_tracks;
create policy "Staff manage programming tracks" on public.programming_tracks for all to authenticated using(exists(select 1 from public.profiles p where p.id=auth.uid() and p.role in('admin','teacher'))) with check(exists(select 1 from public.profiles p where p.id=auth.uid() and p.role in('admin','teacher')));
drop policy if exists "Staff manage programming modules" on public.programming_modules;
create policy "Staff manage programming modules" on public.programming_modules for all to authenticated using(exists(select 1 from public.profiles p where p.id=auth.uid() and p.role in('admin','teacher'))) with check(exists(select 1 from public.profiles p where p.id=auth.uid() and p.role in('admin','teacher')));
drop policy if exists "Staff manage programming lessons" on public.programming_lessons;
create policy "Staff manage programming lessons" on public.programming_lessons for all to authenticated using(exists(select 1 from public.profiles p where p.id=auth.uid() and p.role in('admin','teacher'))) with check(exists(select 1 from public.profiles p where p.id=auth.uid() and p.role in('admin','teacher')));
grant select on public.programming_tracks,public.programming_modules,public.programming_lessons to anon,authenticated;
grant select,insert,delete on public.programming_lesson_progress to authenticated;
insert into public.programming_tracks(id,title,subtitle,description,sort_order) values
('computer-science','Computer Science Fundamentals','ابدأ من الصفر','فهم الكمبيوتر والتفكير المنطقي والخوارزميات وحل المشكلات قبل تعلم أي لغة.',1),
('visual-programming','Visual Programming','البرمجة بالكتل','تعلّم من خلال Scratch والمشاريع المرئية والتفكير البرمجي.',2),
('python','Python Programming','لغة البداية العملية','تعلم Python من الأساسيات إلى البرمجة الكائنية والتطبيقات.',3),
('web-development','Web Development','بناء مواقع الويب','HTML وCSS وJavaScript ثم بناء واجهات ويب تفاعلية.',4),
('programming-languages','Programming Languages','لغات متعددة','التعرف المنهجي على C وC++ وJava وC# ومتى تستخدم كل لغة.',5),
('databases-backend','Databases & Backend','البيانات والخوادم','SQL وقواعد البيانات وواجهات API ومنطق الخادم.',6),
('mobile-development','Mobile App Development','تطبيقات الموبايل','مبادئ تطبيقات الهاتف ثم Flutter وDart.',7),
('ai-data','AI & Data Science','الذكاء الاصطناعي والبيانات','تحليل البيانات ومبادئ تعلم الآلة والذكاء الاصطناعي.',8),
('developer-tools','Professional Developer Tools','أدوات المطور','Git وGitHub والاختبار وتصحيح الأخطاء والنشر.',9),
('real-world-projects','Real-World Projects','مشاريع متكاملة','تطبيق المعرفة في مشاريع عملية وبناء ملف أعمال.',10)
on conflict(id) do nothing;
insert into public.programming_modules(id,track_id,title,description,sort_order) values
('cs-start-here','computer-science','أول خطوة في عالم البرمجة','تعرف على الكمبيوتر والبرامج والبيانات وكيف يفكر المبرمج.',1),
('visual-first-projects','visual-programming','التفكير بالبرمجة المرئية','بناء تتابعات وأحداث وشروط وحلقات بمشاريع مرئية.',1),
('python-foundations','python','أساسيات Python','كتابة أول برنامج وفهم البيانات والتحكم في التنفيذ.',1),
('web-foundations','web-development','أساسيات الويب','فهم المتصفح وHTML وCSS وJavaScript.',1),
('languages-overview','programming-languages','اختيار وفهم اللغات','مقارنة اللغات ومجالات استخدامها ومفاهيمها المشتركة.',1),
('backend-foundations','databases-backend','مقدمة قواعد البيانات والخوادم','تنظيم البيانات وفهم الطلبات والاستجابات.',1),
('mobile-foundations','mobile-development','مقدمة تطبيقات الهاتف','فهم واجهات التطبيقات وتصميم تجربة الاستخدام.',1),
('ai-foundations','ai-data','مقدمة الذكاء الاصطناعي','البيانات والنماذج والتعلم الآلي بصورة مبسطة.',1),
('tools-foundations','developer-tools','بيئة المطور المحترف','إدارة الملفات والإصدارات والاختبار.',1),
('project-foundations','real-world-projects','من الفكرة إلى المشروع','تخطيط مشروع صغير وتنفيذه واختباره وعرضه.',1)
on conflict(id) do nothing;
insert into public.programming_lessons(id,module_id,title,summary,content_md,duration_minutes,sort_order,published) values
('cs-01-what-is-programming','cs-start-here','يعني إيه برمجة؟','فهم معنى البرمجة ودور المبرمج والفرق بين البرنامج ولغة البرمجة.',
E'## ما هي البرمجة؟\nالبرمجة هي كتابة تعليمات واضحة ومنظمة للكمبيوتر حتى ينفذ مهمة معينة. الكمبيوتر سريع جدًا في تنفيذ التعليمات، لكنه يحتاج أن تكون التعليمات محددة وخالية من الغموض.\n\n## البرنامج ولغة البرمجة\n- **البرنامج:** مجموعة تعليمات تحل مشكلة أو تنفذ مهمة.\n- **لغة البرمجة:** طريقة منظمة لكتابة هذه التعليمات، مثل Python أو JavaScript.\n- **المبرمج:** الشخص الذي يفهم المشكلة ويصمم خطوات الحل ثم يختبرها.\n\n## مثال من الحياة\nعندما نطلب من تطبيق حساب مجموع رقمين، يستقبل التطبيق الرقمين، يجمعهما، ثم يعرض النتيجة. هذه خطوات يمكن تحويلها إلى برنامج.\n\n## تذكّر\nالبرمجة ليست حفظ أكواد؛ إنها فهم المشكلة وتقسيمها إلى خطوات منطقية.',12,1,true),
('cs-02-how-computers-work','cs-start-here','كيف يفهم الكمبيوتر التعليمات؟','تعرف على المدخلات والمعالجة والمخرجات والذاكرة بصورة مبسطة.',
E'## نموذج بسيط لعمل الكمبيوتر\nيمكن فهم كثير من البرامج من خلال ثلاث مراحل:\n1. **Input – المدخلات:** البيانات التي يستقبلها البرنامج.\n2. **Processing – المعالجة:** العمليات التي ينفذها على البيانات.\n3. **Output – المخرجات:** النتيجة التي يعرضها.\n\n## مثال\nفي برنامج جمع رقمين: الرقم الأول والثاني مدخلات، عملية الجمع هي المعالجة، والناتج هو المخرج.\n\n## مصطلحات مهمة\n- Hardware: المكونات المادية مثل الشاشة ولوحة المفاتيح.\n- Software: البرامج والتطبيقات.\n- Memory: الذاكرة التي يحتفظ فيها الكمبيوتر بالبيانات أثناء العمل.\n\nجرّب أن تحدد المدخلات والمعالجة والمخرجات في تطبيق الطقس أو الآلة الحاسبة.',12,2,true),
('cs-03-algorithms','cs-start-here','ما هي الخوارزمية؟','تعلم كتابة خطوات مرتبة لحل مشكلة قبل تحويلها إلى كود.',
E'## الخوارزمية Algorithm\nالخوارزمية هي مجموعة خطوات مرتبة ومحددة لحل مشكلة أو تنفيذ مهمة. لا يشترط أن تكون مكتوبة بلغة برمجة.\n\n## مثال: تحضير كوب ماء بارد\n1. أحضر كوبًا.\n2. أضف الماء.\n3. أضف مكعبات الثلج.\n4. قدّم الكوب.\n\n## صفات الخطوات الجيدة\n- واضحة ولا تحتمل أكثر من معنى.\n- مرتبة ترتيبًا منطقيًا.\n- لها بداية ونهاية.\n- قابلة للتنفيذ.\n\nقبل كتابة الكود، اكتب خطوات الحل بلغتك العادية. هذا يقلل الأخطاء ويساعدك على التفكير كمبرمج.',15,3,true),
('cs-04-flowcharts','cs-start-here','مخططات التدفق Flowcharts','حوّل خطوات الحل إلى رسم يوضح مسار تنفيذ البرنامج.',
E'## ما هو مخطط التدفق؟\nهو رسم يستخدم أشكالًا وأسهمًا لعرض خطوات الخوارزمية بصريًا.\n\n## رموز شائعة\n- الشكل البيضاوي: البداية أو النهاية.\n- المستطيل: عملية أو تعليمة.\n- متوازي الأضلاع: إدخال أو إخراج.\n- المعين: اتخاذ قرار مثل نعم أو لا.\n- الأسهم: اتجاه تنفيذ الخطوات.\n\n## مثال\nابدأ ← أدخل درجة الطالب ← هل الدرجة أكبر من أو تساوي 50؟ ← نعم: ناجح / لا: يحتاج إلى مراجعة ← انتهِ.\n\nارسم مخططًا بسيطًا لبرنامج يحدد هل الرقم زوجي أم فردي. لا تقلق بشأن الكود الآن؛ ركّز على منطق الحل.',15,4,true)
on conflict(id) do nothing;
