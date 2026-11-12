function json(body, status=200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" }
  });
}
function config(env) {
  // Accept either the project URL or a URL that already includes /rest/v1.
  const url=String(env.SUPABASE_URL||"").replace(/\/+$/,"").replace(/\/rest\/v1$/i,"");
  const key=String(env.SUPABASE_SERVICE_ROLE_KEY||"");
  return url&&key?{url,key}:null;
}
async function readJson(response) {
  try { return await response.json(); } catch { return {}; }
}
function normalizePhone(value) {
  let digits=String(value||"").replace(/\D/g,"");
  if(digits.startsWith("0020")) digits=digits.slice(2);
  if(digits.startsWith("0")) digits="20"+digits.slice(1);
  if(!digits.startsWith("20")) digits="20"+digits;
  return /^20\d{10}$/.test(digits)?digits:null;
}
export async function onRequestPost({request,env}) {
  if(request.headers.get("origin") && request.headers.get("origin")!==new URL(request.url).origin)
    return json({error:"Cross-origin request rejected"},403);
  const cfg=config(env);
  if(!cfg) return json({error:"Password reset request service is not configured"},503);
  try {
    const body=await request.json().catch(()=>({}));
    const phone=normalizePhone(body.phone);
    if(!phone) return json({error:"Enter a valid Egyptian mobile number"},400);

    // Cloudflare supplies this header from the connecting client, so callers cannot
    // choose the IP key used by the server-side rate limiter.
    const clientIp=String(request.headers.get("CF-Connecting-IP")||"").trim();
    if(!clientIp) return json({error:"Request could not be verified. Please try again later."},503);
    const ipLimit=await fetch(cfg.url+"/rest/v1/rpc/doma_allow_password_reset_ip",{
      method:"POST",
      headers:{apikey:cfg.key,authorization:"Bearer "+cfg.key,"content-type":"application/json"},
      body:JSON.stringify({p_ip:clientIp})
    });
    if(!ipLimit.ok) {
      console.error("[password-reset-request] IP rate-limit check failed", {status:ipLimit.status});
      return json({error:"Password recovery is temporarily unavailable. Please try again later."},503);
    }
    const ipAllowed=await readJson(ipLimit);
    if(ipAllowed!==true)
      return json({error:"Too many requests from this connection. Please wait 15 minutes and try again."},429);

    const since=new Date(Date.now()-15*60*1000).toISOString();
    const recentUrl=cfg.url+"/rest/v1/password_reset_requests?"+new URLSearchParams({
      select:"id",phone:"eq."+phone,created_at:"gte."+since,order:"created_at.desc",limit:"3"
    }).toString();
    const recentResponse=await fetch(recentUrl,{
      headers:{apikey:cfg.key,authorization:"Bearer "+cfg.key}
    });
    const recent=await readJson(recentResponse);
    if(!recentResponse.ok) throw new Error("Could not check request rate limit");
    if(Array.isArray(recent)&&recent.length>=3)
      return json({error:"A request was already received recently. Please wait a few minutes."},429);

    const local="0"+phone.slice(2);
    const lookupParams=new URLSearchParams({
      select:"id",role:"eq.student",
      or:"(phone.eq."+local+",phone.eq."+phone+",phone.eq.+"+phone+")",
      limit:"1"
    });
    const lookup=await fetch(cfg.url+"/rest/v1/profiles?"+lookupParams.toString(),{
      headers:{apikey:cfg.key,authorization:"Bearer "+cfg.key}
    });
    const matches=await readJson(lookup);
    if(!lookup.ok||!Array.isArray(matches)) throw new Error("Could not process the request");

    // Keep the public response identical for unknown numbers, but do not create
    // orphaned admin-queue rows that cannot be tied to a student account.
    if(matches.length===0) return json({ok:true});

    const insert=await fetch(cfg.url+"/rest/v1/password_reset_requests",{
      method:"POST",
      headers:{apikey:cfg.key,authorization:"Bearer "+cfg.key,"content-type":"application/json",prefer:"return=minimal"},
      body:JSON.stringify({phone,student_id:matches[0].id})
    });
    if(!insert.ok) throw new Error("Could not save the request");
    return json({ok:true});
  } catch(error) {
    console.error("[password-reset-request] request failed", {
      name: error && error.name ? String(error.name).slice(0,80) : "UnknownError"
    });
    return json({error:"تعذر استقبال طلب الاسترجاع حاليًا. حاول مرة أخرى لاحقًا."},500);
  }
}
