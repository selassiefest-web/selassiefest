// Shared engine for the BBPAC narrated onboarding decks (orientation.html
// and section-brief.html). One frame on screen at a time, short spoken
// lines by default with an optional "Tell me more" panel for anyone who
// wants depth, and an explicit "Skip to the end" escape hatch -- nobody
// is forced to sit through the whole thing to reach the real CTA.
//
// A page using this loads flip-deck.css, provides the fixed-ID skeleton
// (see orientation.html for the reference markup), sets window.FLIPDECK_FRAMES
// (or calls FlipDeck.init(frames) once frames are ready, e.g. after an
// async Supabase fetch), and this file does the rest.
//
// Voice preference is shared with the document-library reader
// (doc-tools.js's "bbpac_tts_prefs" in localStorage) so picking a voice
// once carries across the whole site.
(function () {
  'use strict';

  var FRAMES = [];
  var state = {
    index: 0, seen: {}, muted: false, autoPlay: false, moreOpen: {}, voices: [], autoTimer: null,
    audioEl: null, usingAudio: false, ttsLines: [], ttsIndex: 0,
  };

  function escapeHtml(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c];
    });
  }

  function ttsPrefs() {
    try { return JSON.parse(localStorage.getItem('bbpac_tts_prefs') || '{}'); } catch (e) { return {}; }
  }

  function pickVoice() {
    if (!('speechSynthesis' in window)) return null;
    state.voices = window.speechSynthesis.getVoices();
    var prefs = ttsPrefs();
    if (prefs.voiceName) {
      for (var i = 0; i < state.voices.length; i++) {
        if (state.voices[i].name === prefs.voiceName) return state.voices[i];
      }
    }
    var enVoices = state.voices.filter(function (v) { return v.lang.indexOf('en') === 0; });
    return enVoices[0] || state.voices[0] || null;
  }

  function renderDots() {
    var dots = document.getElementById('fdDots');
    dots.innerHTML = '';
    FRAMES.forEach(function (_, i) {
      var dot = document.createElement('button');
      dot.className = 'fd-dot';
      dot.setAttribute('aria-label', 'Go to step ' + (i + 1));
      dot.addEventListener('click', function () { goTo(i); });
      dots.appendChild(dot);
    });
  }

  function updateDots() {
    document.querySelectorAll('.fd-dot').forEach(function (dot, i) {
      dot.classList.toggle('active', i === state.index);
      dot.classList.toggle('seen', !!state.seen[i] && i !== state.index);
    });
  }

  function renderFrames() {
    var root = document.getElementById('fdFrames');
    root.innerHTML = FRAMES.map(function (f, i) {
      var moreHtml = '';
      if (f.more && f.more.length) {
        moreHtml =
          '<button type="button" class="fd-more-toggle" data-fd-more="' + i + '"><span>Tell me more</span><span class="chev">&#9662;</span></button>' +
          '<div class="fd-more-panel" data-fd-more-panel="' + i + '" hidden>' +
            f.more.map(function (p) { return '<p>' + escapeHtml(p) + '</p>'; }).join('') +
          '</div>';
      }
      var exampleHtml = f.example ? '<div class="fd-example"><span class="fd-ex-label">' + escapeHtml(f.exampleLabel || 'Real example') + '</span>' + escapeHtml(f.example) + '</div>' : '';
      var statsHtml = f.stats ? '<div class="fd-stat-row">' + f.stats.map(function (s) {
        return '<div class="fd-stat"><div class="n">' + escapeHtml(String(s.n)) + '</div><div class="l">' + escapeHtml(s.label) + '</div></div>';
      }).join('') + '</div>' : '';
      var ctaHtml = f.cta ? '<div class="fd-cta-row">' + f.cta.map(function (c) {
        return '<a class="fd-cta-btn ' + (c.style || 'primary') + '" href="' + c.href + '">' + escapeHtml(c.label) + '</a>';
      }).join('') + '</div>' : '';
      return (
        '<div class="fd-frame" data-fd-frame="' + i + '">' +
          (f.batch ? '<span class="fd-batch">' + escapeHtml(f.batch) + '</span>' : '') +
          '<h1 class="fd-headline">' + escapeHtml(f.headline) + '</h1>' +
          statsHtml + exampleHtml + moreHtml + ctaHtml +
        '</div>'
      );
    }).join('');

    root.querySelectorAll('[data-fd-more]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var idx = Number(btn.getAttribute('data-fd-more'));
        var panel = root.querySelector('[data-fd-more-panel="' + idx + '"]');
        var opening = panel.hidden;
        panel.hidden = !opening;
        btn.classList.toggle('open', opening);
        clearAutoTimer();
        if (opening) {
          state.moreOpen[idx] = true;
          speakFrame(idx);
        } else if ('speechSynthesis' in window) {
          window.speechSynthesis.cancel();
        }
      });
    });
  }

  function clearAutoTimer() {
    if (state.autoTimer) { clearTimeout(state.autoTimer); state.autoTimer = null; }
  }

  function scheduleAuto(delayMs) {
    clearAutoTimer();
    if (!state.autoPlay || state.index >= FRAMES.length - 1) return;
    if (FRAMES[state.index] && FRAMES[state.index].cta) return; // never auto-skip a decision frame
    state.autoTimer = setTimeout(function () { goTo(state.index + 1); }, delayMs);
  }

  // A recorded human voice track for a frame's main narration, when one
  // exists (state.audioEl, lazily created, reused across frames rather than
  // a new Audio() per play). Covers only frame.voice -- there's no recording
  // for the "Tell me more" expansion, so that still falls through to TTS
  // below. A missing/broken file (frame added before its audio is recorded)
  // falls back to TTS too, via onerror, rather than going silent.
  function stopFrameAudio() {
    if (state.audioEl) { state.audioEl.pause(); state.audioEl.onended = null; state.audioEl.onerror = null; }
  }

  function playFrameAudio(frame, i) {
    if (!state.audioEl) state.audioEl = new Audio();
    var el = state.audioEl;
    state.usingAudio = true;
    el.onended = function () { setPlayPauseUI(false); scheduleAuto(1200); };
    el.onerror = function () { state.usingAudio = false; speakLinesTTS(frame.voice || [], i); };
    el.src = frame.audio;
    setPlayPauseUI(true);
    el.play().catch(function () { setPlayPauseUI(false); scheduleAuto(1200); });
  }

  function speakLinesTTS(lines, i) {
    state.usingAudio = false;
    state.ttsLines = lines;
    state.ttsIndex = 0;
    if (state.muted || !('speechSynthesis' in window) || !lines.length) {
      setPlayPauseUI(false);
      scheduleAuto(5000);
      return;
    }
    var voice = pickVoice();
    var prefs = ttsPrefs();
    var rate = Number(prefs.rate) || 1;
    function speakNext() {
      if (state.ttsIndex >= state.ttsLines.length || state.muted || state.index !== i) { setPlayPauseUI(false); scheduleAuto(1200); return; }
      var utt = new SpeechSynthesisUtterance(state.ttsLines[state.ttsIndex]);
      if (voice) utt.voice = voice;
      utt.rate = rate;
      utt.onend = function () { state.ttsIndex++; setTimeout(speakNext, 300); };
      window.speechSynthesis.speak(utt);
    }
    setPlayPauseUI(true);
    speakNext();
  }

  function speakFrame(i) {
    clearAutoTimer();
    if ('speechSynthesis' in window) window.speechSynthesis.cancel();
    stopFrameAudio();
    var frame = FRAMES[i];
    if (!frame) { setPlayPauseUI(false); return; }

    if (frame.audio && !state.moreOpen[i]) {
      state.usingAudio = true;
      if (state.muted) { setPlayPauseUI(false); scheduleAuto(5000); return; }
      playFrameAudio(frame, i);
      return;
    }

    var lines = (frame.voice || []).concat(state.moreOpen[i] ? (frame.more || []) : []);
    speakLinesTTS(lines, i);
  }

  // Rewind restarts the current frame's narration from the top -- for
  // recorded audio that's just seeking to 0; for TTS there's no seek, so
  // it re-runs speakFrame from scratch. Play/pause suspends in place
  // (HTMLMediaElement.pause()/play() for audio, the equivalent
  // SpeechSynthesis.pause()/resume() for TTS) rather than canceling, so
  // resuming picks back up instead of starting the frame over.
  function restartNarration() {
    clearAutoTimer();
    if (state.usingAudio && state.audioEl) {
      state.audioEl.currentTime = 0;
      if (!state.muted) { state.audioEl.play(); setPlayPauseUI(true); }
    } else {
      speakFrame(state.index);
    }
  }

  function togglePlayPause() {
    if (state.usingAudio && state.audioEl && state.audioEl.src) {
      if (state.audioEl.paused) { state.audioEl.play(); setPlayPauseUI(true); }
      else { state.audioEl.pause(); setPlayPauseUI(false); }
      return;
    }
    if ('speechSynthesis' in window && window.speechSynthesis.speaking) {
      if (window.speechSynthesis.paused) { window.speechSynthesis.resume(); setPlayPauseUI(true); }
      else { window.speechSynthesis.pause(); setPlayPauseUI(false); }
    }
  }

  function setPlayPauseUI(playing) {
    var btn = document.getElementById('fdPlayPause');
    if (!btn) return;
    btn.innerHTML = playing ? '<i class="fas fa-pause"></i>' : '<i class="fas fa-play"></i>';
    btn.title = playing ? 'Pause narration' : 'Play narration';
  }

  function goTo(i) {
    if (i < 0 || i >= FRAMES.length) return;
    state.index = i;
    state.seen[i] = true;
    document.querySelectorAll('.fd-frame').forEach(function (el, idx) {
      el.classList.toggle('active', idx === i);
    });
    updateDots();
    document.getElementById('fdCounter').textContent = String(i + 1).padStart(2, '0') + ' / ' + FRAMES.length;
    document.getElementById('fdPrev').disabled = i === 0;
    document.getElementById('fdNext').disabled = i === FRAMES.length - 1;
    var skipBtn = document.getElementById('fdSkip');
    if (skipBtn) skipBtn.style.display = i === FRAMES.length - 1 ? 'none' : '';
    speakFrame(i);
  }

  function setMuted(m) {
    state.muted = m;
    var btn = document.getElementById('fdMute');
    btn.classList.toggle('active', m);
    btn.innerHTML = m ? '<i class="fas fa-volume-mute"></i>' : '<i class="fas fa-volume-up"></i>';
    if (m && 'speechSynthesis' in window) window.speechSynthesis.cancel();
    if (m) stopFrameAudio();
    speakFrame(state.index);
  }

  function setAutoPlay(on) {
    state.autoPlay = on;
    var btn = document.getElementById('fdAutoplay');
    btn.classList.toggle('active', on);
    if (on) scheduleAuto(1200); else clearAutoTimer();
  }

  function init(frames) {
    FRAMES = frames;
    renderFrames();
    renderDots();
    document.getElementById('fdPrev').addEventListener('click', function () { goTo(state.index - 1); });
    document.getElementById('fdNext').addEventListener('click', function () { goTo(state.index + 1); });
    document.getElementById('fdMute').addEventListener('click', function () { setMuted(!state.muted); });
    document.getElementById('fdAutoplay').addEventListener('click', function () { setAutoPlay(!state.autoPlay); });
    var restartBtn = document.getElementById('fdRestart');
    if (restartBtn) restartBtn.addEventListener('click', restartNarration);
    var playPauseBtn = document.getElementById('fdPlayPause');
    if (playPauseBtn) playPauseBtn.addEventListener('click', togglePlayPause);
    var skipBtn = document.getElementById('fdSkip');
    if (skipBtn) skipBtn.addEventListener('click', function () { goTo(FRAMES.length - 1); });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowRight' || e.key === ' ') goTo(state.index + 1);
      if (e.key === 'ArrowLeft') goTo(state.index - 1);
    });
    var touchStartX = null;
    document.addEventListener('touchstart', function (e) { touchStartX = e.touches[0].clientX; }, { passive: true });
    document.addEventListener('touchend', function (e) {
      if (touchStartX === null) return;
      var dx = e.changedTouches[0].clientX - touchStartX;
      if (Math.abs(dx) > 60) goTo(state.index + (dx < 0 ? 1 : -1));
      touchStartX = null;
    }, { passive: true });

    if ('speechSynthesis' in window) window.speechSynthesis.onvoiceschanged = function () { pickVoice(); };
    goTo(0);
  }

  window.FlipDeck = { init: init };
})();
