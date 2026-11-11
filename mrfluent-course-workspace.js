/* DOMA / Mr. Fluent — standalone lesson workspace + local interactive whiteboard.
   Runs after the protected course runtime renders its lesson cards.
   Board notes/drawings stay in the student's browser; no database writes are made.
*/
(function () {
  'use strict';

  const courseView = document.getElementById('courseView');
  if (!courseView) return;

  const levelMatch = location.pathname.match(/MR_FLUENT_([A-C][12])_COURSE\.html/i);
  const level = levelMatch ? levelMatch[1].toUpperCase() : 'A1';
  const requestedLesson = new URLSearchParams(location.search).get('lesson');
  let standaloneApplied = false;

  const backUrl = () => {
    const url = new URL(location.href);
    url.searchParams.delete('lesson');
    url.hash = '';
    return url.href;
  };

  const lessonUrl = id => {
    const url = new URL(location.href);
    url.searchParams.set('lesson', id);
    url.hash = '';
    return url.href;
  };

  function addLessonLinks() {
    courseView.querySelectorAll('.lesson').forEach(lesson => {
      if (lesson.querySelector('.mf-open-lesson')) return;
      const complete = lesson.querySelector('.completeBtn[data-id]');
      const id = complete && complete.dataset.id;
      if (!id || !/^\d+-\d+$/.test(id)) return;

      const link = document.createElement('a');
      link.className = 'mf-open-lesson';
      link.href = lessonUrl(id);
      link.textContent = 'Open full lesson ↗';
      link.setAttribute('aria-label', 'Open this lesson on its own page');
      lesson.prepend(link);
    });
  }

  function loadStrokes(key) {
    try {
      const value = JSON.parse(localStorage.getItem(key) || '[]');
      if (!Array.isArray(value)) return [];
      return value.slice(-100).filter(stroke =>
        stroke && ['#4c3269', '#9a6425', '#243247', '#27845b', 'eraser'].includes(stroke.color) &&
        Array.isArray(stroke.points) && stroke.points.length > 0 &&
        stroke.points.length <= 2500 &&
        stroke.points.every(point =>
          point && Number.isFinite(point.x) && Number.isFinite(point.y)
        )
      );
    } catch (_) {
      return [];
    }
  }

  function createWhiteboard(id) {
    const section = document.createElement('section');
    section.className = 'mf-whiteboard';
    section.innerHTML = `
      <div class="mf-board-heading">
        <div>
          <span class="mf-board-kicker">YOUR INTERACTIVE SPACE</span>
          <h2>Lesson Whiteboard</h2>
          <p>Write, draw, solve examples and keep your notes for this lesson.</p>
        </div>
        <span class="mf-board-saved" role="status" aria-live="polite">Saved on this device</span>
      </div>
      <div class="mf-board-toolbar" role="toolbar" aria-label="Whiteboard tools">
        <button type="button" class="mf-board-tool is-active" data-color="#4c3269" aria-label="Purple pen" title="Purple pen"><i style="background:#4c3269"></i></button>
        <button type="button" class="mf-board-tool" data-color="#9a6425" aria-label="Gold pen" title="Gold pen"><i style="background:#9a6425"></i></button>
        <button type="button" class="mf-board-tool" data-color="#243247" aria-label="Dark blue pen" title="Dark blue pen"><i style="background:#243247"></i></button>
        <button type="button" class="mf-board-tool" data-color="#27845b" aria-label="Green pen" title="Green pen"><i style="background:#27845b"></i></button>
        <button type="button" class="mf-board-tool" data-color="eraser" aria-label="Eraser" title="Eraser">⌫</button>
        <span class="mf-board-divider"></span>
        <label class="mf-board-width">Pen size <input type="range" min="2" max="12" value="4" aria-label="Pen size"></label>
        <button type="button" class="mf-board-action" data-action="undo">Undo</button>
        <button type="button" class="mf-board-action" data-action="clear">Clear board</button>
      </div>
      <div class="mf-board-paper">
        <canvas class="mf-board-canvas" aria-label="Interactive drawing board. Use a mouse, stylus, or finger to write."></canvas>
      </div>
      <label class="mf-board-notes-label" for="mfLessonNotes">Lesson notes</label>
      <textarea class="mf-board-notes" id="mfLessonNotes" rows="4" placeholder="Write your own examples, questions or reminders here…"></textarea>
      <p class="mf-board-footnote">Your drawing and notes are saved locally in this browser on this device. They are not uploaded to your account.</p>
    `;

    const canvas = section.querySelector('canvas');
    const context = canvas.getContext('2d');
    const savedLabel = section.querySelector('.mf-board-saved');
    const notes = section.querySelector('.mf-board-notes');
    const key = `mf-lesson-board-v1:${level}:${id}`;
    const notesKey = key + ':notes';
    let strokes = loadStrokes(key);
    let activeStroke = null;
    let activeColor = '#4c3269';
    let penWidth = 4;
    let cssWidth = 0;
    let cssHeight = 0;

    try { notes.value = localStorage.getItem(notesKey) || ''; } catch (_) {}

    function persist() {
      try {
        localStorage.setItem(key, JSON.stringify(strokes.slice(-100)));
        savedLabel.textContent = 'Saved on this device';
      } catch (_) {
        savedLabel.textContent = 'Could not save — browser storage is full';
      }
    }

    function drawStroke(stroke) {
      if (!stroke || !stroke.points || !stroke.points.length) return;
      context.save();
      context.globalCompositeOperation = stroke.color === 'eraser' ? 'destination-out' : 'source-over';
      context.strokeStyle = stroke.color === 'eraser' ? 'rgba(0,0,0,1)' : stroke.color;
      context.fillStyle = context.strokeStyle;
      context.lineWidth = stroke.width || 4;
      context.lineCap = 'round';
      context.lineJoin = 'round';
      const points = stroke.points;
      if (points.length === 1) {
        context.beginPath();
        context.arc(points[0].x, points[0].y, Math.max(1, (stroke.width || 4) / 2), 0, Math.PI * 2);
        context.fill();
      } else {
        context.beginPath();
        context.moveTo(points[0].x, points[0].y);
        for (let i = 1; i < points.length; i++) context.lineTo(points[i].x, points[i].y);
        context.stroke();
      }
      context.restore();
    }

    function redraw() {
      context.clearRect(0, 0, cssWidth, cssHeight);
      strokes.forEach(drawStroke);
      if (activeStroke && !strokes.includes(activeStroke)) drawStroke(activeStroke);
    }

    function resizeCanvas() {
      const rect = canvas.getBoundingClientRect();
      if (!rect.width || !rect.height) return;
      const ratio = Math.max(1, Math.min(2, window.devicePixelRatio || 1));
      cssWidth = rect.width;
      cssHeight = rect.height;
      canvas.width = Math.round(cssWidth * ratio);
      canvas.height = Math.round(cssHeight * ratio);
      context.setTransform(ratio, 0, 0, ratio, 0, 0);
      redraw();
    }

    function pointFromEvent(event) {
      const rect = canvas.getBoundingClientRect();
      return {x: event.clientX - rect.left, y: event.clientY - rect.top};
    }

    canvas.addEventListener('pointerdown', event => {
      event.preventDefault();
      canvas.setPointerCapture(event.pointerId);
      activeStroke = {color: activeColor, width: penWidth, points: [pointFromEvent(event)]};
      strokes.push(activeStroke);
      redraw();
    });
    canvas.addEventListener('pointermove', event => {
      if (!activeStroke) return;
      event.preventDefault();
      activeStroke.points.push(pointFromEvent(event));
      if (activeStroke.points.length > 2500) activeStroke.points.shift();
      redraw();
    });
    const finishStroke = () => {
      if (!activeStroke) return;
      activeStroke = null;
      persist();
    };
    canvas.addEventListener('pointerup', finishStroke);
    canvas.addEventListener('pointercancel', finishStroke);
    canvas.addEventListener('lostpointercapture', finishStroke);

    section.querySelectorAll('[data-color]').forEach(button => {
      button.addEventListener('click', () => {
        activeColor = button.dataset.color;
        section.querySelectorAll('[data-color]').forEach(item => item.classList.toggle('is-active', item === button));
      });
    });
    section.querySelector('.mf-board-width').querySelector('input').addEventListener('input', event => {
      penWidth = Number(event.target.value) || 4;
    });
    section.querySelector('[data-action="undo"]').addEventListener('click', () => {
      strokes.pop();
      redraw();
      persist();
    });
    section.querySelector('[data-action="clear"]').addEventListener('click', () => {
      strokes = [];
      redraw();
      persist();
    });
    notes.addEventListener('input', () => {
      try {
        localStorage.setItem(notesKey, notes.value);
        savedLabel.textContent = 'Saved on this device';
      } catch (_) {
        savedLabel.textContent = 'Could not save notes';
      }
    });

    if ('ResizeObserver' in window) new ResizeObserver(resizeCanvas).observe(canvas);
    else window.addEventListener('resize', resizeCanvas);
    requestAnimationFrame(resizeCanvas);
    return section;
  }

  function applyStandaloneLesson() {
    if (standaloneApplied) return;
    const id = requestedLesson;
    if (!id || !/^\d+-\d+$/.test(id)) return;
    const complete = [...courseView.querySelectorAll('.completeBtn[data-id]')]
      .find(button => button.dataset.id === id);
    const lesson = complete && complete.closest('.lesson');
    if (!lesson) return;

    standaloneApplied = true;
    const shell = document.createElement('div');
    shell.className = 'mf-lesson-page';
    const top = document.createElement('div');
    top.className = 'mf-lesson-page-top';
    const back = document.createElement('a');
    back.className = 'mf-lesson-back';
    back.href = backUrl();
    back.textContent = '← Back to all lessons';
    const levelTag = document.createElement('span');
    levelTag.className = 'mf-lesson-level';
    levelTag.textContent = level + ' · LESSON ' + (Number(id.split('-')[0]) * 3 + Number(id.split('-')[1]) + 1);
    top.append(back, levelTag);

    lesson.remove();
    shell.append(top, lesson, createWhiteboard(id));
    courseView.replaceChildren(shell);

    document.body.classList.add('mf-lesson-standalone');
    document.title = 'Lesson · Mr. Fluent ' + level;
    document.querySelector('body > header')?.classList.add('mf-workspace-hidden');
    document.querySelector('.topgrid')?.classList.add('mf-workspace-hidden');
    document.querySelector('main.wrap > .box')?.classList.add('mf-workspace-hidden');
    document.querySelector('.student-sidebar')?.classList.add('mf-workspace-hidden');
    document.querySelector('.mobile-menu-backdrop')?.classList.add('mf-workspace-hidden');
    document.querySelector('.mf-video-note')?.classList.add('mf-workspace-hidden');
    document.querySelector('body > footer')?.classList.add('mf-workspace-hidden');
    document.getElementById('mobileMenuToggle')?.classList.add('mf-workspace-hidden');
    document.querySelectorAll('.student-content > section:not(#courseView)').forEach(section => section.classList.add('mf-workspace-hidden'));
  }

  const style = document.createElement('style');
  style.id = 'mf-course-workspace-styles';
  style.textContent = `
    .mf-open-lesson{display:inline-flex;align-items:center;justify-content:center;gap:7px;margin:0 0 14px;padding:9px 14px;border:1px solid rgba(232,185,116,.58);border-radius:12px;background:linear-gradient(135deg,rgba(255,229,189,.18),rgba(184,148,233,.18));color:#ffe5bd!important;text-decoration:none!important;font-weight:800;font-size:12px}
    .mf-open-lesson:hover{border-color:#ffe5bd;background:rgba(255,229,189,.24)}
    body.mf-lesson-standalone main.wrap{max-width:1120px;padding-top:24px}
    body.mf-lesson-standalone .student-layout{display:block!important}
    body.mf-lesson-standalone .student-content{width:100%!important;min-width:0!important}
    body.mf-lesson-standalone #courseView{display:block!important}
    body.mf-lesson-standalone .mf-workspace-hidden{display:none!important}
    .mf-lesson-page{display:grid;gap:16px}
    .mf-lesson-page-top{display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;padding:12px 15px;border:1px solid rgba(255,218,174,.34);border-radius:16px;background:linear-gradient(135deg,rgba(89,55,108,.65),rgba(38,26,54,.88));backdrop-filter:blur(16px)}
    .mf-lesson-back{color:#ffe5bd!important;text-decoration:none!important;font-weight:850}
    .mf-lesson-level,.mf-board-kicker{font-size:10px;letter-spacing:.12em;font-weight:900;color:#e8b974}
    .mf-lesson-page .lesson{margin:0!important}
    .mf-whiteboard{padding:18px;border:1px solid rgba(255,218,174,.36);border-radius:20px;background:linear-gradient(145deg,rgba(89,55,108,.54),rgba(31,21,44,.88));box-shadow:0 18px 44px rgba(8,3,18,.25);backdrop-filter:blur(18px)}
    .mf-board-heading{display:flex;align-items:flex-start;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-bottom:14px}
    .mf-board-heading h2{margin:5px 0;color:#fff4e8;font-size:22px}
    .mf-board-heading p,.mf-board-footnote{margin:4px 0;color:#e4d5e8;font-size:12px;line-height:1.6}
    .mf-board-saved{font-size:10px;color:#baf3d0;padding:6px 9px;border-radius:999px;background:rgba(39,132,91,.16);border:1px solid rgba(186,243,208,.25)}
    .mf-board-toolbar{display:flex;align-items:center;gap:7px;flex-wrap:wrap;margin-bottom:12px}
    .mf-board-tool,.mf-board-action{min-width:36px;height:36px;border:1px solid rgba(255,218,174,.35);border-radius:10px;background:rgba(255,255,255,.08);color:#fff4e8;font-weight:800;cursor:pointer}
    .mf-board-tool{display:grid;place-items:center}
    .mf-board-tool i{width:17px;height:17px;border-radius:50%;border:1px solid rgba(0,0,0,.18)}
    .mf-board-tool.is-active{outline:2px solid #ffe5bd;outline-offset:2px}
    .mf-board-divider{height:24px;width:1px;background:rgba(255,218,174,.3);margin:0 3px}
    .mf-board-width{display:flex;align-items:center;gap:6px;color:#e4d5e8;font-size:11px}
    .mf-board-width input{width:90px;accent-color:#e8b974}
    .mf-board-action{padding:0 11px;font-size:11px}
    .mf-board-paper{overflow:hidden;border-radius:13px;border:1px solid rgba(255,229,189,.8);background:#fffdf8;background-image:linear-gradient(rgba(94,70,120,.07) 1px,transparent 1px),linear-gradient(90deg,rgba(94,70,120,.07) 1px,transparent 1px);background-size:24px 24px}
    .mf-board-canvas{display:block;width:100%;height:340px;touch-action:none;cursor:crosshair}
    .mf-board-notes-label{display:block;margin:14px 0 6px;color:#ffe5bd;font-size:12px;font-weight:850}
    .mf-board-notes{display:block;width:100%;min-height:100px;resize:vertical;padding:12px;border:1px solid rgba(255,218,174,.34);border-radius:12px;background:rgba(15,9,24,.42);color:#fff4e8;font:inherit;line-height:1.6}
    .mf-board-notes::placeholder{color:#c9b6d3}
    @media(max-width:640px){.mf-whiteboard{padding:13px}.mf-board-heading h2{font-size:19px}.mf-board-canvas{height:270px}.mf-board-width{width:100%}.mf-board-toolbar{gap:8px}}
  `;
  document.head.appendChild(style);

  const observer = new MutationObserver(() => {
    if (requestedLesson) applyStandaloneLesson();
    else addLessonLinks();
  });
  observer.observe(courseView, {childList: true, subtree: true});
  if (requestedLesson) applyStandaloneLesson();
  else addLessonLinks();
})();
