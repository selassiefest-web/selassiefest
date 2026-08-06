const CONFIG = {
  contactEmail: 'stephen@selassiefest.com',
  contactPhone: '414-909-3279',
  backUrl: '/empress-empowerment-village/'
};

const state = {
  index: 0,
  investorName: '',
  muted: false,
  seen: new Set(),
  voice: null
};

function tellMoreParagraphs(tellMore) {
  if (!tellMore) return [];
  if (Array.isArray(tellMore)) return tellMore;
  return tellMore.split('\n\n');
}

function renderTable(table) {
  const rows = table.rows.map((r) => `<tr>${r.map((c) => `<td>${c}</td>`).join('')}</tr>`).join('');
  return `
    <div class="detail-table-title">${table.title}</div>
    <table class="deck-table">
      <thead><tr>${table.headers.map((h) => `<th>${h}</th>`).join('')}</tr></thead>
      <tbody>${rows}</tbody>
    </table>
  `;
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
      // 'contain', not 'cover': these photos are a fixed 1792x1024, but the
      // frame-visual pane is much taller/narrower than that on desktop, so
      // 'cover' scaled the image up and cropped both edges symmetrically --
      // cutting the corner EEV logo watermark out of frame entirely. 'contain'
      // guarantees the full photo (logo included) is always visible, matching
      // the letterboxed-on-a-solid-background technique /the-legacy uses for
      // its own non-cropping frames.
      visual.style.backgroundSize = 'contain';
      visual.style.backgroundPosition = 'center';
      visual.style.backgroundRepeat = 'no-repeat';
      visual.style.backgroundColor = '#0D0D0D';
    }
    // Once a frame has a real photo, the "visual spec" caption (the original
    // art-direction note) would just be redundant text sitting on top of the
    // finished image -- only show it for frames still on the CSS gradient placeholder.
    const captionBlock = frame.image ? '' : `<span class="visual-caption"><strong>Visual spec</strong>${frame.visual}</span>`;
    visual.innerHTML = `
      <span class="frame-counter">${String(i + 1).padStart(2, '0')} / ${FRAMES.length}</span>
      ${captionBlock}
    `;

    const content = document.createElement('div');
    content.className = 'frame-content';

    const bulletsBlock = frame.bullets && frame.bullets.length
      ? `<ul class="bullet-list">${frame.bullets.map((b) => `<li>${b}</li>`).join('')}</ul>`
      : '';

    if (frame.cta) {
      content.innerHTML = `
        <div class="frame-content-inner">
          <span class="batch-label">${BATCH_LABELS[frame.batch] || ''}</span>
          <h1 class="headline">${frame.headline}</h1>
          ${bulletsBlock}
          <div class="cta-card">
            <div class="cta-buttons">
              <a class="cta-btn primary" href="mailto:${CONFIG.contactEmail}"><i class="fas fa-envelope"></i> Email Us</a>
              <a class="cta-btn secondary" href="tel:${CONFIG.contactPhone.replace(/[^0-9+]/g, '')}"><i class="fas fa-phone"></i> ${CONFIG.contactPhone}</a>
            </div>
            <p class="cta-fill-note">Zeffy and GoFundMe links launch closer to the event. In the meantime, reach out directly.</p>
          </div>
        </div>
      `;
    } else {
      const paragraphs = tellMoreParagraphs(frame.tellMore);
      const tables = frame.detailTables || [];
      const hasMore = paragraphs.length > 0 || tables.length > 0;
      content.innerHTML = `
        <div class="frame-content-inner">
          <span class="batch-label">${BATCH_LABELS[frame.batch] || ''}</span>
          ${frame.personalize === 'start' && investorName ? `<div class="personalize-tag">Prepared for ${investorName}</div>` : ''}
          <h1 class="headline">${frame.headline}</h1>
          ${bulletsBlock}
          ${hasMore ? `
            <button class="tell-me-more-toggle" data-index="${i}">
              <span class="label">Tell me more</span><span class="chev">▾</span>
            </button>
            <div class="tell-me-more-panel" hidden>
              ${paragraphs.map((p) => `<p>${p}</p>`).join('')}
              ${tables.map((t) => `<div class="detail-table-wrap">${renderTable(t)}</div>`).join('')}
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
    dot.setAttribute('aria-label', `Go to slide ${i + 1}`);
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
  const lines = frame.voice || [];
  if (!lines.length) return;

  const isAskFrame = !!frame.ask;
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
