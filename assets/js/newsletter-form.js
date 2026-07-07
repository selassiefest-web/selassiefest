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

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var email = (input.value || '').trim();

      if (!EMAIL_RE.test(email)) {
        setMsg(msgEl, 'Please enter a valid email address.', 'is-error');
        input.focus();
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
