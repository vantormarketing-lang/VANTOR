/* DOMA swipe-only circular carousels: grade cards + homepage course cards */
(function(){
'use strict';
const VERSION=3, mod=(v,n)=>(v%n+n)%n;
if(window.DomaGradesCarousel?.version===VERSION)return;
const instances=[];
function createCarousel(box,cards,type){
 if(!box||cards.length<2||box.dataset.domaSwipeCarousel==='v3')return;
 box.dataset.domaSwipeCarousel='v3';
 const st={box,cards,type,pos:0,w:0,h:0,ro:null,original:cards.map(c=>({style:c.getAttribute('style'),cls:c.getAttribute('class')}))};
 instances.push(st);
 box.classList.add('doma-swipe-carousel-v3');
 box.setAttribute('role','region');box.setAttribute('aria-roledescription','carousel');box.setAttribute('aria-label',type==='grades'?'Grade carousel':'Learning path carousel');
 box.tabIndex=0;
 box.style.setProperty('position','relative','important');box.style.setProperty('display','block','important');box.style.setProperty('overflow','hidden','important');box.style.setProperty('touch-action','pan-y','important');box.style.setProperty('user-select','none','important');
 cards.forEach(c=>{c.classList.add('doma-swipe-carousel-item-v3');c.style.setProperty('position','absolute','important');c.style.setProperty('left','50%','important');c.style.setProperty('top','50%','important');c.style.setProperty('margin','0','important');c.style.setProperty('backface-visibility','hidden','important');c.style.setProperty('will-change','transform,opacity,filter','important');c.style.setProperty('transition','transform 300ms cubic-bezier(.2,.8,.25,1), opacity 300ms, filter 300ms','important')});
 function measure(){
 const ratio=type==='grades'?.76:.82;
 st.w=Math.min(type==='grades'?340:370,Math.max(210,box.clientWidth*ratio));
 let h=0;cards.forEach(c=>{c.style.setProperty('width',st.w+'px','important');c.style.setProperty('max-width',st.w+'px','important');h=Math.max(h,c.offsetHeight)});
 st.h=Math.max(type==='grades'?235:260,h+36);box.style.setProperty('height',st.h+'px','important');
 }
 function layout(){
 const step=st.w*.78;
 cards.forEach((c,i)=>{
 let d=i-st.pos;d-=cards.length*Math.round(d/cards.length);
 const a=Math.abs(d),sg=d<0?-1:1;
 const x=a<=1.02?d*step:sg*(step+(a-1)*step*.48);
 const scale=a<=1.02?1-.16*a:Math.max(.68-(a-1)*.13,.45);
 const opacity=a<=1.02?1-.48*a:Math.max(.48*(2-a),0);
 const z=-Math.min(a,3)*85,rotate=Math.max(-22,Math.min(22,-d*11));
 c.style.setProperty('transform','translate(-50%,-50%) translate3d('+x+'px,0,'+z+'px) rotateY('+rotate+'deg) scale('+scale+')','important');
 c.style.setProperty('opacity',String(opacity),'important');c.style.setProperty('filter',a>.08?'blur('+Math.min(a,1)*5+'px)':'none','important');
 c.style.setProperty('z-index',String(100-Math.round(a*10)),'important');c.style.setProperty('visibility',a>2.35?'hidden':'visible','important');
 c.style.setProperty('pointer-events',a>1.35?'none':'auto','important');
 });
 }
 function go(p){st.pos=p;layout()}function nearest(i){let cur=Math.round(st.pos),delta=i-mod(cur,cards.length);delta-=cards.length*Math.round(delta/cards.length);go(cur+delta)}
 let drag=false,moved=false,suppress=false,sx=0,sp=0,lx=0,lt=0,v=0;
 box.addEventListener('pointerdown',e=>{if(e.pointerType==='mouse'&&e.button!==0)return;drag=true;moved=false;sx=lx=e.clientX;sp=st.pos;lt=performance.now();v=0});
 box.addEventListener('pointermove',e=>{if(!drag)return;const dx=e.clientX-sx;if(!moved&&Math.abs(dx)>6){moved=true;box.classList.add('doma-swipe-dragging-v3');try{box.setPointerCapture(e.pointerId)}catch(_){}}
 if(!moved)return;const now=performance.now(),dt=now-lt;if(dt>0)v=.72*v+.28*(e.clientX-lx)/dt;lx=e.clientX;lt=now;st.pos=sp-dx/(st.w*.78);layout()});
 function end(e){if(!drag)return;drag=false;box.classList.remove('doma-swipe-dragging-v3');if(!moved)return;if(performance.now()-lt>90)v=0;let base=Math.round(st.pos),target=Math.round(st.pos-v*180/(st.w*.78));go(Math.max(base-2,Math.min(base+2,target)));suppress=true;setTimeout(()=>suppress=false,140);moved=false}
 box.addEventListener('pointerup',end);box.addEventListener('pointercancel',end);
 box.addEventListener('click',e=>{if(suppress){e.preventDefault();e.stopPropagation();return}const c=e.target.closest('.doma-swipe-carousel-item-v3');if(!c||c.parentNode!==box)return;const idx=cards.indexOf(c);if(idx!==mod(Math.round(st.pos),cards.length)){e.preventDefault();e.stopPropagation();nearest(idx)}},true);
 box.addEventListener('keydown',e=>{if(e.key==='ArrowLeft'){e.preventDefault();go(Math.round(st.pos)-1)}else if(e.key==='ArrowRight'){e.preventDefault();go(Math.round(st.pos)+1)}});
 st.ro=new ResizeObserver(()=>{measure();layout()});st.ro.observe(box);cards.forEach(c=>st.ro.observe(c));measure();layout();
}
function initGrades(){
 const box=document.querySelector('#gradeGrid');if(!box)return;
 const cards=[...box.children].filter(el=>el.matches('.grade,article.card,.mf-pastel-grade-card'));
 if(cards.length>=6&&!box.dataset.domaSwipeCarousel)createCarousel(box,cards,'grades');
}
function initCourses(){
 const section=document.querySelector('#english-course .container');if(!section)return;
 const cards=[section.querySelector('.mf-english-course-hero'),section.querySelector('.mf-kids-entry-card'),section.querySelector('.pa-programming-entry-card')].filter(Boolean);
 if(cards.length!==3)return;
 let box=section.querySelector('.doma-course-swipe-track-v3');
 if(!box){
 box=document.createElement('div');box.className='doma-course-swipe-track-v3';box.style.cssText='position:relative;width:100%;overflow:hidden;touch-action:pan-y';
 const first=cards[0];first.parentNode.insertBefore(box,first);cards.forEach(c=>box.appendChild(c));
 }
 if(!box.dataset.domaSwipeCarousel)createCarousel(box,cards,'courses');
}
function init(){initGrades();initCourses()}
let scheduled=false;
const observer=new MutationObserver(()=>{if(scheduled)return;scheduled=true;requestAnimationFrame(()=>{scheduled=false;init()})});
observer.observe(document.body,{childList:true,subtree:true});
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init();
window.DomaGradesCarousel={version:VERSION,refresh:init};
})();