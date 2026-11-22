const DOMA_TURNSTILE_SITE_KEY="0x4AAAAAAGNDTdw2eFVxVWz-";
const DOMA_TURNSTILE_HOSTNAMES=["doma1.pages.dev","doma-academy.pages.dev"];
function json(body,status=200){return new Response(JSON.stringify(body),{status,headers:{"content-type":"application/json; charset=utf-8","cache-control":"no-store"}});}
function allowedHosts(env){return [...new Set([...DOMA_TURNSTILE_HOSTNAMES,...String(env.TURNSTILE_HOSTNAMES||"").split(",")].map(v=>v.trim().toLowerCase()).filter(Boolean))];}
function ipRateKey(ip){if(!ip.includes(":")||ip.includes("."))return ip;const[head,tail]=ip.split("::"),h=head?head.split(":"):[],t=tail?tail.split(":"):[],full=tail===undefined?h:[...h,...Array(Math.max(0,8-h.length-t.length)).fill("0"),...t];return full.slice(0,4).map(g=>g.padStart(4,"0")).join(":")+"::/64";}
async function hmacHex(secret,message){const enc=new TextEncoder(),key=await crypto.subtle.importKey("raw",enc.encode(secret),{name:"HMAC",hash:"SHA-256"},false,["sign"]),sig=await crypto.subtle.sign("HMAC",key,enc.encode(message));return[...new Uint8Array(sig)].map(b=>b.toString(16).padStart(2,"0")).join("");}
export async function onRequestPost({request,env}){
 try{
  const base=String(env.SUPABASE_URL||"").replace(/\/+$/,""),key=env.SUPABASE_SERVICE_ROLE_KEY,secret=env.TURNSTILE_SECRET,ipSecret=env.IP_HASH_SECRET,hosts=allowedHosts(env);
  if(!base||!key||!secret||!ipSecret)return json({error:"Signup protection is not fully configured."},503);
  const url=new URL(request.url),origin=request.headers.get("Origin");
  if(!origin||!hosts.includes(url.hostname.toLowerCase()))return json({error:"Origin not allowed."},403);
  let originHost="";try{originHost=new URL(origin).host.toLowerCase();}catch{return json({error:"Origin not allowed."},403);}
  if(originHost!==url.host.toLowerCase())return json({error:"Origin not allowed."},403);
  const ip=request.headers.get("CF-Connecting-IP")||"";if(!ip)return json({error:"Could not validate request source."},403);
  const body=await request.json().catch(()=>null),token=typeof body?.token==="string"?body.token.trim():"";
  const name=typeof body?.name==="string"?body.name.trim():"",email=typeof body?.email==="string"?body.email.trim().toLowerCase():"",favoritePlayer=typeof body?.favoritePlayer==="string"?body.favoritePlayer.trim().slice(0,60):"";
  if(!token||token.length>2048)return json({error:"Complete security verification first."},400);
  if(!name||name.length>100)return json({error:"Enter a valid name."},400);
  if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)||email.length>254)return json({error:"Enter a valid email address."},400);
  if(!["","Lionel Messi","Cristiano Ronaldo"].includes(favoritePlayer))return json({error:"Choose a valid favorite player."},400);
  if(body?.termsAccepted!==true)return json({error:"Please agree to the Terms & Conditions."},400);
  const verify=await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded"},body:new URLSearchParams({secret,response:token,remoteip:ip})});
  if(!verify.ok)return json({error:"Security verification is temporarily unavailable."},503);
  const v=await verify.json();if(!v?.success||v.action!=="signup"||!hosts.includes(String(v.hostname||"").toLowerCase()))return json({error:"Verification failed. Please try again."},403);
  const hash=await hmacHex(ipSecret,ipRateKey(ip)),rpc=await fetch(base+"/rest/v1/rpc/doma_allow_signup_ip",{method:"POST",headers:{apikey:key,Authorization:"Bearer "+key,"Content-Type":"application/json"},body:JSON.stringify({p_ip_hash:hash})});
  if(!rpc.ok)return json({error:"Signup protection temporarily unavailable."},503);if(await rpc.json()!==true)return json({error:"Too many signup attempts. Please wait and try again later."},429);
  const existing=await fetch(base+"/rest/v1/profiles?select=id&email=eq."+encodeURIComponent(email)+"&limit=1",{headers:{apikey:key,Authorization:"Bearer "+key}});
  if(!existing.ok)return json({error:"Could not verify account availability."},503);if((await existing.json()).length)return json({error:"An account already exists for this email. Try logging in."},409);
  const otp=await fetch(base+"/auth/v1/otp",{method:"POST",headers:{apikey:key,"Content-Type":"application/json"},body:JSON.stringify({email,create_user:true,data:{full_name:name,name,favorite_player:favoritePlayer,login_method:"email_otp",favorite_team:favoritePlayer==="Lionel Messi"?"Barcelona":favoritePlayer==="Cristiano Ronaldo"?"Real Madrid":""}})});
  if(!otp.ok){const err=await otp.json().catch(()=>null);const msg=String(err?.msg||err?.message||err?.error_description||"");if(/already|registered|exists/i.test(msg))return json({error:"An account may already exist for this email. Try logging in."},409);console.error("Supabase OTP request failed",{status:otp.status});return json({error:"Could not send verification code. Please try again."},502);}
  return json({ok:true,message:"Verification code sent."});
 }catch(e){console.error("DOMA email OTP signup error",e instanceof Error?e.message:"unknown");return json({error:"Signup verification temporarily unavailable."},503);}
}