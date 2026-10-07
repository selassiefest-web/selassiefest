// Progressively enhances every sitewide footer newsletter form
// (see the SF-CANONICAL-FOOTER block duplicated across pages).
(function () {
  var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  function setMsg(msgEl, text, state) {
    msgEl.textContent = text;
    msgEl.classList.remove('is-success', 'is-error');
    if (state) msgEl.classList.add(state);
  }

  document.querySelectorAll('[data-sf-newsletter-form]').forEach(function (form) {
    var input = form.querySelector('input[type="email"]');
    var button = form.querySelector('button');
    var msgEl = form.querySelector('[data-sf-nf-msg]');
    // Bot traps (10/6/2026, bots were signing up strangers): a field people
    // never see, and a minimum time between page load and submit. A trapped
    // submit shows the normal success message and saves nothing.
    var trap = document.createElement('input');
    trap.type = 'text'; trap.name = 'website'; trap.tabIndex = -1;
    trap.autocomplete = 'off'; trap.setAttribute('aria-hidden', 'true');
    trap.style.cssText = 'position:absolute;left:-10000px;width:1px;height:1px;opacity:0;';
    form.appendChild(trap);
    var loadedAt = Date.now();

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

      button.disabled = true;
      setMsg(msgEl, 'Signing up...', null);

      window.sfSupabase.subscribeNewsletter(email)
        .then(function () {
          setMsg(msgEl, "You're on the list!", 'is-success');
          form.reset();
        })
        .catch(function (err) {
          if (err && err.code === '23505') {
            setMsg(msgEl, "You're already subscribed.", 'is-success');
            form.reset();
          } else {
            setMsg(msgEl, 'Something went wrong. Please try again.', 'is-error');
          }
        })
        .finally(function () {
          button.disabled = false;
        });
    });
  });
})();
