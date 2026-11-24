/* DOMA homepage circular carousel — grade cards + learning paths */
(function(){
'use strict';
if(window.DomaGradesCarousel?.version===5)return;
const mod=(v,n)=>(v%n+n)%n;
function attachCarousel(track,cards,{grade=false}={}){
 if(!track||cards.length<2||track.dataset.domaCarouselV5)return;
 track.dataset.domaCarouselV5='1';
 let pos=0,width=0,dragging=false,moved=false,startX=0,startPos=0,pointerId=null,suppressClick=false;
 const interactive='button,a,input,select,textarea,[role="button"]';
 track.style.setProperty('position','relative','important');
 track.style.setProperty('display','block','important');
 track.style.setProperty('width','100%','important');
 track.style.setProperty('overflow','hidden','important');
 track.style.setProperty('touch-action','pan-y','important');
 function measure(){
  width=Math.max(200,Math.min(350,track.clientWidth*.70));
  let maxH=0;
  cards.forEach(c=>{c.style.setProperty('width',width+'px','important');c.style.setProperty('max-width',width+'px','important');maxH=Math.max(maxH,c.offsetHeight)});
  track.style.setProperty('height',Math.max(190,maxH+30)+'px','important');
 }
 function render(){
  if(!width)measure();
  const step=width*(grade?.72:.78);
  cards.forEach((c,i)=>{
   let d=i-pos;d-=cards.length*Math.round(d/cards.length);
   const a=Math.abs(d),x=d*step,scale=a<1?1-.12*a:Math.max(.68-.09*(a-1),.45);
   const opacity=a<1?1-.34*a:Math.max(.45*(2.35-a),.08);
   c.style.setProperty('position','absolute','important');c.style.setProperty('left','50%','important');c.style.setProperty('top','50%','important');c.style.setProperty('margin','0','important');
   c.style.setProperty('transform','translate(-50%,-50%) translateX('+x+'px) scale('+scale+')','important');
   c.style.setProperty('opacity',String(opacity),'important');c.style.setProperty('filter',a>.12?'blur('+Math.min(3.5,a*3)+'px)':'none','important');
   c.style.setProperty('z-index',String(90-Math.round(a*12)),'important');
   c.style.setProperty('visibility',a>2.3?'hidden':'visible','important');
   /* Keep cards and their buttons clickable; the carousel itself handles swipe. */
   c.style.setProperty('pointer-events','auto','important');
  });
 }
 function go(next){pos=next;render()}
 function focusCard(i){let current=mod(Math.round(pos),cards.length),delta=i-current;if(delta>cards.length/2)delta-=cards.length;if(delta<-cards.length/2)delta+=cards.length;go(Math.round(pos)+delta)}
 track.addEventListener('pointerdown',e=>{
  if(e.pointerType==='mouse'&&e.button!==0)return;
  if(e.target.closest(interactive))return;
  dragging=true;moved=false;pointerId=e.pointerId;startX=e.clientX;startPos=pos;
 });
 track.addEventListener('pointermove',e=>{
  if(!dragging||e.pointerId!==pointerId)return;
  const dx=e.clientX-startX;
  if(!moved&&Math.abs(dx)>7){moved=true;try{track.setPointerCapture(e.pointerId)}catch(_){}}
  if(moved){if(e.cancelable)e.preventDefault();pos=startPos-dx/(width*(grade?.72:.78));render()}
 });
 function end(e){
  if(!dragging||(e&&e.pointerId!==pointerId))return;
  dragging=false;
  if(moved){go(Math.round(pos));suppressClick=true;window.setTimeout(()=>suppressClick=false,220)}
  moved=false;pointerId=null;
 }
 track.addEventListener('pointerup',end);track.addEventListener('pointercancel',end);
 track.addEventListener('click',e=>{
  if(suppressClick){e.preventDefault();e.stopPropagation();return}
  if(e.target.closest(interactive))return;
  const card=e.target.closest('.doma-carousel-v5-card');
  if(!card)return;const index=cards.indexOf(card);if(index>=0&&index!==mod(Math.round(pos),cards.length)){e.preventDefault();e.stopPropagation();focusCard(index)}
 },true);
 cards.forEach(c=>c.classList.add('doma-carousel-v5-card'));
 track.addEventListener('keydown',e=>{if(e.key==='ArrowRight'){e.preventDefault();go(Math.round(pos)+1)}if(e.key==='ArrowLeft'){e.preventDefault();go(Math.round(pos)-1)}});
 new ResizeObserver(()=>{measure();render()}).observe(track);
 measure();render();
 return {next:()=>go(Math.round(pos)+1),prev:()=>go(Math.round(pos)-1),goTo:i=>{if(i>=0&&i<cards.length)focusCard(i)}};
}
function initGrades(){
 const box=document.querySelector('#gradeGrid');if(!box)return;
 const cards=[...box.children].filter(el=>el.matches('.grade,article.card,.mf-pastel-grade-card'));
 if(cards.length<6)return;
 if(box.dataset.domaCarouselV5==='1')return;
 box.dataset.domaCarouselV5='1';
 window.DomaGradesCarousel=attachCarousel(box,cards,{grade:true})||{version:5};
}
function initCourses(){
 const section=document.querySelector('#english-course .container');if(!section)return;
 const cards=[section.querySelector('.mf-english-course-hero'),section.querySelector('.mf-kids-entry-card'),section.querySelector('.pa-programming-entry-card')].filter(Boolean);
 if(cards.length!==3)return;
 let track=section.querySelector('.doma-course-track-v3');
 if(!track){track=document.createElement('div');track.className='doma-course-track-v3';track.style.cssText='position:relative!important;display:block!important;width:100%!important;height:auto!important;min-height:0!important;overflow:hidden!important;touch-action:pan-y!important;grid-column:1/-1!important';section.insertBefore(track,cards[0]);cards.forEach(c=>track.appendChild(c))}
 attachCarousel(track,cards);
}
function boot(){
 initGrades();initCourses();
 const g=document.querySelector('#gradeGrid');
 if(g)new MutationObserver(()=>{if(!g.dataset.domaCarouselV5){g.dataset.domaCarouselV5='';initGrades()}}).observe(g,{childList:true});
 const course=document.querySelector('#english-course .container');
 if(course)new MutationObserver(()=>{if(!course.querySelector('.doma-course-track-v3'))initCourses()}).observe(course,{childList:true});
}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',boot,{once:true});else boot();
window.DomaGradesCarousel={version:5,refresh:boot};
})();