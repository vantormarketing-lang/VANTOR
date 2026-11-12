const LANGUAGE_IDS = {
  python: 109,
  javascript: 102,
  c: 103,
  cpp: 105,
  java: 91,
  csharp: 51,
  php: 98,
  go: 107,
  ruby: 72,
  rust: 108,
  kotlin: 111,
  swift: 83,
  dart: 90
};

const json = (body, status = 200) => new Response(JSON.stringify(body), {
  status,
  headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" }
});

export async function onRequestPost({ request, env }) {
  try {
    const origin = request.headers.get("Origin");
    const requestOrigin = new URL(request.url).origin;
    if (origin && origin !== requestOrigin) return json({ error: "Origin not allowed." }, 403);

    const authorization = request.headers.get("Authorization") || "";
    if (!authorization.startsWith("Bearer ")) return json({ error: "سجّل الدخول أولًا." }, 401);
    const accessToken = authorization.slice(7).trim();
    if (!accessToken || accessToken.length > 8192) return json({ error: "جلسة الدخول غير صالحة." }, 401);

    const configuredSupabaseUrl = env.SUPABASE_URL;
    const anonKey = env.SUPABASE_ANON_KEY;
    const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;
    const missingConfig = [!configuredSupabaseUrl && "SUPABASE_URL", !anonKey && "SUPABASE_ANON_KEY", !serviceKey && "SUPABASE_SERVICE_ROLE_KEY"].filter(Boolean);
    if (missingConfig.length) return json({ error: `إعدادات التحقق من حساب DOMA غير مكتملة. المتغيرات غير المتاحة: ${missingConfig.join(", ")}` }, 503);

    let supabaseOrigin;
    try {
      supabaseOrigin = new URL(configuredSupabaseUrl.trim()).origin;
      if (!supabaseOrigin || !/^https:\/\//i.test(supabaseOrigin)) throw new Error("Invalid Supabase URL");
    } catch (_) {
      return json({ error: "قيمة SUPABASE_URL غير صالحة. استخدم رابط مشروع Supabase الأساسي بصيغة https://PROJECT_REF.supabase.co" }, 503);
    }

    const authResponse = await fetch(`${supabaseOrigin}/auth/v1/user`, {
      headers: { apikey: anonKey, Authorization: `Bearer ${accessToken}` }
    });
    if (!authResponse.ok) {
      if (authResponse.status === 401) return json({ error: "انتهت جلسة الدخول أو لم تعد صالحة. حدّث تسجيل الدخول ثم حاول مرة أخرى." }, 401);
      const authContentType = authResponse.headers.get("content-type") || "unknown";
      let authErrorDetail = "";
      try {
        const rawAuthError = await authResponse.text();
        authErrorDetail = rawAuthError.replace(/[\r\n\t]+/g, " ").slice(0, 400);
      } catch (_) {}
      console.error("[code-run] Supabase auth verification failed", {
        status: authResponse.status,
        contentType: authContentType,
        response: authErrorDetail || "No response body"
      });
      return json({ error: "تعذر التحقق من جلسة DOMA حاليًا. حاول مرة أخرى بعد قليل." }, 502);
    }
    const authUser = await authResponse.json();
    if (!authUser || !authUser.id) return json({ error: "تعذر التحقق من حسابك." }, 401);

    const adminHeaders = { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` };
    const profileUrl = new URL(`${supabaseOrigin}/rest/v1/profiles`);
    profileUrl.searchParams.set("id", `eq.${authUser.id}`);
    profileUrl.searchParams.set("select", "role");
    profileUrl.searchParams.set("limit", "1");
    const profileResponse = await fetch(profileUrl, { headers: adminHeaders });
    const profiles = profileResponse.ok ? await profileResponse.json() : [];
    const isStaff = profiles.some(p => p.role === "admin" || p.role === "teacher");

    let hasActiveSubscription = false;
    if (!isStaff) {
      const subscriptionUrl = new URL(`${supabaseOrigin}/rest/v1/programming_course_subscriptions`);
      subscriptionUrl.searchParams.set("student_id", `eq.${authUser.id}`);
      subscriptionUrl.searchParams.set("status", "eq.active");
      subscriptionUrl.searchParams.set("starts_at", `lte.${new Date().toISOString()}`);
      subscriptionUrl.searchParams.set("expires_at", `gt.${new Date().toISOString()}`);
      subscriptionUrl.searchParams.set("select", "id");
      subscriptionUrl.searchParams.set("limit", "1");
      const subscriptionResponse = await fetch(subscriptionUrl, { headers: adminHeaders });
      const subscriptions = subscriptionResponse.ok ? await subscriptionResponse.json() : [];
      hasActiveSubscription = Array.isArray(subscriptions) && subscriptions.length > 0;
    }
    if (!isStaff && !hasActiveSubscription) return json({ error: "تشغيل الأكواد متاح لأصحاب الاشتراك النشط في أكاديمية البرمجة." }, 403);

    const body = await request.json();
    const language = String(body.language || "");
    const languageId = LANGUAGE_IDS[language];
    const sourceCode = String(body.source_code || "");
    const stdin = String(body.stdin || "");
    const exerciseId = String(body.exercise_id || "").trim();
    const lessonId = String(body.lesson_id || "").trim();
    if (!languageId) return json({ error: "لغة البرمجة غير مدعومة حاليًا." }, 400);
    if (!sourceCode.trim()) return json({ error: "اكتب الكود أولًا." }, 400);
    if (sourceCode.length > 16000 || stdin.length > 2000) return json({ error: "حجم الكود أو بيانات الإدخال أكبر من الحد المسموح." }, 413);
    if (!env.JUDGE0_URL) return json({ error: "خدمة تشغيل الأكواد لم تُربط بعد. سيتم تفعيلها فور إعداد خادم التشغيل." }, 503);

    // For graded exercises, load the authoritative test cases from the database.
    // Never trust test definitions supplied by the browser.
    let exerciseTests = null;
    if (exerciseId) {
      if (!/^[0-9a-f-]{36}$/i.test(exerciseId)) return json({ error: "معرّف التدريب غير صالح." }, 400);
      const exerciseUrl = new URL(`${supabaseOrigin}/rest/v1/programming_exercises`);
      exerciseUrl.searchParams.set("id", `eq.${exerciseId}`);
      exerciseUrl.searchParams.set("select", "id,lesson_id,language,test_cases,is_published");
      exerciseUrl.searchParams.set("limit", "1");
      const exerciseResponse = await fetch(exerciseUrl, { headers: adminHeaders });
      if (!exerciseResponse.ok) {
        console.error("[code-run] exercise lookup failed", { status: exerciseResponse.status });
        return json({ error: "تعذر تحميل اختبارات التدريب حاليًا." }, 503);
      }
      const exerciseRows = await exerciseResponse.json().catch(() => []);
      const exercise = Array.isArray(exerciseRows) ? exerciseRows[0] : null;
      if (!exercise || exercise.is_published !== true) return json({ error: "التدريب غير متاح." }, 404);
      if (exercise.language !== language || (lessonId && exercise.lesson_id !== lessonId)) {
        return json({ error: "لغة التدريب أو الدرس لا تطابق الطلب." }, 400);
      }
      exerciseTests = Array.isArray(exercise.test_cases) ? exercise.test_cases : [];
      if (!exerciseTests.length || exerciseTests.some(test => !test || typeof test.contains !== "string")) {
        return json({ error: "اختبارات هذا التدريب غير مكتملة." }, 409);
      }
    }

    // Consume a database-backed per-user quota before contacting Judge0.
    // The RPC is atomic, so concurrent requests cannot bypass the limits.
    let quotaResponse;
    try {
      quotaResponse = await fetch(`${supabaseOrigin}/rest/v1/rpc/doma_consume_code_run_quota`, {
        method: "POST",
        headers: { ...adminHeaders, "content-type": "application/json" },
        body: JSON.stringify({ p_user_id: authUser.id })
      });
    } catch (_) {
      return json({ error: "تعذر التحقق من حد تشغيل الأكواد حاليًا. حاول مرة أخرى بعد قليل." }, 503);
    }
    if (!quotaResponse.ok) {
      console.error("[code-run] quota RPC failed", { status: quotaResponse.status });
      return json({ error: "خدمة حماية تشغيل الأكواد غير متاحة حاليًا. لم يتم إرسال الكود للتشغيل." }, 503);
    }
    const quotaRows = await quotaResponse.json().catch(() => []);
    const quota = Array.isArray(quotaRows) ? quotaRows[0] : null;
    if (!quota || typeof quota.allowed !== "boolean") {
      console.error("[code-run] quota RPC returned an invalid response");
      return json({ error: "تعذر تأكيد حد تشغيل الأكواد. لم يتم إرسال الكود للتشغيل." }, 503);
    }
    if (!quota.allowed) {
      const retryAfter = Math.max(1, Number(quota.retry_after_seconds) || 60);
      const message = quota.limit_type === "day"
        ? "وصلت للحد اليومي لتشغيل الأكواد (50 مرة). حاول مرة أخرى بعد تجديد الحد اليومي."
        : "وصلت للحد المسموح لتشغيل الأكواد في الدقيقة (5 مرات). انتظر قليلًا ثم حاول مرة أخرى.";
      return new Response(JSON.stringify({ error: message, retry_after_seconds: retryAfter }), {
        status: 429,
        headers: {
          "content-type": "application/json; charset=utf-8",
          "cache-control": "no-store",
          "retry-after": String(retryAfter)
        }
      });
    }

    const judgeUrl = new URL("/submissions/?base64_encoded=false&wait=false", env.JUDGE0_URL);
    const judgeHeaders = { "content-type": "application/json" };
    const authHeader = String(env.JUDGE0_AUTH_HEADER || "X-Auth-Token").trim();
    if (env.JUDGE0_AUTH_TOKEN && /^[A-Za-z0-9-]{1,80}$/.test(authHeader)) {
      judgeHeaders[authHeader] = env.JUDGE0_AUTH_TOKEN;
    }
    if (env.JUDGE0_AUTH_HOST) judgeHeaders["X-RapidAPI-Host"] = env.JUDGE0_AUTH_HOST;

    const judgeResponse = await fetch(judgeUrl, {
      method: "POST",
      headers: judgeHeaders,
      body: JSON.stringify({
        language_id: languageId,
        source_code: sourceCode,
        stdin,
        cpu_time_limit: 2,
        cpu_extra_time: 0.5,
        wall_time_limit: 6,
        memory_limit: 128000,
        stack_limit: 64000,
        max_processes_and_or_threads: 20,
        max_file_size: 1024,
        enable_network: false,
        number_of_runs: 1
      })
    });
    let result = await judgeResponse.json().catch(() => ({}));
    if (!judgeResponse.ok) return json({ error: result.error || "خدمة التشغيل لم تستطع تنفيذ البرنامج الآن." }, 502);

    // Shared Judge0 Cloud plans may disable wait=true, so poll the submission token.
    if (result.token && (!result.status || result.status.id === 1 || result.status.id === 2)) {
      const pollUrl = new URL(`/submissions/${encodeURIComponent(result.token)}?base64_encoded=false`, env.JUDGE0_URL);
      for (let attempt = 0; attempt < 10; attempt++) {
        await new Promise(resolve => setTimeout(resolve, 500));
        const pollResponse = await fetch(pollUrl, { headers: judgeHeaders });
        if (!pollResponse.ok) break;
        result = await pollResponse.json().catch(() => ({}));
        if (result.status && result.status.id > 2) break;
      }
    }
    if (!result.status || result.status.id === 1 || result.status.id === 2) {
      return json({ error: "خدمة التشغيل استلمت الكود، لكنها مزدحمة حاليًا. حاول مرة أخرى بعد قليل." }, 503);
    }
    const stdout = result.stdout || "";
    const stderr = result.stderr || "";
    const compileOutput = result.compile_output || "";
    const executionAccepted = !!(result.status && result.status.id === 3);
    const testResults = exerciseTests ? exerciseTests.map(test => ({
      label: String(test.label || "فحص الناتج"),
      passed: executionAccepted && stdout.includes(test.contains)
    })) : null;
    const allTestsPassed = !!(exerciseTests && executionAccepted && !stderr && !compileOutput &&
      testResults.every(test => test.passed));

    return json({
      stdout,
      stderr,
      compile_output: compileOutput,
      status: result.status && result.status.description ? result.status.description : "انتهى التشغيل",
      time: result.time || null,
      memory: result.memory || null,
      ...(testResults ? { test_results: testResults, all_tests_passed: allTestsPassed } : {})
    });
  } catch (error) {
    return json({ error: "حدث خطأ مؤقت أثناء تشغيل الكود. حاول مرة أخرى." }, 500);
  }
}
