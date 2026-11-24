/* DOMA homepage circular carousels v6 — preserve card design, restore real swipe */
(function(){
'use strict';
if(window.DomaGradesCarousel?.version===6)return;
const mod=(v,n)=>(v%n+n)%n;
const interactive='button,a,input,select,textarea,[role="button"]';
function mount(track,cards,{kind='grades'}={}){
 if(!track||cards.length<2||track.dataset.domaCarouselV6)return;
 track.dataset.domaCarouselV6='1';
 let pos=0,width=0,drag=false,moved=false,startX=0,startPos=0,pid=null,suppress=false;
 track.style.setProperty('position','relative','important');
 track.style.setProperty('display','block','important');
 track.style.setProperty('width','100%','important');
 track.style.setProperty('overflow','hidden','important');
 track.style.setProperty('touch-action','pan-y','important');
 function measure(){
  width=Math.max(190,Math.min(kind==='grades'?330:350,track.clientWidth*.72));
  let maxH=0;
  cards.forEach(card=>{
   card.style.setProperty('width',width+'px','important');
   card.style.setProperty('max-width',width+'px','important');
   maxH=Math.max(maxH,card.offsetHeight);
  });
  track.style.setProperty('height',Math.max(kind==='grades'?230:160,maxH+36)+'px','important');
 }
 function render(){
  if(!width)measure();
  const step=width*(kind==='grades'?.74:.78);
  cards.forEach((card,i)=>{
   let d=i-pos;d-=cards.length*Math.round(d/cards.length);
   const a=Math.abs(d),x=(a<1.01?d*step:Math.sign(d)*(step+(a-1)*step*.60));
   const scale=a<1.01?1-.14*a:Math.max(.72-.12*(a-1),.48);
   const opacity=a<1.01?1-.42*a:Math.max(.45*(2.35-a),.05);
   const rot=Math.max(-20,Math.min(20,-d*10));
   card.style.setProperty('position','absolute','important');
   card.style.setProperty('left','50%','important');card.style.setProperty('top','50%','important');
   card.style.setProperty('margin','0','important');
   card.style.setProperty('transform','translate(-50%,-50%) translate3d('+x+'px,0,0) rotateY('+rot+'deg) scale('+scale+')','important');
   card.style.setProperty('opacity',String(opacity),'important');
   card.style.setProperty('filter',a>.08?'blur('+Math.min(4,a*4)+'px)':'none','important');
   card.style.setProperty('z-index',String(100-Math.round(a*12)),'important');
   card.style.setProperty('visibility',a>2.4?'hidden':'visible','important');
   card.style.setProperty('pointer-events','auto','important');
  });
 }
 function go(n){pos=n;render()}
 function focus(i){let cur=mod(Math.round(pos),cards.length),delta=i-cur;if(delta>cards.length/2)delta-=cards.length;if(delta<-cards.length/2)delta+=cards.length;go(Math.round(pos)+delta)}
 track.addEventListener('pointerdown',e=>{
  if(e.pointerType==='mouse'&&e.button!==0)return;
  if(e.target.closest(interactive))return;
  drag=true;moved=false;startX=e.clientX;startPos=pos;pid=e.pointerId;
 });
 track.addEventListener('pointermove',e=>{
  if(!drag||e.pointerId!==pid)return;
  const dx=e.clientX-startX;
  if(!moved&&Math.abs(dx)>7){moved=true;try{track.setPointerCapture(e.pointerId)}catch(_){}}
  if(moved){if(e.cancelable)e.preventDefault();pos=startPos-dx/(width*(kind==='grades'?.74:.78));render()}
 });
 function end(e){
  if(!drag||(e&&e.pointerId!==pid))return;
  drag=false;if(moved){go(Math.round(pos));suppress=true;window.setTimeout(()=>suppress=false,220)}
  moved=false;pid=null;
 }
 track.addEventListener('pointerup',end);track.addEventListener('pointercancel',end);
 track.addEventListener('click',e=>{
  if(suppress){e.preventDefault();e.stopPropagation();return}
  if(e.target.closest(interactive))return;
  const card=e.target.closest('.doma-carousel-v6-card');if(!card)return;
  const i=cards.indexOf(card);if(i>=0&&i!==mod(Math.round(pos),cards.length)){e.preventDefault();e.stopPropagation();focus(i)}
 },true);
 cards.forEach(c=>c.classList.add('doma-carousel-v6-card'));
 track.addEventListener('keydown',e=>{if(e.key==='ArrowRight'){e.preventDefault();go(Math.round(pos)+1)}if(e.key==='ArrowLeft'){e.preventDefault();go(Math.round(pos)-1)}});
 new ResizeObserver(()=>{measure();render()}).observe(track);
 measure();render();
}
function initGrades(){
 const box=document.querySelector('#gradeGrid');if(!box)return;
 const cards=[...box.children].filter(c=>c.matches('.grade,article.card,.mf-pastel-grade-card'));
 if(cards.length>=6&&!box.dataset.domaCarouselV6)mount(box,cards,{kind:'grades'});
}
function initCourses(){
 const section=document.querySelector('#english-course .container');if(!section)return;
 const cards=[section.querySelector('.mf-english-course-hero'),section.querySelector('.mf-kids-entry-card'),section.querySelector('.pa-programming-entry-card')].filter(Boolean);
 if(cards.length!==3)return;
 let track=section.querySelector('.doma-course-track-v6');
 if(!track){track=document.createElement('div');track.className='doma-course-track-v6';track.style.cssText='position:relative!important;display:block!important;width:100%!important;height:auto!important;min-height:0!important;overflow:hidden!important;touch-action:pan-y!important;grid-column:1/-1!important';section.insertBefore(track,cards[0]);cards.forEach(c=>track.appendChild(c))}
 mount(track,cards,{kind:'courses'});
}
function init(){initGrades();initCourses()}
let queued=false;
const observer=new MutationObserver(()=>{if(queued)return;queued=true;requestAnimationFrame(()=>{queued=false;init()})});
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',()=>{init();observer.observe(document.body,{childList:true,subtree:true})},{once:true});
else {init();observer.observe(document.body,{childList:true,subtree:true})}
window.DomaGradesCarousel={version:6,refresh:init};
})();