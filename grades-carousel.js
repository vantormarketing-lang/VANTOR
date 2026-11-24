/* DOMA circular grade carousel v5 — direct finger swipe on card surfaces */
(function(){
'use strict';
if(window.DomaGradesCarousel?.version===7)return;
const mod=(v,n)=>(v%n+n)%n,interactive='button,a,input,select,textarea,[role="button"]';
let state=null,observer=null,raf=0;
function dispose(){if(!state)return;state.ro?.disconnect();state.box.classList.remove('doma-grade-carousel-v2');state.cards.forEach(c=>{['position','left','top','width','max-width','margin','transform','opacity','filter','z-index','pointer-events','transition','visibility','touch-action'].forEach(p=>c.style.removeProperty(p));c.classList.remove('doma-grade-carousel-item-v2')});state=null}
function init(){
 const box=document.querySelector('#gradeGrid');if(!box)return;
 const cards=[...box.children].filter(el=>el.matches('.grade, article.card, .mf-pastel-grade-card'));
 if(cards.length<6)return;
 if(state&&state.box===box&&state.cards.length===cards.length&&state.cards.every((c,i)=>c===cards[i]))return;
 dispose();const n=cards.length,st={box,cards,n,pos:0,width:0,height:0,ro:null};state=st;
 box.classList.add('doma-grade-carousel-v2');box.setAttribute('role','region');box.setAttribute('aria-label','Choose your grade carousel');box.setAttribute('aria-roledescription','carousel');box.tabIndex=0;
 ['display','position','grid-template-columns','grid-auto-flow','overflow'].forEach(()=>{});
 box.style.setProperty('display','block','important');box.style.setProperty('position','relative','important');box.style.setProperty('grid-template-columns','none','important');box.style.setProperty('grid-auto-flow','unset','important');box.style.setProperty('overflow','hidden','important');
 cards.forEach(c=>{c.classList.add('doma-grade-carousel-item-v2');c.style.setProperty('position','absolute','important');c.style.setProperty('left','50%','important');c.style.setProperty('top','50%','important');c.style.setProperty('margin','0','important');c.style.setProperty('backface-visibility','hidden','important');c.style.setProperty('touch-action','pan-y','important');c.style.setProperty('transition','transform .25s cubic-bezier(.2,.8,.25,1), opacity .25s, filter .25s','important');c.style.setProperty('will-change','transform,opacity,filter','important')});
 function measure(){st.width=Math.min(330,Math.max(205,box.clientWidth*.72));let h=0;cards.forEach(c=>{c.style.setProperty('width',st.width+'px','important');c.style.setProperty('max-width',st.width+'px','important');h=Math.max(h,c.offsetHeight)});st.height=Math.max(240,h+45);box.style.setProperty('height',st.height+'px','important')}
 function layout(){const step=st.width*.74;cards.forEach((c,i)=>{let d=i-st.pos;d-=n*Math.round(d/n);const a=Math.abs(d),sg=d<0?-1:1,x=a<1.01?d*step:sg*(step+(a-1)*step*.6),sc=a<1.01?1-.14*a:Math.max(.72-(a-1)*.12,.48),op=a<1.01?1-.48*a:Math.max(.48*(2-a),0),z=-Math.min(a,3)*80,rot=Math.max(-20,Math.min(20,-d*10));c.style.setProperty('transform','translate(-50%,-50%) translate3d('+x+'px,0,'+z+'px) rotateY('+rot+'deg) scale('+sc+')','important');c.style.setProperty('opacity',String(op),'important');c.style.setProperty('filter',a>.08?'blur('+Math.min(a,1)*5+'px)':'none','important');c.style.setProperty('z-index',String(100-Math.round(a*10)),'important');c.style.setProperty('pointer-events','auto','important');c.style.setProperty('visibility',a>2.4?'hidden':'visible','important')})}
 function go(p){st.pos=p;layout()}function focus(i){let cur=Math.round(st.pos),delta=i-mod(cur,n);if(delta>n/2)delta-=n;if(delta<-n/2)delta+=n;go(cur+delta)}
 // Mouse drag
 let mouseOn=false,mouseMoved=false,mx=0,my=0,mpos=0,mousePid=null,suppress=false;
 box.addEventListener('pointerdown',e=>{if(e.pointerType==='touch'||(e.pointerType==='mouse'&&e.button!==0))return;if(e.target.closest(interactive))return;mouseOn=true;mouseMoved=false;mx=e.clientX;my=e.clientY;mpos=st.pos;mousePid=e.pointerId});
 box.addEventListener('pointermove',e=>{if(!mouseOn||e.pointerId!==mousePid)return;const dx=e.clientX-mx,dy=e.clientY-my;if(!mouseMoved&&Math.abs(dx)>7&&Math.abs(dx)>Math.abs(dy)){mouseMoved=true;try{box.setPointerCapture(e.pointerId)}catch(_){}}if(mouseMoved){e.preventDefault();st.pos=mpos-dx/(st.width*.74);layout()}});
 function mouseEnd(e){if(!mouseOn||(e&&e.pointerId!==mousePid))return;mouseOn=false;if(mouseMoved){go(Math.round(st.pos));suppress=true;window.setTimeout(()=>suppress=false,220)}mouseMoved=false;mousePid=null}
 box.addEventListener('pointerup',mouseEnd);box.addEventListener('pointercancel',mouseEnd);
 // Delegated touch handlers on carousel container; drag transforms are immediate while finger is down.
 let tActive=false,tMoved=false,tId=null,tStartX=0,tStartY=0,tStartPos=0;
 box.style.setProperty('touch-action','pan-y','important');
 box.addEventListener('touchstart',e=>{if(e.target.closest(interactive))return;if(!e.target.closest('.doma-grade-carousel-item-v2')||e.touches.length!==1)return;const t=e.touches[0];tActive=true;tMoved=false;tId=t.identifier;tStartX=t.clientX;tStartY=t.clientY;tStartPos=st.pos},{passive:true,capture:true});
 box.addEventListener('touchmove',e=>{if(!tActive)return;const t=[...e.touches].find(x=>x.identifier===tId);if(!t)return;const dx=t.clientX-tStartX,dy=t.clientY-tStartY;if(!tMoved&&Math.abs(dx)>7&&Math.abs(dx)>Math.abs(dy)*1.08)tMoved=true;if(tMoved){e.preventDefault();cards.forEach(c=>c.style.setProperty('transition','none','important'));st.pos=tStartPos-dx/(st.width*.74);layout()}},{passive:false,capture:true});
 function touchEnd(){if(!tActive)return;tActive=false;if(tMoved){go(Math.round(st.pos));cards.forEach(c=>c.style.setProperty('transition','transform .25s cubic-bezier(.2,.8,.25,1), opacity .25s, filter .25s','important'));suppress=true;window.setTimeout(()=>suppress=false,220)}tMoved=false;tId=null}
 box.addEventListener('touchend',touchEnd,{passive:true,capture:true});box.addEventListener('touchcancel',touchEnd,{passive:true,capture:true});
 box.addEventListener('click',e=>{if(suppress){e.preventDefault();e.stopPropagation();return}if(e.target.closest(interactive))return;const card=e.target.closest('.doma-grade-carousel-item-v2');if(!card||card.parentNode!==box)return;const i=cards.indexOf(card);if(i>=0&&i!==mod(Math.round(st.pos),n)){e.preventDefault();e.stopPropagation();focus(i)}},true);
 box.addEventListener('keydown',e=>{if(e.key==='ArrowRight'){e.preventDefault();go(Math.round(st.pos)+1)}if(e.key==='ArrowLeft'){e.preventDefault();go(Math.round(st.pos)-1)}});
 st.measure=measure;st.layout=layout;st.ro=new ResizeObserver(()=>{st.measure();st.layout()});st.ro.observe(box);cards.forEach(c=>st.ro.observe(c));st.measure();st.layout();
}
observer=new MutationObserver(()=>{if(raf)return;raf=requestAnimationFrame(()=>{raf=0;init()})});const box=document.querySelector('#gradeGrid');if(box)observer.observe(box,{childList:true});
init();window.addEventListener('resize',()=>{if(state){state.measure();state.layout()}});
window.DomaGradesCarousel={version:7,refresh:init};
})();
