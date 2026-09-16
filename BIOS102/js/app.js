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

  // Exam "master tables" span a range of exercise numbers rather than one
  // chapter -- used for exam review, spanning whatever's actually in
  // data.js within that range (so a manual renumbering, like the real
  // manual's missing Exercise 11, is handled automatically rather than by
  // hardcoding an exercise list here). storageId is an exercise_number
  // sentinel, safely out of range of any real exercise (1-12ish), reused
  // as-is with the existing bios102_student_tables save/load RPCs --
  // no schema change needed for master tables.
  const EXAM_RANGES = [
    { number: 1, label: 'Exam 1 Master Table', range: [1, 6], storageId: 9001 },
    { number: 2, label: 'Exam 2 Master Table', range: [7, 8], storageId: 9002 },
    { number: 3, label: 'Exam 3 Master Table', range: [9, 999], storageId: 9003 },
  ];

  function getExamRanges() {
    return EXAM_RANGES;
  }

  function getExamRange(number) {
    return EXAM_RANGES.find((e) => e.number === Number(number)) || null;
  }

  function getExercisesForExam(number) {
    const exam = getExamRange(number);
    if (!exam) return [];
    return getExercises().filter((e) => e.number >= exam.range[0] && e.number <= exam.range[1]);
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

  // Keys whose values are full hand-written sentences (not a controlled
  // vocabulary), so two organisms almost never phrase them identically
  // even when the underlying trait is basically the same. Measured across
  // every exercise's full organism roster: these two came back "everyone's
  // highlighted" (a tie, i.e. zero signal) 100% of the time, which is pure
  // noise rather than a useful comparison -- so they're excluded from the
  // "highlight what differs" scan in exercise.html, even though they still
  // display normally as columns.
  const NON_COMPARABLE_KEYS = new Set(['distinguishingFeatures', 'reproductiveStructures']);

  function isComparableKey(key) {
    return !NON_COMPARABLE_KEYS.has(key);
  }

  // Facts worth a prominent callout on an exercise's own page, not just a
  // quiet meta line -- currently just the one, confirmed by checking
  // cellType across every organism in data.js: Exercise 1's Oscillatoria
  // and Anabaena are the ONLY 2 prokaryotic organisms studied all semester
  // (all 60 others, Exercises 2-12, are eukaryotic).
  const EXERCISE_CALLOUTS = {
    1: 'Oscillatoria and Anabaena are the <strong>only 2 prokaryotic organisms you study all semester</strong> &mdash; everything from Exercise 2 onward is eukaryotic. This is your one hands-on shot at what "no membrane-bound nucleus" actually looks like before the rest of the course assumes you already have it down.',
  };

  function getExerciseCallout(number) {
    return EXERCISE_CALLOUTS[Number(number)] || null;
  }

  // Optional thematic sub-grouping within one exercise's reference-organism
  // list (see Exercise 2's organismGroups in data.js) -- lets an
  // information-dense exercise present its organisms as a few narrated
  // chunks instead of one flat list, which is what the "why these go
  // together" note is for. Returns null for the (default) ungrouped case so
  // callers can fall back to a flat list; organisms with no matching group
  // (or when organismGroups is absent) are otherwise silently dropped, so
  // this only changes behavior for exercises that opt in.
  function getGroupedOrganisms(exercise) {
    const groups = exercise && exercise.organismGroups;
    if (!groups || !groups.length) return null;
    return groups.map((g) => ({
      ...g,
      organisms: (exercise.organisms || []).filter((o) => o.group === g.id),
    }));
  }

  return {
    getSession, setSession, clearSession, requireSession, mountTopbar,
    escapeHtml, humanizeKey, getExercises, getExercise,
    getExamRanges, getExamRange, getExercisesForExam, isComparableKey, getExerciseCallout,
    collectCharacteristicKeys, formatValue, getGroupedOrganisms,
  };
})();
