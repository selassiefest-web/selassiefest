// Progressively enhances every [data-game-story-form] on the Pickney Time
// games archive pages (calendar/games/*.html). Injects its own styles at
// runtime so the CSS doesn't need to be duplicated across 110 pages.
(function () {
  const MAX_VIDEO_BYTES = 50 * 1024 * 1024;

  function injectStyles() {
    if (document.getElementById('story-form-styles')) return;
    const style = document.createElement('style');
    style.id = 'story-form-styles';
    style.textContent = [
      '.story-form{margin:24px 0;text-align:left;background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.08);border-radius:16px;padding:20px 22px;}',
      '.story-form-row{display:flex;flex-wrap:wrap;gap:10px;margin-bottom:10px;}',
      '.story-form input[type=text],.story-form input[type=email],.story-form textarea{flex:1;min-width:180px;font-family:inherit;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);border-radius:8px;padding:10px 12px;color:#F5F5F5;font-size:.92rem;outline:none;}',
      '.story-form input:focus,.story-form textarea:focus{border-color:rgba(229,169,60,.5);}',
      '.story-form textarea{width:100%;resize:vertical;margin-bottom:10px;}',
      '.story-file-label{display:flex;align-items:center;gap:8px;background:rgba(255,255,255,.05);border:1px dashed rgba(255,255,255,.18);border-radius:8px;padding:9px 14px;font-size:.85rem;color:#ccc;cursor:pointer;transition:.15s;}',
      '.story-file-label:hover{border-color:rgba(229,169,60,.4);color:#E5A93C;}',
      '.story-file-label.has-file{border-style:solid;border-color:rgba(14,94,54,.5);color:#6dbe8f;}',
      '.story-submit-btn{margin-top:6px;width:100%;justify-content:center;}',
      '.story-form-msg{margin:10px 0 0;font-size:.85rem;min-height:1.1em;}',
      '.story-form-msg.is-success{color:#6dbe8f;}',
      '.story-form-msg.is-error{color:#e08585;}',
    ].join('');
    document.head.appendChild(style);
  }

  function setMsg(el, text, state) {
    el.textContent = text;
    el.className = 'story-form-msg' + (state ? ' ' + state : '');
  }

  function wireFileLabel(input) {
    const label = input.closest('.story-file-label');
    const textEl = label.querySelector('.story-file-text');
    const defaultText = textEl.textContent;
    input.addEventListener('change', function () {
      if (input.files && input.files[0]) {
        if (input.type === 'file' && input.name === 'videoFile' && input.files[0].size > MAX_VIDEO_BYTES) {
          textEl.textContent = 'Video too large (50MB max) — pick another';
          label.classList.remove('has-file');
          input.value = '';
          return;
        }
        textEl.textContent = input.files[0].name;
        label.classList.add('has-file');
      } else {
        textEl.textContent = defaultText;
        label.classList.remove('has-file');
      }
    });
  }

  function wireForm(form) {
    const msgEl = form.querySelector('.story-form-msg');
    const submitBtn = form.querySelector('.story-submit-btn');
    const originalBtnHtml = submitBtn.innerHTML;

    form.querySelectorAll('input[type="file"]').forEach(wireFileLabel);

    form.addEventListener('submit', async function (e) {
      e.preventDefault();
      const gameSlug = form.dataset.gameSlug;
      const gameName = form.dataset.gameName;
      const submitterName = form.submitterName.value.trim();
      const submitterEmail = form.submitterEmail.value.trim();
      const storyText = form.storyText.value.trim();
      const photoFile = form.photoFile.files[0] || null;
      const videoFile = form.videoFile.files[0] || null;

      if (!submitterName) {
        setMsg(msgEl, 'Please enter your name.', 'is-error');
        return;
      }
      if (videoFile && videoFile.size > MAX_VIDEO_BYTES) {
        setMsg(msgEl, 'Video is too large (50MB max). Please choose a smaller file.', 'is-error');
        return;
      }

      submitBtn.disabled = true;
      submitBtn.innerHTML = 'Sending…';
      setMsg(msgEl, '', null);

      try {
        await window.sfSupabase.submitGameStory({
          gameSlug, gameName, submitterName,
          submitterEmail, storyText, photoFile, videoFile,
        });
        setMsg(msgEl, "Thank you! Your story is in for review — we'll be in touch if we feature it.", 'is-success');
        form.reset();
        form.querySelectorAll('.story-file-label').forEach(function (label) {
          label.classList.remove('has-file');
          label.querySelector('.story-file-text').textContent = label.dataset.defaultText || label.querySelector('.story-file-text').textContent;
        });
      } catch (err) {
        console.error('Game story submission failed:', err);
        setMsg(msgEl, err && err.message ? err.message : 'Something went wrong. Please try again.', 'is-error');
      } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = originalBtnHtml;
      }
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    const forms = document.querySelectorAll('[data-game-story-form]');
    if (!forms.length) return;
    injectStyles();
    forms.forEach(wireForm);
  });
})();
