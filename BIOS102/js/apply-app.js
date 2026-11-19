// BIOS102 Application Hub. Everything the student types stays in THIS browser (localStorage),
// is never sent to a server, and can be exported and restored as a backup file.
// Portals for these programs do not accept submissions from other sites, so the app does the
// next-best thing: it keeps every common answer ready, builds each program's packet, and gives
// a one-click copy for every field. The student presses Submit themselves in the official portal.
(function () {
  const D = window.AP_DATA;
  const E = window.RM_ENGINE;
  const esc = (s) => BIOS.escapeHtml(s);
  const session = BIOS.requireSession();
  if (!session) return;

  const $ = (sel, root) => (root || document).querySelector(sel);
  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));
  const KEY = 'ap_v1_' + String(session.email || '').toLowerCase();
  const PR = Object.fromEntries(D.PROGRAMS.map((p) => [p.id, p]));
  const MINI = new URLSearchParams(location.search).get('mini');
  const WARN_LIST = 8;

  // ---------------- state ----------------
  function blank() {
    return {
      v: 1,
      profile: { email: session.email || '', country: 'United States', school: 'University of Wisconsin\u2013Parkside' },
      story: { fields: {}, past: '', ex1: '', ex2: '', courses: '', labs: '', work: '', skills: '', honors: '', master: '', showGpa: 'yes', gaps: '' },
      recs: [{ id: 'r1' }, { id: 'r2' }, { id: 'r3' }],
      recStatus: {},
      mine: [],
      programs: {},
      _t: 0,
    };
  }
  let S = blank();
  let view = 'dash';
  let ui = { filter: 'all', sort: 'deadline', open: null, recSel: null, recTone: {} };

  function loadState() {
    try {
      const raw = localStorage.getItem(KEY);
      if (raw) {
        const got = JSON.parse(raw);
        const b = blank();
        S = Object.assign(b, got);
        S.profile = Object.assign(b.profile, got.profile || {});
        S.story = Object.assign(b.story, got.story || {});
        S.story.fields = got.story && got.story.fields ? got.story.fields : {};
        S.recs = got.recs && got.recs.length ? got.recs : b.recs;
        S.mine = (got.mine || []).filter((id) => PR[id]);
      }
    } catch (e) { S = blank(); }
  }
  let saveOk = true;
  function flash(msg, err) {
    const el = $('#saved'); if (!el) return;
    el.textContent = msg; el.className = 'saved show' + (err ? ' err' : '');
    clearTimeout(flash.t);
    if (!err) flash.t = setTimeout(() => { el.className = 'saved'; }, 1200);
  }
  function save() {
    S._t = Date.now();
    try { localStorage.setItem(KEY, JSON.stringify(S)); saveOk = true; flash('Saved on this device'); }
    catch (e) { saveOk = false; flash('Could not save in this browser. Use "Save a backup file" so you do not lose your work.', true); }
  }
  function setPath(obj, path, val) {
    const parts = path.split('.'); let o = obj;
    for (let i = 0; i < parts.length - 1; i++) { if (typeof o[parts[i]] !== 'object' || o[parts[i]] === null) o[parts[i]] = {}; o = o[parts[i]]; }
    o[parts[parts.length - 1]] = val;
  }
  const getPath = (obj, path) => path.split('.').reduce((o, k) => (o == null ? undefined : o[k]), obj);
  function PS(id) {
    if (!S.programs[id]) S.programs[id] = { status: 'planning', done: {}, text: {}, notes: '', submittedAt: '' };
    return S.programs[id];
  }

  // ---------------- profile definition ----------------
  const OPT = {
    classYear: [['first', 'First year'], ['second', 'Second year'], ['third', 'Third year'], ['fourth', 'Fourth year or later']],
    yesno: [['yes', 'Yes'], ['no', 'No']],
    citizenship: [['us', 'U.S. citizen'], ['pr', 'U.S. permanent resident'], ['visa', 'Student or exchange visa holder'], ['other', 'Other / not sure']],
    grad: [['no', 'No, I will still be an undergraduate after summer 2027'], ['yes', 'Yes, I will finish before fall 2027']],
    phd: [['yes', 'Yes, a PhD or MD-PhD is a real goal'], ['maybe', 'Maybe, I am exploring it'], ['no', 'No, I am headed elsewhere (health professions, fieldwork, teaching, industry)'], ['unsure', 'Not sure yet']],
    firstGen: [['yes', 'Yes'], ['no', 'No'], ['skip', 'Prefer not to say']],
  };
  const PF = [
    { g: 'You', f: [
      ['first', 'First name (as on your ID)', 'text', 'given-name'], ['middle', 'Middle name (optional)', 'text', 'additional-name'], ['last', 'Last name', 'text', 'family-name'],
      ['preferred', 'Preferred name (optional)', 'text', 'nickname'], ['email', 'Email (use your UWP Outlook address)', 'email', 'email'], ['altEmail', 'Backup email (optional)', 'email', ''], ['phone', 'Phone', 'tel', 'tel'] ] },
    { g: 'Where you live', f: [
      ['addr1', 'Street address', 'text', 'address-line1'], ['addr2', 'Apartment or unit (optional)', 'text', 'address-line2'], ['city', 'City', 'text', 'address-level2'],
      ['state', 'State', 'text', 'address-level1'], ['zip', 'ZIP code', 'text', 'postal-code'], ['country', 'Country', 'text', 'country-name'] ] },
    { g: 'School', f: [
      ['school', 'College', 'text', 'organization'], ['major', 'Major', 'text', ''], ['minor', 'Minor (optional)', 'text', ''],
      ['classYear', 'Where are you in your degree?', 'select', '', OPT.classYear], ['expectedGrad', 'Expected graduation (for example: May 2028)', 'text', ''],
      ['gpa', 'Overall GPA (from your unofficial transcript)', 'text', ''], ['gpaSci', 'Science GPA (optional)', 'text', ''],
      ['declaredBio', 'Have you declared a Biological Sciences major?', 'select', '', OPT.yesno] ] },
    { g: 'Eligibility answers (programs ask these a lot)', f: [
      ['citizenship', 'Citizenship status', 'select', '', OPT.citizenship], ['gradStatus', 'Will you finish your bachelor\u2019s degree before fall 2027?', 'select', '', OPT.grad],
      ['age18', 'Will you be 18 or older by June 2027?', 'select', '', OPT.yesno], ['phdInterest', 'Is a PhD or MD-PhD a real goal for you?', 'select', '', OPT.phd],
      ['firstGen', 'First in your family to attend college? (optional)', 'select', '', OPT.firstGen], ['hometown', 'Hometown (optional)', 'text', ''] ] },
  ];
  const REQUIRED = ['first', 'last', 'email', 'phone', 'addr1', 'city', 'state', 'zip', 'major', 'classYear', 'expectedGrad', 'gpa', 'citizenship', 'gradStatus', 'age18'];
  const LABEL = {}; PF.forEach((g) => g.f.forEach((f) => { LABEL[f[0]] = f[1]; }));
  const label = (opts, v) => ((opts.find((o) => o[0] === v) || [])[1] || '');
  const prof = () => S.profile || {};
  function profilePct() { const done = REQUIRED.filter((k) => String(prof()[k] || '').trim()).length; return Math.round(done / REQUIRED.length * 100); }
  function missing() { return REQUIRED.filter((k) => !String(prof()[k] || '').trim()); }
  const fullName = () => [prof().first, prof().middle, prof().last].filter((x) => x && x.trim()).join(' ');

  // ---------------- eligibility ----------------
  function eligibility(p) {
    const r = p.req || {}, pf = prof(); const out = []; // {lvl:'ok'|'check'|'no', t}
    const add = (lvl, t) => out.push({ lvl, t });
    if (r.blocked) add('no', r.blocked);
    if (r.cit) {
      const c = pf.citizenship;
      if (!c) add('check', 'Add your citizenship status in My profile.');
      else if (c === 'us' || c === 'pr') add('ok', 'Citizenship: you meet this.');
      else if (r.cit === 'visa-ok' && c === 'visa') add('check', 'Visa holders can apply only with approved OPT or CPT before the appointment. Confirm with the program.');
      else if (r.cit === 'visa-ok') add('check', 'Confirm your status with the program.');
      else if (c === 'visa') add('no', 'This program requires U.S. citizenship or permanent residency.');
      else add('check', 'This program requires U.S. citizenship or permanent residency. Confirm your status with the program.');
    }
    if (r.gpa) {
      const g = parseFloat(pf.gpa);
      if (isNaN(g)) add('check', 'Needs GPA ' + r.gpa.toFixed(1) + ' or higher. Add yours in My profile.');
      else if (g >= r.gpa) add('ok', 'GPA: you meet the ' + r.gpa.toFixed(1) + ' minimum.');
      else add(r.softGpa ? 'check' : 'no', 'Needs GPA ' + r.gpa.toFixed(1) + (r.softGpa ? ' (stated in a secondary listing; confirm)' : '') + '. You entered ' + g.toFixed(2) + '.');
    }
    if (r.notGrad) {
      if (pf.gradStatus === 'yes') add('no', 'You must still be an undergraduate after summer 2027.');
      else if (!pf.gradStatus) add('check', 'Tell us if you finish before fall 2027 (My profile).');
      else add('ok', 'Enrollment: you will still be an undergraduate afterward.');
    }
    if (r.age18) { if (pf.age18 === 'no') add('no', 'You must be 18 by the program start.'); else if (!pf.age18) add('check', 'Answer the age question in My profile.'); }
    if (r.years) {
      if (!pf.classYear) add('check', 'The program targets ' + r.years.map((y) => ({ second: 'sophomores', third: 'juniors' }[y] || y)).join(' and ') + '. Add your year in My profile.');
      else if (r.years.indexOf(pf.classYear) < 0) add('check', 'The program targets sophomores and juniors. Ask whether other years can apply.');
    }
    if (r.phd) {
      if (pf.phdInterest === 'no') add('check', 'This program expects PhD or MD-PhD interest. Apply only if that is true for you.');
      else if (pf.phdInterest === 'unsure' || !pf.phdInterest) add('check', 'This program expects PhD or MD-PhD interest. Only apply if that is a real goal for you.');
      else add('ok', 'Goal: matches the program\u2019s PhD focus.');
    }
    if (r.declaredMajor) { if (pf.declaredBio === 'no') add('no', 'You must be a declared Biological Sciences major.'); else if (!pf.declaredBio) add('check', 'Tell us if you declared the major (My profile).'); else add('ok', 'Major: declared.'); }
    if (!out.length) add('check', 'No hard rules were captured. Read the eligibility line and the official page.');
    const lvl = out.some((x) => x.lvl === 'no') ? 'no' : out.some((x) => x.lvl === 'check') ? 'check' : 'ok';
    return { lvl, items: out };
  }
  const eligChip = (e) => e.lvl === 'ok' ? '<span class="chip g">Looks eligible</span>' : e.lvl === 'no' ? '<span class="chip bad">Probably not eligible</span>' : '<span class="chip w">Check ' + e.items.filter((x) => x.lvl === 'check').length + ' item(s)</span>';

  // ---------------- dates ----------------
  function dl(p) { if (!p.deadline) return null; const [y, m, d] = p.deadline.split('-').map(Number); return new Date(y, m - 1, d, 23, 59, 0); }
  function daysLeft(p) { const d = dl(p); return d ? Math.ceil((d.getTime() - Date.now()) / 86400000) : null; }
  function dlChip(p) {
    const n = daysLeft(p);
    if (n === null) return '<span class="chip">Date not verified</span>';
    const d = dl(p).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    if (n < 0) return `<span class="chip">Closed ${d}</span>`;
    const cls = n <= 14 ? 'bad' : n <= 35 ? 'w' : 'g';
    return `<span class="chip ${cls}">${d} &middot; ${n === 0 ? 'today' : n + ' day' + (n === 1 ? '' : 's')}</span>`;
  }
  const fmtD = (iso) => { const d = new Date(iso); return isNaN(d) ? '' : d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }); };

  // ---------------- checklist and progress ----------------
  function wordCount(t) { const m = String(t || '').trim().match(/\S+/g); return m ? m.length : 0; }
  function recNeeded(p) { return p.recs || 2; }
  function recAsked(id) { return S.recs.filter((r) => r.name && ['asked', 'confirmed', 'received'].indexOf((S.recStatus[r.id] || {})[id]) >= 0).length; }
  function checklist(p) {
    const st = PS(p.id); const items = [];
    items.push({ k: 'official', t: 'Re-read the official page the week you submit (dates and rules change)', man: true });
    items.push({ k: 'elig', t: 'Confirmed you meet every eligibility rule above', man: true });
    if (p.applyKind === 'portal') items.push({ k: 'portal', t: 'Created an account on the application portal', man: true });
    if (/transcript/i.test((p.materials || []).join(' ')) || !p.materials || /check/i.test((p.materials || [''])[0])) items.push({ k: 'transcript', t: 'Downloaded your unofficial transcript (PDF)', man: true });
    items.push({ k: 'cv', t: 'One-page r\u00e9sum\u00e9 ready (make it in My story)', man: true });
    p.prompts.forEach((q) => { const txt = st.text[q.id] || ''; items.push({ k: 'p-' + q.id, t: 'Drafted: ' + (q.label.length > 70 ? q.label.slice(0, 67) + '...' : q.label), auto: wordCount(txt) >= 25 && !/\[[^\]]*\]/.test(txt) }); });
    const need = recNeeded(p); items.push({ k: 'recs', t: 'Asked ' + need + ' recommender' + (need === 1 ? '' : 's') + ' (use the Recommenders tab)', auto: recAsked(p.id) >= need });
    items.push({ k: 'review', t: 'Read everything once, out loud, with no [brackets] left', man: true });
    items.push({ k: 'submitted', t: 'Submitted in the official portal and saved the confirmation', auto: !!st.submittedAt });
    items.forEach((i) => { if (i.man) i.auto = !!st.done[i.k]; });
    return items;
  }
  function progress(p) { const c = checklist(p); return { done: c.filter((i) => i.auto).length, total: c.length, next: c.find((i) => !i.auto) }; }
  const STATUS = [['planning', 'On my list'], ['working', 'Working on it'], ['ready', 'Ready to submit'], ['submitted', 'Submitted'], ['offer', 'Offer received'], ['closed', 'Declined or closed']];

  // ---------------- text helpers ----------------
  function applicantFields() {
    const pf = prof(); const rows = [];
    const add = (l, v) => rows.push([l, String(v == null ? '' : v).trim()]);
    add('Full name', fullName()); add('First name', pf.first); add('Middle name', pf.middle); add('Last name', pf.last); add('Preferred name', pf.preferred);
    add('Email', pf.email); add('Backup email', pf.altEmail); add('Phone', pf.phone);
    add('Street address', pf.addr1); add('Apartment or unit', pf.addr2); add('City', pf.city); add('State', pf.state); add('ZIP code', pf.zip); add('Country', pf.country);
    add('College', pf.school); add('Major', pf.major); add('Minor', pf.minor); add('Class year', label(OPT.classYear, pf.classYear)); add('Expected graduation', pf.expectedGrad);
    add('Overall GPA', pf.gpa); add('Science GPA', pf.gpaSci);
    add('Citizenship', label(OPT.citizenship, pf.citizenship)); add('Finishing before fall 2027?', pf.gradStatus ? (pf.gradStatus === 'yes' ? 'Yes' : 'No') : '');
    add('Hometown', pf.hometown);
    return rows;
  }
  function masterText() {
    const f = S.story.fields || {};
    const bits = (x, d) => (String(x || '').trim() ? String(x).trim().replace(/[.\s]+$/, '') : d);
    if (!f.noticed && !f.observation && !f.question) return '';
    return `In ${bits(f.noticed, '[a course, lab, job or volunteer experience]')}, I noticed ${bits(f.observation, '[what you noticed]')}. It made me curious about ${bits(f.question, '[your question]')}. I explored that question by ${bits(f.didwhat, '[what you actually did]')}, and I learned ${bits(f.learned, '[what you learned or where you got stuck]')}. At [PROGRAM], I am interested in [one or two real project areas] because [your specific connection]. I would bring ${bits(f.skill, '[a habit or skill you really have]')} and hope to develop ${bits(f.develop, '[a research skill]')}. This summer would help me decide ${bits(f.decide, '[a real question]')}.`;
  }
  function copy(text, msg) {
    const done = () => flash(msg || 'Copied');
    const fb = () => { const t = document.createElement('textarea'); t.value = text; document.body.appendChild(t); t.select(); try { document.execCommand('copy'); done(); } catch (e) { flash('Could not copy. Select the text and copy it by hand.', true); } document.body.removeChild(t); };
    if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).then(done, fb); else fb();
  }

  // ---------------- navigation ----------------
  const TABS = [['dash', 'Dashboard'], ['profile', 'My profile'], ['story', 'My story'], ['recs', 'Recommenders'], ['programs', 'Programs'], ['mine', 'My applications'], ['plan', 'Plan and deadlines']];
  function go(v, extra) { view = v; if (extra !== undefined) ui.open = extra; render(); window.scrollTo(0, 0); }
  function renderTabs() {
    $('#steps').innerHTML = TABS.map(([id, l]) => `<li><button type="button" data-act="go" data-v="${id}" ${view === id || (view === 'packet' && id === 'mine') ? 'aria-current="step"' : ''}>${esc(l)}${id === 'mine' && S.mine.length ? ` <span class="chip" style="margin:0 0 0 4px">${S.mine.length}</span>` : ''}</button></li>`).join('');
  }
  function render() {
    stopDictation();
    if (MINI) { $('#view').innerHTML = vMini(); return; }
    renderTabs();
    const fn = { dash: vDash, profile: vProfile, story: vStory, recs: vRecs, programs: vPrograms, mine: vMine, plan: vPlan, packet: vPacket }[view] || vDash;
    $('#view').innerHTML = fn();
    addMics();
    if (view === 'profile') refreshProfileMeter();
  }

  // ---------------- views ----------------
  const BROWSERS = [
    ['Microsoft Edge', 'Settings \u2192 Profiles \u2192 Personal info \u2192 Add info. Turn on "Save and fill basic info". Enter your name, phone, email and address.'],
    ['Google Chrome', 'Settings \u2192 Autofill and passwords \u2192 Addresses and more. Turn on "Save and fill addresses", then choose Add and fill in your details.'],
    ['Safari on a Mac', 'Safari \u2192 Settings \u2192 AutoFill \u2192 "Using info from my contacts" \u2192 Edit. Fill in "My Card" in the Contacts app, and Safari uses it.'],
    ['Safari on an iPhone', 'Settings \u2192 Apps \u2192 Safari \u2192 AutoFill \u2192 My Info, and choose your contact card.'],
    ['Firefox', 'Settings \u2192 Autofill (or Privacy & Security \u2192 Forms and Autofill) \u2192 Saved addresses \u2192 Add.'],
  ];
  function autofillCard() {
    return `<div class="rm-card tint"><h3 class="rm-h3">Type your name and address once, ever (set up browser autofill)</h3>
      <p>Most application forms ask for the same things: name, email, phone, address. Let your browser remember them so it fills them in for you on every portal. Do this once in the browser you use for applications:</p>
      ${BROWSERS.map((b) => `<details style="margin:4px 0"><summary><strong>${esc(b[0])}</strong></summary><p style="margin:6px 0 6px 18px">${esc(b[1])}</p></details>`).join('')}
      <p class="hint">Menu names change between versions. If you do not see them, type &ldquo;autofill&rdquo; in the browser&rsquo;s settings search box.</p>
      <ul style="margin:8px 0 0 18px;padding:0"><li>Use your UWP email so every program reaches you in Outlook.</li><li><strong>Never</strong> save a Social Security number, and skip date of birth. Type those in the portal by hand if a form asks.</li><li>Do this only on your own device. On a library or lab computer, skip autofill and use the copy buttons, then close the browser.</li><li>Autofill is for names and addresses. For essays, use the copy buttons in each program&rsquo;s packet.</li></ul></div>`;
  }
  function vDash() {
    const first = esc(prof().first || (session.displayName || '').split(' ')[0] || 'there');
    const pct = profilePct();
    const storyDone = wordCount(S.story.master || masterText()) >= 60;
    const recDone = S.recs.filter((r) => r.name && r.email).length;
    const mine = S.mine.map((id) => PR[id]).sort(byDeadline);
    const step = (n, t, d, ok, go2, btn) => `<div class="rm-card" style="margin:0"><div class="rm-row"><span class="rank">${n}</span><h3 class="rm-h3" style="margin:0">${t}</h3>${ok ? '<span class="chip g">done</span>' : ''}</div><p class="rm-muted" style="margin:8px 0 12px">${d}</p><button class="${ok ? 'btn-s' : 'btn-p'} btn-sm" data-act="go" data-v="${go2}">${btn}</button></div>`;
    const upcoming = mine.filter((p) => { const n = daysLeft(p); return n === null || n >= 0; }).slice(0, 4);
    return `
      <div class="rm-hero"><h1 class="rm-h1">Hi ${first}. Let&rsquo;s get your summer research applications ready.</h1>
      <p class="rm-lede">Fill in your information once. This hub keeps it ready, builds a packet for every program, and puts a copy button next to every answer. You press Submit yourself in each program&rsquo;s official portal.</p></div>
      <div class="rm-card warn"><strong>Your information stays on this computer.</strong> Everything you type here is saved only in this browser. It is never sent to a server, and your instructor cannot see it. Use &ldquo;Save a backup file&rdquo; at the bottom to move it to another device. Check your UWP Outlook every day; programs write to that address.</div>
      <div class="rm-grid">
        ${step(1, 'Fill in your profile', 'Name, contact, school, GPA, and the eligibility answers programs ask for. ' + pct + '% complete.', pct === 100, 'profile', pct === 100 ? 'Review' : 'Open my profile')}
        ${step(2, 'Write your story', 'Your master statement, your experience, and a one-page r\u00e9sum\u00e9. Honest, specific, yours.', storyDone, 'story', storyDone ? 'Review' : 'Start')}
        ${step(3, 'Line up recommenders', 'Two people who know your work. Ask early; the page drafts the email.', recDone >= 2, 'recs', recDone >= 2 ? 'Review' : 'Add them')}
        ${step(4, 'Pick programs', 'See which ones you look eligible for, by deadline. Five or six strong ones beat twelve rushed ones.', S.mine.length > 0, 'programs', S.mine.length ? 'Browse more' : 'Browse programs')}
      </div>
      ${autofillCard()}
      <h2 class="rm-h2">Coming up</h2>
      ${upcoming.length ? upcoming.map((p) => { const g = progress(p); return `<div class="rm-card ${daysLeft(p) !== null && daysLeft(p) <= 14 ? 'warn' : ''}"><div class="rm-spread"><div><strong>${esc(p.name)}</strong><div class="rm-row">${dlChip(p)}${eligChip(eligibility(p))}</div><div class="rm-muted" style="margin-top:4px">${g.done} of ${g.total} steps done${g.next ? '. Next: ' + esc(g.next.t) : ''}</div></div><button class="btn-p btn-sm" data-act="packet" data-id="${p.id}">Open packet</button></div></div>`; }).join('')
        : `<div class="rm-card green"><p style="margin:0 0 10px">You have not picked any programs yet. A good start is the beginner-friendly ones you look eligible for.</p><div class="rm-row"><button class="btn-p" data-act="addBeginner">Add up to 5 that fit me</button><button class="btn-s" data-act="go" data-v="programs">Browse them all</button></div><p class="hint">Fill in your profile first so the fit check is accurate.</p></div>`}
      <h2 class="rm-h2">Your data</h2>
      <div class="rm-card"><div class="rm-row"><button class="btn-s btn-sm" data-act="backup">Save a backup file</button><label class="btn-s btn-sm" style="cursor:pointer">Restore from a backup<input type="file" id="restore" accept="application/json" hidden></label><button class="btn-t" data-act="wipe">Erase everything on this device</button></div>
      <p class="hint">${saveOk ? 'Saved in this browser.' : 'This browser blocked saving. Use a backup file.'} A backup file contains your personal details, so keep it private.</p></div>`;
  }

  function field(f, prefix) {
    const [id, lab, type, ac, opts] = f; const v = String(getPath(S, prefix + '.' + id) || '');
    const base = `id="f-${id}" data-bind="${prefix}.${id}" ${ac ? `autocomplete="${ac}" name="${ac}"` : `name="${id}"`}`;
    if (type === 'select') return `<div><label class="f" for="f-${id}">${esc(lab)}</label><select ${base}><option value="">Choose</option>${opts.map(([val, l]) => `<option value="${val}" ${v === val ? 'selected' : ''}>${esc(l)}</option>`).join('')}</select></div>`;
    return `<div><label class="f" for="f-${id}">${esc(lab)}</label><input type="${type}" ${base} value="${esc(v)}" ${type === 'text' || type === 'email' || type === 'tel' ? 'maxlength="200"' : ''}></div>`;
  }
  function vProfile() {
    return `<h1 class="rm-h1">My profile</h1>
      <p class="rm-lede">Type these once. Every program packet fills itself from this page. Your browser can also remember what you type here for other websites; accept its offer to save this information when it asks.</p>
      <div class="rm-card ${profilePct() === 100 ? 'green' : 'tint'}" id="meter"></div>
      ${PF.map((g) => `<div class="rm-card"><h3 class="rm-h3">${esc(g.g)}</h3><div class="rm-grid" style="grid-template-columns:repeat(auto-fill,minmax(240px,1fr))">${g.f.map((f) => field(f, 'profile')).join('')}</div></div>`).join('')}
      <div class="rm-card warn"><strong>Not stored here:</strong> Social Security number and date of birth. If a portal asks, type them in the portal yourself.</div>`;
  }
  function refreshProfileMeter() {
    const el = $('#meter'); if (!el) return;
    const m = missing(); const pct = profilePct();
    el.innerHTML = `<strong>${pct}% complete.</strong> ${m.length ? 'Still needed: ' + m.map((k) => esc(LABEL[k].replace(/ \(.*\)/, '').replace(/\?$/, ''))).join(', ') + '.' : 'Everything programs usually ask for is filled in.'}<div class="bar" style="margin-top:8px"><i style="width:${pct}%"></i></div>`;
  }

  function masterBox() {
    const mt = masterText();
    return '<h3 class="rm-h3">Your master statement (assembled from your answers)</h3>' + (mt
      ? '<div class="preview" id="master-prev">' + esc(mt) + '</div><p class="hint">The [brackets] are the parts each program needs you to tailor. You fill those in inside each program’s packet.</p><div class="rm-row"><button class="btn-s btn-sm" data-act="copyMaster">Copy it</button></div>'
      : '<p class="rm-muted" style="margin:0">Answer the first three questions above and it appears here.</p>');
  }
  function vStory() {
    const f = S.story.fields; const mt = masterText();
    const ta = (path, lab, hint, rows) => `<label class="f" for="s-${path}">${lab}</label><textarea id="s-${path}" data-bind="story.${path}" style="min-height:${rows || 84}px" placeholder="${esc(hint || '')}">${esc(getPath(S, 'story.' + path) || '')}</textarea>`;
    return `<h1 class="rm-h1">My story</h1>
      <p class="rm-lede">Programs read what you actually did and how you think. Describe only experience you really have. A careful observation, a revised idea, or a clear record of something unexpected shows how you handle evidence. You can speak any answer instead of typing it.</p>
      <div class="rm-card tint"><strong>New to research? That is fine.</strong> Several of these programs are built for students with little or no lab experience. Describe something the reader can picture, like a lab you did in BIOS102.</div>
      <h2 class="rm-h2">1. Build your master statement</h2>
      <div class="rm-card">${D.STATEMENT_FIELDS.map((q) => ta('fields.' + q.id, esc(q.label), q.hint, 70)).join('')}</div>
      <div class="rm-card green" id="master-box">${masterBox()}</div>
      <h2 class="rm-h2">2. Your background in plain facts</h2>
      <div class="rm-card">
        ${ta('courses', 'Science and math courses you have taken (and are taking)', 'One per line, for example: BIOS 102 Organismal Biology, CHEM 101')}
        ${ta('labs', 'Lab, fieldwork or research experience (class labs count)', 'For example: BIOS102 lab: dissections, microscope work, Pilobolus experiment. Be specific about what YOU did.')}
        ${ta('work', 'Jobs and volunteering', 'One per line: Role, place, dates, what you did or learned')}
        ${ta('skills', 'Skills', 'For example: microscopy, sterile technique, Excel, Python, Spanish, careful note-taking')}
        ${ta('honors', 'Honors, activities and leadership', 'One per line')}
      </div>
      <h2 class="rm-h2">3. Two short examples (many programs ask for these)</h2>
      <div class="rm-card">
        ${ta('ex1', 'An example of how you handled feedback', 'What was the feedback, and what did you change?')}
        ${ta('ex2', 'An example of persisting through something hard, or recording observations carefully', 'What happened, and what did you do?')}
        ${ta('past', 'Past research experience, informal or formal (used when a form asks)', 'It is okay to say you have none yet, and then describe what you have done that is closest, such as course labs. Never invent research.', 110)}
        ${ta('gaps', 'Anything an application reader should understand about your path (optional)', 'Obstacles, work or family duties, a hard semester. Many programs ask how your background shaped your interest.')}
      </div>
      <h2 class="rm-h2">4. One-page r\u00e9sum\u00e9</h2>
      <div class="rm-card"><p>Built from your profile and the facts above. Check it, then print or save it as a PDF.</p>
        <label class="opt" style="max-width:340px"><input type="checkbox" data-bind="story.showGpa" ${S.story.showGpa === 'yes' ? 'checked' : ''} data-check="story.showGpa"> Show my GPA on the r\u00e9sum\u00e9</label>
        <div class="rm-row" style="margin-top:8px"><button class="btn-p" data-act="printResume">Print or save r\u00e9sum\u00e9 as PDF</button></div>
        <p class="hint">In the print window, choose &ldquo;Save as PDF&rdquo; as the destination.</p></div>`;
  }
  function lines(t) { return String(t || '').split('\n').map((x) => x.trim()).filter(Boolean); }
  function printResume() {
    const pf = prof(); const s = S.story;
    const contact = [pf.email, pf.phone, [pf.city, pf.state].filter(Boolean).join(', ')].filter(Boolean).join(' | ');
    const sec = (title, arr) => arr.length ? `<h2>${esc(title)}</h2><ul>${arr.map((x) => `<li>${esc(x)}</li>`).join('')}</ul>` : '';
    $('#printSheet').innerHTML = `<h1 style="font-size:20pt">${esc(fullName() || 'Your name')}</h1><p style="margin:0 0 6pt">${esc(contact)}</p>
      <h2>Education</h2><p style="margin:0">${esc(pf.school || 'University of Wisconsin\u2013Parkside')}, ${esc(pf.major || '[major]')}${pf.minor ? ' (minor: ' + esc(pf.minor) + ')' : ''}<br>Expected graduation: ${esc(pf.expectedGrad || '[date]')}${s.showGpa === 'yes' && pf.gpa ? '<br>GPA: ' + esc(pf.gpa) : ''}</p>
      ${sec('Relevant coursework', lines(s.courses))}${sec('Lab, field and research experience', lines(s.labs))}${sec('Work and volunteer experience', lines(s.work))}${sec('Skills', lines(s.skills))}${sec('Honors and activities', lines(s.honors))}`;
    window.print();
  }

  // Recommenders
  function vRecs() {
    const mine = S.mine.map((id) => PR[id]).sort(byDeadline);
    const sel = ui.recSel || (S.recs.find((r) => r.name) || S.recs[0]).id;
    const r = S.recs.find((x) => x.id === sel) || S.recs[0];
    const forms = S.recs.map((x, i) => `<div class="rm-card"><h3 class="rm-h3">Recommender ${i + 1}</h3><div class="rm-grid" style="grid-template-columns:repeat(auto-fill,minmax(230px,1fr))">
      ${[['name', 'Full name'], ['title', 'Title (for example: Professor of Biology)'], ['org', 'Department or workplace'], ['email', 'Email'], ['phone', 'Phone (optional)'], ['knows', 'How they know you (course and semester)']].map(([k, l]) => `<div><label class="f" for="rc-${x.id}-${k}">${esc(l)}</label><input type="text" id="rc-${x.id}-${k}" data-bind="recs.${i}.${k}" value="${esc(x[k] || '')}"></div>`).join('')}</div></div>`).join('');
    const matrix = mine.length ? `<div class="tablewrap"><table class="rm"><thead><tr><th>Program</th><th>Deadline</th><th>Letters</th>${S.recs.filter((x) => x.name).map((x) => `<th>${esc(x.name.split(' ').slice(-1)[0])}</th>`).join('')}</tr></thead><tbody>${mine.map((p) => `<tr><td>${esc(p.name)}</td><td>${dlChip(p)}</td><td>${esc(p.recs ? p.recs + ' needed' : 'Check form')}${p.recsNote ? `<div class="rm-muted">${esc(p.recsNote)}</div>` : ''}</td>${S.recs.filter((x) => x.name).map((x) => `<td><select data-bind="recStatus.${x.id}.${p.id}"><option value="">Not asked</option>${[['asked', 'Asked'], ['confirmed', 'Said yes'], ['received', 'Letter sent']].map(([v, l]) => `<option value="${v}" ${(S.recStatus[x.id] || {})[p.id] === v ? 'selected' : ''}>${l}</option>`).join('')}</select></td>`).join('')}</tr>`).join('')}</tbody></table></div>` : '<p class="rm-muted">Add programs to My applications and they show up here.</p>';
    const choices = mine.filter((p) => p.recs !== 0);
    const earliest = choices.map(dl).filter(Boolean).sort((a, b) => a - b)[0];
    const askBy = earliest ? new Date(earliest.getTime() - 28 * 86400000) : null;
    const line = (ui.recTone[r.id] || '').trim();
    const ready = r.name && r.email && line.length >= 25 && !/\[[^\]]*\]/.test(line);
    const draft = recDraft(r, choices, line);
    return `<h1 class="rm-h1">Recommenders</h1>
      <p class="rm-lede">Ask two people who have seen how you work, ideally faculty. Ask at least four weeks before the first deadline, and give them what they need to write something specific.</p>
      ${askBy ? `<div class="rm-card ${askBy < new Date() ? 'warn' : 'tint'}"><strong>${askBy < new Date() ? 'Ask now.' : 'Ask by ' + askBy.toLocaleDateString('en-US', { month: 'long', day: 'numeric' }) + '.'}</strong> Your earliest deadline is ${esc(fmtD(earliest))} (${esc(choices.filter((p) => dl(p) && dl(p).getTime() === earliest.getTime())[0].name)}). Four weeks of notice is a kind amount to give a professor.</div>` : ''}
      ${forms}
      <h2 class="rm-h2">Who has been asked for what</h2>${matrix}
      <h2 class="rm-h2">Draft the request</h2>
      <div class="rm-card"><label class="f" for="rsel" style="margin-top:0">Write to</label><select id="rsel" data-recsel="1">${S.recs.filter((x) => x.name).map((x) => `<option value="${x.id}" ${x.id === sel ? 'selected' : ''}>${esc(x.name)}</option>`).join('') || '<option value="">Add a recommender above first</option>'}</select>
        <label class="f" for="rline">One personal sentence (required): why you are asking this person</label>
        <textarea id="rline" data-recline="${esc(r.id)}" placeholder="For example: I really valued the way you explained experimental design in BIOS 303, and you saw how I worked through my lab write-ups.">${esc(ui.recTone[r.id] || '')}</textarea>
        <p class="hint">Mention a specific class or moment. No [brackets] left in it.</p>
        <label class="f">Preview</label><div class="preview" id="rprev">${esc(draft.body)}</div>
        <div class="rm-row"><button class="btn-p" data-act="recOutlook" ${ready ? '' : 'disabled'} data-rneeds="1">Open in Outlook (web)</button><button class="btn-s" data-act="recMail" ${ready ? '' : 'disabled'} data-rneeds="1">Open in my mail app</button><button class="btn-s" data-act="recCopy" ${ready ? '' : 'disabled'} data-rneeds="1">Copy it</button></div>
        <p class="hint">Attach your r\u00e9sum\u00e9, your unofficial transcript and your master statement before you send. You send this yourself from your UWP Outlook.</p></div>`;
  }
  function recDraft(r, progs, line) {
    const list = progs.map((p) => `- ${p.name}: due ${dl(p) ? dl(p).toLocaleDateString('en-US', { month: 'long', day: 'numeric' }) : '(date to be confirmed)'}. ${recHow(p)}`).join('\n');
    const nm = r.name ? r.name.trim() : '[Professor name]';
    const body = `Dear ${nm},

I am applying to summer research programs for 2027 and I would be honored if you would write a letter of recommendation for me.

${line || '[YOUR OWN SENTENCE: why you are asking this person]'}

These are the programs I am applying to, with their deadlines:
${list || '- (I will send you the list shortly)'}

I will attach my r\u00e9sum\u00e9, unofficial transcript and a draft of my statement so you have what you need. If you can write the letter, the programs send you a link or ask you to email it, and I will tell you exactly which way for each one. If you are not able to write for me this time, I completely understand.

Thank you for considering it.

${fullName() || '[Your name]'}
${prof().email || ''}`;
    return { to: r.email || '', subject: 'Request for a letter of recommendation: summer research programs', body };
  }
  function recHow(p) {
    if (p.id === 'uicsurf') return 'Your letter is emailed to surf@uic.edu on letterhead with a signature.';
    if (p.id === 'suip') return 'You will get an automatic email from the portal.';
    if (p.id === 'lyric') return 'You will get an automatic email from the portal when I submit.';
    return 'The portal or I will send you the instructions.';
  }

  // Programs browse
  function byDeadline(a, b) { const x = dl(a), y = dl(b); if (x && y) return x - y; if (x) return -1; if (y) return 1; return (a.rank || 99) - (b.rank || 99); }
  function vPrograms() {
    const f = ui.filter;
    let list = D.PROGRAMS.slice();
    const open = (p) => { const n = daysLeft(p); return n === null || n >= 0; };
    if (f === 'beginner') list = list.filter((p) => p.lists.indexOf('beginner') >= 0);
    else if (f === 'housing') list = list.filter((p) => p.lists.indexOf('housing') >= 0);
    else if (f === 'regional') list = list.filter((p) => p.lists.indexOf('regional') >= 0);
    else if (f === 'national') list = list.filter((p) => p.lists.indexOf('national') >= 0);
    else if (f === 'fit') list = list.filter((p) => eligibility(p).lvl !== 'no' && open(p));
    else if (f === 'open') list = list.filter(open);
    list.sort(ui.sort === 'rank' ? (a, b) => (a.rank || 99) - (b.rank || 99) : byDeadline);
    const FIL = [['all', 'All ' + D.PROGRAMS.length], ['beginner', 'Beginner-friendly'], ['housing', 'Housing help'], ['regional', 'Wisconsin and Illinois'], ['national', 'National'], ['open', 'Still open'], ['fit', 'I look eligible']];
    const card = (p) => {
      const on = S.mine.indexOf(p.id) >= 0; const e = eligibility(p);
      return `<div class="fac a-${p.region === 'National' ? 'mol' : p.region === 'WI' ? 'eco' : 'evo'}"><div class="rm-row">${dlChip(p)}${eligChip(e)}</div><h3>${esc(p.name)}</h3><div class="t">${esc(p.org)} &middot; ${esc(p.city)}</div><p class="one">${esc(p.focus)}</p>
        <div><span class="chip">${esc(p.pay.length > 60 ? p.pay.slice(0, 57) + '...' : p.pay)}</span>${p.beginner ? '<span class="chip g">Beginner-friendly</span>' : ''}<span class="chip ${p.checked === 'page' ? 'b' : ''}">${p.checked === 'page' ? 'Official page re-read ' + esc(D.CHECKED.replace(', 2026', '')) : 'From directory: confirm on official page'}</span></div>
        <div class="rm-row"><button class="btn-${on ? 's' : 'p'} btn-sm" data-act="toggleMine" data-id="${p.id}">${on ? 'On my list \u2713' : 'Add to my list'}</button><button class="btn-s btn-sm" data-act="packet" data-id="${p.id}">Open details</button></div></div>`;
    };
    return `<h1 class="rm-h1">Programs</h1>
      <p class="rm-lede">Summer 2027 research programs, from the UW&ndash;Parkside directory (checked ${esc(D.CHECKED)}). Dates change, so every program page tells you to re-check the official site the week you apply.</p>
      <div class="rm-card tint"><strong>How to choose.</strong> Pick five or six. Mix a few reaches with a few where the program says beginners are welcome. Check the eligibility tag, then the deadline. Programs with early January deadlines need you to start this week.</div>
      <div class="rm-row" style="margin-bottom:10px">${FIL.map(([v, l]) => `<button type="button" class="chip ${f === v ? 'on' : ''}" data-act="filter" data-v="${v}">${esc(l)}</button>`).join('')}</div>
      <div class="rm-row" style="margin-bottom:12px"><span class="rm-muted">Sort:</span><button type="button" class="chip ${ui.sort === 'deadline' ? 'on' : ''}" data-act="sort" data-v="deadline">By deadline</button><button type="button" class="chip ${ui.sort === 'rank' ? 'on' : ''}" data-act="sort" data-v="rank">By directory rank</button></div>
      ${S.mine.length > WARN_LIST ? `<div class="rm-card warn">You have ${S.mine.length} programs on your list. Five or six strong applications beat a dozen rushed ones. Consider removing a few.</div>` : ''}
      <div class="rm-grid">${list.map(card).join('') || '<p class="rm-muted">Nothing matches that filter.</p>'}</div>
      <h2 class="rm-h2">Programs that are not open to most Parkside students</h2>
      <div class="rm-card"><ul style="margin:0 0 0 18px;padding:0">${D.NOT_FOR_YOU.map((x) => `<li style="margin-bottom:4px">${esc(x)}</li>`).join('')}</ul></div>`;
  }

  // My applications
  function vMine() {
    const mine = S.mine.map((id) => PR[id]).sort(byDeadline);
    if (!mine.length) return `<h1 class="rm-h1">My applications</h1><div class="rm-card warn"><p style="margin:0 0 12px">You have not added any programs yet.</p><button class="btn-p" data-act="go" data-v="programs">Browse programs</button></div>`;
    return `<h1 class="rm-h1">My applications</h1>
      <p class="rm-lede">In deadline order. Open a packet to see exactly what to do next and copy every answer.</p>
      ${S.mine.length > WARN_LIST ? `<div class="rm-card warn">You have ${S.mine.length} programs. Five or six strong ones beat a dozen rushed ones.</div>` : ''}
      ${mine.map((p) => { const g = progress(p); const st = PS(p.id); const pct = Math.round(g.done / g.total * 100); const e = eligibility(p);
        return `<div class="rm-card s-${st.status === 'submitted' || st.status === 'offer' ? 'done' : st.status === 'working' ? 'scheduled' : st.status === 'closed' ? 'declined' : 'none'}"><div class="rm-spread"><div><h3 class="rm-h3" style="font-size:19px;color:var(--green)">${esc(p.name)}</h3><div class="rm-row">${dlChip(p)}${eligChip(e)}</div></div>
        <div class="rm-row"><select data-bind="programs.${p.id}.status" data-rerender="1" aria-label="Status of ${esc(p.name)}">${STATUS.map(([v, l]) => `<option value="${v}" ${st.status === v ? 'selected' : ''}>${l}</option>`).join('')}</select></div></div>
        <div class="bar" style="margin:10px 0 4px"><i style="width:${pct}%"></i></div><div class="rm-muted">${g.done} of ${g.total} steps done${g.next ? '. <strong>Next:</strong> ' + esc(g.next.t) : '. All steps are done.'}</div>
        <div class="rm-row" style="margin-top:10px"><button class="btn-p btn-sm" data-act="packet" data-id="${p.id}">Open packet</button><button class="btn-t" data-act="toggleMine" data-id="${p.id}">Remove from my list</button></div></div>`; }).join('')}`;
  }

  // Packet
  function vPacket() {
    const p = PR[ui.open]; if (!p) return vMine();
    const st = PS(p.id); const e = eligibility(p); const g = progress(p); const on = S.mine.indexOf(p.id) >= 0;
    const verif = p.checked === 'page' ? `<span class="chip b">Official page re-read on ${esc(D.CHECKED)}</span>` : '<span class="chip w">From the directory. Not re-read on the official page: confirm every detail there.</span>';
    const portal = p.links.applyKind === 'portal';
    const prompts = p.prompts.map((q) => {
      const txt = st.text[q.id] || ''; const wc = wordCount(txt); const lim = q.limit || {}; const over = (lim.words && wc > lim.words) || (lim.chars && txt.length > lim.chars);
      const br = /\[[^\]]*\]/.test(txt);
      return `<div class="rm-card"><label class="f" for="t-${q.id}" style="margin-top:0">${esc(q.label)}</label>${q.hint ? `<p class="hint">${esc(q.hint)}</p>` : ''}
        <textarea id="t-${q.id}" data-bind="programs.${p.id}.text.${q.id}" data-count="${q.id}" style="min-height:150px">${esc(txt)}</textarea>
        <div class="rm-row" style="margin-top:6px"><span class="rm-muted" id="cnt-${q.id}" ${over ? 'style="color:var(--bad);font-weight:700"' : ''}>${wc} words, ${txt.length} characters${lim.words ? ' (limit ' + lim.words + ' words)' : ''}${lim.chars ? ' (limit ' + lim.chars.toLocaleString() + ' characters)' : ''}${lim.note ? ' (' + esc(lim.note) + ')' : ''}</span><span class="need" id="br-${q.id}" ${br ? '' : 'hidden'}>Replace the [brackets] before you submit.</span></div>
        <div class="rm-row" style="margin-top:6px"><button class="btn-s btn-sm" data-act="seed" data-id="${p.id}" data-q="${q.id}">Start from my master statement</button><button class="btn-s btn-sm" data-act="copyText" data-id="${p.id}" data-q="${q.id}">Copy this answer</button></div></div>`;
    }).join('');
    const check = checklist(p).map((i) => `<label class="q-item"><input type="checkbox" ${i.auto ? 'checked' : ''} ${i.man ? `data-act="toggleCheck" data-id="${p.id}" data-k="${i.k}"` : 'disabled'}> <span>${esc(i.t)}${!i.man ? ' <span class="rm-muted">(updates by itself)</span>' : ''}</span></label>`).join('');
    const recs = S.recs.filter((r) => r.name).map((r) => `<li>${esc(r.name)}: <strong>${esc(label([['', 'Not asked'], ['asked', 'Asked'], ['confirmed', 'Said yes'], ['received', 'Letter sent']], (S.recStatus[r.id] || {})[p.id] || ''))}</strong></li>`).join('');
    const pm = missing();
    return `<button class="btn-t" data-act="go" data-v="mine">&larr; My applications</button>
      <h1 class="rm-h1" style="margin-top:6px">${esc(p.name)}</h1>
      <div class="rm-row">${dlChip(p)}${eligChip(e)}${verif}</div>
      <p class="rm-lede" style="margin-top:8px">${esc(p.focus)}</p>
      <div class="rm-row" style="margin-bottom:14px">${!on ? `<button class="btn-p" data-act="toggleMine" data-id="${p.id}">Add to my list</button>` : `<select data-bind="programs.${p.id}.status" data-rerender="1" aria-label="Status">${STATUS.map(([v, l]) => `<option value="${v}" ${st.status === v ? 'selected' : ''}>${l}</option>`).join('')}</select>`}
        ${p.links.apply ? `<a class="btn-p" href="${esc(p.links.apply)}" target="_blank" rel="noopener">${portal ? 'Open the application portal' : 'Open the official instructions (start here)'}</a>` : '<span class="chip w">No application link verified yet</span>'}
        <a class="btn-s" href="${esc(p.links.page)}" target="_blank" rel="noopener">Official program page</a>
        <button class="btn-s" data-act="mini" data-id="${p.id}">Open the copy helper in its own window</button></div>
      <div class="rm-card ${e.lvl === 'no' ? 'warn' : e.lvl === 'ok' ? 'green' : 'tint'}"><h3 class="rm-h3">Do you qualify?</h3><ul style="margin:0 0 6px 18px;padding:0">${e.items.map((x) => `<li>${x.lvl === 'ok' ? '&#10003;' : x.lvl === 'no' ? '&#10007;' : '&#9888;'} ${esc(x.t)}</li>`).join('')}</ul><p style="margin:6px 0 0"><strong>The program says:</strong> ${esc(p.eligibility)}</p><p class="hint">This check is a guide built from the program&rsquo;s published rules. The program decides eligibility.${pm.length ? ' Fill in My profile to sharpen it.' : ''}</p></div>
      <div class="rm-card"><h3 class="rm-h3">Know before you start</h3><ul style="margin:0 0 0 18px;padding:0"><li><strong>Dates:</strong> ${esc(p.dates)}</li><li><strong>Deadline:</strong> ${esc(p.deadlineText)}</li><li><strong>Pay:</strong> ${esc(p.pay)}</li><li><strong>Housing and travel:</strong> ${esc(p.housing)}</li><li><strong>Status:</strong> ${esc(p.status)}</li>${p.materials.map((m) => `<li><strong>Needs:</strong> ${esc(m)}</li>`).join('')}${p.notes.map((n) => `<li class="caution">${esc(n)}</li>`).join('')}</ul></div>
      <h2 class="rm-h2">Your checklist <span class="rm-muted" style="font-size:15px">(${g.done} of ${g.total})</span></h2><div class="rm-card">${check}</div>
      <h2 class="rm-h2">Essays and statements</h2>${prompts}
      <h2 class="rm-h2">Recommenders</h2><div class="rm-card">${p.recsNote ? `<p style="margin:0 0 6px">${esc(p.recsNote)}</p>` : ''}${recs ? `<ul style="margin:0 0 8px 18px;padding:0">${recs}</ul>` : '<p class="rm-muted">No recommenders added yet.</p>'}<button class="btn-s btn-sm" data-act="go" data-v="recs">Open the Recommenders tab</button></div>
      <h2 class="rm-h2">Copy-ready fields</h2>${copyFields(false)}
      <h2 class="rm-h2">Submit it</h2>
      <div class="rm-card"><ol style="margin:0 0 0 18px;padding:0">
        <li style="margin-bottom:6px"><strong>Re-read the official page</strong> once more. Dates and rules change.</li>
        <li style="margin-bottom:6px">Open the application ${portal ? 'portal' : 'instructions'} above. <strong>These portals do not accept submissions from other sites, so you press Submit yourself.</strong> That is how it works for every program here.</li>
        <li style="margin-bottom:6px">Click &ldquo;Open the copy helper in its own window.&rdquo; Put it next to the portal (on Windows, press the Windows key and an arrow key to snap windows side by side). Copy each field across.</li>
        <li style="margin-bottom:6px">Before you press Submit: no [brackets] left, every required upload attached, letters requested, and the time zone checked.</li>
        <li>Save the confirmation (email or screenshot), then mark it submitted:</li></ol>
        <div class="rm-row" style="margin-top:10px">${st.submittedAt ? `<span class="chip g">Submitted ${esc(fmtD(st.submittedAt))}</span><button class="btn-t" data-act="unsubmit" data-id="${p.id}">Undo</button>` : `<button class="btn-p" data-act="submitted" data-id="${p.id}">I submitted it</button>`}</div></div>
      <div class="rm-card"><label class="f" for="notes" style="margin-top:0">Your notes for this program (contacts, interview, login username)</label><textarea id="notes" data-bind="programs.${p.id}.notes" placeholder="Do not write passwords here.">${esc(st.notes || '')}</textarea></div>`;
  }
  function copyFields(compact) {
    const rows = applicantFields();
    return `<div class="rm-card"><div class="rm-row" style="margin-bottom:8px"><button class="btn-s btn-sm" data-act="copyAll">Copy all my details as one block</button><span class="rm-muted">${rows.filter((r) => !r[1]).length ? 'Empty rows need your info in <a href="#" data-act="go" data-v="profile">My profile</a>.' : ''}</span></div>
      <div class="cfs">${rows.map(([l, v], i) => `<div class="cf"><span class="cf-l">${esc(l)}</span><span class="cf-v ${v ? '' : 'empty'}">${v ? esc(v) : 'Not filled in yet'}</span><button type="button" class="btn-s btn-sm" data-act="copyRow" data-i="${i}" ${v ? '' : 'disabled'}>Copy</button></div>`).join('')}</div></div>`;
  }
  function vMini() {
    const p = PR[MINI];
    if (!p) return '<p class="rm-muted">Program not found.</p>';
    const st = PS(p.id);
    return `<div style="max-width:520px;margin:0 auto;padding:12px">
      <h1 class="rm-h3" style="color:var(--green);font-size:18px">${esc(p.name)}</h1><div class="rm-row">${dlChip(p)}</div>
      <p class="hint">Keep this window beside the application. Press Copy, then paste in the portal. Do not close the portal while you work.</p>
      ${copyFields(true)}
      ${p.prompts.map((q) => `<div class="rm-card"><strong style="font-size:14px">${esc(q.label.length > 90 ? q.label.slice(0, 87) + '...' : q.label)}</strong><div class="rm-muted" style="margin:4px 0 6px">${wordCount(st.text[q.id])} words</div><button class="btn-s btn-sm" data-act="copyText" data-id="${p.id}" data-q="${q.id}" ${(st.text[q.id] || '').trim() ? '' : 'disabled'}>Copy this answer</button></div>`).join('')}</div>`;
  }

  // Plan
  function vPlan() {
    const mine = S.mine.map((id) => PR[id]).sort(byDeadline);
    const all = D.PROGRAMS.filter((p) => p.deadline).sort(byDeadline);
    return `<h1 class="rm-h1">Plan and deadlines</h1>
      <p class="rm-lede">Work backward from the first deadline. Your own programs are marked.</p>
      <div class="rm-card tint">${D.PREP.map((x) => `<p style="margin:0 0 10px"><strong>${esc(x.when)}.</strong> ${esc(x.text)}</p>`).join('')}</div>
      <div class="rm-row" style="margin-bottom:10px"><button class="btn-p btn-sm" data-act="icsAll" ${mine.some((p) => p.deadline) ? '' : 'disabled'}>Download my deadlines for my calendar</button><span class="rm-muted">Adds a reminder one week before and on each deadline day.</span></div>
      <div class="tablewrap"><table class="rm"><thead><tr><th>Deadline</th><th>Program</th><th>Time and notes</th><th></th></tr></thead><tbody>${all.map((p) => { const m = S.mine.indexOf(p.id) >= 0; return `<tr${m ? ' style="background:var(--green-soft)"' : ''}><td>${dlChip(p)}</td><td><strong>${esc(p.name)}</strong>${m ? ' <span class="chip g">mine</span>' : ''}</td><td>${esc(p.deadlineText)}</td><td><button class="btn-s btn-sm" data-act="packet" data-id="${p.id}">Open</button></td></tr>`; }).join('')}</tbody></table></div>
      <p class="hint">Programs without a verified date are on the Programs page. Check their official pages.</p>`;
  }
  function icsAll() {
    const ev = [];
    S.mine.map((id) => PR[id]).filter((p) => p.deadline).forEach((p) => {
      const d = dl(p); const mk = (daysBefore, title) => { const x = new Date(d.getFullYear(), d.getMonth(), d.getDate() - daysBefore, 9, 0, 0); return { start: x, title }; };
      ev.push(Object.assign(mk(7, 'One week left: ' + p.name), { desc: 'Deadline: ' + p.deadlineText + '. Open the Application Hub to see your next step.' }));
      ev.push(Object.assign(mk(0, 'DEADLINE: ' + p.name), { desc: p.deadlineText + '. Check the time zone in the portal.' }));
    });
    const pad = (n) => String(n).padStart(2, '0'); const st = (x) => `${x.getFullYear()}${pad(x.getMonth() + 1)}${pad(x.getDate())}T${pad(x.getHours())}${pad(x.getMinutes())}00`;
    const esc2 = (s) => String(s || '').replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/,/g, '\\,').replace(/;/g, '\\;');
    const out = ['BEGIN:VCALENDAR', 'VERSION:2.0', 'PRODID:-//BIOS102 Application Hub//EN'];
    ev.forEach((e, i) => { const end = new Date(e.start.getTime() + 30 * 60000); out.push('BEGIN:VEVENT', 'UID:ap-' + i + '-' + e.start.getTime() + '@selassiefest.com', 'DTSTAMP:' + st(new Date()), 'DTSTART:' + st(e.start), 'DTEND:' + st(end), 'SUMMARY:' + esc2(e.title), 'DESCRIPTION:' + esc2(e.desc), 'BEGIN:VALARM', 'TRIGGER:-PT30M', 'ACTION:DISPLAY', 'DESCRIPTION:' + esc2(e.title), 'END:VALARM', 'END:VEVENT'); });
    out.push('END:VCALENDAR');
    const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([out.join('\r\n')], { type: 'text/calendar' })); a.download = 'my-research-application-deadlines.ics'; document.body.appendChild(a); a.click(); document.body.removeChild(a);
  }

  // ---------------- dictation ----------------
  const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
  let rec = null, recBtn = null; const MIC = 'Speak instead of typing';
  function stopDictation() { if (rec) { try { rec.stop(); } catch (e) { /* stopped */ } } }
  function addMics() {
    $$('textarea[data-bind], textarea[data-recline]').forEach((ta) => {
      if (ta.dataset.mic) return; ta.dataset.mic = '1';
      const row = document.createElement('div'); row.className = 'rm-row'; row.style.margin = '4px 0 0';
      if (SR) { row.innerHTML = `<button type="button" class="btn-s btn-sm" data-act="dictate">${MIC}</button><span class="hint"></span>`; row.firstChild.dataset.target = ta.id; }
      else row.innerHTML = '<span class="hint">To speak instead of typing, use the microphone key on your keyboard, or open this page in Chrome, Edge or Safari.</span>';
      ta.insertAdjacentElement('afterend', row);
    });
  }
  function toggleDictation(btn) {
    const ta = document.getElementById(btn.dataset.target); const hint = btn.nextElementSibling;
    if (rec && recBtn === btn) { stopDictation(); return; }
    stopDictation(); rec = new SR(); recBtn = btn; rec.lang = 'en-US'; rec.continuous = true; rec.interimResults = false;
    rec.onresult = (ev) => { let t = ''; for (let i = ev.resultIndex; i < ev.results.length; i++) if (ev.results[i].isFinal) t += ev.results[i][0].transcript; if (!t) return; ta.value = (ta.value && !/\s$/.test(ta.value) ? ta.value + ' ' : ta.value) + t.trim(); ta.dispatchEvent(new Event('input', { bubbles: true })); };
    rec.onerror = (ev) => { hint.textContent = ev.error === 'not-allowed' ? 'The microphone is blocked. Allow it in your browser settings and try again.' : 'Could not hear you. Try again.'; };
    rec.onend = () => { btn.textContent = MIC; if (/^Listening/.test(hint.textContent)) hint.textContent = ''; rec = null; recBtn = null; };
    btn.textContent = 'Stop'; hint.textContent = 'Listening... speak, then press Stop. Edit afterward.';
    try { rec.start(); } catch (e) { hint.textContent = 'Could not start the microphone.'; }
  }

  // ---------------- events ----------------
  function toggleMine(id) {
    const i = S.mine.indexOf(id);
    if (i >= 0) S.mine.splice(i, 1); else { S.mine.push(id); PS(id); }
    save(); render();
  }
  function handleClick(e) {
    const b = e.target.closest('[data-act]'); if (!b) return;
    if (b.tagName === 'INPUT' && b.type === 'checkbox' && b.dataset.act !== 'toggleCheck') return;
    if (b.tagName === 'A') e.preventDefault();
    const act = b.dataset.act, id = b.dataset.id, v = b.dataset.v;
    switch (act) {
      case 'go': go(v); break;
      case 'packet': ui.open = id; go('packet', id); break;
      case 'toggleMine': toggleMine(id); break;
      case 'filter': ui.filter = v; render(); break;
      case 'sort': ui.sort = v; render(); break;
      case 'addBeginner': {
        const c = D.PROGRAMS.filter((p) => p.lists.indexOf('beginner') >= 0 && eligibility(p).lvl !== 'no' && (daysLeft(p) === null || daysLeft(p) >= 0) && p.id !== 'thomson').sort(byDeadline).slice(0, 5);
        c.forEach((p) => { if (S.mine.indexOf(p.id) < 0) { S.mine.push(p.id); PS(p.id); } }); save(); go('mine'); break; }
      case 'copyRow': { const r = applicantFields()[Number(b.dataset.i)]; if (r && r[1]) copy(r[1], r[0] + ' copied'); break; }
      case 'copyAll': copy(applicantFields().filter((r) => r[1]).map((r) => r[0] + ': ' + r[1]).join('\n'), 'All details copied'); break;
      case 'copyMaster': copy(masterText(), 'Statement copied'); break;
      case 'copyText': { const t = PS(id).text[b.dataset.q] || ''; if (!t.trim()) { flash('Nothing written yet.', true); break; } copy(t, 'Answer copied'); break; }
      case 'seed': {
        const m = masterText(); if (!m) { flash('Build your master statement in My story first.', true); break; }
        const p = PR[id]; const st = PS(id); const cur = st.text[b.dataset.q] || '';
        if (cur.trim() && !window.confirm('Replace what is in this box with your master statement?')) break;
        st.text[b.dataset.q] = m.replace(/\[PROGRAM\]/g, p.name); save(); render(); break; }
      case 'toggleCheck': { const st = PS(id); st.done[b.dataset.k] = !st.done[b.dataset.k]; save(); render(); break; }
      case 'submitted': { const st = PS(id); st.submittedAt = new Date().toISOString(); st.status = 'submitted'; if (S.mine.indexOf(id) < 0) S.mine.push(id); save(); render(); break; }
      case 'unsubmit': { const st = PS(id); st.submittedAt = ''; st.status = 'working'; save(); render(); break; }
      case 'mini': window.open(location.pathname + '?mini=' + encodeURIComponent(id), 'aphelper', 'width=480,height=800,noopener'); break;
      case 'backup': backup(); break;
      case 'wipe': if (window.confirm('Erase everything you entered on this device? This cannot be undone unless you saved a backup file.')) { try { localStorage.removeItem(KEY); } catch (er) { /* ignore */ } S = blank(); render(); flash('Erased'); } break;
      case 'printResume': printResume(); break;
      case 'icsAll': icsAll(); break;
      case 'dictate': toggleDictation(b); break;
      case 'recOutlook': window.open(E.outlookCompose(currentRecDraft()), '_blank', 'noopener'); break;
      case 'recMail': window.location.href = E.mailto(currentRecDraft()); break;
      case 'recCopy': { const d = currentRecDraft(); copy('To: ' + d.to + '\nSubject: ' + d.subject + '\n\n' + d.body, 'Email copied'); break; }
      default: break;
    }
  }
  function currentRecDraft() {
    const sel = ui.recSel || (S.recs.find((r) => r.name) || S.recs[0]).id; const r = S.recs.find((x) => x.id === sel) || S.recs[0];
    const choices = S.mine.map((id) => PR[id]).sort(byDeadline);
    return recDraft(r, choices, ui.recTone[r.id] || '');
  }
  function backup() {
    const blob = new Blob([JSON.stringify(S, null, 2)], { type: 'application/json' });
    const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = 'my-application-hub-backup.json'; document.body.appendChild(a); a.click(); document.body.removeChild(a); flash('Backup saved to your Downloads folder');
  }
  function handleInput(e) {
    const t = e.target;
    if (t.dataset && t.dataset.recsel) { ui.recSel = t.value; render(); return; }
    if (t.dataset && t.dataset.recline) { ui.recTone[t.dataset.recline] = t.value; const d = currentRecDraft(); const pv = $('#rprev'); if (pv) pv.textContent = d.body; const r = S.recs.find((x) => x.id === t.dataset.recline) || {}; const ok = r.name && r.email && t.value.trim().length >= 25 && !/\[[^\]]*\]/.test(t.value); $$('[data-rneeds]').forEach((x) => { x.disabled = !ok; }); return; }
    if (t.id === 'restore') return;
    const path = t.dataset && t.dataset.bind; if (!path) return;
    let val = t.value; if (t.type === 'checkbox') val = t.checked ? 'yes' : 'no';
    if (t.type === 'radio' && !t.checked) return;
    setPath(S, path, val); save();
    if (path.indexOf('profile.') === 0 && view === 'profile') refreshProfileMeter();
    if (t.dataset.count) { const pid = path.split('.')[1]; const q = PR[pid].prompts.find((x) => x.id === t.dataset.count); const c = $('#cnt-' + t.dataset.count); if (c && q) { const lim = q.limit || {}; const wc = wordCount(val); const over = (lim.words && wc > lim.words) || (lim.chars && val.length > lim.chars); c.textContent = wc + ' words, ' + val.length + ' characters' + (lim.words ? ' (limit ' + lim.words + ' words)' : '') + (lim.chars ? ' (limit ' + lim.chars.toLocaleString() + ' characters)' : '') + (lim.note ? ' (' + lim.note + ')' : ''); c.style.color = over ? 'var(--bad)' : ''; c.style.fontWeight = over ? '700' : ''; } const br = $('#br-' + t.dataset.count); if (br) br.hidden = !/\[[^\]]*\]/.test(val); }
    if (path.indexOf('story.fields.') === 0) { const mb = $('#master-box'); if (mb) mb.innerHTML = masterBox(); }
    if (t.dataset.rerender && e.type === 'change') render();
    if (path.indexOf('recStatus.') === 0 && e.type === 'change') render();
    if (path === 'story.showGpa') { /* saved */ }
  }
  function handleRestore(e) {
    const f = e.target.files && e.target.files[0]; if (!f) return;
    const rd = new FileReader();
    rd.onload = () => { try { const got = JSON.parse(String(rd.result)); if (!got || got.v !== 1) throw new Error('bad'); try { localStorage.setItem(KEY, JSON.stringify(got)); } catch (er) { /* ignore */ } loadState(); render(); flash('Restored from your backup'); } catch (er) { flash('That file is not a valid backup.', true); } };
    rd.readAsText(f);
  }

  // ---------------- boot ----------------
  function boot() {
    $('#who').textContent = session.displayName || session.email || '';
    $('#checked').textContent = D.CHECKED;
    $('#logout').addEventListener('click', () => { BIOS.clearSession(); window.location.href = '/BIOS102/index.html'; });
    loadState();
    const v$ = $('#view');
    v$.addEventListener('click', handleClick); v$.addEventListener('input', handleInput); v$.addEventListener('change', (ev) => { if (ev.target.id === 'restore') handleRestore(ev); else handleInput(ev); });
    $('#steps').addEventListener('click', handleClick);
    if (MINI) { document.body.classList.add('mini'); ui.open = MINI; }
    render();
  }
  boot();
})();
