/* DOMA grade carousel: scoped strictly to #gradeGrid */
(function(){
'use strict';
if(window.DomaGradesCarousel)return;
const cfg={root:'#grades',container:'#gradeGrid',min:6,width:320,step:.74,scale:.86,opacity:.55,blur:6,depth:70,tilt:12,duration:300};
let api=null;
const mod=(x,n)=>(x%n+n)%n;
function init(){
 const box=document.querySelector(cfg.container);
 if(!box||box.children.length<cfg.min||box.classList.contains('doma-cf'))return;
 const cards=[...box.children],n=cards.length;let pos=0,w=cfg.width,prev=[];
 box.classList.add('doma-cf');box.setAttribute('role','region');box.setAttribute('aria-label','Grades carousel');box.setAttribute('aria-roledescription','carousel');box.tabIndex=0;
 cards.forEach(c=>c.classList.add('doma-cf-item'));
 const style=document.createElement('style');style.id='doma-cf-style';
 style.textContent='.doma-cf{position:relative!important;display:block!important;width:100%;height:var(--cf-h)!important;overflow:hidden;perspective:1000px;touch-action:pan-y;user-select:none;cursor:grab}.doma-cf>.doma-cf-item{position:absolute!important;top:50%!important;left:50%!important;width:var(--cf-w)!important;max-width:none!important;margin:0!important;backface-visibility:hidden;will-change:transform,opacity,filter;transition:transform 300ms cubic-bezier(.2,.85,.25,1),opacity 300ms,filter 300ms}.doma-cf.is-dragging>.doma-cf-item{transition:none!important}.doma-cf-ctrl{display:flex;align-items:center;justify-content:center;gap:12px;margin:14px auto}.doma-cf-btn{width:40px;height:40px;border-radius:50%;border:1px solid rgba(255,255,255,.25);background:rgba(118,35,55,.3);color:#fff;display:grid;place-items:center;cursor:pointer}.doma-cf-dots{display:flex;gap:8px;align-items:center}.doma-cf-dot{width:8px;height:8px;border-radius:99px;border:0;background:#ffffff55;padding:0;cursor:pointer}.doma-cf-dot[aria-current=true]{width:20px;background:#fff}@media(prefers-reduced-motion:reduce){.doma-cf>.doma-cf-item{transition-duration:1ms}}';
 document.head.appendChild(style);
 const controls=document.createElement('div');controls.className='doma-cf-ctrl';
 const prevBtn=document.createElement('button'),nextBtn=document.createElement('button');[prevBtn,nextBtn].forEach(b=>{b.type='button';b.className='doma-cf-btn'});
 prevBtn.setAttribute('aria-label','Previous grade');nextBtn.setAttribute('aria-label','Next grade');
 prevBtn.innerHTML='<span aria-hidden="true">‹</span>';nextBtn.innerHTML='<span aria-hidden="true">›</span>';
 const dots=document.createElement('div');dots.className='doma-cf-dots';const dotList=cards.map((_,i)=>{const b=document.createElement('button');b.type='button';b.className='doma-cf-dot';b.setAttribute('aria-label','Go to grade '+(i+1));dots.appendChild(b);b.onclick=()=>goIndex(i);return b});
 controls.append(prevBtn,dots,nextBtn);box.insertAdjacentElement('afterend',controls);
 function measure(){w=Math.min(cfg.width,Math.max(220,Math.floor(box.clientWidth*.74)));box.style.setProperty('--cf-w',w+'px');let h=0;cards.forEach(c=>h=Math.max(h,c.offsetHeight));box.style.setProperty('--cf-h',(h+56)+'px')}
 function layout(){const step=w*cfg.step;cards.forEach((c,i)=>{let d=i-pos;d-=n*Math.round(d/n);let a=Math.abs(d),sg=d<0?-1:1,x=a<=1?d*step:sg*(step+(a-1)*step*.55),z=-Math.min(a,2)*cfg.depth,rot=Math.max(-28,Math.min(28,-d*cfg.tilt)),sc=a<=1?1-(1-cfg.scale)*a:Math.max(cfg.scale-(a-1)*.1,.6),op=a<=1?1-(1-cfg.opacity)*a:Math.max(cfg.opacity*(2-a),0);c.style.transform='translate(-50%,-50%) translate3d('+x+'px,0,'+z+'px) rotateY('+rot+'deg) scale('+sc+')';c.style.opacity=op;c.style.filter=a>0.1?'blur('+Math.min(a,1)*cfg.blur+'px)':'none';c.style.zIndex=100-Math.round(a*10);c.style.pointerEvents=a>1.6?'none':'';c.classList.toggle('is-active',i===mod(Math.round(pos),n));prev[i]=d});dotList.forEach((d,i)=>d.setAttribute('aria-current',i===mod(Math.round(pos),n)?'true':'false'))}
 function go(t){pos=t;layout()}function goIndex(i){let base=Math.round(pos),delta=i-mod(base,n);delta-=n*Math.round(delta/n);go(base+delta)}function next(){go(Math.round(pos)+1)}function prevStep(){go(Math.round(pos)-1)}
 prevBtn.onclick=prevStep;nextBtn.onclick=next;
 let drag=false,moved=false,sx=0,sp=0,lp=0,lt=0,vel=0;
 box.addEventListener('pointerdown',e=>{if(e.pointerType==='mouse'&&e.button!==0)return;drag=true;moved=false;sx=lp=e.clientX;sp=pos;lt=performance.now();vel=0});
 box.addEventListener('pointermove',e=>{if(!drag)return;let dx=e.clientX-sx;if(!moved&&Math.abs(dx)>6){moved=true;box.classList.add('is-dragging');try{box.setPointerCapture(e.pointerId)}catch(_){}}if(!moved)return;let now=performance.now(),dt=now-lt;if(dt>0)vel=.75*vel+.25*((e.clientX-lp)/dt);lp=e.clientX;lt=now;pos=sp-dx/(w*cfg.step);layout()});
 function release(){if(!drag)return;drag=false;if(!moved)return;box.classList.remove('is-dragging');if(performance.now()-lt>90)vel=0;let base=Math.round(pos),target=Math.round(pos-(vel*180)/(w*cfg.step));go(Math.max(base-2,Math.min(base+2,target)));moved=false}
 box.addEventListener('pointerup',release);box.addEventListener('pointercancel',release);box.addEventListener('dragstart',e=>e.preventDefault());
 box.addEventListener('click',e=>{if(moved){e.preventDefault();e.stopPropagation();return}let card=e.target.closest('.doma-cf-item');if(card&&card.parentNode===box){let i=cards.indexOf(card);if(i!==mod(Math.round(pos),n)){e.preventDefault();e.stopPropagation();goIndex(i)}}},true);
 box.addEventListener('keydown',e=>{if(e.key==='ArrowRight'){e.preventDefault();next()}if(e.key==='ArrowLeft'){e.preventDefault();prevStep()}});
 box.addEventListener('wheel',e=>{if(Math.abs(e.deltaX)>Math.abs(e.deltaY)&&Math.abs(e.deltaX)>4){e.preventDefault();nextOrPrev(e.deltaX)}},{passive:false});
 function nextOrPrev(v){go(Math.round(pos)+(v>0?1:-1))}
 const ro=new ResizeObserver(()=>{measure();layout()});ro.observe(box);cards.forEach(c=>ro.observe(c));measure();layout();
 api={next,prev:prevStep,goTo:goIndex,refresh:init,config:cfg};
}
function start(){init();const mo=new MutationObserver(()=>{if(!api)init()});mo.observe(document.body,{childList:true,subtree:true});window.addEventListener('load',init)}
window.DomaGradesCarousel={refresh:init,next:()=>api&&api.next(),prev:()=>api&&api.prev(),goTo:i=>api&&api.goTo(i),config:cfg};
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',start);else start();
})();