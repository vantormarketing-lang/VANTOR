/* DOMA carousel v4: fixed-height, swipe-only, circular cards */
(function(){
'use strict';
const VERSION=4;if(window.DomaGradesCarousel?.version===VERSION)return;
const mod=(n,m)=>(n%m+m)%m, states=new Map();
function setup(box,cards,kind){
 if(!box||cards.length<2||states.has(box))return;
 const h=kind==='grades'?285:340, st={box,cards,kind,pos:0,width:0};states.set(box,st);
 box.dataset.domaSwipeCarousel='v4';box.classList.add('doma-swipe-carousel-v4');
 box.setAttribute('role','region');box.setAttribute('aria-roledescription','carousel');box.setAttribute('aria-label',kind==='grades'?'Grade carousel':'Learning path carousel');box.tabIndex=0;
 ['position','display','overflow','touch-action','user-select','box-sizing'].forEach((p,i)=>box.style.setProperty(p,['relative','block','hidden','pan-y','none','border-box'][i],'important'));
 box.style.setProperty('height',h+'px','important');
 if(kind==='courses'){box.style.setProperty('grid-column','1 / -1','important');box.style.setProperty('width','100%','important');box.style.setProperty('min-width','0','important')}
 cards.forEach(card=>{card.classList.add('doma-swipe-carousel-item-v4');[['position','absolute'],['left','50%'],['top','50%'],['margin','0'],['height','auto'],['min-height','0'],['max-height',kind==='grades'?'265px':'320px'],['box-sizing','border-box'],['backface-visibility','hidden'],['will-change','transform,opacity,filter'],['transition','transform 300ms cubic-bezier(.2,.8,.25,1), opacity 300ms, filter 300ms']].forEach(([p,v])=>card.style.setProperty(p,v,'important'))});
 function measure(){st.width=Math.min(kind==='grades'?330:355,Math.max(185,box.clientWidth*(kind==='grades'?.78:.8)));cards.forEach(c=>{c.style.setProperty('width',st.width+'px','important');c.style.setProperty('max-width',st.width+'px','important')})}
 function layout(){const step=st.width*.78;cards.forEach((c,i)=>{let d=i-st.pos;d-=cards.length*Math.round(d/cards.length);const a=Math.abs(d),sg=d<0?-1:1,x=a<=1.02?d*step:sg*(step+(a-1)*step*.5),scale=a<=1.02?1-.15*a:Math.max(.66-(a-1)*.12,.44),opacity=a<=1.02?1-.45*a:Math.max(.5*(2-a),0);c.style.setProperty('transform','translate(-50%,-50%) translate3d('+x+'px,0,0) scale('+scale+')','important');c.style.setProperty('opacity',opacity+'','important');c.style.setProperty('filter',a>.08?'blur('+Math.min(a,1)*4+'px)':'none','important');c.style.setProperty('z-index',100-Math.round(a*10)+'','important');c.style.setProperty('visibility',a>2.1?'hidden':'visible','important');c.style.setProperty('pointer-events',a>1.2?'none':'auto','important')})}
 function go(p){st.pos=p;layout()}
 function nearest(i){let cur=Math.round(st.pos),delta=i-mod(cur,cards.length);delta-=cards.length*Math.round(delta/cards.length);go(cur+delta)}
 let drag=false,moved=false,suppress=false,sx=0,sp=0,lx=0,lt=0,v=0,pid=null;
 box.addEventListener('pointerdown',e=>{if(e.pointerType==='mouse'&&e.button!==0)return;drag=true;moved=false;pid=e.pointerId;sx=lx=e.clientX;sp=st.pos;lt=performance.now();v=0});
 box.addEventListener('pointermove',e=>{if(!drag||e.pointerId!==pid)return;const dx=e.clientX-sx;if(!moved&&Math.abs(dx)>7){moved=true;try{box.setPointerCapture(e.pointerId)}catch(_){} }if(!moved)return;let now=performance.now(),dt=now-lt;if(dt>0)v=.7*v+.3*(e.clientX-lx)/dt;lx=e.clientX;lt=now;st.pos=sp-dx/(st.width*.78);layout()});
 function end(e){if(!drag||(e&&e.pointerId!==pid))return;drag=false;if(moved){if(performance.now()-lt>100)v=0;let target=Math.round(st.pos-v*125/(st.width*.78)),base=Math.round(st.pos);go(Math.max(base-1,Math.min(base+1,target)));suppress=true;setTimeout(()=>suppress=false,170)}moved=false;pid=null}
 box.addEventListener('pointerup',end);box.addEventListener('pointercancel',end);
 box.addEventListener('click',e=>{if(suppress){e.preventDefault();e.stopPropagation();return}let card=e.target.closest('.doma-swipe-carousel-item-v4');if(!card||card.parentNode!==box)return;let i=cards.indexOf(card);if(i!==mod(Math.round(st.pos),cards.length)){e.preventDefault();e.stopPropagation();nearest(i)}},true);
 box.addEventListener('keydown',e=>{if(e.key==='ArrowLeft'){e.preventDefault();go(Math.round(st.pos)-1)}if(e.key==='ArrowRight'){e.preventDefault();go(Math.round(st.pos)+1)}});
 measure();layout();new ResizeObserver(()=>{measure();layout()}).observe(box);
}
function initGrades(){let box=document.querySelector('#gradeGrid');if(!box)return;let cards=[...box.children].filter(e=>e.matches('.grade,article.card,.mf-pastel-grade-card'));if(cards.length>=6&&!states.has(box))setup(box,cards,'grades')}
function initCourses(){let sec=document.querySelector('#english-course .container');if(!sec)return;let cards=[sec.querySelector('.mf-english-course-hero'),sec.querySelector('.mf-kids-entry-card'),sec.querySelector('.pa-programming-entry-card')].filter(Boolean);if(cards.length!==3)return;let box=sec.querySelector('.doma-course-swipe-track-v4');if(!box){box=document.createElement('div');box.className='doma-course-swipe-track-v4';box.style.cssText='position:relative;min-width:0;width:100%;overflow:hidden;touch-action:pan-y';box.style.setProperty('grid-column','1 / -1','important');sec.insertBefore(box,cards[0]);cards.forEach(c=>box.appendChild(c))}if(!states.has(box))setup(box,cards,'courses')}
function init(){initGrades();initCourses()}
let pending=false;new MutationObserver(()=>{if(pending)return;pending=true;requestAnimationFrame(()=>{pending=false;init()})}).observe(document.body,{childList:true,subtree:true});
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init();
window.DomaGradesCarousel={version:VERSION,refresh:init};
})();