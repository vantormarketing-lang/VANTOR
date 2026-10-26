(function(){
  'use strict';
  var SPLASH_ID = 'mfFluentStartupPhotoSplash';
  var DISPLAY_MS = 5000;
  var FADE_MS = 260;

  function isInstalledApp(){
    try {
      return !!((window.matchMedia && window.matchMedia('(display-mode: standalone)').matches) ||
        window.navigator.standalone === true);
    } catch (_) { return false; }
  }

  function showSplash(){
    if (!isInstalledApp() || document.getElementById(SPLASH_ID) || !document.body) return;

    // Reuse the exact photograph already embedded in the student Grade dashboard.
    var source = document.querySelector('.doma-student-top-profile img[alt="Teacher"]');
    if (!source) return;
    var photoSrc = source.currentSrc || source.getAttribute('src');
    if (!photoSrc) return;

    var layer = document.createElement('div');
    layer.id = SPLASH_ID;
    layer.setAttribute('aria-hidden', 'true');
    layer.style.cssText = [
      'position:fixed',
      'inset:0',
      'z-index:2147483647',
      'width:100vw',
      'height:100vh',
      'height:100dvh',
      'overflow:hidden',
      'margin:0',
      'padding:0',
      'border:0',
      'background:#09080b',
      'opacity:1',
      'transition:opacity ' + FADE_MS + 'ms ease',
      'pointer-events:auto',
      'isolation:isolate'
    ].join(';');

    var image = document.createElement('img');
    image.alt = '';
    image.draggable = false;
    image.decoding = 'sync';
    image.src = photoSrc;
    image.style.cssText = [
      'display:block',
      'width:100%',
      'height:100%',
      'max-width:none',
      'max-height:none',
      'object-fit:cover',
      'object-position:center 28%',
      'user-select:none',
      '-webkit-user-select:none',
      '-webkit-user-drag:none',
      'pointer-events:none'
    ].join(';');

    layer.appendChild(image);
    document.body.appendChild(layer);

    // Keep the image full-screen for the requested five seconds, then fade it away.
    window.setTimeout(function(){
      if (!layer.isConnected) return;
      layer.style.opacity = '0';
      window.setTimeout(function(){
        if (layer.parentNode) layer.parentNode.removeChild(layer);
      }, FADE_MS + 40);
    }, DISPLAY_MS);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', showSplash, { once: true });
  } else {
    showSplash();
  }
})();