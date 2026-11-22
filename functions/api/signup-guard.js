export async function onRequestGet({ request, env }) {
  const allowedHostnames = String(env.TURNSTILE_HOSTNAMES || "").split(",").map(x => x.trim().toLowerCase()).filter(Boolean);
  const hostname = new URL(request.url).hostname.toLowerCase();
  if (!allowedHostnames.includes(hostname) || !env.TURNSTILE_SITE_KEY) {
    return new Response(JSON.stringify({ error: "Signup verification is unavailable." }), { status: 503, headers: { "content-type": "application/json", "cache-control": "no-store" } });
  }
  return new Response(JSON.stringify({ siteKey: env.TURNSTILE_SITE_KEY }), { status: 200, headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" } });
}

export async function onRequestPost({ request, env }) {
  const json = (body, status = 200) => new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" }
  });

  try {
    const configuredUrl = env.SUPABASE_URL;
    const anonKey = env.SUPABASE_ANON_KEY;
    const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;
    const secret = env.TURNSTILE_SECRET;
    const siteKey = env.TURNSTILE_SITE_KEY;
    const allowedHostnames = String(env.TURNSTILE_HOSTNAMES || "")
      .split(",").map(x => x.trim().toLowerCase()).filter(Boolean);

    if (!configuredUrl || !anonKey || !serviceKey || !secret || !siteKey || !allowedHostnames.length) {
      return json({ error: "Signup protection is not configured yet." }, 503);
    }

    const origin = request.headers.get("Origin");
    const requestUrl = new URL(request.url);
    if (origin && new URL(origin).host.toLowerCase() !== requestUrl.host.toLowerCase()) {
      return json({ error: "Origin not allowed." }, 403);
    }
    if (!allowedHostnames.includes(requestUrl.hostname.toLowerCase())) {
      return json({ error: "Host not allowed." }, 403);
    }

    const ip = request.headers.get("CF-Connecting-IP") || "";
    if (!ip) return json({ error: "Could not validate request source." }, 403);
    const ipHashBuffer = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(ip));
    const ipHash = [...new Uint8Array(ipHashBuffer)].map(b => b.toString(16).padStart(2, "0")).join("");

    const supabaseBase = configuredUrl.replace(/\/+$/, "");
    const limitResponse = await fetch(`${supabaseBase}/rest/v1/rpc/doma_allow_signup_ip`, {
      method: "POST",
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ p_ip_hash: ipHash })
    });
    if (!limitResponse.ok) return json({ error: "Signup protection temporarily unavailable." }, 503);
    const allowed = await limitResponse.json();
    if (allowed !== true) return json({ error: "Too many signup attempts. Please wait and try again later." }, 429);

    const body = await request.json().catch(() => null);
    const token = typeof body?.token === "string" ? body.token.trim() : "";
    if (!token || token.length > 2048) return json({ error: "Complete the verification first." }, 400);

    const verifyResponse = await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({ secret, response: token, remoteip: ip })
    });
    if (!verifyResponse.ok) return json({ error: "Verification service unavailable." }, 503);
    const verification = await verifyResponse.json();
    if (!verification?.success ||
        (verification.action !== "signup") ||
        !allowedHostnames.includes(String(verification.hostname || "").toLowerCase())) {
      return json({ error: "Verification failed. Please try again." }, 403);
    }

    return json({ ok: true });
  } catch (error) {
    return json({ error: "Signup protection temporarily unavailable." }, 503);
  }
}