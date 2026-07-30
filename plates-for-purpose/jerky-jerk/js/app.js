const CONFIG = {
  contactEmail: 'stephen@selassiefest.com',
  contactPhone: '(414) 909-3279',
  scheduleUrl: 'https://selassiefest.com/'
};

const state = {
  index: 0,
  investorName: '',
  muted: false,
  seen: new Set(),
  voice: null,
  speaking: false,
  autoPlay: false,
  extended: false,
  autoAdvanceTimer: null
};

// If speech is unavailable/muted, auto-advance still needs to move on
// eventually rather than sit frozen -- this is a flat "roughly enough time
// to read the slide" fallback, not a per-word estimate.
const MUTED_AUTOPLAY_DELAY_MS = 6000;

function interpolate(text, name) {
  return text.replace('{{name}}', name);
}

function voiceLinesFor(frame) {
  const name = state.investorName.trim();
  if (frame.personalize === 'start') {
    return frame.voice.map((line) => interpolate(line, name || 'your restaurant'));
  }
  if (frame.personalize === 'close') {
    return frame.voice.map((line) => {
      if (!line.includes('{{name}}')) return line;
      return name ? interpolate(line, name) : 'This is the proposal.';
    });
  }
  return frame.voice;
}

function tellMoreParagraphs(tellMore) {
  if (!tellMore) return [];
  if (Array.isArray(tellMore)) return tellMore;
  return tellMore.split('\n\n');
}

function renderFrames() {
  const viewer = document.getElementById('frame-viewer');
  const investorName = state.investorName.trim();
  viewer.innerHTML = '';
  FRAMES.forEach((frame, i) => {
    const el = document.createElement('div');
    el.className = 'frame';
    el.dataset.batch = frame.batch;
    if (frame.ask) el.dataset.ask = 'true';
    el.dataset.index = i;

    const visual = document.createElement('div');
    visual.className = 'frame-visual' + (frame.ask ? ' ask' : '');
    if (frame.image) {
      visual.style.backgroundImage = `url('${frame.image}')`;
      visual.style.backgroundRepeat = 'no-repeat';
      // Text-heavy graphic frames sit on a solid near-black background --
      // 'contain' shows the whole image with invisible letterboxing rather
      // than 'cover' cropping their edge-to-edge text.
      if (frame.imageFit === 'contain') {
        visual.style.backgroundSize = 'contain';
        visual.style.backgroundColor = '#0a0a0a';
      }
    }
    const logoRow = frame.logos ? `
      <div class="logo-row${frame.logoReveal ? ' reveal' : ''}">
        ${frame.logos.map((l) => `<img src="${l.src}" alt="${l.alt}">`).join('')}
      </div>
    ` : '';
    // Once a real designed image or logo exists, the "Visual spec" caption
    // (the original art-direction note) would just be redundant text sitting
    // on top of the finished artwork.
    const captionBlock = (frame.image || frame.logos || frame.video) ? '' : `<span class="visual-caption"><strong>Visual spec</strong>${frame.visual}</span>`;
    // frame.video: set `src` to a locally-stored file for an inline player,
    // or `url` to an external link (YouTube/Instagram/etc.) for a play-button
    // link. Leave both unset and it renders as a marked "coming soon" slot.
    // frame.video.links: list of {platform, url} pointing to the influencer's
    // actual posts on each platform (Instagram, TikTok, etc.). A null url
    // renders as a "coming soon" pill instead of a link.
    const socialLinksRow = (frame.video && frame.video.links && frame.video.links.length) ? `
      <div class="video-links">
        ${frame.video.links.map((l) => l.url
          ? `<a class="social-pill" href="${l.url}" target="_blank" rel="noopener">${l.platform}</a>`
          : `<span class="social-pill social-pill--pending">${l.platform} — coming soon</span>`
        ).join('')}
      </div>
    ` : '';
    const videoBlock = frame.video ? `
      <div class="video-slot">
        ${frame.video.src
          ? `<video class="video-embed" controls playsinline${frame.video.poster ? ` poster="${frame.video.poster}"` : ''}><source src="${frame.video.src}"></video>`
          : frame.video.url
            ? `<a class="video-play" href="${frame.video.url}" target="_blank" rel="noopener" aria-label="Watch the video">&#9658;</a>`
            : `<span class="video-play video-play--pending" aria-label="Video coming soon">&#9658;</span>`
        }
        <span class="video-caption">${frame.video.caption || ''}</span>
        ${socialLinksRow}
      </div>
    ` : '';
    visual.innerHTML = `
      <span class="frame-counter">${String(i + 1).padStart(2, '0')} / ${FRAMES.length}</span>
      ${logoRow}
      ${videoBlock}
      ${captionBlock}
    `;

    const content = document.createElement('div');
    content.className = 'frame-content';

    if (frame.cta) {
      content.innerHTML = `
        <div class="frame-content-inner">
          <span class="batch-label">${BATCH_LABELS[frame.batch] || ''}</span>
          <h1 class="headline">${frame.headline}</h1>
          <div class="cta-card">
            <div class="cta-buttons">
              <a class="cta-btn primary" href="mailto:${CONFIG.contactEmail}">Email Ras Tafari Inc.</a>
              ${CONFIG.scheduleUrl ? `<a class="cta-btn secondary" href="${CONFIG.scheduleUrl}" target="_blank" rel="noopener">Visit SelassieFest.com</a>` : ''}
            </div>
            <button type="button" class="cta-copy-email" id="cta-copy-email" data-email="${CONFIG.contactEmail}">No mail app? Tap to copy: ${CONFIG.contactEmail}</button>
          </div>
        </div>
      `;
    } else {
      const paragraphs = tellMoreParagraphs(frame.tellMore);
      content.innerHTML = `
        <div class="frame-content-inner">
          <span class="batch-label">${BATCH_LABELS[frame.batch] || ''}</span>
          ${frame.proof ? '<span class="proof-badge">Already a SelassieFest partner</span>' : ''}
          ${frame.personalize === 'start' && investorName ? `<div class="personalize-tag">Prepared for ${investorName}</div>` : ''}
          <h1 class="headline">${frame.headline}</h1>
          ${paragraphs.length ? `
            <button class="tell-me-more-toggle" data-index="${i}">
              <span class="label">Tell me more</span><span class="chev">▾</span>
            </button>
            <div class="tell-me-more-panel" hidden>
              ${paragraphs.map((p) => `<p>${p}</p>`).join('')}
            </div>
          ` : ''}
        </div>
      `;
    }

    el.appendChild(visual);
    el.appendChild(content);
    viewer.appendChild(el);
  });

  viewer.querySelectorAll('.tell-me-more-toggle').forEach((btn) => {
    btn.addEventListener('click', () => {
      const panel = btn.nextElementSibling;
      const open = !panel.hidden;
      panel.hidden = open;
      btn.classList.toggle('open', !open);
      // Tapping this while driving beats having to read the panel -- also
      // pause any pending auto-advance so it doesn't cut the explanation off.
      clearAutoAdvance();
      if (!open) {
        const idx = Number(btn.dataset.index);
        speakOnce(tellMoreParagraphs(FRAMES[idx].tellMore));
      } else if ('speechSynthesis' in window) {
        speechSynthesis.cancel();
      }
    });
  });

  // Fallback for viewers with no mail app configured -- mailto: links go
  // nowhere silently in that case, so this copies the address instead.
  viewer.querySelectorAll('.cta-copy-email').forEach((btn) => {
    const original = btn.textContent;
    btn.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(btn.dataset.email);
        btn.textContent = 'Copied! ' + btn.dataset.email;
      } catch (err) {
        console.error('Clipboard copy failed:', err);
        btn.textContent = btn.dataset.email + ' (copy failed — select manually)';
      }
      setTimeout(() => { btn.textContent = original; }, 2500);
    });
  });
}

function renderDots() {
  const dots = document.getElementById('progress-dots');
  dots.innerHTML = '';
  FRAMES.forEach((_, i) => {
    const dot = document.createElement('button');
    dot.className = 'dot';
    dot.setAttribute('aria-label', `Go to frame ${i + 1}`);
    dot.addEventListener('click', () => goTo(i));
    dots.appendChild(dot);
  });
}

function updateDots() {
  document.querySelectorAll('.dot').forEach((dot, i) => {
    dot.classList.toggle('active', i === state.index);
    dot.classList.toggle('seen', state.seen.has(i) && i !== state.index);
  });
}

function pickVoice() {
  const voices = speechSynthesis.getVoices().filter((v) => v.lang.startsWith('en'));
  if (!voices.length) return null;
  const byScore = (v) => {
    const n = v.name.toLowerCase();
    if (n.includes('natural') || n.includes('neural')) return 3;
    if (n.includes('google')) return 2;
    if (v.lang === 'en-US') return 1;
    return 0;
  };
  return voices.sort((a, b) => byScore(b) - byScore(a))[0];
}

function clearAutoAdvance() {
  if (state.autoAdvanceTimer) {
    clearTimeout(state.autoAdvanceTimer);
    state.autoAdvanceTimer = null;
  }
}

// Schedules the hands-free jump to the next frame. No-ops if auto-play is
// off or this is already the last frame -- called unconditionally from
// speakFrame's completion path, so it's the single place that decides
// whether a jump actually happens.
function scheduleAutoAdvance(delayMs) {
  clearAutoAdvance();
  if (!state.autoPlay || state.index >= FRAMES.length - 1) return;
  state.autoAdvanceTimer = setTimeout(() => goTo(state.index + 1), delayMs);
}

// One-off speech for the manually-tapped "Tell me more" panel -- independent
// of the auto-play chain, so it never fights with a scheduled auto-advance.
function speakOnce(lines, rate = 0.92, gapMs = 350) {
  if (!('speechSynthesis' in window) || !lines.length) return;
  speechSynthesis.cancel();
  let i = 0;
  const speakNext = () => {
    if (i >= lines.length) return;
    const utter = new SpeechSynthesisUtterance(lines[i]);
    utter.voice = state.voice;
    utter.rate = rate;
    utter.onend = () => { i += 1; setTimeout(speakNext, gapMs); };
    speechSynthesis.speak(utter);
  };
  speakNext();
}

function speakFrame(frame) {
  clearAutoAdvance();
  if ('speechSynthesis' in window) speechSynthesis.cancel();

  const mainLines = voiceLinesFor(frame);
  const extraLines = state.extended ? tellMoreParagraphs(frame.tellMore) : [];
  const lines = [...mainLines, ...extraLines];

  const isAskFrame = frame.batch === 'ask';
  const rate = isAskFrame ? 0.85 : 0.92;
  const gapMs = isAskFrame ? 650 : 350;

  if (!('speechSynthesis' in window) || state.muted || !lines.length) {
    scheduleAutoAdvance(MUTED_AUTOPLAY_DELAY_MS);
    return;
  }

  let i = 0;
  const speakNext = () => {
    if (i >= lines.length || state.muted) {
      scheduleAutoAdvance(1200);
      return;
    }
    const utter = new SpeechSynthesisUtterance(lines[i]);
    utter.voice = state.voice;
    utter.rate = rate;
    utter.onend = () => {
      i += 1;
      setTimeout(speakNext, gapMs);
    };
    speechSynthesis.speak(utter);
  };
  speakNext();
}

function goTo(index) {
  if (index < 0 || index >= FRAMES.length) return;
  state.index = index;
  state.seen.add(index);

  document.querySelectorAll('.frame').forEach((el, i) => {
    el.classList.toggle('active', i === index);
  });
  updateDots();

  document.getElementById('nav-prev').disabled = index === 0;
  document.getElementById('nav-next').disabled = index === FRAMES.length - 1;

  speakFrame(FRAMES[index]);
}

function setMuted(muted) {
  state.muted = muted;
  document.getElementById('nav-mute').textContent = muted ? '🔇' : '🔊';
  if (muted && 'speechSynthesis' in window) speechSynthesis.cancel();
  // Muting mid-speech needs the auto-advance fallback timer instead of the
  // onend callback it would otherwise get; unmuting just replays the frame,
  // which re-establishes the normal onend-based timing.
  speakFrame(FRAMES[state.index]);
}

function setAutoPlay(on) {
  state.autoPlay = on;
  const btn = document.getElementById('nav-autoplay');
  btn.classList.toggle('active', on);
  btn.setAttribute('aria-pressed', String(on));
  if (!on) {
    clearAutoAdvance();
  } else if (!('speechSynthesis' in window) || !speechSynthesis.speaking) {
    scheduleAutoAdvance(1200);
  }
}

function setExtended(on) {
  state.extended = on;
  const btn = document.getElementById('nav-extended');
  btn.classList.toggle('active', on);
  btn.setAttribute('aria-pressed', String(on));
  // Re-speak the current frame so the change takes effect immediately
  // instead of waiting for the next slide.
  speakFrame(FRAMES[state.index]);
}

function beginExperience() {
  state.investorName = document.getElementById('investor-name').value;
  // Set state directly rather than via setAutoPlay/setExtended -- those also
  // trigger an immediate re-speak, which would race with goTo(0)'s own
  // first speakFrame call below.
  state.autoPlay = document.getElementById('opt-autoplay').checked;
  state.extended = document.getElementById('opt-extended').checked;
  document.getElementById('start-screen').hidden = true;
  document.getElementById('deck').hidden = false;

  renderFrames();
  renderDots();

  const autoBtn = document.getElementById('nav-autoplay');
  autoBtn.classList.toggle('active', state.autoPlay);
  autoBtn.setAttribute('aria-pressed', String(state.autoPlay));
  const extBtn = document.getElementById('nav-extended');
  extBtn.classList.toggle('active', state.extended);
  extBtn.setAttribute('aria-pressed', String(state.extended));

  goTo(0);
}

document.getElementById('begin-btn').addEventListener('click', beginExperience);

document.getElementById('nav-next').addEventListener('click', () => goTo(state.index + 1));
document.getElementById('nav-prev').addEventListener('click', () => goTo(state.index - 1));
document.getElementById('nav-replay').addEventListener('click', () => speakFrame(FRAMES[state.index]));
document.getElementById('nav-mute').addEventListener('click', () => setMuted(!state.muted));
document.getElementById('nav-autoplay').addEventListener('click', () => setAutoPlay(!state.autoPlay));
document.getElementById('nav-extended').addEventListener('click', () => setExtended(!state.extended));

document.addEventListener('keydown', (e) => {
  if (document.getElementById('deck').hidden) return;
  if (e.key === 'ArrowRight' || e.key === ' ') goTo(state.index + 1);
  if (e.key === 'ArrowLeft') goTo(state.index - 1);
});

let touchStartX = null;
document.addEventListener('touchstart', (e) => {
  if (document.getElementById('deck').hidden) return;
  touchStartX = e.touches[0].clientX;
}, { passive: true });
document.addEventListener('touchend', (e) => {
  if (touchStartX === null || document.getElementById('deck').hidden) return;
  const dx = e.changedTouches[0].clientX - touchStartX;
  if (Math.abs(dx) > 60) goTo(state.index + (dx < 0 ? 1 : -1));
  touchStartX = null;
}, { passive: true });

if ('speechSynthesis' in window) {
  speechSynthesis.onvoiceschanged = () => { state.voice = pickVoice(); };
  state.voice = pickVoice();
}
