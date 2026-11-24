/* DOMA circular grade carousel - isolated to #gradeGrid */
(function(){
'use strict';
if(window.DomaGradesCarousel?.version===3)return;
const containerSelector='#gradeGrid', minCards=6;
let state=null,observer=null,raf=0;
const modulo=(v,n)=>(v%n+n)%n;
function dispose(){
 if(! state)return;
 state.ro?.disconnect();
 state.box.classList.remove('doma-grade-carousel-v2');
 state.cards.forEach(c=>{['position','left','top','width','max-width','margin','transform','opacity','filter','z-index','pointer-events','transition'].forEach(p=>c.style.removeProperty(p));c.classList.remove('doma-grade-carousel-item-v2')});
 state.controls?.remove();state=null;
}
function init(){
 const box=document.querySelector(containerSelector);if(!box)return;
 const cards=[...box.children].filter(el=>el.matches('.grade, article.card, .mf-pastel-grade-card'));
 if(cards.length<minCards)return;
 if(state&&state.box===box&&state.cards.every((c,i)=>c===cards[i])&&state.cards.length===cards.length)return;
 dispose();
 const n=cards.length;
 const st={box,cards,n,pos:0,width:0,height:0,controls:null,ro:null};state=st;
 box.classList.add('doma-grade-carousel-v2');
 box.setAttribute('role','region');box.setAttribute('aria-label','Choose your grade carousel');box.setAttribute('aria-roledescription','carousel');box.tabIndex=0;
 box.style.setProperty('display','block','important');box.style.setProperty('position','relative','important');box.style.setProperty('grid-template-columns','none','important');box.style.setProperty('grid-auto-flow','unset','important');box.style.setProperty('overflow','hidden','important');box.style.setProperty('touch-action','pan-y','important');
 cards.forEach(c=>{c.classList.add('doma-grade-carousel-item-v2');c.style.setProperty('position','absolute','important');c.style.setProperty('left','50%','important');c.style.setProperty('top','50%','important');c.style.setProperty('margin','0','important');c.style.setProperty('backface-visibility','hidden','important');c.style.setProperty('transition','transform .3s cubic-bezier(.2,.8,.25,1), opacity .3s, filter .3s','important');c.style.setProperty('will-change','transform,opacity,filter','important')});

 function measure(){
 st.width=Math.min(330,Math.max(205,box.clientWidth*.72));
 let h=0;cards.forEach(c=>{c.style.setProperty('width',st.width+'px','important');c.style.setProperty('max-width',st.width+'px','important');h=Math.max(h,c.offsetHeight)});
 st.height=Math.max(240,h+45);box.style.setProperty('height',st.height+'px','important');
 }
 function layout(){
 const step=st.width*.74;
 cards.forEach((c,i)=>{
 let d=i-st.pos;d-=n*Math.round(d/n);const abs=Math.abs(d),sign=d<0?-1:1;
 let x=abs<1.01?d*step:sign*(step+(abs-1)*step*.6);
 let scale=abs<1.01?1-.14*abs:Math.max(.72-(abs-1)*.12,.48);
 let opacity=abs<1.01?1-.48*abs:Math.max(.48*(2-abs),0);
 let z=-Math.min(abs,3)*80,rot=Math.max(-20,Math.min(20,-d*10));
 c.style.setProperty('transform','translate(-50%,-50%) translate3d('+x+'px,0,'+z+'px) rotateY('+rot+'deg) scale('+scale+')','important');
 c.style.setProperty('opacity',String(opacity),'important');c.style.setProperty('filter',abs>.08?'blur('+Math.min(abs,1)*5+'px)':'none','important');c.style.setProperty('z-index',String(100-Math.round(abs*10)),'important');
 c.style.setProperty('pointer-events',abs>1.4?'none':'auto','important');
 c.style.setProperty('visibility',abs>2.4?'hidden':'visible','important');
 });

 }
 function go(p){st.pos=p;layout()}function goIndex(i){const cur=Math.round(st.pos);let delta=i-modulo(cur,n);delta-=n*Math.round(delta/n);go(cur+delta)}function stepNext(){go(Math.round(st.pos)+1)}function stepPrev(){go(Math.round(st.pos)-1)}
 prev.onclick=stepPrev;next.onclick=stepNext;
 let drag=false,moved=false,suppress=false,startX=0,startPos=0,lastX=0,lastT=0,velocity=0;
 box.addEventListener('pointerdown',e=>{if(e.pointerType==='mouse'&&e.button!==0)return;drag=true;moved=false;startX=lastX=e.clientX;startPos=st.pos;lastT=performance.now();velocity=0});
 box.addEventListener('pointermove',e=>{if(!drag)return;const dx=e.clientX-startX;if(!moved&&Math.abs(dx)>7){moved=true;box.classList.add('doma-grade-carousel-dragging-v2');try{box.setPointerCapture(e.pointerId)}catch(_){}}if(!moved)return;const now=performance.now(),dt=now-lastT;if(dt>0)velocity=.7*velocity+.3*(e.clientX-lastX)/dt;lastX=e.clientX;lastT=now;st.pos=startPos-dx/(st.width*.74);layout()});
 function release(){if(!drag)return;drag=false;if(!moved)return;box.classList.remove('doma-grade-carousel-dragging-v2');if(performance.now()-lastT>100)velocity=0;let base=Math.round(st.pos),target=Math.round(st.pos-velocity*170/(st.width*.74));go(Math.max(base-2,Math.min(base+2,target)));suppress=true;window.setTimeout(()=>suppress=false,100);moved=false}
 box.addEventListener('pointerup',release);box.addEventListener('pointercancel',release);
 box.addEventListener('click',e=>{if(suppress)return;const card=e.target.closest('.doma-grade-carousel-item-v2');if(!card||card.parentNode!==box)return;const i=cards.indexOf(card);if(i!==modulo(Math.round(st.pos),n)){e.preventDefault();e.stopPropagation();goIndex(i)}},true);
 box.addEventListener('keydown',e=>{if(e.key==='ArrowRight'){e.preventDefault();stepNext()}if(e.key==='ArrowLeft'){e.preventDefault();stepPrev()}});
 st.ro=new ResizeObserver(()=>{measure();layout()});st.ro.observe(box);cards.forEach(c=>st.ro.observe(c));measure();layout();
 }
 if(observer)observer.disconnect();
 observer=new MutationObserver(()=>{if(raf)return;raf=requestAnimationFrame(()=>{raf=0;init()})});
 const box=document.querySelector(containerSelector);if(box)observer.observe(box,{childList:true});
 init();
 window.addEventListener('resize',()=>{if(state){state.width=Math.min(330,Math.max(205,state.box.clientWidth*.72));state.cards.forEach(c=>c.style.setProperty('width',state.width+'px','important'));state.box.style.setProperty('height',state.height+'px','important');}});
 window.DomaGradesCarousel={version:3,next:()=>state&&state.pos++,prev:()=>state&&state.pos--,goTo:i=>state&&i>=0&&i<state.n,refresh:init};

function initCourses(){
 const section=document.querySelector('#english-course .container');if(!section)return;
 const cards=[section.querySelector('.mf-english-course-hero'),section.querySelector('.mf-kids-entry-card'),section.querySelector('.pa-programming-entry-card')].filter(Boolean);
 if(cards.length!==3)return;
 let track=section.querySelector('.doma-course-track-v3');
 if(!track){track=document.createElement('div');track.className='doma-course-track-v3';track.style.cssText='position:relative!important;display:block!important;width:100%!important;height:350px!important;overflow:hidden!important;touch-action:pan-y!important;grid-column:1/-1!important';section.insertBefore(track,cards[0]);cards.forEach(c=>track.appendChild(c))}
 if(track.dataset.carouselReady==='1')return;track.dataset.carouselReady='1';
 let pos=0,width=0,drag=false,moved=false,startX=0,startPos=0,suppress=false,pid=null;
 cards.forEach(c=>{c.style.setProperty('position','absolute','important');c.style.setProperty('left','50%','important');c.style.setProperty('top','50%','important');c.style.setProperty('margin','0','important');c.style.setProperty('transition','transform .3s, opacity .3s, filter .3s','important');c.style.setProperty('will-change','transform','important')});
 function measure(){width=Math.max(220,Math.min(360,track.clientWidth*.72));cards.forEach(c=>{c.style.setProperty('width',width+'px','important');c.style.setProperty('max-width',width+'px','important')})}
 function render(){const step=width*.78;cards.forEach((c,i)=>{let d=i-pos;d-=cards.length*Math.round(d/cards.length);const a=Math.abs(d),x=d*step,scale=a<1?1-.14*a:Math.max(.6-.1*(a-1),.42),opacity=a<1?1-.4*a:Math.max(.5*(2-a),0);c.style.setProperty('transform','translate(-50%,-50%) translateX('+x+'px) scale('+scale+')','important');c.style.setProperty('opacity',String(opacity),'important');c.style.setProperty('filter',a>.05?'blur('+Math.min(4,a*4)+'px)':'none','important');c.style.setProperty('z-index',String(100-Math.round(a*12)),'important');c.style.setProperty('visibility',a>2?'hidden':'visible','important');c.style.setProperty('pointer-events',a>1.15?'none':'auto','important')})}
 function go(p){pos=p;render()}
 function focus(i){let cur=Math.round(pos),delta=i-((cur%cards.length+cards.length)%cards.length);if(delta>cards.length/2)delta-=cards.length;go(cur+delta)}
 track.addEventListener('pointerdown',e=>{if(e.pointerType==='mouse'&&e.button!==0)return;drag=true;moved=false;startX=e.clientX;startPos=pos;pid=e.pointerId;try{track.setPointerCapture(pid)}catch(_){}});
 track.addEventListener('pointermove',e=>{if(!drag||e.pointerId!==pid)return;const dx=e.clientX-startX;if(Math.abs(dx)>6)moved=true;if(moved){pos=startPos-dx/(width*.78);render()}});
 function end(e){if(!drag||(e&&e.pointerId!==pid))return;drag=false;if(moved){go(Math.round(pos));suppress=true;window.setTimeout(()=>suppress=false,180)}moved=false;pid=null}
 track.addEventListener('pointerup',end);track.addEventListener('pointercancel',end);
 track.addEventListener('click',e=>{if(suppress){e.preventDefault();e.stopPropagation();return}const card=e.target.closest('.doma-course-track-v3>*');if(!card||!cards.includes(card))return;let idx=cards.indexOf(card);if(idx!==((Math.round(pos)%cards.length+cards.length)%cards.length)){e.preventDefault();e.stopPropagation();focus(idx)}},true);
 measure();render();new ResizeObserver(()=>{measure();render()}).observe(track);
}

 if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',()=>{init();initCourses()});else{init();initCourses()}
})();