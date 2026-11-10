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
        authErrorDetail = rawAuthError.replace(/[\\r\\n\\t]+/g, " ").slice(0, 400);
      } catch (_) {}
      const diagnosticText = authErrorDetail || "No response body";
      return json({
        error: `تعذر التحقق من جلسة DOMA عبر Supabase (HTTP ${authResponse.status}). تفاصيل الاستجابة: ${diagnosticText}`,
        diagnostic: {
          endpoint: "Supabase Auth /auth/v1/user",
          contentType: authContentType,
          response: diagnosticText
        }
      }, 502);
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
    if (!languageId) return json({ error: "لغة البرمجة غير مدعومة حاليًا." }, 400);
    if (!sourceCode.trim()) return json({ error: "اكتب الكود أولًا." }, 400);
    if (sourceCode.length > 16000 || stdin.length > 2000) return json({ error: "حجم الكود أو بيانات الإدخال أكبر من الحد المسموح." }, 413);
    if (!env.JUDGE0_URL) return json({ error: "خدمة تشغيل الأكواد لم تُربط بعد. سيتم تفعيلها فور إعداد خادم التشغيل." }, 503);

    const judgeUrl = new URL("/submissions?base64_encoded=false&wait=false", env.JUDGE0_URL);
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
    return json({
      stdout: result.stdout || "",
      stderr: result.stderr || "",
      compile_output: result.compile_output || "",
      status: result.status && result.status.description ? result.status.description : "انتهى التشغيل",
      time: result.time || null,
      memory: result.memory || null
    });
  } catch (error) {
    return json({ error: "حدث خطأ مؤقت أثناء تشغيل الكود. حاول مرة أخرى." }, 500);
  }
}
