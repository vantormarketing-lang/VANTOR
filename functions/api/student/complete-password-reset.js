function json(body,status=200) {
  return new Response(JSON.stringify(body),{status,headers:{"content-type":"application/json; charset=utf-8","cache-control":"no-store"}});
}
async function readJson(response) { try{return await response.json()}catch{return {}} }
export async function onRequestPost({request,env}) {
  if(request.headers.get("origin") && request.headers.get("origin")!==new URL(request.url).origin)
    return json({error:"Cross-origin request rejected"},403);
  const url=String(env.SUPABASE_URL||"").replace(/\/+$/,"");
  const key=String(env.SUPABASE_SERVICE_ROLE_KEY||"");
  if(!url||!key) return json({error:"Server password-change credentials are not configured"},503);
  const token=(request.headers.get("authorization")||"").replace(/^Bearer\s+/i,"").trim();
  if(!token) return json({error:"Sign in again to continue"},401);
  try {
    const userResponse=await fetch(url+"/auth/v1/user",{headers:{apikey:key,authorization:"Bearer "+token}});
    const user=await readJson(userResponse);
    if(!userResponse.ok||!user.id) return json({error:"Your session expired. Sign in again."},401);
    if(user.app_metadata?.must_change_password!==true)
      return json({error:"This account does not require a temporary-password change"},403);
    const body=await request.json().catch(()=>({}));
    const password=String(body.password||"");
    if(password.length<10||password.length>72)
      return json({error:"Choose a password between 10 and 72 characters"},400);
    const metadata={...(user.app_metadata||{}),must_change_password:false};
    const update=await fetch(url+"/auth/v1/admin/users/"+encodeURIComponent(user.id),{
      method:"PUT",
      headers:{apikey:key,authorization:"Bearer "+key,"content-type":"application/json"},
      body:JSON.stringify({password,app_metadata:metadata})
    });
    const result=await readJson(update);
    if(!update.ok) return json({error:"Could not save the new password"},502);
    return json({ok:true});
  } catch(error) {
    console.error("[complete-password-reset] password update failed", {
      name: error && error.name ? String(error.name).slice(0,80) : "UnknownError"
    });
    return json({error:"تعذر تغيير كلمة المرور حاليًا. حاول مرة أخرى بعد قليل."},500);
  }
}
