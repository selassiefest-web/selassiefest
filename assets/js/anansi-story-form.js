// Powers the story submission form on /calendar/games/anansi-stories.html.
(function () {
  var form = document.querySelector('[data-sf-anansi-form]');
  if (!form) return;

  var msgEl = form.querySelector('[data-sf-anansi-msg]');
  var button = form.querySelector('.asf-submit');
  var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  function setMsg(text, state) {
    msgEl.textContent = text;
    msgEl.classList.remove('is-success', 'is-error');
    if (state) msgEl.classList.add(state);
  }

  form.addEventListener('submit', function (e) {
    e.preventDefault();

    var name = form.querySelector('#asf-name').value.trim();
    var email = form.querySelector('#asf-email').value.trim();
    var storyTitle = form.querySelector('#asf-title').value.trim();
    var storyText = form.querySelector('#asf-text').value.trim();

    if (!name || !email || !storyTitle || !storyText) {
      setMsg('Please fill in every field.', 'is-error');
      return;
    }
    if (!EMAIL_RE.test(email)) {
      setMsg('Please enter a valid email address.', 'is-error');
      return;
    }

    button.disabled = true;
    setMsg('Submitting your story...', null);

    window.sfSupabase.submitAnansiStory({ name: name, email: email, storyTitle: storyTitle, storyText: storyText })
      .then(function () {
        setMsg('Thank you! Your story has been submitted.', 'is-success');
        form.reset();
      })
      .catch(function () {
        setMsg('Something went wrong. Please try again, or email us instead.', 'is-error');
      })
      .finally(function () {
        button.disabled = false;
      });
  });
})();
