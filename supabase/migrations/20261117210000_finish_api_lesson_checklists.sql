-- Complete the API lesson checklists and documentation sections.
update public.programming_lessons set content_md=rtrim(content_md)||E'\n\n'||$last_0$## 8. توثيق أمثلة واقعية

أضف مثالًا لاستجابة القائمة يتضمن data وpagination، وحدد هل total يمثل كل النتائج أم النتائج بعد التصفية. وثّق ترتيب النتائج حتى لا تتغير بصورة عشوائية بين الصفحات. إذا كان العميل يرسل limit غير رقمي أو قيمة سالبة، أعد خطأ تحقق واضحًا أو استخدم قيمة افتراضية موثقة.

**مراجعة نهائية:** لا تجعل العميل يحدد أعمدة قاعدة البيانات أو يمرر نص SQL. حوّل query parameters إلى خيارات مسموحة، واستخدم معاملات قاعدة البيانات الممررة لحماية الاستعلامات من الحقن.$last_0$,updated_at=now() where id='backend-05-api-crud-pagination' and published=true and content_md not like '%## 8.%';
update public.programming_lessons set content_md=rtrim(content_md)||E'\n\n'||$last_1$## 8. انتهاء الجلسة وتجديدها

اختبر ما يحدث عندما تنتهي الجلسة أثناء استخدام التطبيق. يجب أن تتعامل الواجهة مع 401 بطريقة واضحة، مثل مطالبة المستخدم بتسجيل الدخول مجددًا، دون تكرار الطلبات بلا نهاية. لا تحاول تحويل 403 إلى إعادة تسجيل دخول تلقائية؛ فقد تكون الجلسة صالحة لكن الإذن غير متاح.

**مراجعة نهائية:** راجع كل مسار حساس، وحدد من يستطيع قراءته أو إنشاءه أو تعديله أو حذفه. اجعل الاختبار يشمل مستخدمًا يملك المورد وآخر لا يملكه، وتأكد أن قرار السماح أو الرفض يحدث على الخادم.$last_1$,updated_at=now() where id='backend-06-api-auth-errors' and published=true and content_md not like '%## 8.%';
