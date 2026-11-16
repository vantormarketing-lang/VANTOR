(function(){
  'use strict';
  var style = document.createElement('style');
  style.textContent = [
    '.pa-extra-labs{display:grid;gap:14px;margin:16px 0 22px}',
    '.pa-extra-card{padding:16px;border:1px solid rgba(205,170,111,.28);border-radius:18px;background:linear-gradient(145deg,rgba(43,31,55,.92),rgba(24,20,34,.96));color:#f1e5d4}',
    '.pa-extra-card h3{margin:0 0 7px;color:#e5c47e;font-size:17px}',
    '.pa-extra-card p{margin:0 0 12px;color:#cdbfae;font-size:12px;line-height:1.8}',
    '.pa-symbol-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(118px,1fr));gap:8px}',
    '.pa-symbol-item{padding:10px;border:1px solid rgba(205,170,111,.18);border-radius:11px;background:rgba(255,255,255,.035);display:grid;grid-template-columns:38px 1fr;align-items:center;gap:8px}',
    '.pa-symbol-item code{direction:ltr;text-align:center;font-size:19px;color:#f1cf88;font-weight:800}',
    '.pa-symbol-item span{font-size:11px;line-height:1.5;color:#e6d8c5}',
    '.pa-terminal-head{display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap}',
    '.pa-terminal-badge{font-size:10px;color:#a9d8b5;border:1px solid rgba(100,190,130,.3);padding:4px 8px;border-radius:99px}',
    '.pa-terminal-screen{min-height:145px;max-height:260px;overflow:auto;white-space:pre-wrap;direction:ltr;text-align:left;padding:12px;border-radius:12px;background:#100d17;color:#e8e2d8;font:12px/1.75 ui-monospace,Consolas,monospace}',
    '.pa-terminal-form{display:flex;gap:8px;margin-top:10px;direction:ltr}',
    '.pa-terminal-form input{min-width:0;flex:1;padding:11px;border-radius:10px;border:1px solid rgba(205,170,111,.28);background:#171321;color:#fff;font:13px ui-monospace,Consolas,monospace}',
    '.pa-terminal-form button,.pa-terminal-reset{border:0;border-radius:10px;padding:10px 14px;background:linear-gradient(120deg,#b58a4e,#e0c07b);color:#21172a;font-weight:800;cursor:pointer}',
    '.pa-terminal-reset{margin-top:9px;background:rgba(255,255,255,.08);border:1px solid rgba(205,170,111,.22);color:#e8d6b8;font-size:11px}',
    '@media(max-width:520px){.pa-terminal-form{flex-wrap:wrap}.pa-terminal-form input{flex-basis:100%}.pa-terminal-form button{flex:1}}'
  ].join('');
  document.head.appendChild(style);

  function mount(lab){
    if(!lab || lab.dataset.extraLabsMounted==='1') return;
    lab.dataset.extraLabsMounted='1';
    var wrapper=document.createElement('div');
    wrapper.className='pa-extra-labs';
    wrapper.innerHTML =
      '<section class="pa-extra-card" aria-label="دليل رموز لوحة المفاتيح">'+
        '<h3>دليل رموز لوحة المفاتيح</h3>'+
        '<p>استخدم تخطيط English عند كتابة الكود. وظيفة الرمز تختلف حسب اللغة، وهذه أشهر الاستخدامات.</p>'+
        '<div class="pa-symbol-grid">'+
          '<div class="pa-symbol-item"><code>( )</code><span>أقواس الدوال وتجميع العمليات</span></div>'+
          '<div class="pa-symbol-item"><code>[ ]</code><span>القوائم والفهارس</span></div>'+
          '<div class="pa-symbol-item"><code>{ }</code><span>القواميس أو كتل الكود</span></div>'+
          '<div class="pa-symbol-item"><code>:</code><span>بداية كتلة في Python</span></div>'+
          '<div class="pa-symbol-item"><code>;</code><span>نهاية تعليمة في C++ وJavaScript</span></div>'+
          '<div class="pa-symbol-item"><code>' \"</code><span>علامات إحاطة النصوص</span></div>'+
          '<div class="pa-symbol-item"><code>=</code><span>إسناد قيمة</span></div>'+
          '<div class="pa-symbol-item"><code>==</code><span>مقارنة التساوي</span></div>'+
          '<div class="pa-symbol-item"><code>_</code><span>فاصل داخل أسماء المتغيرات</span></div>'+
          '<div class="pa-symbol-item"><code>#</code><span>تعليق في Python</span></div>'+
          '<div class="pa-symbol-item"><code>//</code><span>تعليق في JavaScript وC++</span></div>'+
          '<div class="pa-symbol-item"><code>!</code><span>النفي في لغات كثيرة</span></div>'+
        '</div>'+
      '</section>'+
      '<section class="pa-extra-card" aria-label="محاكي الطرفية التدريبي">'+
        '<div class="pa-terminal-head"><div><h3>محاكي Terminal التدريبي</h3><p>بيئة وهمية آمنة للتدرب على أوامر أساسية. لا تتصل بجهازك ولا تنفذ أوامر نظام حقيقية.</p></div><span class="pa-terminal-badge">Sandbox تعليمي</span></div>'+
        '<pre class="pa-terminal-screen" id="paTrainingTerminal" aria-live="polite">DOMA Training Terminal v1\nاكتب help لعرض الأوامر المتاحة.\nstudent@doma:~/project$</pre>'+
        '<form class="pa-terminal-form" id="paTrainingTerminalForm"><input id="paTrainingTerminalInput" type="text" autocomplete="off" spellcheck="false" aria-label="أمر الطرفية" placeholder="اكتب أمرًا مثل help أو ls"><button type="submit">تنفيذ</button></form>'+
        '<button type="button" class="pa-terminal-reset" id="paTrainingTerminalReset">إعادة ضبط المحاكي</button>'+
      '</section>';
    lab.insertAdjacentElement('afterend',wrapper);
    var screen=wrapper.querySelector('#paTrainingTerminal');
    var form=wrapper.querySelector('#paTrainingTerminalForm');
    var input=wrapper.querySelector('#paTrainingTerminalInput');
    var reset=wrapper.querySelector('#paTrainingTerminalReset');
    var cwd='/project';
    var dirs=new Set(['/project','/project/src','/project/assets']);
    var files=new Map([
      ['/project/README.md','DOMA practice project'],
      ['/project/src/hello.py','print("Hello from DOMA Terminal!")'],
      ['/project/src/main.py','name = "Student"\nprint("Welcome", name)']
    ]);
    function pathOf(base,name){
      if(!name || name==='.') return base;
      if(name==='..') return base.slice(0,base.lastIndexOf('/')) || '/';
      if(name[0]==='/') return name.replace(/\\/g,'/').replace(/\/$/,'') || '/';
      return (base==='/'?'':base)+'/'+name;
    }
    function list(){
      var prefix=cwd==='/'?'/':cwd+'/';
      var found=new Set();
      dirs.forEach(function(p){if(p!==cwd && p.startsWith(prefix)){var rest=p.slice(prefix.length);if(rest&&!rest.includes('/'))found.add(rest+'/')}});
      files.forEach(function(v,p){if(p.startsWith(prefix)){var rest=p.slice(prefix.length);if(rest&&!rest.includes('/'))found.add(rest)}});
      return Array.from(found).sort().join('  ') || '(المجلد فارغ)';
    }
    function write(line){
      var current=screen.textContent;
      screen.textContent=(current+'\n'+line).slice(-6500);
      screen.scrollTop=screen.scrollHeight;
    }
    function execute(raw){
      var command=raw.trim();
      if(!command) return;
      write('student@doma:'+cwd+'$ '+command);
      var parts=command.match(/(?:[^\s"]+|"[^"]*")+/g)||[];
      var cmd=parts[0].toLowerCase();
      var arg=(parts[1]||'').replace(/^"|"$/g,'');
      var target=pathOf(cwd,arg);
      if(cmd==='help'){
        write('الأوامر المتاحة: help, pwd, ls, dir, cd, mkdir, touch, cat, type, clear, cls, python hello.py');
        write('هذه محاكاة محدودة؛ أوامر حذف الملفات أو صلاحيات النظام غير متاحة.');
      }else if(cmd==='pwd'){write(cwd)}
      else if(cmd==='ls'||cmd==='dir'){write(list())}
      else if(cmd==='cd'){
        if(!arg){cwd='/project';}
        else if(dirs.has(target)){cwd=target;}
        else{write('المجلد غير موجود: '+arg);}
      }else if(cmd==='mkdir'){
        if(!arg){write('الاستخدام: mkdir folder-name');}
        else if(dirs.has(target)||files.has(target)){write('الاسم مستخدم بالفعل.');}
        else{dirs.add(target);write('تم إنشاء المجلد: '+arg);}
      }else if(cmd==='touch'){
        if(!arg){write('الاستخدام: touch file-name');}
        else if(dirs.has(target)){write('يوجد مجلد بهذا الاسم.');}
        else{files.set(target,files.get(target)||'');write('تم إنشاء الملف: '+arg);}
      }else if(cmd==='cat'||cmd==='type'){
        if(!arg){write('الاستخدام: cat file-name');}
        else if(files.has(target)){write(files.get(target)||'(الملف فارغ)');}
        else{write('الملف غير موجود: '+arg);}
      }else if(cmd==='clear'||cmd==='cls'){
        screen.textContent='DOMA Training Terminal v1\nتم تنظيف الشاشة. اكتب help للمساعدة.';
      }else if(cmd==='python'||cmd==='python3'||cmd==='py'){
        var fileArg=parts[1]||'';
        var pyPath=pathOf(cwd,fileArg);
        if(!files.has(pyPath)){write('python: لا يوجد ملف بهذا الاسم: '+fileArg);}
        else{
          var source=files.get(pyPath);
          var prints=source.matchAll(/print\(\s*["']([^"']*)["']\s*\)/g),outputs=Array.from(prints).map(function(m){return m[1]});
          if(outputs.length)outputs.forEach(write);
          else write('تم تشغيل المحاكاة: لم يتم العثور على أمر print نصي بسيط.');
        }
      }else{
        write('الأمر غير مدعوم في المحاكي. اكتب help لمعرفة الأوامر المتاحة.');
      }
      write('');
    }
    form.addEventListener('submit',function(event){event.preventDefault();execute(input.value);input.value='';input.focus();});
    reset.addEventListener('click',function(){
      cwd='/project';dirs=new Set(['/project','/project/src','/project/assets']);
      files=new Map([['/project/README.md','DOMA practice project'],['/project/src/hello.py','print("Hello from DOMA Terminal!")'],['/project/src/main.py','name = "Student"\nprint("Welcome", name)']]);
      screen.textContent='DOMA Training Terminal v1\nتمت إعادة ضبط البيئة. اكتب help للمساعدة.\nstudent@doma:~/project$';
      input.value='';
    });
  }
  function scan(){
    document.querySelectorAll('.pa-code-lab').forEach(mount);
  }
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',scan);else scan();
  new MutationObserver(scan).observe(document.documentElement,{childList:true,subtree:true});
})();