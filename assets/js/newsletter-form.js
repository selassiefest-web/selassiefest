// Progressively enhances every sitewide footer newsletter form
// (see the SF-CANONICAL-FOOTER block duplicated across pages).
// Signups go through the newsletter-signup edge function, which checks a
// Cloudflare Turnstile token before saving; the table no longer takes
// direct anon inserts (bots were signing up strangers, 10/6/2026).
(function () {
  var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  var SIGNUP_URL = 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/newsletter-signup';
  var TURNSTILE_SITE_KEY = '0x4AAAAAAFP_zBLKj8yz11WF';

  function setMsg(msgEl, text, state) {
    msgEl.textContent = text;
    msgEl.classList.remove('is-success', 'is-error');
    if (state) msgEl.classList.add(state);
  }

  var forms = document.querySelectorAll('[data-sf-newsletter-form]');
  if (!forms.length) return;

  // Turnstile is loaded once per page and rendered into each form. Managed
  // mode with interaction-only appearance: most visitors never see it.
  var widgets = [];
  window.sfNewsletterTurnstileReady = function () {
    widgets.forEach(function (w) {
      w.id = window.turnstile.render(w.el, {
        sitekey: TURNSTILE_SITE_KEY,
        appearance: 'interaction-only',
        action: 'newsletter',
      });
    });
  };
  var script = document.createElement('script');
  script.src = 'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit&onload=sfNewsletterTurnstileReady';
  script.async = true;
  script.defer = true;
  document.head.appendChild(script);

  forms.forEach(function (form) {
    var input = form.querySelector('input[type="email"]');
    var button = form.querySelector('button');
    var msgEl = form.querySelector('[data-sf-nf-msg]');
    // Bot traps: a field people never see, and a minimum time between page
    // load and submit. A trapped submit shows the normal success message and
    // saves nothing. The server checks the honeypot again.
    var trap = document.createElement('input');
    trap.type = 'text'; trap.name = 'website'; trap.tabIndex = -1;
    trap.autocomplete = 'off'; trap.setAttribute('aria-hidden', 'true');
    trap.style.cssText = 'position:absolute;left:-10000px;width:1px;height:1px;opacity:0;';
    form.appendChild(trap);
    var loadedAt = Date.now();

    var widget = { el: document.createElement('div'), id: null };
    widget.el.className = 'sf-nf-turnstile';
    form.insertBefore(widget.el, msgEl);
    widgets.push(widget);

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var email = (input.value || '').trim();

      if (!EMAIL_RE.test(email)) {
        setMsg(msgEl, 'Please enter a valid email address.', 'is-error');
        input.focus();
        return;
      }

      if (trap.value || Date.now() - loadedAt < 3000) {
        setMsg(msgEl, "You're on the list!", 'is-success');
        form.reset();
        return;
      }

      var token = window.turnstile && widget.id !== null ? window.turnstile.getResponse(widget.id) : '';
      if (!token) {
        setMsg(msgEl, 'One moment, checking you\'re not a bot. Try again in a few seconds.', 'is-error');
        return;
      }

      button.disabled = true;
      setMsg(msgEl, 'Signing up...', null);

      fetch(SIGNUP_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email, token: token, website: trap.value }),
      })
        .then(function (res) { return res.json(); })
        .then(function (out) {
          if (out.ok) {
            setMsg(msgEl, out.already ? "You're already subscribed." : "You're on the list!", 'is-success');
            form.reset();
          } else {
            setMsg(msgEl, out.error || 'Something went wrong. Please try again.', 'is-error');
          }
        })
        .catch(function () {
          setMsg(msgEl, 'Something went wrong. Please try again.', 'is-error');
        })
        .finally(function () {
          button.disabled = false;
          // Tokens work once; get a fresh one for the next try.
          if (window.turnstile && widget.id !== null) window.turnstile.reset(widget.id);
        });
    });
  });
})();
