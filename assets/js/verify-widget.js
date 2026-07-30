// Shared "prove you're a real person, and this is really your email"
// widget for public-facing forms (currently the volunteer application and
// the 13 sponsor inquiry pages). Two independent layers:
//
//   1. A honeypot field + a minimum-fill-time check (protect/looksLikeBot)
//      -- catches scripted bots before we ever send anyone an email.
//   2. A one-time 6-digit email code, round-tripped through the
//      request-<purpose>-verification / verify-<purpose>-code Edge
//      Functions (confirm) -- this is what the real table's INSERT policy
//      actually checks (see supabase/schema.sql), so this step is not
//      optional theater: submission is impossible without it.
//
// Usage:
//   window.sfVerify.protect(formEl);                 // call once, on load
//   if (window.sfVerify.looksLikeBot(formEl)) return; // call in submit handler
//   const ok = await window.sfVerify.confirm({ purpose: 'volunteer', email });
//   if (!ok) return; // user cancelled the code prompt
//   // ... proceed with the real submitVolunteerSignup/submitSponsorInquiry call
(function () {
  const FUNCTIONS_BASE = 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1';
  const ENDPOINTS = {
    volunteer: {
      request: `${FUNCTIONS_BASE}/request-volunteer-verification`,
      verify: `${FUNCTIONS_BASE}/verify-volunteer-code`,
    },
    sponsor: {
      request: `${FUNCTIONS_BASE}/request-sponsor-verification`,
      verify: `${FUNCTIONS_BASE}/verify-sponsor-code`,
    },
  };
  const MIN_FILL_MS = 3000;

  function injectStyles() {
    if (document.getElementById('sf-verify-styles')) return;
    const style = document.createElement('style');
    style.id = 'sf-verify-styles';
    style.textContent = `
      #sf-verify-overlay {
        position: fixed; inset: 0; z-index: 9999;
        background: rgba(5,6,8,0.82);
        display: flex; align-items: center; justify-content: center;
        padding: 20px; font-family: 'Jost', sans-serif;
      }
      #sf-verify-overlay[hidden] { display: none; }
      .sf-verify-card {
        width: 100%; max-width: 400px;
        background: #111; border: 1px solid rgba(229,169,60,0.4);
        border-radius: 24px; padding: 28px; color: #F5F5F5;
      }
      .sf-verify-kicker {
        font-size: 0.68rem; letter-spacing: 0.2em; text-transform: uppercase;
        color: #E5A93C; margin-bottom: 10px;
      }
      .sf-verify-title { font-size: 1.2rem; font-weight: 400; margin-bottom: 8px; }
      .sf-verify-sub { font-size: 0.85rem; color: #bbb; font-weight: 300; line-height: 1.5; margin-bottom: 18px; }
      .sf-verify-sub strong { color: #F5F5F5; font-weight: 500; }
      #sf-verify-code-input {
        width: 100%; font-family: 'Jost', sans-serif; font-size: 1.3rem;
        letter-spacing: 0.4em; text-align: center; padding: 12px 14px;
        border-radius: 12px; border: 1px solid rgba(255,255,255,0.15);
        background: #1a1a1a; color: #F5F5F5; margin-bottom: 12px;
      }
      #sf-verify-code-input:focus { outline: none; border-color: #E5A93C; }
      .sf-verify-status { min-height: 1.2em; font-size: 0.8rem; margin-bottom: 12px; }
      .sf-verify-status.is-error { color: #C83737; }
      .sf-verify-status.is-ok { color: #6dbe8f; }
      .sf-verify-actions { display: flex; flex-direction: column; gap: 10px; }
      .sf-verify-btn {
        font-family: 'Jost', sans-serif; font-size: 0.85rem; font-weight: 400;
        letter-spacing: 0.05em; padding: 12px 20px; border-radius: 40px;
        border: none; cursor: pointer; transition: 0.2s;
      }
      .sf-verify-btn.primary { background: #0E5E36; color: #fff; }
      .sf-verify-btn.primary:hover { background: #147a45; }
      .sf-verify-btn.primary:disabled { opacity: 0.5; cursor: default; }
      .sf-verify-row { display: flex; gap: 10px; }
      .sf-verify-row .sf-verify-btn { flex: 1; }
      .sf-verify-btn.secondary { background: transparent; color: #ccc; border: 1px solid rgba(255,255,255,0.15); }
      .sf-verify-btn.secondary:hover { border-color: #E5A93C; color: #E5A93C; }
      .sf-verify-btn.secondary:disabled { opacity: 0.4; cursor: default; }
      .sf-verify-cancel {
        display: block; text-align: center; margin-top: 14px; font-size: 0.78rem;
        color: #888; background: none; border: none; cursor: pointer; text-decoration: underline;
      }
    `;
    document.head.appendChild(style);
  }

  function buildOverlay() {
    let overlay = document.getElementById('sf-verify-overlay');
    if (overlay) return overlay;
    overlay = document.createElement('div');
    overlay.id = 'sf-verify-overlay';
    overlay.hidden = true;
    overlay.innerHTML = `
      <div class="sf-verify-card">
        <div class="sf-verify-kicker">One quick step</div>
        <div class="sf-verify-title">Confirm your email</div>
        <div class="sf-verify-sub" id="sf-verify-sub"></div>
        <input type="text" id="sf-verify-code-input" inputmode="numeric" maxlength="6" placeholder="000000" autocomplete="one-time-code">
        <div class="sf-verify-status" id="sf-verify-status"></div>
        <div class="sf-verify-actions">
          <button type="button" class="sf-verify-btn primary" id="sf-verify-submit-btn">Verify &amp; Continue</button>
          <div class="sf-verify-row">
            <button type="button" class="sf-verify-btn secondary" id="sf-verify-resend-btn">Resend code</button>
          </div>
        </div>
        <button type="button" class="sf-verify-cancel" id="sf-verify-cancel-btn">Cancel</button>
      </div>
    `;
    document.body.appendChild(overlay);
    return overlay;
  }

  async function postJson(url, body) {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    return res.json();
  }

  function startResendCooldown(btn, seconds) {
    let remaining = seconds;
    btn.disabled = true;
    const original = 'Resend code';
    const tick = () => {
      if (remaining <= 0) {
        btn.disabled = false;
        btn.textContent = original;
        return;
      }
      btn.textContent = `Resend code (${remaining}s)`;
      remaining -= 1;
      setTimeout(tick, 1000);
    };
    tick();
  }

  window.sfVerify = {
    // Adds an invisible honeypot field to a form and records when it was
    // rendered, so obvious bots (which fill every field instantly and
    // never actually run this script's timers) get caught before we ever
    // email anyone a code. Safe to call more than once per form.
    protect(form) {
      if (!form || form.dataset.sfProtected) return;
      form.dataset.sfProtected = '1';
      form.dataset.sfMountedAt = String(Date.now());
      const wrap = document.createElement('div');
      wrap.style.cssText = 'position:absolute;left:-9999px;top:-9999px;height:0;width:0;overflow:hidden;';
      wrap.setAttribute('aria-hidden', 'true');
      const hp = document.createElement('input');
      hp.type = 'text';
      hp.name = 'sf_hp_website';
      hp.tabIndex = -1;
      hp.autocomplete = 'off';
      wrap.appendChild(hp);
      form.appendChild(wrap);
    },

    // True if the honeypot got filled in or the form was submitted
    // suspiciously fast -- both strong signals of a script driving the
    // form rather than a person.
    looksLikeBot(form) {
      if (!form) return false;
      const hp = form.querySelector('input[name="sf_hp_website"]');
      if (hp && hp.value) return true;
      const mountedAt = Number(form.dataset.sfMountedAt || 0);
      if (mountedAt && Date.now() - mountedAt < MIN_FILL_MS) return true;
      return false;
    },

    // Inserts a visible, required "I'm not a robot" checkbox directly
    // before the form's submit button, for pages that don't already have
    // one hand-authored in their markup. Idempotent. Returns the checkbox.
    insertHumanCheckbox(form, submitBtn) {
      if (!form) return null;
      const existing = form.querySelector('[data-sf-human-check]');
      if (existing) return existing;
      const wrap = document.createElement('label');
      wrap.className = 'full-col';
      wrap.style.cssText = 'display:flex; align-items:center; gap:8px; font-size:0.85rem; font-weight:300; margin:4px 0 8px;';
      const box = document.createElement('input');
      box.type = 'checkbox';
      box.required = true;
      box.dataset.sfHumanCheck = '1';
      box.style.cssText = 'width:auto; flex-shrink:0;';
      wrap.appendChild(box);
      wrap.appendChild(document.createTextNode("I confirm I'm a real person submitting this form (not a bot)."));
      const btn = submitBtn || form.querySelector('button[type="submit"]');
      if (btn && btn.parentElement === form) {
        form.insertBefore(wrap, btn);
      } else if (btn) {
        btn.insertAdjacentElement('beforebegin', wrap);
      } else {
        form.appendChild(wrap);
      }
      return box;
    },

    // True once the checkbox inserted by insertHumanCheckbox (or an
    // equivalent hand-authored one marked data-sf-human-check) is checked.
    humanCheckPassed(form) {
      if (!form) return false;
      const box = form.querySelector('[data-sf-human-check]');
      return box ? box.checked : true;
    },

    // Sends a code to `email`, shows a modal for the visitor to enter it,
    // and resolves true once verify-<purpose>-code confirms it -- which is
    // the only way the corresponding table's RLS policy will accept the
    // real insert afterward. Resolves false if the visitor cancels.
    async confirm({ purpose, email }) {
      const endpoints = ENDPOINTS[purpose];
      if (!endpoints) throw new Error(`Unknown verification purpose: ${purpose}`);

      injectStyles();
      const overlay = buildOverlay();
      const sub = overlay.querySelector('#sf-verify-sub');
      const input = overlay.querySelector('#sf-verify-code-input');
      const status = overlay.querySelector('#sf-verify-status');
      const submitBtn = overlay.querySelector('#sf-verify-submit-btn');
      const resendBtn = overlay.querySelector('#sf-verify-resend-btn');
      const cancelBtn = overlay.querySelector('#sf-verify-cancel-btn');

      sub.innerHTML = `We're sending a 6-digit code to <strong>${email}</strong>. Enter it below to confirm it's really you.`;
      input.value = '';
      status.textContent = 'Sending code…';
      status.className = 'sf-verify-status';
      submitBtn.disabled = true;
      resendBtn.disabled = true;
      overlay.hidden = false;
      input.focus();

      const sendCode = async () => {
        status.textContent = 'Sending code…';
        status.className = 'sf-verify-status';
        try {
          const res = await postJson(endpoints.request, { email });
          if (res.error) {
            status.textContent = res.error;
            status.className = 'sf-verify-status is-error';
          } else {
            status.textContent = 'Code sent — check your inbox (and spam folder).';
            status.className = 'sf-verify-status is-ok';
          }
        } catch (err) {
          status.textContent = 'Could not send the code. Check your connection and try again.';
          status.className = 'sf-verify-status is-error';
        }
        submitBtn.disabled = false;
        startResendCooldown(resendBtn, 60);
      };

      await sendCode();

      return new Promise((resolve) => {
        let settled = false;

        const cleanup = () => {
          overlay.hidden = true;
          submitBtn.removeEventListener('click', onVerify);
          resendBtn.removeEventListener('click', onResend);
          cancelBtn.removeEventListener('click', onCancel);
          input.removeEventListener('keydown', onKeydown);
        };

        const onVerify = async () => {
          const code = input.value.trim();
          if (!code) return;
          submitBtn.disabled = true;
          status.textContent = 'Checking…';
          status.className = 'sf-verify-status';
          try {
            const res = await postJson(endpoints.verify, { email, code });
            if (res.valid) {
              status.textContent = 'Verified!';
              status.className = 'sf-verify-status is-ok';
              settled = true;
              cleanup();
              resolve(true);
            } else {
              status.textContent = res.error || "That code doesn't match.";
              status.className = 'sf-verify-status is-error';
              submitBtn.disabled = false;
              input.select();
            }
          } catch (err) {
            status.textContent = 'Could not check the code. Try again.';
            status.className = 'sf-verify-status is-error';
            submitBtn.disabled = false;
          }
        };

        const onResend = () => { sendCode(); };
        const onCancel = () => {
          if (settled) return;
          cleanup();
          resolve(false);
        };
        const onKeydown = (e) => {
          if (e.key === 'Enter') { e.preventDefault(); onVerify(); }
        };

        submitBtn.addEventListener('click', onVerify);
        resendBtn.addEventListener('click', onResend);
        cancelBtn.addEventListener('click', onCancel);
        input.addEventListener('keydown', onKeydown);
      });
    },
  };
})();
