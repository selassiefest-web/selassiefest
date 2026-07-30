const CONFIG = {
  contactEmail: 'stephen@selassiefest.com',
  scheduleUrl: 'https://selassiefest.com/'
};

const LOGOS_PUBLIC_BASE = 'https://xdjbgcqaynnzykrglgnf.supabase.co/storage/v1/object/public/plates-for-purpose-logos';
const MUTED_AUTOPLAY_DELAY_MS = 6000;

const BATCH_LABELS = {
  ask: 'The Ask',
  benefits: 'What It Comes With',
  proof: 'The Proof',
  program: 'How It Works',
  fit: 'Is This You?',
  decision: 'Your Decision',
  close: 'What’s Next'
};

const state = {
  index: 0,
  muted: false,
  seen: new Set(),
  voice: null,
  autoPlay: false,
  extended: false,
  autoAdvanceTimer: null,
  restaurant: null,
  selectedDecision: null,
};

let FRAMES = [];

// Builds the whole narrated deck from one restaurant's data. No generic
// {{name}} substitution needed here (unlike the Jerky Jerk deck) -- we
// already know exactly which restaurant this is, so real values are baked
// straight into the copy.
function buildFrames(r, confirmedCount) {
  const detailBits = [];
  if (r.suggested_donation) detailBits.push(r.suggested_donation);
  if (r.target_ask_value) detailBits.push(`roughly ${r.target_ask_value} in value`);
  const detailLine = detailBits.length ? `In practice, that usually looks like: ${detailBits.join(' — ')}.` : '';
  const ask = r.donation_ask || 'a donation to our festival raffle';
  const momentumLine = confirmedCount >= 2
    ? `${confirmedCount} Chicago restaurants have already said yes to this exact program.`
    : `A real Chicago restaurant already said yes to this exact program.`;

  return [
    {
      id: 1,
      batch: 'ask',
      ask: true,
      image: 'assets/images/ask-hero.jpg',
      headline: `Here’s the ask, upfront: ${ask}.`,
      voice: [
        'This is Plates for Purpose.',
        `Being one of us means ${r.business_name}’s name promoted right alongside the festival itself — new customers walking through the door, and a standing invite back every year SelassieFest returns.`,
        detailLine,
        `Sized so it never puts real strain on ${r.business_name}’s kitchen or books.`,
      ].filter(Boolean),
      tellMore: `This is a real program from Ras Tafari Inc — the 501(c)(3) nonprofit behind SelassieFest. The ask is simple and upfront: ${ask}${detailBits.length ? ' (' + detailBits.join(', ') + ')' : ''} — whatever’s comfortable. What matters more is the invitation behind it — restaurants like this one are already part of what makes this community work, and Plates for Purpose is one way to help that work grow.`,
    },
    {
      id: 2,
      batch: 'ask',
      logoReveal: true,
      logos: r.logo_path ? [{ src: `${LOGOS_PUBLIC_BASE}/${r.logo_path}`, alt: r.business_name }] : [],
      image: 'assets/images/logo-bg.jpg',
      headline: `${r.business_name} — here’s what saying yes looks like.`,
      voice: ['Let’s make it official.'],
      tellMore: null,
    },
    {
      id: 3,
      batch: 'benefits',
      image: 'assets/images/exchange.jpg',
      headline: 'What it comes with — the actual trade.',
      voice: [
        `You give: ${ask}.`,
        'You get: free promotion, new customers, festival-day exposure, a vendor invite, and a tax-deductible receipt.',
      ],
      tellMore: `${r.business_name} would give ${ask.toLowerCase()} — and get free promotion through SelassieFest’s social channels and on-site signage, a shoutout from the Main Stage, a standing invite to return as a vendor at Ital Marketplace or Heritage Village, and a donation acknowledgment letter for tax records.`,
    },
    {
      id: 4,
      batch: 'benefits',
      image: 'assets/images/stage-day.jpg',
      headline: 'It’s not just a logo on a page. It’s your name from the stage, in front of a crowd that came to eat.',
      voice: ['On-site signage. An announcement from the Main Stage. A shoutout on SelassieFest’s own social channels.'],
      tellMore: 'The festival-day recognition — signage, a Main Stage shoutout, a post from SelassieFest’s own social channels — is the amplification layer on top of whatever content and goodwill the partnership builds.',
    },
    {
      id: 5,
      batch: 'proof',
      proof: true,
      proofLink: { url: '/plates-for-purpose/jerky-jerk/', label: 'View the Example →' },
      image: 'assets/images/proof-jerky-jerk.jpg',
      headline: 'This isn’t hypothetical — here’s how it went for Jerky Jerk.',
      voice: [momentumLine, 'Here’s their completed story, start to finish.'],
      tellMore: 'Jerky Jerk, a real Chicago Caribbean restaurant, said yes to this exact program — the same ask, the same benefits. Tap through to see exactly how it played out for them, narrated the same way this deck is.',
    },
    {
      id: 6,
      batch: 'program',
      image: 'assets/images/timeline.jpg',
      headline: 'Here’s what happens next, and when.',
      voice: [
        'Say yes, and we confirm the details this week.',
        'SelassieFest returns July 24th, 2027 — that’s the target for handing off what you’re able to give.',
        'We’re building our 2027 Founding Restaurant Partner roster right now. We’d love to hear back within the next 7 days so we can lock in the lineup.',
      ],
      tellMore: 'The earlier a restaurant is confirmed, the earlier its name starts showing up in SelassieFest’s promotion — time in front of the festival’s audience before July 24, 2027 is a real, finite resource, which is why we’re asking for a response within about a week rather than leaving it open-ended.',
    },
    {
      id: 7,
      batch: 'fit',
      image: 'assets/images/ingredients.jpg',
      headline: 'Here’s the profile that made this work before — does yours match?',
      voice: [
        'Jamaican, Caribbean, or African diaspora cuisine that fits the SelassieFest food identity.',
        'Locally owned, community-facing, and active — or growth-minded — on social media.',
        'Able to comfortably give what’s being asked, without financial strain.',
      ],
      tellMore: 'Restaurants best suited for Plates for Purpose serve Caribbean or African diaspora cuisine that fits the SelassieFest food identity, are locally owned and community-facing, and can comfortably make the ask without financial strain. That’s the same checklist Jerky Jerk fit — and the same one being used here.',
    },
    {
      id: 8,
      batch: 'decision',
      decision: true,
      offerChoices: Array.isArray(r.offer_choices) ? r.offer_choices : [],
      offerNote: r.offer_note || null,
      image: 'assets/images/marketplace.jpg',
      headline: 'What do you think?',
      // Only the "yes" path gets spoken -- narration nudges toward the
      // desired action rather than reading out all three options evenly;
      // "Let's talk more" and "Not right now" stay visible as real buttons,
      // just unspoken.
      voice: [`Whenever you’re ready, just tap “Yes, count us in” below.`],
      tellMore: null,
    },
    {
      id: 9,
      batch: 'close',
      cta: true,
      image: 'assets/images/close-bg.jpg',
      headline: 'Let’s talk.',
      voice: [],
      tellMore: null,
    },
  ];
}

function tellMoreParagraphs(tellMore) {
  if (!tellMore) return [];
  if (Array.isArray(tellMore)) return tellMore;
  return tellMore.split('\n\n');
}

function escapeHtml(s) {
  return String(s == null ? '' : s).replace(/[&<>"']/g, (c) =>
    ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c])
  );
}

function renderFrames() {
  const viewer = document.getElementById('frame-viewer');
  viewer.innerHTML = '';
  FRAMES.forEach((frame, i) => {
    const el = document.createElement('div');
    el.className = 'frame';
    el.dataset.batch = frame.batch;
    if (frame.ask) el.dataset.ask = 'true';
    el.dataset.index = i;

    const visual = document.createElement('div');
    visual.className = 'frame-visual';
    if (frame.image) {
      visual.style.backgroundImage = `url('${frame.image}')`;
      visual.style.backgroundRepeat = 'no-repeat';
    }
    const logoRow = (frame.logos && frame.logos.length) ? `
      <div class="logo-row">
        ${frame.logos.map((l) => `<img src="${l.src}" alt="${escapeHtml(l.alt)}">`).join('')}
      </div>
    ` : '';
    visual.innerHTML = `
      <span class="frame-counter">${String(i + 1).padStart(2, '0')} / ${FRAMES.length}</span>
      ${logoRow}
    `;

    const content = document.createElement('div');
    content.className = 'frame-content';

    if (frame.cta) {
      content.innerHTML = `
        <div class="frame-content-inner">
          <span class="batch-label">${BATCH_LABELS[frame.batch] || ''}</span>
          <h1 class="headline">${escapeHtml(frame.headline)}</h1>
          <div class="cta-card">
            <div class="cta-buttons">
              <a class="cta-btn primary" href="mailto:${CONFIG.contactEmail}">Email Ras Tafari Inc.</a>
              <a class="cta-btn secondary" href="${CONFIG.scheduleUrl}" target="_blank" rel="noopener">Visit SelassieFest.com</a>
            </div>
            <button type="button" class="cta-copy-email" data-email="${CONFIG.contactEmail}">No mail app? Tap to copy: ${CONFIG.contactEmail}</button>
          </div>
        </div>
      `;
    } else if (frame.decision) {
      const offerChoiceButtons = (frame.offerChoices || [])
        .map((choice) => `<button type="button" class="offer-choice" data-value="${escapeHtml(choice)}">${escapeHtml(choice)}</button>`)
        .join('');
      content.innerHTML = `
        <div class="frame-content-inner">
          <span class="batch-label">${BATCH_LABELS[frame.batch] || ''}</span>
          <h1 class="headline">${escapeHtml(frame.headline)}</h1>
          <form id="decision-form">
            <input type="text" name="sf_hp_company" class="honeypot" tabindex="-1" autocomplete="off">
            <div class="decision-choices">
              <button type="button" class="decision-choice" data-value="yes">Yes, count us in</button>
              <button type="button" class="decision-choice" data-value="maybe">Let’s talk more</button>
              <button type="button" class="decision-choice" data-value="no">Not right now</button>
            </div>
            <div class="decision-fields" id="decision-fields" hidden>
              <div class="offer-choices-block" id="offer-choices-block" hidden>
                <label class="offer-choices-label">What can you offer?</label>
                <div class="offer-choices" id="offer-choices">
                  ${offerChoiceButtons}
                  <button type="button" class="offer-choice" data-value="__other__">Something else</button>
                </div>
                <div class="form-field" id="offer-other-field" hidden>
                  <label for="offer-other-text">Tell us what you’d like to give</label>
                  <textarea id="offer-other-text" name="offerOther"></textarea>
                </div>
                ${frame.offerNote ? `<p class="offer-note">${escapeHtml(frame.offerNote)}</p>` : ''}
              </div>
              <div class="form-field">
                <label for="respondent-name">Your name</label>
                <input type="text" id="respondent-name" name="respondentName">
              </div>
              <div class="form-field">
                <label for="respondent-email">Your email <span class="required-mark">*</span></label>
                <input type="email" id="respondent-email" name="respondentEmail" required>
              </div>
              <div class="form-field">
                <label for="contact-info">Phone (optional)</label>
                <input type="text" id="contact-info" name="contactInfo">
              </div>
              <button type="submit" class="submit-btn" id="submit-btn">Send Our Decision</button>
            </div>
          </form>
          <div id="thank-you" class="thank-you" hidden>
            <div class="big">Thank you! \u{1F64F}\u{1F3FE}</div>
            <p>We’ve got your response. If you said yes, keep an eye on your email — that's where we'll confirm your raffle tickets are being prepared.</p>
          </div>
        </div>
      `;
    } else {
      const paragraphs = tellMoreParagraphs(frame.tellMore);
      const proofBtn = frame.proofLink
        ? `<a class="proof-link-btn" href="${frame.proofLink.url}" target="_blank" rel="noopener">${frame.proofLink.label}</a>`
        : '';
      content.innerHTML = `
        <div class="frame-content-inner">
          <span class="batch-label">${BATCH_LABELS[frame.batch] || ''}</span>
          <h1 class="headline">${escapeHtml(frame.headline)}</h1>
          ${proofBtn}
          ${paragraphs.length ? `
            <button class="tell-me-more-toggle" data-index="${i}">
              <span class="label">Tell me more</span><span class="chev">▾</span>
            </button>
            <div class="tell-me-more-panel" hidden>
              ${paragraphs.map((p) => `<p>${escapeHtml(p)}</p>`).join('')}
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
      clearAutoAdvance();
      if (!open) {
        const idx = Number(btn.dataset.index);
        speakOnce(tellMoreParagraphs(FRAMES[idx].tellMore));
      } else if ('speechSynthesis' in window) {
        speechSynthesis.cancel();
      }
    });
  });

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

  const decisionForm = document.getElementById('decision-form');
  if (decisionForm) {
    let selectedOffer = null;

    decisionForm.querySelectorAll('.decision-choice').forEach((btn) => {
      btn.addEventListener('click', () => {
        state.selectedDecision = btn.dataset.value;
        decisionForm.querySelectorAll('.decision-choice').forEach((b) => b.classList.toggle('selected', b === btn));
        document.getElementById('decision-fields').hidden = false;
        // The offer picker only makes sense once someone's actually said
        // yes -- asking "which package" before that is presumptuous.
        document.getElementById('offer-choices-block').hidden = btn.dataset.value !== 'yes';
        clearAutoAdvance();
      });
    });

    decisionForm.querySelectorAll('.offer-choice').forEach((btn) => {
      btn.addEventListener('click', () => {
        selectedOffer = btn.dataset.value;
        decisionForm.querySelectorAll('.offer-choice').forEach((b) => b.classList.toggle('selected', b === btn));
        document.getElementById('offer-other-field').hidden = selectedOffer !== '__other__';
      });
    });

    decisionForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const form = e.target;
      if (form.sf_hp_company.value) return;
      if (!state.selectedDecision) return;
      const btn = document.getElementById('submit-btn');
      btn.disabled = true;
      btn.textContent = 'Sending…';
      const offerDetails = state.selectedDecision !== 'yes'
        ? null
        : (selectedOffer === '__other__' ? form.offerOther.value : selectedOffer) || null;
      try {
        await window.sfSupabase.submitPlatesForPurposeResponse({
          restaurantSlug: state.restaurant.slug,
          businessName: state.restaurant.business_name,
          decision: state.selectedDecision,
          offerDetails,
          respondentName: form.respondentName.value,
          email: form.respondentEmail.value,
          contactInfo: form.contactInfo.value,
        });
        form.hidden = true;
        document.getElementById('thank-you').hidden = false;
        setTimeout(() => goTo(state.index + 1), 1800);
      } catch (err) {
        console.error('Failed to submit decision:', err);
        btn.disabled = false;
        btn.textContent = 'Send Our Decision';
        alert('Sorry, something went wrong sending your decision. Please try again, or email stephen@selassiefest.com directly.');
      }
    });
  }
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

// Never auto-advances off the decision frame -- that one needs a real
// answer, not a timer, regardless of the auto-play setting.
function scheduleAutoAdvance(delayMs) {
  clearAutoAdvance();
  if (!state.autoPlay || state.index >= FRAMES.length - 1) return;
  if (FRAMES[state.index] && FRAMES[state.index].decision) return;
  state.autoAdvanceTimer = setTimeout(() => goTo(state.index + 1), delayMs);
}

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

  const mainLines = frame.voice || [];
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
  document.getElementById('nav-mute').textContent = muted ? '\u{1F507}' : '\u{1F50A}';
  if (muted && 'speechSynthesis' in window) speechSynthesis.cancel();
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
  speakFrame(FRAMES[state.index]);
}

function beginExperience() {
  document.getElementById('start-screen').hidden = true;
  document.getElementById('deck').hidden = false;

  state.autoPlay = document.getElementById('opt-autoplay').checked;
  state.extended = document.getElementById('opt-extended').checked;

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

async function init() {
  const params = new URLSearchParams(location.search);
  const slug = (params.get('r') || '').trim();
  if (!slug) {
    showNotFound();
    return;
  }
  let restaurant = null;
  try {
    restaurant = await window.sfSupabase.fetchPlatesForPurposeRestaurant(slug);
  } catch (err) {
    console.error('Failed to load restaurant:', err);
  }
  if (!restaurant) {
    showNotFound();
    return;
  }
  state.restaurant = restaurant;

  let confirmedCount = 0;
  try {
    confirmedCount = await window.sfSupabase.fetchPlatesForPurposeConfirmedCount();
  } catch (err) {
    console.error('Failed to load confirmed count:', err);
  }
  FRAMES = buildFrames(restaurant, confirmedCount);

  document.title = `Plates for Purpose — ${restaurant.business_name}`;
  document.getElementById('start-sub-text').textContent =
    `A quick, narrated walkthrough of the ask for ${restaurant.business_name} — the ask, what it comes with, and how it played out for a restaurant already in. Tap begin to start the narration — this also lets your browser enable audio playback.`;
  if (restaurant.logo_path) {
    const logoImg = document.getElementById('start-logo');
    logoImg.src = `${LOGOS_PUBLIC_BASE}/${restaurant.logo_path}`;
    logoImg.alt = restaurant.business_name;
    logoImg.hidden = false;
  }

  document.getElementById('loading-screen').hidden = true;
  document.getElementById('start-screen').hidden = false;
}

function showNotFound() {
  document.getElementById('loading-screen').hidden = true;
  document.getElementById('not-found-screen').hidden = false;
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

init();
