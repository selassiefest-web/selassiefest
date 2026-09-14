// BIOS102 shared app logic: session handling + the characteristics table
// builder. Loaded after /assets/js/supabase-client.js and BIOS102/js/data.js.
// No build step (site convention) -- plain script, attached to window.BIOS.
window.BIOS = (() => {
  const SESSION_KEY = 'bios102_session';

  function getSession() {
    try {
      const raw = localStorage.getItem(SESSION_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch (e) {
      return null;
    }
  }

  function setSession(session) {
    localStorage.setItem(SESSION_KEY, JSON.stringify(session));
  }

  function clearSession() {
    localStorage.removeItem(SESSION_KEY);
  }

  // Redirects to login if there's no session; returns it otherwise. Call at
  // the top of any page that requires a logged-in student. A session is
  // { sessionToken, email, displayName } -- sessionToken is what actually
  // gets sent to Supabase (see bios102LoadStudentTables/bios102SaveStudentTable);
  // email/displayName here are only for display, never trusted as identity.
  function requireSession() {
    const session = getSession();
    if (!session || !session.sessionToken) {
      window.location.href = '/BIOS102/index.html';
      return null;
    }
    return session;
  }

  function mountTopbar(session) {
    const el = document.getElementById('topbar');
    if (!el) return;
    el.innerHTML = `
      <div class="brand">
        <a href="/BIOS102/dashboard.html" style="color:inherit;text-decoration:none;">
          BIOS102 <span>Lab Companion</span>
        </a>
        <small>Diversity of Life</small>
      </div>
      <div class="session-info">
        <span>${escapeHtml(session.displayName || session.email)}</span>
        <button id="bios-logout-btn" type="button">Log out</button>
      </div>
    `;
    const btn = document.getElementById('bios-logout-btn');
    if (btn) {
      btn.addEventListener('click', () => {
        clearSession();
        window.location.href = '/BIOS102/index.html';
      });
    }
  }

  function escapeHtml(str) {
    return String(str == null ? '' : str).replace(/[&<>"']/g, (c) => ({
      '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
    }[c]));
  }

  function humanizeKey(key) {
    return key
      .replace(/([A-Z])/g, ' $1')
      .replace(/^./, (c) => c.toUpperCase())
      .trim();
  }

  function getExercises() {
    return (window.BIOS102_DATA && window.BIOS102_DATA.exercises) || [];
  }

  function getExercise(number) {
    return getExercises().find((e) => e.number === Number(number));
  }

  // Every distinct characteristic key present across an exercise's
  // organisms, in first-seen order -- this drives the column picker.
  function collectCharacteristicKeys(exercise) {
    const seen = [];
    const set = new Set();
    (exercise.organisms || []).forEach((org) => {
      Object.keys(org.characteristics || {}).forEach((k) => {
        if (!set.has(k)) {
          set.add(k);
          seen.push(k);
        }
      });
    });
    return seen;
  }

  function formatValue(v) {
    if (v === true) return 'Yes';
    if (v === false) return 'No';
    if (v === undefined || v === null) return '';
    return String(v);
  }

  return {
    getSession, setSession, clearSession, requireSession, mountTopbar,
    escapeHtml, humanizeKey, getExercises, getExercise,
    collectCharacteristicKeys, formatValue,
  };
})();
