/* DOMA home carousels v5 - swipeable circular grade and course cards */
(function(){
'use strict';
const V=5;if(window.DomaGradesCarousel?.version===V)return;
const states=new WeakMap(),mod=(x,n)=>(x%n+n)%n;
function mount(box,cards,type){
 if(!box||cards.length<2||states.has(box))return;
 const H=type==='grades'?280:340,s={cards,type,pos:0,w:0};states.set(box,s);
 box.dataset.domaSwipeCarousel='v5';box.classList.add('doma-swipe-carousel-v5');
 box.style.setProperty('position','relative','important');box.style.setProperty('display','block','important');box.style.setProperty('overflow','hidden','important');box.style.setProperty('height',H+'px','important');box.style.setProperty('width','100%','important');box.style.setProperty('touch-action','pan-y','important');
 if(type==='courses')box.style.setProperty('grid-column','1 / -1','important');
 box.setAttribute('aria-roledescription','carousel');box.setAttribute('aria-label',type==='grades'?'Grades carousel':'Courses carousel');
 cards.forEach(c=>{c.classList.add('doma-swipe-item-v5');[['position','absolute'],['left','50%'],['top','50%'],['margin','0'],['height','auto'],['min-height','0'],['max-height',type==='grades'?'260px':'320px'],['box-sizing','border-box'],['transition','transform 300ms ease, opacity 300ms ease, filter 300ms ease'],['will-change','transform']].forEach(([p,v])=>c.style.setProperty(p,v,'important'))});
 function measure(){s.w=Math.max(160,Math.min(type==='grades'?330:350,box.clientWidth*(type==='grades'?.78:.78)));cards.forEach(c=>{c.style.setProperty('width',s.w+'px','important');c.style.setProperty('max-width',s.w+'px','important')})}
 function render(){let step=s.w*.78;cards.forEach((c,i)=>{let d=i-s.pos;d-=cards.length*Math.round(d/cards.length);let a=Math.abs(d),x=d*step,sc=a<1.01?1-.14*a:Math.max(.62-.1*(a-1),.42),op=a<1.01?1-.4*a:Math.max(.48*(2-a),0);c.style.setProperty('transform','translate(-50%,-50%) translateX('+x+'px) scale('+sc+')','important');c.style.setProperty('opacity',op+'','important');c.style.setProperty('filter',a>.05?'blur('+Math.min(4,a*4)+'px)':'none','important');c.style.setProperty('z-index',String(100-Math.round(a*12)),'important');c.style.setProperty('visibility',a>2.05?'hidden':'visible','important');c.style.setProperty('pointer-events',a>1.15?'none':'auto','important')})}
 function move(n){s.pos=n;render()}
 function focusCard(idx){let current=Math.round(s.pos),delta=idx-mod(current,cards.length);if(delta>cards.length/2)delta-=cards.length;move(current+delta)}
 let active=false,dragged=false,start=0,origin=0,pid=null,ignoreClick=false;
 box.addEventListener('pointerdown',e=>{if(e.pointerType==='mouse'&&e.button!==0)return;active=true;dragged=false;start=e.clientX;origin=s.pos;pid=e.pointerId;try{box.setPointerCapture(e.pointerId)}catch(_){}});
 box.addEventListener('pointermove',e=>{if(!active||e.pointerId!==pid)return;let dx=e.clientX-start;if(Math.abs(dx)>6)dragged=true;if(dragged){s.pos=origin-dx/(s.w*.78);render()}});
 function stop(e){if(!active||(e&&e.pointerId!==pid))return;active=false;if(dragged){let target=Math.round(s.pos),base=Math.round(origin);target=Math.max(base-1,Math.min(base+1,target));move(target);ignoreClick=true;window.setTimeout(()=>ignoreClick=false,200)}dragged=false;pid=null}
 box.addEventListener('pointerup',stop);box.addEventListener('pointercancel',stop);
 box.addEventListener('click',e=>{if(ignoreClick){e.preventDefault();e.stopPropagation();return}let c=e.target.closest('.doma-swipe-item-v5');if(!c||!cards.includes(c))return;let idx=cards.indexOf(c);if(idx!==mod(Math.round(s.pos),cards.length)){e.preventDefault();e.stopPropagation();focusCard(idx)}},true);
 box.addEventListener('keydown',e=>{if(e.key==='ArrowLeft'){e.preventDefault();move(Math.round(s.pos)-1)}else if(e.key==='ArrowRight'){e.preventDefault();move(Math.round(s.pos)+1)}});
 measure();render();new ResizeObserver(()=>{measure();render()}).observe(box);
}
function grades(){let b=document.querySelector('#gradeGrid');if(!b)return;let c=[...b.children].filter(x=>x.matches('.grade,article.card,.mf-pastel-grade-card'));if(c.length===6&&!states.has(b))mount(b,c,'grades')}
function courses(){let sec=document.querySelector('#english-course .container');if(!sec)return;let c=[sec.querySelector('.mf-english-course-hero'),sec.querySelector('.mf-kids-entry-card'),sec.querySelector('.pa-programming-entry-card')].filter(Boolean);if(c.length!==3)return;let b=sec.querySelector('.doma-course-swipe-track-v5');if(!b){b=document.createElement('div');b.className='doma-course-swipe-track-v5';b.style.setProperty('grid-column','1 / -1','important');b.style.setProperty('width','100%','important');b.style.setProperty('min-width','0','important');b.style.setProperty('height','340px','important');b.style.setProperty('position','relative','important');b.style.setProperty('overflow','hidden','important');b.style.setProperty('touch-action','pan-y','important');sec.insertBefore(b,c[0]);c.forEach(x=>b.appendChild(x))}if(!states.has(b))mount(b,c,'courses')}
function init(){grades();courses()}
let scheduled=false;new MutationObserver(()=>{if(scheduled)return;scheduled=true;requestAnimationFrame(()=>{scheduled=false;init()})}).observe(document.body,{subtree:true,childList:true});
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init();
window.DomaGradesCarousel={version:V,refresh:init};
})();