const CONFIG = {
  contactEmail: 'selassiefest@gmail.com',
  contactPhone: '(414) 909-3279',
  scheduleUrl: 'https://selassiefest.com/'
};

const state = {
  index: 0,
  investorName: '',
  muted: false,
  seen: new Set(),
  voice: null,
  speaking: false
};

function interpolate(text, name) {
  return text.replace('{{name}}', name);
}

function voiceLinesFor(frame) {
  const name = state.investorName.trim();
  if (frame.personalize === 'start') {
    return frame.voice
      .filter((line) => name || !line.includes('{{name}}'))
      .map((line) => interpolate(line, name));
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
    const videoBlock = frame.video ? `
      <div class="video-slot">
        ${frame.video.src
          ? `<video class="video-embed" controls playsinline${frame.video.poster ? ` poster="${frame.video.poster}"` : ''}><source src="${frame.video.src}"></video>`
          : frame.video.url
            ? `<a class="video-play" href="${frame.video.url}" target="_blank" rel="noopener" aria-label="Watch the video">&#9658;</a>`
            : `<span class="video-play video-play--pending" aria-label="Video coming soon">&#9658;</span>`
        }
        <span class="video-caption">${frame.video.caption || ''}</span>
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

function speakFrame(frame) {
  if (!('speechSynthesis' in window) || state.muted) return;
  speechSynthesis.cancel();
  const lines = voiceLinesFor(frame);
  if (!lines.length) return;

  const isAskFrame = frame.batch === 'ask';
  const rate = isAskFrame ? 0.85 : 0.92;
  const gapMs = isAskFrame ? 650 : 350;

  let i = 0;
  const speakNext = () => {
    if (i >= lines.length || state.muted) return;
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
  if (muted) speechSynthesis.cancel();
}

function beginExperience() {
  state.investorName = document.getElementById('investor-name').value;
  document.getElementById('start-screen').hidden = true;
  document.getElementById('deck').hidden = false;

  renderFrames();
  renderDots();
  goTo(0);
}

document.getElementById('begin-btn').addEventListener('click', beginExperience);

document.getElementById('nav-next').addEventListener('click', () => goTo(state.index + 1));
document.getElementById('nav-prev').addEventListener('click', () => goTo(state.index - 1));
document.getElementById('nav-replay').addEventListener('click', () => speakFrame(FRAMES[state.index]));
document.getElementById('nav-mute').addEventListener('click', () => setMuted(!state.muted));

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
