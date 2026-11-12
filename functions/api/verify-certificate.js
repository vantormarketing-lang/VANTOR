function json(body,status=200){
  return new Response(JSON.stringify(body),{
    status,
    headers:{"content-type":"application/json; charset=utf-8","cache-control":"no-store"}
  });
}
async function readJson(response){try{return await response.json()}catch{return null}}
export async function onRequestPost({request,env}){
  const origin=request.headers.get("Origin");
  if(origin&&origin!==new URL(request.url).origin)return json({error:"Origin not allowed."},403);
  const base=String(env.SUPABASE_URL||"").replace(/\/+$/,"").replace(/\/rest\/v1$/i,"");
  const key=String(env.SUPABASE_SERVICE_ROLE_KEY||"");
  if(!base||!key)return json({error:"Verification service is unavailable."},503);
  const body=await request.json().catch(()=>({}));
  const code=String(body.code||"").trim();
  if(code.length<8||code.length>80)return json({error:"Invalid certificate code."},400);
  const ip=String(request.headers.get("CF-Connecting-IP")||"").trim();
  if(!ip)return json({error:"Request could not be verified."},503);
  const headers={apikey:key,authorization:"Bearer "+key,"content-type":"application/json"};
  try{
    const quotaResponse=await fetch(base+"/rest/v1/rpc/doma_allow_certificate_lookup",{
      method:"POST",headers,body:JSON.stringify({p_ip:ip})
    });
    if(!quotaResponse.ok)return json({error:"Verification service is temporarily unavailable."},503);
    const allowed=await readJson(quotaResponse);
    if(allowed!==true)return json({error:"Too many certificate lookups."},429);
    const lookup=await fetch(base+"/rest/v1/rpc/programming_lookup_certificate",{
      method:"POST",headers,body:JSON.stringify({p_code:code})
    });
    if(!lookup.ok)return json({error:"Verification service is temporarily unavailable."},503);
    const rows=await readJson(lookup);
    const certificate=Array.isArray(rows)?rows[0]||null:null;
    return json({certificate});
  }catch(error){
    console.error("[certificate-verify-api]",error&&error.name||"Error");
    return json({error:"Verification service is temporarily unavailable."},503);
  }
}
