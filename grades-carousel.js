/* DOMA grade carousel v4 — fix touch swipe and keep grade buttons clickable */
(function(){
'use strict';
if(window.DomaGradesCarousel?.version===4)return;
const mod=(v,n)=>(v%n+n)%n;
const interactive='button,a,input,select,textarea,[role="button"]';
let state=null,observer=null,raf=0;
function dispose(){if(!state)return;state.ro?.disconnect();state.box.classList.remove('doma-grade-carousel-v2');state.cards.forEach(c=>{['position','left','top','width','max-width','margin','transform','opacity','filter','z-index','pointer-events','transition','visibility'].forEach(p=>c.style.removeProperty(p));c.classList.remove('doma-grade-carousel-item-v2')});state=null}
function init(){
 const box=document.querySelector('#gradeGrid');if(!box)return;
 const cards=[...box.children].filter(el=>el.matches('.grade, article.card, .mf-pastel-grade-card'));
 if(cards.length<6)return;
 if(state&&state.box===box&&state.cards.length===cards.length&&state.cards.every((c,i)=>c===cards[i]))return;
 dispose();const n=cards.length,st={box,cards,n,pos:0,width:0,height:0,ro:null};state=st;
 box.classList.add('doma-grade-carousel-v2');box.setAttribute('role','region');box.setAttribute('aria-label','Choose your grade carousel');box.setAttribute('aria-roledescription','carousel');box.tabIndex=0;
 box.style.setProperty('display','block','important');box.style.setProperty('position','relative','important');box.style.setProperty('grid-template-columns','none','important');box.style.setProperty('grid-auto-flow','unset','important');box.style.setProperty('overflow','hidden','important');box.style.setProperty('touch-action','pan-y','important');
 cards.forEach(c=>{c.classList.add('doma-grade-carousel-item-v2');c.style.setProperty('position','absolute','important');c.style.setProperty('left','50%','important');c.style.setProperty('top','50%','important');c.style.setProperty('margin','0','important');c.style.setProperty('backface-visibility','hidden','important');c.style.setProperty('transition','transform .3s cubic-bezier(.2,.8,.25,1), opacity .3s, filter .3s','important');c.style.setProperty('will-change','transform,opacity,filter','important')});
 function measure(){st.width=Math.min(330,Math.max(205,box.clientWidth*.72));let h=0;cards.forEach(c=>{c.style.setProperty('width',st.width+'px','important');c.style.setProperty('max-width',st.width+'px','important');h=Math.max(h,c.offsetHeight)});st.height=Math.max(240,h+45);box.style.setProperty('height',st.height+'px','important')}
 function layout(){const step=st.width*.74;cards.forEach((c,i)=>{let d=i-st.pos;d-=n*Math.round(d/n);const a=Math.abs(d),sg=d<0?-1:1,x=a<1.01?d*step:sg*(step+(a-1)*step*.6),sc=a<1.01?1-.14*a:Math.max(.72-(a-1)*.12,.48),op=a<1.01?1-.48*a:Math.max(.48*(2-a),0),z=-Math.min(a,3)*80,rot=Math.max(-20,Math.min(20,-d*10));c.style.setProperty('transform','translate(-50%,-50%) translate3d('+x+'px,0,'+z+'px) rotateY('+rot+'deg) scale('+sc+')','important');c.style.setProperty('opacity',String(op),'important');c.style.setProperty('filter',a>.08?'blur('+Math.min(a,1)*5+'px)':'none','important');c.style.setProperty('z-index',String(100-Math.round(a*10)),'important');c.style.setProperty('pointer-events','auto','important');c.style.setProperty('visibility',a>2.4?'hidden':'visible','important')})}
 function go(p){st.pos=p;layout()}function focus(i){let cur=Math.round(st.pos),delta=i-mod(cur,n);if(delta>n/2)delta-=n;if(delta<-n/2)delta+=n;go(cur+delta)}
 let active=false,moved=false,startX=0,startPos=0,pointerId=null,suppress=false;
 box.addEventListener('pointerdown',e=>{if(e.pointerType==='mouse'&&e.button!==0)return;if(e.target.closest(interactive))return;active=true;moved=false;startX=e.clientX;startPos=st.pos;pointerId=e.pointerId});
 box.addEventListener('pointermove',e=>{if(!active||e.pointerId!==pointerId)return;let dx=e.clientX-startX;if(!moved&&Math.abs(dx)>7){moved=true;try{box.setPointerCapture(e.pointerId)}catch(_){}}if(moved){if(e.cancelable)e.preventDefault();st.pos=startPos-dx/(st.width*.74);layout()}});
 function release(e){if(!active||(e&&e.pointerId!==pointerId))return;active=false;if(moved){go(Math.round(st.pos));suppress=true;window.setTimeout(()=>suppress=false,180)}moved=false;pointerId=null}
 box.addEventListener('pointerup',release);box.addEventListener('pointercancel',release);
 box.addEventListener('click',e=>{if(suppress){e.preventDefault();e.stopPropagation();return}if(e.target.closest(interactive))return;const card=e.target.closest('.doma-grade-carousel-item-v2');if(!card||card.parentNode!==box)return;const i=cards.indexOf(card);if(i>=0&&i!==mod(Math.round(st.pos),n)){e.preventDefault();e.stopPropagation();focus(i)}},true);
 box.addEventListener('keydown',e=>{if(e.key==='ArrowRight'){e.preventDefault();go(Math.round(st.pos)+1)}if(e.key==='ArrowLeft'){e.preventDefault();go(Math.round(st.pos)-1)}});
 st.ro=new ResizeObserver(()=>{measure();layout()});st.ro.observe(box);cards.forEach(c=>st.ro.observe(c));measure();layout();
}
if(observer)observer.disconnect();observer=new MutationObserver(()=>{if(raf)return;raf=requestAnimationFrame(()=>{raf=0;init()})});const box=document.querySelector('#gradeGrid');if(box)observer.observe(box,{childList:true});
init();window.addEventListener('resize',()=>{if(state){measure();layout()}});
window.DomaGradesCarousel={version:4,refresh:init};
})();
