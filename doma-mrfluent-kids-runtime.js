
(function(){
'use strict';
var query = new URLSearchParams(window.location.search);
var route = (query.get('kids') || '').toLowerCase();
if (!route) return;

document.body.classList.add('mf-kids-route');
var root = document.createElement('main');
root.id = 'mfKidsStandaloneRoot';
document.body.appendChild(root);
// Isolate the Kids route from the academy DOM instead of relying on a list of section IDs.
// The grade cards are nested/initialized by other page code, so hide every element outside
// this route root while preserving the page's stylesheets and scripts.
function isolateKidsPage(){
  // Remove any orphaned text nodes left directly under <body> by the academy shell.
  // These can leak tiny fragments (for example, literal newline markers) above the Kids header.
  Array.prototype.slice.call(document.body.childNodes).forEach(function(node){
    if(node.nodeType===Node.TEXT_NODE && node.textContent.trim()) node.parentNode.removeChild(node);
  });
  var keepTags = {STYLE:1, SCRIPT:1, LINK:1, META:1};
  document.body.querySelectorAll('*').forEach(function(el){
    // Keep the academy login/signup modal interactive on isolated Kids pages.
    if (el === root || root.contains(el) || keepTags[el.tagName] || el.id === 'modal' || (el.closest && el.closest('#modal'))) return;
    el.style.setProperty('display','none','important');
    el.style.setProperty('visibility','hidden','important');
    el.setAttribute('aria-hidden','true');
  });
}
var L = [["A","a","Apple","تفاحة","🍎"],["B","b","Ball","كرة","⚽"],["C","c","Cat","قطة","🐱"],["D","d","Dog","كلب","🐶"],["E","e","Egg","بيضة","🥚"],["F","f","Fish","سمكة","🐟"],["G","g","Grapes","عنب","🍇"],["H","h","Hat","قبعة","🧢"],["I","i","Ice cream","آيس كريم","🍦"],["J","j","Juice","عصير","🧃"],["K","k","Kite","طائرة ورقية","🪁"],["L","l","Lion","أسد","🦁"],["M","m","Moon","قمر","🌙"],["N","n","Nest","عش","🪺"],["O","o","Orange","برتقالة","🍊"],["P","p","Pen","قلم","🖊️"],["Q","q","Queen","ملكة","👑"],["R","r","Rabbit","أرنب","🐰"],["S","s","Sun","شمس","☀️"],["T","t","Tiger","نمر","🐯"],["U","u","Umbrella","مظلة","☂️"],["V","v","Van","سيارة صغيرة","🚐"],["W","w","Watermelon","بطيخ","🍉"],["X","x","Xylophone","آلة إكسليفون","🎼"],["Y","y","Yo-yo","يويو","🪀"],["Z","z","Zebra","حمار وحشي","🦓"]];
function esc(value){return String(value == null ? '' : value).replace(/[&<>"']/g,function(ch){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch];});}
function url(page, extra){return './?kids=' + encodeURIComponent(page) + (extra || '');}
function header(){return '<header class="mfkr-top"><div class="mfkr-wrap mfkr-nav"><a class="mfkr-brand" href="./?kids=hub"><span class="mfkr-brand-icon">✦</span><span>Mr. Fluent Kids<small>LEARN · PLAY · GROW</small></span></a><a class="mfkr-btn" href="./">← DOMA Academy</a></div></header>';}
function footer(){return '<footer class="mfkr-footer"><div class="mfkr-wrap">Mr. Fluent Kids · Learn a little every day.</div></footer>';}
function shell(kicker,title,ar,description,content){return header() + '<section class="mfkr-page"><div class="mfkr-wrap"><div class="mfkr-heading"><div class="mfkr-eyebrow"><span class="mfkr-dot"></span>' + kicker + '</div><h1>' + title + '</h1><div class="mfkr-ar" lang="ar">' + ar + '</div>' + (description ? '<p>' + description + '</p>' : '') + '</div>' + content + '</div></section>' + footer();}
function backButtons(href,label){return '<div class="mfkr-back-row"><a class="mfkr-btn" href="' + href + '">' + label + '</a><a class="mfkr-btn" href="./?kids=hub">All paths</a><a class="mfkr-btn" href="./">DOMA Academy</a></div>';}
function pathCard(icon,tag,title,arabic,description,group){return '<a class="mfkr-choice" href="' + url(group) + '"><div class="mfkr-card-top"><span class="mfkr-art">' + icon + '</span><span class="mfkr-tag">' + tag + '</span></div><h2>' + title + '</h2><div class="mfkr-ar">' + arabic + '</div><p class="mfkr-desc">' + description + '</p><div class="mfkr-card-foot"><span>3 learning levels</span><span>Open path ↗</span></div></a>';}
function mfkrSelectEnglishVoice(utterance){try{var voices=window.speechSynthesis&&window.speechSynthesis.getVoices?window.speechSynthesis.getVoices():[];var english=voices.filter(function(v){return /^en([_-]|$)/i.test(v.lang||'');});var preferred=english.find(function(v){return /^en[-_]US/i.test(v.lang||'')&&/(neural|natural|google us english|microsoft|samantha|aria|jenny|zira|guy)/i.test(v.name||'');})||english.find(function(v){return /^en[-_]US/i.test(v.lang||'');})||english[0];if(preferred)utterance.voice=preferred;}catch(_){}}
function levelCard(code,title,description,group){var dest=code==='A1'?url('a1'):code==='A2'?url('a2'):code==='B1'?url('b1'):code==='B2'?url('b2'):code==='C1'?url('c1'):code==='C2'?url('c2'):url('soon','&level='+encodeURIComponent(code)+'&group='+encodeURIComponent(group));var ready=code==='A1'||code==='A2'||code==='B1'||code==='B2'||code==='C1'||code==='C2';return '<a class="mfkr-level" href="'+dest+'"><div class="mfkr-card-top"><span class="mfkr-code">'+code+'</span><span class="mfkr-tag">'+(ready?'READY TO LEARN':'IN THE MAKING')+'</span></div><h2>'+title+'</h2><p>'+description+'</p><div class="mfkr-card-foot"><span>'+(code==='A1'?'Letters A–Z':code==='A2'?'Grammar & writing':code==='B1'?'50 everyday words':code==='B2'?'Reading & summary':code==='C1'?'Stories & grammar':code==='C2'?'Writing & review':'Level '+code)+'</span><span>Open ↗</span></div></a>';}

var journeyLevels=[
  {code:'A1',route:'a1',title:'My First ABC',arabic:'الحروف والصوت',group:'younger',icon:'🔤',desc:'Letters, sounds and first words'},
  {code:'B1',route:'b1',title:'My First Words',arabic:'كلماتي الأولى',group:'younger',icon:'🧸',desc:'Useful words for daily life'},
  {code:'C1',route:'c1',title:'My First Sentences',arabic:'جُمَلي الأولى',group:'younger',icon:'💬',desc:'Build sentences and follow stories'},
  {code:'A2',route:'a2',title:'Word Explorers',arabic:'مستكشف الكلمات',group:'older',icon:'🧭',desc:'Vocabulary in everyday contexts'},
  {code:'B2',route:'b2',title:'Reading Builders',arabic:'أبطال القراءة',group:'older',icon:'📚',desc:'Read, understand and connect ideas'},
  {code:'C2',route:'c2',title:'Confident English',arabic:'ثقة في الإنجليزية',group:'older',icon:'🌟',desc:'Advanced reading and communication'}
];
var journeyUserId=null,journeyStoreKey='mrfluent-kids-journey-v1:guest',journeyData={levels:{}},journeyLoading=true,journeyPending=[],journeySyncTimer=null,journeyDirty={},journeyWritingQueued=false,journeySyncStatus='local',journeyToolState={route:'',speakingFeedback:'',speakingWrongOption:-1,speakingReplay:false,speakingReplayIndex:0,speakingPendingId:'',speakingPendingIndex:0,finalIndex:0,finalScore:0,finalAnswered:false,finalPicked:-1,finalFeedback:'',finalFinished:false};
var journeyCertificateName='';
var journeyDailyChallengeState={date:'',levelCode:'',index:0,phase:'words',feedback:'',done:false,pickedSentence:[]};

function journeyLevelCode(){return ({a1:'A1',a2:'A2',b1:'B1',b2:'B2',c1:'C1',c2:'C2'})[route]||'';}
function journeyUnique(values){return Array.from(new Set((Array.isArray(values)?values:[]).filter(function(v){return typeof v==='string'&&v.length>0;}).map(function(v){return v.slice(0,180);}))).slice(-300);}
function journeyGetLevel(code){
  if(!journeyData.levels)journeyData.levels={};
  if(!journeyData.levels[code])journeyData.levels[code]={checkpointKeys:[],wordsSeen:[],wrongAnswers:[],stars:0,badges:[],speakingKeys:[],finalQuizBest:0,finalQuizAttempts:0,speakingCompleted:false,certificateEarned:false,certificateCode:'',certifiedAt:null,legacyStats:{words:0,activities:0,best:0,attempts:0}};
  var level=journeyData.levels[code];
  if(!Array.isArray(level.checkpointKeys))level.checkpointKeys=[];
  if(!Array.isArray(level.wordsSeen))level.wordsSeen=[];
  if(!Array.isArray(level.wrongAnswers))level.wrongAnswers=[];
  if(!level.legacyStats)level.legacyStats={words:0,activities:0,best:0,attempts:0};
  level.speakingKeys=journeyUnique(level.checkpointKeys.filter(function(k){return /^speaking:/.test(k);}));
  level.speakingCompleted=level.speakingKeys.length>=3;
  level.finalQuizBest=Math.max(0,Math.min(5,Number(level.finalQuizBest)||0));
  level.finalQuizAttempts=Math.max(0,Number(level.finalQuizAttempts)||0);
  journeyRecalculate(level);
  return level;
}
function journeyRecalculate(level){
  level.checkpointKeys=journeyUnique(level.checkpointKeys);
  level.wordsSeen=journeyUnique(level.wordsSeen).slice(-100);
  level.speakingKeys=journeyUnique(level.checkpointKeys.filter(function(k){return /^speaking:/.test(k);}));
  level.speakingCompleted=level.speakingKeys.length>=3;
  var dailyChallenges=level.checkpointKeys.filter(function(k){return /^activity:daily-challenge:\d{4}-\d{2}-\d{2}$/.test(k);}).length;
  var genuineActivities=level.checkpointKeys.filter(function(k){return (/^activity:|^speaking:|^final:/.test(k))&&!/^activity:daily-challenge:/.test(k);}).length;
  level.stars=Math.min(20,Math.floor(level.wordsSeen.length/4)+Math.min(3,genuineActivities)+Math.min(5,dailyChallenges)+
    (level.speakingCompleted?2:0)+(level.finalQuizBest>=4?2:0)+(level.certificateEarned?2:0));
  level.badges=[];
  if(level.wordsSeen.length>=3)level.badges.push('first-steps');
  if(level.wordsSeen.length>=8)level.badges.push('practice-explorer');
  if(level.speakingKeys.length>=2)level.badges.push('steady-learner');
  if(level.certificateEarned)level.badges.push('learning-champion');
}
function journeyMergeLevel(code,row){
  if(!row||!journeyLevels.some(function(x){return x.code===code;}))return;
  var level=journeyGetLevel(code);
  var keys=row.checkpoint_keys||row.checkpointKeys||[];
  var words=row.words_seen||row.wordsSeen||[];
  level.checkpointKeys=journeyUnique(level.checkpointKeys.concat(Array.isArray(keys)?keys:[]));
  level.wordsSeen=journeyUnique(level.wordsSeen.concat(Array.isArray(words)?words:[])).slice(-100);
  var answers=row.wrong_answers||row.wrongAnswers;
  if(Array.isArray(answers)){
    answers.forEach(function(item){
      if(!item||!item.id)return;
      var existing=level.wrongAnswers.find(function(w){return w.id===item.id;});
      if(existing){
        existing.attempts=Math.max(Number(existing.attempts)||1,Number(item.attempts)||1);
        var existingReviewTime=Math.max(Date.parse(existing.createdAt||'')||0,Date.parse(existing.reviewedAt||'')||0);
        var incomingReviewTime=Math.max(Date.parse(item.createdAt||'')||0,Date.parse(item.reviewedAt||'')||0);
        if(incomingReviewTime>existingReviewTime){
          existing.reviewed=!!item.reviewed;
          if(item.createdAt)existing.createdAt=item.createdAt;
          existing.reviewedAt=item.reviewedAt||null;
          if(item.selected)existing.selected=item.selected;
          if(item.correct)existing.correct=item.correct;
          if(item.nextReviewAt!==undefined)existing.nextReviewAt=item.nextReviewAt||null;
          if(item.reviewIntervalDays!==undefined)existing.reviewIntervalDays=Number(item.reviewIntervalDays)||0;
          if(item.reviewRepetitions!==undefined)existing.reviewRepetitions=Number(item.reviewRepetitions)||0;
        }else if(incomingReviewTime===existingReviewTime&&item.reviewed){
          existing.reviewed=true;
          existing.reviewedAt=item.reviewedAt||existing.reviewedAt||null;
        }
      }else level.wrongAnswers.push(item);
    });
    level.wrongAnswers=level.wrongAnswers.slice(-40);
  }
  level.finalQuizBest=Math.max(level.finalQuizBest,Math.min(5,Number(row.final_quiz_best!=null?row.final_quiz_best:row.finalQuizBest)||0));
  level.finalQuizAttempts=Math.max(level.finalQuizAttempts,Number(row.final_quiz_attempts!=null?row.final_quiz_attempts:row.finalQuizAttempts)||0);
  level.certificateEarned=level.certificateEarned||!!(row.certificate_earned!=null?row.certificate_earned:row.certificateEarned);
  level.certificateCode=level.certificateCode||row.certificate_code||row.certificateCode||'';
  level.certifiedAt=level.certifiedAt||row.certified_at||row.certifiedAt||null;
  journeyRecalculate(level);
}
function journeyLocalRead(key){try{var raw=localStorage.getItem(key);return raw?JSON.parse(raw):null;}catch(_){return null;}}
function journeySaveLocal(){try{localStorage.setItem(journeyStoreKey,JSON.stringify({levels:journeyData.levels||{},savedAt:new Date().toISOString()}));}catch(_){}}
function journeyMergeLegacy(code,row){
  if(!row)return;
  var words=row.completed_words||row.viewedWords||row.completedWords||[];
  var activities=row.completed_activities||row.completedActivities||[];
  if(!Array.isArray(words))words=[];
  if(!Array.isArray(activities))activities=[];
  var score=Number(row.best_quiz_score!=null?row.best_quiz_score:row.bestQuizScore)||0;
  var attempts=Number(row.quiz_attempts!=null?row.quiz_attempts:row.quizAttempts)||0;
  var level=journeyGetLevel(code);
  words.forEach(function(word){if(typeof word==='string'&&word){level.wordsSeen=journeyUnique(level.wordsSeen.concat([word]));}});
  activities.forEach(function(activity){if(typeof activity==='string'&&activity){level.checkpointKeys=journeyUnique(level.checkpointKeys.concat(['saved-activity:'+activity]));}});
  level.legacyStats={
    words:Math.max(Number(level.legacyStats.words)||0,words.length),
    activities:Math.max(Number(level.legacyStats.activities)||0,activities.length),
    best:Math.max(Number(level.legacyStats.best)||0,score),
    attempts:Math.max(Number(level.legacyStats.attempts)||0,attempts)
  };
  journeyRecalculate(level);
  if(journeyUserId&&(words.length||activities.length||score||attempts))journeyScheduleSync(code);
}
function journeyLoadLegacyLocal(code){
  var spec={A2:'mrfluent-growing-a2-progress:',B2:'mrfluent-growing-b2-progress:',C2:'mrfluent-growing-c2-progress:'}[code];
  if(!spec)return;
  var row=journeyLocalRead(spec+(journeyUserId||'guest'));
  if(row)journeyMergeLegacy(code,row);
}
function journeyScheduleSync(code){
  if(!journeyUserId||typeof sb==='undefined'||!sb||!sb.from)return;
  journeySyncStatus='saving';
  journeyDirty[code]=true;
  if(journeySyncTimer)clearTimeout(journeySyncTimer);
  journeySyncTimer=setTimeout(async function(){
    var pending=Object.keys(journeyDirty);journeyDirty={};
    for(var i=0;i<pending.length;i++){
      var level=journeyGetLevel(pending[i]);
      try{
        var result=await sb.from('mrfluent_kids_journey_progress').upsert({
          user_id:journeyUserId,
          level_code:pending[i],
          checkpoint_keys:level.checkpointKeys.slice(-300),
          words_seen:level.wordsSeen.slice(-100),
          wrong_answers:level.wrongAnswers.slice(-40),
          final_quiz_best:level.finalQuizBest,
          final_quiz_attempts:level.finalQuizAttempts,
          updated_at:new Date().toISOString()
        },{onConflict:'user_id,level_code'}).select('level_code,speaking_completed,certificate_earned,certificate_code,certified_at').single();
        if(result&&result.error)throw result.error;
        if(result&&result.data){
          var savedLevel=journeyGetLevel(result.data.level_code||pending[i]);
          savedLevel.speakingCompleted=!!result.data.speaking_completed;
          savedLevel.certificateEarned=!!result.data.certificate_earned;
          savedLevel.certificateCode=result.data.certificate_code||'';
          savedLevel.certifiedAt=result.data.certified_at||null;
          journeyRecalculate(savedLevel);
        }
        journeySyncStatus='synced';
      }catch(_){journeySyncStatus='error';}
    }
    journeySaveLocal();
    journeyRenderCurrent();
  },650);
}
function journeyRecord(actionKey,wordValue,codeOverride){
  var code=codeOverride||journeyLevelCode();
  if(!code)return;
  if(journeyLoading){journeyPending.push({type:'record',code:code,actionKey:actionKey,wordValue:wordValue});return;}
  var level=journeyGetLevel(code);
  var key=String(actionKey||'').replace(/\s+/g,' ').trim().slice(0,180);
  if(!key)return;
  if(level.checkpointKeys.indexOf(key)<0)level.checkpointKeys.push(key);
  if(wordValue){
    var word=String(wordValue).replace(/\s+/g,' ').trim().slice(0,100);
    if(word&&level.wordsSeen.indexOf(word)<0)level.wordsSeen.push(word);
  }
  journeyRecalculate(level);
  journeyMaybeAwardCertificate(code);
  journeySaveLocal();
  journeyRenderCurrent();
  journeyScheduleSync(code);
}
function journeyMaybeAwardCertificate(code){
  var level=journeyGetLevel(code);
  if(level.wordsSeen.length>=5&&level.speakingKeys.length>=3&&level.finalQuizBest>=4&&!level.certificateEarned){
    if(journeyUserId){
      journeyScheduleSync(code);
      return;
    }
    level.certificateEarned=true;
    level.certificateCode='MF-'+code+'-LOCAL-'+String(Date.now()).slice(-5);
    level.certifiedAt=new Date().toISOString();
    journeyRecalculate(level);
    journeySaveLocal();
  }
}
function journeyAddReviewItem(item,codeOverride){
 var code=codeOverride||journeyLevelCode();if(!code||!item||!item.id)return;if(journeyLoading){journeyPending.push({type:'review',code:code,item:item});return;}
 var l=journeyGetLevel(code),old=l.wrongAnswers.find(function(w){return w.id===item.id;});
 if(old){old.attempts=(Number(old.attempts)||1)+1;old.reviewed=false;old.reviewedAt=null;old.nextReviewAt=null;old.reviewIntervalDays=0;old.reviewRepetitions=0;old.createdAt=new Date().toISOString();old.selected=item.selected||old.selected;}
 else l.wrongAnswers.push({id:String(item.id).slice(0,180),level:code,question:String(item.question||'Practice question').slice(0,260),arabic:String(item.arabic||'').slice(0,260),selected:String(item.selected||'').slice(0,180),correct:String(item.correct||'').slice(0,180),kind:String(item.kind||'quiz').slice(0,40),createdAt:new Date().toISOString(),attempts:1,reviewed:false,reviewRepetitions:0,reviewIntervalDays:0,nextReviewAt:null});
 l.wrongAnswers=l.wrongAnswers.slice(-40);journeySaveLocal();journeyRenderCurrent();journeyScheduleSync(code);
}
function journeySpeak(textValue){
  if(!textValue||!('speechSynthesis' in window)||!('SpeechSynthesisUtterance' in window))return;
  try{window.speechSynthesis.cancel();var utterance=new SpeechSynthesisUtterance(String(textValue));utterance.lang='en-US';utterance.rate=.82;utterance.pitch=1.02;window.speechSynthesis.speak(utterance);}catch(_){}
}
function journeyCaptureWrongAnswer(button){
  var code=journeyLevelCode();
  if(!code||!button.classList.contains('is-wrong'))return false;
  var panel=button.closest('#mfkrA2Quiz,#mfkrB1Quiz,#mfkrC1Quiz,#mfkrB2Quiz,#mfkrC2Quiz,#mfkrC2Inference,#mfkrC2Connectors,#mfkrC2Speaking,#mfkrA2Match,#mfkrB2Sequence');
  if(!panel)panel=button.closest('.mfkr-quiz-panel')||button.parentElement;
  var qNode=panel&&panel.querySelector?panel.querySelector('h3[lang="en"],h3,h4,[data-quiz-question]'):null;
  var arNode=panel&&panel.querySelector?panel.querySelector('.mfkr-quiz-hint,.mfkr-c1-story-title-ar,.mfkr-ar'):null;
  var correctNode=panel&&panel.querySelector?panel.querySelector('.is-correct'):null;
  var feedbackNode=panel&&panel.querySelector?panel.querySelector('.mfkr-quiz-feedback'):null;
  var question=qNode?String(qNode.textContent||'').replace(/\s+/g,' ').trim():'Question';
  if(/^Question \d+/i.test(question)){var all=panel.querySelectorAll('h3');if(all.length>1)question=String(all[all.length-1].textContent||'').replace(/\s+/g,' ').trim();}
  var correct=correctNode?String(correctNode.textContent||'').replace(/\s+/g,' ').trim():'';
  if(!correct&&feedbackNode)correct=String(feedbackNode.textContent||'').replace(/^.*?(?:correct answer:|الإجابة الصحيحة:|المعنى الصحيح هو:|الرد المناسب:)\s*/i,'').replace(/\s+/g,' ').trim();
  if(!correct)return false;
  var kind=panel&&panel.id?panel.id.replace(/^mfkr/,'').slice(0,40):'quiz';
  var itemId=code+'|'+kind+'|'+question.toLowerCase().slice(0,95);
  journeyAddReviewItem({id:itemId,question:question,arabic:arNode?arNode.textContent:'',selected:button.textContent,correct:correct,kind:kind},code);
  return true;
}
function journeySpeakingData(code){
  var data={
    A1:[
      {id:'greeting',q:'Someone asks: What is your name?',ar:'شخص يسألك: ما اسمك؟',options:[{en:'My name is Sara.',ar:'اسمي سارة.'},{en:'I am a pencil.',ar:'أنا قلم.'},{en:'Good night, sun.',ar:'تصبح على خير يا شمس.'}],correct:0},
      {id:'feeling',q:'Your friend asks: How are you?',ar:'صديقك يسألك: كيف حالك؟',options:[{en:'It is under the table.',ar:'إنه تحت الطاولة.'},{en:'I am happy, thank you.',ar:'أنا سعيد، شكرًا لك.'},{en:'Seven blue cats.',ar:'سبع قطط زرقاء.'}],correct:1},
      {id:'favourite',q:'Someone asks about your favourite colour.',ar:'شخص يسألك عن لونك المفضل.',options:[{en:'I am a school.',ar:'أنا مدرسة.'},{en:'Open the window yesterday.',ar:'افتح النافذة أمس.'},{en:'I like blue.',ar:'أنا أحب اللون الأزرق.'}],correct:2}
    ],
    B1:[
      {id:'greeting',q:'You meet a new classmate. What can you say?',ar:'تقابل زميلًا جديدًا في الفصل. ماذا تقول؟',options:[{en:'Close the blue book.',ar:'أغلق الكتاب الأزرق.'},{en:'Hello! Nice to meet you.',ar:'مرحبًا! سعيد بلقائك.'},{en:'The apple is sleeping.',ar:'التفاحة نائمة.'}],correct:1},
      {id:'thirsty',q:'Your friend asks: What do you drink when you are thirsty?',ar:'صديقك يسألك: ماذا تشرب عندما تعطش؟',options:[{en:'I read a banana.',ar:'أقرأ موزة.'},{en:'I sleep the milk.',ar:'أنام اللبن.'},{en:'I drink water.',ar:'أشرب الماء.'}],correct:2},
      {id:'routine',q:'Someone asks what you do every day.',ar:'شخص يسألك عمّا تفعله كل يوم.',options:[{en:'I go to school and read.',ar:'أذهب إلى المدرسة وأقرأ.'},{en:'Yesterday is a rabbit.',ar:'أمس أرنب.'},{en:'The chair drinks.',ar:'الكرسي يشرب.'}],correct:0}
    ],
    C1:[
      {id:'ability',q:'Tell your friend what you can do.',ar:'أخبر صديقك بشيء تستطيع فعله.',options:[{en:'A story can red.',ar:'قصة يستطيع أحمر.'},{en:'Can the is garden.',ar:'يستطيع الـ الحديقة.'},{en:'I can read a story.',ar:'أستطيع قراءة قصة.'}],correct:2},
      {id:'like',q:'Tell someone what you like.',ar:'أخبر شخصًا بشيء تحبه.',options:[{en:'Like I the flowers red.',ar:'أحب أنا الـ الزهور أحمر.'},{en:'I like flowers.',ar:'أنا أحب الزهور.'},{en:'Flowers can the happy.',ar:'الزهور تستطيع الـ سعيدة.'}],correct:1},
      {id:'describe',q:'Describe your cat.',ar:'صِف قطتك.',options:[{en:'My cat is small.',ar:'قطتي صغيرة.'},{en:'My cat small is a.',ar:'قطتي صغيرة يكون أ.'},{en:'Small my is cat the.',ar:'صغيرة قطتي يكون القط.'}],correct:0}
    ],
    A2:[
      {id:'borrow',q:'You need a pencil. What is a polite request?',ar:'تحتاج قلمًا. ما الطلب المهذب؟',options:[{en:'Give pencil me yesterday.',ar:'أعطني قلمًا أمس.'},{en:'Could I borrow your pencil, please?',ar:'هل يمكنني استعارة قلمك، من فضلك؟'},{en:'Your pencil can swim.',ar:'قلمك يستطيع السباحة.'}],correct:1},
      {id:'directions',q:'You are lost. Ask for directions.',ar:'أنت لا تعرف الطريق. اطلب إرشادات.',options:[{en:'The library eats a bus.',ar:'المكتبة تأكل حافلة.'},{en:'I am opposite yesterday.',ar:'أنا مقابل أمس.'},{en:'Excuse me, how can I get to the library?',ar:'عذرًا، كيف أصل إلى المكتبة؟'}],correct:2},
      {id:'routine',q:'Explain one part of your daily routine.',ar:'اشرح جزءًا من روتينك اليومي.',options:[{en:'I usually prepare my bag at night.',ar:'عادة أجهز حقيبتي ليلًا.'},{en:'I usually bag my night prepare.',ar:'عادة حقيبة أنا الليل أجهز.'},{en:'My routine is a museum eat.',ar:'روتيني متحف يأكل.'}],correct:0}
    ],
    B2:[
      {id:'suggestion',q:'Your class wants a cleaner school. Make a suggestion.',ar:'فصلك يريد مدرسة أنظف. قدّم اقتراحًا.',options:[{en:'The notebook is a blue because.',ar:'الكشكول أزرق لأن.'},{en:'Cleaning yesterday will be had.',ar:'التنظيف أمس سيكون كان.'},{en:'Why do we not put recycling boxes near the gate?',ar:'لماذا لا نضع صناديق إعادة التدوير قرب البوابة؟'}],correct:2},
      {id:'clarify',q:'You did not understand a direction. What should you say?',ar:'لم تفهم إرشادًا. ماذا تقول؟',options:[{en:'I will never ask any question.',ar:'لن أسأل أي سؤال أبدًا.'},{en:'Could you explain the last step again, please?',ar:'هل يمكنك شرح الخطوة الأخيرة مرة أخرى؟'},{en:'The museum is eating the map.',ar:'المتحف يأكل الخريطة.'}],correct:1},
      {id:'sequence',q:'Tell someone how you solve a problem.',ar:'أخبر شخصًا كيف تحل مشكلة.',options:[{en:'First I check the facts, then I choose a solution.',ar:'أتحقق من الحقائق أولًا، ثم أختار حلًا.'},{en:'Solution first facts because yesterday.',ar:'الحل أولًا الحقائق لأن أمس.'},{en:'I decide before I know anything.',ar:'أقرر قبل أن أعرف أي شيء.'}],correct:0}
    ],
    C2:[
      {id:'disagree',q:'You disagree respectfully with a classmate.',ar:'أنت تختلف مع زميلك بطريقة محترمة.',options:[{en:'You are wrong, so stop talking.',ar:'أنت مخطئ، لذا توقف عن الكلام.'},{en:'I see your point, but the evidence suggests another answer.',ar:'أتفهم وجهة نظرك، لكن الأدلة تشير إلى إجابة أخرى.'},{en:'I will agree even if the facts are unclear.',ar:'سأوافق حتى لو كانت الحقائق غير واضحة.'}],correct:1},
      {id:'reliable',q:'A surprising claim appears online. What should you do?',ar:'ظهرت معلومة مفاجئة على الإنترنت. ماذا تفعل؟',options:[{en:'Check reliable sources before sharing it.',ar:'أتحقق من مصادر موثوقة قبل مشاركتها.'},{en:'Share it immediately because it sounds exciting.',ar:'أشاركها فورًا لأنها تبدو مثيرة.'},{en:'Ignore every source and guess.',ar:'أتجاهل كل المصادر وأخمن.'}],correct:0},
      {id:'impact',q:'Suggest a practical improvement for your school.',ar:'اقترح تحسينًا عمليًا لمدرستك.',options:[{en:'We should choose a plan without evaluating it.',ar:'يجب اختيار خطة دون تقييمها.'},{en:'No one can contribute anything useful.',ar:'لا يستطيع أحد المساهمة بشيء مفيد.'},{en:'We could run a book-sharing project and measure its impact.',ar:'يمكننا تنظيم مشروع لتبادل الكتب وقياس تأثيره.'}],correct:2}
    ]
  };
  return data[code]||data.A1;
}
function journeyFinalQuestions(code){
  var data={
    A1:[
      {id:'letter-after-a',q:'Which letter comes after A?',ar:'أي حرف يأتي بعد A؟',options:['C','B','D'],correct:1},
      {id:'b-word',q:'Which word starts with the letter B?',ar:'أي كلمة تبدأ بحرف B؟',options:['Cat','Ball','Apple'],correct:1},
      {id:'cat-meaning',q:'Which word means قطة?',ar:'ما الكلمة الإنجليزية التي تعني قطة؟',options:['Dog','Cat','Sun'],correct:1},
      {id:'upper-d',q:'Choose the capital form of d.',ar:'اختر الحرف الكبير المقابل لـ d.',options:['D','b','P'],correct:0},
      {id:'sun-meaning',q:'Which word means شمس?',ar:'ما الكلمة الإنجليزية التي تعني شمس؟',options:['Moon','Fish','Sun'],correct:2}
    ],
    B1:[
      {id:'family',q:'Who is your mother?',ar:'من هي أمك؟',options:['A school subject','A member of my family','A kind of food'],correct:1},
      {id:'drink',q:'What do you drink when you are thirsty?',ar:'ماذا تشرب عندما تعطش؟',options:['Bread','Water','A book'],correct:1},
      {id:'animal',q:'Which animal can fly?',ar:'أي حيوان يستطيع الطيران؟',options:['Fish','Rabbit','Bird'],correct:2},
      {id:'action',q:'Choose the correct daily action.',ar:'اختر فعلًا يوميًا صحيحًا.',options:['I eat breakfast.','I breakfast eat is.','I eating is breakfast.'],correct:0},
      {id:'sleep',q:'When do most people sleep?',ar:'متى ينام معظم الناس؟',options:['Inside a sandwich','Under water every day','At night'],correct:2}
    ],
    C1:[
      {id:'word-order',q:'Choose the correct sentence.',ar:'اختر الجملة الصحيحة.',options:['I like apples.','Like I apples.','Apples I like the.'],correct:0},
      {id:'can',q:'Choose the correct way to express ability.',ar:'اختر التعبير الصحيح عن القدرة.',options:['I can jump.','I can jumps.','I jumping can.'],correct:0},
      {id:'describe',q:'Complete: The cat ___ small.',ar:'أكمل: القطة صغيرة.',options:['are','is','am'],correct:1},
      {id:'story',q:'What does Mia plant in the story?',ar:'ماذا تزرع ميا في القصة؟',options:['A red flower','A toy car','A sandwich'],correct:0},
      {id:'where',q:'Where does the flower grow?',ar:'أين تنمو الزهرة؟',options:['In the sea','In the sun','Inside a shoe'],correct:1}
    ],
    A2:[
      {id:'timetable',q:'What does a timetable show?',ar:'ماذا يوضّح جدول الحصص؟',options:['Animal colours','Lesson times','A recipe for soup'],correct:1},
      {id:'borrow',q:'Choose the polite request.',ar:'اختر الطلب المهذب.',options:['Give me pencil yesterday.','I borrow you are.','Can I borrow your pencil, please?'],correct:2},
      {id:'routine',q:'Complete: I ___ wake up early.',ar:'أكمل: أنا أستيقظ مبكرًا عادةً.',options:['museum','usually','opposite'],correct:1},
      {id:'place',q:'Which place lends books?',ar:'أي مكان نستعير منه الكتب؟',options:['Market','Bus station','Library'],correct:2},
      {id:'direction',q:'What does opposite mean?',ar:'ما معنى opposite؟',options:['Behind forever','Across from','Very hungry'],correct:1}
    ],
    B2:[
      {id:'detail',q:'Why should a reader check details?',ar:'لماذا يراجع القارئ التفاصيل؟',options:['To make a story longer only','To support understanding','To avoid the main idea'],correct:1},
      {id:'sequence',q:'Which word is useful to show the first step?',ar:'أي كلمة تُستخدم لتوضيح الخطوة الأولى؟',options:['Yesterday maybe','Although because','First'],correct:2},
      {id:'solution',q:'A solution is...',ar:'ما معنى solution؟',options:['A type of weather','An answer to a problem','A school timetable'],correct:1},
      {id:'environment',q:'Which action helps the environment?',ar:'أي تصرف يساعد البيئة؟',options:['Throwing away every bottle','Leaving lights on all day','Reusing bags'],correct:2},
      {id:'evidence',q:'What is evidence?',ar:'ما معنى evidence؟',options:['A random guess','Information that supports an idea','A place to buy fruit'],correct:1}
    ],
    C2:[
      {id:'reliable',q:'A reliable source is one that...',ar:'المصدر الموثوق هو الذي...',options:['Always agrees with us','Can be checked and trusted','Has the loudest headline'],correct:1},
      {id:'evidence',q:'What should support a strong conclusion?',ar:'ما الذي يدعم الاستنتاج القوي؟',options:['A guess alone','A colourful title only','Relevant evidence'],correct:2},
      {id:'connector',q:'Choose the best connector: The plan was expensive; ___, it saved resources later.',ar:'اختر أداة الربط الأنسب: كانت الخطة مكلفة؛ ومع ذلك وفرت الموارد لاحقًا.',options:['For example','Nevertheless','Because of yesterday'],correct:1},
      {id:'sustainable',q:'A sustainable plan uses resources...',ar:'الخطة المستدامة تستخدم الموارد...',options:['Once and wastes the rest','Wisely over time','Without any evaluation'],correct:1},
      {id:'perspective',q:'What is a perspective?',ar:'ما معنى perspective؟',options:['A final score','A type of notebook','A point of view'],correct:2}
    ]
  };
  return data[code]||data.A1;
}
function journeyGlobalBadges(){
  var totalWords=0,levelsWithPractice=0,certificates=0;
  journeyLevels.forEach(function(item){var level=journeyGetLevel(item.code);totalWords+=level.wordsSeen.length;if(level.speakingKeys.length)levelsWithPractice++;if(level.certificateEarned)certificates++;});
  return [
    {id:'first-steps',icon:'🌱',title:'First Steps',ar:'أول خطواتك',earned:totalWords>=3,rule:'LISTEN TO 3 ITEMS'},
    {id:'practice-explorer',icon:'🧭',title:'Practice Explorer',ar:'مستكشف التدريب',earned:totalWords>=8,rule:'EXPLORE 8 ITEMS'},
    {id:'steady-learner',icon:'✨',title:'Steady Learner',ar:'متعلم مثابر',earned:levelsWithPractice>=3,rule:'PRACTISE IN 3 LEVELS'},
    {id:'learning-champion',icon:'🏆',title:'Learning Champion',ar:'بطل التعلّم',earned:certificates>=1,rule:'EARN A CERTIFICATE'}
  ];
}

function journeyDashboardHtml(){
  return '<style id="mfkj-dashboard-v2-css">#mfKidsStandaloneRoot .mfkj-dash-panel{margin-top:16px;padding:clamp(15px,3vw,22px);border:1px solid rgba(165,77,102,.34);border-radius:19px;background:linear-gradient(145deg,rgba(48,24,34,.76),rgba(14,10,14,.92));box-shadow:0 16px 42px rgba(0,0,0,.19),inset 0 1px 0 rgba(255,255,255,.035)}#mfKidsStandaloneRoot .mfkj-dash-panel-head{display:flex;justify-content:space-between;align-items:flex-start;gap:12px;margin-bottom:14px}#mfKidsStandaloneRoot .mfkj-dash-panel-head h3{font-size:clamp(16px,2vw,21px);margin:5px 0 4px;color:#fff2f6}#mfKidsStandaloneRoot .mfkj-dash-panel-head p{margin:0;color:#baabb2;font-size:11px;line-height:1.7}#mfKidsStandaloneRoot .mfkj-membership-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}#mfKidsStandaloneRoot .mfkj-membership-item{min-width:0;padding:13px;border:1px solid rgba(255,255,255,.07);border-radius:14px;background:linear-gradient(145deg,rgba(35,21,29,.92),rgba(17,12,16,.96))}#mfKidsStandaloneRoot .mfkj-membership-item.is-unlocked{border-color:rgba(98,212,177,.28)}#mfKidsStandaloneRoot .mfkj-membership-item.is-expiring{border-color:rgba(238,188,106,.48)}#mfKidsStandaloneRoot .mfkj-membership-item.is-pending-card{border-color:rgba(173,145,240,.35)}#mfKidsStandaloneRoot .mfkj-membership-item-top{display:flex;justify-content:space-between;align-items:center;gap:5px;flex-wrap:wrap}#mfKidsStandaloneRoot .mfkj-membership-code{font-size:11px;font-weight:950;letter-spacing:.11em;color:#e6bbcb}#mfKidsStandaloneRoot .mfkj-membership-pill{font-size:8px;font-weight:800;border-radius:99px;padding:5px 7px;background:rgba(255,255,255,.05);color:#d8cbd0}#mfKidsStandaloneRoot .mfkj-membership-pill.is-active{color:#9ce9ce;background:rgba(58,164,129,.12)}#mfKidsStandaloneRoot .mfkj-membership-pill.is-pending{color:#d4c3ff;background:rgba(130,105,211,.13)}#mfKidsStandaloneRoot .mfkj-membership-pill.is-locked{color:#c0b0b7}#mfKidsStandaloneRoot .mfkj-membership-item h4{font-size:12px;margin:11px 0 4px;color:#fff0f4}#mfKidsStandaloneRoot .mfkj-membership-item .mfkj-ar{font-size:10px;margin:0;color:#c9b2bc}#mfKidsStandaloneRoot .mfkj-membership-info{display:grid;gap:4px;min-height:48px;margin-top:12px;color:#d4c3cb;font-size:9px;line-height:1.55}#mfKidsStandaloneRoot .mfkj-membership-info small{font-size:9px;color:#a899a2}#mfKidsStandaloneRoot .mfkj-membership-item.is-expiring .mfkj-membership-info small{color:#edc98c}#mfKidsStandaloneRoot .mfkj-membership-action{display:flex;align-items:center;justify-content:space-between;gap:8px;padding:9px 10px;margin-top:11px;border:1px solid rgba(177,95,124,.28);border-radius:10px;background:rgba(105,39,64,.16);color:#f4d7e2;font-size:9px;font-weight:850}#mfKidsStandaloneRoot .mfkj-membership-action span{color:#9ce9ce}#mfKidsStandaloneRoot .mfkj-membership-state{padding:13px;border:1px dashed rgba(184,120,146,.35);border-radius:12px;color:#c9b6c0;font-size:11px;line-height:1.7}#mfKidsStandaloneRoot .mfkj-daily-question{padding:14px;border:1px solid rgba(126,94,189,.27);border-radius:15px;background:linear-gradient(145deg,rgba(34,25,48,.7),rgba(18,12,19,.88))}#mfKidsStandaloneRoot .mfkj-daily-meta{display:flex;justify-content:space-between;gap:8px;flex-wrap:wrap;color:#bea9d5;font-size:8px;font-weight:850;letter-spacing:.1em}#mfKidsStandaloneRoot .mfkj-daily-word-row{display:flex;align-items:center;justify-content:space-between;gap:12px;margin:15px 0 6px}#mfKidsStandaloneRoot .mfkj-daily-word-row h4{font-size:clamp(22px,4vw,30px);margin:5px 0;color:#fff4fa}#mfKidsStandaloneRoot .mfkj-daily-listen{border:1px solid rgba(124,212,192,.34);border-radius:11px;background:rgba(43,126,107,.12);color:#b3f2dc;padding:10px 12px;font-size:10px;font-weight:850}#mfKidsStandaloneRoot .mfkj-daily-question>.mfkj-ar{margin:8px 0 12px;color:#cdbac5;font-size:11px}#mfKidsStandaloneRoot .mfkj-daily-options{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:8px}#mfKidsStandaloneRoot .mfkj-daily-option{min-height:43px;border:1px solid rgba(211,180,202,.14);border-radius:10px;background:rgba(255,255,255,.035);color:#f8e9f0;padding:9px 7px;font-size:11px;font-weight:800}#mfKidsStandaloneRoot .mfkj-daily-option:hover{border-color:rgba(130,232,203,.45);background:rgba(50,141,119,.1)}#mfKidsStandaloneRoot .mfkj-daily-feedback{min-height:18px;margin:10px 0;color:#adf0d8;font-size:10px}#mfKidsStandaloneRoot .mfkj-daily-complete{display:flex;align-items:center;gap:14px;padding:16px;border:1px solid rgba(102,220,172,.35);border-radius:14px;background:linear-gradient(135deg,rgba(43,125,96,.15),rgba(23,17,24,.74))}#mfKidsStandaloneRoot .mfkj-daily-check{display:grid;place-items:center;flex:0 0 42px;height:42px;border-radius:50%;background:rgba(69,177,134,.16);color:#a7f1d5;font-size:22px}#mfKidsStandaloneRoot .mfkj-daily-complete strong{color:#c4f7e4;font-size:14px}#mfKidsStandaloneRoot .mfkj-daily-complete p{margin:5px 0;color:#c8b9c4;font-size:10px;line-height:1.7}#mfKidsStandaloneRoot .mfkj-daily-complete small{font-size:9px;color:#a69aa3}#mfKidsStandaloneRoot .mfkj-daily-builder-title{font-size:18px;margin:6px 0;color:#fff1f8}#mfKidsStandaloneRoot .mfkj-daily-built{display:flex;flex-wrap:wrap;align-items:center;gap:7px;min-height:48px;margin:13px 0;padding:10px;border:1px dashed rgba(171,132,194,.34);border-radius:12px;background:rgba(7,5,9,.25)}#mfKidsStandaloneRoot .mfkj-daily-picked{padding:7px 9px;border:1px solid rgba(119,209,183,.27);border-radius:9px;background:rgba(44,130,106,.14);color:#d1f8e8;font-size:11px;font-weight:850}#mfKidsStandaloneRoot .mfkj-daily-placeholder{color:#9f91a2;font-size:10px}#mfKidsStandaloneRoot .mfkj-daily-word-token{min-height:42px}#mfKidsStandaloneRoot .mfkj-daily-word-token:disabled{opacity:.28;cursor:default}#mfKidsStandaloneRoot .mfkj-daily-builder-actions{display:flex;justify-content:flex-end;margin-top:9px}#mfKidsStandaloneRoot .mfkj-daily-clear{border:1px solid rgba(205,174,195,.18);border-radius:9px;background:rgba(255,255,255,.035);color:#ccb8c7;padding:8px 10px;font-size:9px;font-weight:800}@media(max-width:820px){#mfKidsStandaloneRoot .mfkj-membership-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:540px){#mfKidsStandaloneRoot .mfkj-membership-grid{grid-template-columns:1fr}#mfKidsStandaloneRoot .mfkj-daily-options{grid-template-columns:1fr}#mfKidsStandaloneRoot .mfkj-membership-info{min-height:0}} </style>'+
    '<section class="mfkj-dashboard" id="mfkjDashboard" aria-label="My Learning Journey">'+
    '<div class="mfkj-dash-head"><div class="mfkj-dash-title"><span class="mfkj-kicker">YOUR PROGRESS · رحلتك التعليمية</span><h2>My Learning Journey <i class="mfkj-pulse-dot"></i></h2><p>خطوة صغيرة كل يوم بتقربك من هدفك.</p><a class="mfkr-btn mfkj-review-cta" href="'+url('review')+'">🧠 My Review · مراجعة أخطائي <span id="mfkjReviewCount">0</span></a></div>'+
    '<div class="mfkj-summary-grid"><div class="mfkj-summary-stat"><strong id="mfkjTotalStars">0</strong><span>STARS · نجوم</span></div><div class="mfkj-summary-stat"><strong id="mfkjTotalBadges">0</strong><span>BADGES · شارات</span></div><div class="mfkj-summary-stat"><strong id="mfkjActiveLevels">0/6</strong><span>ACTIVE LEVELS · مستويات بدأت</span></div></div></div>'+
    '<div class="mfkj-level-grid" id="mfkjLevelGrid"></div>'+
    '<section class="mfkj-dash-panel mfkj-membership-panel" aria-label="Kids subscription status"><div class="mfkj-dash-panel-head"><div><span class="mfkj-kicker">YOUR MEMBERSHIP · اشتراكك</span><h3>Subscriptions & access</h3><p lang="ar">تابع حالة كل مستوى وموعد انتهاء الاشتراك.</p></div><span class="mfkj-panel-icon">🔐</span></div><div class="mfkj-membership-grid" id="mfkjMembershipGrid"><div class="mfkj-membership-state">Checking your subscription status…</div></div></section>'+
    '<section class="mfkj-dash-panel mfkj-daily-panel" aria-label="Daily Kids Challenge"><div class="mfkj-dash-panel-head"><div><span class="mfkj-kicker">A LITTLE EVERY DAY · كل يوم خطوة</span><h3>Daily Challenge <i class="mfkj-pulse-dot"></i></h3><p lang="ar">خمس كلمات قصيرة، استمع للنطق ثم رتّب جملة في النهاية.</p></div><span class="mfkj-panel-icon">🎯</span></div><div id="mfkjDailyChallenge"><div class="mfkj-membership-state">Preparing today’s challenge…</div></div></section>'+
    '<div class="mfkj-badge-area"><div class="mfkj-badge-heading"><div><span class="mfkj-kicker">LITTLE WINS</span><h3>Your achievements <span class="mfkj-title-ar">إنجازاتك</span></h3></div><p>النجوم والشارات تُفتح مع التدريب الحقيقي والإجابات الصحيحة.</p></div><div class="mfkj-badge-grid" id="mfkjBadgeGrid"></div></div>'+
    '<p class="mfkj-save-status" id="mfkjSaveStatus">جاري تحميل التقدم…</p>'+
  '</section>';
}

function journeyKidsActiveMembership(){
  var ctx=window.__mfKidsJourneyAccessContext||null;
  if(!ctx||!ctx.user||!Array.isArray(ctx.levels)||!Array.isArray(ctx.subscriptions))return null;
  var active=ctx.current||ctx.subscriptions[0]||null;
  if(!active)return {ctx:ctx,subscription:null,level:null};
  var remote=ctx.levels.find(function(item){return String(item.id)===String(active.level_id);});
  var level=remote&&journeyLevels.find(function(item){return item.code===String(remote.code||'').toUpperCase();});
  return {ctx:ctx,subscription:active,level:level||null};
}
function journeyDateLabel(value){
  var date=value?new Date(value):null;
  if(!date||!Number.isFinite(date.getTime()))return '—';
  try{return date.toLocaleDateString('en-GB',{day:'numeric',month:'short',year:'numeric'});}catch(_){return date.toISOString().slice(0,10);}
}
function journeyRenderMembershipStatus(){
  var host=root.querySelector('#mfkjMembershipGrid');if(!host)return;
  var ctx=window.__mfKidsJourneyAccessContext||null;
  if(!ctx||!ctx.user||!Array.isArray(ctx.levels)){
    host.innerHTML='<div class="mfkj-membership-state">Sign in to view your subscriptions. · سجّل الدخول لمتابعة اشتراكاتك.</div>';
    return;
  }
  var subscriptions=Array.isArray(ctx.subscriptions)?ctx.subscriptions:[];
  var requests=Array.isArray(ctx.requests)?ctx.requests:[];
  var wholeCourse=String(ctx.track&&ctx.track.code||'').toUpperCase()==='KIDS_JOURNEY';
  var courseActive=wholeCourse?subscriptions.filter(function(sub){return String(sub.status||'').toLowerCase()==='active'&&new Date(sub.expires_at).getTime()>Date.now()&&new Date(sub.starts_at).getTime()<=Date.now();}).sort(function(a,b){return new Date(b.expires_at)-new Date(a.expires_at);})[0]:null;
  var coursePending=wholeCourse?requests.find(function(req){return String(req.status||'').toLowerCase()==='pending';}):null;
  var courseLatest=wholeCourse?(coursePending||requests[0]||null):null;
  host.innerHTML=journeyLevels.map(function(item){
    var remoteLevel=ctx.levels.find(function(level){return String(level.code||'').toUpperCase()===item.code;});
    var levelId=remoteLevel&&remoteLevel.id;
    var active=wholeCourse?courseActive:(levelId&&subscriptions.filter(function(sub){return String(sub.level_id)===String(levelId)&&String(sub.status||'').toLowerCase()==='active'&&new Date(sub.expires_at).getTime()>Date.now()&&new Date(sub.starts_at).getTime()<=Date.now();}).sort(function(a,b){return new Date(b.expires_at)-new Date(a.expires_at);})[0]);
    var levelRequests=wholeCourse?requests.filter(function(req){return String(req.status||'').toLowerCase()==='pending'||String(req.requested_level_id)===String(levelId);}).sort(function(a,b){return new Date(b.created_at||0)-new Date(a.created_at||0);}):requests.filter(function(req){return levelId&&String(req.requested_level_id)===String(levelId);}).sort(function(a,b){return new Date(b.created_at||0)-new Date(a.created_at||0);});
    var latest=wholeCourse?courseLatest:(levelRequests[0]||null);
    var action='',badge='',description='',cardClass='';
    if(active){
      var expMs=new Date(active.expires_at).getTime();
      var days=Math.ceil((expMs-Date.now())/86400000);
      var warning=days<=7;
      badge='<span class="mfkj-membership-pill is-active">● Active</span>';
      description='<b>Course access until '+esc(journeyDateLabel(active.expires_at))+'</b><small>'+(warning?'⚠ Expires in '+Math.max(0,days)+' day(s)':'All six levels are unlocked')+'</small>';
      action='<a class="mfkj-membership-action" href="'+url(item.route)+'">Continue learning <span>↗</span></a>';
      cardClass=warning?' is-expiring':' is-unlocked';
    }else if(latest&&String(latest.status||'').toLowerCase()==='pending'){
      badge='<span class="mfkj-membership-pill is-pending">◷ Pending review</span>';
      description='<b>Full-course payment under review</b><small lang="ar">الاشتراك هيتفعّل لكل المستويات بعد مراجعة الأدمن.</small>';
      action='<a class="mfkj-membership-action" href="'+url('entry')+'">طلبك قيد المراجعة · عرض الحالة <span>↗</span></a>';
      cardClass=' is-pending-card';
    }else if(latest&&String(latest.status||'').toLowerCase()==='rejected'){
      badge='<span class="mfkj-membership-pill is-locked">Needs attention</span>';
      description='<b>Full-course request not approved</b><small>'+esc(String(latest.admin_note||'Review the payment details and try again.').slice(0,150))+'</small>';
      action='<a class="mfkj-membership-action" href="'+kidsJourneySubscribeUrl()+'">Review & retry <span>↗</span></a>';
      cardClass=' is-locked';
    }else{
      badge='<span class="mfkj-membership-pill is-locked">Locked</span>';
      description='<b>Full course not active</b><small>One subscription · 100 EGP · 30 days</small>';
      action='<a class="mfkj-membership-action" href="'+kidsJourneySubscribeUrl()+'">Subscribe to all levels <span>↗</span></a>';
      cardClass=' is-locked';
    }
    return '<article class="mfkj-membership-item'+cardClass+'"><div class="mfkj-membership-item-top"><span class="mfkj-membership-code">'+item.code+'</span>'+badge+'</div><h4>'+esc(item.title)+'</h4><p class="mfkj-ar" lang="ar">'+esc(item.arabic)+'</p><div class="mfkj-membership-info">'+description+'</div>'+action+'</article>';
  }).join('');
}

function journeyDailyBank(code){
  var banks={
    A1:[['apple','تفاحة'],['book','كتاب'],['happy','سعيد'],['garden','حديقة'],['friend','صديق'],['school','مدرسة']],
    A2:[['market','سوق'],['choose','يختار'],['hungry','جائع'],['window','نافذة'],['carry','يحمل'],['weather','الطقس']],
    B1:[['improve','يطوّر'],['careful','حذر'],['borrow','يستعير'],['journey','رحلة'],['advice','نصيحة'],['return','يعود']],
    B2:[['reliable','موثوق'],['evidence','دليل'],['compare','يقارن'],['although','بالرغم من'],['solution','حل'],['protect','يحمي']],
    C1:[['accomplish','ينجز'],['clarify','يوضح'],['significant','مهم'],['outcome','نتيجة'],['approach','أسلوب'],['maintain','يحافظ على']],
    C2:[['compelling','مقنع'],['inherent','متأصل'],['ambiguous','ملتبس'],['reinforce','يعزّز'],['plausible','معقول'],['counterpart','نظير']]
  };
  return banks[code]||banks.A1;
}
function journeyLocalDateKey(){
  var now=new Date();
  return now.getFullYear()+'-'+String(now.getMonth()+1).padStart(2,'0')+'-'+String(now.getDate()).padStart(2,'0');
}
function journeyDailyQuestions(code,date){
  var bank=journeyDailyBank(code);
  var ordinal=Math.floor(Date.UTC(Number(date.slice(0,4)),Number(date.slice(5,7))-1,Number(date.slice(8,10)))/86400000);
  var offset=ordinal%bank.length;
  return Array.from({length:5},function(_,index){
    var targetIndex=(offset+index)%bank.length;
    var item=bank[targetIndex];
    var choices=[item,bank[(targetIndex+1)%bank.length],bank[(targetIndex+3)%bank.length]];
    var rotate=(ordinal+index)%choices.length;
    choices=choices.slice(rotate).concat(choices.slice(0,rotate));
    return {word:item[0],meaning:item[1],choices:choices.map(function(choice){return choice[1];}),correct:choices.findIndex(function(choice){return choice[0]===item[0];})};
  });
}
function journeyDailySentence(code,date){
  var choices={
    A1:[
      {answer:['I','like','apples'],arabic:'أنا أحب التفاح.',scrambled:['apples','like','I']},
      {answer:['The','cat','is','happy'],arabic:'القطة سعيدة.',scrambled:['happy','The','is','cat']}
    ],
    A2:[
      {answer:['I','am','hungry'],arabic:'أنا جائع.',scrambled:['hungry','I','am']},
      {answer:['The','weather','is','nice'],arabic:'الطقس جميل.',scrambled:['nice','is','The','weather']}
    ],
    B1:[
      {answer:['I','borrow','a','book'],arabic:'أنا أستعير كتابًا.',scrambled:['book','I','a','borrow']},
      {answer:['We','help','our','friends'],arabic:'نحن نساعد أصدقاءنا.',scrambled:['friends','We','our','help']}
    ],
    B2:[
      {answer:['We','found','a','solution'],arabic:'وجدنا حلًا.',scrambled:['solution','a','We','found']},
      {answer:['They','protect','the','environment'],arabic:'هم يحمون البيئة.',scrambled:['environment','the','They','protect']}
    ],
    C1:[
      {answer:['We','need','a','clear','approach'],arabic:'نحتاج إلى أسلوب واضح.',scrambled:['approach','clear','We','a','need']},
      {answer:['The','results','are','significant'],arabic:'النتائج مهمة.',scrambled:['significant','The','are','results']}
    ],
    C2:[
      {answer:['The','evidence','is','compelling'],arabic:'الأدلة مقنعة.',scrambled:['compelling','evidence','The','is']},
      {answer:['A','clear','plan','can','reinforce','progress'],arabic:'يمكن لخطة واضحة أن تعزّز التقدم.',scrambled:['progress','clear','A','reinforce','plan','can']}
    ]
  };
  var day=Math.floor(Date.UTC(Number(date.slice(0,4)),Number(date.slice(5,7))-1,Number(date.slice(8,10)))/86400000);
  var bank=choices[code]||choices.A1;
  return bank[day%bank.length];
}
function journeyRenderDailyChallenge(){
  var host=root.querySelector('#mfkjDailyChallenge');if(!host)return;
  var membership=journeyKidsActiveMembership();
  if(!membership||!membership.subscription||!membership.level){
    host.innerHTML='<div class="mfkj-membership-state">Activate a Kids level to unlock the daily challenge. · فعّل اشتراك مستوى لفتح تحدّي اليوم.</div>';
    return;
  }
  var code=membership.level.code,date=journeyLocalDateKey(),dailyKey='activity:daily-challenge:'+date;
  var level=journeyGetLevel(code);
  var saved=level.checkpointKeys.indexOf(dailyKey)>=0;
  if(journeyDailyChallengeState.date!==date||journeyDailyChallengeState.levelCode!==code){
    journeyDailyChallengeState={date:date,levelCode:code,index:0,phase:'words',feedback:'',done:false,pickedSentence:[]};
  }
  var questions=journeyDailyQuestions(code,date);
  if(saved||journeyDailyChallengeState.done){
    host.innerHTML='<div class="mfkj-daily-complete"><span class="mfkj-daily-check">✓</span><div><strong>Challenge completed!</strong><p lang="ar">برافو! أنهيت كلمات اليوم ورتّبت الجملة وكسبت نجمة تقدم. ارجع بكرة لتحدٍّ جديد.</p><small>'+journeyDateLabel(date)+' · '+code+'</small></div></div>';
    return;
  }
  if(journeyDailyChallengeState.phase==='sentence'||journeyDailyChallengeState.index>=questions.length){
    var sentence=journeyDailySentence(code,date);
    var picked=Array.isArray(journeyDailyChallengeState.pickedSentence)?journeyDailyChallengeState.pickedSentence:[];
    var chosen=picked.map(function(i){return sentence.scrambled[i];});
    var used=Object.create(null);picked.forEach(function(i){used[i]=true;});
    host.innerHTML='<div class="mfkj-daily-question mfkj-daily-builder"><div class="mfkj-daily-meta"><span>FINAL STEP · SENTENCE BUILDER</span><span>'+code+' · 6 / 6</span></div><span class="mfkj-kicker">PUT THE WORDS IN ORDER</span><h4 class="mfkj-daily-builder-title">Build the sentence</h4><p class="mfkj-ar" lang="ar">'+esc(sentence.arabic)+'</p><div class="mfkj-daily-built" aria-live="polite">'+(chosen.length?chosen.map(function(word){return '<span class="mfkj-daily-picked">'+esc(word)+'</span>';}).join(' '):'<span class="mfkj-daily-placeholder">Tap the words below in the correct order…</span>')+'</div><div class="mfkj-daily-options mfkj-daily-word-bank">'+sentence.scrambled.map(function(word,i){return '<button type="button" class="mfkj-daily-option mfkj-daily-word-token" data-mfkj-daily-sentence-word="'+i+'" '+(used[i]?'disabled':'')+'>'+esc(word)+'</button>';}).join('')+'</div><div class="mfkj-daily-builder-actions"><button class="mfkj-daily-clear" type="button" data-mfkj-daily-clear>Clear order</button></div><p class="mfkj-daily-feedback" role="status">'+esc(journeyDailyChallengeState.feedback||'Arrange the English words to match the Arabic sentence.')+'</p><div class="mfkj-meter" role="progressbar" aria-label="Daily challenge progress" aria-valuemin="0" aria-valuemax="6" aria-valuenow="'+(5+chosen.length)+'"><span style="width:'+((5+chosen.length)/6*100)+'%"></span></div></div>';
    host.querySelectorAll('[data-mfkj-daily-sentence-word]').forEach(function(button){
      button.addEventListener('click',function(){
        var token=Number(button.getAttribute('data-mfkj-daily-sentence-word'));
        if(picked.indexOf(token)>=0)return;
        journeyDailyChallengeState.pickedSentence=picked.concat([token]);
        var currentWords=journeyDailyChallengeState.pickedSentence.map(function(i){return sentence.scrambled[i];});
        if(currentWords.length===sentence.answer.length){
          if(currentWords.join(' ')===sentence.answer.join(' ')){
            journeyDailyChallengeState.done=true;
            questions.forEach(function(question){journeyRecord('daily-word:'+date+':'+question.word,question.word,code);});
            journeyRecord(dailyKey,null,code);
            return;
          }
          journeyDailyChallengeState.feedback='الترتيب مش مضبوط. جرّب مرة تانية. · Not quite — clear the order and try again.';
          journeyDailyChallengeState.pickedSentence=[];
        }else{
          journeyDailyChallengeState.feedback='';
        }
        journeyRenderDailyChallenge();
      });
    });
    var clear=host.querySelector('[data-mfkj-daily-clear]');
    if(clear)clear.addEventListener('click',function(){journeyDailyChallengeState.pickedSentence=[];journeyDailyChallengeState.feedback='Start again from the first word.';journeyRenderDailyChallenge();});
    return;
  }
  var index=Math.max(0,Math.min(questions.length-1,journeyDailyChallengeState.index));
  var q=questions[index];
  host.innerHTML='<div class="mfkj-daily-question"><div class="mfkj-daily-meta"><span>WORD '+(index+1)+' / '+questions.length+'</span><span>'+code+' · '+esc(journeyDateLabel(date))+'</span></div><div class="mfkj-daily-word-row"><div><span class="mfkj-kicker">WHAT DOES THIS WORD MEAN?</span><h4 lang="en">'+esc(q.word)+'</h4></div><button class="mfkj-daily-listen" type="button" data-mfkj-daily-speak aria-label="Listen to '+esc(q.word)+'">🔊 Listen</button></div><p class="mfkj-ar" lang="ar">اختار المعنى العربي الصحيح للكلمة.</p><div class="mfkj-daily-options">'+q.choices.map(function(choice,i){return '<button type="button" class="mfkj-daily-option" data-mfkj-daily-answer="'+i+'">'+esc(choice)+'</button>';}).join('')+'</div><p class="mfkj-daily-feedback" role="status">'+esc(journeyDailyChallengeState.feedback||'اختار إجابة واحدة. · Choose one answer.')+'</p><div class="mfkj-meter" role="progressbar" aria-label="Daily challenge progress" aria-valuemin="0" aria-valuemax="6" aria-valuenow="'+index+'"><span style="width:'+(index/6*100)+'%"></span></div></div>';
  host.querySelectorAll('[data-mfkj-daily-answer]').forEach(function(button){
    button.addEventListener('click',function(){
      var picked=Number(button.getAttribute('data-mfkj-daily-answer'));
      if(picked!==q.correct){
        journeyDailyChallengeState.feedback='قريب! جرّب تاني. · Not quite — try again.';
        journeyRenderDailyChallenge();
        return;
      }
      journeyDailyChallengeState.index=index+1;
      journeyDailyChallengeState.feedback='إجابة صحيحة! ✓ · Correct!';
      if(journeyDailyChallengeState.index>=questions.length){
        journeyDailyChallengeState.phase='sentence';
        journeyDailyChallengeState.pickedSentence=[];
        journeyDailyChallengeState.feedback='ممتاز! دلوقتي رتّب كلمات الجملة. · Great! Build the sentence now.';
      }
      journeyRenderDailyChallenge();
    });
  });
  var listen=host.querySelector('[data-mfkj-daily-speak]');
  if(listen)listen.addEventListener('click',function(){journeySpeak(q.word);});
}

function journeyRenderDashboard(){
  var dash=root.querySelector('#mfkjDashboard');if(!dash)return;
  journeyRenderMembershipStatus();
  journeyRenderDailyChallenge();
  var totalStars=0,totalWords=0,activeLevels=0,pendingReviews=0,certs=0;
  journeyLevels.forEach(function(item){
    var level=journeyGetLevel(item.code);
    totalStars+=level.stars;totalWords+=level.wordsSeen.length;
    pendingReviews+=journeyReviewPendingCount(level);
    if(level.wordsSeen.length||level.speakingKeys.length||level.finalQuizAttempts)activeLevels++;
    if(level.certificateEarned)certs++;
  });
  var badges=journeyGlobalBadges();
  var node=dash.querySelector('#mfkjTotalStars');if(node)node.textContent=totalStars;
  node=dash.querySelector('#mfkjTotalBadges');if(node)node.textContent=badges.filter(function(b){return b.earned;}).length;
  node=dash.querySelector('#mfkjActiveLevels');if(node)node.textContent=activeLevels+'/6';
  node=dash.querySelector('#mfkjReviewCount');if(node)node.textContent=pendingReviews;
  var grid=dash.querySelector('#mfkjLevelGrid');
  if(grid)grid.innerHTML=journeyLevels.map(function(item){
    var level=journeyGetLevel(item.code);
    var wordPart=Math.min(1,level.wordsSeen.length/5)*35;
    var speakPart=Math.min(1,level.speakingKeys.length/3)*30;
    var quizPart=Math.min(1,level.finalQuizBest/4)*35;
    var pct=Math.round(wordPart+speakPart+quizPart);
    var state=level.certificateEarned?'CERTIFICATE EARNED':pct===0?'READY WHEN YOU ARE':pct<55?'IN PROGRESS':pct<100?'KEEP GOING':'CHALLENGE PASSED';
    var detail=level.wordsSeen.length+'/5 items · speaking '+level.speakingKeys.length+'/3 · best quiz '+level.finalQuizBest+'/5';
    if(journeyReviewPendingCount(level))detail+=' · review pending';
    return '<a class="mfkj-level-card" href="'+url(item.route)+'"><div class="mfkj-level-card-top"><span class="mfkj-level-icon">'+item.icon+'</span><span class="mfkj-level-status">'+state+'</span></div><div class="mfkj-level-code">'+item.code+'</div><h3>'+item.title+'</h3><p class="mfkj-ar" lang="ar">'+item.arabic+'</p><p class="mfkj-level-desc">'+item.desc+'</p><div class="mfkj-meter" role="progressbar" aria-label="'+item.code+' completion progress" aria-valuemin="0" aria-valuemax="100" aria-valuenow="'+pct+'"><span style="width:'+pct+'%"></span></div><div class="mfkj-level-meta"><span>⭐ '+level.stars+' stars</span><span>'+pct+'%</span></div><p class="mfkj-level-detail">'+detail+'</p><div class="mfkj-open-row"><span>Open level · افتح المستوى</span><b>↗</b></div></a>';
  }).join('');
  var badgeGrid=dash.querySelector('#mfkjBadgeGrid');
  if(badgeGrid)badgeGrid.innerHTML=badges.map(function(b){
    return '<div class="mfkj-badge-card'+(b.earned?' is-earned':'')+'"><span class="mfkj-badge-icon">'+(b.earned?b.icon:'🔒')+'</span><div><strong>'+b.title+'</strong><small lang="ar">'+b.ar+'</small><em>'+(b.earned?'UNLOCKED':b.rule)+'</em></div></div>';
  }).join('');
  var status=dash.querySelector('#mfkjSaveStatus');
  if(status)status.textContent=journeyUserId?(journeySyncStatus==='error'?'تعذرت المزامنة؛ ما زال التقدم محفوظًا محليًا. تحقق من الاتصال ثم نفذ نشاطًا جديدًا لإعادة المحاولة.':journeySyncStatus==='synced'?'✓ آخر تحديث محفوظ في حسابك.':'تقدمك مرتبط بحسابك؛ تتم المزامنة عند الاتصال.'):'التقدم محفوظ على هذا الجهاز حاليًا. سجّل الدخول لمزامنته بين أجهزتك.';
}
function journeyRenderMiniCard(){
  var code=journeyLevelCode();if(!code)return;
  var wrap=root.querySelector('.mfkr-page .mfkr-wrap');if(!wrap)return;
  var card=root.querySelector('#mfkjMiniCard');
  if(!card){card=document.createElement('section');card.id='mfkjMiniCard';card.className='mfkj-mini-card';var back=wrap.querySelector('.mfkr-back-row');if(back)wrap.insertBefore(card,back);else wrap.appendChild(card);}
  var level=journeyGetLevel(code);
  var pct=Math.round(Math.min(1,level.wordsSeen.length/5)*35+Math.min(1,level.speakingKeys.length/3)*30+Math.min(1,level.finalQuizBest/4)*35);
  card.innerHTML='<div class="mfkj-mini-left"><span class="mfkj-kicker">MY LEARNING JOURNEY</span><h3>⭐ '+level.stars+' Stars <span lang="ar">· '+code+'</span></h3><p>'+level.wordsSeen.length+'/5 items · speaking '+level.speakingKeys.length+'/3 · best quiz '+level.finalQuizBest+'/5</p><div class="mfkj-meter"><span style="width:'+pct+'%"></span></div></div><div class="mfkj-mini-actions"><a class="mfkr-btn mfkj-mini-link" href="'+url('hub')+'">View journey · رحلتي ↗</a><a class="mfkr-btn mfkj-mini-link" href="'+url('review')+'">My Review · مراجعة الأخطاء</a></div>';
}
function journeyRenderCurrent(){
 if(route==='hub')journeyRenderDashboard();
 else if(route==='review')journeyRenderReview();
 else if(route==='map'){if(window.__mfKidsToolsAuthorized)renderCourseMap();}
 else if(route==='parents'){if(window.__mfKidsToolsAuthorized)journeyRenderParentOverview();}
 else if(route==='lab'){if(window.__mfKidsToolsAuthorized)renderLearningLab();}
 else {journeyRenderMiniCard();journeyRenderLevelTools();}
}
function journeyAttachTracker(){
  // Capture steps that redraw their activity panel during the page's own click handler.
  // Deferring the check lets the level renderer finish before we record completion/review.
  root.addEventListener('click',function(event){
    var button=event.target&&event.target.closest?event.target.closest('button'):null;
    if(!button||!root.contains(button))return;
    if(button.matches('[data-b2-sequence]')){
      var hostBefore=button.closest('#mfkrB2Sequence');
      var badgeBefore=hostBefore&&hostBefore.querySelector('.mfkr-quiz-badge');
      var stepMatch=badgeBefore&&String(badgeBefore.textContent||'').match(/EVENT\s+(\d+)/i);
      var stepNumber=stepMatch?Number(stepMatch[1]):1;
      var selectedText=String(button.textContent||'').replace(/\s+/g,' ').trim();
      setTimeout(function(){
        var host=root.querySelector('#mfkrB2Sequence');
        if(!host)return;
        if((host.querySelector('h3')&&host.querySelector('h3').textContent.indexOf('Story in order!')>=0)){
          journeyRecord('activity:b2-story-order-completed',null,'B2');
          return;
        }
        var badge=host.querySelector('.mfkr-quiz-badge'),m=badge&&String(badge.textContent||'').match(/EVENT\s+(\d+)/i),nextStep=m?Number(m[1]):stepNumber;
        if(nextStep>stepNumber){
          journeyRecord('activity:b2-story-sequence-step:'+stepNumber,null,'B2');
          return;
        }
        var feedback=host.querySelector('#mfkrB2SequenceFeedback');
        if(feedback&&feedback.classList.contains('is-wrong')){
          var expected=host.querySelector('[data-b2-sequence="'+String(stepNumber-1)+'"]');
          journeyAddReviewItem({
            id:'B2|story-sequence|step-'+stepNumber,
            question:'Which event comes next in the story?',
            arabic:'اختار الحدث الذي يأتي بعده في القصة.',
            selected:selectedText,
            correct:expected?String(expected.textContent||'').replace(/\s+/g,' ').trim():'Read the story and choose the next event.',
            kind:'story-sequence'
          },'B2');
        }
      },0);
    }
    if(button.matches('[data-b2-connector-next]')){
      setTimeout(function(){
        var host=root.querySelector('#mfkrB2Connectors');
        if(host&&host.querySelector('h3')&&host.querySelector('h3').textContent.indexOf('Ideas connected!')>=0){
          journeyRecord('activity:b2-connector-lab-completed',null,'B2');
        }
      },0);
    }
  },true);

  root.addEventListener('click',function(event){
    var target=event.target;
    if(!target||!target.closest)return;
    var button=target.closest('button');
    if(!button||!root.contains(button))return;
    if(button.hasAttribute('data-mfj-parent-refresh')){kidsJourneyHandleParentRoute();return;}
    if(button.hasAttribute('data-mfj-speaking-record-start')){mfkjStartSpeakingRecording();return;}
    if(button.hasAttribute('data-mfj-speaking-record-stop')){mfkjStopSpeakingRecording();return;}
    if(button.hasAttribute('data-mfj-speaking-record-delete')){mfkjClearSpeakingRecording();var recordingHost=root.querySelector('#mfkjSpeakingRecording'),recordingStatus=root.querySelector('#mfkjSpeakingRecorderStatus');if(recordingHost)recordingHost.innerHTML='';if(recordingStatus)recordingStatus.textContent='تم حذف التسجيل من هذه الجلسة.';var startButton=root.querySelector('[data-mfj-speaking-record-start]'),stopButton=root.querySelector('[data-mfj-speaking-record-stop]'),deleteButton=root.querySelector('[data-mfj-speaking-record-delete]');if(startButton)startButton.disabled=false;if(stopButton)stopButton.disabled=true;if(deleteButton)deleteButton.disabled=true;return;}
    if(button.hasAttribute('data-mfj-speaking-listen')){var listenM=journeySpeakingData(journeyLevelCode())[journeySpeakingCurrentIndex()];if(listenM)journeySpeak(listenM.q);return;}
    if(button.hasAttribute('data-mfj-speaking-answer')){journeySpeak(button.getAttribute('data-mfj-speaking-answer'));return;}
    if(button.hasAttribute('data-mfj-speaking-complete')){journeyCompleteSpeaking();return;}
    if(button.hasAttribute('data-mfj-speaking-replay')){journeyToolState.speakingReplay=true;journeyToolState.speakingReplayIndex=0;journeyToolState.speakingPendingId='';journeyToolState.speakingPendingIndex=0;journeyToolState.speakingFeedback='Practise all three missions again. نجرب المواقف مرة تانية.';journeyToolState.speakingWrongOption=-1;journeyRenderCurrent();return;}
    if(button.hasAttribute('data-mfj-speaking-choice')){journeyHandleSpeakingChoice(Number(button.getAttribute('data-mfj-speaking-choice')));return;}
    if(button.hasAttribute('data-mfj-final-choice')){journeyHandleFinalChoice(Number(button.getAttribute('data-mfj-final-choice')));return;}
    if(button.hasAttribute('data-mfj-final-next')){journeyHandleFinalNext();return;}
    if(button.hasAttribute('data-mfj-final-restart')){journeyToolState.finalIndex=0;journeyToolState.finalScore=0;journeyToolState.finalAnswered=false;journeyToolState.finalPicked=-1;journeyToolState.finalFeedback='';journeyToolState.finalFinished=false;journeyRenderCurrent();return;}
    if(button.hasAttribute('data-mfj-review-speak')){journeySpeak(button.getAttribute('data-mfj-review-speak'));return;}
    if(button.hasAttribute('data-mfj-review-done')){journeyMarkReviewDone(button.getAttribute('data-mfj-review-done'));return;}
    if(button.hasAttribute('data-mfj-print-certificate')){journeyPrintCertificate();return;}
    if(button.classList.contains('is-wrong')){journeyCaptureWrongAnswer(button);return;}

    // These controls can become disabled after the level renderer validates the action.
    // Process their completed state before the disabled-button guard.
    if(button.classList.contains('is-correct')){
      var host=button.closest('#mfkrA2Quiz,#mfkrB1Quiz,#mfkrC1Quiz,#mfkrB2Quiz,#mfkrC2Quiz,#mfkrC2Inference,#mfkrC2Connectors,#mfkrC2Speaking,#mfkrA2Match,#mfkrB2Sequence');
      var h=host&&host.querySelector?host.querySelector('h3[lang="en"],h3,h4,[data-quiz-question]'):null;
      var q=String(h?h.textContent:(host&&host.id)||button.parentElement.textContent||'quiz').replace(/\s+/g,' ').trim().slice(0,90);
      journeyRecord('activity:correct:'+journeyLevelCode()+':'+q.toLowerCase());
      return;
    }
    if(button.matches('[data-a2-next]')){
      var a2Feedback=root.querySelector('#mfkrA2BuilderFeedback');
      if(a2Feedback&&/Amazing!|أكملت كل الجمل بنجاح/.test(a2Feedback.textContent||''))journeyRecord('activity:a2-sentence-builder-completed');
      return;
    }
    if(button.matches('[data-c1-check]')){
      var c1Feedback=root.querySelector('#mfkrC1BuilderFeedback');
      if(c1Feedback&&c1Feedback.classList.contains('is-right'))journeyRecord('activity:c1-sentence-builder-completed');
      return;
    }
    if(button.matches('[data-c2-writing-save]')){
      var draft=root.querySelector('#mfkrC2WritingDraft'),draftWords=String(draft&&draft.value||'').trim().match(/\S+/g)||[];
      if(draftWords.length>=40)journeyRecord('activity:c2-writing-completed');
      return;
    }
    if(button.matches('[data-a2-story-done],[data-b2-read-done],[data-c2-read-done]')){
      var readingKey=button.getAttribute('data-a2-story-done')||button.getAttribute('data-b2-read-done')||button.getAttribute('data-c2-read-done')||'reading';
      journeyRecord('activity:reading:'+journeyLevelCode()+':'+readingKey);
      return;
    }
    if(button.disabled||button.closest('.mfkr-top,.mfkr-back-row'))return;
    var attrs=Array.prototype.slice.call(button.attributes||[]);
    var soundAttr=attrs.find(function(a){return /^data-(kids|a2|b1|b2|c1|c2)-speak$/i.test(a.name);});
    var trackedWord=button.getAttribute('data-a2-word-track')||button.getAttribute('data-c2-track')||button.getAttribute('data-b2-track');
    if(soundAttr||trackedWord){
      var spoken=String((soundAttr&&soundAttr.value)||trackedWord||'').replace(/\s+/g,' ').trim();
      if(spoken)journeyRecord('word:'+spoken.toLowerCase().slice(0,100),spoken);
    }
  });
  root.addEventListener('input',function(event){
    var field=event.target;
    if(field&&field.matches&&field.matches('textarea.mfkr-c2-writing-area')&&!journeyWritingQueued&&String(field.value||'').trim().length>=30){
      journeyWritingQueued=true;journeyRecord('draft:c2-writing-draft-started');
    }
    if(field&&field.matches&&field.matches('[data-mfj-certificate-name]')){
      journeyCertificateName=String(field.value||'').slice(0,80);
      try{localStorage.setItem('mrfluent-kids-certificate-name:'+(journeyUserId||'guest'),journeyCertificateName);}catch(_){}
    }
  });
}
async function journeyInit(){
  journeyLoading=true;
  var user=null;
  try{
    if(typeof sessionUser!=='undefined'&&sessionUser)user=sessionUser;
    if(!user&&typeof sb!=='undefined'&&sb&&sb.auth){var session=await sb.auth.getSession();user=session&&session.data&&session.data.session&&session.data.session.user||null;}
  }catch(_){}
  journeyUserId=user&&user.id||null;
  journeySyncStatus=journeyUserId?'loading':'local';
  journeyStoreKey='mrfluent-kids-journey-v1:'+(journeyUserId||'guest');
  try{journeyCertificateName=localStorage.getItem('mrfluent-kids-certificate-name:'+(journeyUserId||'guest'))||'';}catch(_){}
  journeyData={levels:{}};
  var local=journeyLocalRead(journeyStoreKey);
  if(local&&local.levels)Object.keys(local.levels).forEach(function(code){journeyMergeLevel(code,local.levels[code]);});
  ['A2','B2','C2'].forEach(journeyLoadLegacyLocal);
  var journeyServerLevels=[];
  var journeyServerLoaded=false;
  if(journeyUserId&&typeof sb!=='undefined'&&sb&&sb.from){
    try{
      var central=await sb.from('mrfluent_kids_journey_progress').select('level_code,checkpoint_keys,words_seen,stars,badges,wrong_answers,final_quiz_best,final_quiz_attempts,speaking_completed,certificate_earned,certificate_code,certified_at,updated_at').eq('user_id',journeyUserId);
      if(central.error)throw central.error;
      if(Array.isArray(central.data))central.data.forEach(function(row){
        journeyMergeLevel(row.level_code,row);
        var serverLevel=journeyGetLevel(row.level_code);
        serverLevel.certificateEarned=!!row.certificate_earned;
        serverLevel.certificateCode=row.certificate_code||'';
        serverLevel.certifiedAt=row.certified_at||null;
        journeyRecalculate(serverLevel);
        if(journeyServerLevels.indexOf(row.level_code)<0)journeyServerLevels.push(row.level_code);
      });
      journeyServerLoaded=true;
      journeySyncStatus='synced';
    }catch(_){journeySyncStatus='error';}
    var specs=[{code:'A2',table:'mrfluent_growing_progress'},{code:'B2',table:'mrfluent_growing_b2_progress'},{code:'C2',table:'mrfluent_growing_c2_progress'}];
    var legacyRows=await Promise.all(specs.map(async function(spec){
      try{var response=await sb.from(spec.table).select('completed_words,completed_activities,best_quiz_score,quiz_attempts').eq('user_id',journeyUserId).eq('level_code',spec.code).order('updated_at',{ascending:false}).limit(1);if(response.error||!Array.isArray(response.data)||!response.data.length)return null;return {code:spec.code,row:response.data[0]};}catch(_){return null;}
    }));
    legacyRows.forEach(function(entry){if(entry)journeyMergeLegacy(entry.code,entry.row);});
  }
  journeyLevels.forEach(function(item){
    var level=journeyGetLevel(item.code);
    if(journeyUserId&&journeyServerLoaded&&journeyServerLevels.indexOf(item.code)<0){
      level.certificateEarned=false;
      level.certificateCode='';
      level.certifiedAt=null;
      journeyRecalculate(level);
    }
    journeyMaybeAwardCertificate(item.code);
  });
  journeySaveLocal();
  journeyLoading=false;
  var pending=journeyPending.slice();journeyPending=[];
  pending.forEach(function(item){if(item.type==='review')journeyAddReviewItem(item.item,item.code);else journeyRecord(item.actionKey,item.wordValue,item.code);});
  journeyRenderCurrent();
}

function journeySpeakingCurrentIndex(){
  var code=journeyLevelCode(),level=journeyGetLevel(code),missions=journeySpeakingData(code);
  if(journeyToolState.speakingReplay)return Math.max(0,Math.min(missions.length-1,journeyToolState.speakingReplayIndex||0));
  for(var i=0;i<missions.length;i++)if(level.checkpointKeys.indexOf('speaking:'+missions[i].id)<0)return i;
  return missions.length-1;
}
function journeyRenderLevelTools(){
  var code=journeyLevelCode();if(!code)return;
  var wrap=root.querySelector('.mfkr-page .mfkr-wrap');if(!wrap)return;
  function ensure(id,cls){var el=root.querySelector('#'+id);if(!el){el=document.createElement('section');el.id=id;el.className=cls;var back=wrap.querySelector('.mfkr-back-row');if(back)wrap.insertBefore(el,back);else wrap.appendChild(el);}return el;}
  if(journeyToolState.route!==route){journeyToolState={route:route,speakingFeedback:'',speakingWrongOption:-1,speakingReplay:false,speakingReplayIndex:0,speakingPendingId:'',speakingPendingIndex:0,finalIndex:0,finalScore:0,finalAnswered:false,finalPicked:-1,finalFeedback:'',finalFinished:false};}
  var level=journeyGetLevel(code),missions=journeySpeakingData(code),mi=journeySpeakingCurrentIndex();
  var speaking=ensure('mfkjSpeaking','mfkj-panel');
  if(level.speakingCompleted&&!journeyToolState.speakingReplay) speaking.innerHTML='<div class="mfkj-panel-head"><div><span class="mfkj-kicker">SPEAKING MISSIONS · محادثة</span><h2>Speaking Studio <i class="mfkj-pulse-dot"></i></h2><p lang="ar">أحسنت! أكملت المواقف الثلاثة لهذا المستوى.</p></div><span class="mfkj-panel-icon">💬</span></div><div class="mfkj-complete-note">✓ 3 / 3 speaking missions completed</div><button type="button" class="mfkr-btn mfkj-secondary" data-mfj-speaking-replay>Practise again · تدريب مرة أخرى</button>';
  else{
    var mission=missions[mi],pendingSpeaking=journeyToolState.speakingPendingId===mission.id;
    var speakingContent=pendingSpeaking?
      '<div class="mfkj-model-reply"><span class="mfkj-kicker">MODEL REPLY · الرد الصحيح</span><p lang="en">'+esc(mission.options[mission.correct].en)+'</p><p lang="ar" dir="rtl">'+esc(mission.options[mission.correct].ar)+'</p><div class="mfkj-model-actions"><button type="button" class="mfkr-btn mfkj-secondary" data-mfj-speaking-answer="'+esc(mission.options[mission.correct].en)+'">🔊 Listen to the reply · اسمع الرد</button><button type="button" class="mfkr-btn mfkj-primary" data-mfj-speaking-complete>I said it aloud ✓ · قلتها بصوتي</button></div><small class="mfkj-self-practice-note">اسمع الجملة وكرّرها بصوت واضح، ثم اضغط «قلتُها بصوتي» لإتمام المهمة.</small><div class="mfkj-speaking-recorder" style="margin-top:14px;padding:13px;border-radius:14px;background:rgba(255,255,255,.045);border:1px solid rgba(204,169,110,.25)"><p lang="ar" dir="rtl" style="margin:0 0 10px">تدريب اختياري: سجّل الجملة لمدة تصل إلى 15 ثانية ثم استمع إليها وقارنها بالنموذج. التسجيل مؤقت داخل الجلسة فقط؛ لا يتم رفعه أو حفظه في حسابك. استخدم الميكروفون بموافقة ولي أمرك.</p><div style="display:flex;gap:8px;flex-wrap:wrap"><button type="button" class="mfkr-btn mfkj-secondary" data-mfj-speaking-record-start>🎙️ ابدأ التسجيل</button><button type="button" class="mfkr-btn mfkj-secondary" data-mfj-speaking-record-stop disabled>إيقاف التسجيل</button><button type="button" class="mfkr-btn mfkj-secondary" data-mfj-speaking-record-delete disabled>حذف التسجيل</button></div><div id="mfkjSpeakingRecording" style="margin-top:8px"></div><p id="mfkjSpeakingRecorderStatus" class="mfkj-feedback" aria-live="polite">لا يوجد تسجيل بعد. يمكنك الاكتفاء بالاستماع والتكرار.</p><small>لا نقدم درجة آلية للنطق؛ استخدم التسجيل لمقارنة وضوح الكلمات ونهاياتها وسرعة الكلام بالنموذج.</small></div></small></div>':
      '<div class="mfkj-choice-list">'+mission.options.map(function(opt,index){return '<button type="button" class="mfkj-choice-option'+(journeyToolState.speakingWrongOption===index?' is-wrong':'')+'" data-mfj-speaking-choice="'+index+'"><span>'+esc(opt.en)+'</span><small lang="ar" dir="rtl">'+esc(opt.ar)+'</small></button>';}).join('')+'</div>';
    speaking.innerHTML='<div class="mfkj-panel-head"><div><span class="mfkj-kicker">SPEAKING MISSIONS · محادثة</span><h2>Speaking Studio <i class="mfkj-pulse-dot"></i></h2><p lang="ar">اختار الرد المناسب، وبعدها اسمعه وكرّره بصوتك لإتمام المهمة.</p></div><span class="mfkj-panel-icon">💬</span></div><div class="mfkj-mission-meta"><span>MISSION '+(mi+1)+' / '+missions.length+'</span><span>'+level.speakingKeys.length+' completed</span></div><div class="mfkj-mission-question"><p lang="en">'+esc(mission.q)+'</p><p lang="ar" dir="rtl">'+esc(mission.ar)+'</p><button class="mfkr-btn mfkj-secondary" type="button" data-mfj-speaking-listen>🔊 Listen to the question · اسمع السؤال</button></div>'+speakingContent+'<p class="mfkj-feedback" aria-live="polite">'+esc(journeyToolState.speakingFeedback||'اختار الرد المناسب لإكمال المهمة.')+'</p><div class="mfkj-panel-foot"><span>⭐ اختار الرد الصحيح ثم كرّره بصوتك لإكمال المهمة.</span></div>';
  }
  var final=ensure('mfkjFinal','mfkj-panel');
  var questions=journeyFinalQuestions(code);
  if(journeyToolState.finalFinished){
    var passed=journeyToolState.finalScore>=4;
    final.innerHTML='<div class="mfkj-panel-head"><div><span class="mfkj-kicker">LEVEL CHALLENGE · الاختبار النهائي</span><h2>Final Challenge</h2><p lang="ar">النتيجة محفوظة في تقدم المستوى.</p></div><span class="mfkj-panel-icon">🏆</span></div><div class="mfkj-final-result"><span class="mfkj-result-icon">'+(passed?'🏆':'📘')+'</span><h3>'+(passed?'Challenge passed!':'Keep practising!')+'</h3><p>Score: '+journeyToolState.finalScore+' / 5 · Best: '+level.finalQuizBest+' / 5</p><p lang="ar" dir="rtl">'+(passed?'ممتاز! حصلت على 4 إجابات صحيحة على الأقل.':'راجع My Review وتدرّب ثم أعد الاختبار. تحتاج إلى 4 إجابات صحيحة من 5.')+'</p><button type="button" class="mfkr-btn mfkj-primary" data-mfj-final-restart>Try again · إعادة الاختبار</button></div>';
  }else{
    var qi=Math.max(0,Math.min(journeyToolState.finalIndex,questions.length-1)),q=questions[qi];
    final.innerHTML='<div class="mfkj-panel-head"><div><span class="mfkj-kicker">LEVEL CHALLENGE · الاختبار النهائي</span><h2>Final Challenge</h2><p lang="ar">خمس أسئلة تناسب المستوى. النجاح من 4 إجابات صحيحة.</p></div><span class="mfkj-panel-icon">🏆</span></div><div class="mfkj-mission-meta"><span>QUESTION '+(qi+1)+' / '+questions.length+'</span><span>Current score: '+journeyToolState.finalScore+'</span></div><div class="mfkj-mission-question"><p lang="en">'+q.q+'</p><p lang="ar" dir="rtl">'+q.ar+'</p></div><div class="mfkj-choice-list">'+q.options.map(function(opt,index){return '<button type="button" class="mfkj-choice-option'+(journeyToolState.finalAnswered&&index===q.correct?' is-correct':'')+(journeyToolState.finalAnswered&&index===journeyToolState.finalPicked&&index!==q.correct?' is-wrong':'')+'" data-mfj-final-choice="'+index+'"'+(journeyToolState.finalAnswered?' disabled':'')+'><span>'+opt+'</span></button>';}).join('')+'</div><p class="mfkj-feedback" aria-live="polite">'+(journeyToolState.finalFeedback||'اختار إجابة واحدة. الأخطاء هتظهر في My Review.')+'</p>'+(journeyToolState.finalAnswered?'<button type="button" class="mfkr-btn mfkj-primary" data-mfj-final-next>'+(qi===questions.length-1?'Finish challenge · إنهاء الاختبار':'Next question · السؤال التالي')+' →</button>':'')+'<div class="mfkj-panel-foot"><span>Best score: '+level.finalQuizBest+' / 5</span><span>Attempts: '+level.finalQuizAttempts+'</span></div>';
  }
  var cert=ensure('mfkjCertificate','mfkj-panel mfkj-certificate');
  journeyMaybeAwardCertificate(code);level=journeyGetLevel(code);
  if(level.certificateEarned){
    cert.innerHTML='<div class="mfkj-certificate-sheet"><div class="mfkj-certificate-top">MR. FLUENT KIDS · CERTIFICATE OF ACHIEVEMENT</div><div class="mfkj-certificate-star">✦</div><h2>Certificate of Achievement</h2><p lang="ar" dir="rtl">شهادة إنجاز وإتمام المستوى</p><label for="mfkjCertificateName">Learner name · اسم الطفل</label><input id="mfkjCertificateName" data-mfj-certificate-name maxlength="80" placeholder="Enter the learner name" value="'+esc(journeyCertificateName)+'"/><div class="mfkj-certificate-level">'+code+' · '+journeyLevels.filter(function(x){return x.code===code;})[0].title+'</div><p class="mfkj-certificate-copy">Awarded for completing the speaking missions and passing the level challenge.</p><p class="mfkj-certificate-copy" lang="ar" dir="rtl">تُمنح هذه الشهادة لإكمال مهام المحادثة واجتياز اختبار المستوى.</p><div class="mfkj-certificate-meta"><span>Certificate ID: '+esc(level.certificateCode||('MF-'+code))+'</span><span>'+esc((level.certifiedAt||new Date().toISOString()).slice(0,10))+'</span></div><button type="button" class="mfkr-btn mfkj-primary" data-mfj-print-certificate>Print / Save as PDF · طباعة أو حفظ PDF</button><p class="mfkj-certificate-note">'+(journeyUserId?'✓ تم حفظ إنجاز الشهادة في حسابك.':'الشهادة محفوظة على هذا الجهاز؛ سجّل الدخول لمزامنتها.')+'</p></div>';
  }else{
    var words=level.wordsSeen.length,speakingCount=level.speakingKeys.length,quizPass=level.finalQuizBest>=4;
    cert.innerHTML='<div class="mfkj-panel-head"><div><span class="mfkj-kicker">CERTIFICATE PATH · الشهادة</span><h2>Level Certificate</h2><p lang="ar">أكمل المتطلبات للحصول على شهادة يمكنك حفظها PDF.</p></div><span class="mfkj-panel-icon">🎓</span></div><div class="mfkj-requirements"><div class="'+(words>=5?'done':'')+'"><span>'+(words>=5?'✓':'1')+'</span><p><b>Explore 5 words or phrases</b><small lang="ar">استمع إلى 5 كلمات أو عبارات مختلفة</small><em>'+Math.min(words,5)+' / 5</em></p></div><div class="'+(speakingCount>=3?'done':'')+'"><span>'+(speakingCount>=3?'✓':'2')+'</span><p><b>Say 3 replies aloud</b><small lang="ar">أكمل 3 مهام محادثة وكرّر الردود بصوتك</small><em>'+Math.min(speakingCount,3)+' / 3</em></p></div><div class="'+(quizPass?'done':'')+'"><span>'+(quizPass?'✓':'3')+'</span><p><b>Pass the final challenge (4/5)</b><small lang="ar">احصل على 4 إجابات صحيحة من 5</small><em>'+level.finalQuizBest+' / 5</em></p></div></div><p class="mfkj-feedback">'+(words>=5&&speakingCount>=3&&quizPass?'جاري تجهيز الشهادة…':'الشهادة هتتفتح تلقائيًا بعد استيفاء الشروط الثلاثة.')+'</p>';
  }
  var review=ensure('mfkjToolsReview','mfkj-panel mfkj-review-shortcut');
  var pending=level.wrongAnswers.filter(function(w){return !w.reviewed;}).length;
  review.innerHTML='<div class="mfkj-panel-head"><div><span class="mfkj-kicker">LEARN FROM MISTAKES · اتعلم من أخطائك</span><h2>My Review</h2><p lang="ar">'+pending+' سؤال محتاج مراجعة في هذا المستوى.</p></div><span class="mfkj-panel-icon">🧠</span></div><p class="mfkj-review-desc">كل إجابة غلط هتتحفظ للمراجعة، وتقدر تسمع الإجابة الصحيحة وتتدرّب عليها.</p><a class="mfkr-btn mfkj-secondary" href="'+url('review')+'">Open My Review · افتح المراجعة ↗</a>';
}
function journeyHandleSpeakingChoice(index){
  var code=journeyLevelCode(),missions=journeySpeakingData(code),mi=journeySpeakingCurrentIndex(),mission=missions[mi];
  if(!mission||journeyToolState.speakingPendingId)return;
  var choice=mission.options[index];if(!choice)return;
  if(index===mission.correct){
    journeyToolState.speakingFeedback='ممتاز! اسمع الرد الصحيح وكرّره بصوتك، وبعدها اضغط «قلتُها بصوتي».';
    journeyToolState.speakingWrongOption=-1;
    journeyToolState.speakingPendingId=mission.id;
    journeyToolState.speakingPendingIndex=mi;
  }else{
    journeyToolState.speakingWrongOption=index;
    journeyToolState.speakingFeedback='قريب! جرّب تاني. الإجابة الصحيحة هتظهر في My Review لو احتجتها.';
    journeyAddReviewItem({id:code+'|speaking|'+mission.id,question:mission.q,arabic:mission.ar,selected:choice.en,correct:mission.options[mission.correct].en,kind:'speaking'},code);
  }
  journeyRenderCurrent();
}

var mfkjSpeakingRecorderState={recorder:null,stream:null,chunks:[],objectUrl:null,timer:null};
function mfkjClearSpeakingRecording(){
 var state=mfkjSpeakingRecorderState;
 if(state.timer){clearTimeout(state.timer);state.timer=null;}
 if(state.recorder){try{state.recorder.onstop=null;if(state.recorder.state!=='inactive')state.recorder.stop();}catch(_){}state.recorder=null;}
 if(state.stream){try{state.stream.getTracks().forEach(function(track){track.stop();});}catch(_){}state.stream=null;}
 if(state.objectUrl){try{URL.revokeObjectURL(state.objectUrl);}catch(_){}state.objectUrl=null;}
 state.chunks=[];
}
function mfkjStopSpeakingRecording(){
 var state=mfkjSpeakingRecorderState;
 if(state.recorder&&state.recorder.state!=='inactive'){try{state.recorder.stop();}catch(_){}}
}
async function mfkjStartSpeakingRecording(){
 var status=root.querySelector('#mfkjSpeakingRecorderStatus');
 var startButton=root.querySelector('[data-mfj-speaking-record-start]');
 var stopButton=root.querySelector('[data-mfj-speaking-record-stop]');
 var deleteButton=root.querySelector('[data-mfj-speaking-record-delete]');
 var host=root.querySelector('#mfkjSpeakingRecording');
 if(!navigator.mediaDevices||!navigator.mediaDevices.getUserMedia||typeof MediaRecorder==='undefined'){
  if(status)status.textContent='هذا المتصفح لا يدعم التسجيل الصوتي هنا. استخدم زر الاستماع وكرّر الجملة بصوتك.';
  return;
 }
 mfkjClearSpeakingRecording();
 try{
  var stream=await navigator.mediaDevices.getUserMedia({audio:true});
  var state=mfkjSpeakingRecorderState;
  var recorder=new MediaRecorder(stream);
  state.stream=stream;state.recorder=recorder;state.chunks=[];
  recorder.ondataavailable=function(event){if(event.data&&event.data.size)state.chunks.push(event.data);};
  recorder.onerror=function(){if(status)status.textContent='تعذر إكمال التسجيل. تحقق من إذن الميكروفون وحاول مرة أخرى.';};
  recorder.onstop=function(){
   if(state.timer){clearTimeout(state.timer);state.timer=null;}
   if(state.stream){try{state.stream.getTracks().forEach(function(track){track.stop();});}catch(_){}state.stream=null;}
   state.recorder=null;
   var blob=new Blob(state.chunks,{type:recorder.mimeType||'audio/webm'});
   state.chunks=[];
   if(!blob.size){if(status)status.textContent='لم يتم التقاط صوت. حاول مرة أخرى.';if(startButton)startButton.disabled=false;if(stopButton)stopButton.disabled=true;return;}
   if(state.objectUrl){try{URL.revokeObjectURL(state.objectUrl);}catch(_){}}
   state.objectUrl=URL.createObjectURL(blob);
   if(host){host.innerHTML='';var audio=document.createElement('audio');audio.controls=true;audio.preload='none';audio.src=state.objectUrl;audio.style.width='100%';audio.setAttribute('aria-label','Your temporary speaking practice recording');host.appendChild(audio);}
   if(status)status.textContent='تم التسجيل. استمع الآن وقارن صوتك بالنموذج؛ التسجيل غير محفوظ وسيختفي عند مغادرة الصفحة أو حذفه.';
   if(startButton)startButton.disabled=false;if(stopButton)stopButton.disabled=true;if(deleteButton)deleteButton.disabled=false;
  };
  recorder.start(250);
  if(status)status.textContent='جاري التسجيل… سيتوقف تلقائيًا بعد 15 ثانية.';
  if(startButton)startButton.disabled=true;if(stopButton)stopButton.disabled=false;if(deleteButton)deleteButton.disabled=true;
  state.timer=setTimeout(function(){mfkjStopSpeakingRecording();},15000);
 }catch(error){
  if(status)status.textContent='لم نتمكن من فتح الميكروفون. اسمح باستخدامه من إعدادات المتصفح ثم حاول مرة أخرى.';
  if(startButton)startButton.disabled=false;if(stopButton)stopButton.disabled=true;if(deleteButton)deleteButton.disabled=true;
 }
}
if(!window.__mfkjSpeakingPagehideBound){window.addEventListener('pagehide',mfkjClearSpeakingRecording);window.__mfkjSpeakingPagehideBound=true;}

function journeyCompleteSpeaking(){
  var code=journeyLevelCode(),missions=journeySpeakingData(code),mi=Number(journeyToolState.speakingPendingIndex)||0,mission=missions[mi];
  if(!mission||journeyToolState.speakingPendingId!==mission.id)return;
  mfkjClearSpeakingRecording();
  var replay=!!journeyToolState.speakingReplay;
  journeyToolState.speakingPendingId='';
  journeyToolState.speakingPendingIndex=0;
  journeyToolState.speakingWrongOption=-1;
  if(replay){
    journeyToolState.speakingReplayIndex=mi+1;
    if(journeyToolState.speakingReplayIndex>=missions.length){
      journeyToolState.speakingReplay=false;
      journeyToolState.speakingReplayIndex=0;
      journeyToolState.speakingFeedback='Great practice! أنهيت التدريب مرة أخرى.';
    }else{
      journeyToolState.speakingFeedback='ممتاز! ننتقل للموقف التالي.';
    }
  }else{
    journeyToolState.speakingFeedback='تم إكمال مهمة المحادثة بعد التدريب بصوتك ✓';
  }
  journeyRecord('speaking:'+mission.id,null,code);
  journeyMaybeAwardCertificate(code);
  journeyRenderCurrent();
}
function journeyHandleFinalChoice(index){
  if(journeyToolState.finalAnswered||journeyToolState.finalFinished)return;
  var code=journeyLevelCode(),questions=journeyFinalQuestions(code),q=questions[journeyToolState.finalIndex];
  if(!q||!q.options[index])return;
  journeyToolState.finalPicked=index;journeyToolState.finalAnswered=true;
  if(index===q.correct){
    journeyToolState.finalScore++;
    journeyToolState.finalFeedback='Correct! إجابة صحيحة.';
    journeyRecord('activity:final:'+q.id,null,code);
  }else{
    journeyToolState.finalFeedback='راجع الاختيار الصحيح في My Review ثم حاول مرة أخرى.';
    journeyAddReviewItem({id:code+'|final|'+q.id,question:q.q,arabic:q.ar,selected:q.options[index],correct:q.options[q.correct],kind:'final-challenge'},code);
  }
  journeyRenderCurrent();
}
function journeyHandleFinalNext(){
  if(!journeyToolState.finalAnswered)return;
  var questions=journeyFinalQuestions(journeyLevelCode());
  if(journeyToolState.finalIndex<questions.length-1){
    journeyToolState.finalIndex++;journeyToolState.finalAnswered=false;journeyToolState.finalPicked=-1;journeyToolState.finalFeedback='';
  }else{
    var code=journeyLevelCode(),level=journeyGetLevel(code);
    level.finalQuizAttempts++;
    level.finalQuizBest=Math.max(level.finalQuizBest,journeyToolState.finalScore);
    if(journeyToolState.finalScore>=4){
      if(level.checkpointKeys.indexOf('final:passed')<0)level.checkpointKeys.push('final:passed');
      journeyToolState.finalFeedback='Challenge passed!';
    }else journeyToolState.finalFeedback='Challenge completed. Keep practising and try again.';
    journeyToolState.finalFinished=true;
    journeyRecalculate(level);journeyMaybeAwardCertificate(code);journeySaveLocal();journeyScheduleSync(code);
  }
  journeyRenderCurrent();
}
function journeyMarkReviewDone(id){
 if(!id)return;
 journeyLevels.forEach(function(item){var l=journeyGetLevel(item.code),w=l.wrongAnswers.find(function(x){return x.id===id;});if(w){var n=Math.min(30,(Number(w.reviewRepetitions)||0)+1),a=[1,3,7,14,30],days=a[Math.min(n-1,a.length-1)],now=new Date();w.reviewed=true;w.reviewedAt=now.toISOString();w.reviewRepetitions=n;w.reviewIntervalDays=days;w.nextReviewAt=new Date(now.getTime()+days*86400000).toISOString();journeySaveLocal();journeyScheduleSync(item.code);}});
 journeyRenderCurrent();
}
function journeyRenderReview(){
 var host=root.querySelector('#mfkjReviewRoot');if(!host)return;var items=[],reviewed=0;
 journeyLevels.forEach(function(def){var l=journeyGetLevel(def.code);l.wrongAnswers.forEach(function(w){var x=Object.assign({level:def.code,levelTitle:def.title},w);if(journeyReviewIsDue(w)){x.isScheduledDue=!!w.reviewed;items.push(x);}else reviewed++;});});
 items.sort(function(a,b){return (Date.parse(a.nextReviewAt||'')||0)-(Date.parse(b.nextReviewAt||'')||0)||String(a.createdAt||'').localeCompare(String(b.createdAt||''));});
 var cards=items.map(function(x){var days=journeyReviewNextInterval(x);return '<article class="mfkj-review-card"><div class="mfkj-review-top"><span class="mfkj-level-code">'+x.level+' · '+esc(x.kind||'practice')+'</span><span class="mfkj-review-attempts">Tried '+(Number(x.attempts)||1)+' time(s)</span></div>'+(x.isScheduledDue?'<p class="mfkj-review-ar" lang="ar" dir="rtl">⏰ موعد المراجعة وصل.</p>':'')+'<h3>'+esc(x.question||'Practice question')+'</h3>'+(x.arabic?'<p class="mfkj-review-ar" lang="ar" dir="rtl">'+esc(x.arabic)+'</p>':'')+'<div class="mfkj-review-answer"><span>YOUR ANSWER · إجابتك</span><p>'+esc(x.selected||'—')+'</p></div><div class="mfkj-review-correct"><span>CORRECT ANSWER · الإجابة الصحيحة</span><p>'+esc(x.correct||'—')+'</p></div><div class="mfkj-review-actions"><button type="button" class="mfkr-btn mfkj-secondary" data-mfj-review-speak="'+esc(x.correct||'')+'">🔊 Listen · اسمع</button><button type="button" class="mfkr-btn mfkj-primary" data-mfj-review-done="'+esc(x.id)+'">راجعتها ✓ · تذكير بعد '+days+' يوم</button></div></article>';}).join('');
 host.innerHTML='<div class="mfkj-review-header"><span class="mfkj-kicker">PERSONAL PRACTICE · مراجعة شخصية</span><h2>My Review <i class="mfkj-pulse-dot"></i></h2><p lang="ar" dir="rtl">الأسئلة الخاطئة محفوظة هنا. بعد المراجعة ستعود في موعد مناسب: يوم، ثم 3 و7 و14 و30 يومًا.</p><div class="mfkj-review-summary"><span>Due now · مستحقة الآن: <b>'+items.length+'</b></span><span>Scheduled/reviewed · مؤجلة للموعد التالي: <b>'+reviewed+'</b></span></div></div>'+(cards||'<div class="mfkj-empty"><span>🌱</span><h3>No pending mistakes</h3><p lang="ar" dir="rtl">لا توجد أخطاء مستحقة للمراجعة حاليًا.</p><a class="mfkr-btn mfkj-primary" href="'+url('hub')+'">العودة للرحلة التعليمية</a></div>')+backButtons(url('hub'),'← Back to journey');
}
function renderReview(){
  document.title='My Review | Mr. Fluent Kids';
  root.innerHTML=shell('YOUR PERSONAL REVIEW','My Review.','راجع أخطاءك وتعلّم منها.','Wrong answers from your practice are collected here so you can listen, review and try again.','<div id="mfkjReviewRoot"></div>');
  journeyRenderReview();
}
function journeyPrintCertificate(){
  try{
    document.body.classList.add('mfkj-print-certificate');
    var clean=function(){document.body.classList.remove('mfkj-print-certificate');window.removeEventListener('afterprint',clean);};
    window.addEventListener('afterprint',clean);
    window.print();
    setTimeout(clean,1500);
  }catch(_){document.body.classList.remove('mfkj-print-certificate');}
}
function journeyCourseCatalogHtml(){
  var young=journeyLevels.filter(function(item){return item.group==='younger';});
  var growing=journeyLevels.filter(function(item){return item.group==='older';});
  function card(item,index,groupLabel){
    return '<a class="mfkj-course-level-card" href="'+url(item.route)+'"><div class="mfkj-course-card-top"><span class="mfkj-course-icon">'+item.icon+'</span><span class="mfkj-course-index">'+String(index+1).padStart(2,'0')+'</span></div><div class="mfkj-course-code">'+esc(item.code)+'</div><h3>'+esc(item.title)+'</h3><p class="mfkj-course-ar" lang="ar">'+esc(item.arabic)+'</p><p class="mfkj-course-desc">'+esc(item.desc)+'</p><div class="mfkj-course-card-foot"><span>'+esc(groupLabel)+'</span><b>Open level ↗</b></div></a>';
  }
  return '<style id="mfkj-course-catalog-css">#mfKidsStandaloneRoot .mfkj-course-catalog{margin:24px 0 30px}#mfKidsStandaloneRoot .mfkj-course-group{padding:20px;border:1px solid rgba(169,95,130,.25);border-radius:22px;background:linear-gradient(145deg,rgba(50,25,39,.42),rgba(15,10,16,.54));box-shadow:0 18px 40px rgba(0,0,0,.12)}#mfKidsStandaloneRoot .mfkj-course-group-head{display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:16px}#mfKidsStandaloneRoot .mfkj-course-group-kicker{font-size:8px;font-weight:900;letter-spacing:.18em;color:#ca9eb9}#mfKidsStandaloneRoot .mfkj-course-group-head h2{font-size:clamp(18px,2.4vw,25px);margin:5px 0;color:#f8e7f1}#mfKidsStandaloneRoot .mfkj-course-group-head p{margin:0;color:#bca9b5;font-size:11px;line-height:1.7}#mfKidsStandaloneRoot .mfkj-course-group-badge{flex:0 0 auto;border:1px solid rgba(194,134,167,.25);border-radius:99px;padding:8px 10px;color:#e9cadb;background:rgba(104,49,79,.15);font-size:9px;font-weight:850}#mfKidsStandaloneRoot .mfkj-course-card-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}#mfKidsStandaloneRoot .mfkj-course-level-card{min-width:0;display:flex;flex-direction:column;padding:16px;border:1px solid rgba(196,126,159,.2);border-radius:17px;background:linear-gradient(145deg,rgba(59,31,47,.72),rgba(17,12,19,.92));text-decoration:none;color:#f8eaf1;box-shadow:inset 0 1px 0 rgba(255,255,255,.03);transition:transform .18s ease,border-color .18s ease,box-shadow .18s ease}#mfKidsStandaloneRoot .mfkj-course-level-card:hover{transform:translateY(-3px);border-color:rgba(137,223,199,.38);box-shadow:0 15px 34px rgba(0,0,0,.21),0 0 24px rgba(93,205,174,.06)}#mfKidsStandaloneRoot .mfkj-course-card-top{display:flex;align-items:center;justify-content:space-between;gap:8px}#mfKidsStandaloneRoot .mfkj-course-icon{display:grid;place-items:center;width:43px;height:43px;border:1px solid rgba(188,124,159,.21);border-radius:13px;background:rgba(116,54,88,.2);font-size:22px}#mfKidsStandaloneRoot .mfkj-course-index{font-size:9px;font-weight:900;letter-spacing:.14em;color:#a58c9f}#mfKidsStandaloneRoot .mfkj-course-code{margin-top:15px;color:#9debd2;font-weight:950;font-size:10px;letter-spacing:.18em}#mfKidsStandaloneRoot .mfkj-course-level-card h3{margin:5px 0 3px;font-size:clamp(13px,1.3vw,16px);color:#ffeff7;line-height:1.35}#mfKidsStandaloneRoot .mfkj-course-ar{margin:0;color:#dfb9d0;font-size:10px;line-height:1.6}#mfKidsStandaloneRoot .mfkj-course-desc{margin:10px 0 18px;min-height:36px;color:#b8a7b3;font-size:10px;line-height:1.7}#mfKidsStandaloneRoot .mfkj-course-card-foot{display:flex;justify-content:space-between;align-items:center;gap:8px;margin-top:auto;padding-top:10px;border-top:1px solid rgba(194,147,171,.1);font-size:8px;color:#9e8a99}#mfKidsStandaloneRoot .mfkj-course-card-foot b{color:#b9f0df;font-size:9px}#mfKidsStandaloneRoot .mfkj-course-separator{display:flex;align-items:center;gap:12px;margin:20px 3px;color:#ae94b0;font-size:8px;font-weight:900;letter-spacing:.16em}#mfKidsStandaloneRoot .mfkj-course-separator:before,#mfKidsStandaloneRoot .mfkj-course-separator:after{content:"";height:1px;flex:1;background:linear-gradient(90deg,transparent,rgba(171,111,159,.4),transparent)}@media(max-width:760px){#mfKidsStandaloneRoot .mfkj-course-group{padding:14px}#mfKidsStandaloneRoot .mfkj-course-card-grid{grid-template-columns:repeat(2,minmax(0,1fr));gap:9px}#mfKidsStandaloneRoot .mfkj-course-level-card{padding:12px}}@media(max-width:480px){#mfKidsStandaloneRoot .mfkj-course-group-head{flex-direction:column}#mfKidsStandaloneRoot .mfkj-course-group-badge{align-self:flex-start}#mfKidsStandaloneRoot .mfkj-course-card-grid{grid-template-columns:1fr}#mfKidsStandaloneRoot .mfkj-course-desc{min-height:0}}</style><div class="mfkj-course-catalog"><section class="mfkj-course-group"><div class="mfkj-course-group-head"><div><span class="mfkj-course-group-kicker">STAGE 01 · FIRST STEPS</span><h2>Little Learners <i class="mfkj-pulse-dot"></i></h2><p lang="ar">المستويات المناسبة للأطفال الأصغر سنًا — من الحروف للكلمات ثم تكوين الجمل.</p></div><span class="mfkj-course-group-badge">3 levels · Easier → harder</span></div><div class="mfkj-course-card-grid">'+young.map(function(item,index){return card(item,index,'Little Learners');}).join('')+'</div></section><div class="mfkj-course-separator"><span>THE NEXT STAGE · المرحلة التالية</span></div><section class="mfkj-course-group"><div class="mfkj-course-group-head"><div><span class="mfkj-course-group-kicker">STAGE 02 · GROWING SKILLS</span><h2>Growing Learners <i class="mfkj-pulse-dot"></i></h2><p lang="ar">المستويات المناسبة للأطفال الأكبر سنًا — من توسيع المفردات للقراءة والمهارات المتقدمة.</p></div><span class="mfkj-course-group-badge">3 levels · Build confidence</span></div><div class="mfkj-course-card-grid">'+growing.map(function(item,index){return card(item,index,'Growing Learners');}).join('')+'</div></section></div>';
}

function mfkjToolsCss(){return '<style id="mfkj-learning-tools-css">'+
'#mfKidsStandaloneRoot .mfkj-t-wrap{margin:18px 0 24px;color:#f8eaf1}'+
'#mfKidsStandaloneRoot .mfkj-t-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;margin:14px 0}'+
'#mfKidsStandaloneRoot .mfkj-t-card{min-width:0;padding:15px;border:1px solid rgba(196,126,159,.2);border-radius:17px;background:linear-gradient(145deg,rgba(59,31,47,.72),rgba(17,12,19,.92))}'+
'#mfKidsStandaloneRoot .mfkj-t-card h2,#mfKidsStandaloneRoot .mfkj-t-card h3{margin:5px 0 8px;color:#ffeff7;font-size:15px;line-height:1.45}'+
'#mfKidsStandaloneRoot .mfkj-t-card p,#mfKidsStandaloneRoot .mfkj-t-card li{color:#c6b3c1;font-size:11px;line-height:1.8}'+
'#mfKidsStandaloneRoot .mfkj-t-card ul{padding-inline-start:18px}'+
'#mfKidsStandaloneRoot .mfkj-t-kicker{font-size:9px;font-weight:900;letter-spacing:.1em;color:#9debd2}'+
'#mfKidsStandaloneRoot .mfkj-t-pill{display:inline-flex;margin:3px;padding:5px 8px;border:1px solid rgba(145,240,219,.16);border-radius:99px;background:rgba(145,240,219,.055);color:#d5f9ef;font-size:9px;font-weight:800}'+
'#mfKidsStandaloneRoot .mfkj-t-link{display:inline-flex;align-items:center;justify-content:center;margin-top:8px;padding:9px 11px;border:1px solid rgba(145,240,219,.22);border-radius:11px;background:rgba(145,240,219,.07);color:#c7f7e9;text-decoration:none;font-size:10px;font-weight:900}'+
'#mfKidsStandaloneRoot .mfkj-t-nav{display:flex;flex-wrap:wrap;gap:7px;margin:16px 0}'+
'#mfKidsStandaloneRoot .mfkj-t-nav a{padding:9px 11px;border:1px solid rgba(196,126,159,.18);border-radius:11px;background:rgba(255,255,255,.025);color:#e9d5e2;text-decoration:none;font-size:10px;font-weight:800}'+
'#mfKidsStandaloneRoot .mfkj-t-nav a.is-active{border-color:rgba(145,240,219,.35);background:rgba(145,240,219,.09);color:#c7f7e9}'+
'#mfKidsStandaloneRoot .mfkj-t-stats{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:8px;margin:12px 0}'+
'#mfKidsStandaloneRoot .mfkj-t-stat{padding:12px 8px;border:1px solid rgba(196,126,159,.16);border-radius:13px;background:rgba(255,255,255,.025);text-align:center}'+
'#mfKidsStandaloneRoot .mfkj-t-stat b{display:block;color:#9debd2;font-size:20px}#mfKidsStandaloneRoot .mfkj-t-stat span{display:block;color:#bca9b5;font-size:9px;margin-top:4px}'+
'#mfKidsStandaloneRoot .mfkj-t-meter{height:6px;overflow:hidden;border-radius:99px;background:rgba(255,255,255,.07);margin:9px 0}#mfKidsStandaloneRoot .mfkj-t-meter span{display:block;height:100%;background:linear-gradient(90deg,#9debd2,#bd91ef)}'+
'#mfKidsStandaloneRoot .mfkj-t-note{padding:12px 14px;border:1px solid rgba(196,126,159,.16);border-radius:13px;background:rgba(255,255,255,.025);color:#c6b3c1;font-size:11px;line-height:1.8}'+
'#mfKidsStandaloneRoot .mfkj-t-select,#mfKidsStandaloneRoot .mfkj-t-area{width:100%;box-sizing:border-box;padding:11px 12px;border:1px solid rgba(196,126,159,.22);border-radius:12px;background:rgba(10,7,13,.55);color:#fff7ff;font:inherit;font-size:12px}'+
'#mfKidsStandaloneRoot .mfkj-t-area{min-height:170px;margin-top:10px;resize:vertical;line-height:1.8}'+
'#mfKidsStandaloneRoot .mfkj-t-status{min-height:22px;color:#9debd2;font-size:10px;line-height:1.7;margin-top:8px}'+
'@media(max-width:620px){#mfKidsStandaloneRoot .mfkj-t-grid{grid-template-columns:minmax(0,1fr)}#mfKidsStandaloneRoot .mfkj-t-stats{grid-template-columns:repeat(2,minmax(0,1fr))}#mfKidsStandaloneRoot .mfkj-t-card{padding:13px}}'+
'</style>';}
function mfkjCurriculumData(){return [
{code:'A1',route:'a1',group:'Little Learners',title:'My First ABC',focus:'الحروف والأصوات الأولى',skills:['تمييز الحروف','أصوات الحروف','كلمات مصوّرة','الاستماع'],current:['26 بطاقة حروف كبيرة وصغيرة مع كلمات وصور ومعانٍ عربية وصوت.','تتبّع الحروف وSound Detective والاختيار البصري والاستماع.','Speaking Studio وFinal Challenge وMy Review والشهادة.'],next:'تمييز الأصوات المتقاربة داخل كلمات قصيرة؛ لن نكرر لعبة اختيار الصورة.'},
{code:'B1',route:'b1',group:'Little Learners',title:'My First Words',focus:'مفردات الحياة اليومية',skills:['مفردات مصوّرة','المعنى','الاستماع','تواصل بسيط'],current:['بنك كلمات يومية بالصور والمعاني وتحدّي الكلمات.','Trace & Write وLook & Choose وListen & Choose وWord Detective.','Speaking Studio وFinal Challenge وMy Review والشهادة.'],next:'مواقف سؤال وجواب يومية وتنويع الموضوعات بدل تكرار اختيار المعنى.'},
{code:'C1',route:'c1',group:'Little Learners',title:'My First Sentences',focus:'تكوين الجمل والقصص',skills:['ترتيب الكلمات','قراءة القصص','قواعد بسيطة','فهم المقروء'],current:['12 كلمة أساسية بأمثلة وترجمة عربية.','قصة Mia and the Flower وخمس قصص قصيرة إضافية.','8 مهام تكوين جمل و8 أسئلة قواعد و6 أسئلة فهم.'],next:'إعادة سرد قصة باستخدام first / next / finally دون تكرار أسئلة الفهم.'},
{code:'A2',route:'a2',group:'Growing Learners',title:'Word Explorers',focus:'المفردات في السياق',skills:['مفردات موضوعية','قراءة','جمل','قواعد وكتابة'],current:['Explore by Topic وReading Corner وSentence Builder.','Listen & Match وWord Challenge وGrammar in Everyday Life.','My School-Day Paragraph والأنشطة المشتركة الأربعة.'],next:'مواقف تواصل وظيفي مثل الوقت والاتجاهات والطلب بأدب بدل لعبة مفردات شبيهة.'},
{code:'B2',route:'b2',group:'Growing Learners',title:'Reading Builders',focus:'القراءة وربط الأفكار',skills:['فهم النص','ترتيب الأحداث','أدوات الربط','تلخيص'],current:['Read, Listen & Understand وWords that Build Meaning.','Story Sequence وConnector Lab وReading Challenge وReading Detective/summary.','الأنشطة المشتركة الأربعة.'],next:'السبب والنتيجة وهدف الكاتب والاستدلال بدليل من النص، مع إبقاء ترتيب القصة والتلخيص.'},
{code:'C2',route:'c2',group:'Growing Learners',title:'Confident English',focus:'الفهم والتعبير المتقدم',skills:['الاستنتاج','قراءة متقدمة','محادثة','فقرة مكتوبة'],current:['Read Beyond the Words وWords for Better Ideas.','Think Like a Reader وConnector & Grammar Lab وSpeaking Studio.','Build a Strong Paragraph والأنشطة المشتركة ومراجعة الأخطاء.'],next:'قائمة مراجعة لتحرير الكتابة: وضوح الفكرة والدليل والربط وعلامات الترقيم.'}
];}
function journeyCourseQuickLinksHtml(){return mfkjToolsCss()+'<div class="mfkj-t-wrap mfkj-t-grid"><article class="mfkj-t-card"><span class="mfkj-t-kicker">CURRICULUM</span><h3>خريطة المنهج · Curriculum Map</h3><p>المحتوى الموجود والفجوة التالية لكل مستوى.</p><a class="mfkj-t-link" href="'+url('map')+'">افتح الخريطة ↗</a></article><article class="mfkj-t-card"><span class="mfkj-t-kicker">FAMILY PROGRESS</span><h3>متابعة ولي الأمر</h3><p>ملخص التقدم والأنشطة والمراجعات المستحقة.</p><a class="mfkj-t-link" href="'+url('parents')+'">عرض التقدم ↗</a></article><article class="mfkj-t-card"><span class="mfkj-t-kicker">PRACTICE</span><h3>Learning Lab · مساحة التعلّم</h3><p>مهمات منزلية ومشروعات وكتابة مستقلة.</p><a class="mfkj-t-link" href="./?kids=lab&amp;kidsTab=overview">افتح مساحة التعلّم ↗</a></article></div>';}
function renderCourseMap(){document.title='Kids Curriculum Map | Mr. Fluent Kids';var cards=mfkjCurriculumData().map(function(x,i){return '<article class="mfkj-t-card"><span class="mfkj-t-kicker">'+esc(x.group)+' · '+String(i+1).padStart(2,'0')+'</span><h2>'+esc(x.code)+' · '+esc(x.title)+'</h2><p>'+esc(x.focus)+'</p><div>'+x.skills.map(function(k){return '<span class="mfkj-t-pill">'+esc(k)+'</span>';}).join('')+'</div><p class="mfkj-t-kicker">الموجود بالفعل</p><ul>'+x.current.map(function(k){return '<li>'+esc(k)+'</li>';}).join('')+'</ul><div class="mfkj-t-note"><b>النقطة التالية المقترحة:</b> '+esc(x.next)+'</div><a class="mfkj-t-link" href="'+url(x.route)+'">افتح المستوى ↗</a></article>';}).join('');root.innerHTML=shell('THE SIX-LEVEL ROADMAP','Curriculum Map.','خريطة منهج Mr. Fluent Kids','المحتوى الموجود أولًا، ثم النواقص فقط. الترتيب: A1 ثم B1 ثم C1 وبعدها A2 ثم B2 ثم C2.',mfkjToolsCss()+'<div class="mfkj-t-wrap"><div class="mfkj-t-note">«الموجود بالفعل» مأخوذ من صفحات المستويات. «النقطة التالية» فجوة تطوير وليست نشاطًا أُضيف بالفعل.</div><div class="mfkj-t-grid">'+cards+'</div><div class="mfkj-t-nav"><a href="./?kids=lab&amp;kidsTab=overview">Learning Lab</a><a href="'+url('parents')+'">متابعة ولي الأمر</a><a href="'+url('hub')+'">العودة للمستويات</a></div></div>');}
function journeyReviewIsDue(item){if(!item)return false;if(!item.reviewed)return true;var due=Date.parse(item.nextReviewAt||item.next_review_at||'');return !isNaN(due)&&due<=Date.now();}
function journeyReviewPendingCount(level){return level&&Array.isArray(level.wrongAnswers)?level.wrongAnswers.filter(journeyReviewIsDue).length:0;}
function journeyReviewNextInterval(item){var a=[1,3,7,14,30],r=Math.max(0,Number(item&&item.reviewRepetitions)||0);return a[Math.min(r,a.length-1)];}
function renderParentOverview(){document.title='Family Progress | Mr. Fluent Kids';root.innerHTML=shell('FAMILY PROGRESS','Parent Overview.','متابعة ولي الأمر','تقرير آمن عن تقدم الطلاب المرتبطين بحساب ولي الأمر.',mfkjToolsCss()+'<div class="mfkj-t-wrap"><div class="mfkj-t-nav"><button type="button" class="mfkr-btn mfkj-secondary" data-mfj-parent-refresh>تحديث التقرير ↻</button><a href="./">العودة إلى DOMA</a></div><div id="mfkjParentSummary" class="mfkj-t-wrap"><div class="mfkj-t-note">جاري تحميل التقرير…</div></div></div>');journeyRenderParentOverview();}
function journeyRenderParentOverview(){
 var host=root.querySelector('#mfkjParentSummary');if(!host)return;
 var report=window.__mfKidsParentReport||null;
 if(!report){host.innerHTML='<div class="mfkj-t-note">جاري تحميل تقرير ولي الأمر…</div>';return;}
 var children=Array.isArray(report.children)?report.children:[];
 if(!children.length){
  host.innerHTML='<div class="mfkj-t-note"><b>لا يوجد طالب مرتبط بهذا الحساب حتى الآن.</b><p lang="ar" dir="rtl">اطلب من إدارة DOMA ربط حساب ولي الأمر بحساب الطالب من لوحة الإدارة. لن تظهر بيانات أي طالب غير مرتبط بحسابك.</p><p lang="ar" dir="rtl">بعد إنشاء الربط، اضغط «تحديث التقرير» لعرض التقدم.</p></div>';
  return;
 }
 var totals=children.reduce(function(acc,child){
  (Array.isArray(child.levels)?child.levels:[]).forEach(function(level){
   acc.stars+=Number(level.stars)||0;
   acc.due+=Number(level.review_due_count)||0;
   if(level.certificate_earned)acc.certificates++;
   if(Number(level.progress_percent)>0)acc.started++;
   acc.progress+=Number(level.progress_percent)||0;
   acc.levels++;
  });
  if(child.subscription_active)acc.activeSubscriptions++;
  return acc;
 },{stars:0,due:0,certificates:0,started:0,progress:0,levels:0,activeSubscriptions:0});
 var cards=children.map(function(child){
  var levels=Array.isArray(child.levels)?child.levels:[];
  var levelCards=levels.map(function(level){
   var pct=Math.max(0,Math.min(100,Number(level.progress_percent)||0));
   var due=Number(level.review_due_count)||0;
   var words=Number(level.words_learned)||0;
   var speaking=Number(level.speaking_missions_completed)||0;
   var best=Number(level.final_quiz_best)||0;
   var status=level.certificate_earned?'أكمل متطلبات الشهادة':pct>=80?'تقدم قوي':pct>=35?'في مرحلة التعلم':pct>0?'بدأ التعلم':'لم يبدأ بعد';
   var advice=due?'ابدأ بمراجعة الأخطاء المستحقة.':speaking<3?'شجّعه على إكمال مواقف المحادثة.':best<4?'راجعوا الدرس ثم أعيدوا التحدي النهائي.':words<5?'وسّعوا حصيلة الكلمات الجديدة.':'اطلبوا منه شرح ما تعلّمه بجمله الخاصة.';
   return '<article class="mfkj-t-card"><div class="mfkj-t-kicker">'+esc(level.level_code||'')+' · '+esc(status)+'</div><h3>'+pct+'% · '+(Number(level.stars)||0)+' ⭐</h3><div class="mfkj-t-meter" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="'+pct+'"><span style="width:'+pct+'%"></span></div><p>كلمات '+words+' · أنشطة '+(Number(level.activity_count)||0)+' · محادثة '+speaking+'/3 · أفضل تحدٍّ '+best+'/5</p><p>'+(due?'<b>مراجعات مستحقة: '+due+'</b> · ':'')+esc(advice)+'</p></article>';
  }).join('');
  var last=child.last_activity_at?journeyDateLabel(child.last_activity_at):'لا يوجد نشاط مسجل';
  return '<section class="mfkj-t-card" style="grid-column:1/-1"><div class="mfkj-t-kicker">STUDENT REPORT · تقرير الطالب</div><div style="display:flex;gap:12px;align-items:center;justify-content:space-between;flex-wrap:wrap"><div><h2>'+esc(child.student_name||'الطالب')+'</h2><p>'+esc(child.grade_name||'')+' · آخر نشاط: '+esc(last)+'</p></div><span class="mfkj-t-pill">'+(child.subscription_active?'اشتراك Kids نشط':'اشتراك Kids غير نشط')+'</span></div><div class="mfkj-t-grid">'+levelCards+'</div></section>';
 }).join('');
 var average=totals.levels?Math.round(totals.progress/totals.levels):0;
 var advice=totals.due?'ابدأوا بالمراجعات المستحقة قبل فتح دروس جديدة.':'حافظوا على جلسات قصيرة ومنتظمة، واطلبوا من الطالب شرح ما تعلّمه بصوته.';
 host.innerHTML='<div class="mfkj-t-stats"><div class="mfkj-t-stat"><b>'+children.length+'</b><span>طلاب مرتبطون</span></div><div class="mfkj-t-stat"><b>'+totals.stars+'</b><span>نجوم مكتسبة</span></div><div class="mfkj-t-stat"><b>'+totals.due+'</b><span>مراجعات مستحقة</span></div><div class="mfkj-t-stat"><b>'+totals.certificates+'</b><span>شهادات مكتملة</span></div></div><div class="mfkj-t-note"><b>متوسط التقدم المسجل:</b> '+average+'% · '+esc(advice)+'<div style="margin-top:6px;font-size:12px">الاشتراكات النشطة: '+totals.activeSubscriptions+' / '+children.length+' · تم إنشاء التقرير: '+esc(journeyDateLabel(report.generated_at))+'</div></div><div class="mfkj-t-grid">'+cards+'</div><div class="mfkj-t-note">يعرض هذا التقرير بيانات الطلاب المرتبطين بحساب ولي الأمر فقط. لا تُعرض بيانات حسابات أخرى.</div>';
}
function mfkjLabKey(){return 'mrfluent-kids-writing-lab-v1:'+(journeyUserId||(typeof sessionUser!=='undefined'&&sessionUser&&sessionUser.id)||'guest');}
function mfkjLabRead(){try{return JSON.parse(localStorage.getItem(mfkjLabKey())||'{}')||{};}catch(_){return {};}}
function renderLearningLab(){
var valid=['overview','missions','maker','review','writing','portfolio'],tab=String(query.get('kidsTab')||'overview').toLowerCase();if(valid.indexOf(tab)<0)tab='overview';document.title='Learning Lab | Mr. Fluent Kids';
var tabs=[['overview','البداية'],['missions','مهمات البيت'],['maker','مشروعات عملية'],['review','مراجعة ذكية'],['writing','تدريب الكتابة'],['portfolio','ملف الإنجاز']],nav=tabs.map(function(t){return '<a class="'+(tab===t[0]?'is-active':'')+'" href="'+(t[0]==='review'?url('review'):'./?kids=lab&amp;kidsTab='+t[0])+'">'+t[1]+'</a>';}).join('');
var missions=[{c:'A1',id:'a1home',t:'Letter Hunt · رحلة الحروف',d:'اختار 3 أشياء في البيت، انطق أول صوت في كل كلمة وحدد الحرف.'},{c:'B1',id:'b1home',t:'Everyday Words · كلمات من البيت',d:'اختار 5 أشياء وقل اسمها بالإنجليزية ثم جملة قصيرة.'},{c:'C1',id:'c1home',t:'Three-Sentence Story · حكاية قصيرة',d:'اختار صورة ووصفها بثلاث جمل: من؟ أين؟ ماذا يحدث؟'},{c:'A2',id:'a2home',t:'Polite English · كلام مهذّب',d:'تدرّب على طلب شيء بأدب أو السؤال عن الوقت مع تبادل الأدوار.'},{c:'B2',id:'b2home',t:'Cause & Effect · السبب والنتيجة',d:'اذكر ما حدث في قصة ولماذا، واستشهد بتفصيل من النص.'},{c:'C2',id:'c2home',t:'Opinion & Evidence · رأي ودليل',d:'عبّر عن رأيك في قصة مع سببين ودليل من النص.'}];
var projects=[{c:'A1',id:'a1book',t:'My ABC Mini-Book · كتاب حروفي',d:'4 صفحات تضم حرفًا كبيرًا وصغيرًا ورسمة وكلمة ومعنى عربي.'},{c:'B1',id:'b1cards',t:'Five Word Cards · خمس بطاقات',d:'5 بطاقات: صورة من الأمام، والكلمة والمعنى وجملة من الخلف.'},{c:'C1',id:'c1strip',t:'Picture Story Strip · شريط قصة',d:'رتّب 3 صور واستخدم first / next / finally.'},{c:'A2',id:'a2dialog',t:'Everyday Dialogue · حوار يومي',d:'اكتب حوارًا قصيرًا للسؤال عن الوقت أو الاتجاهات.'},{c:'B2',id:'b2evidence',t:'Reading Evidence Board · لوحة الأدلة',d:'اكتب الفكرة الرئيسية ودليلين وعلاقة سبب ونتيجة.'},{c:'C2',id:'c2revision',t:'Mini Review & Revision · مراجعة وتحرير',d:'راجع نصًا من حيث وضوح الفكرة والدليل والربط والترقيم.'}];
var prompts={A1:{t:'My favourite thing',ar:'ارسم شيئًا تحبه واكتب اسمه والحرف الأول.',ex:'This is my… It is…'},B1:{t:'A friendly message',ar:'اكتب رسالة قصيرة لصديق عن نشاط تحبه.',ex:'Hi! I like… Would you like to…?'},C1:{t:'A picture in three lines',ar:'اكتب ثلاث جمل تصف صورة واحدة.',ex:'I can see… The… is… I feel…'},A2:{t:'Ask for information',ar:'اكتب رسالة قصيرة تسأل فيها عن موعد أو اتجاه.',ex:'Excuse me, what time…? How can I get to…?'},B2:{t:'Explain an event',ar:'اكتب عن حدث واذكر السبب ودليلًا من النص.',ex:'This happened because… One detail is…'},C2:{t:'Recommendation with evidence',ar:'اكتب توصية لقصة ثم راجع وضوح الرأي والدليل والربط.',ex:'I recommend… because… One detail that supports my view…'}};
var d=mfkjLabRead(),content='';
if(tab==='overview')content='<div class="mfkj-t-note">مهمات تطبيقية خارج شاشة الأسئلة، ومشروعات وكتابة مستقلة. المراجعة تستخدم بنك الأخطاء الحالي بلا تكرار.</div><div class="mfkj-t-grid"><article class="mfkj-t-card"><h3>Curriculum Map</h3><p>المحتوى الحالي والفجوات التالية.</p><a class="mfkj-t-link" href="'+url('map')+'">افتح الخريطة</a></article><article class="mfkj-t-card"><h3>Parent Overview</h3><p>ملخص التقدم المسجّل.</p><a class="mfkj-t-link" href="'+url('parents')+'">عرض التقدم</a></article><article class="mfkj-t-card"><h3>Home Missions</h3><p>مهمات قصيرة من الحياة اليومية.</p><a class="mfkj-t-link" href="./?kids=lab&amp;kidsTab=missions">اختار مهمة</a></article><article class="mfkj-t-card"><h3>Maker Projects</h3><p>مشروعات لها ناتج يستطيع الطفل شرحه.</p><a class="mfkj-t-link" href="./?kids=lab&amp;kidsTab=maker">ابدأ مشروعًا</a></article><article class="mfkj-t-card"><h3>Writing Studio</h3><p>مهمات كتابة مستقلة حسب المستوى.</p><a class="mfkj-t-link" href="./?kids=lab&amp;kidsTab=writing">ابدأ الكتابة</a></article><article class="mfkj-t-card"><h3>Smart Review</h3><p>نفس بنك الأخطاء الموجود بالفعل.</p><a class="mfkj-t-link" href="'+url('review')+'">راجع الآن</a></article></div>';
else if(tab==='missions'||tab==='maker'){var arr=tab==='missions'?missions:projects;content='<div class="mfkj-t-note">أنشطة تطبيقية خارج شاشة الأسئلة؛ سجّل الإنجاز بعد تنفيذ المهمة. التسجيل لا يقيّم جودة العمل تلقائيًا.</div><div class="mfkj-t-grid">'+arr.map(function(x){var kind=tab==='missions'?'mission':'project',key='activity:lab:'+x.c+':'+kind+':'+x.id,done=journeyGetLevel(x.c).checkpointKeys.indexOf(key)>=0;return '<article class="mfkj-t-card"><span class="mfkj-t-kicker">'+x.c+' · '+kind.toUpperCase()+'</span><h3>'+esc(x.t)+'</h3><p>'+esc(x.d)+'</p><button class="mfkr-btn mfkj-primary" type="button" data-mfkj-lab-done="'+x.c+'|'+kind+'|'+x.id+'" '+(done?'disabled':'')+'>'+(done?'✓ مسجّلة':'تم التنفيذ · سجّل الإنجاز')+'</button></article>';}).join('')+'</div>';}
else if(tab==='review')content='<div class="mfkj-t-card"><span class="mfkj-t-kicker">SPACED REVIEW</span><h3>نستخدم My Review الحالي</h3><p>بعد تعليم السؤال كمراجَع يعود في موعد لاحق: يوم، ثم 3 و7 و14 و30 يومًا. الأسئلة المستحقة تظهر في صفحة My Review نفسها.</p><a class="mfkj-t-link" href="'+url('review')+'">افتح بنك المراجعة</a></div>';
else if(tab==='writing'){var code=String(d.selectedCode||'A1').toUpperCase();if(!prompts[code])code='A1';var draft=d[code]||{};content='<div class="mfkj-t-card"><span class="mfkj-t-kicker">WRITING STUDIO</span><h3>اكتب على قدّ مستواك</h3><label for="mfkjLabLevel" class="mfkj-t-kicker">المستوى</label><select id="mfkjLabLevel" class="mfkj-t-select">'+journeyLevels.map(function(x){return '<option value="'+x.code+'" '+(x.code===code?'selected':'')+'>'+x.code+' · '+esc(x.title)+'</option>';}).join('')+'</select><h3 id="mfkjLabPromptTitle">'+esc(prompts[code].t)+'</h3><p id="mfkjLabPrompt" lang="ar" dir="rtl">'+esc(prompts[code].ar)+'</p><p id="mfkjLabExample" lang="en">'+esc(prompts[code].ex)+'</p><textarea id="mfkjLabDraft" class="mfkj-t-area" maxlength="6000" placeholder="اكتب هنا…">'+esc(draft.text||'')+'</textarea><button type="button" class="mfkr-btn mfkj-primary" data-mfkj-lab-save>حفظ المسودة وتسجيل النشاط</button><p id="mfkjLabStatus" class="mfkj-t-status" aria-live="polite">'+(draft.saved?'✓ محفوظة على هذا الجهاز.':'تُحفظ المسودة محليًا على هذا الجهاز أثناء الكتابة.')+'</p><p class="mfkj-t-note">نص المسودة على الجهاز الحالي؛ إنجاز النشاط يتزامن مع الحساب عند تسجيل الدخول والاتصال.</p></div>';}
else{var written=Object.keys(d).filter(function(k){return prompts[k]&&d[k]&&String(d[k].text||'').trim();}),badges=journeyGlobalBadges();content='<div class="mfkj-t-stats"><div class="mfkj-t-stat"><b>'+journeyLevels.reduce(function(a,x){return a+journeyGetLevel(x.code).stars;},0)+'</b><span>نجوم</span></div><div class="mfkj-t-stat"><b>'+journeyLevels.reduce(function(a,x){return a+journeyGetLevel(x.code).checkpointKeys.filter(function(k){return /^activity:lab:/.test(k);}).length;},0)+'</b><span>مهمات ومشروعات</span></div><div class="mfkj-t-stat"><b>'+badges.filter(function(x){return x.earned;}).length+'</b><span>شارات</span></div><div class="mfkj-t-stat"><b>'+written.length+'</b><span>مسودات محلية</span></div></div><div class="mfkj-t-grid">'+journeyLevels.map(function(x){var l=journeyGetLevel(x.code),a=l.checkpointKeys.filter(function(k){return /^activity:lab:/.test(k);}).length;return '<article class="mfkj-t-card"><h3>'+esc(x.code)+' · '+esc(x.title)+'</h3><p>نجوم '+l.stars+' · مهام ومشروعات '+a+' · كلمات '+l.wordsSeen.length+'</p><a class="mfkj-t-link" href="'+url(x.route)+'">افتح المستوى</a></article>';}).join('')+'</div><article class="mfkj-t-card"><h3>مسودات الكتابة على هذا الجهاز</h3>'+(written.length?written.map(function(k){return '<p><strong>'+k+' · '+esc(prompts[k].t)+'</strong><br>'+esc(String(d[k].text||'').slice(0,140))+'</p>';}).join(''):'<p>لا توجد مسودات محفوظة حتى الآن.</p>')+'</article>';}
root.innerHTML=shell('LEARN · APPLY · CREATE','Learning Lab.','مساحة التعلّم','مهمات تطبيقية ومشروعات وكتابة مستقلة حسب المستوى.',mfkjToolsCss()+'<div class="mfkj-t-wrap"><div class="mfkj-t-nav">'+nav+'</div><div id="mfkjLabContent">'+content+'</div><div class="mfkj-t-nav"><a href="'+url('map')+'">خريطة المنهج</a><a href="'+url('parents')+'">متابعة ولي الأمر</a><a href="'+url('hub')+'">العودة للمستويات</a></div></div>');
var host=root.querySelector('#mfkjLabContent');if(!host)return;
host.addEventListener('click',function(e){var b=e.target.closest('[data-mfkj-lab-done]');if(b){var p=b.getAttribute('data-mfkj-lab-done').split('|');if(p.length===3)journeyRecord('activity:lab:'+p[0]+':'+p[1]+':'+p[2],null,p[0]);return;}if(e.target.closest('[data-mfkj-lab-save]')){var sel=host.querySelector('#mfkjLabLevel'),area=host.querySelector('#mfkjLabDraft'),c=String(sel&&sel.value||'A1'),v=String(area&&area.value||'').trim(),status=host.querySelector('#mfkjLabStatus');if(v.length<3){if(status)status.textContent='اكتب بضعة كلمات قبل الحفظ.';return;}var saved=mfkjLabRead();saved[c]={text:v.slice(0,6000),prompt:prompts[c].ar,updatedAt:new Date().toISOString(),saved:true};saved.selectedCode=c;try{localStorage.setItem(mfkjLabKey(),JSON.stringify(saved));}catch(_){}journeyRecord('activity:lab:'+c+':writing',null,c);}});
host.addEventListener('input',function(e){if(!e.target||e.target.id!=='mfkjLabDraft')return;var sel=host.querySelector('#mfkjLabLevel'),c=String(sel&&sel.value||'A1'),saved=mfkjLabRead();saved[c]={text:e.target.value.slice(0,6000),prompt:prompts[c].ar,updatedAt:new Date().toISOString(),saved:false};saved.selectedCode=c;try{localStorage.setItem(mfkjLabKey(),JSON.stringify(saved));}catch(_){}});
host.addEventListener('change',function(e){if(!e.target||e.target.id!=='mfkjLabLevel')return;var c=String(e.target.value||'A1'),saved=mfkjLabRead(),v=saved[c]||{},p=prompts[c],area=host.querySelector('#mfkjLabDraft');if(area)area.value=v.text||'';var t=host.querySelector('#mfkjLabPromptTitle'),ar=host.querySelector('#mfkjLabPrompt'),ex=host.querySelector('#mfkjLabExample'),st=host.querySelector('#mfkjLabStatus');if(t)t.textContent=p.t;if(ar)ar.textContent=p.ar;if(ex)ex.textContent=p.ex;if(st)st.textContent=v.saved?'✓ محفوظة على هذا الجهاز.':'تُحفظ المسودة محليًا أثناء الكتابة.';saved.selectedCode=c;try{localStorage.setItem(mfkjLabKey(),JSON.stringify(saved));}catch(_){}});
}

function renderHub(){
  document.title='Mr. Fluent Kids · All Six Levels';
  // Keep this landing page focused on the two age-based level groups only.
  root.innerHTML=header()+'<section class="mfkr-page"><div class="mfkr-wrap">'+journeyCourseCatalogHtml()+journeyCourseQuickLinksHtml()+'</div></section>'+footer();
}

function renderLevels(group){var young=group==='younger';var arr=young?[['A1','My First ABC','الحروف الكبيرة والصغيرة، صورة، كلمة، ترجمة عربية وزرّان للصوت.'],['B1','My First Words','كلمات يومية جديدة مع الاستماع والصور والألعاب.'],['C1','My First Sentences','كوّن جملًا بسيطة وابدأ فهم القصص المصورة.']]:[['A2','Word Explorers','وسّع حصيلة الكلمات واربطها بموضوعات قريبة من الطفل.'],['B2','Reading Builders','تدرّب على القراءة والفهم واستخدام الكلمات في سياقها.'],['C2','Confident English','قوّي الجمل والمحادثات القصيرة والفهم.']];var cards=arr.map(function(item){return levelCard(item[0],item[1],item[2],group);}).join('');document.title=(young?'Little Learners':'Growing Learners')+' | Mr. Fluent Kids';root.innerHTML=shell(young?'LITTLE LEARNERS':'GROWING LEARNERS',young?'Little Learners':'Growing Learners',young?'مسار الأطفال الأصغر سنًا':'مسار الأطفال الأكبر شوية','Select a level to start your next learning adventure.','<div class="mfkr-level-grid">'+cards+'</div>'+backButtons(url('hub'),'← Back to paths')+(young?'<div class="mfkr-note">المستويات A1 وB1 وC1 متاحة الآن. افتح C1 لتكوين الجمل وقراءة قصة قصيرة والتدرّب على الفهم والنطق.</div>':'<div class="mfkr-note">المستويات A2 وB2 وC2 متاحة الآن. استكشف الكلمات في A2، وطوّر القراءة في B2، ثم أتقن المهارات المتقدمة الشاملة في C2.</div>'));}

function renderC1(){
  document.title='C1 — My First Sentences | Mr. Fluent Kids';
  var vocab=[
    {word:'like',meaning:'يحب',picture:'💗',tag:'VERB',example:'I like apples.',sentence:'أنا أحب التفاح.'},
    {word:'can',meaning:'يستطيع',picture:'💪',tag:'VERB',example:'I can jump.',sentence:'أستطيع القفز.'},
    {word:'see',meaning:'يرى',picture:'👀',tag:'VERB',example:'I can see a bird.',sentence:'أستطيع أن أرى طائرًا.'},
    {word:'happy',meaning:'سعيد',picture:'😊',tag:'FEELINGS',example:'My friend is happy.',sentence:'صديقي سعيد.'},
    {word:'small',meaning:'صغير',picture:'🐱',tag:'ADJECTIVE',example:'The cat is small.',sentence:'القطة صغيرة.'},
    {word:'red',meaning:'أحمر',picture:'🔴',tag:'COLOUR',example:'The ball is red.',sentence:'الكرة حمراء.'},
    {word:'friend',meaning:'صديق',picture:'🤝',tag:'PEOPLE',example:'You are my friend.',sentence:'أنت صديقي.'},
    {word:'garden',meaning:'حديقة',picture:'🌷',tag:'PLACES',example:'This is my garden.',sentence:'هذه حديقتي.'},
    {word:'flower',meaning:'زهرة',picture:'🌼',tag:'NATURE',example:'I see a red flower.',sentence:'أرى زهرة حمراء.'},
    {word:'play',meaning:'يلعب',picture:'🧩',tag:'VERB',example:'We play together.',sentence:'نحن نلعب معًا.'},
    {word:'have',meaning:'لديه / يملك',picture:'🎒',tag:'VERB',example:'I have a book.',sentence:'لديّ كتاب.'},
    {word:'read',meaning:'يقرأ',picture:'📚',tag:'VERB',example:'I read a story.',sentence:'أقرأ قصة.'}
  ];
  var story=[
    {en:'Mia has a small garden.',ar:'لدى ميا حديقة صغيرة.'},
    {en:'She plants a red flower.',ar:'هي تزرع زهرة حمراء.'},
    {en:'The flower grows in the sun.',ar:'تنمو الزهرة تحت الشمس.'},
    {en:'Mia waters the flower every morning.',ar:'تسقي ميا الزهرة كل صباح.'},
    {en:'A little bird comes to the garden.',ar:'يأتي طائر صغير إلى الحديقة.'},
    {en:'Mia can see the bird near the flower.',ar:'تستطيع ميا رؤية الطائر قرب الزهرة.'},
    {en:'Her friend Tom helps her.',ar:'يساعدها صديقها توم.'},
    {en:'They are happy in the garden.',ar:'هما سعيدان في الحديقة.'}
  ];
  var miniStories=[
    {title:'Ben and the Blue Kite',arTitle:'بن والطائرة الورقية الزرقاء',icon:'🪁',lines:[{en:'Ben has a blue kite.',ar:'لدى بن طائرة ورقية زرقاء.'},{en:'The wind is strong.',ar:'الرياح قوية.'},{en:'He runs and the kite flies high.',ar:'يجري فترتفع الطائرة الورقية عاليًا.'}]},
    {title:'The Helpful Puppy',arTitle:'الجرو المساعد',icon:'🐶',lines:[{en:'A puppy sees a little girl.',ar:'يرى جرو فتاة صغيرة.'},{en:'She drops her ball.',ar:'تسقط كرتها.'},{en:'The puppy brings it back.',ar:'يعيد الجرو الكرة إليها.'}]},
    {title:'A Rainy Day',arTitle:'يوم ممطر',icon:'🌧️',lines:[{en:'Rain falls in the morning.',ar:'تهطل الأمطار في الصباح.'},{en:'Mona puts on her coat.',ar:'ترتدي منى معطفها.'},{en:'She reads a book at home.',ar:'تقرأ كتابًا في المنزل.'}]},
    {title:'Nina’s Lunch',arTitle:'غداء نينا',icon:'🍎',lines:[{en:'Nina has a sandwich and an apple.',ar:'لدى نينا شطيرة وتفاحة.'},{en:'She shares her apple with a friend.',ar:'تشارك تفاحتها مع صديقة.'},{en:'They eat together and smile.',ar:'تأكلان معًا وتبتسمان.'}]},
    {title:'The Lost Pencil',arTitle:'القلم الرصاص المفقود',icon:'✏️',lines:[{en:'Adam cannot find his pencil.',ar:'لا يستطيع آدم العثور على قلمه الرصاص.'},{en:'His friend looks under the desk.',ar:'ينظر صديقه تحت المكتب.'},{en:'They find it beside the book.',ar:'يعثران عليه بجانب الكتاب.'}]}
  ];
    var sentences=[
    {answer:['I','like','apples'],words:['apples','I','like'],ar:'أنا أحب التفاح.'},
    {answer:['The','cat','is','small'],words:['small','is','The','cat'],ar:'القطة صغيرة.'},
    {answer:['I','can','see','a','bird'],words:['bird','I','a','see','can'],ar:'أستطيع أن أرى طائرًا.'},
    {answer:['I','am','happy'],words:['happy','I','am'],ar:'أنا سعيد.'},
    {answer:['We','have','a','garden'],words:['garden','We','a','have'],ar:'لدينا حديقة.'},
    {answer:['She','can','read'],words:['read','She','can'],ar:'هي تستطيع القراءة.'},
    {answer:['The','flowers','are','red'],words:['red','are','The','flowers'],ar:'الزهور حمراء.'},
    {answer:['I','see','two','birds'],words:['birds','I','two','see'],ar:'أرى طائرين.'}
  ];
  var questions=[
    {q:'What does Mia plant?',ar:'ماذا تزرع ميا؟',options:[{en:'A red flower',ar:'زهرة حمراء',yes:true},{en:'A blue kite',ar:'طائرة ورقية زرقاء'},{en:'A green tree',ar:'شجرة خضراء'}]},
    {q:'Where does the flower grow?',ar:'أين تنمو الزهرة؟',options:[{en:'In a box',ar:'داخل صندوق'},{en:'In the sun',ar:'تحت الشمس',yes:true},{en:'In the sea',ar:'في البحر'}]},
    {q:'What does Mia have?',ar:'ماذا لدى ميا؟',options:[{en:'A small garden',ar:'حديقة صغيرة',yes:true},{en:'A new bike',ar:'دراجة جديدة'},{en:'A blue bag',ar:'حقيبة زرقاء'}]},
    {q:'When does Mia water the flower?',ar:'متى تسقي ميا الزهرة؟',options:[{en:'Every morning',ar:'كل صباح',yes:true},{en:'At night',ar:'ليلًا'},{en:'Once a year',ar:'مرة في السنة'}]},
    {q:'Who helps Mia?',ar:'من يساعد ميا؟',options:[{en:'Tom',ar:'توم',yes:true},{en:'Her teacher',ar:'معلمتها'},{en:'Her brother',ar:'أخوها'}]},
    {q:'How do Mia and Tom feel in the garden?',ar:'كيف يشعران في الحديقة؟',options:[{en:'Happy',ar:'سعيدان',yes:true},{en:'Angry',ar:'غاضبان'},{en:'Sleepy',ar:'نعسانان'}]}
  ];
  var builderIndex=0,pickedIndexes=[],builderSolved=false,quizIndex=0,quizScore=0,quizAnswered=false;
  var grammarQuestions=[{q:'I ___ happy today.',ar:'أنا سعيد اليوم.',options:['am','is','are'],correct:0,why:'مع I نستخدم am.'},{q:'She ___ a red flower.',ar:'هي تملك زهرة حمراء.',options:['have','has','having'],correct:1,why:'مع he وshe وit نستخدم has.'},{q:'They ___ play together.',ar:'هم يستطيعون اللعب معًا.',options:['can','is','has'],correct:0,why:'بعد can نستخدم الفعل في صورته الأساسية.'},{q:'I see two ___.',ar:'أرى طائرين.',options:['bird','birds','birdes'],correct:1,why:'غالبًا نضيف s للاسم عند الحديث عن أكثر من شيء.'},{q:'___ cat is small.',ar:'القطة صغيرة.',options:['The','the','tHE'],correct:0,why:'نبدأ الجملة بحرف كبير.'},{q:'Choose the correct sentence.',ar:'اختر الجملة الصحيحة.',options:['we is happy.','We are happy.','We happy are.'],correct:1,why:'We تأتي معها are، وتبدأ الجملة بحرف كبير.'},{q:'Finish the sentence: I have a book__',ar:'أكمل علامة الترقيم.',options:['.','?',' ,'],correct:0,why:'الجملة الخبرية تنتهي عادةً بنقطة.'},{q:'I ___ read a story every day.',ar:'أستطيع قراءة قصة كل يوم.',options:['can','am','has'],correct:0,why:'نستخدم can للتعبير عن القدرة.'}];
  var grammarIndex=0,grammarScore=0,grammarAnswered=false,grammarCompletionRecorded=false;
  function speakC1(value,rate){
    var status=root.querySelector('#mfkrC1AudioStatus');
    if(!('speechSynthesis' in window)||!('SpeechSynthesisUtterance' in window)){
      if(status)status.textContent='النطق الصوتي غير مدعوم في هذا المتصفح. جرّب متصفحًا حديثًا.';
      return;
    }
    window.speechSynthesis.cancel();
    var utterance=new SpeechSynthesisUtterance(value);mfkrSelectEnglishVoice(utterance);
    utterance.lang='en-US';utterance.rate=rate||.8;utterance.pitch=1.03;
    utterance.onstart=function(){if(status)status.textContent='🔊 جاري النطق: '+value;};
    utterance.onend=function(){if(status)status.textContent='اضغط على زر الصوت للاستماع مرة أخرى.';};
    utterance.onerror=function(){if(status)status.textContent='تعذّر تشغيل الصوت. جرّب مرة أخرى.';};
    window.speechSynthesis.speak(utterance);
  }
  function drawBuilder(){
    var item=sentences[builderIndex];
    var pool=root.querySelector('#mfkrC1WordPool');
    var output=root.querySelector('#mfkrC1BuiltSentence');
    pool.innerHTML=item.words.map(function(word,index){
      if(pickedIndexes.indexOf(index)>=0)return '';
      return '<button type="button" class="mfkr-c1-chip" data-c1-pick="'+index+'">'+esc(word)+'</button>';
    }).join('');
    output.innerHTML=pickedIndexes.length?pickedIndexes.map(function(index,pos){
      return '<button type="button" class="mfkr-c1-chip is-picked" data-c1-remove="'+pos+'" aria-label="Remove '+esc(item.words[index])+'">'+esc(item.words[index])+' <span aria-hidden="true">×</span></button>';
    }).join(''):'<span class="mfkr-c1-output-placeholder">اضغط على الكلمات لترتيبها هنا</span>';
    root.querySelector('#mfkrC1BuilderCount').textContent='Sentence '+(builderIndex+1)+' / '+sentences.length;
    root.querySelector('#mfkrC1BuilderFeedback').textContent=builderSolved?'ممتاز! '+item.ar:'رتّب الكلمات ثم اضغط «تحقّق من الجملة».';
    root.querySelector('#mfkrC1BuilderFeedback').classList.toggle('is-right',builderSolved);
    root.querySelector('[data-c1-check]').disabled=pickedIndexes.length===0||builderSolved;
    root.querySelector('[data-c1-next]').disabled=!builderSolved;
  }
  function drawQuiz(){
    var host=root.querySelector('#mfkrC1Quiz');
    if(quizIndex>=questions.length){
      host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🏆</div><h3>Great job!</h3><div class="mfkr-ar" lang="ar">أحسنت! خلصت تحدّي القصة.</div><p class="mfkr-quiz-feedback is-right">Your score: '+quizScore+' / '+questions.length+' — نتيجتك</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-c1-restart>جرّب مرة أخرى ↻</button></div>';
      return;
    }
    var q=questions[quizIndex];
    host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">QUESTION '+(quizIndex+1)+' / '+questions.length+'</span><span class="mfkr-quiz-score">Score: '+quizScore+'</span></div><h3 lang="en">'+esc(q.q)+'</h3><p class="mfkr-quiz-hint" lang="ar">'+esc(q.ar)+'</p><div class="mfkr-quiz-options mfkr-c1-options">'+q.options.map(function(option,index){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option" data-c1-quiz-option="'+index+'"><span lang="en">'+esc(option.en)+'</span><span class="mfkr-c1-option-ar" lang="ar">'+esc(option.ar)+'</span></button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrC1QuizFeedback" lang="ar" aria-live="polite">اقرأ السؤال واختار الإجابة الصحيحة.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-c1-quiz-next disabled>السؤال التالي ←</button></div>';
  }
  function drawGrammar(){
    var host=root.querySelector('#mfkrC1Grammar');if(!host)return;
    if(grammarIndex>=grammarQuestions.length){host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🌱</div><h3>Grammar Garden complete!</h3><p lang="ar">نتيجتك: '+grammarScore+' من '+grammarQuestions.length+'. '+(grammarScore>=6?'أحسنت! راجعت أهم قواعد تكوين الجمل.':'راجع القواعد القصيرة ثم جرّب مرة أخرى.')+'</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-c1-grammar-restart>أعد تدريب القواعد ↻</button></div>';if(!grammarCompletionRecorded){grammarCompletionRecorded=true;if(typeof journeyRecord==='function'&&grammarScore>=6)journeyRecord('checkpoint:c1-grammar',null,'C1');}return;}
    var item=grammarQuestions[grammarIndex];host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">GRAMMAR CHECK</span><span class="mfkr-quiz-count">Question '+(grammarIndex+1)+' / '+grammarQuestions.length+'</span><span class="mfkr-quiz-score">Score: '+grammarScore+'</span></div><h3 lang="en">'+esc(item.q)+'</h3><p class="mfkr-quiz-hint" lang="ar">'+esc(item.ar)+'</p><div class="mfkr-quiz-options">'+item.options.map(function(option,index){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option" data-c1-grammar-option="'+index+'">'+esc(option)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrC1GrammarFeedback" lang="ar" aria-live="polite">اختار الإجابة الأنسب، ثم اقرأ سبب الإجابة.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-c1-grammar-next disabled>السؤال التالي ←</button></div>';
  }
  var miniStoryCards=miniStories.map(function(storyItem,index){return '<article class="mfkr-a2-story-card"><div class="mfkr-topic-heading"><div><h3>'+esc(storyItem.title)+'</h3><div class="mfkr-c1-story-title-ar" lang="ar">'+esc(storyItem.arTitle)+'</div></div><span class="mfkr-art" aria-hidden="true">'+storyItem.icon+'</span></div>'+storyItem.lines.map(function(line){return '<div class="mfkr-c1-story-en" lang="en">'+esc(line.en)+'</div><div class="mfkr-c1-story-ar" lang="ar">'+esc(line.ar)+'</div>';}).join('')+'<div class="mfkr-c1-actions"><button type="button" class="mfkr-sound" data-c1-mini-story="'+index+'">🔊 استمع للقصة</button></div></article>';}).join('');
  var wordCards=vocab.map(function(item){return '<article class="mfkr-word-card"><div class="mfkr-word-card-head"><span class="mfkr-word-picture" aria-hidden="true">'+item.picture+'</span><span class="mfkr-word-tag">'+esc(item.tag)+'</span></div><div class="mfkr-word">'+esc(item.word)+'</div><div class="mfkr-meaning" lang="ar">'+esc(item.meaning)+'</div><div class="mfkr-example-label">SAY IT IN A SENTENCE</div><div class="mfkr-example" lang="en">'+esc(item.example)+'</div><div class="mfkr-example-ar" lang="ar">'+esc(item.sentence)+'</div><div class="mfkr-word-actions"><button type="button" class="mfkr-sound" data-c1-speak="'+esc(item.word)+'">🔊 الكلمة</button><button type="button" class="mfkr-sound" data-c1-speak="'+esc(item.example)+'">♫ الجملة</button></div></article>';}).join('');
  var storyCards=story.map(function(line,index){return '<article class="mfkr-c1-story-line"><span class="mfkr-c1-story-number">0'+(index+1)+'</span><div class="mfkr-c1-story-en" lang="en">'+esc(line.en)+'</div><div class="mfkr-c1-story-ar" lang="ar">'+esc(line.ar)+'</div></article>';}).join('');
  root.innerHTML=shell('LITTLE LEARNERS · LEVEL C1','My First Sentences.','جُمَلي الأولى.','كوّن جملًا بسيطة، واقرأ قصة قصيرة، واسمع النطق، ثم جرّب تحدّي الفهم.','<div class="mfkr-summary"><span>6 short stories · 8 sentence tasks · grammar checkpoint</span><div class="mfkr-progress"><span style="width:100%"></span></div><span>Build · Read · Listen · Play</span></div><section class="mfkr-topic-panel mfkr-c1-story-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">STORY TIME · قصة مصوّرة</div><h2>Mia and the Flower</h2><div class="mfkr-c1-story-title-ar" lang="ar">ميا والزهرة</div></div><span class="mfkr-art" aria-hidden="true">🌷</span></div><div class="mfkr-c1-story-grid">'+storyCards+'</div><div class="mfkr-c1-actions"><button type="button" class="mfkr-btn mfkr-btn-primary" data-c1-story-speak>🔊 استمع للقصة / Listen</button><span class="mfkr-c1-story-tip">اقرأ الجملة الإنجليزية ثم معناها بالعربي.</span></div></section><section class="mfkr-topic-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">STORY SHELF · رف القصص</div><h2>Five More Little Stories</h2><div class="mfkr-c1-story-title-ar" lang="ar">خمس قصص قصيرة جديدة، مع الترجمة والصوت</div></div><span class="mfkr-art" aria-hidden="true">📚</span></div><div class="mfkr-a2-story-grid">'+miniStoryCards+'</div></section><section class="mfkr-quiz-panel mfkr-c1-builder-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 01 · BUILD A SENTENCE</div><h2>Sentence Builder <span aria-hidden="true">✦</span></h2><p lang="ar">كوّن جملة صحيحة بالضغط على الكلمات بالترتيب. يمكنك إزالة أي كلمة بالضغط عليها.</p></div><div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge" id="mfkrC1BuilderCount">Sentence 1 / 3</span><span class="mfkr-quiz-score">8 sentences to practise</span></div><div class="mfkr-c1-output" id="mfkrC1BuiltSentence" aria-live="polite"></div><div class="mfkr-c1-chip-row" id="mfkrC1WordPool"></div><p class="mfkr-quiz-feedback" id="mfkrC1BuilderFeedback" lang="ar" aria-live="polite">رتّب الكلمات ثم اضغط «تحقّق من الجملة».</p><div class="mfkr-c1-actions"><button type="button" class="mfkr-btn mfkr-btn-primary" data-c1-check>تحقّق من الجملة ✓</button><button type="button" class="mfkr-btn" data-c1-next disabled>الجملة التالية ←</button></div></section><div class="mfkr-topic-heading mfkr-c1-vocab-heading"><div><div class="mfkr-mini-eyebrow">WORDS TO HELP YOU</div><h2>Words make sentences</h2><div class="mfkr-c1-story-title-ar" lang="ar">كلمات تساعدك على تكوين الجمل</div></div><span class="mfkr-count">12 words</span></div><div class="mfkr-word-grid" id="mfkrC1WordGrid">'+wordCards+'</div><p class="mfkr-audio-status" id="mfkrC1AudioStatus" aria-live="polite">اضغط على الكلمة أو الجملة لسماع النطق باللغة الإنجليزية.</p><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 02 · GRAMMAR GARDEN</div><h2>Grammar Garden <span aria-hidden="true">✦</span></h2><p lang="ar">راجع am/is/are، واستخدام can وhas، والجمع، والحروف الكبيرة وعلامات الترقيم.</p><div class="mfkr-c1-story-title-ar" lang="en" style="margin:10px 0">I am happy. · She has a book. · They can play. · Two birds.</div><div id="mfkrC1Grammar"></div></section><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 03 · STORY CHALLENGE</div><h2>Story Challenge <span aria-hidden="true">✦</span></h2><p lang="ar">جاوب عن الأسئلة بعد قراءة قصة ميا والزهرة. كل سؤال له معنى بالعربي.</p></div><div id="mfkrC1Quiz"></div></section>'+backButtons(url('younger'),'← الرجوع للمستويات')+'<div class="mfkr-note">نصيحة: اسمع الجملة، اقرأ معناها، ثم كرّرها بصوتك. جرّب تكوين الجملة أكثر من مرة لحد ما ترتيب الكلمات يبقى سهلًا.</div>');
  drawBuilder();
  drawQuiz();
  drawGrammar();
  root.addEventListener('click',function(event){
    var miniStorySound=event.target.closest('[data-c1-mini-story]');if(miniStorySound){var miniIndex=Number(miniStorySound.getAttribute('data-c1-mini-story'));if(miniStories[miniIndex])speakC1(miniStories[miniIndex].lines.map(function(line){return line.en;}).join(' '),.78);return;}var grammarOption=event.target.closest('[data-c1-grammar-option]');if(grammarOption&&!grammarAnswered&&grammarIndex<grammarQuestions.length){var grammarPick=Number(grammarOption.getAttribute('data-c1-grammar-option')),grammarItem=grammarQuestions[grammarIndex],grammarCorrect=grammarPick===grammarItem.correct;grammarAnswered=true;if(grammarCorrect)grammarScore++;root.querySelectorAll('[data-c1-grammar-option]').forEach(function(button){var idx=Number(button.getAttribute('data-c1-grammar-option'));button.disabled=true;if(idx===grammarItem.correct)button.classList.add('is-correct');else if(button===grammarOption&&!grammarCorrect)button.classList.add('is-wrong');});var grammarFeedback=root.querySelector('#mfkrC1GrammarFeedback');if(grammarFeedback){grammarFeedback.textContent=grammarCorrect?'ممتاز! '+grammarItem.why:'الإجابة الصحيحة: '+grammarItem.options[grammarItem.correct]+'. '+grammarItem.why;grammarFeedback.classList.toggle('is-right',grammarCorrect);grammarFeedback.classList.toggle('is-wrong',!grammarCorrect);}var grammarScoreNode=root.querySelector('#mfkrC1Grammar .mfkr-quiz-score');if(grammarScoreNode)grammarScoreNode.textContent='Score: '+grammarScore;root.querySelector('[data-c1-grammar-next]').disabled=false;return;}if(event.target.closest('[data-c1-grammar-next]')&&grammarAnswered){grammarIndex++;grammarAnswered=false;drawGrammar();return;}if(event.target.closest('[data-c1-grammar-restart]')){grammarIndex=0;grammarScore=0;grammarAnswered=false;grammarCompletionRecorded=false;drawGrammar();return;}var sound=event.target.closest('[data-c1-speak]');
    if(sound){speakC1(sound.getAttribute('data-c1-speak'),sound.getAttribute('data-c1-speak').length>18?.86:.78);return;}
    if(event.target.closest('[data-c1-story-speak]')){speakC1(story.map(function(line){return line.en;}).join(' '),.76);return;}
    var pick=event.target.closest('[data-c1-pick]');
    if(pick&&!builderSolved){pickedIndexes.push(Number(pick.getAttribute('data-c1-pick')));drawBuilder();return;}
    var remove=event.target.closest('[data-c1-remove]');
    if(remove&&!builderSolved){pickedIndexes.splice(Number(remove.getAttribute('data-c1-remove')),1);drawBuilder();return;}
    if(event.target.closest('[data-c1-check]')&&!builderSolved){
      var item=sentences[builderIndex],attempt=pickedIndexes.map(function(index){return item.words[index];});
      builderSolved=attempt.join(' ')===(item.answer.join(' '));
      var feedback=root.querySelector('#mfkrC1BuilderFeedback');
      feedback.textContent=builderSolved?'رائع! '+item.answer.join(' ')+'. — '+item.ar:'لسه مش بالترتيب الصحيح. اضغط على أي كلمة في الجملة لإزالتها، وحاول تاني.';
      feedback.classList.toggle('is-right',builderSolved);
      feedback.classList.toggle('is-wrong',!builderSolved);
      root.querySelector('[data-c1-check]').disabled=pickedIndexes.length===0||builderSolved;
      root.querySelector('[data-c1-next]').disabled=!builderSolved;
      return;
    }
    if(event.target.closest('[data-c1-next]')&&builderSolved){
      builderIndex=(builderIndex+1)%sentences.length;pickedIndexes=[];builderSolved=false;drawBuilder();return;
    }
    var optionButton=event.target.closest('[data-c1-quiz-option]');
    if(optionButton&&!quizAnswered&&quizIndex<questions.length){
      var selectedIndex=Number(optionButton.getAttribute('data-c1-quiz-option')),q=questions[quizIndex],correct=!!q.options[selectedIndex].yes;
      quizAnswered=true;if(correct)quizScore++;
      root.querySelectorAll('[data-c1-quiz-option]').forEach(function(button){
        var index=Number(button.getAttribute('data-c1-quiz-option'));button.disabled=true;
        if(q.options[index].yes)button.classList.add('is-correct');
        else if(index===selectedIndex&&!correct)button.classList.add('is-wrong');
      });
      var feedback=root.querySelector('#mfkrC1QuizFeedback');
      feedback.textContent=correct?'ممتاز! إجابة صحيحة ✨':'قريب جدًا! الإجابة الصحيحة هي: '+q.options.filter(function(option){return option.yes;})[0].ar;
      feedback.classList.toggle('is-right',correct);feedback.classList.toggle('is-wrong',!correct);
      var score=root.querySelector('.mfkr-quiz-score');if(score)score.textContent='Score: '+quizScore;
      root.querySelector('[data-c1-quiz-next]').disabled=false;
      return;
    }
    if(event.target.closest('[data-c1-quiz-next]')){if(!quizAnswered)return;quizIndex++;quizAnswered=false;drawQuiz();return;}
    if(event.target.closest('[data-c1-restart]')){quizIndex=0;quizScore=0;quizAnswered=false;drawQuiz();return;}
  });
}

function renderSoon(){var code=(query.get('level')||'Level').toUpperCase();var group=query.get('group')==='older'?'older':'younger';var titles={A2:'Word Explorers',B2:'Reading Builders',C2:'Confident English',B1:'My First Words',C1:'My First Sentences'};document.title=code+' coming soon | Mr. Fluent Kids';root.innerHTML=shell('YOUR NEXT ADVENTURE',esc(code)+' is on the way.','المستوى ده لسه تحت الإنشاء.','We are preparing the lessons, activities and audio for this level.','<div class="mfkr-choice-grid"><div class="mfkr-choice"><div class="mfkr-card-top"><span class="mfkr-art">🛠️</span><span class="mfkr-tag">IN DEVELOPMENT</span></div><h2>'+esc(titles[code]||'Coming soon')+'</h2><p class="mfkr-desc">Lessons and activities are being prepared. Start with A1 while the next level is in development.</p><div class="mfkr-card-foot"><span>Coming soon</span><span>✦</span></div></div><a class="mfkr-choice" href="'+url('a1')+'"><div class="mfkr-card-top"><span class="mfkr-art">🔤</span><span class="mfkr-tag">AVAILABLE NOW</span></div><h2>My First ABC</h2><div class="mfkr-ar">الحروف من A إلى Z</div><p class="mfkr-desc">Capital and small letters, picture clues, Arabic meanings and pronunciation buttons.</p><div class="mfkr-card-foot"><span>A1 · Alphabet</span><span>Start learning ↗</span></div></a></div>'+backButtons(url(group), '← Back to levels'));}

function mfkjA1OpenLessonMenu(){
 var overlay=root.querySelector('#mfkjA1LessonMenu');if(!overlay)return;
 if(overlay.hidden)window.__mfkjA1BodyOverflowBefore=document.body.style.overflow;
 overlay.hidden=false;overlay.setAttribute('aria-hidden','false');document.body.style.overflow='hidden';
 var trigger=root.querySelector('#mfkjA1MenuTrigger');if(trigger)trigger.setAttribute('aria-expanded','true');
}
function mfkjA1CloseLessonMenu(){
 var overlay=root.querySelector('#mfkjA1LessonMenu');if(overlay){overlay.hidden=true;overlay.setAttribute('aria-hidden','true');}
 document.body.style.overflow=window.__mfkjA1BodyOverflowBefore||'';
 var trigger=root.querySelector('#mfkjA1MenuTrigger');if(trigger){trigger.setAttribute('aria-expanded','false');trigger.focus({preventScroll:true});}
}
function mfkjA1SelectLessonPanel(key){
 var found=null;
 root.querySelectorAll('[data-mfkj-a1-panel]').forEach(function(panel){
  var active=panel.getAttribute('data-mfkj-a1-panel')===key;
  panel.hidden=!active;if(active)found=panel;
 });
 if(!found)return;
 window.__mfkjA1ActivePanel=key;mfkjA1CloseLessonMenu();found.scrollIntoView({behavior:'smooth',block:'start'});
}
function mfkjA1InstallLessonMenu(){
 var summary=root.querySelector('.mfkr-summary'),grid=root.querySelector('#mfkrAlphabetGrid'),status=root.querySelector('#mfkrAudioStatus');
 if(summary&&grid&&status&&!summary.closest('[data-mfkj-a1-panel]')){
  var abc=document.createElement('section');abc.className='mfkj-a1-panel';abc.setAttribute('data-mfkj-a1-panel','abc');
  summary.parentNode.insertBefore(abc,summary);abc.appendChild(summary);abc.appendChild(grid);abc.appendChild(status);
  var heading=document.createElement('div');heading.className='mfkj-a1-content-heading';
  heading.innerHTML='<h1>ABC</h1><p lang="ar" dir="rtl">الحروف من A إلى Z · الحرف والصورة والصوت</p>';abc.insertBefore(heading,summary);
 }
 [
  {selector:'.mfkr-topic-panel',key:'trace'},
  {selector:'.mfkr-quiz-panel:not(.mfkr-a1-activity-panel)',key:'sound'},
  {selector:'#mfkrA1LookQuiz',key:'look'},
  {selector:'#mfkrA1ListenQuiz',key:'listen'}
 ].forEach(function(item){var panel=root.querySelector(item.selector);if(panel){panel.classList.add('mfkj-a1-panel');panel.setAttribute('data-mfkj-a1-panel',item.key);}});
 root.classList.add('mfkj-a1-workspace');window.__mfkjA1ActivePanel='abc';
 root.querySelectorAll('[data-mfkj-a1-panel]').forEach(function(panel){panel.hidden=panel.getAttribute('data-mfkj-a1-panel')!=='abc';});
 if(!root.querySelector('#mfkjA1MenuTrigger')){
  var trigger=document.createElement('button');trigger.type='button';trigger.id='mfkjA1MenuTrigger';trigger.className='mfkj-a1-menu-trigger';
  trigger.setAttribute('aria-label','فتح قائمة الدروس والأنشطة');trigger.setAttribute('aria-controls','mfkjA1LessonMenu');trigger.setAttribute('aria-expanded','false');
  trigger.innerHTML='<span aria-hidden="true">☰</span><span>القائمة</span>';trigger.addEventListener('click',mfkjA1OpenLessonMenu);root.appendChild(trigger);
 }
 var old=root.querySelector('#mfkjA1LessonMenu');if(old)old.remove();
 var overlay=document.createElement('div');overlay.id='mfkjA1LessonMenu';overlay.className='mfkj-a1-overlay';overlay.hidden=true;overlay.setAttribute('aria-hidden','true');
 overlay.innerHTML='<aside class="mfkj-a1-dialog" role="dialog" aria-modal="true" aria-label="قائمة دروس وأنشطة A1">'+
 '<header class="mfkj-a1-dialog-head"><div><span class="mfkj-a1-kicker">MR. FLUENT KIDS · A1</span><h2>الدروس والأنشطة</h2></div><button type="button" class="mfkj-a1-close" data-mfkj-a1-menu-close>إغلاق القائمة</button></header>'+
 '<nav class="mfkj-a1-menu-list" aria-label="دروس وأنشطة المستوى">'+
 '<div class="mfkj-a1-menu-group">دروس المستوى A1</div>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="abc"><span aria-hidden="true">🔤</span><span>ABC · الحروف والأصوات</span></button>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="trace"><span aria-hidden="true">✍️</span><span>Trace the Letter · تتبّع الحرف</span></button>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="sound"><span aria-hidden="true">🔎</span><span>Sound Detective · اكتشف الصوت</span></button>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="look"><span aria-hidden="true">🖼️</span><span>Look &amp; Choose · اختار اسم الصورة</span></button>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="listen"><span aria-hidden="true">🎧</span><span>Listen &amp; Choose · اسمع واختار</span></button>'+
 '<div class="mfkj-a1-menu-group">Learning Lab · مساحة التعلّم</div>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=lab&amp;kidsTab=overview"><span aria-hidden="true">🌱</span><span>Learning Lab · البداية</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=lab&amp;kidsTab=missions"><span aria-hidden="true">🏡</span><span>Home Missions · مهمات البيت</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=lab&amp;kidsTab=maker"><span aria-hidden="true">🧩</span><span>Maker Projects · مشروعات عملية</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=review"><span aria-hidden="true">🧠</span><span>Smart Review · مراجعة ذكية</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=lab&amp;kidsTab=writing"><span aria-hidden="true">✍️</span><span>Writing Studio · تدريب الكتابة</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=lab&amp;kidsTab=portfolio"><span aria-hidden="true">📒</span><span>Achievement Portfolio · ملف الإنجاز</span></a>'+
 '<div class="mfkj-a1-menu-group">أدوات المستوى</div>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="speaking"><span aria-hidden="true">💬</span><span>Speaking Studio</span></button>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="final"><span aria-hidden="true">🏆</span><span>Final Challenge</span></button>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="certificate"><span aria-hidden="true">🎓</span><span>Level Certificate</span></button>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="review"><span aria-hidden="true">🧠</span><span>My Review · مراجعة أخطائي</span></button>'+
 '<div class="mfkj-a1-menu-group">الخريطة والمتابعة</div>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=map"><span aria-hidden="true">🗺️</span><span>Curriculum Map · خريطة المنهج</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=parents"><span aria-hidden="true">👪</span><span>Parent Overview · متابعة ولي الأمر</span></a>'+
 '<div class="mfkj-a1-menu-group">التنقّل</div>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=hub"><span aria-hidden="true">↩</span><span>الرجوع للمستويات</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./"><span aria-hidden="true">✦</span><span>DOMA Academy</span></a>'+
 '</nav></aside>';
 overlay.addEventListener('click',function(event){
  if(event.target===overlay){mfkjA1CloseLessonMenu();return;}
  var close=event.target.closest('[data-mfkj-a1-menu-close]');if(close){mfkjA1CloseLessonMenu();return;}
  var item=event.target.closest('[data-mfkj-a1-target]');if(item)mfkjA1SelectLessonPanel(item.getAttribute('data-mfkj-a1-target'));
 });
 root.appendChild(overlay);
 if(window.__mfkjA1MenuKeyHandler)document.removeEventListener('keydown',window.__mfkjA1MenuKeyHandler);
 window.__mfkjA1MenuKeyHandler=function(event){var menu=root.querySelector('#mfkjA1LessonMenu');if(event.key==='Escape'&&menu&&!menu.hidden)mfkjA1CloseLessonMenu();};
 document.addEventListener('keydown',window.__mfkjA1MenuKeyHandler);
}
function mfkjA1SyncWorkspace(){
 if(!root||!root.classList.contains('mfkj-a1-workspace'))return;
 [
  {selector:'#mfkjSpeaking',key:'speaking'},
  {selector:'#mfkjFinal',key:'final'},
  {selector:'#mfkjCertificate',key:'certificate'},
  {selector:'#mfkjToolsReview',key:'review'}
 ].forEach(function(item){var panel=root.querySelector(item.selector);if(panel){panel.classList.add('mfkj-a1-panel');panel.setAttribute('data-mfkj-a1-panel',item.key);}});
 var active=window.__mfkjA1ActivePanel||'abc',found=false;
 root.querySelectorAll('[data-mfkj-a1-panel]').forEach(function(panel){var show=panel.getAttribute('data-mfkj-a1-panel')===active;panel.hidden=!show;if(show)found=true;});
 if(!found){window.__mfkjA1ActivePanel='abc';root.querySelectorAll('[data-mfkj-a1-panel]').forEach(function(panel){panel.hidden=panel.getAttribute('data-mfkj-a1-panel')!=='abc';});}
}

function mfkjCreateCourseExtraActivities(code,wrap){
 var gridIds={A2:'mfkrA2WordGrid',B1:'mfkrB1WordGrid',C1:'mfkrC1WordGrid',B2:'mfkrB2WordGrid',C2:'mfkrC2WordGrid'};
 var grid=root.querySelector('#'+gridIds[code]);if(!grid)return[];
 var bank=Array.from(grid.querySelectorAll('.mfkr-word-card')).map(function(card,index){
  var pick=function(selector){var node=card.querySelector(selector);return node?String(node.textContent||'').replace(/\s+/g,' ').trim():'';};
  return{idx:index,word:pick('.mfkr-word'),meaning:pick('.mfkr-meaning'),picture:pick('.mfkr-word-picture')||'🔤',example:pick('.mfkr-example')||pick('.mfkr-c1-story-en'),exampleAr:pick('.mfkr-example-ar')||pick('.mfkr-c1-story-ar')};
 }).filter(function(item){return item.word&&item.meaning;});
 if(bank.length<4)return[];
 var limitWords={B1:1,C1:5,A2:7,B2:9,C2:12};
 function shuffle(items){var result=items.slice();for(var i=result.length-1;i>0;i--){var j=Math.floor(Math.random()*(i+1)),tmp=result[i];result[i]=result[j];result[j]=tmp;}return result;}
 function escapePattern(text){return String(text).split('').map(function(ch){return '\\.^$*+?()[]{}|'.indexOf(ch)>=0?'\\'+ch:ch;}).join('');}
 function blankTarget(item){
  var example=item.example||item.word;
  var re=new RegExp('(^|[^A-Za-z])'+escapePattern(item.word)+'(?=$|[^A-Za-z])','i');
  var result=example.replace(re,'$1_____');
  return result===example?example:result;
 }
 function panel(suffix,key,title,subtitle){
  var node=document.createElement('section');node.id='mfkjExtra'+code+suffix;
  node.className='mfkr-topic-panel mfkj-course-practice-panel';node.setAttribute('data-mfkj-course-practice',key);
  node.innerHTML='<div class="mfkj-x-head"><span class="mfkj-x-icon" aria-hidden="true">'+({trace:'✍️',visual:'🖼️',listen:'🎧',detective:'🔎'}[key]||'✦')+'</span><div><div class="mfkr-mini-eyebrow">LEVEL PRACTICE · '+code+'</div><h2>'+title+'</h2><p lang="ar" dir="rtl">'+subtitle+'</p></div></div>';
  var back=wrap.querySelector('.mfkr-back-row');wrap.insertBefore(node,back||null);return node;
 }
 function choicesFor(target){return shuffle([target].concat(shuffle(bank.filter(function(item){return item.idx!==target.idx;})).slice(0,3)));}
 function choiceLabel(kind,item){
  if(kind==='visual'){
   if(code==='B1'||code==='A2'||code==='B2')return '<strong>'+esc(item.word)+'</strong>';
   if(code==='C1')return '<strong>'+esc(item.example||item.word)+'</strong><small lang="ar" dir="rtl">'+esc(item.exampleAr||item.meaning)+'</small>';
   return '<strong lang="ar" dir="rtl">'+esc(item.meaning)+'</strong>';
  }
  if(kind==='listen'){
   if(code==='B1')return '<span class="mfkj-x-picture">'+esc(item.picture)+'</span><small lang="ar" dir="rtl">'+esc(item.meaning)+'</small>';
   if(code==='C1')return '<strong lang="ar" dir="rtl">'+esc(item.exampleAr||item.meaning)+'</strong>';
   if(code==='A2')return '<strong>'+esc(item.word)+'</strong><small lang="ar" dir="rtl">'+esc(item.meaning)+'</small>';
   return '<strong lang="ar" dir="rtl">'+esc(item.meaning)+'</strong>';
  }
  if(kind==='detective'){
   if(code==='B1'||code==='B2')return '<strong lang="ar" dir="rtl">'+esc(item.meaning)+'</strong>';
   if(code==='C1')return '<strong>'+esc(item.example||item.word)+'</strong><small lang="ar" dir="rtl">'+esc(item.exampleAr||item.meaning)+'</small>';
   return '<strong>'+esc(item.word)+'</strong><small lang="ar" dir="rtl">'+esc(item.meaning)+'</small>';
  }
  return '<strong>'+esc(item.word)+'</strong>';
 }
 function promptFor(kind,target){
  if(kind==='visual'){
   if(code==='B1')return '<div class="mfkj-x-picture-prompt"><span>'+esc(target.picture)+'</span><p>What is in the picture? · ما الكلمة التي تناسب الصورة؟</p></div>';
   if(code==='C1')return '<div class="mfkj-x-picture-prompt"><span>'+esc(target.picture)+'</span><p>اختار الجملة الإنجليزية المناسبة للصورة.</p></div>';
   if(code==='C2')return '<div class="mfkj-x-question"><span>CONTEXT CLUE · افهم من السياق</span><p lang="en">'+esc(blankTarget(target))+'</p><p lang="ar" dir="rtl">اختار المعنى العربي للكلمة الناقصة.</p></div>';
   return '<div class="mfkj-x-question"><span>COMPLETE THE SENTENCE · أكمل الجملة</span><p lang="en">'+esc(blankTarget(target))+'</p><p lang="ar" dir="rtl">اختر الكلمة التي تكمل الجملة من السياق.</p></div>';
  }
  if(kind==='listen'){
   var instruction=code==='B1'?'اسمع الكلمة واختار الصورة المناسبة.':code==='C1'?'اسمع الجملة واختار معناها.':code==='A2'?'اسمع المثال واختار الكلمة المستهدفة.':code==='B2'?'اسمع المثال ثم اختار المعنى المناسب في السياق.':'اسمع الجملة المتقدمة واختار أقرب معنى.';
   return '<div class="mfkj-x-question"><span>LISTEN · اسمع واختار</span><p lang="ar" dir="rtl">'+instruction+'</p><button type="button" class="mfkr-btn mfkr-btn-primary mfkj-x-play" data-mfkj-x-play>🔊 اسمع السؤال</button></div>';
  }
  if(code==='B1')return '<div class="mfkj-x-question"><span>WORD DETECTIVE · محقق الكلمات</span><p>What does <strong>'+esc(target.word)+'</strong> mean?</p><p lang="ar" dir="rtl">اختار المعنى العربي الصحيح.</p></div>';
  if(code==='C1')return '<div class="mfkj-x-question"><span>SENTENCE DETECTIVE · محقق الجمل</span><p lang="ar" dir="rtl">'+esc(target.exampleAr||target.meaning)+'</p><p>اختار الجملة الإنجليزية المطابقة للمعنى.</p></div>';
  if(code==='A2')return '<div class="mfkj-x-question"><span>WORD IN CONTEXT · الكلمة في سياقها</span><p lang="en">'+esc(blankTarget(target))+'</p><p lang="ar" dir="rtl">اختار الكلمة التي تكمل الجملة.</p></div>';
  if(code==='B2')return '<div class="mfkj-x-question"><span>READING DETECTIVE · محقق القراءة</span><p lang="en">'+esc(target.example||target.word)+'</p><p lang="ar" dir="rtl">استنتج معنى الكلمة من المثال.</p></div>';
  return '<div class="mfkj-x-question"><span>ADVANCED WORD CLUE · دليل متقدم</span><p lang="en">'+esc(blankTarget(target))+'</p><p lang="ar" dir="rtl">استخدم سياق الجملة لاختيار الكلمة الأدق.</p></div>';
 }
 function audioText(target){return code==='B1'?target.word:(target.example||target.word);}
 function speak(textValue,statusNode){
  if(!('speechSynthesis' in window)||!('SpeechSynthesisUtterance' in window)){if(statusNode)statusNode.textContent='ميزة الصوت غير مدعومة في هذا المتصفح.';return;}
  try{window.speechSynthesis.cancel();var utterance=new SpeechSynthesisUtterance(textValue);if(typeof mfkrSelectEnglishVoice==='function')mfkrSelectEnglishVoice(utterance);utterance.lang='en-US';utterance.rate=code==='B1'?.76:code==='C1'?.82:code==='A2'?.84:code==='B2'?.88:.9;window.speechSynthesis.speak(utterance);}catch(_){if(statusNode)statusNode.textContent='تعذّر تشغيل الصوت. جرّب مرة أخرى.';}
 }
 function createQuiz(kind,title,subtitle){
  var node=panel(kind[0].toUpperCase()+kind.slice(1),kind,title,subtitle);
  node.innerHTML+='<div class="mfkj-x-game" data-mfkj-x-stage></div><div class="mfkj-x-game-foot"><span data-mfkj-x-score>Question 1 · Score 0</span><div><button type="button" class="mfkr-btn" data-mfkj-x-next disabled>السؤال التالي ←</button><button type="button" class="mfkr-btn" data-mfkj-x-reset>إعادة النتيجة ↻</button></div></div><p class="mfkj-x-feedback" data-mfkj-x-feedback lang="ar" dir="rtl" aria-live="polite">اختار إجابتك، وبعدها كمّل لجولة جديدة.</p>';
  var state={target:null,options:[],answered:false,selected:-1,question:0,score:0};
  function render(){
   var stage=node.querySelector('[data-mfkj-x-stage]'),score=node.querySelector('[data-mfkj-x-score]'),next=node.querySelector('[data-mfkj-x-next]'),feedback=node.querySelector('[data-mfkj-x-feedback]');
   if(!state.target){state.target=bank[Math.floor(Math.random()*bank.length)];state.options=choicesFor(state.target);}
   stage.innerHTML=promptFor(kind,state.target)+'<div class="mfkj-x-options">'+state.options.map(function(item){var correct=item.idx===state.target.idx,selected=item.idx===state.selected;return '<button type="button" class="mfkj-x-option'+(state.answered&&correct?' is-correct':'')+(state.answered&&selected&&!correct?' is-wrong':'')+'" data-mfkj-x-option="'+item.idx+'" '+(state.answered?'disabled':'')+'>'+choiceLabel(kind,item)+'</button>';}).join('')+'</div>';
   score.textContent='Question '+(state.question+1)+' · Score '+state.score;
   next.disabled=!state.answered;feedback.textContent=state.answered?(state.selected===state.target.idx?'ممتاز! إجابة صحيحة ✨':'قريب! الإجابة الصحيحة: '+state.target.word+' · '+state.target.meaning):'اختار إجابة، والأسئلة مستمرة من غير حدّ.';
  }
  node.addEventListener('click',function(event){
   var option=event.target.closest('[data-mfkj-x-option]');
   if(option){if(state.answered)return;state.selected=Number(option.getAttribute('data-mfkj-x-option'));state.answered=true;var chosen=String(option.textContent||'').replace(/\s+/g,' ').trim();if(state.selected===state.target.idx){state.score++;if(typeof journeyRecord==='function')journeyRecord('activity:'+code+':'+kind+':'+String(state.target.word).toLowerCase(),state.target.word,code);}else if(typeof journeyAddReviewItem==='function'){journeyAddReviewItem({id:code+'|extra|'+kind+'|'+String(state.target.word).toLowerCase(),question:title+' · '+String(state.target.example||state.target.word||title).slice(0,220),arabic:state.target.meaning||'',selected:chosen,correct:String(state.target.word||'')+' · '+String(state.target.meaning||''),kind:kind+' practice'},code);}render();return;}
   if(event.target.closest('[data-mfkj-x-play]')){speak(audioText(state.target),node.querySelector('[data-mfkj-x-feedback]'));return;}
   if(event.target.closest('[data-mfkj-x-next]')){if(!state.answered)return;state.question++;state.target=null;state.selected=-1;state.answered=false;render();return;}
   if(event.target.closest('[data-mfkj-x-reset]')){state.question=0;state.score=0;state.target=null;state.selected=-1;state.answered=false;render();}
  });
  render();return{key:kind+'-extra',label:({visual:'Look & Choose · اختار الإجابة المناسبة',listen:'Listen & Choose · اسمع واختار',detective:'Detective Challenge · تحدّي التفكير'}[kind]),node:node};
 }
 var traceNode=panel('Trace','trace','Trace & Write · تتبّع واكتب','تدرّب على كتابة الكلمة أو الجملة بخط يدك. كل مستوى يستخدم كلمات وجمل تناسب تقدّمك.');
 traceNode.innerHTML+='<div class="mfkj-x-trace-wrap"><canvas class="mfkj-x-canvas" width="900" height="270" aria-label="Trace the English word or sentence"></canvas><p class="mfkj-x-trace-ar" lang="ar" dir="rtl" data-mfkj-x-trace-ar></p><div class="mfkj-x-trace-actions"><span data-mfkj-x-trace-count>Practice 1</span><button type="button" class="mfkr-btn" data-mfkj-x-trace-clear>امسح الكتابة</button><button type="button" class="mfkr-btn mfkr-btn-primary" data-mfkj-x-trace-next>نص جديد ↻</button></div></div>';
 var traceState={index:0,target:null,drawing:false,last:null,drawn:false};
 var canvas=traceNode.querySelector('canvas'),ctx=canvas.getContext('2d');
 function traceValue(item){if(code==='B1')return item.word;var max=limitWords[code]||7;return String(item.example||item.word).split(/\s+/).slice(0,max).join(' ');}
 function drawTraceGuide(){
  if(!ctx)return;ctx.clearRect(0,0,canvas.width,canvas.height);
  var target=traceValue(traceState.target),fontSize=({B1:104,C1:65,A2:56,B2:48,C2:42})[code]||54;
  ctx.font='900 '+fontSize+'px Arial, sans-serif';var words=target.split(/\s+/),lines=[],line='';
  words.forEach(function(word){var candidate=line?line+' '+word:word;if(ctx.measureText(candidate).width>810&&line){lines.push(line);line=word;}else line=candidate;});if(line)lines.push(line);
  while(lines.length>3&&fontSize>31){fontSize-=3;ctx.font='900 '+fontSize+'px Arial, sans-serif';lines=[];line='';words.forEach(function(word){var candidate=line?line+' '+word:word;if(ctx.measureText(candidate).width>810&&line){lines.push(line);line=word;}else line=candidate;});if(line)lines.push(line);}
  var lineHeight=Math.min(72,fontSize+14),startY=(canvas.height-(lines.length-1)*lineHeight)/2-2;
  ctx.textAlign='center';ctx.textBaseline='middle';ctx.lineWidth=2.5;ctx.strokeStyle='rgba(237,174,216,.92)';ctx.setLineDash([7,8]);
  lines.forEach(function(text,index){ctx.strokeText(text,canvas.width/2,startY+index*lineHeight,820);});
  ctx.setLineDash([]);ctx.fillStyle='rgba(180,153,185,.86)';ctx.font='600 17px Arial, sans-serif';ctx.fillText('Trace slowly · تتبّع ببطء',canvas.width/2,canvas.height-18);
  var hint=traceNode.querySelector('[data-mfkj-x-trace-ar]');if(hint)hint.textContent=traceState.target.meaning||'';
  traceNode.querySelector('[data-mfkj-x-trace-count]').textContent='Practice '+(traceState.index+1)+' · '+(code==='B1'?'Word':code==='C1'?'Short sentence':code==='A2'?'Sentence':'Context sentence');
 }
 function selectTraceTarget(){traceState.target=bank[Math.floor(Math.random()*bank.length)];drawTraceGuide();}
 function point(event){var rect=canvas.getBoundingClientRect();return{x:(event.clientX-rect.left)*canvas.width/rect.width,y:(event.clientY-rect.top)*canvas.height/rect.height};}
 canvas.addEventListener('pointerdown',function(event){if(!ctx)return;traceState.drawing=true;traceState.drawn=true;traceState.last=point(event);if(canvas.setPointerCapture)canvas.setPointerCapture(event.pointerId);ctx.beginPath();ctx.moveTo(traceState.last.x,traceState.last.y);event.preventDefault();});
 canvas.addEventListener('pointermove',function(event){if(!traceState.drawing||!ctx)return;var p=point(event);ctx.strokeStyle='rgba(145,240,219,.95)';ctx.lineWidth=6;ctx.lineCap='round';ctx.lineJoin='round';ctx.beginPath();ctx.moveTo(traceState.last.x,traceState.last.y);ctx.lineTo(p.x,p.y);ctx.stroke();traceState.last=p;event.preventDefault();});
 ['pointerup','pointercancel','lostpointercapture'].forEach(function(name){canvas.addEventListener(name,function(){traceState.drawing=false;traceState.last=null;});});
 traceNode.addEventListener('click',function(event){if(event.target.closest('[data-mfkj-x-trace-clear]')){drawTraceGuide();return;}if(event.target.closest('[data-mfkj-x-trace-next]')){if(traceState.drawn&&traceState.target&&typeof journeyRecord==='function'){var tv=traceValue(traceState.target);journeyRecord('activity:'+code+':trace:'+String(tv).toLowerCase(),tv,code);}traceState.index++;traceState.drawn=false;selectTraceTarget();}});
 selectTraceTarget();
 var extras=[
  createQuiz('visual','Look & Choose · شوف واختار',({B1:'شوف الصورة واختار الكلمة المناسبة.',C1:'طابق الصورة مع جملة بسيطة.',A2:'اقرأ الجملة واختار الكلمة الناقصة.',B2:'استخدم سياق الجملة لتحديد الكلمة.',C2:'استنتج معنى الكلمة من سياق الجملة.'})[code]||'اختار الإجابة المناسبة.'),
  createQuiz('listen','Listen & Choose · اسمع واختار',({B1:'اسمع الكلمة ثم اختار الصورة.',C1:'اسمع الجملة ثم اختار معناها.',A2:'اسمع المثال وحدد الكلمة المستهدفة.',B2:'استمع للمثال واختر معنى المفردة.',C2:'استمع للسياق واختر المعنى الأدق.'})[code]||'استمع ثم اختر.'),
  createQuiz('detective','Word Detective · محقق الكلمات',({B1:'اكتشف معنى الكلمة اليومية.',C1:'طابق المعنى العربي مع الجملة الإنجليزية.',A2:'اكتشف الكلمة من مكانها في الجملة.',B2:'استخدم المثال لاستنتاج معنى الكلمة.',C2:'استخدم دليل السياق لاختيار الكلمة الأدق.'})[code]||'استخدم الأدلة للإجابة.')
 ];
 extras.unshift({key:'trace-extra',label:'Trace & Write · تتبّع واكتب',node:traceNode});
 return extras;
}
function mfkjInstallCourseLevelMenu(code){
 if(!root||code==='A1')return;
 var wrap=root.querySelector('.mfkr-page .mfkr-wrap');if(!wrap)return;
 var direct=function(selector){return Array.from(wrap.children).filter(function(node){return node.matches(selector);});};
 var first=function(selector,index){return direct(selector)[index||0]||null;};
 var idPanel=function(id,selector){var el=wrap.querySelector('#'+id);if(!el)return null;var panel=el.closest(selector||'.mfkr-quiz-panel');return panel&&panel.parentElement===wrap?panel:null;};
 var topicPanels=direct('.mfkr-topic-panel');
 var extras=mfkjCreateCourseExtraActivities(code,wrap);
 var one=function(list){return list.filter(Boolean);};
 var commonNote=first('.mfkr-note');
 var groups=[];
 if(code==='A2'){
  groups=[
   {key:'vocab',label:'Explore by topic · اكتشف الكلمات',nodes:one([first('.mfkr-summary.mfkr-a2-summary'),topicPanels[0],first('#mfkrA2WordGrid'),first('#mfkrA2AudioStatus')])},
   {key:'story',label:'Reading Corner · ركن القراءة',nodes:one([first('.mfkr-a2-story')])},
   {key:'builder',label:'Sentence Builder · تكوين الجمل',nodes:one([first('.mfkr-a2-builder')])},
   {key:'matching',label:'Listen & Match · الاستماع والمطابقة',nodes:one([first('.mfkr-a2-matching')])},
   {key:'challenge',label:'Word Challenge · تحدّي الكلمات',nodes:one([first('.mfkr-a2-challenge')])},
   {key:'grammar',label:'Grammar in Everyday Life · القواعد',nodes:one([first('.mfkr-a2-grammar-panel')])},
   {key:'writing',label:'My School-Day Paragraph · الكتابة',nodes:one([first('.mfkr-a2-writing-panel')])},
   {key:'progress',label:'Your learning journey · تقدّمي',nodes:one([first('.mfkr-a2-progress-panel'),commonNote])}
  ];
 }else if(code==='B1'){
  groups=[
   {key:'words',label:'My First Words · الكلمات الأولى',nodes:one([first('.mfkr-summary'),topicPanels[0],first('#mfkrB1WordGrid'),first('#mfkrB1AudioStatus'),commonNote])},
   {key:'challenge',label:'Word Challenge · تحدّي الكلمات',nodes:one([first('.mfkr-quiz-panel')])}
  ];
 }else if(code==='B2'){
  groups=[
   {key:'reading',label:'Read, Listen & Understand · القراءة',nodes:one([first('.mfkr-summary.mfkr-a2-summary'),topicPanels.filter(function(n){return !n.classList.contains('mfkr-b2-summary-panel')&&!n.classList.contains('mfkr-a2-progress-panel');})[0]])},
   {key:'vocab',label:'Words that build meaning · المفردات',nodes:one([topicPanels.filter(function(n){return !n.classList.contains('mfkr-b2-summary-panel')&&!n.classList.contains('mfkr-a2-progress-panel');})[1],first('#mfkrB2WordGrid'),first('#mfkrB2AudioStatus')])},
   {key:'sequence',label:'Story Sequence · ترتيب القصة',nodes:one([idPanel('mfkrB2Sequence')])},
   {key:'connectors',label:'Connector Lab · ربط الأفكار',nodes:one([idPanel('mfkrB2Connectors')])},
   {key:'challenge',label:'Reading Challenge · تحدّي القراءة',nodes:one([idPanel('mfkrB2Quiz')])},
   {key:'summary',label:'Reading Detective · كتابة الملخص',nodes:one([first('.mfkr-b2-summary-panel')])},
   {key:'progress',label:'Your reading journey · تقدّمي',nodes:one([first('.mfkr-a2-progress-panel'),commonNote])}
  ];
 }else if(code==='C1'){
  var storyShelf=topicPanels.find(function(n){return !n.classList.contains('mfkr-c1-story-panel')&&!n.classList.contains('mfkr-a2-progress-panel');});
  groups=[
   {key:'story',label:'Mia and the Flower · القصة الأولى',nodes:one([first('.mfkr-summary'),first('.mfkr-c1-story-panel')])},
   {key:'stories',label:'Five More Little Stories · رف القصص',nodes:one([storyShelf])},
   {key:'builder',label:'Sentence Builder · تكوين الجمل',nodes:one([first('.mfkr-c1-builder-panel')])},
   {key:'words',label:'Words make sentences · كلمات الجمل',nodes:one([first('.mfkr-c1-vocab-heading'),first('#mfkrC1WordGrid'),first('#mfkrC1AudioStatus'),commonNote])},
   {key:'grammar',label:'Grammar Garden · حديقة القواعد',nodes:one([idPanel('mfkrC1Grammar')])},
   {key:'challenge',label:'Story Challenge · تحدّي القصة',nodes:one([idPanel('mfkrC1Quiz')])}
  ];
 }else if(code==='C2'){
  var mainTopics=topicPanels.filter(function(n){return !n.classList.contains('mfkr-a2-progress-panel');});
  groups=[
   {key:'reading',label:'Read Beyond the Words · القراءة المتقدمة',nodes:one([first('.mfkr-summary.mfkr-a2-summary'),mainTopics[0]])},
   {key:'vocab',label:'Words for Better Ideas · المفردات المتقدمة',nodes:one([mainTopics[1],first('#mfkrC2WordGrid'),first('#mfkrC2AudioStatus')])},
   {key:'inference',label:'Think Like a Reader · الفهم والاستنتاج',nodes:one([idPanel('mfkrC2Inference')])},
   {key:'connectors',label:'Connector & Grammar Lab · القواعد والربط',nodes:one([idPanel('mfkrC2Connectors')])},
   {key:'speaking-practice',label:'Speaking Studio · مواقف التواصل',nodes:one([idPanel('mfkrC2Speaking')])},
   {key:'writing',label:'Build a Strong Paragraph · ورشة الكتابة',nodes:one([first('.mfkr-c2-writing')])},
   {key:'progress',label:'Your C2 Journey · تقدّمي',nodes:one([first('.mfkr-a2-progress-panel'),commonNote])}
  ];
 }else return;
 extras.forEach(function(extra){groups.push({key:extra.key,label:extra.label,nodes:[extra.node]});});
 groups=groups.map(function(group){group.nodes=group.nodes.filter(function(node,index,all){return node&&node.parentElement===wrap&&all.indexOf(node)===index;});return group;}).filter(function(group){return group.nodes.length;});
 if(!groups.length)return;
 var used=new Set();
 groups.forEach(function(group){
  group.nodes=group.nodes.filter(function(node){if(used.has(node))return false;used.add(node);return true;});
  var panel=document.createElement('section');panel.className='mfkj-a1-panel';panel.setAttribute('data-mfkj-a1-panel',group.key);
  panel.hidden=true;panel.setAttribute('aria-label',group.label);
  group.nodes.forEach(function(node){panel.appendChild(node);});
  var back=wrap.querySelector('.mfkr-back-row');wrap.insertBefore(panel,back||null);
 });
 root.classList.add('mfkj-a1-workspace');
 window.__mfkjA1ActivePanel=groups[0].key;
 root.querySelectorAll('[data-mfkj-a1-panel]').forEach(function(panel){panel.hidden=panel.getAttribute('data-mfkj-a1-panel')!==window.__mfkjA1ActivePanel;});
 var levelTitles={A2:'Word Explorers',B1:'My First Words',B2:'Reading Builders',C1:'My First Sentences',C2:'Confident English'};
 var trigger=document.createElement('button');trigger.type='button';trigger.id='mfkjA1MenuTrigger';trigger.className='mfkj-a1-menu-trigger';
 trigger.setAttribute('aria-label','فتح قائمة الدروس والأنشطة');trigger.setAttribute('aria-controls','mfkjA1LessonMenu');trigger.setAttribute('aria-expanded','false');
 trigger.innerHTML='<span aria-hidden="true">☰</span><span>القائمة</span>';trigger.addEventListener('click',mfkjA1OpenLessonMenu);root.appendChild(trigger);
 var groupButtons=groups.map(function(group){return '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="'+group.key+'"><span aria-hidden="true">'+({'vocab':'🔤','words':'🧸','reading':'📚','story':'🌷','stories':'📖','builder':'🧩','matching':'🎧','challenge':'🏆','grammar':'✏️','writing':'📝','progress':'⭐','sequence':'🔢','connectors':'🔗','summary':'🧠','inference':'🔎','speaking-practice':'💬','trace-extra':'✍️','visual-extra':'🖼️','listen-extra':'🎧','detective-extra':'🔍'}[group.key]||'✦')+'</span><span>'+group.label+'</span></button>';}).join('');
 var overlay=document.createElement('div');overlay.id='mfkjA1LessonMenu';overlay.className='mfkj-a1-overlay';overlay.hidden=true;overlay.setAttribute('aria-hidden','true');
 overlay.innerHTML='<aside class="mfkj-a1-dialog" role="dialog" aria-modal="true" aria-label="قائمة دروس وأنشطة المستوى">'+
 '<header class="mfkj-a1-dialog-head"><div><span class="mfkj-a1-kicker">MR. FLUENT KIDS · LEVEL '+code+'</span><h2>'+levelTitles[code]+'</h2></div><button type="button" class="mfkj-a1-close" data-mfkj-a1-menu-close>إغلاق القائمة</button></header>'+
 '<nav class="mfkj-a1-menu-list" aria-label="دروس وأنشطة المستوى"><div class="mfkj-a1-menu-group">دروس وأنشطة المستوى</div>'+groupButtons+
 '<div class="mfkj-a1-menu-group">Learning Lab · مساحة التعلّم</div>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=lab&amp;kidsTab=overview"><span aria-hidden="true">🌱</span><span>Learning Lab · البداية</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=lab&amp;kidsTab=missions"><span aria-hidden="true">🏡</span><span>Home Missions · مهمات البيت</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=lab&amp;kidsTab=maker"><span aria-hidden="true">🧩</span><span>Maker Projects · مشروعات عملية</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=review"><span aria-hidden="true">🧠</span><span>Smart Review · مراجعة ذكية</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=lab&amp;kidsTab=writing"><span aria-hidden="true">✍️</span><span>Writing Studio · تدريب الكتابة</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=lab&amp;kidsTab=portfolio"><span aria-hidden="true">📒</span><span>Achievement Portfolio · ملف الإنجاز</span></a>'+
 '<div class="mfkj-a1-menu-group">أدوات المستوى</div>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="speaking"><span aria-hidden="true">💬</span><span>Speaking Studio</span></button>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="final"><span aria-hidden="true">🏆</span><span>Final Challenge</span></button>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="certificate"><span aria-hidden="true">🎓</span><span>Level Certificate</span></button>'+
 '<button type="button" class="mfkj-a1-menu-item" data-mfkj-a1-target="review"><span aria-hidden="true">🧠</span><span>My Review · مراجعة أخطائي</span></button>'+
 '<div class="mfkj-a1-menu-group">الخريطة والمتابعة</div>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=map"><span aria-hidden="true">🗺️</span><span>Curriculum Map · خريطة المنهج</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=parents"><span aria-hidden="true">👪</span><span>Parent Overview · متابعة ولي الأمر</span></a>'+
 '<div class="mfkj-a1-menu-group">التنقّل</div>'+
 '<a class="mfkj-a1-menu-item" href="./?kids=hub"><span aria-hidden="true">↩</span><span>الرجوع للمستويات</span></a>'+
 '<a class="mfkj-a1-menu-item" href="./"><span aria-hidden="true">✦</span><span>DOMA Academy</span></a></nav></aside>';
 overlay.addEventListener('click',function(event){
  if(event.target===overlay){mfkjA1CloseLessonMenu();return;}
  if(event.target.closest('[data-mfkj-a1-menu-close]')){mfkjA1CloseLessonMenu();return;}
  var item=event.target.closest('[data-mfkj-a1-target]');if(item)mfkjA1SelectLessonPanel(item.getAttribute('data-mfkj-a1-target'));
 });
 root.appendChild(overlay);
 if(window.__mfkjA1MenuKeyHandler)document.removeEventListener('keydown',window.__mfkjA1MenuKeyHandler);
 window.__mfkjA1MenuKeyHandler=function(event){var menu=root.querySelector('#mfkjA1LessonMenu');if(event.key==='Escape'&&menu&&!menu.hidden)mfkjA1CloseLessonMenu();};
 document.addEventListener('keydown',window.__mfkjA1MenuKeyHandler);
}

function renderAlphabet(){document.title='A1 — My First ABC | Mr. Fluent Kids';var cards=L.map(function(item){var cap=item[0],small=item[1],word=item[2],meaning=item[3],picture=item[4];return '<article class="mfkr-letter-card" aria-label="Letter '+cap+', '+esc(word)+'"><div class="mfkr-letter-head"><div class="mfkr-letter-forms"><span>'+cap+'</span> <span>'+small+'</span></div><span class="mfkr-picture" aria-hidden="true">'+picture+'</span></div><div class="mfkr-word" lang="en">'+esc(word)+'</div><div class="mfkr-meaning" lang="ar">'+esc(meaning)+'</div><div class="mfkr-sounds"><button class="mfkr-sound" type="button" data-kids-speak="'+esc(cap)+'" data-label="letter '+cap+'"><span aria-hidden="true">🔊</span> صوت الحرف</button><button class="mfkr-sound" type="button" data-kids-speak="'+esc(word)+'" data-label="'+esc(word)+'"><span aria-hidden="true">♫</span> صوت الكلمة</button></div></article>';}).join('');root.innerHTML=shell('LITTLE LEARNERS · LEVEL A1','My First ABC.','اتعلّم الحروف من A إلى Z.','كل كارت فيه الحرف الكبير والصغير، وصورة وكلمة بالإنجليزي، ومعناها بالعربي، وزرين لسماع النطق.','<div class="mfkr-summary"><span>26 letters</span><div class="mfkr-progress"><span></span></div><span>Letter · Picture · Word · Sound</span></div><div class="mfkr-alpha-grid" id="mfkrAlphabetGrid">'+cards+'</div><div class="mfkr-audio-status" id="mfkrAudioStatus" aria-live="polite">اضغط على علامة الصوت لسماع نطق الحرف أو الكلمة.</div><section class="mfkr-topic-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">LETTER PRACTICE · تدريب الحروف</div><h2>Trace the Letter</h2><div class="mfkr-c1-story-title-ar" lang="ar">تتبّع شكل الحرف بإصبعك على الشاشة أو بالماوس.</div></div><span class="mfkr-art" aria-hidden="true">✍️</span></div><div style="display:flex;justify-content:center;align-items:center;padding:10px 0"><canvas id="mfkrLetterTraceCanvas" width="600" height="280" aria-label="Trace the displayed English letter" style="display:block;width:100%;max-width:430px;height:auto;aspect-ratio:15/7;touch-action:none;border:1px solid rgba(206,164,255,.2);border-radius:18px;background:rgba(12,8,18,.35)"></canvas></div><div class="mfkr-c1-actions"><button type="button" class="mfkr-btn" data-a1-trace-prev>← الحرف السابق</button><strong id="mfkrA1TraceLetter" style="color:#ff9dd4;font-size:20px">A</strong><button type="button" class="mfkr-btn" data-a1-trace-next>الحرف التالي →</button><button type="button" class="mfkr-btn" data-a1-trace-clear>أعد المحاولة</button></div><p class="mfkr-quiz-feedback" id="mfkrA1TraceFeedback" lang="ar" aria-live="polite">اتبع الخط المنقّط ببطء، ثم جرّب الحرف التالي.</p></section><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">SOUND DETECTIVE · اكتشف الصوت الأول</div><h2>Which Letter Starts the Word?</h2><p lang="ar">اقرأ الكلمة واختر الحرف الذي تبدأ به. أجب عن 5 أسئلة لتكمل تدريب الأصوات.</p></div><div id="mfkrA1SoundChallenge"></div></section><section class="mfkr-quiz-panel mfkr-a1-activity-panel" id="mfkrA1LookQuiz"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">LOOK &amp; CHOOSE · اختار اسم الصورة</div><h2>What is in the picture?</h2><p lang="ar">شوف الصورة واختار اسمها الصحيح من 3 اختيارات. العب براحتك، الأسئلة مبتخلصش.</p></div><div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">PICTURE WORDS</span><span id="mfkrA1LookCount" class="mfkr-quiz-count">Question 1 · Unlimited</span><span id="mfkrA1LookScore" class="mfkr-quiz-score">Score: 0</span></div><div id="mfkrA1LookStage"></div><p class="mfkr-quiz-feedback" id="mfkrA1LookFeedback" lang="ar" aria-live="polite">اختار الكلمة اللي بتوصف الصورة.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-a1-look-next disabled>السؤال التالي ←</button></div></section><section class="mfkr-quiz-panel mfkr-a1-activity-panel" id="mfkrA1ListenQuiz"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">LISTEN &amp; CHOOSE · اسمع واختار</div><h2>Listen. Look. Choose!</h2><p lang="ar">اسمع اسم الكلمة بالإنجليزي، وبعدين اختار الصورة الصحيحة. أسماء الصور مش ظاهرة قبل إجابتك، والأسئلة مستمرة من غير حد.</p></div><div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">LISTENING GAME</span><span id="mfkrA1ListenCount" class="mfkr-quiz-count">Question 1 · Unlimited</span><span id="mfkrA1ListenScore" class="mfkr-quiz-score">Score: 0</span></div><div class="mfkr-a1-listen-prompt"><div><strong>What can you hear?</strong><small lang="ar" dir="rtl">اضغط على زر الصوت واسمع كويس.</small></div><button type="button" class="mfkr-btn mfkr-btn-primary" id="mfkrA1ListenPlay">🔊 Play the word</button></div><div id="mfkrA1ListenStage" class="mfkr-a1-picture-options mfkr-a1-image-options" aria-label="Choose the picture you hear"></div><p class="mfkr-quiz-feedback" id="mfkrA1ListenFeedback" lang="ar" aria-live="polite">اسمع الكلمة، وبعدها اختار صورة من التلاتة.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-a1-listen-next disabled>السؤال التالي ←</button></div></section>'+backButtons(url('younger'),'← Back to levels'));var grid=root.querySelector('#mfkrAlphabetGrid');var status=root.querySelector('#mfkrAudioStatus');grid.addEventListener('click',function(event){var button=event.target.closest('button[data-kids-speak]');if(!button)return;var value=button.getAttribute('data-kids-speak');if(!('speechSynthesis' in window)||!('SpeechSynthesisUtterance' in window)){status.textContent='ميزة النطق غير مدعومة في هذا المتصفح. جرّب متصفحًا حديثًا.';return;}window.speechSynthesis.cancel();var speech=new SpeechSynthesisUtterance(value);mfkrSelectEnglishVoice(speech);speech.lang='en-US';speech.rate=.78;speech.pitch=1.02;speech.onstart=function(){status.textContent='Now speaking: '+button.getAttribute('data-label');};speech.onend=function(){status.textContent='اضغط على علامة الصوت لسماع نطق الحرف أو الكلمة.';};speech.onerror=function(){status.textContent='تعذّر تشغيل الصوت. جرّب الضغط مرة أخرى.';};window.speechSynthesis.speak(speech);});
var traceIndex=0,traceLetters=L.map(function(item){return item[0];}),traceCanvas=root.querySelector('#mfkrLetterTraceCanvas'),traceLabel=root.querySelector('#mfkrA1TraceLetter'),traceFeedback=root.querySelector('#mfkrA1TraceFeedback'),traceDrawing=false,traceDistance=0,traceLastPoint=null;
function drawTraceLetter(){if(!traceCanvas)return;var ctx=traceCanvas.getContext('2d');if(!ctx)return;ctx.clearRect(0,0,traceCanvas.width,traceCanvas.height);ctx.textAlign='center';ctx.textBaseline='middle';ctx.font='900 182px Arial, sans-serif';ctx.lineWidth=4;ctx.strokeStyle='rgba(255,157,212,.95)';ctx.setLineDash([10,10]);ctx.strokeText(traceLetters[traceIndex],300,130);ctx.setLineDash([]);ctx.fillStyle='rgba(210,192,229,.86)';ctx.font='600 22px Arial, sans-serif';ctx.fillText('Trace the letter '+traceLetters[traceIndex],300,240);if(traceLabel)traceLabel.textContent=traceLetters[traceIndex];if(traceFeedback)traceFeedback.textContent='اتبع الخط المنقّط ببطء، ثم جرّب الحرف التالي.';}
function tracePoint(event){var rect=traceCanvas.getBoundingClientRect();return{x:(event.clientX-rect.left)*(traceCanvas.width/rect.width),y:(event.clientY-rect.top)*(traceCanvas.height/rect.height)};}
function shuffleA1(list){var result=list.slice();for(var i=result.length-1;i>0;i--){var j=Math.floor(Math.random()*(i+1)),tmp=result[i];result[i]=result[j];result[j]=tmp;}return result;}
var a1SoundTargets=shuffleA1(L).slice(0,5),a1SoundIndex=0,a1SoundScore=0,a1SoundAnswered=false;
function drawFirstSound(){var host=root.querySelector('#mfkrA1SoundChallenge');if(!host)return;if(a1SoundIndex>=a1SoundTargets.length){host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🔤</div><h3>Sound Detective complete!</h3><p lang="ar">نتيجتك: '+a1SoundScore+' من '+a1SoundTargets.length+'. '+(a1SoundScore>=4?'رائع! أتقنت معظم الأصوات الأولى.':'تدرّب على نطق الكلمات ثم حاول مرة أخرى.')+'</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-a1-sound-restart>ابدأ التحدّي من جديد ↻</button></div>';if(a1SoundScore>=4&&typeof journeyRecord==='function')journeyRecord('checkpoint:a1-first-sounds',null,'A1');return;}var target=a1SoundTargets[a1SoundIndex],options=shuffleA1(L.map(function(item){return item[0];}).filter(function(cap){return cap!==target[0];})).slice(0,3);options.push(target[0]);options=shuffleA1(options);host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">FIRST SOUND</span><span class="mfkr-quiz-count">Question '+(a1SoundIndex+1)+' / '+a1SoundTargets.length+'</span><span class="mfkr-quiz-score">Score: '+a1SoundScore+'</span></div><div style="display:flex;align-items:center;justify-content:center;gap:14px;margin:16px 0"><span class="mfkr-art" aria-hidden="true" style="font-size:34px">'+target[4]+'</span><h3 lang="en">Which letter starts <strong>'+esc(target[2])+'</strong>?</h3></div><div class="mfkr-quiz-options">'+options.map(function(cap){return '<button type="button" class="mfkr-quiz-option" data-a1-sound-option="'+cap+'">'+cap+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrA1SoundFeedback" lang="ar" aria-live="polite">فكّر في الصوت الأول للكلمة، وليس اسم الحرف فقط.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-a1-sound-next disabled>السؤال التالي ←</button></div>';}
if(traceCanvas){var traceCtx=traceCanvas.getContext('2d');drawTraceLetter();traceCanvas.addEventListener('pointerdown',function(event){traceDrawing=true;traceDistance=0;traceLastPoint=tracePoint(event);traceCtx.beginPath();traceCtx.moveTo(traceLastPoint.x,traceLastPoint.y);if(traceCanvas.setPointerCapture)traceCanvas.setPointerCapture(event.pointerId);event.preventDefault();});traceCanvas.addEventListener('pointermove',function(event){if(!traceDrawing)return;var p=tracePoint(event),dx=p.x-traceLastPoint.x,dy=p.y-traceLastPoint.y;traceDistance+=Math.sqrt(dx*dx+dy*dy);traceCtx.lineWidth=13;traceCtx.lineCap='round';traceCtx.lineJoin='round';traceCtx.strokeStyle='#93f0d6';traceCtx.lineTo(p.x,p.y);traceCtx.stroke();traceLastPoint=p;event.preventDefault();});traceCanvas.addEventListener('pointerup',function(){traceDrawing=false;if(traceDistance>40){if(traceFeedback)traceFeedback.textContent='أحسنت! جرّبت رسم الحرف '+traceLetters[traceIndex]+'. انتقل للحرف التالي أو أعد المحاولة.';if(typeof journeyRecord==='function')journeyRecord('activity:a1-letter-tracing',null,'A1');}else if(traceFeedback)traceFeedback.textContent='حاول تتبّع جزء أكبر من الحرف المنقّط، بهدوء.';});traceCanvas.addEventListener('pointercancel',function(){traceDrawing=false;});}
root.addEventListener('click',function(event){var traceNext=event.target.closest('[data-a1-trace-next]'),tracePrev=event.target.closest('[data-a1-trace-prev]');if(traceNext||tracePrev){traceIndex=(traceIndex+(traceNext?1:traceLetters.length-1))%traceLetters.length;drawTraceLetter();return;}if(event.target.closest('[data-a1-trace-clear]')){drawTraceLetter();return;}var soundOption=event.target.closest('[data-a1-sound-option]');if(soundOption&&!a1SoundAnswered&&a1SoundIndex<a1SoundTargets.length){var target=a1SoundTargets[a1SoundIndex],correct=soundOption.getAttribute('data-a1-sound-option')===target[0];a1SoundAnswered=true;if(correct)a1SoundScore++;root.querySelectorAll('[data-a1-sound-option]').forEach(function(button){button.disabled=true;if(button.getAttribute('data-a1-sound-option')===target[0])button.classList.add('is-correct');else if(button===soundOption&&!correct)button.classList.add('is-wrong');});var feedback=root.querySelector('#mfkrA1SoundFeedback');if(feedback){feedback.textContent=correct?'ممتاز! '+target[2]+' تبدأ بصوت الحرف '+target[0]+'.':'الإجابة الصحيحة: '+target[0]+' مثل '+target[2]+'.';feedback.classList.toggle('is-right',correct);feedback.classList.toggle('is-wrong',!correct);}var score=root.querySelector('#mfkrA1SoundChallenge .mfkr-quiz-score');if(score)score.textContent='Score: '+a1SoundScore;var next=root.querySelector('[data-a1-sound-next]');if(next)next.disabled=false;return;}if(event.target.closest('[data-a1-sound-next]')){if(!a1SoundAnswered)return;a1SoundIndex++;a1SoundAnswered=false;drawFirstSound();return;}if(event.target.closest('[data-a1-sound-restart]')){a1SoundTargets=shuffleA1(L).slice(0,5);a1SoundIndex=0;a1SoundScore=0;a1SoundAnswered=false;drawFirstSound();return;}});
drawFirstSound();

var mfkrLookDeck=[],mfkrLookIndex=0,mfkrLookScore=0,mfkrLookAnswered=false;
var mfkrListenDeck=[],mfkrListenIndex=0,mfkrListenScore=0,mfkrListenAnswered=false;
var mfkrLookStage=root.querySelector('#mfkrA1LookStage'),mfkrLookCount=root.querySelector('#mfkrA1LookCount'),mfkrLookScoreNode=root.querySelector('#mfkrA1LookScore'),mfkrLookFeedback=root.querySelector('#mfkrA1LookFeedback');
var mfkrListenStage=root.querySelector('#mfkrA1ListenStage'),mfkrListenCount=root.querySelector('#mfkrA1ListenCount'),mfkrListenScoreNode=root.querySelector('#mfkrA1ListenScore'),mfkrListenFeedback=root.querySelector('#mfkrA1ListenFeedback'),mfkrListenPlay=root.querySelector('#mfkrA1ListenPlay');
function mfkrA1WordPool(){return L.filter(function(item){return item&&item[2]&&item[3]&&item[4];});}
function mfkrA1PictureMarkup(item){return '<span class="mfkr-a1-choice-picture" aria-hidden="true">'+item[4]+'</span>';}
function mfkrA1Audio(word){if(!('speechSynthesis' in window)||!('SpeechSynthesisUtterance' in window)){if(mfkrListenFeedback)mfkrListenFeedback.textContent='الصوت مش مدعوم في المتصفح ده. جرّب Chrome أو Edge محدث، وتقدر تكمل باقي النشاط.';return;}try{window.speechSynthesis.cancel();var utterance=new SpeechSynthesisUtterance(word);if(typeof mfkrSelectEnglishVoice==='function')mfkrSelectEnglishVoice(utterance);utterance.lang='en-US';utterance.rate=.76;utterance.pitch=1.02;utterance.onerror=function(){if(mfkrListenFeedback)mfkrListenFeedback.textContent='تعذّر تشغيل الصوت. اضغط Play the word وجرب تاني.';};window.speechSynthesis.speak(utterance);}catch(_){if(mfkrListenFeedback)mfkrListenFeedback.textContent='تعذّر تشغيل الصوت. جرّب الضغط مرة تانية.';}}
function mfkrA1FinishMarkup(score,total,title,message,icon,restartAttr){return '<div class="mfkr-a1-game-finish"><span class="mfkr-a1-game-trophy" aria-hidden="true">'+icon+'</span><div class="mfkr-mini-eyebrow">ACTIVITY COMPLETE</div><h3>'+title+'</h3><strong class="mfkr-a1-game-result">'+score+' / '+total+'</strong><p lang="ar">'+message+'</p><button type="button" class="mfkr-btn mfkr-btn-primary" '+restartAttr+'>↻ العب من جديد</button></div>';}
function mfkrA1DrawLook(){
 if(!mfkrLookStage)return;mfkrLookAnswered=false;var pool=mfkrA1WordPool();if(!pool.length){mfkrLookStage.textContent='لا توجد كلمات متاحة الآن.';return;}if(!mfkrLookDeck.length)mfkrLookDeck=shuffleA1(pool);
 if(mfkrLookIndex>0&&mfkrLookIndex%mfkrLookDeck.length===0){var previous=mfkrLookDeck[mfkrLookDeck.length-1][0];mfkrLookDeck=shuffleA1(pool);if(mfkrLookDeck.length>1&&mfkrLookDeck[0][0]===previous){var swap=mfkrLookDeck[0];mfkrLookDeck[0]=mfkrLookDeck[1];mfkrLookDeck[1]=swap;}}
 var pos=mfkrLookIndex%mfkrLookDeck.length,next=root.querySelector('[data-a1-look-next]');if(next){next.disabled=true;next.hidden=false;next.textContent='السؤال التالي ←';}var current=mfkrLookDeck[pos],choices=shuffleA1([current].concat(shuffleA1(pool.filter(function(item){return item[0]!==current[0];})).slice(0,2)));
 mfkrLookCount.textContent='Question '+(mfkrLookIndex+1)+' · Unlimited';mfkrLookScoreNode.textContent='Score: '+mfkrLookScore;mfkrLookFeedback.textContent='اختار اسم الصورة الصحيح.';
 mfkrLookStage.innerHTML='<div class="mfkr-a1-look-question"><div class="mfkr-a1-big-picture" role="img" aria-label="Picture to identify">'+current[4]+'</div><div class="mfkr-a1-look-question-copy"><strong>What is it?</strong><small lang="ar" dir="rtl">اختار الكلمة اللي بتوصف الصورة.</small></div></div><div class="mfkr-quiz-options mfkr-a1-word-options">'+choices.map(function(item,i){return '<button type="button" class="mfkr-quiz-option mfkr-a1-word-option" data-a1-look-answer="'+esc(item[0])+'"><span class="mfkr-a1-answer-letter">'+String.fromCharCode(65+i)+'</span><span>'+esc(item[2])+'</span></button>';}).join('')+'</div>';
}
function mfkrA1DrawListen(){
 if(!mfkrListenStage)return;mfkrListenAnswered=false;var pool=mfkrA1WordPool();if(!pool.length){mfkrListenStage.textContent='لا توجد كلمات متاحة الآن.';return;}if(!mfkrListenDeck.length)mfkrListenDeck=shuffleA1(pool);
 if(mfkrListenIndex>0&&mfkrListenIndex%mfkrListenDeck.length===0){var previous=mfkrListenDeck[mfkrListenDeck.length-1][0];mfkrListenDeck=shuffleA1(pool);if(mfkrListenDeck.length>1&&mfkrListenDeck[0][0]===previous){var swap=mfkrListenDeck[0];mfkrListenDeck[0]=mfkrListenDeck[1];mfkrListenDeck[1]=swap;}}
 var pos=mfkrListenIndex%mfkrListenDeck.length,next=root.querySelector('[data-a1-listen-next]');if(next){next.disabled=true;next.hidden=false;next.textContent='السؤال التالي ←';}if(mfkrListenPlay)mfkrListenPlay.disabled=false;var current=mfkrListenDeck[pos],choices=shuffleA1([current].concat(shuffleA1(pool.filter(function(item){return item[0]!==current[0];})).slice(0,2)));
 mfkrListenCount.textContent='Question '+(mfkrListenIndex+1)+' · Unlimited';mfkrListenScoreNode.textContent='Score: '+mfkrListenScore;mfkrListenFeedback.textContent='اضغط زر الصوت وبعدين اختار الصورة اللي سمعت اسمها.';
 mfkrListenStage.innerHTML=choices.map(function(item,i){return '<button type="button" class="mfkr-a1-image-option" data-a1-listen-answer="'+esc(item[0])+'" aria-label="Picture option '+String.fromCharCode(65+i)+'"><span class="mfkr-a1-answer-letter">'+String.fromCharCode(65+i)+'</span><span class="mfkr-a1-image-tile" role="img" aria-label="Illustration '+String.fromCharCode(65+i)+'">'+item[4]+'</span><span class="mfkr-a1-image-reveal">'+esc(item[2])+'<small lang="ar" dir="rtl">'+esc(item[3])+'</small></span></button>';}).join('');
}
function mfkrA1StartLook(){mfkrLookDeck=shuffleA1(mfkrA1WordPool());mfkrLookIndex=0;mfkrLookScore=0;mfkrA1DrawLook();}
function mfkrA1StartListen(){if('speechSynthesis' in window)window.speechSynthesis.cancel();mfkrListenDeck=shuffleA1(mfkrA1WordPool());mfkrListenIndex=0;mfkrListenScore=0;if(mfkrListenPlay)mfkrListenPlay.hidden=false;mfkrA1DrawListen();}
if(mfkrLookStage){mfkrLookStage.addEventListener('click',function(event){if(event.target.closest('[data-a1-look-restart]')){mfkrA1StartLook();return;}var button=event.target.closest('[data-a1-look-answer]');if(!button||mfkrLookAnswered||button.disabled)return;var current=mfkrLookDeck[mfkrLookIndex];if(button.getAttribute('data-a1-look-answer')!==current[0]){button.classList.add('is-wrong');button.disabled=true;mfkrLookFeedback.textContent='مش دي الصورة، جرّب اختيار تاني 😊';return;}mfkrLookAnswered=true;mfkrLookScore++;mfkrLookStage.querySelectorAll('[data-a1-look-answer]').forEach(function(option){option.disabled=true;if(option.getAttribute('data-a1-look-answer')===current[0])option.classList.add('is-correct');});mfkrLookScoreNode.textContent='Score: '+mfkrLookScore;mfkrLookFeedback.textContent='ممتاز! '+current[2]+' معناها '+current[3]+'.';var next=root.querySelector('[data-a1-look-next]');if(next)next.disabled=false;});}
if(mfkrListenStage){mfkrListenStage.addEventListener('click',function(event){if(event.target.closest('[data-a1-listen-restart]')){mfkrA1StartListen();return;}var button=event.target.closest('[data-a1-listen-answer]');if(!button||mfkrListenAnswered||button.disabled)return;var current=mfkrListenDeck[mfkrListenIndex];if(button.getAttribute('data-a1-listen-answer')!==current[0]){button.classList.add('is-wrong');button.disabled=true;mfkrListenFeedback.textContent='مش هي الكلمة اللي سمعتها. شغّل الصوت تاني وجرب صورة تانية.';return;}mfkrListenAnswered=true;mfkrListenScore++;mfkrListenStage.querySelectorAll('[data-a1-listen-answer]').forEach(function(option){option.disabled=true;if(option.getAttribute('data-a1-listen-answer')===current[0])option.classList.add('is-correct');});mfkrListenScoreNode.textContent='Score: '+mfkrListenScore;mfkrListenFeedback.textContent='ممتاز! '+current[2]+' معناها '+current[3]+'.';var next=root.querySelector('[data-a1-listen-next]');if(next)next.disabled=false;var speakAgain=root.querySelector('#mfkrA1ListenPlay');if(speakAgain)speakAgain.disabled=true;});}
var mfkrLookNext=root.querySelector('[data-a1-look-next]');if(mfkrLookNext)mfkrLookNext.addEventListener('click',function(){if(!mfkrLookAnswered)return;mfkrLookIndex++;mfkrA1DrawLook();});
var mfkrListenNext=root.querySelector('[data-a1-listen-next]');if(mfkrListenNext)mfkrListenNext.addEventListener('click',function(){if(!mfkrListenAnswered)return;mfkrListenIndex++;mfkrA1DrawListen();});
if(mfkrListenPlay)mfkrListenPlay.addEventListener('click',function(){var current=mfkrListenDeck[mfkrListenIndex];if(!current)return;mfkrA1Audio(current[2]);mfkrListenFeedback.textContent='اسمع الكلمة كويس، وبعدها اختار الصورة الصح.';});
mfkrA1StartLook();mfkrA1StartListen();
mfkjA1InstallLessonMenu();

}

function renderA2(){
  document.title='A2 — Word Explorers | Mr. Fluent Kids';
  var vocab=[
    {word:'timetable',meaning:'جدول الحصص',picture:'🗓️',category:'school',example:'I check my timetable.',sentence:'أراجع جدول حصصي.'},
    {word:'subject',meaning:'مادة دراسية',picture:'📘',category:'school',example:'Science is my favourite subject.',sentence:'العلوم مادتي المفضلة.'},
    {word:'homework',meaning:'واجب منزلي',picture:'✏️',category:'school',example:'I finish my homework after school.',sentence:'أنهي واجبي بعد المدرسة.'},
    {word:'library',meaning:'مكتبة',picture:'📚',category:'school',example:'I read quietly in the library.',sentence:'أقرأ بهدوء في المكتبة.'},
    {word:'borrow',meaning:'يستعير',picture:'🤝',category:'school',example:'Can I borrow your pencil?',sentence:'هل يمكنني استعارة قلمك؟'},
    {word:'explain',meaning:'يشرح',picture:'💬',category:'school',example:'Please explain the answer.',sentence:'من فضلك اشرح الإجابة.'},
    {word:'wake up',meaning:'يستيقظ',picture:'⏰',category:'routine',example:'I wake up at seven.',sentence:'أستيقظ في السابعة.'},
    {word:'brush',meaning:'يفرّش / ينظّف بالفرشاة',picture:'🪥',category:'routine',example:'I brush my teeth every morning.',sentence:'أنظّف أسناني كل صباح.'},
    {word:'usually',meaning:'عادةً',picture:'🔁',category:'routine',example:'I usually walk to school.',sentence:'أذهب إلى المدرسة سيرًا عادةً.'},
    {word:'early',meaning:'مبكرًا',picture:'🌅',category:'routine',example:'We arrive early for class.',sentence:'نصل مبكرًا إلى الحصة.'},
    {word:'prepare',meaning:'يحضّر / يستعد',picture:'🎒',category:'routine',example:'I prepare my bag at night.',sentence:'أجهّز حقيبتي ليلًا.'},
    {word:'routine',meaning:'روتين يومي',picture:'📋',category:'routine',example:'Reading is part of my routine.',sentence:'القراءة جزء من روتيني اليومي.'},
    {word:'healthy',meaning:'صحيّ',picture:'🥗',category:'hobbies',example:'Fruit is a healthy snack.',sentence:'الفاكهة وجبة خفيفة صحية.'},
    {word:'delicious',meaning:'لذيذ',picture:'😋',category:'hobbies',example:'This soup is delicious.',sentence:'هذا الحساء لذيذ.'},
    {word:'recipe',meaning:'وصفة طعام',picture:'🧾',category:'hobbies',example:'The recipe is easy to follow.',sentence:'اتباع وصفة الطعام سهل.'},
    {word:'collect',meaning:'يجمع',picture:'🪨',category:'hobbies',example:'I collect interesting stones.',sentence:'أجمع أحجارًا مميزة.'},
    {word:'practise',meaning:'يتدرّب / يمارس',picture:'🎸',category:'hobbies',example:'I practise the guitar after dinner.',sentence:'أتدرّب على الجيتار بعد العشاء.'},
    {word:'weekend',meaning:'عطلة نهاية الأسبوع',picture:'🎉',category:'hobbies',example:'We visit our cousins at the weekend.',sentence:'نزور أبناء عمومتنا في عطلة نهاية الأسبوع.'},
    {word:'station',meaning:'محطة',picture:'🚉',category:'places',example:'The bus station is near the market.',sentence:'محطة الحافلات قريبة من السوق.'},
    {word:'market',meaning:'سوق',picture:'🛍️',category:'places',example:'Mum buys fruit at the market.',sentence:'تشتري أمي الفاكهة من السوق.'},
    {word:'museum',meaning:'متحف',picture:'🏛️',category:'places',example:'We learn about history at the museum.',sentence:'نتعلم التاريخ في المتحف.'},
    {word:'straight',meaning:'مستقيمًا / على طول',picture:'➡️',category:'places',example:'Walk straight and turn left.',sentence:'امشِ على طول ثم انعطف يسارًا.'},
    {word:'opposite',meaning:'مقابل',picture:'↔️',category:'places',example:'The café is opposite the park.',sentence:'المقهى مقابل الحديقة.'},
    {word:'between',meaning:'بين',picture:'↕️',category:'places',example:'The bank is between two shops.',sentence:'البنك بين متجرين.'}
  ];
  var topics=[
    ['all','All words','كل الكلمات'],
    ['school','School & Study','المدرسة والمذاكرة'],
    ['routine','Daily Routines','الروتين اليومي'],
    ['hobbies','Food & Hobbies','الطعام والهوايات'],
    ['places','Places Around Us','الأماكن من حولنا']
  ];
  var story=[
    {en:'Sara checks her timetable before school.',ar:'تراجع سارة جدول حصصها قبل المدرسة.'},
    {en:'Her first subject is science, so she packs her notebook.',ar:'مادتها الأولى هي العلوم، لذلك تضع كشكولها في الحقيبة.'},
    {en:'After class, Sara goes to the library to borrow a book.',ar:'بعد الحصة، تذهب سارة إلى المكتبة لاستعارة كتاب.'},
    {en:'She walks past the market on her way home.',ar:'تمرّ بجوار السوق في طريقها إلى المنزل.'},
    {en:'At home, she prepares a healthy snack and finishes her homework.',ar:'في المنزل، تحضّر وجبة خفيفة صحية وتنهي واجبها.'},
    {en:'In the evening, she practises the guitar for twenty minutes.',ar:'في المساء، تتدرّب على الجيتار لمدة عشرين دقيقة.'}
  ];
  var sentences=[
    {answer:['I','usually','wake','up','early.'],ar:'أستيقظ مبكرًا عادةً.'},
    {answer:['Can','I','borrow','your','pencil?'],ar:'هل يمكنني استعارة قلمك؟'},
    {answer:['The','library','is','opposite','the','park.'],ar:'المكتبة مقابل الحديقة.'},
    {answer:['We','prepare','a','healthy','snack.'],ar:'نحضّر وجبة خفيفة صحية.'}
  ];
  var matches=[
    {word:'timetable',meaning:'جدول الحصص'},
    {word:'wake up',meaning:'يستيقظ'},
    {word:'healthy',meaning:'صحيّ'},
    {word:'museum',meaning:'متحف'},
    {word:'borrow',meaning:'يستعير'},
    {word:'between',meaning:'بين'}
  ];
  var quizQuestions=[
    {q:'What does “timetable” mean?',ar:'ما معنى كلمة timetable؟',options:['جدول الحصص','وصفة طعام','محطة'],correct:0},
    {q:'Where does Sara go to borrow a book?',ar:'أين تذهب سارة لاستعارة كتاب؟',options:['The market','The library','The station'],correct:1},
    {q:'Which word means “عادةً”?',ar:'أي كلمة معناها عادةً؟',options:['Usually','Early','Between'],correct:0},
    {q:'What does Sara prepare at home?',ar:'ماذا تحضّر سارة في المنزل؟',options:['A healthy snack','A timetable','A school subject'],correct:0},
    {q:'Choose the correct sentence.',ar:'اختر الجملة الصحيحة.',options:['I usually wake up early.','I early usually up wake.','Wake I usually early up.'],correct:0},
    {q:'What does “opposite” mean?',ar:'ما معنى opposite؟',options:['داخل','خلف','مقابل'],correct:2},
    {q:'How long does Sara practise the guitar?',ar:'كم تستغرق سارة في التدريب على الجيتار؟',options:['Ten minutes','Twenty minutes','One hour'],correct:1},
    {q:'Which word is connected with cooking?',ar:'أي كلمة مرتبطة بالطهي؟',options:['Recipe','Museum','Timetable'],correct:0}
  ];
  var grammarQuestions=[{q:'I ___ my homework after school.',ar:'أنهي واجبي بعد المدرسة.',options:['finish','finishes','finishing'],correct:0,why:'مع I نستخدم الفعل الأساسي: finish.'},{q:'Mona ___ to school early.',ar:'تذهب منى إلى المدرسة مبكرًا.',options:['go','goes','going'],correct:1,why:'مع she نضيف s إلى الفعل في المضارع البسيط.'},{q:'Look! The children ___ in the garden.',ar:'انظر! الأطفال يلعبون في الحديقة الآن.',options:['play','are playing','plays'],correct:1,why:'نستخدم are playing لشيء يحدث الآن مع الجمع.'},{q:'There ___ two books on the desk.',ar:'يوجد كتابان على المكتب.',options:['is','are','be'],correct:1,why:'نستخدم are مع الأسماء في الجمع.'},{q:'Yesterday, we ___ a museum.',ar:'زرنا متحفًا أمس.',options:['visit','visited','visiting'],correct:1,why:'Yesterday تدل على الماضي، لذلك نستخدم visited.'},{q:'I am interested ___ science.',ar:'أنا مهتم بالعلوم.',options:['in','on','at'],correct:0,why:'التعبير الصحيح هو interested in.'}];var grammarIndex=0,grammarScore=0,grammarAnswered=false,grammarCompletionRecorded=false,a2WritingDraft='';
  var currentTopic='all',viewedWords=[],completedActivities=[],bestQuizScore=0,quizAttempts=0;
  var sentenceIndex=0,pickedIndexes=[],poolWords=[],builderSolved=false,solvedSentences=[];
  var matchIndex=0,matchScore=0,matchAnswered=false,matchOptions=[];
  var quizIndex=0,quizScore=0,quizAnswered=false,quizOptions=[],progressUserId=null,progressKey='mrfluent-growing-a2-progress:guest',saveTimer=null;
  function shuffledA2(items){
    var result=items.slice();
    for(var i=result.length-1;i>0;i--){var j=Math.floor(Math.random()*(i+1));var temp=result[i];result[i]=result[j];result[j]=temp;}
    return result;
  }
  function speakA2(text,rate){
    var status=root.querySelector('#mfkrA2AudioStatus');
    if(!('speechSynthesis' in window)||!('SpeechSynthesisUtterance' in window)){
      if(status)status.textContent='النطق الصوتي غير مدعوم في هذا المتصفح. جرّب متصفحًا حديثًا.';
      return false;
    }
    window.speechSynthesis.cancel();
    var utterance=new SpeechSynthesisUtterance(text);mfkrSelectEnglishVoice(utterance);
    utterance.lang='en-US';utterance.rate=rate||.82;utterance.pitch=1.02;
    utterance.onstart=function(){if(status)status.textContent='🔊 Listening: '+text;};
    utterance.onend=function(){if(status)status.textContent='اضغط على زر الصوت للاستماع مرة أخرى.';};
    utterance.onerror=function(){if(status)status.textContent='تعذّر تشغيل الصوت. جرّب مرة أخرى.';};
    window.speechSynthesis.speak(utterance);
    return true;
  }
  function drawGrammar(){var host=root.querySelector('#mfkrA2Grammar');if(!host)return;if(grammarIndex>=grammarQuestions.length){host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">📘</div><h3>Grammar checkpoint complete!</h3><p lang="ar">نتيجتك: '+grammarScore+' من '+grammarQuestions.length+'. '+(grammarScore>=5?'ممتاز! أنت تستخدم القواعد في سياقها.':'راجع الأمثلة القصيرة ثم حاول مرة أخرى.')+'</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-a2-grammar-restart>أعد تدريب القواعد ↻</button></div>';if(!grammarCompletionRecorded){grammarCompletionRecorded=true;markActivity('grammar');if(typeof journeyRecord==='function'&&grammarScore>=5)journeyRecord('checkpoint:a2-grammar',null,'A2');}return;}var item=grammarQuestions[grammarIndex];host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">GRAMMAR IN CONTEXT</span><span class="mfkr-quiz-count">Question '+(grammarIndex+1)+' / '+grammarQuestions.length+'</span><span class="mfkr-quiz-score">Score: '+grammarScore+'</span></div><h3 lang="en">'+esc(item.q)+'</h3><p class="mfkr-quiz-hint" lang="ar">'+esc(item.ar)+'</p><div class="mfkr-quiz-options">'+item.options.map(function(option,index){return '<button type="button" class="mfkr-quiz-option" data-a2-grammar-option="'+index+'">'+esc(option)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrA2GrammarFeedback" lang="ar" aria-live="polite">اختر الإجابة، ثم اقرأ التفسير.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-a2-grammar-next disabled>السؤال التالي ←</button></div>';}
  function a2WordCount(value){var words=String(value||'').trim().match(/\S+/g);return words?words.length:0;}
  function updateA2WritingCount(){var field=root.querySelector('#mfkrA2WritingDraft'),count=root.querySelector('#mfkrA2WritingCount');if(count)count.textContent=a2WordCount(field?field.value:a2WritingDraft)+' words';}
  function drawProgress(){
    var wordLabel=root.querySelector('#mfkrA2ProgressWords');
    var activityLabel=root.querySelector('#mfkrA2ProgressActivities');
    var bar=root.querySelector('#mfkrA2ProgressBar');
    var status=root.querySelector('#mfkrA2SaveStatus');
    if(wordLabel)wordLabel.textContent=viewedWords.length+' / 24 words explored';
    if(activityLabel)activityLabel.textContent=completedActivities.length+' / 6 activities completed';
    if(bar)bar.style.width=Math.round(viewedWords.length/24*100)+'%';
    if(status&&!progressUserId)status.textContent='يُحفظ التقدّم على هذا الجهاز. سجّل الدخول لمزامنته مع حسابك.';
  }
  function saveProgress(){
    try{localStorage.setItem(progressKey,JSON.stringify({viewedWords:viewedWords,completedActivities:completedActivities,bestQuizScore:bestQuizScore,quizAttempts:quizAttempts}));}catch(_){}
    drawProgress();
    if(!progressUserId||typeof sb==='undefined'||!sb||!sb.from)return;
    var status=root.querySelector('#mfkrA2SaveStatus');
    if(status)status.textContent='جارٍ حفظ التقدّم في حسابك…';
    if(saveTimer)clearTimeout(saveTimer);
    saveTimer=setTimeout(async function(){
      try{
        var session=await sb.auth.getSession();
        var activeUser=session&&session.data&&session.data.session&&session.data.session.user;
        if(!activeUser||activeUser.id!==progressUserId)return;
        var payload={user_id:progressUserId,level_code:'A2',completed_words:viewedWords,completed_activities:completedActivities,best_quiz_score:bestQuizScore,quiz_attempts:quizAttempts,updated_at:new Date().toISOString()};
        var result=await sb.from('mrfluent_growing_progress').upsert(payload,{onConflict:'user_id,level_code'});
        if(result.error)throw result.error;
        if(status)status.textContent='تم حفظ تقدّمك في حسابك ✓';
      }catch(error){
        console.warn('A2 progress sync failed; local progress remains saved.',error);
        if(status)status.textContent='التقدّم محفوظ على هذا الجهاز؛ تعذّرت المزامنة مؤقتًا.';
      }
    },350);
  }
  function markWord(word){
    if(viewedWords.indexOf(word)<0){viewedWords.push(word);saveProgress();}
  }
  function markActivity(activity){
    if(completedActivities.indexOf(activity)<0){completedActivities.push(activity);saveProgress();}
  }
  function initializeProgress(){
    (async function(){
      var user=null;
      try{
        if(typeof sessionUser!=='undefined'&&sessionUser)user=sessionUser;
        if(!user&&typeof sb!=='undefined'&&sb&&sb.auth){
          var session=await sb.auth.getSession();
          user=session&&session.data&&session.data.session&&session.data.session.user||null;
        }
      }catch(_){}
      progressUserId=user&&user.id||null;
      progressKey='mrfluent-growing-a2-progress:'+(progressUserId||'guest');try{a2WritingDraft=localStorage.getItem('mfkr-a2-writing-draft:'+(progressUserId||'guest'))||'';var writingField=root.querySelector('#mfkrA2WritingDraft');if(writingField)writingField.value=a2WritingDraft;updateA2WritingCount();}catch(_){}
      try{
        var local=JSON.parse(localStorage.getItem(progressKey)||'{}');
        viewedWords=Array.isArray(local.viewedWords)?local.viewedWords.filter(function(w){return vocab.some(function(v){return v.word===w;});}):[];
        completedActivities=Array.isArray(local.completedActivities)?local.completedActivities.filter(function(a){return ['story','sentence-builder','listen-match','word-challenge','grammar','writing'].indexOf(a)>=0;}):[];
        bestQuizScore=Math.max(0,Math.min(8,Number(local.bestQuizScore)||0));
        quizAttempts=Math.max(0,Number(local.quizAttempts)||0);
      }catch(_){}
      drawProgress();
      if(progressUserId&&typeof sb!=='undefined'&&sb&&sb.from){
        try{
          var response=await sb.from('mrfluent_growing_progress').select('completed_words,completed_activities,best_quiz_score,quiz_attempts').eq('user_id',progressUserId).eq('level_code','A2').maybeSingle();
          if(response.error)throw response.error;
          if(response.data){
            viewedWords=Array.from(new Set(viewedWords.concat(Array.isArray(response.data.completed_words)?response.data.completed_words:[]))).filter(function(w){return vocab.some(function(v){return v.word===w;});});
            completedActivities=Array.from(new Set(completedActivities.concat(Array.isArray(response.data.completed_activities)?response.data.completed_activities:[]))).filter(function(a){return ['story','sentence-builder','listen-match','word-challenge','grammar','writing'].indexOf(a)>=0;});
            bestQuizScore=Math.max(bestQuizScore,Number(response.data.best_quiz_score)||0);
            quizAttempts=Math.max(quizAttempts,Number(response.data.quiz_attempts)||0);
          }
          saveProgress();
        }catch(error){
          console.warn('A2 remote progress could not be loaded.',error);
          var status=root.querySelector('#mfkrA2SaveStatus');
          if(status)status.textContent='التقدّم المحفوظ محليًا متاح؛ ستتم محاولة المزامنة عند توفر الاتصال.';
        }
      }
    })();
  }
  function renderWords(){
    var list=currentTopic==='all'?vocab:vocab.filter(function(item){return item.category===currentTopic;});
    root.querySelector('#mfkrA2WordGrid').innerHTML=list.map(function(item){
      return '<article class="mfkr-word-card"><div class="mfkr-word-card-head"><span class="mfkr-word-picture" aria-hidden="true">'+item.picture+'</span><span class="mfkr-word-tag">'+esc(item.category==='school'?'SCHOOL':item.category==='routine'?'ROUTINE':item.category==='hobbies'?'HOBBIES':'PLACES')+'</span></div><div class="mfkr-word">'+esc(item.word)+'</div><div class="mfkr-meaning" lang="ar">'+esc(item.meaning)+'</div><div class="mfkr-example-label">USE IT IN A SENTENCE</div><div class="mfkr-example" lang="en">'+esc(item.example)+'</div><div class="mfkr-example-ar" lang="ar">'+esc(item.sentence)+'</div><div class="mfkr-word-actions"><button type="button" class="mfkr-sound" data-a2-speak="'+esc(item.word)+'" data-a2-word-track="'+esc(item.word)+'">🔊 الكلمة</button><button type="button" class="mfkr-sound" data-a2-speak="'+esc(item.example)+'" data-a2-word-track="'+esc(item.word)+'">♫ الجملة</button></div></article>';
    }).join('');
    root.querySelectorAll('[data-a2-topic]').forEach(function(button){
      var active=button.getAttribute('data-a2-topic')===currentTopic;
      button.classList.toggle('is-active',active);button.setAttribute('aria-pressed',active?'true':'false');
    });
    root.querySelector('#mfkrA2VisibleCount').textContent=list.length+' كلمة';
  }
  function drawBuilder(){
    var item=sentences[sentenceIndex];
    root.querySelector('#mfkrA2WordPool').innerHTML=poolWords.map(function(word,index){
      if(pickedIndexes.indexOf(index)>=0)return '';
      return '<button type="button" class="mfkr-c1-chip" data-a2-pick="'+index+'">'+esc(word)+'</button>';
    }).join('');
    root.querySelector('#mfkrA2BuiltSentence').innerHTML=pickedIndexes.length?pickedIndexes.map(function(index,pos){
      return '<button type="button" class="mfkr-c1-chip is-picked" data-a2-remove="'+pos+'">'+esc(poolWords[index])+' <span aria-hidden="true">×</span></button>';
    }).join(''):'<span class="mfkr-c1-output-placeholder">اضغط على الكلمات لترتيبها هنا</span>';
    root.querySelector('#mfkrA2BuilderCount').textContent='Sentence '+(sentenceIndex+1)+' / '+sentences.length;
    root.querySelector('#mfkrA2BuilderSolved').textContent=solvedSentences.filter(Boolean).length+' / '+sentences.length+' completed';
    var feedback=root.querySelector('#mfkrA2BuilderFeedback');
    feedback.textContent=builderSolved?'Excellent! '+item.answer.join(' ')+' — '+item.ar:'رتّب الكلمات ثم اضغط «تحقّق من الجملة».';
    feedback.classList.toggle('is-right',builderSolved);feedback.classList.remove('is-wrong');
    root.querySelector('[data-a2-check]').disabled=pickedIndexes.length===0||builderSolved;
    root.querySelector('[data-a2-next]').disabled=!builderSolved;
  }
  function drawMatch(){
    var host=root.querySelector('#mfkrA2Match');
    if(matchIndex>=matches.length){
      host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🎧</div><h3>Great listening!</h3><div class="mfkr-ar" lang="ar">أحسنت! خلصت نشاط الاستماع والمطابقة.</div><p class="mfkr-quiz-feedback is-right">Your score: '+matchScore+' / '+matches.length+'</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-a2-match-restart>إعادة النشاط ↻</button></div>';
      markActivity('listen-match');return;
    }
    var target=matches[matchIndex];
    var allMeanings=vocab.map(function(v){return v.meaning;}).filter(function(m,index,arr){return arr.indexOf(m)===index&&m!==target.meaning;});
    matchOptions=shuffledA2([target.meaning].concat(shuffledA2(allMeanings).slice(0,2)));
    host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">LISTEN &amp; MATCH</span><span class="mfkr-quiz-count">'+(matchIndex+1)+' / '+matches.length+'</span><span class="mfkr-quiz-score">Score: '+matchScore+'</span></div><div class="mfkr-a2-match-prompt"><span class="mfkr-art" aria-hidden="true">🎧</span><div><h3>Listen to the word</h3><p lang="ar">اسمع الكلمة الإنجليزية ثم اختر معناها بالعربي.</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-a2-match-listen>🔊 اسمع الكلمة</button></div></div><div class="mfkr-quiz-options mfkr-c1-options">'+matchOptions.map(function(option,index){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option" data-a2-match-option="'+index+'" lang="ar">'+esc(option)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrA2MatchFeedback" lang="ar" aria-live="polite">استمع جيدًا واختر المعنى.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-a2-match-next disabled>التالي ←</button></div>';
  }
  function drawQuiz(){
    var host=root.querySelector('#mfkrA2Quiz');
    if(quizIndex>=quizQuestions.length){
      quizAttempts++;bestQuizScore=Math.max(bestQuizScore,quizScore);markActivity('word-challenge');saveProgress();
      host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🏆</div><h3>Word Explorer Champion!</h3><div class="mfkr-ar" lang="ar">أحسنت! أنهيت التحدّي.</div><p class="mfkr-quiz-feedback is-right">Your score: '+quizScore+' / '+quizQuestions.length+' · Best: '+bestQuizScore+' / '+quizQuestions.length+'</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-a2-quiz-restart>إعادة الاختبار ↻</button></div>';
      return;
    }
    quizAnswered=false;
    var q=quizQuestions[quizIndex];
    quizOptions=shuffledA2(q.options.map(function(option,index){return {text:option,correct:index===q.correct};}));
    host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">WORD CHALLENGE</span><span class="mfkr-quiz-count">Question '+(quizIndex+1)+' / '+quizQuestions.length+'</span><span class="mfkr-quiz-score">Score: '+quizScore+'</span></div><h3 lang="en">'+esc(q.q)+'</h3><p class="mfkr-quiz-hint" lang="ar">'+esc(q.ar)+'</p><div class="mfkr-quiz-options mfkr-c1-options">'+quizOptions.map(function(option,index){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option" data-a2-quiz-option="'+index+'">'+esc(option.text)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrA2QuizFeedback" lang="ar" aria-live="polite">خد وقتك وفكّر في الإجابة.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-a2-quiz-next disabled>السؤال التالي ←</button></div>';
  }
  var wordCards=vocab.map(function(item){return item;});
  root.innerHTML=shell('GROWING LEARNERS · LEVEL A2','Word Explorers.','مستكشفو الكلمات.','اكتشف كلمات جديدة، واستخدمها في جمل، واقرأ قصة، ثم اختبر فهمك واستماعك.','<div class="mfkr-summary mfkr-a2-summary"><span>24 useful words</span><div class="mfkr-progress"><span id="mfkrA2ProgressBar" style="width:0%"></span></div><span id="mfkrA2ProgressWords">0 / 24 words explored</span></div><section class="mfkr-topic-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">WORD EXPLORER · اكتشف الكلمات</div><h2>Explore by topic</h2><div class="mfkr-c1-story-title-ar" lang="ar">اختار موضوعًا وابدأ الاستكشاف</div></div><span class="mfkr-count" id="mfkrA2VisibleCount">24 كلمة</span></div><div class="mfkr-topics mfkr-a2-topics" role="group" aria-label="اختار موضوع الكلمات">'+topics.map(function(topic){return '<button type="button" class="mfkr-topic'+(topic[0]==='all'?' is-active':'')+'" data-a2-topic="'+topic[0]+'" aria-pressed="'+(topic[0]==='all'?'true':'false')+'"><span>'+topic[1]+'</span>'+topic[2]+'</button>';}).join('')+'</div></section><div class="mfkr-word-grid" id="mfkrA2WordGrid"></div><p class="mfkr-audio-status" id="mfkrA2AudioStatus" aria-live="polite">اضغط على زر الكلمة أو المثال لسماع النطق باللغة الإنجليزية.</p><section class="mfkr-topic-panel mfkr-a2-story"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">READING CORNER · ركن القراءة</div><h2>A Busy Day at School</h2><div class="mfkr-c1-story-title-ar" lang="ar">يوم مزدحم في المدرسة</div></div><span class="mfkr-art" aria-hidden="true">📖</span></div><div class="mfkr-a2-story-grid">'+story.map(function(line,index){return '<article class="mfkr-a2-story-card"><span class="mfkr-c1-story-number">0'+(index+1)+'</span><div class="mfkr-c1-story-en" lang="en">'+esc(line.en)+'</div><div class="mfkr-c1-story-ar" lang="ar">'+esc(line.ar)+'</div><button type="button" class="mfkr-sound mfkr-a2-line-sound" data-a2-story-line="'+index+'">🔊 اسمع الجملة</button></article>';}).join('')+'</div><div class="mfkr-c1-actions"><button type="button" class="mfkr-btn mfkr-btn-primary" data-a2-story-listen>🔊 استمع للقصة كاملة</button><button type="button" class="mfkr-btn" data-a2-story-done>✓ أنهيت قراءة القصة</button></div></section><section class="mfkr-quiz-panel mfkr-a2-builder"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 01 · BUILD A SENTENCE</div><h2>Sentence Builder <span aria-hidden="true">✦</span></h2><p lang="ar">كوّن الجملة بالضغط على الكلمات بالترتيب. اضغط على الكلمة داخل الجملة لإزالتها وإعادة ترتيبها.</p></div><div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge" id="mfkrA2BuilderCount">Sentence 1 / 4</span><span class="mfkr-quiz-score" id="mfkrA2BuilderSolved">0 / 4 completed</span></div><div class="mfkr-c1-output" id="mfkrA2BuiltSentence" aria-live="polite"></div><div class="mfkr-c1-chip-row" id="mfkrA2WordPool"></div><p class="mfkr-quiz-feedback" id="mfkrA2BuilderFeedback" lang="ar" aria-live="polite">رتّب الكلمات ثم تحقق من الجملة.</p><div class="mfkr-c1-actions"><button type="button" class="mfkr-btn mfkr-btn-primary" data-a2-check>تحقّق من الجملة ✓</button><button type="button" class="mfkr-btn" data-a2-next disabled>الجملة التالية ←</button></div></section><section class="mfkr-quiz-panel mfkr-a2-matching"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 02 · LISTEN &amp; MATCH</div><h2>Listen &amp; Match <span aria-hidden="true">✦</span></h2><p lang="ar">اسمع نطق الكلمة الإنجليزية واختر معناها الصحيح بالعربي.</p></div><div id="mfkrA2Match"></div></section><section class="mfkr-quiz-panel mfkr-a2-challenge"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 03 · FINAL CHALLENGE</div><h2>Word Challenge <span aria-hidden="true">✦</span></h2><p lang="ar">ثمانية أسئلة في الكلمات والقصة والجمل. شوف تقدر تجمع كام نقطة!</p></div><div id="mfkrA2Quiz"></div></section><section class="mfkr-quiz-panel mfkr-a2-grammar-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 04 · GRAMMAR IN CONTEXT</div><h2>Grammar in Everyday Life <span aria-hidden="true">✦</span></h2><p lang="ar">راجع المضارع البسيط، وما يحدث الآن، والماضي، ثم طبّق القاعدة في جمل من الحياة اليومية.</p><div class="mfkr-c1-story-title-ar" lang="en" style="margin:10px 0">Usually, I check my timetable. · Today, I am working on a project. · Yesterday, we visited a museum.</div></div><div id="mfkrA2Grammar"></div></section><section class="mfkr-topic-panel mfkr-a2-writing-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">ACTIVITY 05 · WRITING &amp; SPEAKING PRACTICE</div><h2>My School-Day Paragraph</h2><div class="mfkr-c1-story-title-ar" lang="ar">اكتب من 3 إلى 5 جمل عن يومك، ثم استمع إليها وكررها بصوتك.</div></div><span class="mfkr-art" aria-hidden="true">✍️</span></div><p class="mfkr-c1-story-en" lang="en">Model: I usually arrive early. I check my timetable. Today, I am working on a science project.</p><textarea id="mfkrA2WritingDraft" class="mfkr-c2-writing-area" rows="5" maxlength="1800" placeholder="I usually… Today, I am…"></textarea><div class="mfkr-c2-writing-meta"><span id="mfkrA2WritingCount">0 words</span><span>اكتب 20 كلمة على الأقل، ثم احفظها.</span></div><div class="mfkr-c1-actions"><button type="button" class="mfkr-btn mfkr-btn-primary" data-a2-writing-save>💾 احفظ كتابتي</button><button type="button" class="mfkr-btn" data-a2-writing-read>🔊 استمع إلى كتابتي</button><button type="button" class="mfkr-btn" data-a2-writing-clear>مسح المسودة</button></div><p class="mfkr-audio-status" id="mfkrA2WritingStatus" aria-live="polite">المسودة تُحفظ على هذا الجهاز تلقائيًا.</p></section><section class="mfkr-topic-panel mfkr-a2-progress-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">MY PROGRESS · تقدّمي</div><h2>Your learning journey</h2><div class="mfkr-c1-story-title-ar" lang="ar">كل خطوة تقرّبك من هدفك</div></div><span class="mfkr-art" aria-hidden="true">⭐</span></div><div class="mfkr-a2-progress-detail"><span id="mfkrA2ProgressActivities">0 / 6 activities completed</span><span>Best challenge score: <strong id="mfkrA2BestScore">0 / 8</strong></span><span>Total attempts: <strong id="mfkrA2Attempts">0</strong></span></div><p class="mfkr-audio-status" id="mfkrA2SaveStatus" aria-live="polite">جارٍ تحميل تقدّمك…</p></section>'+backButtons(url('older'),'← الرجوع إلى Growing Learners')+'<div class="mfkr-note">نصيحة: اسمع الكلمة والجملة، اقرأ الترجمة، وبعدها جرّب استخدامها في جملة من عندك. تقدّمك يُحفظ على هذا الجهاز، ويتزامن مع حسابك عند تسجيل الدخول.</div>');
  function drawProgressExtended(){
    drawProgress();
    var best=root.querySelector('#mfkrA2BestScore');if(best)best.textContent=bestQuizScore+' / 8';
    var attempts=root.querySelector('#mfkrA2Attempts');if(attempts)attempts.textContent=quizAttempts;
  }
  var originalDrawProgress=drawProgress;
  drawProgress=function(){originalDrawProgress();var best=root.querySelector('#mfkrA2BestScore');if(best)best.textContent=bestQuizScore+' / 8';var attempts=root.querySelector('#mfkrA2Attempts');if(attempts)attempts.textContent=quizAttempts;};
  poolWords=shuffledA2(sentences[0].answer.slice());
  renderWords();drawBuilder();drawMatch();drawQuiz();drawGrammar();updateA2WritingCount();initializeProgress();
  root.addEventListener('click',function(event){
    var grammarOption=event.target.closest('[data-a2-grammar-option]');if(grammarOption&&!grammarAnswered&&grammarIndex<grammarQuestions.length){var grammarPick=Number(grammarOption.getAttribute('data-a2-grammar-option')),grammarItem=grammarQuestions[grammarIndex],grammarCorrect=grammarPick===grammarItem.correct;grammarAnswered=true;if(grammarCorrect)grammarScore++;root.querySelectorAll('[data-a2-grammar-option]').forEach(function(button){var idx=Number(button.getAttribute('data-a2-grammar-option'));button.disabled=true;if(idx===grammarItem.correct)button.classList.add('is-correct');else if(button===grammarOption&&!grammarCorrect)button.classList.add('is-wrong');});var grammarFeedback=root.querySelector('#mfkrA2GrammarFeedback');if(grammarFeedback){grammarFeedback.textContent=grammarCorrect?'ممتاز! '+grammarItem.why:'الإجابة الصحيحة: '+grammarItem.options[grammarItem.correct]+'. '+grammarItem.why;grammarFeedback.classList.toggle('is-right',grammarCorrect);grammarFeedback.classList.toggle('is-wrong',!grammarCorrect);}var grammarScoreNode=root.querySelector('#mfkrA2Grammar .mfkr-quiz-score');if(grammarScoreNode)grammarScoreNode.textContent='Score: '+grammarScore;root.querySelector('[data-a2-grammar-next]').disabled=false;return;}if(event.target.closest('[data-a2-grammar-next]')&&grammarAnswered){grammarIndex++;grammarAnswered=false;drawGrammar();return;}if(event.target.closest('[data-a2-grammar-restart]')){grammarIndex=0;grammarScore=0;grammarAnswered=false;grammarCompletionRecorded=false;drawGrammar();return;}if(event.target.closest('[data-a2-writing-save]')){var a2Field=root.querySelector('#mfkrA2WritingDraft');a2WritingDraft=a2Field?a2Field.value:'';updateA2WritingCount();if(a2WordCount(a2WritingDraft)>=20){markActivity('writing');if(typeof journeyRecord==='function')journeyRecord('activity:a2-writing',null,'A2');var a2Status=root.querySelector('#mfkrA2WritingStatus');if(a2Status)a2Status.textContent='تم حفظ الكتابة. اقرأها بصوتك أيضًا، ثم استمع للنطق للمقارنة.';}else{var shortStatus=root.querySelector('#mfkrA2WritingStatus');if(shortStatus)shortStatus.textContent='أضف مزيدًا من التفاصيل حتى تصل إلى 20 كلمة على الأقل.';}try{localStorage.setItem('mfkr-a2-writing-draft:'+(progressUserId||'guest'),a2WritingDraft);}catch(_){}return;}if(event.target.closest('[data-a2-writing-read]')){var readField=root.querySelector('#mfkrA2WritingDraft'),readValue=String(readField&&readField.value||'').trim();if(readValue)speakA2(readValue,.84);else{var readStatus=root.querySelector('#mfkrA2WritingStatus');if(readStatus)readStatus.textContent='اكتب جملك أولًا، ثم استمع إليها وكررها بصوتك.';}return;}if(event.target.closest('[data-a2-writing-clear]')){a2WritingDraft='';var clearField=root.querySelector('#mfkrA2WritingDraft');if(clearField)clearField.value='';updateA2WritingCount();try{localStorage.removeItem('mfkr-a2-writing-draft:'+(progressUserId||'guest'));}catch(_){}var clearStatus=root.querySelector('#mfkrA2WritingStatus');if(clearStatus)clearStatus.textContent='تم مسح المسودة.';return;}var topicButton=event.target.closest('[data-a2-topic]');
    if(topicButton){currentTopic=topicButton.getAttribute('data-a2-topic');renderWords();return;}
    var soundButton=event.target.closest('[data-a2-speak]');
    if(soundButton){var sound=soundButton.getAttribute('data-a2-speak');var trackedWord=soundButton.getAttribute('data-a2-word-track')||sound;markWord(trackedWord);speakA2(sound,sound.length>18?.86:.78);return;}
    var storyLineButton=event.target.closest('[data-a2-story-line]');
    if(storyLineButton){var line=story[Number(storyLineButton.getAttribute('data-a2-story-line'))];if(line)speakA2(line.en,.8);return;}
    if(event.target.closest('[data-a2-story-listen]')){speakA2(story.map(function(line){return line.en;}).join(' '),.77);markActivity('story');return;}
    if(event.target.closest('[data-a2-story-done]')){markActivity('story');var done=event.target.closest('[data-a2-story-done]');done.textContent='✓ تم إكمال القصة';done.disabled=true;return;}
    var pick=event.target.closest('[data-a2-pick]');
    if(pick&&!builderSolved){pickedIndexes.push(Number(pick.getAttribute('data-a2-pick')));drawBuilder();return;}
    var remove=event.target.closest('[data-a2-remove]');
    if(remove&&!builderSolved){pickedIndexes.splice(Number(remove.getAttribute('data-a2-remove')),1);drawBuilder();return;}
    if(event.target.closest('[data-a2-check]')&&!builderSolved){
      var targetSentence=sentences[sentenceIndex],attempt=pickedIndexes.map(function(index){return poolWords[index];});
      builderSolved=attempt.join(' ')==targetSentence.answer.join(' ');
      var feedback=root.querySelector('#mfkrA2BuilderFeedback');
      feedback.textContent=builderSolved?'رائع! '+targetSentence.answer.join(' ')+ ' — '+targetSentence.ar:'لسه مش بالترتيب الصحيح. اضغط على الكلمات في الجملة لإزالتها وحاول تاني.';
      feedback.classList.toggle('is-right',builderSolved);feedback.classList.toggle('is-wrong',!builderSolved);
      root.querySelector('[data-a2-check]').disabled=pickedIndexes.length===0||builderSolved;
      root.querySelector('[data-a2-next]').disabled=!builderSolved;
      if(builderSolved)solvedSentences[sentenceIndex]=true;
      root.querySelector('#mfkrA2BuilderSolved').textContent=solvedSentences.filter(Boolean).length+' / '+sentences.length+' completed';
      return;
    }
    if(event.target.closest('[data-a2-next]')&&builderSolved){
      if(sentenceIndex===sentences.length-1){markActivity('sentence-builder');var fb=root.querySelector('#mfkrA2BuilderFeedback');fb.textContent='Amazing! أكملت كل الجمل بنجاح. تقدر تعيد التدريب من البداية.';root.querySelector('[data-a2-next]').disabled=true;return;}
      sentenceIndex++;pickedIndexes=[];builderSolved=false;poolWords=shuffledA2(sentences[sentenceIndex].answer.slice());drawBuilder();return;
    }
    if(event.target.closest('[data-a2-match-listen]')){speakA2(matches[matchIndex].word,.8);markWord(matches[matchIndex].word);return;}
    var matchOption=event.target.closest('[data-a2-match-option]');
    if(matchOption&&!matchAnswered&&matchIndex<matches.length){
      var selected=Number(matchOption.getAttribute('data-a2-match-option')),correct=matchOptions[selected]===matches[matchIndex].meaning;
      matchAnswered=true;if(correct)matchScore++;
      root.querySelectorAll('[data-a2-match-option]').forEach(function(button){button.disabled=true;var idx=Number(button.getAttribute('data-a2-match-option'));if(matchOptions[idx]===matches[matchIndex].meaning)button.classList.add('is-correct');else if(button===matchOption&&!correct)button.classList.add('is-wrong');});
      var matchFeedback=root.querySelector('#mfkrA2MatchFeedback');matchFeedback.textContent=correct?'ممتاز! إجابة صحيحة ✨':'حاول تاني في المرة القادمة. المعنى الصحيح: '+matches[matchIndex].meaning;
      matchFeedback.classList.toggle('is-right',correct);matchFeedback.classList.toggle('is-wrong',!correct);
      root.querySelector('.mfkr-a2-matching .mfkr-quiz-score').textContent='Score: '+matchScore;
      root.querySelector('[data-a2-match-next]').disabled=false;return;
    }
    if(event.target.closest('[data-a2-match-next]')&&matchAnswered){matchIndex++;matchAnswered=false;drawMatch();return;}
    if(event.target.closest('[data-a2-match-restart]')){matchIndex=0;matchScore=0;matchAnswered=false;drawMatch();return;}
    var quizOption=event.target.closest('[data-a2-quiz-option]');
    if(quizOption&&!quizAnswered&&quizIndex<quizQuestions.length){
      var selectedQuiz=Number(quizOption.getAttribute('data-a2-quiz-option')),isCorrect=!!quizOptions[selectedQuiz].correct;
      quizAnswered=true;if(isCorrect)quizScore++;
      root.querySelectorAll('[data-a2-quiz-option]').forEach(function(button){button.disabled=true;var index=Number(button.getAttribute('data-a2-quiz-option'));if(quizOptions[index].correct)button.classList.add('is-correct');else if(button===quizOption&&!isCorrect)button.classList.add('is-wrong');});
      var quizFeedback=root.querySelector('#mfkrA2QuizFeedback');quizFeedback.textContent=isCorrect?'ممتاز! إجابة صحيحة ✨':'الإجابة الصحيحة: '+quizOptions.filter(function(option){return option.correct;})[0].text;
      quizFeedback.classList.toggle('is-right',isCorrect);quizFeedback.classList.toggle('is-wrong',!isCorrect);
      root.querySelector('.mfkr-a2-challenge .mfkr-quiz-score').textContent='Score: '+quizScore;
      root.querySelector('[data-a2-quiz-next]').disabled=false;return;
    }
    if(event.target.closest('[data-a2-quiz-next]')&&quizAnswered){quizIndex++;drawQuiz();return;}
    if(event.target.closest('[data-a2-quiz-restart]')){quizIndex=0;quizScore=0;quizAnswered=false;drawQuiz();return;}
  });
  root.addEventListener('input',function(event){if(event.target&&event.target.id==='mfkrA2WritingDraft'){a2WritingDraft=event.target.value;updateA2WritingCount();try{localStorage.setItem('mfkr-a2-writing-draft:'+(progressUserId||'guest'),a2WritingDraft);}catch(_){}var status=root.querySelector('#mfkrA2WritingStatus');if(status)status.textContent='تم حفظ المسودة على هذا الجهاز تلقائيًا.';}});
}

function renderC2(){
  document.title='C2 — Confident English | Mr. Fluent Kids';
  var vocab=[
    {word:'analyse',meaning:'يحلّل',pic:'🔍',topic:'thinking',example:'We analyse the evidence before deciding.',ar:'نحلّل الأدلة قبل اتخاذ القرار.'},
    {word:'evidence',meaning:'دليل / أدلة',pic:'🧾',topic:'thinking',example:'The writer gives evidence for the main idea.',ar:'يقدّم الكاتب أدلة على الفكرة الرئيسية.'},
    {word:'reliable',meaning:'موثوق',pic:'✅',topic:'thinking',example:'Check whether the website is reliable.',ar:'تحقّق مما إذا كان الموقع موثوقًا.'},
    {word:'perspective',meaning:'وجهة نظر',pic:'👓',topic:'thinking',example:'Try to understand another person’s perspective.',ar:'حاول فهم وجهة نظر شخص آخر.'},
    {word:'conclusion',meaning:'استنتاج / خاتمة',pic:'🎯',topic:'thinking',example:'The conclusion brings the main points together.',ar:'تجمع الخاتمة الأفكار الرئيسية معًا.'},
    {word:'evaluate',meaning:'يقيّم',pic:'📊',topic:'thinking',example:'We evaluate each idea before choosing.',ar:'نقيّم كل فكرة قبل الاختيار.'},
    {word:'contribute',meaning:'يساهم',pic:'🤝',topic:'community',example:'Every student can contribute to the project.',ar:'يمكن لكل طالب أن يساهم في المشروع.'},
    {word:'volunteer',meaning:'يتطوّع / متطوّع',pic:'🙌',topic:'community',example:'Volunteers helped organise the event.',ar:'ساعد المتطوعون في تنظيم الفعالية.'},
    {word:'initiative',meaning:'مبادرة',pic:'🚀',topic:'community',example:'Our class started an initiative to share books.',ar:'بدأ فصلنا مبادرة لتبادل الكتب.'},
    {word:'cooperate',meaning:'يتعاون',pic:'🧩',topic:'community',example:'Teams cooperate to solve complex problems.',ar:'تتعاون الفرق لحل المشكلات المعقدة.'},
    {word:'impact',meaning:'تأثير',pic:'🌊',topic:'community',example:'Small actions can have a lasting impact.',ar:'قد يكون للأفعال الصغيرة تأثير مستمر.'},
    {word:'allocate',meaning:'يخصّص',pic:'📦',topic:'community',example:'We allocate time for research and discussion.',ar:'نخصّص وقتًا للبحث والنقاش.'},
    {word:'sustainable',meaning:'مستدام',pic:'🌱',topic:'future',example:'A sustainable plan uses resources wisely.',ar:'تستخدم الخطة المستدامة الموارد بحكمة.'},
    {word:'resource',meaning:'مورد',pic:'💧',topic:'future',example:'Water is a valuable natural resource.',ar:'الماء مورد طبيعي قيّم.'},
    {word:'consequence',meaning:'نتيجة / عاقبة',pic:'🔗',topic:'future',example:'Every choice may have a consequence.',ar:'قد يكون لكل اختيار نتيجة.'},
    {word:'prevent',meaning:'يمنع',pic:'🛡️',topic:'future',example:'Clear rules can prevent misunderstandings.',ar:'يمكن للقواعد الواضحة منع سوء الفهم.'},
    {word:'persuade',meaning:'يقنع',pic:'💬',topic:'communication',example:'Use strong reasons to persuade your audience.',ar:'استخدم أسبابًا قوية لإقناع جمهورك.'},
    {word:'emphasise',meaning:'يؤكّد / يشدّد على',pic:'📣',topic:'communication',example:'The speaker emphasised the importance of teamwork.',ar:'أكّد المتحدث أهمية العمل الجماعي.'},
    {word:'summarise',meaning:'يلخّص',pic:'📝',topic:'communication',example:'Summarise the article in your own words.',ar:'لخّص المقال بكلماتك أنت.'},
    {word:'clarify',meaning:'يوضّح',pic:'💡',topic:'communication',example:'Could you clarify your last point?',ar:'هل يمكنك توضيح نقطتك الأخيرة؟'}
  ];
  var topics=[['all','All words','كل الكلمات'],['thinking','Critical Thinking','التفكير النقدي'],['community','Community Projects','المجتمع والمبادرات'],['future','Solutions & Sustainability','الحلول والاستدامة'],['communication','Communication','التواصل والتعبير']];
  var passages=[
    {title:'The Library That Changed a Neighbourhood',arTitle:'المكتبة التي غيّرت الحيّ',icon:'📚',lines:[
      {en:'When the old library began to lose visitors, the neighbourhood council considered closing it.',ar:'عندما بدأت المكتبة القديمة تفقد زوارها، فكّر مجلس الحي في إغلاقها.'},
      {en:'A group of students suggested asking residents what they actually needed.',ar:'اقترحت مجموعة من الطلاب سؤال السكان عمّا يحتاجون إليه فعلًا.'},
      {en:'Their survey showed that families wanted flexible opening hours, quiet study areas, and practical workshops.',ar:'أظهر استطلاعهم أن العائلات تريد مواعيد مرنة، وأماكن هادئة للمذاكرة، وورشًا عملية.'},
      {en:'The students presented the evidence to the council instead of simply arguing that the library should stay open.',ar:'قدّم الطلاب الأدلة إلى المجلس بدلًا من الاكتفاء بالقول إن المكتبة يجب أن تظل مفتوحة.'},
      {en:'After a three-month trial, attendance increased and local volunteers offered to run weekly activities.',ar:'بعد تجربة استمرت ثلاثة أشهر، زاد الحضور وعرض متطوعون محليون تنظيم أنشطة أسبوعية.'},
      {en:'The project demonstrated that listening carefully can turn a disagreement into a practical solution.',ar:'أوضح المشروع أن الاستماع بعناية يمكن أن يحوّل الخلاف إلى حل عملي.'}
    ]},
    {title:'Can We Trust Everything Online?',arTitle:'هل يمكننا تصديق كل ما نراه على الإنترنت؟',icon:'🧠',lines:[
      {en:'An attractive headline can make a story seem convincing before we have checked its details.',ar:'قد يجعل العنوان الجذاب الخبر يبدو مقنعًا قبل أن نتحقق من تفاصيله.'},
      {en:'Responsible readers identify the original source and compare the claim with reliable reporting.',ar:'يحدّد القارئ المسؤول المصدر الأصلي ويقارن الادعاء بتقارير موثوقة.'},
      {en:'They also check the date, because an old photograph can be shared as if it showed a recent event.',ar:'ويتحققون أيضًا من التاريخ، لأن صورة قديمة قد تُنشر كما لو أنها توثّق حدثًا حديثًا.'},
      {en:'If strong evidence is missing, it is better to say “I am not sure” than to repeat the claim.',ar:'إذا غابت الأدلة القوية، فمن الأفضل قول «لست متأكدًا» بدلًا من تكرار الادعاء.'},
      {en:'This habit does not mean doubting everyone; it means giving important information a fair check.',ar:'لا تعني هذه العادة الشك في الجميع، بل تعني التحقق العادل من المعلومات المهمة.'},
      {en:'Thinking critically helps us make informed decisions and discuss differences respectfully.',ar:'يساعدنا التفكير النقدي على اتخاذ قرارات واعية ومناقشة الاختلافات باحترام.'}
    ]},
    {title:'A More Sustainable School',arTitle:'مدرسة أكثر استدامة',icon:'🌱',lines:[
      {en:'The school environmental club noticed that many half-used notebooks were thrown away at the end of term.',ar:'لاحظ نادي البيئة في المدرسة أن كثيرًا من الكشاكيل المستخدمة جزئيًا تُلقى في نهاية الفصل الدراسي.'},
      {en:'Instead of blaming students, the club studied the problem and counted how much paper could be saved.',ar:'بدلًا من لوم الطلاب، درس النادي المشكلة وحسب كمية الورق التي يمكن توفيرها.'},
      {en:'They proposed a collection point for reusable supplies and a simple system for sharing extra materials.',ar:'اقترحوا نقطة لجمع الأدوات القابلة لإعادة الاستخدام ونظامًا بسيطًا لتبادل الأدوات الزائدة.'},
      {en:'Teachers supported a one-month trial and asked students to record what worked well.',ar:'دعم المعلمون تجربة لمدة شهر وطلبوا من الطلاب تسجيل ما نجح منها.'},
      {en:'The results showed less waste, lower costs, and more cooperation between classes.',ar:'أظهرت النتائج نفايات أقل وتكاليف أقل وتعاونًا أكبر بين الفصول.'},
      {en:'The club used these results to recommend a long-term plan that could be improved each term.',ar:'استخدم النادي هذه النتائج لاقتراح خطة طويلة المدى يمكن تطويرها كل فصل دراسي.'}
    ]}
  ];
  var inferenceQuestions=[
    {q:'Why did the students conduct a survey in the library passage?',ar:'لماذا أجرى الطلاب استطلاعًا في قصة المكتبة؟',options:['To learn what residents needed','To prove the council was wrong','To count the books'],correct:0},
    {q:'Which detail best supports the idea that the library project worked?',ar:'أي تفصيل يدعم أكثر فكرة نجاح مشروع المكتبة؟',options:['The library was old','Attendance increased after the trial','The council held a meeting'],correct:1},
    {q:'What is the best lesson from “Can We Trust Everything Online?”',ar:'ما أفضل درس من نص «هل نصدق كل ما نراه على الإنترنت؟»؟',options:['Share news quickly','Trust every headline','Check sources and evidence before believing a claim'],correct:2},
    {q:'Why did the school club count the paper that could be saved?',ar:'لماذا حسب نادي المدرسة كمية الورق التي يمكن توفيرها؟',options:['To understand the problem with evidence','To make the notebooks heavier','To stop every classroom activity'],correct:0},
    {q:'What does “a one-month trial” suggest?',ar:'ماذا تعني عبارة تجربة لمدة شهر؟',options:['The plan was tested before a long-term decision','The school closed for a month','The plan could never change'],correct:0},
    {q:'Which sentence best summarises all three passages?',ar:'أي جملة تلخّص النصوص الثلاثة؟',options:['Problems are solved by blaming people','Evidence, listening, and cooperation can improve decisions','Every idea works without planning'],correct:1}
  ];
  var connectorQuestions=[
    {before:'The idea was popular,',after:'the team checked the evidence first.',ar:'كانت الفكرة شائعة، لكن الفريق تحقّق من الأدلة أولًا.',options:['so','but','because'],correct:1},
    {before:'The students collected feedback',after:'they could improve the plan.',ar:'جمع الطلاب الملاحظات لكي يتمكنوا من تحسين الخطة.',options:['so that','although','unless'],correct:0},
    {before:'If we reuse our supplies,',after:'we will reduce waste.',ar:'إذا أعدنا استخدام أدواتنا، فسنقلل النفايات.',options:['we will reduce waste','we reduced waste yesterday','we would reduced waste'],correct:0},
    {before:'The report was clear',after:'it included reliable evidence.',ar:'كان التقرير واضحًا لأنه تضمّن أدلة موثوقة.',options:['although','because','unless'],correct:1},
    {before:'The club had limited time.',after:'the team prioritised the most useful actions.',ar:'كان وقت النادي محدودًا. لذلك رتّب الفريق أولويات أكثر الإجراءات فائدة.',options:['However,','Therefore,','For example,'],correct:1},
    {before:'The suggestion was expensive.',after:'the council agreed to test a smaller version.',ar:'كان الاقتراح مكلفًا. ومع ذلك وافق المجلس على تجربة نسخة أصغر.',options:['Nevertheless,','For instance,','As a result of,'],correct:0}
  ];
  var speakingQuestions=[
    {scenario:'A classmate disagrees with your opinion.',ar:'زميلك لا يوافق على رأيك.',prompt:'Which reply keeps the discussion respectful?',options:['You never understand anything.','That is a different view. What evidence supports it?','Let us stop talking forever.'],correct:1},
    {scenario:'You did not understand the speaker’s last point.',ar:'لم تفهم آخر نقطة قالها المتحدث.',prompt:'What is the clearest response?',options:['Could you clarify your last point, please?','That was definitely wrong.','I will pretend I understand.'],correct:0},
    {scenario:'Your team has three possible project ideas.',ar:'لدى فريقك ثلاث أفكار للمشروع.',prompt:'What should the team do first?',options:['Choose the first idea without discussion.','Compare the benefits, costs, and evidence for each idea.','Ignore everyone’s suggestions.'],correct:1},
    {scenario:'You want to persuade the school to reuse supplies.',ar:'تريد إقناع المدرسة بإعادة استخدام الأدوات.',prompt:'Which approach is strongest?',options:['Give clear reasons and examples of the likely impact.','Say that everyone must agree with you.','Repeat the same sentence louder.'],correct:0},
    {scenario:'You discover that something you shared was inaccurate.',ar:'اكتشفت أن معلومة نشرتها لم تكن دقيقة.',prompt:'What is the most responsible action?',options:['Leave it there and hope no one notices.','Correct it clearly and explain the update.','Blame the first person who shared it.'],correct:1}
  ];
  var finalQuestions=[
    {q:'Which word means “موثوق”?',ar:'اختر معنى موثوق.',options:['Reliable','Crowded','Temporary'],correct:0},
    {q:'What is the main reason students surveyed residents?',ar:'لماذا سأل الطلاب سكان الحي؟',options:['To understand their needs','To avoid reading','To close the library'],correct:0},
    {q:'Choose the best connector: “The claim seemed surprising, ___ we checked two sources.”',ar:'اختر أداة الربط المناسبة.',options:['so','although','unless'],correct:0},
    {q:'Which action shows critical thinking?',ar:'أي تصرف يدل على التفكير النقدي؟',options:['Checking evidence before sharing','Believing every headline','Ignoring dates and sources'],correct:0},
    {q:'What does “allocate” mean?',ar:'ما معنى allocate؟',options:['يخصّص','يختفي','يعارض'],correct:0},
    {q:'Which detail supports a long-term school plan?',ar:'أي تفصيل يدعم خطة طويلة المدى؟',options:['A trial shows less waste and lower costs','A student dislikes the colour','A notebook is new'],correct:0},
    {q:'Choose the correct conditional sentence.',ar:'اختر جملة الشرط الصحيحة.',options:['If we reuse supplies, we will reduce waste.','If we will reuse supplies, we reduce yesterday.','If reuse supplies, we will reduces waste.'],correct:0},
    {q:'What is a conclusion?',ar:'ما المقصود بالخاتمة أو الاستنتاج؟',options:['A closing part that brings the main points together','A random detail in the middle','A list of unrelated words'],correct:0},
    {q:'Which is the most respectful disagreement?',ar:'أي رد يعبر عن اختلاف محترم؟',options:['I see your point, but the evidence suggests another view.','You are foolish.','I will not listen to you.'],correct:0},
    {q:'What should you do when a source is unreliable?',ar:'ماذا تفعل إذا كان المصدر غير موثوق؟',options:['Find a stronger source before repeating the claim','Share it because the title is exciting','Remove every other source'],correct:0},
    {q:'Which word means “يساهم”?',ar:'اختر معنى يساهم.',options:['Contribute','Prevent','Clarify'],correct:0},
    {q:'What connects all three C2 readings?',ar:'ما الفكرة المشتركة بين نصوص C2؟',options:['Use evidence and cooperation to improve decisions','Never change a plan','Solve every problem alone'],correct:0}
  ];
  var currentTopic='all',viewedWords=[],completedActivities=[],readPassages=[],bestQuizScore=0,quizAttempts=0,writingDraft='';
  var inferenceIndex=0,inferenceScore=0,inferenceAnswered=false,inferenceOptions=[];
  var connectorIndex=0,connectorScore=0,connectorAnswered=false,connectorOptions=[];
  var speakingIndex=0,speakingScore=0,speakingAnswered=false,speakingOptions=[];
  var quizIndex=0,quizScore=0,quizAnswered=false,quizOptions=[],progressUserId=null,progressKey='mrfluent-growing-c2-progress:guest',saveTimer=null;
  function shuffleC2(items){var arr=items.slice();for(var i=arr.length-1;i>0;i--){var j=Math.floor(Math.random()*(i+1)),tmp=arr[i];arr[i]=arr[j];arr[j]=tmp;}return arr;}
  function speakC2(text,rate){
    var status=root.querySelector('#mfkrC2AudioStatus');
    if(!('speechSynthesis' in window)||!('SpeechSynthesisUtterance' in window)){if(status)status.textContent='النطق الصوتي غير مدعوم في هذا المتصفح.';return;}
    window.speechSynthesis.cancel();var utterance=new SpeechSynthesisUtterance(text);mfkrSelectEnglishVoice(utterance);utterance.lang='en-US';utterance.rate=rate||.82;utterance.pitch=1.02;
    utterance.onstart=function(){if(status)status.textContent='🔊 Listening: '+text;};
    utterance.onend=function(){if(status)status.textContent='اضغط على زر الصوت للاستماع مرة أخرى.';};
    utterance.onerror=function(){if(status)status.textContent='تعذّر تشغيل الصوت. جرّب مرة أخرى.';};
    window.speechSynthesis.speak(utterance);
  }
  function doneCount(){return ['reading','inference','connectors','speaking','writing','final-challenge'].filter(function(k){return completedActivities.indexOf(k)>=0;}).length;}
  function drawProgress(){
    var words=root.querySelector('#mfkrC2ProgressWords'),acts=root.querySelector('#mfkrC2ProgressActivities'),bar=root.querySelector('#mfkrC2ProgressBar'),best=root.querySelector('#mfkrC2BestScore'),attempts=root.querySelector('#mfkrC2Attempts'),status=root.querySelector('#mfkrC2SaveStatus');
    if(words)words.textContent=viewedWords.length+' / '+vocab.length+' advanced words explored';
    if(acts)acts.textContent=doneCount()+' / 6 activities completed';
    if(bar)bar.style.width=Math.round(viewedWords.length/vocab.length*100)+'%';
    if(best)best.textContent=bestQuizScore+' / 12';if(attempts)attempts.textContent=quizAttempts;
    if(status&&!progressUserId)status.textContent='التقدّم محفوظ على هذا الجهاز. سجّل الدخول لمزامنته مع حسابك.';
  }
  function saveProgress(){
    var record={viewedWords:viewedWords,completedActivities:completedActivities,readPassages:readPassages,bestQuizScore:bestQuizScore,quizAttempts:quizAttempts,writingDraft:writingDraft};
    try{localStorage.setItem(progressKey,JSON.stringify(record));}catch(_){}
    drawProgress();
    if(!progressUserId||typeof sb==='undefined'||!sb||!sb.from)return;
    if(saveTimer)clearTimeout(saveTimer);
    var status=root.querySelector('#mfkrC2SaveStatus');if(status)status.textContent='جارٍ حفظ تقدّمك في حسابك…';
    saveTimer=setTimeout(async function(){
      try{
        var session=await sb.auth.getSession(),active=session&&session.data&&session.data.session&&session.data.session.user;
        if(!active||active.id!==progressUserId)return;
        var payload={user_id:progressUserId,level_code:'C2',completed_words:viewedWords,completed_activities:completedActivities.concat(readPassages.map(function(n){return 'passage-'+n;})),best_quiz_score:bestQuizScore,quiz_attempts:quizAttempts,writing_draft:writingDraft,updated_at:new Date().toISOString()};
        var response=await sb.from('mrfluent_growing_c2_progress').upsert(payload,{onConflict:'user_id,level_code'});
        if(response.error)throw response.error;
        if(status)status.textContent='تم حفظ تقدّمك في حسابك ✓';
      }catch(error){console.warn('C2 progress sync failed; local progress remains saved.',error);if(status)status.textContent='التقدّم محفوظ على هذا الجهاز؛ تعذّرت المزامنة مؤقتًا.';}
    },450);
  }
  function markWord(word){if(vocab.some(function(v){return v.word===word;})&&viewedWords.indexOf(word)<0){viewedWords.push(word);saveProgress();}}
  function markActivity(key){if(completedActivities.indexOf(key)<0){completedActivities.push(key);saveProgress();}}
  function wordCount(text){var words=String(text||'').trim().match(/\S+/g);return words?words.length:0;}
  function updateWritingCount(){
    var text=root.querySelector('#mfkrC2WritingDraft'),count=root.querySelector('#mfkrC2WordCount'),target=root.querySelector('#mfkrC2WritingHint');
    if(count)count.textContent=wordCount(text?text.value:writingDraft)+' words';
    if(target){var n=wordCount(text?text.value:writingDraft);target.textContent=n<80?'Aim for 80–120 words. Add a clear main idea, two supporting details, and a conclusion.':'Good start! Check your main idea, supporting evidence, and conclusion.';}
  }
  function initializeProgress(){
    (async function(){
      var user=null;
      try{if(typeof sessionUser!=='undefined'&&sessionUser)user=sessionUser;if(!user&&typeof sb!=='undefined'&&sb&&sb.auth){var sess=await sb.auth.getSession();user=sess&&sess.data&&sess.data.session&&sess.data.session.user||null;}}catch(_){}
      progressUserId=user&&user.id||null;progressKey='mrfluent-growing-c2-progress:'+(progressUserId||'guest');
      try{
        var local=JSON.parse(localStorage.getItem(progressKey)||'{}');
        viewedWords=Array.isArray(local.viewedWords)?local.viewedWords.filter(function(w){return vocab.some(function(v){return v.word===w;});}):[];
        completedActivities=Array.isArray(local.completedActivities)?local.completedActivities.filter(function(k){return ['reading','inference','connectors','speaking','writing','final-challenge'].indexOf(k)>=0;}):[];
        readPassages=Array.isArray(local.readPassages)?local.readPassages.filter(function(n){return Number.isInteger(n)&&n>=0&&n<passages.length;}):[];
        bestQuizScore=Math.max(0,Math.min(12,Number(local.bestQuizScore)||0));quizAttempts=Math.max(0,Number(local.quizAttempts)||0);writingDraft=typeof local.writingDraft==='string'?local.writingDraft:'';
      }catch(_){}
      var draftField=root.querySelector('#mfkrC2WritingDraft');if(draftField)draftField.value=writingDraft;
      updateWritingCount();drawProgress();
      readPassages.forEach(function(index){var button=root.querySelector('[data-c2-read-done="'+index+'"]');if(button){button.textContent='✓ Completed';button.disabled=true;}});
      if(progressUserId&&typeof sb!=='undefined'&&sb&&sb.from){
        try{
          var remote=await sb.from('mrfluent_growing_c2_progress').select('completed_words,completed_activities,best_quiz_score,quiz_attempts,writing_draft').eq('user_id',progressUserId).eq('level_code','C2').maybeSingle();
          if(remote.error)throw remote.error;
          if(remote.data){
            viewedWords=Array.from(new Set(viewedWords.concat(Array.isArray(remote.data.completed_words)?remote.data.completed_words:[]))).filter(function(w){return vocab.some(function(v){return v.word===w;});});
            var remoteActs=Array.isArray(remote.data.completed_activities)?remote.data.completed_activities:[];
            completedActivities=Array.from(new Set(completedActivities.concat(remoteActs.filter(function(k){return ['reading','inference','connectors','speaking','writing','final-challenge'].indexOf(k)>=0;}))));
            readPassages=Array.from(new Set(readPassages.concat(remoteActs.filter(function(k){return /^passage-[0-2]$/.test(k);}).map(function(k){return Number(k.slice(8));}))));
            bestQuizScore=Math.max(bestQuizScore,Number(remote.data.best_quiz_score)||0);quizAttempts=Math.max(quizAttempts,Number(remote.data.quiz_attempts)||0);
            if(!writingDraft&&typeof remote.data.writing_draft==='string')writingDraft=remote.data.writing_draft;
          }
          var field=root.querySelector('#mfkrC2WritingDraft');if(field)field.value=writingDraft;
          updateWritingCount();
          readPassages.forEach(function(index){var button=root.querySelector('[data-c2-read-done="'+index+'"]');if(button){button.textContent='✓ Completed';button.disabled=true;}});
          saveProgress();
        }catch(error){console.warn('C2 remote progress could not be loaded.',error);var status=root.querySelector('#mfkrC2SaveStatus');if(status)status.textContent='التقدّم المحلي متاح؛ ستتم محاولة المزامنة عند توفر الاتصال.';}
      }
    })();
  }
  function renderVocab(){
    var list=currentTopic==='all'?vocab:vocab.filter(function(v){return v.topic===currentTopic;});
    root.querySelector('#mfkrC2WordGrid').innerHTML=list.map(function(v){var tag={thinking:'CRITICAL THINKING',community:'COMMUNITY',future:'FUTURE & SOLUTIONS',communication:'COMMUNICATION'}[v.topic];return '<article class="mfkr-word-card"><div class="mfkr-word-card-head"><span class="mfkr-word-picture" aria-hidden="true">'+v.pic+'</span><span class="mfkr-word-tag">'+tag+'</span></div><div class="mfkr-word">'+esc(v.word)+'</div><div class="mfkr-meaning" lang="ar">'+esc(v.meaning)+'</div><div class="mfkr-example-label">ADVANCED VOCABULARY IN CONTEXT</div><div class="mfkr-example" lang="en">'+esc(v.example)+'</div><div class="mfkr-example-ar" lang="ar">'+esc(v.ar)+'</div><div class="mfkr-word-actions"><button type="button" class="mfkr-sound" data-c2-speak="'+esc(v.word)+'" data-c2-track="'+esc(v.word)+'">🔊 الكلمة</button><button type="button" class="mfkr-sound" data-c2-speak="'+esc(v.example)+'" data-c2-track="'+esc(v.word)+'">♫ المثال</button></div></article>';}).join('');
    root.querySelectorAll('[data-c2-topic]').forEach(function(btn){var active=btn.getAttribute('data-c2-topic')===currentTopic;btn.classList.toggle('is-active',active);btn.setAttribute('aria-pressed',active?'true':'false');});
    root.querySelector('#mfkrC2VisibleCount').textContent=list.length+' words';
  }
  function drawInference(){
    var host=root.querySelector('#mfkrC2Inference');
    if(inferenceIndex>=inferenceQuestions.length){host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🧠</div><h3>Critical thinker!</h3><div class="mfkr-ar" lang="ar">أحسنت! أنهيت نشاط الفهم والاستنتاج.</div><p class="mfkr-quiz-feedback is-right">Your score: '+inferenceScore+' / '+inferenceQuestions.length+'</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-c2-inference-restart>إعادة النشاط ↻</button></div>';markActivity('inference');return;}
    inferenceAnswered=false;var q=inferenceQuestions[inferenceIndex];inferenceOptions=shuffleC2(q.options.map(function(t,i){return {text:t,correct:i===q.correct};}));
    host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">INFERENCE '+(inferenceIndex+1)+' / '+inferenceQuestions.length+'</span><span class="mfkr-quiz-score">Score: '+inferenceScore+'</span></div><h3 lang="en">'+esc(q.q)+'</h3><p class="mfkr-quiz-hint" lang="ar">'+esc(q.ar)+'</p><div class="mfkr-quiz-options mfkr-c1-options">'+inferenceOptions.map(function(o,i){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option" data-c2-inference="'+i+'">'+esc(o.text)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrC2InferenceFeedback" lang="ar" aria-live="polite">ارجع إلى النص وفكّر في الدليل.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-c2-inference-next disabled>السؤال التالي ←</button></div>';
  }
  function drawConnectors(){
    var host=root.querySelector('#mfkrC2Connectors');
    if(connectorIndex>=connectorQuestions.length){host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🔗</div><h3>Language expert!</h3><div class="mfkr-ar" lang="ar">أحسنت! أنهيت تحدّي أدوات الربط والتراكيب.</div><p class="mfkr-quiz-feedback is-right">Your score: '+connectorScore+' / '+connectorQuestions.length+'</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-c2-connector-restart>إعادة التدريب ↻</button></div>';markActivity('connectors');return;}
    connectorAnswered=false;var q=connectorQuestions[connectorIndex];
    host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">LANGUAGE LAB '+(connectorIndex+1)+' / '+connectorQuestions.length+'</span><span class="mfkr-quiz-score">Score: '+connectorScore+'</span></div><div class="mfkr-b2-connector-sentence" lang="en">'+esc(q.before)+' <span class="mfkr-b2-blank">_____</span> '+esc(q.after)+'</div><p class="mfkr-quiz-hint" lang="ar">'+esc(q.ar)+'</p><div class="mfkr-quiz-options mfkr-c1-options">'+q.options.map(function(o,i){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option" data-c2-connector="'+i+'">'+esc(o)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrC2ConnectorFeedback" lang="ar" aria-live="polite">اختر أداة الربط أو التركيب الأنسب.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-c2-connector-next disabled>التالي ←</button></div>';
  }
  function drawSpeaking(){
    var host=root.querySelector('#mfkrC2Speaking');
    if(speakingIndex>=speakingQuestions.length){host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🎙️</div><h3>Confident communicator!</h3><div class="mfkr-ar" lang="ar">أحسنت! أنهيت مواقف التواصل.</div><p class="mfkr-quiz-feedback is-right">Your score: '+speakingScore+' / '+speakingQuestions.length+'</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-c2-speaking-restart>إعادة التدريب ↻</button></div>';markActivity('speaking');return;}
    speakingAnswered=false;var q=speakingQuestions[speakingIndex];speakingOptions=shuffleC2(q.options.map(function(t,i){return {text:t,correct:i===q.correct};}));
    host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">SPEAKING STUDIO '+(speakingIndex+1)+' / '+speakingQuestions.length+'</span><span class="mfkr-quiz-score">Score: '+speakingScore+'</span></div><div class="mfkr-a2-match-prompt"><span class="mfkr-art" aria-hidden="true">💬</span><div><h3 lang="en">'+esc(q.scenario)+'</h3><p lang="ar">'+esc(q.ar)+'</p><strong>'+esc(q.prompt)+'</strong></div></div><div class="mfkr-quiz-options mfkr-c1-options">'+speakingOptions.map(function(o,i){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option" data-c2-speaking="'+i+'">'+esc(o.text)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrC2SpeakingFeedback" lang="ar" aria-live="polite">اختار الرد الأكثر وضوحًا واحترامًا.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-c2-speaking-next disabled>الموقف التالي ←</button></div>';
  }
  function drawFinalQuiz(){
    var host=root.querySelector('#mfkrC2Quiz');
    if(quizIndex>=finalQuestions.length){quizAttempts++;bestQuizScore=Math.max(bestQuizScore,quizScore);markActivity('final-challenge');saveProgress();host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🏆</div><h3>Confident English Champion!</h3><div class="mfkr-ar" lang="ar">أحسنت! أكملت الاختبار الشامل لمستوى C2.</div><p class="mfkr-quiz-feedback is-right">Your score: '+quizScore+' / 12 · Best: '+bestQuizScore+' / 12</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-c2-quiz-restart>إعادة الاختبار ↻</button></div>';return;}
    quizAnswered=false;var q=finalQuestions[quizIndex];quizOptions=shuffleC2(q.options.map(function(t,i){return {text:t,correct:i===q.correct};}));
    host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">C2 MASTER CHALLENGE</span><span class="mfkr-quiz-count">Question '+(quizIndex+1)+' / '+finalQuestions.length+'</span><span class="mfkr-quiz-score">Score: '+quizScore+'</span></div><h3 lang="en">'+esc(q.q)+'</h3><p class="mfkr-quiz-hint" lang="ar">'+esc(q.ar)+'</p><div class="mfkr-quiz-options mfkr-c1-options">'+quizOptions.map(function(o,i){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option" data-c2-quiz="'+i+'">'+esc(o.text)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrC2QuizFeedback" lang="ar" aria-live="polite">راجع ما تعلّمته قبل اختيار الإجابة.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-c2-quiz-next disabled>السؤال التالي ←</button></div>';
  }
  root.innerHTML=shell('GROWING LEARNERS · FINAL LEVEL C2','Confident English.','الإنجليزية بثقة.','المستوى الشامل الأخير: فكّر نقديًا، وافهم النصوص بعمق، وعبّر عن رأيك، واكتب فقرة واضحة ومدعومة بالأسباب.','<div class="mfkr-summary mfkr-a2-summary"><span>20 advanced words · 3 readings · 4 skill labs</span><div class="mfkr-progress"><span id="mfkrC2ProgressBar" style="width:0%"></span></div><span id="mfkrC2ProgressWords">0 / 20 advanced words explored</span></div><section class="mfkr-topic-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">READING LAB · معمل القراءة المتقدمة</div><h2>Read Beyond the Words</h2><div class="mfkr-c1-story-title-ar" lang="ar">اقرأ ما وراء الكلمات واستنتج الفكرة</div></div><span class="mfkr-art" aria-hidden="true">📚</span></div><div class="mfkr-a2-story-grid">'+passages.map(function(p,index){return '<article class="mfkr-a2-story-card"><span class="mfkr-c1-story-number">0'+(index+1)+'</span><div class="mfkr-topic-heading"><div><h3>'+esc(p.title)+'</h3><div class="mfkr-c1-story-title-ar" lang="ar">'+esc(p.arTitle)+'</div></div><span class="mfkr-art" aria-hidden="true">'+p.icon+'</span></div>'+p.lines.map(function(line){return '<div class="mfkr-c1-story-en" lang="en">'+esc(line.en)+'</div><div class="mfkr-c1-story-ar" lang="ar">'+esc(line.ar)+'</div>';}).join('')+'<div class="mfkr-c1-actions"><button type="button" class="mfkr-sound" data-c2-pass-listen="'+index+'">🔊 Listen</button><button type="button" class="mfkr-sound" data-c2-read-done="'+index+'">'+(readPassages.indexOf(index)>=0?'✓ Completed':'✓ أنهيت القراءة')+'</button></div></article>';}).join('')+'</div></section><section class="mfkr-topic-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">ADVANCED VOCABULARY IN CONTEXT · مفردات متقدمة</div><h2>Words for Better Ideas</h2><div class="mfkr-c1-story-title-ar" lang="ar">كلمات تساعدك على التفكير والتعبير بدقة</div></div><span class="mfkr-count" id="mfkrC2VisibleCount">20 words</span></div><div class="mfkr-topics mfkr-a2-topics" role="group" aria-label="Choose advanced vocabulary topic">'+topics.map(function(t){return '<button type="button" class="mfkr-topic'+(t[0]==='all'?' is-active':'')+'" data-c2-topic="'+t[0]+'" aria-pressed="'+(t[0]==='all'?'true':'false')+'"><span>'+t[1]+'</span>'+t[2]+'</button>';}).join('')+'</div></section><div class="mfkr-word-grid" id="mfkrC2WordGrid"></div><p class="mfkr-audio-status" id="mfkrC2AudioStatus" aria-live="polite">استمع إلى الكلمات والأمثلة، ثم حاول استخدام كل كلمة في جملة من عندك.</p><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 01 · INFERENCE &amp; EVIDENCE</div><h2>Think Like a Reader <span aria-hidden="true">✦</span></h2><p lang="ar">أسئلة أعمق عن الفكرة الرئيسية، والأدلة، وهدف الكاتب، والاستنتاج.</p></div><div id="mfkrC2Inference"></div></section><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 02 · LANGUAGE &amp; LOGIC</div><h2>Connector &amp; Grammar Lab <span aria-hidden="true">✦</span></h2><p lang="ar">استخدم أدوات الربط وتراكيب الشرط والنتيجة والتباين في سياق واضح.</p></div><div id="mfkrC2Connectors"></div></section><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 03 · REAL-LIFE COMMUNICATION</div><h2>Speaking Studio <span aria-hidden="true">✦</span></h2><p lang="ar">اختر الرد الأفضل في مواقف النقاش، وطلب التوضيح، والإقناع، وتصحيح المعلومات.</p></div><div id="mfkrC2Speaking"></div></section><section class="mfkr-quiz-panel mfkr-c2-writing"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 04 · WRITING WORKSHOP</div><h2>Build a Strong Paragraph <span aria-hidden="true">✦</span></h2><p lang="ar">اكتب فقرة من 80 إلى 120 كلمة عن: كيف يمكن لمدرستنا أن تصبح أفضل للمجتمع؟ ابدأ بفكرة رئيسية، وأضف سببين أو مثالين، واستخدم أداة ربط، ثم اختم باستنتاج.</p></div><div class="mfkr-c2-writing-prompts"><span>Useful starters: <strong>In my view…</strong></span><span><strong>One reason is…</strong></span><span><strong>For example…</strong></span><span><strong>As a result…</strong></span><span><strong>In conclusion…</strong></span></div><textarea id="mfkrC2WritingDraft" class="mfkr-c2-writing-area" rows="7" maxlength="3000" placeholder="In my view, our school can help the community by…"></textarea><div class="mfkr-c2-writing-meta"><span id="mfkrC2WordCount">0 words</span><span id="mfkrC2WritingHint">Aim for 80–120 words. Add a clear main idea, two supporting details, and a conclusion.</span></div><div class="mfkr-c1-actions"><button type="button" class="mfkr-btn mfkr-btn-primary" data-c2-writing-save>💾 احفظ فقرتي</button><button type="button" class="mfkr-btn" data-c2-writing-clear>مسح المسودة</button></div><p class="mfkr-audio-status">قبل الحفظ، راجع: هل الفكرة واضحة؟ هل توجد أسباب أو أمثلة؟ هل استخدمت أدوات الربط؟ هل كتبت خاتمة؟</p></section><div class="mfkr-topic-panel" style="margin-top:12px"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">MODEL ANSWER · نموذج إرشادي</div><h3>Example: A Better Community</h3><div class="mfkr-c1-story-title-ar" lang="ar">اقرأ المثال ولا تنسخ الفقرة كما هي؛ استخدم الفكرة لتكتب بأسلوبك.</div></div><span class="mfkr-art" aria-hidden="true">📘</span></div><details><summary style="cursor:pointer;color:#d9baff;font-weight:900;padding:8px">Show the full model / عرض المثال</summary><p class="mfkr-c1-story-en" lang="en" style="margin-top:10px">In my view, our school can help the community by creating a small book-sharing corner and organising a monthly clean-up day. One reason is that students can donate books they have finished, so younger children will have more stories to read. For example, each class could label and organise its books before sharing them. Another benefit is that a clean-up day would encourage students, families, and neighbours to work together. The school could measure progress by recording how many books are shared and how much litter is collected. As a result, the project would build responsibility and stronger relationships. In conclusion, small, well-planned actions can make our community better.</p><p class="mfkr-c1-story-ar" lang="ar">في رأيي، يمكن لمدرستنا مساعدة المجتمع من خلال إنشاء ركن صغير لتبادل الكتب وتنظيم يوم تنظيف كل شهر. أحد الأسباب هو أن الطلاب يستطيعون التبرع بالكتب التي انتهوا من قراءتها، وبذلك يجد الأطفال الأصغر سنًا قصصًا أكثر لقراءتها. على سبيل المثال، يمكن لكل فصل تصنيف كتبه وترتيبها قبل مشاركتها. ومن الفوائد الأخرى أن يوم التنظيف سيشجع الطلاب والأسر والجيران على العمل معًا. ويمكن للمدرسة قياس التقدم من خلال تسجيل عدد الكتب المتبادلة وكمية القمامة التي جُمعت. ونتيجة لذلك، سيبني المشروع روح المسؤولية وعلاقات أقوى. في الختام، تستطيع الأعمال الصغيرة المخططة جيدًا تحسين مجتمعنا.</p></details></div><div class="mfkr-topic-panel" style="margin-top:12px"><div class="mfkr-mini-eyebrow">WRITING SELF-CHECK · راجع كتابتك</div><p class="mfkr-c1-story-title-ar" lang="ar">ضع علامة على كل معيار بعد التحقق منه بنفسك.</p><div style="display:grid;gap:10px;margin:12px 0"><label style="display:flex;align-items:flex-start;gap:8px;color:#e2d4ed"><input type="checkbox" data-c2-rubric-item> الفكرة الرئيسية واضحة في البداية.</label><label style="display:flex;align-items:flex-start;gap:8px;color:#e2d4ed"><input type="checkbox" data-c2-rubric-item> يوجد سببان أو مثالان يدعمان الفكرة.</label><label style="display:flex;align-items:flex-start;gap:8px;color:#e2d4ed"><input type="checkbox" data-c2-rubric-item> استخدمت أداة ربط مناسبة مثل because أو as a result.</label><label style="display:flex;align-items:flex-start;gap:8px;color:#e2d4ed"><input type="checkbox" data-c2-rubric-item> توجد خاتمة تلخص الرسالة الرئيسية.</label></div><div class="mfkr-c1-actions"><button type="button" class="mfkr-btn mfkr-btn-primary" data-c2-writing-rubric-check>راجع المعايير الأربعة ✓</button></div><p class="mfkr-quiz-feedback" id="mfkrC2RubricFeedback" lang="ar" aria-live="polite">يُقيّم هذا الفحص قائمة المراجعة التي اخترتها، وليس جودة النص تلقائيًا.</p></div><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">FINAL ACTIVITY 05 · MASTER CHALLENGE</div><h2>C2 Master Challenge <span aria-hidden="true">✦</span></h2><p lang="ar">اختبار شامل من 12 سؤالًا يجمع المفردات والفهم والاستنتاج والقواعد والتواصل.</p></div><div id="mfkrC2Quiz"></div></section><section class="mfkr-topic-panel mfkr-a2-progress-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">MY PROGRESS · تقدّمي</div><h2>Your C2 Journey</h2><div class="mfkr-c1-story-title-ar" lang="ar">أنت في المستوى الأخير — واصل التقدّم!</div></div><span class="mfkr-art" aria-hidden="true">🏆</span></div><div class="mfkr-a2-progress-detail"><span id="mfkrC2ProgressActivities">0 / 6 activities completed</span><span>Best master score: <strong id="mfkrC2BestScore">0 / 12</strong></span><span>Total attempts: <strong id="mfkrC2Attempts">0</strong></span></div><p class="mfkr-audio-status" id="mfkrC2SaveStatus" aria-live="polite">جارٍ تحميل تقدّمك…</p></section>'+backButtons(url('older'),'← الرجوع إلى Growing Learners')+'<div class="mfkr-note">لأفضل نتيجة: اقرأ النصوص قبل الإجابة، واستخدم المفردات الجديدة في فقرتك، وحاول توضيح سبب اختيارك بدلًا من حفظ الإجابة فقط.</div>');
  function bindPassageReadIndicators(){
    readPassages.forEach(function(index){var btn=root.querySelector('[data-c2-read-done="'+index+'"]');if(btn){btn.textContent='✓ Completed';btn.disabled=true;}});
  }
  renderVocab();drawInference();drawConnectors();drawSpeaking();drawFinalQuiz();initializeProgress();
  root.addEventListener('input',function(event){
    if(event.target&&event.target.id==='mfkrC2WritingDraft'){writingDraft=event.target.value;updateWritingCount();saveProgress();}
  });
  root.addEventListener('click',function(event){
    var topicButton=event.target.closest('[data-c2-topic]');if(topicButton){currentTopic=topicButton.getAttribute('data-c2-topic');renderVocab();return;}
    var sound=event.target.closest('[data-c2-speak]');if(sound){var phrase=sound.getAttribute('data-c2-speak');markWord(sound.getAttribute('data-c2-track')||phrase);speakC2(phrase,phrase.length>20?.86:.78);return;}
    var passageSound=event.target.closest('[data-c2-pass-listen]');if(passageSound){var pi=Number(passageSound.getAttribute('data-c2-pass-listen'));if(passages[pi])speakC2(passages[pi].lines.map(function(line){return line.en;}).join(' '),.77);return;}
    var readDone=event.target.closest('[data-c2-read-done]');if(readDone){var ri=Number(readDone.getAttribute('data-c2-read-done'));if(Number.isInteger(ri)&&ri>=0&&ri<passages.length&&readPassages.indexOf(ri)<0)readPassages.push(ri);bindPassageReadIndicators();if(readPassages.length===passages.length)markActivity('reading');saveProgress();return;}
    var inferencePick=event.target.closest('[data-c2-inference]');
    if(inferencePick&&!inferenceAnswered){var ii=Number(inferencePick.getAttribute('data-c2-inference')),ic=!!inferenceOptions[ii].correct;inferenceAnswered=true;if(ic)inferenceScore++;root.querySelectorAll('[data-c2-inference]').forEach(function(btn){var k=Number(btn.getAttribute('data-c2-inference'));btn.disabled=true;if(inferenceOptions[k].correct)btn.classList.add('is-correct');else if(btn===inferencePick&&!ic)btn.classList.add('is-wrong');});var ifb=root.querySelector('#mfkrC2InferenceFeedback');ifb.textContent=ic?'ممتاز! استندت إلى دليل مناسب.':'راجع النص مرة أخرى. الإجابة الصحيحة: '+inferenceOptions.filter(function(o){return o.correct;})[0].text;ifb.classList.toggle('is-right',ic);ifb.classList.toggle('is-wrong',!ic);root.querySelector('[data-c2-inference-next]').disabled=false;var iscore=root.querySelector('#mfkrC2Inference .mfkr-quiz-score');if(iscore)iscore.textContent='Score: '+inferenceScore;return;}
    if(event.target.closest('[data-c2-inference-next]')&&inferenceAnswered){inferenceIndex++;drawInference();return;}
    if(event.target.closest('[data-c2-inference-restart]')){inferenceIndex=0;inferenceScore=0;inferenceAnswered=false;drawInference();return;}
    var connectorPick=event.target.closest('[data-c2-connector]');
    if(connectorPick&&!connectorAnswered){var ci=Number(connectorPick.getAttribute('data-c2-connector')),cc=ci===connectorQuestions[connectorIndex].correct;connectorAnswered=true;if(cc)connectorScore++;root.querySelectorAll('[data-c2-connector]').forEach(function(btn){var k=Number(btn.getAttribute('data-c2-connector'));btn.disabled=true;if(k===connectorQuestions[connectorIndex].correct)btn.classList.add('is-correct');else if(btn===connectorPick&&!cc)btn.classList.add('is-wrong');});var cfb=root.querySelector('#mfkrC2ConnectorFeedback');cfb.textContent=cc?'اختيار ممتاز؛ الجملة مترابطة وصحيحة.':'اختيار آخر أنسب هنا: '+connectorQuestions[connectorIndex].options[connectorQuestions[connectorIndex].correct];cfb.classList.toggle('is-right',cc);cfb.classList.toggle('is-wrong',!cc);root.querySelector('[data-c2-connector-next]').disabled=false;var cs=root.querySelector('#mfkrC2Connectors .mfkr-quiz-score');if(cs)cs.textContent='Score: '+connectorScore;return;}
    if(event.target.closest('[data-c2-connector-next]')&&connectorAnswered){connectorIndex++;drawConnectors();return;}
    if(event.target.closest('[data-c2-connector-restart]')){connectorIndex=0;connectorScore=0;connectorAnswered=false;drawConnectors();return;}
    var speakingPick=event.target.closest('[data-c2-speaking]');
    if(speakingPick&&!speakingAnswered){var si=Number(speakingPick.getAttribute('data-c2-speaking')),sc=!!speakingOptions[si].correct;speakingAnswered=true;if(sc)speakingScore++;root.querySelectorAll('[data-c2-speaking]').forEach(function(btn){var k=Number(btn.getAttribute('data-c2-speaking'));btn.disabled=true;if(speakingOptions[k].correct)btn.classList.add('is-correct');else if(btn===speakingPick&&!sc)btn.classList.add('is-wrong');});var sfb=root.querySelector('#mfkrC2SpeakingFeedback');sfb.textContent=sc?'رد مناسب وواضح ومحترم.':'جرّب ردًا أوضح وأكثر احترامًا: '+speakingOptions.filter(function(o){return o.correct;})[0].text;sfb.classList.toggle('is-right',sc);sfb.classList.toggle('is-wrong',!sc);root.querySelector('[data-c2-speaking-next]').disabled=false;var ss=root.querySelector('#mfkrC2Speaking .mfkr-quiz-score');if(ss)ss.textContent='Score: '+speakingScore;return;}
    if(event.target.closest('[data-c2-speaking-next]')&&speakingAnswered){speakingIndex++;drawSpeaking();return;}
    if(event.target.closest('[data-c2-speaking-restart]')){speakingIndex=0;speakingScore=0;speakingAnswered=false;drawSpeaking();return;}
    if(event.target.closest('[data-c2-writing-save]')){writingDraft=root.querySelector('#mfkrC2WritingDraft').value;updateWritingCount();if(wordCount(writingDraft)>=40)markActivity('writing');saveProgress();var saveBtn=root.querySelector('[data-c2-writing-save]');saveBtn.textContent='✓ تم حفظ المسودة';setTimeout(function(){if(saveBtn&&saveBtn.isConnected)saveBtn.textContent='💾 احفظ فقرتي';},1600);return;}
    if(event.target.closest('[data-c2-writing-clear]')){writingDraft='';var draft=root.querySelector('#mfkrC2WritingDraft');if(draft)draft.value='';updateWritingCount();saveProgress();return;}
    var rubricCheck=event.target.closest('[data-c2-writing-rubric-check]');if(rubricCheck){var rubricItems=Array.prototype.slice.call(root.querySelectorAll('[data-c2-rubric-item]')),rubricDone=rubricItems.filter(function(item){return item.checked;}).length,writingWords=wordCount(String((root.querySelector('#mfkrC2WritingDraft')||{}).value||writingDraft)),rubricFeedback=root.querySelector('#mfkrC2RubricFeedback');if(rubricFeedback){if(rubricDone===4&&writingWords>=80&&writingWords<=120){rubricFeedback.textContent='ممتاز! اكتملت المعايير الأربعة وطول الفقرة مناسب: '+writingWords+' كلمة.';rubricFeedback.classList.add('is-right');rubricFeedback.classList.remove('is-wrong');if(typeof journeyRecord==='function')journeyRecord('activity:c2-writing-rubric',null,'C2');}else if(rubricDone===4){rubricFeedback.textContent='كل المعايير محددة؛ راجع طول الفقرة ليكون بين 80 و120 كلمة. عدد الكلمات الحالي: '+writingWords+'.';rubricFeedback.classList.remove('is-right');rubricFeedback.classList.add('is-wrong');}else{rubricFeedback.textContent='راجعت '+rubricDone+' من 4 معايير. أكمل المراجعة ثم افحص طول الفقرة.';rubricFeedback.classList.remove('is-right');rubricFeedback.classList.add('is-wrong');}}return;}var finalPick=event.target.closest('[data-c2-quiz]');
    if(finalPick&&!quizAnswered){var qi=Number(finalPick.getAttribute('data-c2-quiz')),qc=!!quizOptions[qi].correct;quizAnswered=true;if(qc)quizScore++;root.querySelectorAll('[data-c2-quiz]').forEach(function(btn){var k=Number(btn.getAttribute('data-c2-quiz'));btn.disabled=true;if(quizOptions[k].correct)btn.classList.add('is-correct');else if(btn===finalPick&&!qc)btn.classList.add('is-wrong');});var qfb=root.querySelector('#mfkrC2QuizFeedback');qfb.textContent=qc?'إجابة ممتازة!':'الإجابة الصحيحة: '+quizOptions.filter(function(o){return o.correct;})[0].text;qfb.classList.toggle('is-right',qc);qfb.classList.toggle('is-wrong',!qc);var qscore=root.querySelector('#mfkrC2Quiz .mfkr-quiz-score');if(qscore)qscore.textContent='Score: '+quizScore;root.querySelector('[data-c2-quiz-next]').disabled=false;return;}
    if(event.target.closest('[data-c2-quiz-next]')&&quizAnswered){quizIndex++;drawFinalQuiz();return;}
    if(event.target.closest('[data-c2-quiz-restart]')){quizIndex=0;quizScore=0;quizAnswered=false;drawFinalQuiz();return;}
  });
}

function renderB2(){
  document.title='B2 — Reading Builders | Mr. Fluent Kids';
  var vocab=[
    {word:'discover',meaning:'يكتشف',pic:'🔎',topic:'reading',example:'We discover new facts in books.',ar:'نكتشف حقائق جديدة في الكتب.'},
    {word:'carefully',meaning:'بعناية',pic:'🧐',topic:'reading',example:'Read the instructions carefully.',ar:'اقرأ التعليمات بعناية.'},
    {word:'detail',meaning:'تفصيل',pic:'🧩',topic:'reading',example:'One small detail helped me solve the puzzle.',ar:'ساعدني تفصيل صغير في حل اللغز.'},
    {word:'decide',meaning:'يقرّر',pic:'💡',topic:'reading',example:'Nour decided to visit the library.',ar:'قررت نور زيارة المكتبة.'},
    {word:'journey',meaning:'رحلة',pic:'🧭',topic:'world',example:'Our journey began early in the morning.',ar:'بدأت رحلتنا في الصباح الباكر.'},
    {word:'entrance',meaning:'مدخل',pic:'🚪',topic:'world',example:'Meet me at the entrance.',ar:'قابلني عند المدخل.'},
    {word:'crowded',meaning:'مزدحم',pic:'👥',topic:'world',example:'The market was crowded on Friday.',ar:'كان السوق مزدحمًا يوم الجمعة.'},
    {word:'quiet',meaning:'هادئ',pic:'🌿',topic:'world',example:'We found a quiet place to read.',ar:'وجدنا مكانًا هادئًا للقراءة.'},
    {word:'protect',meaning:'يحمي',pic:'🛡️',topic:'nature',example:'Trees protect small animals from the sun.',ar:'تحمي الأشجار الحيوانات الصغيرة من الشمس.'},
    {word:'environment',meaning:'البيئة',pic:'🌍',topic:'nature',example:'We can help the environment.',ar:'يمكننا المساعدة في حماية البيئة.'},
    {word:'reduce',meaning:'يقلّل',pic:'♻️',topic:'nature',example:'We reduce waste by reusing bags.',ar:'نقلّل النفايات بإعادة استخدام الأكياس.'},
    {word:'solution',meaning:'حل',pic:'✅',topic:'nature',example:'Working together can find a solution.',ar:'يمكن للعمل معًا أن يجد حلًا.'}
  ];
  var topics=[['all','All words','كل الكلمات'],['reading','Reading Skills','مهارات القراءة'],['world','Places & Travel','الأماكن والرحلات'],['nature','Nature & Solutions','الطبيعة والحلول']];
  var passages=[
    {title:'The Missing Notebook',arTitle:'الكشكول المفقود',icon:'📓',lines:[
      {en:'On Monday, Lina could not find her science notebook.',ar:'يوم الاثنين، لم تستطع لينا العثور على كشكول العلوم.'},
      {en:'She checked her bag carefully, but it was not there.',ar:'فتّشت حقيبتها بعناية، لكنه لم يكن هناك.'},
      {en:'Her friend Adam remembered seeing it near the library entrance.',ar:'تذكّر صديقها آدم أنه رآه بالقرب من مدخل المكتبة.'},
      {en:'They asked the librarian, who found the notebook on a quiet reading table.',ar:'سألا أمين المكتبة، الذي وجد الكشكول على طاولة هادئة للقراءة.'}
    ]},
    {title:'A Cleaner School',arTitle:'مدرسة أكثر نظافة',icon:'🌱',lines:[
      {en:'The students noticed too much plastic around the school yard.',ar:'لاحظ الطلاب وجود الكثير من البلاستيك في فناء المدرسة.'},
      {en:'Their teacher asked them to discover where most of the waste came from.',ar:'طلبت منهم معلمتهم اكتشاف مصدر معظم النفايات.'},
      {en:'They placed separate boxes for paper, plastic, and food leftovers.',ar:'وضعوا صناديق منفصلة للورق والبلاستيك وبقايا الطعام.'},
      {en:'A week later, the yard was cleaner because everyone helped.',ar:'بعد أسبوع، أصبح الفناء أنظف لأن الجميع تعاونوا.'}
    ]},
    {title:'The Museum Map',arTitle:'خريطة المتحف',icon:'🗺️',lines:[
      {en:'Youssef and his cousin visited a history museum on Saturday.',ar:'زار يوسف وابن عمه متحفًا للتاريخ يوم السبت.'},
      {en:'At the entrance, they studied a map and chose three rooms to explore.',ar:'عند المدخل، درسا خريطة واختارا ثلاث قاعات لاستكشافها.'},
      {en:'They read each description carefully and wrote down an interesting detail.',ar:'قرآ كل وصف بعناية وكتبا تفصيلًا مثيرًا للاهتمام.'},
      {en:'Before leaving, they decided to return with their class.',ar:'قبل المغادرة، قررا العودة مع فصلهما.'}
    ]}
  ];
  var sequence=[
    {en:'Mariam noticed litter near the school gate.',ar:'لاحظت مريم قمامة قرب بوابة المدرسة.'},
    {en:'She asked her classmates to help.',ar:'طلبت من زملائها المساعدة.'},
    {en:'They separated paper and plastic into two boxes.',ar:'فصلوا الورق والبلاستيك في صندوقين.'},
    {en:'The entrance looked cleaner after their work.',ar:'أصبح المدخل أنظف بعد عملهم.'}
  ];
  var connectorQuestions=[
    {before:'I wanted to borrow the book,',after:'the library was closed.',ar:'أردت استعارة الكتاب، لكن المكتبة كانت مغلقة.',options:['because','but','so'],correct:1},
    {before:'We wore our coats',after:'the weather was cold.',ar:'ارتدينا معاطفنا لأن الطقس كان باردًا.',options:['because','but','and'],correct:0},
    {before:'Hana finished her project,',after:'she showed it to the teacher.',ar:'أنهت هناء مشروعها، لذلك عرضته على المعلمة.',options:['but','so','because'],correct:1},
    {before:'Omar likes reading',after:'drawing pictures.',ar:'يحب عمر القراءة والرسم.',options:['and','because','so'],correct:0}
  ];
  var quizQuestions=[
    {q:'Where was Lina’s notebook found?',ar:'أين وُجد كشكول لينا؟',opts:['Near the library entrance','On a reading table','Inside her bag'],correct:1},
    {q:'Why did the students place separate boxes?',ar:'لماذا وضع الطلاب صناديق منفصلة؟',opts:['To sort the waste','To store their books','To decorate the classroom'],correct:0},
    {q:'What does “carefully” mean?',ar:'ما معنى carefully؟',opts:['بسرعة','بعناية','بصوت مرتفع'],correct:1},
    {q:'What did Youssef and his cousin use at the museum?',ar:'ماذا استخدم يوسف وابن عمه في المتحف؟',opts:['A timetable','A map','A recipe'],correct:1},
    {q:'Which word means “حل”؟',ar:'أي كلمة معناها حل؟',opts:['Entrance','Detail','Solution'],correct:2},
    {q:'Choose the best connector: “It was raining, ___ we stayed inside.”',ar:'اختر أداة الربط المناسبة: كانت السماء تمطر، لذلك بقينا بالداخل.',opts:['so','but','because'],correct:0},
    {q:'What helped make the school yard cleaner?',ar:'ما الذي ساعد في جعل فناء المدرسة أنظف؟',opts:['Everyone helped','The students left early','The teacher closed the gate'],correct:0},
    {q:'What is the main idea of the museum passage?',ar:'ما الفكرة الرئيسية لفقرة المتحف؟',opts:['Planning a visit and learning from exhibits','Buying a new notebook','Cleaning a crowded market'],correct:0}
  ];
  var currentTopic='all',viewedWords=[],completedActivities=[],bestQuizScore=0,quizAttempts=0;
  var readPassages=[],sequenceOrder=[],sequenceChosen=[],connectIndex=0,connectScore=0,connectAnswered=false,quizIndex=0,quizScore=0,quizAnswered=false,quizOptions=[];
  var progressUserId=null,progressKey='mrfluent-growing-b2-progress:guest',saveTimer=null,b2SummaryDraft='',b2SummaryKey='mfkr-b2-summary-draft:guest';
  function updateB2Summary(){var field=root.querySelector('#mfkrB2SummaryDraft'),count=root.querySelector('#mfkrB2SummaryCount');if(count){var words=String(field&&field.value||b2SummaryDraft).trim().match(/\S+/g);count.textContent=(words?words.length:0)+' words';}}
  function loadB2Summary(){try{b2SummaryDraft=localStorage.getItem(b2SummaryKey)||'';var field=root.querySelector('#mfkrB2SummaryDraft');if(field)field.value=b2SummaryDraft;}catch(_){}updateB2Summary();}
  function shuffledB2(items){var result=items.slice();for(var i=result.length-1;i>0;i--){var j=Math.floor(Math.random()*(i+1)),tmp=result[i];result[i]=result[j];result[j]=tmp;}return result;}
  function speakB2(text,rate){
    var status=root.querySelector('#mfkrB2AudioStatus');
    if(!('speechSynthesis' in window)||!('SpeechSynthesisUtterance' in window)){if(status)status.textContent='النطق الصوتي غير مدعوم في هذا المتصفح.';return;}
    window.speechSynthesis.cancel();var utterance=new SpeechSynthesisUtterance(text);mfkrSelectEnglishVoice(utterance);utterance.lang='en-US';utterance.rate=rate||.82;utterance.pitch=1.02;
    utterance.onstart=function(){if(status)status.textContent='🔊 Listening: '+text;};
    utterance.onend=function(){if(status)status.textContent='اضغط على زر الصوت للاستماع مرة أخرى.';};
    utterance.onerror=function(){if(status)status.textContent='تعذّر تشغيل الصوت. جرّب مرة أخرى.';};
    window.speechSynthesis.speak(utterance);
  }
  function completedCount(){return ['reading','story-order','connectors','reading-challenge'].filter(function(key){return completedActivities.indexOf(key)>=0;}).length;}
  function drawProgress(){
    var words=root.querySelector('#mfkrB2ProgressWords'),activities=root.querySelector('#mfkrB2ProgressActivities'),bar=root.querySelector('#mfkrB2ProgressBar'),best=root.querySelector('#mfkrB2BestScore'),attempts=root.querySelector('#mfkrB2Attempts'),status=root.querySelector('#mfkrB2SaveStatus');
    if(words)words.textContent=viewedWords.length+' / '+vocab.length+' words explored';
    if(activities)activities.textContent=completedCount()+' / 5 activities completed';
    if(bar)bar.style.width=Math.round(viewedWords.length/vocab.length*100)+'%';
    if(best)best.textContent=bestQuizScore+' / 8';if(attempts)attempts.textContent=quizAttempts;
    if(status&&!progressUserId)status.textContent='التقدّم محفوظ على هذا الجهاز. سجّل الدخول لمزامنته مع حسابك.';
  }
  function saveProgress(){
    var record={viewedWords:viewedWords,completedActivities:completedActivities,readPassages:readPassages,bestQuizScore:bestQuizScore,quizAttempts:quizAttempts};
    try{localStorage.setItem(progressKey,JSON.stringify(record));}catch(_){}
    drawProgress();
    if(!progressUserId||typeof sb==='undefined'||!sb||!sb.from)return;
    if(saveTimer)clearTimeout(saveTimer);
    var status=root.querySelector('#mfkrB2SaveStatus');if(status)status.textContent='جارٍ حفظ تقدّمك في حسابك…';
    saveTimer=setTimeout(async function(){
      try{
        var session=await sb.auth.getSession(),active=session&&session.data&&session.data.session&&session.data.session.user;
        if(!active||active.id!==progressUserId)return;
        var payload={user_id:progressUserId,level_code:'B2',completed_words:viewedWords,completed_activities:completedActivities.concat(readPassages.map(function(n){return 'reading-'+n;})),best_quiz_score:bestQuizScore,quiz_attempts:quizAttempts,updated_at:new Date().toISOString()};
        var response=await sb.from('mrfluent_growing_b2_progress').upsert(payload,{onConflict:'user_id,level_code'});
        if(response.error)throw response.error;
        if(status)status.textContent='تم حفظ تقدّمك في حسابك ✓';
      }catch(error){console.warn('B2 progress sync failed; local progress remains saved.',error);if(status)status.textContent='التقدّم محفوظ على هذا الجهاز؛ تعذّرت المزامنة مؤقتًا.';}
    },350);
  }
  function markWord(word){if(vocab.some(function(v){return v.word===word;})&&viewedWords.indexOf(word)<0){viewedWords.push(word);saveProgress();}}
  function markActivity(key){if(completedActivities.indexOf(key)<0){completedActivities.push(key);saveProgress();}}
  function initializeProgress(){
    (async function(){
      var user=null;
      try{if(typeof sessionUser!=='undefined'&&sessionUser)user=sessionUser;if(!user&&typeof sb!=='undefined'&&sb&&sb.auth){var session=await sb.auth.getSession();user=session&&session.data&&session.data.session&&session.data.session.user||null;}}catch(_){}
      progressUserId=user&&user.id||null;progressKey='mrfluent-growing-b2-progress:'+(progressUserId||'guest');b2SummaryKey='mfkr-b2-summary-draft:'+(progressUserId||'guest');loadB2Summary();
      try{
        var local=JSON.parse(localStorage.getItem(progressKey)||'{}');
        viewedWords=Array.isArray(local.viewedWords)?local.viewedWords.filter(function(w){return vocab.some(function(v){return v.word===w;});}):[];
        completedActivities=Array.isArray(local.completedActivities)?local.completedActivities.filter(function(a){return ['reading','story-order','connectors','reading-challenge','summary'].indexOf(a)>=0;}):[];
        readPassages=Array.isArray(local.readPassages)?local.readPassages.filter(function(n){return n>=0&&n<passages.length;}):[];
        bestQuizScore=Math.max(0,Math.min(8,Number(local.bestQuizScore)||0));quizAttempts=Math.max(0,Number(local.quizAttempts)||0);
      }catch(_){}
      drawProgress();
      if(progressUserId&&typeof sb!=='undefined'&&sb&&sb.from){
        try{
          var remote=await sb.from('mrfluent_growing_b2_progress').select('completed_words,completed_activities,best_quiz_score,quiz_attempts').eq('user_id',progressUserId).eq('level_code','B2').maybeSingle();
          if(remote.error)throw remote.error;
          if(remote.data){
            viewedWords=Array.from(new Set(viewedWords.concat(Array.isArray(remote.data.completed_words)?remote.data.completed_words:[]))).filter(function(w){return vocab.some(function(v){return v.word===w;});});
            var acts=Array.isArray(remote.data.completed_activities)?remote.data.completed_activities:[];
            completedActivities=Array.from(new Set(completedActivities.concat(acts.filter(function(a){return ['reading','story-order','connectors','reading-challenge','summary'].indexOf(a)>=0;}))));
            readPassages=Array.from(new Set(readPassages.concat(acts.filter(function(a){return /^reading-[0-2]$/.test(a);}).map(function(a){return Number(a.slice(8));}))));
            bestQuizScore=Math.max(bestQuizScore,Number(remote.data.best_quiz_score)||0);quizAttempts=Math.max(quizAttempts,Number(remote.data.quiz_attempts)||0);
          }
          readPassages.forEach(function(index){var button=root.querySelector('[data-b2-read-done="'+index+'"]');if(button){button.textContent='✓ Completed';button.disabled=true;}});
          saveProgress();
        }catch(error){console.warn('B2 remote progress could not be loaded.',error);var status=root.querySelector('#mfkrB2SaveStatus');if(status)status.textContent='التقدّم المحلي متاح؛ ستتم محاولة المزامنة عند توفر الاتصال.';}
      }
    })();
  }
  function renderVocab(){
    var list=currentTopic==='all'?vocab:vocab.filter(function(v){return v.topic===currentTopic;});
    root.querySelector('#mfkrB2WordGrid').innerHTML=list.map(function(v){return '<article class="mfkr-word-card"><div class="mfkr-word-card-head"><span class="mfkr-word-picture" aria-hidden="true">'+v.pic+'</span><span class="mfkr-word-tag">'+esc(v.topic==='reading'?'READING':v.topic==='world'?'WORLD':'NATURE')+'</span></div><div class="mfkr-word">'+esc(v.word)+'</div><div class="mfkr-meaning" lang="ar">'+esc(v.meaning)+'</div><div class="mfkr-example-label">READ IT IN CONTEXT</div><div class="mfkr-example" lang="en">'+esc(v.example)+'</div><div class="mfkr-example-ar" lang="ar">'+esc(v.ar)+'</div><div class="mfkr-word-actions"><button type="button" class="mfkr-sound" data-b2-speak="'+esc(v.word)+'" data-b2-track="'+esc(v.word)+'">🔊 الكلمة</button><button type="button" class="mfkr-sound" data-b2-speak="'+esc(v.example)+'" data-b2-track="'+esc(v.word)+'">♫ المثال</button></div></article>';}).join('');
    root.querySelectorAll('[data-b2-topic]').forEach(function(button){var active=button.getAttribute('data-b2-topic')===currentTopic;button.classList.toggle('is-active',active);button.setAttribute('aria-pressed',active?'true':'false');});
    root.querySelector('#mfkrB2VisibleCount').textContent=list.length+' words';
  }
  function drawSequence(){
    var host=root.querySelector('#mfkrB2Sequence');
    if(sequenceChosen.length===sequence.length){
      host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🧩</div><h3>Story in order!</h3><div class="mfkr-ar" lang="ar">أحسنت! رتّبت الأحداث بالترتيب الصحيح.</div><p class="mfkr-quiz-feedback is-right">4 / 4 events arranged</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-b2-sequence-restart>إعادة النشاط ↻</button></div>';
      markActivity('story-order');return;
    }
    var expected=sequence[sequenceChosen.length];
    host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">EVENT '+(sequenceChosen.length+1)+' / '+sequence.length+'</span><span class="mfkr-quiz-score">Tap the first event, then the next</span></div><p class="mfkr-quiz-hint" lang="ar">اختار الحدث الذي يأتي بعده في القصة.</p><div class="mfkr-a2-story-grid">'+sequenceOrder.map(function(item){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option mfkr-b2-sequence-option" data-b2-sequence="'+item.id+'"><span lang="en">'+esc(item.en)+'</span><span class="mfkr-c1-option-ar" lang="ar">'+esc(item.ar)+'</span></button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrB2SequenceFeedback" lang="ar" aria-live="polite">ابدأ بالحدث الأول في القصة.</p>';
    var fb=root.querySelector('#mfkrB2SequenceFeedback');if(fb)fb.textContent=sequenceChosen.length?'ممتاز! اختار الحدث التالي.':'ابدأ بالحدث الأول في القصة.';
  }
  function drawConnectors(){
    var host=root.querySelector('#mfkrB2Connectors');
    if(connectIndex>=connectorQuestions.length){
      host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🔗</div><h3>Ideas connected!</h3><div class="mfkr-ar" lang="ar">أحسنت! خلصت تدريب أدوات الربط.</div><p class="mfkr-quiz-feedback is-right">Your score: '+connectScore+' / '+connectorQuestions.length+'</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-b2-connect-restart>إعادة التدريب ↻</button></div>';
      markActivity('connectors');return;
    }
    connectAnswered=false;var q=connectorQuestions[connectIndex];
    host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">CONNECTOR '+(connectIndex+1)+' / '+connectorQuestions.length+'</span><span class="mfkr-quiz-score">Score: '+connectScore+'</span></div><div class="mfkr-b2-connector-sentence" lang="en">'+esc(q.before)+' <span class="mfkr-b2-blank">_____</span> '+esc(q.after)+'</div><p class="mfkr-quiz-hint" lang="ar">'+esc(q.ar)+'</p><div class="mfkr-quiz-options mfkr-c1-options">'+q.options.map(function(option,index){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option" data-b2-connector="'+index+'">'+esc(option)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrB2ConnectorFeedback" lang="ar" aria-live="polite">اختار أداة الربط المناسبة.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-b2-connect-next disabled>السؤال التالي ←</button></div>';
  }
  function drawQuiz(){
    var host=root.querySelector('#mfkrB2Quiz');
    if(quizIndex>=quizQuestions.length){
      quizAttempts++;bestQuizScore=Math.max(bestQuizScore,quizScore);markActivity('reading-challenge');saveProgress();
      host.innerHTML='<div class="mfkr-c1-finish"><div class="mfkr-art" aria-hidden="true">🏆</div><h3>Reading Star!</h3><div class="mfkr-ar" lang="ar">أحسنت! أنهيت تحدّي القراءة والفهم.</div><p class="mfkr-quiz-feedback is-right">Your score: '+quizScore+' / 8 · Best: '+bestQuizScore+' / 8</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-b2-quiz-restart>إعادة الاختبار ↻</button></div>';return;
    }
    quizAnswered=false;var q=quizQuestions[quizIndex];quizOptions=shuffledB2(q.opts.map(function(option,index){return {text:option,correct:index===q.correct};}));
    host.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">READING CHALLENGE</span><span class="mfkr-quiz-count">Question '+(quizIndex+1)+' / '+quizQuestions.length+'</span><span class="mfkr-quiz-score">Score: '+quizScore+'</span></div><h3 lang="en">'+esc(q.q)+'</h3><p class="mfkr-quiz-hint" lang="ar">'+esc(q.ar)+'</p><div class="mfkr-quiz-options mfkr-c1-options">'+quizOptions.map(function(option,index){return '<button type="button" class="mfkr-quiz-option mfkr-c1-option" data-b2-quiz="'+index+'">'+esc(option.text)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrB2QuizFeedback" lang="ar" aria-live="polite">اقرأ السؤال واختار الإجابة الصحيحة.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-b2-quiz-next disabled>السؤال التالي ←</button></div>';
  }
  root.innerHTML=shell('GROWING LEARNERS · LEVEL B2','Reading Builders.','بنّاؤو مهارات القراءة.','اقرأ لتفهم، واكتشف معاني الكلمات من السياق، ورتّب الأفكار، واربط الجمل بوضوح.','<div class="mfkr-summary mfkr-a2-summary"><span>3 reading passages</span><div class="mfkr-progress"><span id="mfkrB2ProgressBar" style="width:0%"></span></div><span id="mfkrB2ProgressWords">0 / 12 words explored</span></div><section class="mfkr-topic-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">READING LAB · معمل القراءة</div><h2>Read, Listen &amp; Understand</h2><div class="mfkr-c1-story-title-ar" lang="ar">اقرأ واستمع وافهم</div></div><span class="mfkr-art" aria-hidden="true">📚</span></div><div class="mfkr-a2-story-grid">'+passages.map(function(p,index){return '<article class="mfkr-a2-story-card"><span class="mfkr-c1-story-number">0'+(index+1)+'</span><div class="mfkr-topic-heading"><div><h3>'+esc(p.title)+'</h3><div class="mfkr-c1-story-title-ar" lang="ar">'+esc(p.arTitle)+'</div></div><span class="mfkr-art" aria-hidden="true">'+p.icon+'</span></div>'+p.lines.map(function(line){return '<div class="mfkr-c1-story-en" lang="en">'+esc(line.en)+'</div><div class="mfkr-c1-story-ar" lang="ar">'+esc(line.ar)+'</div>';}).join('')+'<div class="mfkr-c1-actions"><button type="button" class="mfkr-sound" data-b2-pass-listen="'+index+'">🔊 Listen</button><button type="button" class="mfkr-sound" data-b2-read-done="'+index+'">'+(readPassages.indexOf(index)>=0?'✓ Completed':'✓ أنهيت القراءة')+'</button></div></article>';}).join('')+'</div></section><section class="mfkr-topic-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">VOCABULARY IN CONTEXT · كلمات من السياق</div><h2>Words that build meaning</h2><div class="mfkr-c1-story-title-ar" lang="ar">تعلّم الكلمات من الأمثلة</div></div><span class="mfkr-count" id="mfkrB2VisibleCount">12 words</span></div><div class="mfkr-topics mfkr-a2-topics" role="group" aria-label="Choose vocabulary topic">'+topics.map(function(topic){return '<button type="button" class="mfkr-topic'+(topic[0]==='all'?' is-active':'')+'" data-b2-topic="'+topic[0]+'" aria-pressed="'+(topic[0]==='all'?'true':'false')+'"><span>'+topic[1]+'</span>'+topic[2]+'</button>';}).join('')+'</div></section><div class="mfkr-word-grid" id="mfkrB2WordGrid"></div><p class="mfkr-audio-status" id="mfkrB2AudioStatus" aria-live="polite">اضغط على الكلمة لسماع النطق، وراجع المثال لمعرفة استخدامها.</p><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 01 · PUT THE STORY IN ORDER</div><h2>Story Sequence <span aria-hidden="true">✦</span></h2><p lang="ar">رتّب أحداث القصة بالنقر عليها من البداية إلى النهاية.</p></div><div id="mfkrB2Sequence"></div></section><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 02 · CONNECT YOUR IDEAS</div><h2>Connector Lab <span aria-hidden="true">✦</span></h2><p lang="ar">تدرّب على and وbut وbecause وso عشان تربط أفكارك بطريقة صحيحة.</p></div><div id="mfkrB2Connectors"></div></section><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">ACTIVITY 03 · FINAL READING CHALLENGE</div><h2>Reading Challenge <span aria-hidden="true">✦</span></h2><p lang="ar">ثمانية أسئلة في فهم النصوص والمفردات وأدوات الربط.</p></div><div id="mfkrB2Quiz"></div></section><section class="mfkr-topic-panel mfkr-b2-summary-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">ACTIVITY 04 · SUMMARY &amp; EVIDENCE</div><h2>Reading Detective: Summarise</h2><div class="mfkr-c1-story-title-ar" lang="ar">اكتب ملخصًا من جملتين، ثم تأكد من الفكرة الرئيسية وتفصيل يدعمها.</div></div><span class="mfkr-art" aria-hidden="true">🧠</span></div><p class="mfkr-c1-story-en" lang="en">Use the library passage. Explain what the students did and give one result that proves the plan helped.</p><textarea id="mfkrB2SummaryDraft" class="mfkr-c2-writing-area" rows="4" maxlength="1200" placeholder="The students asked residents what they needed. After the trial, …"></textarea><div class="mfkr-c2-writing-meta"><span id="mfkrB2SummaryCount">0 words</span><span>Aim for 25–45 words.</span></div><div class="mfkr-c1-actions"><label style="display:flex;align-items:center;gap:7px;color:#d8c6e8"><input type="checkbox" id="mfkrB2SummaryMainIdea"> ذكرت الفكرة الرئيسية</label><label style="display:flex;align-items:center;gap:7px;color:#d8c6e8"><input type="checkbox" id="mfkrB2SummaryEvidence"> ذكرت نتيجة أو دليلًا من النص</label><button type="button" class="mfkr-btn mfkr-btn-primary" data-b2-summary-check>راجع ملخصي ✓</button></div><p class="mfkr-quiz-feedback" id="mfkrB2SummaryFeedback" lang="ar" aria-live="polite">بعد الكتابة، راجع الفكرة الرئيسية والدليل والطول قبل إكمال النشاط.</p><details class="mfkr-topic-panel" style="margin-top:12px"><summary style="cursor:pointer;color:#d9baff;font-weight:900;padding:8px">قارن بملخص نموذجي / Show a model summary</summary><p class="mfkr-c1-story-en" lang="en" style="margin-top:10px">The students asked local families what they needed, then used the evidence to improve the library. After a three-month trial, more people visited and volunteers organised weekly activities.</p><p class="mfkr-c1-story-ar" lang="ar">سأل الطلاب العائلات عمّا تحتاج إليه، ثم استخدموا الأدلة لتحسين المكتبة. وبعد تجربة استمرت ثلاثة أشهر، زاد عدد الزوار ونظّم المتطوعون أنشطة أسبوعية.</p></details></section><section class="mfkr-topic-panel mfkr-a2-progress-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">MY PROGRESS · تقدّمي</div><h2>Your reading journey</h2><div class="mfkr-c1-story-title-ar" lang="ar">كل قراءة جديدة توسّع فهمك</div></div><span class="mfkr-art" aria-hidden="true">⭐</span></div><div class="mfkr-a2-progress-detail"><span id="mfkrB2ProgressActivities">0 / 5 activities completed</span><span>Best challenge score: <strong id="mfkrB2BestScore">0 / 8</strong></span><span>Total attempts: <strong id="mfkrB2Attempts">0</strong></span></div><p class="mfkr-audio-status" id="mfkrB2SaveStatus" aria-live="polite">جارٍ تحميل تقدّمك…</p></section>'+backButtons(url('older'),'← الرجوع إلى Growing Learners')+'<div class="mfkr-note">نصيحة: اقرأ الفقرة مرة بنفسك، ثم استمع إليها، وبعدها حاول تلخيص فكرتها في جملة واحدة.</div>');
  var progressDraw=drawProgress;
  drawProgress=function(){progressDraw();};
  renderVocab();updateB2Summary();
  sequenceOrder=shuffledB2(sequence.map(function(item,index){return {id:index,en:item.en,ar:item.ar};}));
  drawSequence();drawConnectors();drawQuiz();initializeProgress();
  root.addEventListener('click',function(event){
    if(event.target.closest('[data-b2-summary-check]')){b2SummaryDraft=String((root.querySelector('#mfkrB2SummaryDraft')||{}).value||'');var summaryWords=b2SummaryDraft.trim().match(/\S+/g)||[],mainIdea=!!(root.querySelector('#mfkrB2SummaryMainIdea')||{}).checked,evidence=!!(root.querySelector('#mfkrB2SummaryEvidence')||{}).checked;var summaryFeedback=root.querySelector('#mfkrB2SummaryFeedback');if(summaryWords.length<25||summaryWords.length>45){if(summaryFeedback){summaryFeedback.textContent='اضبط الملخص ليكون من 25 إلى 45 كلمة، مع الفكرة الرئيسية ونتيجة من النص.';summaryFeedback.classList.remove('is-right');summaryFeedback.classList.add('is-wrong');}}else if(!mainIdea||!evidence){if(summaryFeedback){summaryFeedback.textContent='الطول مناسب. ضع علامة على الفكرة الرئيسية والدليل بعد التأكد من وجودهما في كتابتك.';summaryFeedback.classList.remove('is-right');summaryFeedback.classList.add('is-wrong');}}else{if(summaryFeedback){summaryFeedback.textContent='ممتاز! تحقّقت من الطول والفكرة الرئيسية والدليل. قارن بملخص نموذجي عند الحاجة.';summaryFeedback.classList.add('is-right');summaryFeedback.classList.remove('is-wrong');}markActivity('summary');if(typeof journeyRecord==='function')journeyRecord('activity:b2-summary',null,'B2');}try{localStorage.setItem(b2SummaryKey,b2SummaryDraft);}catch(_){}return;}var topicButton=event.target.closest('[data-b2-topic]');
    if(topicButton){currentTopic=topicButton.getAttribute('data-b2-topic');renderVocab();return;}
    var wordSound=event.target.closest('[data-b2-speak]');
    if(wordSound){var sound=wordSound.getAttribute('data-b2-speak');markWord(wordSound.getAttribute('data-b2-track')||sound);speakB2(sound,sound.length>18?.86:.78);return;}
    var listenPassage=event.target.closest('[data-b2-pass-listen]');
    if(listenPassage){var pi=Number(listenPassage.getAttribute('data-b2-pass-listen'));if(passages[pi])speakB2(passages[pi].lines.map(function(line){return line.en;}).join(' '),.78);return;}
    var readDone=event.target.closest('[data-b2-read-done]');
    if(readDone){var ri=Number(readDone.getAttribute('data-b2-read-done'));if(readPassages.indexOf(ri)<0)readPassages.push(ri);readDone.textContent='✓ Completed';readDone.disabled=true;if(readPassages.length===passages.length)markActivity('reading');saveProgress();return;}
    var sequenceButton=event.target.closest('[data-b2-sequence]');
    if(sequenceButton&&sequenceChosen.length<sequence.length){
      var eventId=Number(sequenceButton.getAttribute('data-b2-sequence')),expected=sequence[sequenceChosen.length];
      var fb=root.querySelector('#mfkrB2SequenceFeedback');
      if(expected&&eventId===sequenceChosen.length){
        sequenceChosen.push(eventId);sequenceOrder=sequenceOrder.filter(function(item){return item.id!==eventId;});drawSequence();
      }else if(fb){fb.textContent='مش ده الحدث التالي. اقرأ الجمل تاني وحاول ترتّب الأحداث.';fb.classList.add('is-wrong');}
      return;
    }
    if(event.target.closest('[data-b2-sequence-restart]')){sequenceChosen=[];sequenceOrder=shuffledB2(sequence.map(function(item,index){return {id:index,en:item.en,ar:item.ar};}));drawSequence();return;}
    var connectorOption=event.target.closest('[data-b2-connector]');
    if(connectorOption&&!connectAnswered&&connectIndex<connectorQuestions.length){
      var q=connectorQuestions[connectIndex],selected=Number(connectorOption.getAttribute('data-b2-connector')),correct=selected===q.correct;
      connectAnswered=true;if(correct)connectScore++;
      root.querySelectorAll('[data-b2-connector]').forEach(function(button){button.disabled=true;var idx=Number(button.getAttribute('data-b2-connector'));if(idx===q.correct)button.classList.add('is-correct');else if(button===connectorOption&&!correct)button.classList.add('is-wrong');});
      var cf=root.querySelector('#mfkrB2ConnectorFeedback');cf.textContent=correct?'ممتاز! أداة الربط صحيحة.':'الإجابة الصحيحة: '+q.options[q.correct];cf.classList.toggle('is-right',correct);cf.classList.toggle('is-wrong',!correct);
      root.querySelector('.mfkr-quiz-next-row [data-b2-connect-next]').disabled=false;
      var scoreEl=root.querySelector('#mfkrB2Connectors .mfkr-quiz-score');if(scoreEl)scoreEl.textContent='Score: '+connectScore;return;
    }
    if(event.target.closest('[data-b2-connect-next]')&&connectAnswered){connectIndex++;drawConnectors();return;}
    if(event.target.closest('[data-b2-connect-restart]')){connectIndex=0;connectScore=0;connectAnswered=false;drawConnectors();return;}
    var quizOption=event.target.closest('[data-b2-quiz]');
    if(quizOption&&!quizAnswered&&quizIndex<quizQuestions.length){
      var chosen=Number(quizOption.getAttribute('data-b2-quiz')),isCorrect=!!quizOptions[chosen].correct;quizAnswered=true;if(isCorrect)quizScore++;
      root.querySelectorAll('[data-b2-quiz]').forEach(function(button){button.disabled=true;var idx=Number(button.getAttribute('data-b2-quiz'));if(quizOptions[idx].correct)button.classList.add('is-correct');else if(button===quizOption&&!isCorrect)button.classList.add('is-wrong');});
      var qf=root.querySelector('#mfkrB2QuizFeedback');qf.textContent=isCorrect?'ممتاز! إجابة صحيحة ✨':'الإجابة الصحيحة: '+quizOptions.filter(function(o){return o.correct;})[0].text;qf.classList.toggle('is-right',isCorrect);qf.classList.toggle('is-wrong',!isCorrect);
      var qs=root.querySelector('#mfkrB2Quiz .mfkr-quiz-score');if(qs)qs.textContent='Score: '+quizScore;
      root.querySelector('[data-b2-quiz-next]').disabled=false;return;
    }
    if(event.target.closest('[data-b2-quiz-next]')&&quizAnswered){quizIndex++;drawQuiz();return;}
    if(event.target.closest('[data-b2-quiz-restart]')){quizIndex=0;quizScore=0;quizAnswered=false;drawQuiz();return;}
  });
  root.addEventListener('input',function(event){if(event.target&&event.target.id==='mfkrB2SummaryDraft'){b2SummaryDraft=event.target.value;updateB2Summary();try{localStorage.setItem(b2SummaryKey,b2SummaryDraft);}catch(_){}}});
}

function renderB1(){
  document.title='B1 — My First Words | Mr. Fluent Kids';
  var words=[
    {word:'mother',meaning:'أم',picture:'👩',category:'family',example:'This is my mother.',sentence:'هذه أمي.'},
    {word:'father',meaning:'أب',picture:'👨',category:'family',example:'My father is kind.',sentence:'أبي طيب.'},
    {word:'sister',meaning:'أخت',picture:'👧',category:'family',example:'My sister can read.',sentence:'أختي تستطيع القراءة.'},
    {word:'brother',meaning:'أخ',picture:'👦',category:'family',example:'My brother likes to play.',sentence:'أخي يحب اللعب.'},
    {word:'baby',meaning:'طفل رضيع',picture:'👶',category:'family',example:'The baby is sleeping.',sentence:'الطفل الرضيع نائم.'},
    {word:'apple',meaning:'تفاحة',picture:'🍎',category:'food',example:'I eat an apple.',sentence:'أنا آكل تفاحة.'},
    {word:'bread',meaning:'خبز',picture:'🍞',category:'food',example:'I like fresh bread.',sentence:'أنا أحب الخبز الطازج.'},
    {word:'milk',meaning:'لبن',picture:'🥛',category:'food',example:'I drink milk every day.',sentence:'أنا أشرب اللبن كل يوم.'},
    {word:'water',meaning:'ماء',picture:'💧',category:'food',example:'Please give me some water.',sentence:'من فضلك أعطني بعض الماء.'},
    {word:'banana',meaning:'موزة',picture:'🍌',category:'food',example:'The banana is yellow.',sentence:'الموزة لونها أصفر.'},
    {word:'cat',meaning:'قطة',picture:'🐱',category:'animals',example:'The cat is small.',sentence:'القطة صغيرة.'},
    {word:'dog',meaning:'كلب',picture:'🐶',category:'animals',example:'The dog can run.',sentence:'الكلب يستطيع الجري.'},
    {word:'bird',meaning:'طائر',picture:'🐦',category:'animals',example:'The bird can fly.',sentence:'الطائر يستطيع الطيران.'},
    {word:'fish',meaning:'سمكة',picture:'🐟',category:'animals',example:'The fish is in the water.',sentence:'السمكة في الماء.'},
    {word:'rabbit',meaning:'أرنب',picture:'🐰',category:'animals',example:'The rabbit can jump.',sentence:'الأرنب يستطيع القفز.'},
    {word:'eat',meaning:'يأكل',picture:'🍽️',category:'actions',example:'I eat with my family.',sentence:'أنا آكل مع عائلتي.'},
    {word:'drink',meaning:'يشرب',picture:'🥤',category:'actions',example:'I drink water.',sentence:'أنا أشرب الماء.'},
    {word:'read',meaning:'يقرأ',picture:'📚',category:'actions',example:'I read a story.',sentence:'أنا أقرأ قصة.'},
    {word:'play',meaning:'يلعب',picture:'🧩',category:'actions',example:'We play together.',sentence:'نحن نلعب معًا.'},
    {word:'sleep',meaning:'ينام',picture:'🌙',category:'actions',example:'I sleep at night.',sentence:'أنا أنام ليلًا.'},
    {word:'blue',meaning:'أزرق',picture:'🟦',category:'colours',example:'The sky is blue.',sentence:'السماء زرقاء.'},
    {word:'green',meaning:'أخضر',picture:'🍀',category:'colours',example:'The leaf is green.',sentence:'الورقة خضراء.'},
    {word:'yellow',meaning:'أصفر',picture:'🌞',category:'colours',example:'The sun looks yellow.',sentence:'تبدو الشمس صفراء.'},
    {word:'black',meaning:'أسود',picture:'⚫',category:'colours',example:'My shoes are black.',sentence:'حذائي أسود.'},
    {word:'one',meaning:'واحد',picture:'1️⃣',category:'numbers',example:'I have one pencil.',sentence:'لديّ قلم رصاص واحد.'},
    {word:'two',meaning:'اثنان',picture:'2️⃣',category:'numbers',example:'I can see two birds.',sentence:'أستطيع أن أرى طائرين.'},
    {word:'three',meaning:'ثلاثة',picture:'3️⃣',category:'numbers',example:'We have three books.',sentence:'لدينا ثلاثة كتب.'},
    {word:'four',meaning:'أربعة',picture:'4️⃣',category:'numbers',example:'Four friends play together.',sentence:'أربعة أصدقاء يلعبون معًا.'},
    {word:'ten',meaning:'عشرة',picture:'🔟',category:'numbers',example:'I count to ten.',sentence:'أعدّ حتى عشرة.'},
    {word:'head',meaning:'رأس',picture:'🙂',category:'body',example:'Touch your head.',sentence:'المس رأسك.'},
    {word:'hand',meaning:'يد',picture:'✋',category:'body',example:'Raise your hand.',sentence:'ارفع يدك.'},
    {word:'eye',meaning:'عين',picture:'👁️',category:'body',example:'I have two eyes.',sentence:'لديّ عينان.'},
    {word:'foot',meaning:'قدم',picture:'🦶',category:'body',example:'My foot is warm.',sentence:'قدمي دافئة.'},
    {word:'shirt',meaning:'قميص',picture:'👕',category:'clothes',example:'My shirt is clean.',sentence:'قميصي نظيف.'},
    {word:'shoes',meaning:'حذاء',picture:'👟',category:'clothes',example:'These shoes are new.',sentence:'هذا الحذاء جديد.'},
    {word:'hat',meaning:'قبعة',picture:'🧢',category:'clothes',example:'I wear a hat outside.',sentence:'أرتدي قبعة في الخارج.'},
    {word:'socks',meaning:'جوارب',picture:'🧦',category:'clothes',example:'My socks are blue.',sentence:'جواربي زرقاء.'},
    {word:'pencil',meaning:'قلم رصاص',picture:'✏️',category:'school',example:'I write with a pencil.',sentence:'أكتب بقلم رصاص.'},
    {word:'teacher',meaning:'معلّم',picture:'👩‍🏫',category:'school',example:'Our teacher is helpful.',sentence:'معلّمنا متعاون.'},
    {word:'desk',meaning:'مكتب دراسي',picture:'🪑',category:'school',example:'My book is on the desk.',sentence:'كتابي على المكتب.'},
    {word:'ruler',meaning:'مسطرة',picture:'📏',category:'school',example:'Use a ruler to draw a line.',sentence:'استخدم مسطرة لرسم خط.'},
    {word:'sunny',meaning:'مشمس',picture:'☀️',category:'weather',example:'It is sunny today.',sentence:'الجو مشمس اليوم.'},
    {word:'rainy',meaning:'ممطر',picture:'🌧️',category:'weather',example:'It is rainy in winter.',sentence:'الجو ممطر في الشتاء.'},
    {word:'windy',meaning:'عاصف',picture:'🌬️',category:'weather',example:'It is windy outside.',sentence:'الجو عاصف في الخارج.'},
    {word:'cloudy',meaning:'غائم',picture:'☁️',category:'weather',example:'The sky is cloudy.',sentence:'السماء غائمة.'},
    {word:'cold',meaning:'بارد',picture:'🥶',category:'weather',example:'It is cold today.',sentence:'الجو بارد اليوم.'},
    {word:'door',meaning:'باب',picture:'🚪',category:'home',example:'Close the door, please.',sentence:'أغلق الباب من فضلك.'},
    {word:'room',meaning:'غرفة',picture:'🛏️',category:'home',example:'My room is tidy.',sentence:'غرفتي مرتبة.'},
    {word:'bed',meaning:'سرير',picture:'🛏️',category:'home',example:'I make my bed every morning.',sentence:'أرتّب سريري كل صباح.'},
    {word:'chair',meaning:'كرسي',picture:'🪑',category:'home',example:'Please sit on the chair.',sentence:'من فضلك اجلس على الكرسي.'}
  ];
  var topics=[['all','✨','كل الكلمات'],['family','🏡','العيلة'],['food','🍎','الأكل والشرب'],['animals','🐾','الحيوانات'],['actions','⚡','الأفعال'],['colours','🎨','الألوان'],['numbers','🔢','الأرقام'],['body','🖐️','الجسم'],['clothes','👕','الملابس'],['school','✏️','المدرسة'],['weather','🌦️','الطقس'],['home','🏠','البيت']];
  var activeTopic='all';
  var quizIndex=0,quizScore=0,quizAnswered=false,quizOrder=[];
  function shuffled(list){return list.slice().sort(function(){return Math.random()-.5;});}
  function speak(textValue,rate){
    var status=root.querySelector('#mfkrB1AudioStatus');
    if(!('speechSynthesis' in window)||!('SpeechSynthesisUtterance' in window)){if(status)status.textContent='النطق الصوتي غير مدعوم في هذا المتصفح. جرّب متصفحًا حديثًا.';return;}
    window.speechSynthesis.cancel();
    var utterance=new SpeechSynthesisUtterance(textValue);mfkrSelectEnglishVoice(utterance);
    utterance.lang='en-US';utterance.rate=rate||.82;utterance.pitch=1.03;
    utterance.onstart=function(){if(status)status.textContent='🔊 جاري نطق: '+textValue;};
    utterance.onend=function(){if(status)status.textContent='اختار كلمة أو مثالًا لسماع النطق مرة أخرى.';};
    utterance.onerror=function(){if(status)status.textContent='تعذّر تشغيل الصوت. اضغط مرة أخرى.';};
    window.speechSynthesis.speak(utterance);
  }
  function wordCard(item){
    return '<article class="mfkr-word-card"><div class="mfkr-word-card-head"><span class="mfkr-word-picture" aria-hidden="true">'+item.picture+'</span><span class="mfkr-word-tag">'+({family:'FAMILY',food:'FOOD',animals:'ANIMALS',actions:'ACTIONS',colours:'COLOURS',numbers:'NUMBERS',body:'BODY',clothes:'CLOTHES',school:'SCHOOL',weather:'WEATHER',home:'HOME'}[item.category])+'</span></div><div class="mfkr-word">'+esc(item.word)+'</div><div class="mfkr-meaning" lang="ar">'+esc(item.meaning)+'</div><div class="mfkr-example-label">LET’S USE IT</div><div class="mfkr-example" lang="en">'+esc(item.example)+'</div><div class="mfkr-example-ar" lang="ar">'+esc(item.sentence)+'</div><div class="mfkr-word-actions"><button type="button" class="mfkr-sound" data-b1-speak="'+esc(item.word)+'">🔊 الكلمة</button><button type="button" class="mfkr-sound" data-b1-speak="'+esc(item.example)+'">♫ الجملة</button></div></article>';
  }
  function drawWords(){
    var filtered=activeTopic==='all'?words:words.filter(function(item){return item.category===activeTopic;});
    root.querySelector('#mfkrB1WordGrid').innerHTML=filtered.map(wordCard).join('');
    root.querySelectorAll('[data-b1-topic]').forEach(function(button){
      var active=button.getAttribute('data-b1-topic')===activeTopic;
      button.classList.toggle('is-active',active);
      button.setAttribute('aria-pressed',active?'true':'false');
    });
    root.querySelector('#mfkrB1VisibleCount').textContent=filtered.length+' كلمة';
  }
  function drawQuiz(){
    var box=root.querySelector('#mfkrB1Quiz');
    quizAnswered=false;
    if(quizIndex>=5){
      box.innerHTML='<div class="mfkr-quiz-finish"><span class="mfkr-quiz-emoji">🏆</span><h3>Great job!</h3><p lang="ar">خلصت التحدي! نتيجتك: <strong>'+quizScore+' من 5</strong></p><p class="mfkr-quiz-sub" lang="ar">جرّب مرة تانية وشوف تقدر تحسن نتيجتك؟</p><button type="button" class="mfkr-btn mfkr-btn-primary" data-b1-restart>ابدأ تحديًا جديدًا ↻</button></div>';
      return;
    }
    var target=quizOrder[quizIndex];
    var options=shuffled([target].concat(shuffled(words.filter(function(item){return item.word!==target.word;}).slice()).slice(0,3)));
    box.innerHTML='<div class="mfkr-quiz-topline"><span class="mfkr-quiz-badge">WORD CHALLENGE</span><span class="mfkr-quiz-count">Question '+(quizIndex+1)+' / 5</span><span class="mfkr-quiz-score">Score: '+quizScore+'</span></div><h3 lang="en">What does <span>'+esc(target.word)+'</span> mean?</h3><p class="mfkr-quiz-hint" lang="ar">اختار المعنى الصحيح للكلمة.</p><div class="mfkr-quiz-options">'+options.map(function(option){return '<button type="button" class="mfkr-quiz-option" data-b1-quiz-option="'+esc(option.word)+'" lang="ar">'+esc(option.meaning)+'</button>';}).join('')+'</div><p class="mfkr-quiz-feedback" id="mfkrB1QuizFeedback" lang="ar" aria-live="polite">خد وقتك وفكّر في الإجابة.</p><div class="mfkr-quiz-next-row"><button type="button" class="mfkr-btn mfkr-btn-primary" data-b1-next disabled>السؤال التالي ←</button></div>';
  }
  root.innerHTML=shell('LITTLE LEARNERS · LEVEL B1','My First Words.','كلماتي الأولى.','اتعلّم كلمات يومية بالصور والترجمة العربية، واسمع نطق الكلمة والجملة، وبعدها جرّب التحدي الصغير.','<div class="mfkr-summary"><span>50 useful words</span><div class="mfkr-progress"><span style="width:100%"></span></div><span>Picture · Meaning · Sentence · Sound</span></div><div class="mfkr-topic-panel"><div class="mfkr-topic-heading"><div><div class="mfkr-mini-eyebrow">CHOOSE A TOPIC</div><h2>Let’s learn together</h2></div><span class="mfkr-count" id="mfkrB1VisibleCount">50 كلمة</span></div><div class="mfkr-topics" role="group" aria-label="اختار مجموعة الكلمات">'+topics.map(function(topic){return '<button type="button" class="mfkr-topic'+(topic[0]==='all'?' is-active':'')+'" data-b1-topic="'+topic[0]+'" aria-pressed="'+(topic[0]==='all'?'true':'false')+'"><span>'+topic[1]+'</span>'+topic[2]+'</button>';}).join('')+'</div></div><div class="mfkr-word-grid" id="mfkrB1WordGrid"></div><div class="mfkr-audio-status" id="mfkrB1AudioStatus" aria-live="polite">اختار كلمة أو مثالًا لسماع النطق مرة أخرى.</div><section class="mfkr-quiz-panel"><div class="mfkr-quiz-intro"><div class="mfkr-mini-eyebrow">PLAY &amp; PRACTISE</div><h2>Word Challenge <span aria-hidden="true">✦</span></h2><p lang="ar">اختبر نفسك: شوف الكلمة بالإنجليزي واختار معناها بالعربي.</p></div><div id="mfkrB1Quiz"></div></section>'+backButtons(url('younger'),'← الرجوع للمستويات')+ '<div class="mfkr-note">نصيحة: اسمع الكلمة لوحدها الأول، ثم اسمع المثال كاملًا، وكرّر بصوتك. كل مرة هتتعلم كلمة جديدة هتقرب خطوة من التحدث بالإنجليزي.</div>');
  drawWords();
  quizOrder=shuffled(words).slice(0,5);
  drawQuiz();
  root.addEventListener('click',function(event){
    var topicButton=event.target.closest('[data-b1-topic]');
    if(topicButton){activeTopic=topicButton.getAttribute('data-b1-topic');drawWords();return;}
    var soundButton=event.target.closest('[data-b1-speak]');
    if(soundButton){speak(soundButton.getAttribute('data-b1-speak'),soundButton.getAttribute('data-b1-speak').length>20?.88:.78);return;}
    var optionButton=event.target.closest('[data-b1-quiz-option]');
    if(optionButton&&!quizAnswered){
      var chosen=optionButton.getAttribute('data-b1-quiz-option');
      var target=quizOrder[quizIndex];
      quizAnswered=true;
      var correct=chosen===target.word;
      if(correct)quizScore++;
      root.querySelectorAll('[data-b1-quiz-option]').forEach(function(button){
        button.disabled=true;
        if(button.getAttribute('data-b1-quiz-option')===target.word)button.classList.add('is-correct');
        else if(button===optionButton&&!correct)button.classList.add('is-wrong');
      });
      var feedback=root.querySelector('#mfkrB1QuizFeedback');
      feedback.textContent=correct?'ممتاز! إجابة صحيحة ✨':'قربت! المعنى الصحيح هو: '+target.meaning;
      feedback.classList.toggle('is-right',correct);
      feedback.classList.toggle('is-wrong',!correct);
      root.querySelector('.mfkr-quiz-score').textContent='Score: '+quizScore;
      root.querySelector('[data-b1-next]').disabled=false;
      return;
    }
    if(event.target.closest('[data-b1-next]')){if(!quizAnswered)return;quizIndex++;drawQuiz();return;}
    if(event.target.closest('[data-b1-restart]')){quizIndex=0;quizScore=0;quizOrder=shuffled(words).slice(0,5);drawQuiz();return;}
  });
}


function kidsJourneySubscribeUrl(){return url('subscribe');}
var kidsJourneyPendingMarkerKey='mfkj-kids-pending-request-user-v1';
function kidsJourneyHasPendingMarker(userId){if(!userId)return false;try{return window.localStorage.getItem(kidsJourneyPendingMarkerKey)===String(userId)}catch(_){return false}}
function kidsJourneyClearPendingMarker(userId){if(!userId)return;try{if(window.localStorage.getItem(kidsJourneyPendingMarkerKey)===String(userId))window.localStorage.removeItem(kidsJourneyPendingMarkerKey)}catch(_){}}
function kidsJourneyIsTerminalRequest(request){var status=String(request&&request.status||'').toLowerCase().trim().replace(/[ -]+/g,'_');return ['rejected','declined','denied','cancelled','canceled','approved','active','completed'].indexOf(status)>=0}
function kidsJourneyGetClient(){return typeof sb!=='undefined'&&sb&&sb.from&&sb.auth?sb:null;}
var kidsJourneyClientReadyPromise=null;
function kidsJourneyWaitForClient(){
  var ready=kidsJourneyGetClient();
  if(ready)return Promise.resolve(ready);
  if(!kidsJourneyClientReadyPromise){
    kidsJourneyClientReadyPromise=new Promise(function(resolve,reject){
      var started=Date.now();
      function check(){
        var client=kidsJourneyGetClient();
        if(client){resolve(client);return;}
        if(Date.now()-started>=15000){
          reject(new Error('Supabase did not initialize. Check the network/CDN connection and reload the page.'));
          return;
        }
        setTimeout(check,100);
      }
      check();
    });
  }
  return kidsJourneyClientReadyPromise;
}
function kidsJourneyDefinition(code){return journeyLevels.find(function(item){return item.code===String(code||'').toUpperCase();})||journeyLevels[0];}
function kidsJourneyDate(value){if(!value)return '—';var d=new Date(value);return Number.isNaN(d.getTime())?'—':d.toLocaleDateString(undefined,{year:'numeric',month:'short',day:'numeric'});}
async function kidsJourneyLoadContext(code){
  var client;
  try{client=await kidsJourneyWaitForClient();}
  catch(error){return {error:error&&error.message||'The academy connection could not be initialized. Refresh this page and try again.'};}
  // Distinguish a logged-out visitor from a real connection/verification failure.
  var sessionResult;
  try{sessionResult=await client.auth.getSession();}
  catch(error){
    console.warn('Kids Journey session lookup failed:',error);
    return {error:'Could not read the saved sign-in session. Please sign in again.'};
  }
  if(sessionResult&&sessionResult.error){
    var sessionErrorName=String(sessionResult.error.name||'');
    var sessionErrorMessage=String(sessionResult.error.message||'');
    if(/AuthSessionMissingError|Auth session missing|invalid.*(refresh|jwt|token|session)|(refresh|jwt|token|session).*(expired|invalid|missing|not found)/i.test(sessionErrorName+' '+sessionErrorMessage))return {user:null};
    console.warn('Kids Journey session lookup returned an error:',sessionResult.error);
    return {error:'Could not read the saved sign-in session. Please sign in again.'};
  }
  var session=sessionResult&&sessionResult.data&&sessionResult.data.session||null;
  var user=session&&session.user||null;
  if(!session||!user)return {user:null};

  // getClaims verifies the JWT and can refresh a near-expiry session. It avoids
  // a redundant getUser(token) network check on this route. The database queries
  // below still enforce the actual subscription/access rules through Supabase RLS.
  var claimsResult;
  try{claimsResult=await client.auth.getClaims();}
  catch(error){
    console.warn('Kids Journey JWT verification threw an error:',error);
    return {error:'Could not verify your sign-in. Please sign in again and refresh.'};
  }
  if(claimsResult&&claimsResult.error){
    var authErrorName=String(claimsResult.error.name||'');
    var authErrorMessage=String(claimsResult.error.message||'');
    if(/AuthSessionMissingError|Auth session missing|invalid.*(refresh|jwt|token|session)|(refresh|jwt|token|session).*(expired|invalid|missing|not found)/i.test(authErrorName+' '+authErrorMessage))return {user:null};
    console.warn('Kids Journey JWT verification failed:',claimsResult.error);
    return {error:'Could not verify your sign-in. Please sign in again and refresh.'};
  }
  var claims=claimsResult&&claimsResult.data&&claimsResult.data.claims||null;
  if(!claims||!claims.sub||String(claims.sub)!==String(user.id)){
    console.warn('Kids Journey: verified JWT subject did not match the stored session user.');
    return {user:null};
  }

  // getClaims may refresh the stored session, so re-read it before querying RLS-protected data.
  var latestSessionResult;
  try{latestSessionResult=await client.auth.getSession();}
  catch(error){
    console.warn('Kids Journey refreshed session lookup failed:',error);
    return {error:'Could not read the saved sign-in session. Please sign in again.'};
  }
  if(latestSessionResult&&latestSessionResult.error){
    console.warn('Kids Journey refreshed session lookup returned an error:',latestSessionResult.error);
    return {error:'Could not read the saved sign-in session. Please sign in again.'};
  }
  var latestSession=latestSessionResult&&latestSessionResult.data&&latestSessionResult.data.session||null;
  if(!latestSession||!latestSession.user||String(latestSession.user.id)!==String(claims.sub))return {user:null};
  user=latestSession.user;
  var trackResult=await client.from('mrfluent_kids_tracks').select('id,code,title,price_egp,duration_days,is_published').eq('code','KIDS_JOURNEY').eq('is_published',true).maybeSingle();
  if(trackResult.error)return {user:user,error:'Could not load the Kids subscription plan: '+trackResult.error.message};
  if(!trackResult.data)return {user:user,error:'The Kids Journey payment plan is not configured yet. Contact the academy.'};
  var now=new Date().toISOString();
  var readResults=await Promise.all([
    client.from('mrfluent_kids_levels').select('id,track_id,code,title,sort_order,is_published').eq('track_id',trackResult.data.id).eq('is_published',true).order('sort_order',{ascending:true}),
    client.from('mrfluent_kids_subscriptions').select('id,track_id,level_id,status,starts_at,expires_at,price_egp').eq('user_id',user.id).eq('track_id',trackResult.data.id).eq('status','active').gt('expires_at',now).lte('starts_at',now).order('expires_at',{ascending:false}).limit(10),
    client.from('mrfluent_kids_enrollment_requests').select('id,status,track_id,requested_level_id,admin_note,created_at,reviewed_at').eq('user_id',user.id).eq('track_id',trackResult.data.id).order('created_at',{ascending:false}).limit(20)
  ]);
  var levelsResult=readResults[0],subsResult=readResults[1],requestResult=readResults[2];
  if(levelsResult.error)return {user:user,track:trackResult.data,error:'Could not load the Kids levels: '+levelsResult.error.message};
  var levels=levelsResult.data||[];
  var level=levels.find(function(item){return item.code===String(code||'A1').toUpperCase();});
  if(!level)return {user:user,track:trackResult.data,levels:levels,error:'This Kids level is not available for subscription yet.'};
  if(subsResult.error)return {user:user,track:trackResult.data,levels:levels,level:level,error:'Could not verify your Kids access: '+subsResult.error.message};
  if(requestResult.error)return {user:user,track:trackResult.data,levels:levels,level:level,subscriptions:subsResult.data||[],error:'Could not load your Kids payment request status: '+requestResult.error.message};
  var requests=requestResult.data||[];
  var pending=requests.find(function(r){return String(r.status).toLowerCase()==='pending';})||null;
  var current=(subsResult.data||[])[0]||null;
  var wholeCourse=String(trackResult.data.code||'').toUpperCase()==='KIDS_JOURNEY';
  var active=(subsResult.data||[]).find(function(s){return wholeCourse||String(s.level_id)===String(level.id);})||null;
  var latest=wholeCourse?(pending||requests[0]||null):(requests.find(function(r){return String(r.requested_level_id)===String(level.id);})||null);
  return {user:user,track:trackResult.data,levels:levels,level:level,subscriptions:subsResult.data||[],current:current,active:active,pending:pending,latest:latest,requests:requests};
}
function kidsJourneyStatus(element,message,kind){
  if(!element)return;
  element.className='mfkj-pay-status'+(kind?' '+kind:'');
  element.textContent=String(message||'');
}
function kidsJourneyReturnHomeWithNotice(title,message,kind,delay){
  var wait=Math.max(0,Number(delay)||0);
  root.innerHTML=shell('DOMA ACADEMY','تم إرسال الطلب','حالة طلب الاشتراك','', '<style>#mfKidsStandaloneRoot .mfkj-notice-screen{min-height:58vh;display:flex;align-items:center;justify-content:center;padding:18px 0}#mfKidsStandaloneRoot .mfkj-notice-card{width:min(100%,560px);text-align:center;padding:clamp(24px,5vw,42px);border:1px solid rgba(173,89,111,.5);border-radius:24px;background:linear-gradient(145deg,rgba(34,14,21,.97),rgba(15,9,13,.98));box-shadow:0 24px 60px rgba(0,0,0,.35)}#mfKidsStandaloneRoot .mfkj-notice-icon{width:64px;height:64px;margin:0 auto 15px;border-radius:50%;display:grid;place-items:center;background:rgba(58,135,99,.16);border:1px solid rgba(107,194,157,.45);color:#9fe1ba;font-size:31px}#mfKidsStandaloneRoot .mfkj-notice-card h2{color:#fff;margin:0 0 12px;font-size:clamp(23px,5vw,31px)}#mfKidsStandaloneRoot .mfkj-notice-card [data-mfkj-home-notice]{color:#f0dfe5;font-size:15px;line-height:1.95;margin:0 auto;max-width:430px}#mfKidsStandaloneRoot .mfkj-notice-card [data-mfkj-return-home]{margin-top:20px}</style><div class="mfkj-notice-screen"><section class="mfkj-notice-card" role="status" aria-live="polite"><div class="mfkj-notice-icon" aria-hidden="true">✓</div><h2 data-mfkj-notice-title></h2><div data-mfkj-home-notice class="mfkj-pay-status"></div><button type="button" class="mfkj-pay-submit" data-mfkj-return-home>الرجوع للرئيسية</button></section></div>');
  var titleNode=root.querySelector('[data-mfkj-notice-title]');
  var statusNode=root.querySelector('[data-mfkj-home-notice]');
  if(titleNode)titleNode.textContent=String(title||'حالة طلب الاشتراك');
  kidsJourneyStatus(statusNode,message,kind||'');
  function goHome(){window.location.replace(window.location.pathname||'/');}
  var back=root.querySelector('[data-mfkj-return-home]');
  if(back)back.addEventListener('click',goHome);
  if(wait)setTimeout(goHome,wait);
}
function kidsJourneyAuthActions(show){
  var host=root.querySelector('[data-mfj-pay-auth-actions]');
  if(host)host.style.display=show?'flex':'none';
}
function kidsJourneyOpenAuth(mode){
  if(typeof openAuth==='function'){openAuth(mode||'login');return;}
  window.location.href='./?auth=signup&kids=subscribe&level='+encodeURIComponent((query.get('level')||'A1').toUpperCase());
}
function kidsJourneyDisablePayment(disabled){
  var form=root.querySelector('#mfkjKidsPaymentForm');
  if(!form)return;
  form.querySelectorAll('input,select,button[type="submit"]').forEach(function(el){el.disabled=!!disabled;});
}
function kidsJourneyRenderGateMessage(code,ctx){
  var host=root.querySelector('[data-mfj-kids-gate-status]');
  var actions=root.querySelector('[data-mfj-kids-gate-actions]');
  if(!host||!actions)return;
  if(ctx.error){
    host.className='mfkj-pay-status is-error';
    host.textContent=ctx.error+' The learning content will remain locked until access can be verified.';
    actions.innerHTML='<button type="button" class="mfkr-btn mfkj-primary" data-mfj-kids-login>Sign in</button><button type="button" class="mfkr-btn" data-mfj-kids-signup>Create account</button><a class="mfkr-btn" href="'+url(code.toLowerCase())+'">Retry access check ↻</a><a class="mfkr-btn" href="'+kidsJourneySubscribeUrl()+'">Open full-course subscription</a>';
    return;
  }
  if(!ctx.user){
    host.className='mfkj-pay-status is-warn';
    host.textContent='Sign in with your DOMA Academy account. One Kids course subscription opens all six levels A1–C2 after approval.';
    actions.innerHTML='<button type="button" class="mfkr-btn mfkj-primary" data-mfj-kids-login>Sign in</button><button type="button" class="mfkr-btn" data-mfj-kids-signup>Create account</button>';
    return;
  }
  if(ctx.active)return;
  if(ctx.pending){
    host.className='mfkj-pay-status is-warn';
    host.textContent='Your full-course payment request covering all six levels A1–C2 is awaiting admin review. You do not need to choose a level or submit another request.';
    actions.innerHTML='<a class="mfkr-btn mfkj-primary" href="'+url('entry')+'">طلبك قيد المراجعة · عرض الحالة</a><a class="mfkr-btn" href="'+url('hub')+'">العودة لمستويات الكورس</a>';
    return;
  }
  host.className='mfkj-pay-status';
  if(ctx.current){
    host.textContent='Your full Kids course access is active until '+kidsJourneyDate(ctx.current.expires_at)+'. All six levels A1–C2 are included.';
  }else if(ctx.latest&&String(ctx.latest.status).toLowerCase()==='rejected'){
    host.textContent='Your previous full-course request was not approved. Check the admin note if available, then submit a new payment receipt.';
  }else{
    host.textContent='No active full-course subscription was found. Submit one Mobile Cash receipt for all six levels A1–C2; they remain locked until an administrator approves payment.';
  }
  actions.innerHTML='<a class="mfkr-btn mfkj-primary" href="'+kidsJourneySubscribeUrl()+'">Subscribe to all levels · 100 EGP / 30 days</a><a class="mfkr-btn" href="'+url('hub')+'">Back to course levels</a>';
}

async function kidsJourneyRenderLevelGate(code,renderer){
  var def=kidsJourneyDefinition(code);
  document.title=def.code+' · Kids Course Access | Mr. Fluent Kids';
  root.innerHTML=shell('KIDS COURSE ACCESS','Unlock all six Kids levels.','اشتراك واحد يفتح الكورس كله.','A single 30-day Kids course subscription covers A1–C2. School-grade access and the separate English Course remain independent.','<div class="mfkj-pay-gate"><div class="mfkj-pay-kicker"><span class="mfkr-dot"></span> MEMBERSHIP CHECK</div><h2>'+esc(def.code)+' · '+esc(def.title)+'</h2><div class="mfkj-pay-price"><strong>100</strong><span>EGP / 30 days</span></div><div data-mfj-kids-gate-status class="mfkj-pay-status">Checking your Kids subscription…</div><div class="mfkr-back-row" data-mfj-kids-gate-actions><a class="mfkr-btn" href="'+url('hub')+'">Back to Kids paths</a></div></div>'+backButtons(url(def.group),'← Back to levels'));
  var ctx;
  try{ctx=await kidsJourneyLoadContext(def.code);}catch(e){ctx={error:e&&e.message||'Could not verify Kids access.'};}
  if(ctx&&ctx.active){
    renderer();
    journeyRenderCurrent();
    if(def.code==='A1')mfkjA1SyncWorkspace();
    else mfkjInstallCourseLevelMenu(def.code);
    mfkjA1SyncWorkspace();
    return;
  }
  kidsJourneyRenderGateMessage(def.code,ctx||{error:'Could not verify Kids access.'});
  var login=root.querySelector('[data-mfj-kids-login]');
  var signup=root.querySelector('[data-mfj-kids-signup]');
  if(login)login.addEventListener('click',function(){kidsJourneyOpenAuth('login');});
  if(signup)signup.addEventListener('click',function(){kidsJourneyOpenAuth('signup');});
}
function kidsJourneyRenderSubscription(){
  var def=kidsJourneyDefinition('A1');
  document.title='Full Kids Course Subscription | Mr. Fluent Kids';
  var receiver=typeof MOBILE_CASH!=='undefined'?MOBILE_CASH:'01006525147';
  root.innerHTML=shell('MR. FLUENT KIDS','Mr. Fluent Kids','كورس الأطفال','', '<style id="mfkj-full-course-payment-css">#mfKidsStandaloneRoot .mfkj-pay-layout{display:block;width:min(100%,720px);margin:0 auto}#mfKidsStandaloneRoot .mfkj-payment-unified{position:relative;overflow:hidden;padding:clamp(17px,3.5vw,30px);border:1px solid rgba(153,70,91,.55);border-radius:22px;background:linear-gradient(145deg,rgba(34,14,21,.96),rgba(15,9,13,.98));box-shadow:0 22px 55px rgba(0,0,0,.32),inset 0 1px 0 rgba(255,255,255,.04)}#mfKidsStandaloneRoot .mfkj-payment-unified:before{content:"";position:absolute;inset:0 0 auto;height:3px;background:linear-gradient(90deg,#7d2941,#c05269,#8e5bd9);pointer-events:none}#mfKidsStandaloneRoot .mfkj-payment-unified h2{margin:9px 0 6px;color:#fff;font-size:clamp(22px,4vw,31px);line-height:1.25;letter-spacing:-.5px}#mfKidsStandaloneRoot .mfkj-payment-subtitle{color:#c4b4ba;font-size:13px;line-height:1.8;margin:0 0 17px}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-price{display:flex;align-items:baseline;gap:10px;margin:14px 0;padding:12px 15px;border:1px solid rgba(173,89,111,.28);border-radius:14px;background:linear-gradient(110deg,rgba(106,31,51,.28),rgba(38,17,29,.38))}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-price strong{color:#f5c0ce;font-size:clamp(34px,6vw,43px);line-height:1;font-weight:900}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-price>span{color:#e8d5db;font-size:12px}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-receiver{padding:14px 15px;border:1px solid rgba(107,194,157,.28);border-radius:14px;background:linear-gradient(130deg,rgba(25,74,57,.22),rgba(14,30,25,.42));margin:12px 0 18px}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-receiver small{display:block;color:#a5d8bf;font-size:10px;font-weight:800;letter-spacing:1px}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-receiver strong{display:block;margin:4px 0;color:#f0fff7;font-size:clamp(23px,4vw,29px);letter-spacing:1px}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-receiver p{margin:0;color:#b9cfc4;font-size:11px;line-height:1.7}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-fields{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:13px;margin-top:12px}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-field{min-width:0}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-field.full{grid-column:1/-1}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-field label{display:block;margin:0 0 6px;color:#f1e4e8;font-size:12px;font-weight:750}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-field input{width:100%;min-width:0;padding:12px;border:1px solid rgba(156,99,116,.34);border-radius:11px;background:rgba(8,7,9,.78);color:#fff;outline:none}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-field input:focus{border-color:#c05269;box-shadow:0 0 0 3px rgba(192,82,105,.13)}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-field input[type=file]{font-size:11px}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-help{display:block;margin-top:5px;color:#9f9298;font-size:10px;line-height:1.6}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-consent{display:flex;align-items:flex-start;gap:9px;margin:15px 0;color:#bfb0b6;font-size:11px;line-height:1.7}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-consent input{accent-color:#b94a66;margin-top:4px;flex:0 0 auto}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-submit{width:100%;min-height:49px;border:1px solid rgba(219,120,145,.65);border-radius:12px;background:linear-gradient(110deg,#7d2941,#a63b57);color:#fff;font-weight:850;box-shadow:0 8px 22px rgba(113,28,52,.22)}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-submit:disabled{opacity:.55;cursor:not-allowed}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-status{margin-top:12px}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-auth-actions{display:flex;gap:9px;flex-wrap:wrap;margin-top:12px}@media(max-width:540px){#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-fields{grid-template-columns:1fr}#mfKidsStandaloneRoot .mfkj-payment-unified .mfkj-pay-field.full{grid-column:auto}#mfKidsStandaloneRoot .mfkj-payment-unified{border-radius:18px}}</style><div class="mfkj-pay-layout"><section class="mfkj-pay-card mfkj-payment-unified"><div class="mfkj-pay-kicker"><span class="mfkr-dot"></span> KIDS COURSE · MOBILE CASH</div><h2>Mr. Fluent Kids — Complete Course</h2><p class="mfkj-payment-subtitle">اشتراك واحد يفتح كل المستويات من A1 إلى C2 بعد موافقة الإدارة.</p><div class="mfkj-pay-price"><strong id="mfkjPayAmount">100</strong><span>EGP / <b id="mfkjPayDays">30</b> days</span></div><div class="mfkj-pay-receiver"><small>OFFICIAL TRANSFER NUMBER · رقم التحويل</small><strong>'+esc(receiver)+'</strong><p>حوّل المبلغ الموضح أعلاه إلى الرقم الرسمي، ثم ارفع صورة أو ملف الإيصال.</p></div><form id="mfkjKidsPaymentForm" data-mfkj-level="A1"><div class="mfkj-pay-fields"><div class="mfkj-pay-field"><label for="mfkjGuardianContact">Parent / guardian phone · رقم ولي الأمر *</label><input id="mfkjGuardianContact" name="guardian" type="tel" autocomplete="tel" minlength="7" placeholder="Parent or guardian phone" required><span class="mfkj-pay-help">رقم الأب أو الأم للتواصل عند الحاجة.</span></div><div class="mfkj-pay-field"><label for="mfkjSenderPhone">Transfer sender phone · رقم المحوّل *</label><input id="mfkjSenderPhone" name="sender" type="tel" autocomplete="tel" minlength="5" placeholder="Number used for transfer" required><span class="mfkj-pay-help">اكتب الرقم اللي تم التحويل منه.</span></div><div class="mfkj-pay-field full"><label for="mfkjReceipt">Payment receipt · إيصال التحويل *</label><input id="mfkjReceipt" name="receipt" type="file" accept=".jpg,.jpeg,.png,.webp,.pdf,image/jpeg,image/png,image/webp,application/pdf" required><span class="mfkj-pay-help">JPG, PNG, WEBP or PDF · maximum 5 MB.</span></div></div><label class="mfkj-pay-consent"><input id="mfkjGuardianConsent" name="consent" type="checkbox" required><span>I am the parent/guardian, or I have permission to submit these payment details.</span></label><button class="mfkj-pay-submit" type="submit" id="mfkjSubmitPayment" disabled>Confirm and send payment request</button><div id="mfkjPaymentStatus" class="mfkj-pay-status" aria-live="polite">Checking your account and request status…</div><div class="mfkj-pay-auth-actions" data-mfj-pay-auth-actions><button class="mfkr-btn mfkj-primary" type="button" data-mfkj-auth="login">Sign in</button><button class="mfkr-btn" type="button" data-mfkj-auth="signup">Create account</button></div></form></section></div>'+backButtons(url('hub'),'← Back to course levels'));
  var form=root.querySelector('#mfkjKidsPaymentForm');
  form.addEventListener('submit',function(event){event.preventDefault();kidsJourneySubmitPayment('A1');});
  root.querySelectorAll('[data-mfkj-auth]').forEach(function(button){button.addEventListener('click',function(){kidsJourneyOpenAuth(button.getAttribute('data-mfkj-auth'));});});
  kidsJourneyLoadPaymentState('A1');
}
async function kidsJourneyLoadPaymentState(code){
  var status=root.querySelector('#mfkjPaymentStatus');
  if(!status)return;
  var ctx;
  try{ctx=await kidsJourneyLoadContext(code);}catch(e){ctx={error:e&&e.message||'Could not load payment status.'};}
  if(!root.querySelector('#mfkjPaymentStatus'))return;
  var form=root.querySelector('#mfkjKidsPaymentForm');
  var submit=root.querySelector('#mfkjSubmitPayment');
  var amount=root.querySelector('#mfkjPayAmount'),days=root.querySelector('#mfkjPayDays');
  if(ctx.track){if(amount)amount.textContent=String(ctx.track.price_egp==null?100:ctx.track.price_egp);if(days)days.textContent=String(ctx.track.duration_days||30);}
  var currentUserId=(ctx&&ctx.user&&ctx.user.id)||(typeof sessionUser!=='undefined'&&sessionUser&&sessionUser.id)||null;
  var hasLocalPending=kidsJourneyHasPendingMarker(currentUserId);
  if(ctx.error){
    if(hasLocalPending){
      kidsJourneyReturnHomeWithNotice('طلبك قيد المراجعة','تم حفظ طلبك بالفعل. تعذّر تحديث الحالة على الهاتف الآن، لذلك لن نطلب منك إيصالًا جديدًا.','is-warn',0);
      return;
    }
    kidsJourneyStatus(status,ctx.error+' You can reopen sign-in below, then retry the payment page.','is-error');
    kidsJourneyDisablePayment(true);
    kidsJourneyAuthActions(true);
    return;
  }
  if(!ctx.user){
    kidsJourneyStatus(status,'Sign in or create a DOMA Academy account before submitting payment. Your receipt remains private.','is-warn');
    kidsJourneyDisablePayment(true);
    kidsJourneyAuthActions(true);
    return;
  }
  kidsJourneyAuthActions(false);
  if(ctx.pending||(!ctx.current&&hasLocalPending&&!(ctx.latest&&kidsJourneyIsTerminalRequest(ctx.latest)))){
    try{window.localStorage.setItem(kidsJourneyPendingMarkerKey,String(currentUserId));}catch(_){}
    kidsJourneyReturnHomeWithNotice('طلبك قيد المراجعة','طلبك تم إرساله بالفعل، وهو الآن في انتظار مراجعة الإدارة. من فضلك انتظر الموافقة، ومش محتاج تبعت طلب جديد.','is-warn',0);
    return;
  }
  if(ctx.current){
    kidsJourneyClearPendingMarker(currentUserId);
    kidsJourneyStatus(status,'Your complete Kids course access is active until '+kidsJourneyDate(ctx.current.expires_at)+'. A successful renewal extends access to all six levels A1–C2 for '+String(ctx.track&&ctx.track.duration_days||30)+' days.','is-ok');
  }else if(ctx.latest&&String(ctx.latest.status).toLowerCase()==='rejected'){
    kidsJourneyClearPendingMarker(currentUserId);
    kidsJourneyStatus(status,'Your earlier full-course request was not approved. Review the note, then you may submit a new receipt. '+(ctx.latest.admin_note||''),'is-warn');
  }else{
    kidsJourneyStatus(status,'This payment is for the complete Kids course. All six levels stay locked until the academy approves the receipt.','');
  }
  if(form)form.querySelectorAll('input,select').forEach(function(el){el.disabled=false;});
  if(submit){submit.disabled=false;submit.textContent='Send payment request';}
}
async function kidsJourneySubmitPayment(code){
  var form=root.querySelector('#mfkjKidsPaymentForm');
  var status=root.querySelector('#mfkjPaymentStatus');
  var submit=root.querySelector('#mfkjSubmitPayment');
  if(!form||!status||!submit)return;
  var client;
  try{client=await kidsJourneyWaitForClient();}
  catch(error){kidsJourneyStatus(status,error&&error.message||'The academy connection could not be initialized. Refresh this page and try again.','is-error');return;}
  if(!form.querySelector('#mfkjGuardianConsent').checked){kidsJourneyStatus(status,'Please confirm the parent/guardian permission before submitting.','is-error');return;}
  var guardian=form.querySelector('#mfkjGuardianContact').value.trim();
  var sender=form.querySelector('#mfkjSenderPhone').value.trim();
  var noteNode=form.querySelector('#mfkjPayNote');
  var note=noteNode?noteNode.value.trim():'';
  var file=form.querySelector('#mfkjReceipt').files&&form.querySelector('#mfkjReceipt').files[0];
  if(guardian.length<7){kidsJourneyStatus(status,'Enter a valid parent or guardian contact.','is-error');return;}
  if(sender.length<5){kidsJourneyStatus(status,'Enter the sender phone number used for Mobile Cash.','is-error');return;}
  if(!file){kidsJourneyStatus(status,'Choose the transfer receipt before submitting.','is-error');return;}
  var allowed=['image/jpeg','image/png','image/webp','application/pdf'];
  if(allowed.indexOf(String(file.type||'').toLowerCase())<0){kidsJourneyStatus(status,'The receipt must be a JPG, PNG, WEBP, or PDF file.','is-error');return;}
  if(file.size<1||file.size>5*1024*1024){kidsJourneyStatus(status,'The receipt must be no larger than 5 MB.','is-error');return;}
  submit.disabled=true;submit.textContent='Uploading receipt…';
  var uploadedPath=null;
  try{
    var ctx=await kidsJourneyLoadContext(code);
    if(ctx.error)throw new Error(ctx.error);
    if(!ctx.user)throw new Error('Please sign in before submitting the payment.');
    if(ctx.pending)throw new Error('There is already a Kids payment request awaiting admin approval.');
    var extension=({'image/jpeg':'jpg','image/png':'png','image/webp':'webp','application/pdf':'pdf'})[file.type.toLowerCase()];
    var randomId=(window.crypto&&typeof window.crypto.randomUUID==='function')?window.crypto.randomUUID():String(Date.now())+'-'+Math.random().toString(36).slice(2,12);
    uploadedPath=ctx.user.id+'/kids/'+Date.now()+'-'+randomId+'.'+extension;
    var upload=await client.storage.from('payment-proofs').upload(uploadedPath,file,{cacheControl:'3600',contentType:file.type,upsert:false});
    if(upload.error)throw upload.error;
    submit.textContent='Submitting payment request…';
    var courseNote='FULL KIDS COURSE SUBSCRIPTION (A1–C2 — all six levels).'+(note?' '+note:'');
    var created=await client.rpc('mrfluent_create_kids_enrollment_request',{
      p_track_id:ctx.track.id,p_level_id:ctx.level.id,p_guardian_contact:guardian,
      p_sender_phone:sender,p_proof_path:uploadedPath,p_note:courseNote.slice(0,300)
    });
    if(created.error)throw created.error;
    if(!created.data)throw new Error('The request ID was not returned. Refresh this page to check request status before trying again.');
    uploadedPath=null;
    try{window.localStorage.setItem('mfkj-kids-pending-request-user-v1',String(ctx.user.id));}catch(_){}
    kidsJourneyReturnHomeWithNotice('تم إرسال طلب الاشتراك بنجاح','تم استلام طلبك بنجاح، وصفحة الاشتراك اتقفلت. هتقدر تدخل كورس الأطفال مباشرة بعد موافقة الإدارة على الإيصال.','is-ok',3200);
    return;
  }catch(error){
    if(uploadedPath){
      try{await client.storage.from('payment-proofs').remove([uploadedPath]);}catch(_){}
    }
    var submitError=String(error&&error.message||error||'');
    if(/already awaiting review|already awaiting admin review|already.*pending/i.test(submitError)){
      kidsJourneyReturnHomeWithNotice('طلبك قيد المراجعة','طلبك تم إرساله بالفعل، وهو الآن في انتظار مراجعة الإدارة. مش هيتعمل طلب مكرر، ومن فضلك انتظر الموافقة.','is-warn',3200);
      return;
    }
    kidsJourneyStatus(status,'Could not submit the payment request. '+(submitError||'Check the connection and try again.'),'is-error');
  }finally{
    if(root.querySelector('#mfkjSubmitPayment')&&!(root.querySelector('#mfkjSubmitPayment').textContent||'').includes('pending review')){
      root.querySelector('#mfkjSubmitPayment').disabled=false;
      root.querySelector('#mfkjSubmitPayment').textContent='Send payment request';
    }
  }
}
var kidsJourneyAuthBound=false;
async function kidsJourneyBindAuthRefresh(){
  if(kidsJourneyAuthBound)return;
  var client;
  try{client=await kidsJourneyWaitForClient();}
  catch(error){console.warn('Kids auth listener could not be started.',error);return;}
  if(kidsJourneyAuthBound||!client.auth||!client.auth.onAuthStateChange)return;
  kidsJourneyAuthBound=true;
  client.auth.onAuthStateChange(function(event){
    if(event!=='SIGNED_IN'&&event!=='SIGNED_OUT'&&event!=='TOKEN_REFRESHED')return;
    if(route==='subscribe'){kidsJourneyLoadPaymentState(kidsJourneyDefinition(query.get('level')||'A1').code);return;}
    var item=journeyLevels.find(function(x){return x.route===route;});
    if(item)kidsJourneyRenderLevelGate(item.code,function(){kidsJourneyRenderLevel(item.code);});
  });
}
function kidsJourneyRenderLevel(code){
  if(code==='A1')renderAlphabet();
  else if(code==='A2')renderA2();
  else if(code==='B1')renderB1();
  else if(code==='B2')renderB2();
  else if(code==='C1')renderC1();
  else if(code==='C2')renderC2();
}

function kidsJourneyRenderEntryScreen(message,kind){
  var status=message||'Create your account or sign in to continue to Kids subscriptions.';
  root.innerHTML=shell('MR. FLUENT KIDS','Start your learning journey.','ابدأ رحلة تعلّم الإنجليزي.','Create your student account first. After signing in, you will go directly to the Kids subscription page.','<div class="mfkj-pay-gate"><div class="mfkj-pay-kicker"><span class="mfkr-dot"></span> STUDENT ACCOUNT</div><h2>Create your account</h2><p class="mfkj-pay-muted">بعد إنشاء الحساب هتنتقل مباشرةً لصفحة الاشتراك، والمحتوى يفضل مقفول لحد الموافقة على الدفع.</p><div data-mfkj-entry-status class="mfkj-pay-status '+(kind||'')+'"></div><div class="mfkr-back-row"><button class="mfkj-pay-submit" type="button" data-mfkj-entry-signup>Create account</button><button class="mfkr-btn" type="button" data-mfkj-entry-login>Sign in</button><button class="mfkr-btn" type="button" data-mfkj-entry-retry>Continue / Retry</button></div></div>');
  var statusNode=root.querySelector('[data-mfkj-entry-status]');
  if(statusNode)statusNode.textContent=status;
  var signup=root.querySelector('[data-mfkj-entry-signup]');
  var login=root.querySelector('[data-mfkj-entry-login]');
  var retry=root.querySelector('[data-mfkj-entry-retry]');
  if(signup)signup.addEventListener('click',function(){if(typeof openAuth==='function')openAuth('signup');});
  if(login)login.addEventListener('click',function(){if(typeof openAuth==='function')openAuth('login');});
  if(retry)retry.addEventListener('click',function(){kidsJourneyHandlePreCourseRoute(route);});
}
async function kidsJourneyHandleParentRoute(){
  var user=typeof sessionUser!=='undefined'&&sessionUser?sessionUser:null;
  if(!user&&typeof sb!=='undefined'&&sb&&sb.auth){try{var sessionResult=await sb.auth.getSession();user=sessionResult&&sessionResult.data&&sessionResult.data.session&&sessionResult.data.session.user||null;}catch(_){}}
  if(!user){window.__mfKidsToolsAuthorized=false;kidsJourneyRenderEntryScreen('Sign in with the parent account to see your linked students.','is-warn');if(typeof openAuth==='function')setTimeout(function(){try{openAuth('login');}catch(error){console.warn('Parent sign-in could not be opened.',error);}},100);return;}
  if(typeof sb==='undefined'||!sb||!sb.rpc){window.__mfKidsToolsAuthorized=false;kidsJourneyRenderEntryScreen('Parent reporting is temporarily unavailable. Please try again later.','is-error');return;}
  try{var response=await sb.rpc('mrfluent_kids_parent_dashboard');if(response&&response.error)throw response.error;window.__mfKidsParentReport=response&&response.data||{children:[]};window.__mfKidsToolsAuthorized=true;renderParentOverview();}
  catch(error){window.__mfKidsToolsAuthorized=false;kidsJourneyRenderEntryScreen('Could not load the parent report: '+String(error&&error.message||'Please try again.'),'is-error');}
}
async function kidsJourneyHandlePreCourseRoute(routeName){
  if(routeName==='map'||routeName==='parents'||routeName==='lab')window.__mfKidsToolsAuthorized=false;
  if(routeName==='parents'){await kidsJourneyHandleParentRoute();return;}
  var ctx;
  var cachedContext=window.__mfKidsJourneyAccessContext||null;
  var cachedAt=Number(window.__mfKidsJourneyAccessContextAt||0);
  var activeMainUser=typeof sessionUser!=='undefined'&&sessionUser?String(sessionUser.id||''):'';
  if(cachedContext&&cachedContext.user&&activeMainUser&&String(cachedContext.user.id)===activeMainUser&&Date.now()-cachedAt<8000)ctx=cachedContext;
  else{
    try{ctx=await kidsJourneyLoadContext('A1');}
    catch(error){ctx={error:error&&error.message||'Could not verify Kids access.'};}
  }
  if(ctx&&ctx.error){
    var markerUser=(ctx&&ctx.user&&ctx.user.id)||(typeof sessionUser!=='undefined'&&sessionUser&&sessionUser.id)||null;
    if(kidsJourneyHasPendingMarker(markerUser)){
      kidsJourneyReturnHomeWithNotice('طلبك قيد المراجعة','تم حفظ طلبك بالفعل. التحقق من الحالة تأخر على الهاتف، لذلك لن نفتح نموذج دفع جديدًا.','is-warn',0);
      return;
    }
    kidsJourneyRenderEntryScreen(ctx.error+' Your course will stay locked until the account and subscription can be verified.','is-error');
    return;
  }
  if(!ctx||!ctx.user){
    kidsJourneyRenderEntryScreen('Create your DOMA Academy account or sign in. The full-course subscription page opens next.','is-warn');
    if(typeof openAuth==='function')setTimeout(function(){try{openAuth('signup');}catch(error){console.warn('Kids signup form could not be opened.',error);}},100);
    return;
  }
  window.__mfKidsJourneyAccessContext=ctx;
  window.__mfKidsJourneyAccessContextAt=Date.now();
  if(ctx.current){
    if(routeName==='map'||routeName==='parents'||routeName==='lab')window.__mfKidsToolsAuthorized=true;
    kidsJourneyClearPendingMarker(ctx.user&&ctx.user.id);
    if(routeName==='entry'){
      window.location.replace(url('hub'));return;
    }
    if(routeName==='hub'){window.__mfKidsJourneyAccessContext=ctx;renderHub();return;}
    if(routeName==='younger'||routeName==='older'){renderLevels(routeName);return;} if(routeName==='map'){renderCourseMap();return;} if(routeName==='parents'){renderParentOverview();return;} if(routeName==='lab'){renderLearningLab();return;}
  }
  if(ctx.latest&&kidsJourneyIsTerminalRequest(ctx.latest))kidsJourneyClearPendingMarker(ctx.user&&ctx.user.id);
  if(ctx.pending||(kidsJourneyHasPendingMarker(ctx.user&&ctx.user.id)&&!(ctx.latest&&kidsJourneyIsTerminalRequest(ctx.latest)))){
    try{if(ctx.user&&ctx.user.id)window.localStorage.setItem(kidsJourneyPendingMarkerKey,String(ctx.user.id));}catch(_){}
    kidsJourneyReturnHomeWithNotice('طلبك قيد المراجعة','طلب الاشتراك اتبعت بالفعل ولسه في انتظار مراجعة الإدارة. من فضلك انتظر الموافقة، مش محتاج تبعت طلب تاني. كورس الأطفال هيفتح لك بعد الموافقة على الإيصال.','is-warn',0);
    return;
  }
  if(window.mfKidsNavigateInPlace&&window.mfKidsNavigateInPlace(kidsJourneySubscribeUrl('A1')))return;
  window.location.replace(kidsJourneySubscribeUrl('A1'));
}
async function kidsJourneyAfterAuth(){
  if(route==='subscribe'){
    await kidsJourneyLoadPaymentState(kidsJourneyDefinition(query.get('level')||'A1').code);
    return;
  }
  if(route==='entry'||route==='hub'||route==='younger'||route==='older'||route==='map'||route==='parents'||route==='lab'){
    await kidsJourneyHandlePreCourseRoute(route);
    return;
  }
  var item=journeyLevels.find(function(x){return x.route===route;});
  if(item){
    var ctx;
    try{ctx=await kidsJourneyLoadContext(item.code);}
    catch(error){ctx={error:error&&error.message||'Could not verify Kids access.'};}
    if(ctx&&ctx.active){kidsJourneyRenderLevel(item.code);journeyRenderCurrent();return;}
    if(ctx&&ctx.pending){
      kidsJourneyReturnHomeWithNotice('طلبك قيد المراجعة','طلبك تم إرساله بالفعل، وهو الآن في انتظار مراجعة الإدارة. من فضلك انتظر الموافقة، ومش محتاج تبعت طلب جديد.','is-warn',3200);
      return;
    }
    window.location.replace(kidsJourneySubscribeUrl(item.code));
  }
}
window.__mfKidsEntryFlow=(route==='subscribe'||route==='entry'||route==='hub'||route==='younger'||route==='older'||route==='map'||route==='parents'||route==='lab'||journeyLevels.some(function(item){return item.route===route;}));
window.__mfKidsAfterAuth=kidsJourneyAfterAuth;

function kidsJourneyRenderRouteInPlace(nextRoute,href,pushHistory){
  var next=String(nextRoute||'hub').toLowerCase();
  if(pushHistory&&href){try{window.history.pushState({mfKidsRoute:true},'',href)}catch(error){console.warn('Kids route history update failed.',error)}}
  route=next;query=new URLSearchParams(window.location.search);
  if(route==='subscribe'){kidsJourneyRenderSubscription();kidsJourneyBindAuthRefresh();}
  else if(route==='entry'||route==='hub'||route==='younger'||route==='older'||route==='map'||route==='parents'||route==='lab'){kidsJourneyBindAuthRefresh();kidsJourneyHandlePreCourseRoute(route);}
  else{
    var item=journeyLevels.find(function(level){return level.route===route;});
    if(item){kidsJourneyBindAuthRefresh();kidsJourneyRenderLevelGate(item.code,function(){kidsJourneyRenderLevel(item.code);journeyRenderCurrent();});}
    else if(route==='review')renderReview();
    else if(route==='soon')renderSoon();
    else renderHub();
  }
  try{window.scrollTo(0,0)}catch(_){}
}
window.mfKidsNavigateInPlace=function(destination){
  var target;try{target=new URL(String(destination||''),window.location.href)}catch(_){return false}
  if(target.origin!==window.location.origin||target.pathname!==window.location.pathname||!target.searchParams.get('kids'))return false;
  kidsJourneyRenderRouteInPlace(target.searchParams.get('kids'),target.href,true);return true;
};
document.addEventListener('click',function(event){
  if(event.defaultPrevented||event.button!==0||event.metaKey||event.ctrlKey||event.shiftKey||event.altKey)return;
  var link=event.target&&event.target.closest?event.target.closest('#mfKidsStandaloneRoot a[href]'):null;
  if(!link||link.hasAttribute('download')||(link.target&&link.target!=='_self'))return;
  var target;try{target=new URL(link.href,window.location.href)}catch(_){return}
  if(target.origin!==window.location.origin||target.pathname!==window.location.pathname||!target.searchParams.get('kids'))return;
  event.preventDefault();window.mfKidsNavigateInPlace(target.href);
});
window.addEventListener('popstate',function(){
  if(!document.body.classList.contains('mf-kids-route'))return;
  kidsJourneyRenderRouteInPlace(new URLSearchParams(window.location.search).get('kids')||'hub',window.location.href,false);
});

if(route==='subscribe'){kidsJourneyRenderSubscription();kidsJourneyBindAuthRefresh();}
else if(route==='entry'||route==='hub'||route==='younger'||route==='older'||route==='map'||route==='parents'||route==='lab'){
  kidsJourneyBindAuthRefresh();
  kidsJourneyHandlePreCourseRoute(route);
}
else if(route==='a1'||route==='a2'||route==='b1'||route==='b2'||route==='c1'||route==='c2'){
  var requestedKidsLevel=journeyLevels.find(function(item){return item.route===route;});
  if(requestedKidsLevel){kidsJourneyRenderLevelGate(requestedKidsLevel.code,function(){kidsJourneyRenderLevel(requestedKidsLevel.code);});kidsJourneyBindAuthRefresh();}
  else renderHub();
}
else if(route==='review')renderReview();
else if(route==='soon')renderSoon();
else renderHub();
// Apply after the Kids content is rendered so its own cards remain visible.
isolateKidsPage();
journeyAttachTracker();
journeyRenderCurrent();
journeyInit();
// Catch any late-created academy nodes and keep them outside this page-only view.
if (window.MutationObserver) {
  var kidsPageObserver = new MutationObserver(function(records){
    var outsideAdded = records.some(function(record){
      return Array.prototype.some.call(record.addedNodes,function(node){
        return node.nodeType === 1 && node !== root && !root.contains(node);
      });
    });
    if (outsideAdded) isolateKidsPage();
  });
  kidsPageObserver.observe(document.body,{childList:true,subtree:true});
}
})();
