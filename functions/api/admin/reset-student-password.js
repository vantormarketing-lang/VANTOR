function json(body, status=200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" }
  });
}
function envConfig(env) {
  const url=String(env.SUPABASE_URL||"").replace(/\/+$/,"");
  const key=String(env.SUPABASE_SERVICE_ROLE_KEY||"");
  return url&&key?{url,key}:null;
}
async function readJson(response) {
  try { return await response.json(); } catch { return {}; }
}
async function authUser(request, cfg) {
  const token=(request.headers.get("authorization")||"").replace(/^Bearer\s+/i,"").trim();
  if(!token) return {error:"Missing authenticated session",status:401};
  const r=await fetch(cfg.url+"/auth/v1/user",{
    headers:{apikey:cfg.key,authorization:"Bearer "+token}
  });
  const data=await readJson(r);
  if(!r.ok||!data.id) return {error:"Invalid or expired session",status:401};
  return {user:data,token};
}
async function profile(cfg,id) {
  const q=await fetch(cfg.url+"/rest/v1/profiles?id=eq."+encodeURIComponent(id)+"&select=id,role,phone,full_name",{
    headers:{apikey:cfg.key,authorization:"Bearer "+cfg.key}
  });
  const rows=await readJson(q);
  if(!q.ok||!Array.isArray(rows)) throw new Error("Could not verify account profile");
  return rows[0]||null;
}
async function authAdminUser(cfg,id) {
  const r=await fetch(cfg.url+"/auth/v1/admin/users/"+encodeURIComponent(id),{
    headers:{apikey:cfg.key,authorization:"Bearer "+cfg.key}
  });
  const data=await readJson(r);
  if(!r.ok||!data.id) throw new Error("Could not load target Auth account");
  return data;
}
function makeTemporaryPassword() {
  const alphabet="ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
  const out=[];
  const ceiling=Math.floor(256/alphabet.length)*alphabet.length;
  while(out.length<10) {
    const bytes=new Uint8Array(16);
    crypto.getRandomValues(bytes);
    for(const b of bytes) {
      if(b>=ceiling) continue;
      out.push(alphabet[b%alphabet.length]);
      if(out.length===10) break;
    }
  }
  return out.join("");
}
export async function onRequestPost({request,env}) {
  if(request.headers.get("origin") && request.headers.get("origin")!==new URL(request.url).origin)
    return json({error:"Cross-origin request rejected"},403);
  const cfg=envConfig(env);
  if(!cfg) return json({error:"Server reset credentials are not configured"},503);
  try {
    const auth=await authUser(request,cfg);
    if(auth.error) return json({error:auth.error},auth.status);
    const actor=await profile(cfg,auth.user.id);
    if(!actor||String(actor.role).toLowerCase()!=="admin")
      return json({error:"Only an administrator can reset student passwords"},403);
    const body=await request.json().catch(()=>({}));
    const studentId=String(body.student_id||"");
    if(!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(studentId))
      return json({error:"Invalid student account"},400);
    const student=await profile(cfg,studentId);
    if(!student||String(student.role).toLowerCase()!=="student")
      return json({error:"Student account was not found"},404);
    const target=await authAdminUser(cfg,studentId);
    const temporaryPassword=makeTemporaryPassword();
    const appMetadata={...(target.app_metadata||{}),must_change_password:true};
    const update=await fetch(cfg.url+"/auth/v1/admin/users/"+encodeURIComponent(studentId),{
      method:"PUT",
      headers:{apikey:cfg.key,authorization:"Bearer "+cfg.key,"content-type":"application/json"},
      body:JSON.stringify({password:temporaryPassword,app_metadata:appMetadata})
    });
    const result=await readJson(update);
    if(!update.ok) return json({error:"Supabase could not reset this account"},502);
    return json({ok:true,temporary_password:temporaryPassword,student:{name:student.full_name||"",phone:student.phone||""}});
  } catch(error) {
    return json({error:error?.message||"Password reset failed"},500);
  }
}
