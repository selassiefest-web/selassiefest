// BIOS102 Summer Plan: run the summer research program as a program. A student keeps a docket of
// VERIFIED people, moves each through a status pipeline, follows a ten-week plan, drafts one-reason
// letters and plans the 30/60/90-day follow-up. Everything is saved only in this browser. The tool never
// sends a message, never invents a person, and caps outside meetings so the lab stays first.
(function () {
  const E = window.RM_ENGINE;
  const esc = (s) => BIOS.escapeHtml(s);
  const session = BIOS.requireSession();
  if (!session) return;
  const $ = (s, r) => (r || document).querySelector(s);
  const $$ = (s, r) => Array.from((r || document).querySelectorAll(s));
  const EMAIL = String(session.email || '').toLowerCase();
  const KEY = 'sd_v1_' + EMAIL, APKEY = 'ap_v1_' + EMAIL;
  const WEEK_CAP = 3;

  const STATUSES = [['not_researched', 'Not researched'], ['identified', 'Identified'], ['intro', 'Introduction needed'], ['drafted', 'Email drafted'], ['sent', 'Email sent'], ['awaiting', 'Awaiting response'], ['confirmed', 'Meeting confirmed'], ['completed', 'Meeting completed'], ['thanked', 'Thank-you sent'], ['followup', 'Follow-up needed'], ['ongoing', 'Ongoing mentorship']];
  const MET = ['completed', 'thanked', 'followup', 'ongoing'];
  const KINDS = [['researcher', 'Researcher'], ['leadership', 'Dean or senior leader'], ['mentor', 'Program or advising staff'], ['student', 'Student'], ['admissions', 'Admissions office (public role)']];
  const AIMS = { researcher: [1, 3], leadership: [1, 2], mentor: [2, 4], student: [4, 8] };
  const kindLabel = (k) => (KINDS.find((x) => x[0] === k) || [0, k])[1];
  const statusLabel = (s) => (STATUSES.find((x) => x[0] === s) || [0, s])[1];

  const WEEKS = [
    { t: 'Learn the bench and the map', i: 'The lab comes first. Learn it, and the campus around it.', k: ['Agree meeting windows with your supervisor', 'Meet your day-to-day lab mentor', 'Meet the summer program coordinator', 'Write the one-sentence affiliation statement, with its source', 'Start the People list (identified only, nothing sent yet)'] },
    { t: 'One lab conversation, two offices', i: 'A scientific conversation first, then offices that need lead time.', k: ['Meet one researcher about their work', 'Verify two senior or graduate-program leaders on official pages', 'Draft and approve one letter each, naming one reason each', 'Send those requests with two to three weeks of lead time'] },
    { t: 'A few careful conversations', i: 'Start with student voices, through an office or an introduction.', k: ['Ask the coordinator who you may appropriately approach', 'Hold one student conversation', 'Attend one open seminar', 'Log what you learned for every meeting'] },
    { t: 'Students who are further along', i: 'Ask about their experience, not anything confidential.', k: ['Meet one upper-year or graduate student', 'Do the mid-summer reflection: what has changed in my thinking?', 'Check lab workload with your supervisor'] },
    { t: 'Widen only where the work points', i: 'Add a person only when you have a specific question.', k: ['Contact a department leader only if you have a specific departmental question', 'Review all notes and unanswered questions', 'Stay at or under three meetings this week'] },
    { t: 'Check the science, not the social calendar', i: 'Put the research results first.', k: ['Review methods and results with your mentor', 'Attend one public event', 'Send a follow-up only to people you spoke with substantively'] },
    { t: 'Ask what continues', i: 'Find out what can keep going after August.', k: ['Discuss academic-year research with your two or three strongest mentors', 'Ask about open seminars or journal clubs', 'Draft the research-continuation plan'] },
    { t: 'Close the loop', i: 'Present, thank, and agree how you will stay in touch.', k: ['Present your research (lab meeting or program symposium)', 'Send thank-you notes within 24 hours of each meeting', 'Ask permission to send an occasional update'] },
    { t: 'Only the live threads', i: 'Optional week: finish what matters, drop the rest.', k: ['Resolve the most important unanswered question', 'Release any request that did not get a reply, politely'] },
    { t: 'Leave a record', i: 'Make the summer last past September.', k: ['Debrief with the coordinator', 'Set your 30, 60 and 90-day reminders', 'Save a one-page summary and an updated profile'] },
  ];

  const Q = {
    researcher: ['What question is the lab most interested in answering right now?', 'What would a suitable undergraduate contribution look like?', 'Who would supervise me day to day, and what training comes first?', 'How often would we discuss progress and troubleshoot?', 'Could this continue during the academic year?'],
    leadership: ['What do you hope undergraduate researchers learn beyond lab techniques?', 'How does the college connect research with education?', 'Which public events or seminars would you recommend?', 'What habits help students become thoughtful, reliable learners?', 'Which office or person would be the right one to approach next?'],
    mentor: ['What are the expectations for summer researchers here?', 'Who is it appropriate for me to approach, and how?', 'What options exist to continue research after the summer?', 'Are there seminars or presentations I am welcome at?'],
    student: ['What surprised you most about the transition?', 'What did you do as an undergraduate that mattered, and what would you do differently?', 'How did you find mentors?', 'How do you balance coursework and research?', 'What advice would you give someone still exploring?'],
    admissions: ['What official resources explain your current expectations for prospective students?', 'Which public sessions or events are open to undergraduates?', 'How do you suggest students reflect on a research experience?'],
  };
  const BOUND = { researcher: 'Do not assume a lab has an opening. Ask what a contribution could look like.', leadership: 'Do not ask for admission preference, application review or advocacy.', mentor: 'Ask for guidance and introductions, not favors.', student: 'Ask about their own experience only. Never ask for confidential information.', admissions: 'Ask what is appropriate FIRST and follow their guidance. Never ask about committee members, scoring, cutoffs, or your own application.' };

  // ---------------- state ----------------
  function blank() {
    return { v: 1, setup: { university: '', medCollege: '', affiliation: '', affiliationSource: '', program: '', start: '', end: '', supervisor: '', project: '', coordinator: '', labWindows: '' },
      me: { name: session.displayName || '', email: session.email || '', home: 'UW–Parkside', major: '', year: '', interests: '', priorLab: '' }, contacts: [], done: {}, _t: 0 };
  }
  let S = blank();
  let view = 'start';
  let ui = { open: null, letterFor: '', tpl: '', reason: '', times: '' };
  function load() {
    try {
      const raw = localStorage.getItem(KEY);
      if (raw) { const g = JSON.parse(raw); const b = blank(); S = Object.assign(b, g); S.setup = Object.assign(b.setup, g.setup || {}); S.me = Object.assign(b.me, g.me || {}); S.contacts = g.contacts || []; S.done = g.done || {}; }
      else {
        // first visit: borrow name, major and year from the Application Hub profile, if it exists on this device
        const ap = JSON.parse(localStorage.getItem(APKEY) || 'null');
        if (ap && ap.profile) { const p = ap.profile; S.me.name = [p.first, p.last].filter(Boolean).join(' ') || S.me.name; S.me.major = p.major || ''; S.me.year = ({ first: 'first-year', second: 'second-year', third: 'third-year', fourth: 'fourth-year' })[p.classYear] || ''; S.me.email = p.email || S.me.email; S.me.home = p.school || S.me.home; }
      }
    } catch (e) { S = blank(); }
  }
  function flash(msg, err) { const el = $('#saved'); if (!el) return; el.textContent = msg; el.className = 'saved show' + (err ? ' err' : ''); clearTimeout(flash.t); if (!err) flash.t = setTimeout(() => { el.className = 'saved'; }, 1100); }
  function save() { S._t = Date.now(); try { localStorage.setItem(KEY, JSON.stringify(S)); flash('Saved on this device'); } catch (e) { flash('This browser blocked saving. Use "Save a backup file".', true); } }
  function setPath(o, path, v) { const p = path.split('.'); for (let i = 0; i < p.length - 1; i++) { if (o[p[i]] == null || typeof o[p[i]] !== 'object') o[p[i]] = {}; o = o[p[i]]; } o[p[p.length - 1]] = v; }
  const today = () => new Date().toISOString().slice(0, 10);
  const daysSince = (iso) => { if (!iso) return null; const t = new Date(iso).getTime(); return isNaN(t) ? null : Math.floor((Date.now() - t) / 86400000); };
  const fmt = (iso, o) => { const d = new Date(iso); return isNaN(d) ? '' : d.toLocaleDateString('en-US', o || { month: 'short', day: 'numeric' }); };
  const sentenceOk = (t) => { t = String(t || '').trim(); return t.length >= 25 && !/\[[^\]]*\]/.test(t); };
  const canContact = (c) => c.verified === 'yes' && String(c.source || '').trim().length > 6 && String(c.name || '').trim();

  // ---------------- rules ----------------
  function weekStart(d) { const x = new Date(d); x.setHours(0, 0, 0, 0); const day = (x.getDay() + 6) % 7; x.setDate(x.getDate() - day); return x; }
  function meetingsInWeekOf(dateStr) {
    const ws = weekStart(dateStr).getTime();
    return S.contacts.filter((c) => c.confirmedDate && ['confirmed', 'completed', 'thanked', 'followup', 'ongoing'].indexOf(c.status) >= 0 && weekStart(c.confirmedDate).getTime() === ws).length;
  }
  function flags(c) {
    const f = [];
    if (['sent', 'awaiting'].indexOf(c.status) >= 0 && (daysSince(c.requestDate) || 0) >= 8 && !c.nudged) f.push(['warn', 'One polite follow-up is due (8+ days)']);
    if (['sent', 'awaiting'].indexOf(c.status) >= 0 && c.nudged && (daysSince(c.requestDate) || 0) >= 16) f.push(['', 'No reply after one follow-up. Release it courteously.']);
    if (c.status === 'completed' && !c.thanksSent && (daysSince(c.confirmedDate) || 0) >= 1) f.push(['bad', 'Thank-you is due (within 24 hours)']);
    if (c.status === 'confirmed' && !c.prepDone) f.push(['warn', 'Prep packet not done']);
    if (c.confirmedDate && ['confirmed'].indexOf(c.status) >= 0 && meetingsInWeekOf(c.confirmedDate) > WEEK_CAP) f.push(['bad', 'More than ' + WEEK_CAP + ' meetings that week']);
    if (c.status !== 'not_researched' && !canContact(c) && ['sent', 'awaiting', 'drafted', 'confirmed'].indexOf(c.status) >= 0) f.push(['warn', 'Not verified: add the official source']);
    return f;
  }
  function counts() {
    const out = {};
    KINDS.forEach(([k]) => { out[k] = { met: S.contacts.filter((c) => c.kind === k && MET.indexOf(c.status) >= 0).length, all: S.contacts.filter((c) => c.kind === k).length }; });
    return out;
  }
  function currentWeek() {
    if (!S.setup.start) return null;
    const d = Math.floor((Date.now() - new Date(S.setup.start + 'T00:00:00').getTime()) / 86400000);
    return d < 0 ? 0 : Math.floor(d / 7) + 1;
  }
  function nextActions() {
    const out = [];
    S.contacts.forEach((c) => flags(c).forEach((fl) => out.push({ c, t: fl[1], tone: fl[0] })));
    out.sort((a, b) => (b.tone === 'bad') - (a.tone === 'bad'));
    return out;
  }

  // ---------------- navigation ----------------
  const TABS = [['start', 'Start'], ['setup', 'Campus and me'], ['people', 'People'], ['weeks', 'Ten weeks'], ['letters', 'Letters'], ['after', 'After the summer']];
  function go(v) { view = v; render(); window.scrollTo(0, 0); }
  function render() {
    $('#steps').innerHTML = TABS.map(([id, l]) => `<li><button type="button" data-act="go" data-v="${id}" ${view === id ? 'aria-current="step"' : ''}>${esc(l)}</button></li>`).join('');
    const fn = { start: vStart, setup: vSetup, people: vPeople, weeks: vWeeks, letters: vLetters, after: vAfter }[view] || vStart;
    $('#view').innerHTML = fn();
    addMics();
  }

  // ---------------- views ----------------
  function vStart() {
    const first = esc((S.me.name || '').split(' ')[0] || 'there');
    const wk = currentWeek(); const cts = counts(); const acts = nextActions();
    const aim = (k) => { const a = AIMS[k]; const c = cts[k].met; return `<div class="rm-card" style="margin:0"><div class="rm-muted" style="font-weight:600">${esc(kindLabel(k))}</div><div class="rank" style="font-size:32px">${c}<span class="rm-muted" style="font-size:16px"> met</span></div><div class="rm-muted">${cts[k].all} on the list &middot; aim ${a[0]}&ndash;${a[1]}${c > a[1] ? '. Enough: more will crowd the lab.' : ''}</div></div>`; };
    return `<div class="rm-hero"><h1 class="rm-h1">Hi ${first}. Run the summer as a program.</h1>
      <p class="rm-lede">You won a research spot. This plan helps you do the research well and also learn from the people around it, without letting the lab slip. It starts empty: nothing here is invented for you.</p></div>
      <div class="rm-card warn"><strong>Your information stays on this computer.</strong> Nothing here is sent anywhere. The tool never sends a message for you; you review and send every email yourself from your UWP Outlook. Check Outlook every day.</div>
      ${!S.setup.program ? `<div class="rm-card green rm-spread"><div><strong>First, tell it about your program.</strong><div class="rm-muted">Your program, host campus and dates (it builds your ten weeks from them).</div></div><button class="btn-p" data-act="go" data-v="setup">Set up</button></div>` : `<div class="rm-card green"><strong>${esc(S.setup.program)}</strong>${S.setup.university ? ' at ' + esc(S.setup.university) : ''}${wk ? ' &middot; ' + (wk >= 1 && wk <= 10 ? 'Week ' + wk : wk === 0 ? 'starts ' + esc(fmt(S.setup.start)) : 'program ended') : ''}</div>`}
      <div class="rm-grid" style="grid-template-columns:repeat(auto-fill,minmax(200px,1fr))">${['researcher', 'leadership', 'mentor', 'student'].map(aim).join('')}</div>
      <p class="hint">These counts are aims, not promises anyone owes you. Quality beats quantity.</p>
      <h2 class="rm-h2">Next actions</h2>
      ${acts.length ? acts.slice(0, 6).map((a) => `<div class="rm-card ${a.tone === 'bad' ? 'warn' : ''}"><div class="rm-spread"><div><strong>${esc(a.c.name || 'Unnamed contact')}</strong><div class="rm-muted">${esc(a.t)}</div></div><button class="btn-s btn-sm" data-act="open" data-id="${a.c.id}">Open</button></div></div>`).join('') : '<div class="rm-card"><p style="margin:0" class="rm-muted">Nothing is waiting. Add a verified person, or finish this week&rsquo;s lab tasks, before you look for another meeting.</p></div>'}
      <h2 class="rm-h2">Rules that do not bend</h2>
      <div class="rm-card tint"><ul style="margin:0 0 0 18px;padding:0">
        <li><strong>The lab comes first.</strong> No more than ${WEEK_CAP} outside meetings in a week, scheduled around your experiments.</li>
        <li><strong>Verify before you write.</strong> A person goes on the list only after you have seen their title on an official page. Record the source.</li>
        <li><strong>One person, one letter, one reason.</strong> No mass emails. A generic reason means do not send.</li>
        <li><strong>Ask for time, not favors.</strong> Never ask for an admission preference, an application review, or anything confidential.</li>
        <li><strong>A profile is not an open position.</strong> Do not assume a lab has room.</li>
        <li><strong>One polite follow-up</strong> after 8 days. Then let it go. A no, or silence, is final and courteous.</li></ul></div>`;
  }

  function fieldRow(label, path, val, ph, type) {
    return `<div><label class="f" for="${path}">${esc(label)}</label><input type="${type || 'text'}" id="${path}" data-bind="${path}" value="${esc(val || '')}" ${ph ? `placeholder="${esc(ph)}"` : ''}></div>`;
  }
  function vSetup() {
    const s = S.setup, m = S.me;
    return `<h1 class="rm-h1">Campus and me</h1>
      <p class="rm-lede">Fill in what you know. Leave a field empty if you do not know it yet.</p>
      <div class="rm-card"><h3 class="rm-h3">Your summer program</h3><div class="rm-grid" style="grid-template-columns:repeat(auto-fill,minmax(240px,1fr))">
        ${fieldRow('Program name', 'setup.program', s.program)}${fieldRow('Host university or institute', 'setup.university', s.university)}${fieldRow('Medical college or school (if any)', 'setup.medCollege', s.medCollege)}
        ${fieldRow('First day', 'setup.start', s.start, '', 'date')}${fieldRow('Last day', 'setup.end', s.end, '', 'date')}${fieldRow('Research supervisor', 'setup.supervisor', s.supervisor)}${fieldRow('Program coordinator', 'setup.coordinator', s.coordinator)}${fieldRow('Windows your supervisor approved for meetings', 'setup.labWindows', s.labWindows, 'for example Tue and Thu after 3 pm')}</div>
        <label class="f" for="setup.project">Your project, in one plain sentence</label><textarea id="setup.project" data-bind="setup.project">${esc(s.project)}</textarea>
        <label class="f" for="setup.affiliation">How the medical college is tied to the university (one sentence)</label><textarea id="setup.affiliation" data-bind="setup.affiliation" placeholder="Use the institution's own page. A shared campus is not the same as a faculty appointment.">${esc(s.affiliation)}</textarea>
        ${fieldRow('Source page for that sentence (web address)', 'setup.affiliationSource', s.affiliationSource)}
        <p class="hint">A hospital appointment is not a medical-college appointment. Check each person&rsquo;s own official profile.</p></div>
      <div class="rm-card"><h3 class="rm-h3">About you</h3><div class="rm-grid" style="grid-template-columns:repeat(auto-fill,minmax(240px,1fr))">
        ${fieldRow('Name', 'me.name', m.name)}${fieldRow('Email (your UWP Outlook)', 'me.email', m.email, '', 'email')}${fieldRow('Home university', 'me.home', m.home)}${fieldRow('Major', 'me.major', m.major)}${fieldRow('Year (for example second-year)', 'me.year', m.year)}</div>
        <label class="f" for="me.interests">Your scientific interests, honestly (it is fine to say you are still exploring)</label><textarea id="me.interests" data-bind="me.interests">${esc(m.interests)}</textarea>
        <label class="f" for="me.priorLab">Your real lab experience so far (or &ldquo;this is my first research experience&rdquo;)</label><textarea id="me.priorLab" data-bind="me.priorLab">${esc(m.priorLab)}</textarea></div>
      <div class="rm-card green"><h3 class="rm-h3">Your 30-second introduction</h3><div class="preview">${esc(intro())}</div><button class="btn-s btn-sm" data-act="copyIntro">Copy it</button></div>
      <div class="rm-card"><div class="rm-row"><button class="btn-s btn-sm" data-act="backup">Save a backup file</button><label class="btn-s btn-sm" style="cursor:pointer">Restore from a backup<input type="file" id="restore" accept="application/json" hidden></label><button class="btn-t" data-act="wipe">Erase everything on this device</button></div><p class="hint">A backup file contains your notes and contact details, so keep it private.</p></div>`;
  }
  function intro() {
    const m = S.me, s = S.setup;
    return `I'm ${m.name || '[Your name]'}, a ${m.year || '[year]'} ${m.major || '[major]'} student at ${m.home || '[university]'}. This summer I'm in ${s.supervisor ? s.supervisor + "'s" : "a"} lab${s.project ? ' working on ' + s.project.replace(/[.\s]+$/, '') : ''}. I'm exploring ${m.interests ? m.interests.replace(/[.\s]+$/, '') : '[your honest interests]'}, and I'd like to understand [a specific topic for this person].`;
  }

  // People
  function blankContact(kind) {
    return { id: 'c' + Date.now().toString(36) + Math.random().toString(36).slice(2, 5), kind, name: '', title: '', dept: '', verified: 'no', source: '', email: '', emailSource: '', why: '', topic: '', status: 'not_researched', requestDate: '', confirmedDate: '', place: '', prepDone: false, thanksSent: false, nudged: false, notes: '', tier: '' };
  }
  function vPeople() {
    const list = S.contacts;
    const add = KINDS.map(([k, l]) => `<button type="button" class="chip" data-act="addContact" data-v="${k}">+ ${esc(l)}</button>`).join('');
    const cards = list.map((c, i) => contactCard(c, i)).join('');
    return `<h1 class="rm-h1">People</h1>
      <p class="rm-lede">Only people you have verified on an official page. Add one at a time. The status moves from &ldquo;Not researched&rdquo; to &ldquo;Ongoing mentorship&rdquo;; the page tells you when a follow-up or thank-you is due.</p>
      <div class="rm-card tint"><strong>Verify first.</strong> Before you write to anyone, open the official page, see their exact title, and paste its web address below. A person without a source cannot be marked ready to contact. Do not guess an email address. If none is published, use the office&rsquo;s public contact route.</div>
      <div class="rm-row" style="margin-bottom:12px"><span class="rm-muted">Add:</span>${add}</div>
      ${list.length ? cards : '<div class="rm-card"><p style="margin:0" class="rm-muted">No one yet. Start with your supervisor, your day-to-day mentor and the program coordinator.</p></div>'}`;
  }
  function contactCard(c, i) {
    const open = ui.open === c.id; const fl = flags(c); const P = 'contacts.' + i + '.';
    const bind = (k, label, ph, type) => `<div><label class="f" for="${P}${k}">${esc(label)}</label><input type="${type || 'text'}" id="${P}${k}" data-bind="${P}${k}" ${['name', 'title', 'dept', 'source', 'requestDate', 'confirmedDate'].indexOf(k) >= 0 ? 'data-rerender="1"' : ''} value="${esc(c[k] || '')}" ${ph ? `placeholder="${esc(ph)}"` : ''}></div>`;
    return `<div class="rm-card ${MET.indexOf(c.status) >= 0 ? 's-done' : c.status === 'confirmed' ? 's-scheduled' : ['sent', 'awaiting'].indexOf(c.status) >= 0 ? 's-sent' : 's-none'}">
      <div class="rm-spread"><div><h3 class="rm-h3" style="font-size:18px;color:var(--green)">${esc(c.name || 'Unnamed contact')}</h3><div class="rm-muted">${esc(c.title || '')}${c.title && c.dept ? ' &middot; ' : ''}${esc(c.dept || '')}</div><div class="rm-row"><span class="chip">${esc(kindLabel(c.kind))}</span><span class="chip ${canContact(c) ? 'g' : 'w'}">${canContact(c) ? 'Verified, source recorded' : 'Not verified yet'}</span><span class="chip b">${esc(statusLabel(c.status))}</span>${fl.map((f) => `<span class="chip ${f[0] === 'bad' ? 'bad' : 'w'}">${esc(f[1])}</span>`).join('')}</div></div>
      <div class="rm-row"><button class="btn-s btn-sm" data-act="open" data-id="${c.id}">${open ? 'Close' : 'Edit'}</button></div></div>
      ${c.kind === 'admissions' ? `<div class="rm-card warn" style="margin:8px 0 0"><strong>Admissions office, public role only.</strong> Ask what educational conversation or event is appropriate and follow their guidance for prospective students. Never seek committee members, scoring, cutoffs or your own application evaluation. These do not count toward any target.</div>` : ''}
      ${open ? `<div class="detail"><div class="rm-grid" style="grid-template-columns:repeat(auto-fill,minmax(230px,1fr))">
        ${bind('name', 'Full name')}${bind('title', 'Exact title (as on the official page)')}${bind('dept', 'Department or office')}
        <div><label class="f" for="${P}verified">Verified on an official page?</label><select id="${P}verified" data-bind="${P}verified" data-rerender="1"><option value="no" ${c.verified !== 'yes' ? 'selected' : ''}>Not yet</option><option value="yes" ${c.verified === 'yes' ? 'selected' : ''}>Yes, I saw it</option></select></div>
        ${bind('source', 'Official page (web address)', 'https://')}${bind('email', 'Public email (only if published)')}${bind('emailSource', 'Where the email is published')}
        <div><label class="f" for="${P}status">Status</label><select id="${P}status" data-bind="${P}status" data-rerender="1">${STATUSES.map(([v, l]) => `<option value="${v}" ${c.status === v ? 'selected' : ''}>${l}</option>`).join('')}</select></div>
        ${bind('requestDate', 'Date you sent the request', '', 'date')}${bind('confirmedDate', 'Meeting date and time', '', 'datetime-local')}${bind('place', 'Where (room or video link)')}</div>
        <label class="f" for="${P}why">Why meet this person (one specific, honest sentence)</label><textarea id="${P}why" data-bind="${P}why">${esc(c.why)}</textarea>
        <label class="f" for="${P}topic">What you want to learn from them</label><input type="text" id="${P}topic" data-bind="${P}topic" value="${esc(c.topic)}">
        <label class="f" for="${P}notes">Notes (professional only: what you learned, what they offered, what you agreed to do)</label><textarea id="${P}notes" data-bind="${P}notes">${esc(c.notes)}</textarea>
        <div class="rm-row" style="margin-top:8px"><label class="opt"><input type="checkbox" data-bind="${P}prepDone" data-check="1" data-rerender="1" ${c.prepDone ? 'checked' : ''}> Prep packet done</label><label class="opt"><input type="checkbox" data-bind="${P}thanksSent" data-check="1" data-rerender="1" ${c.thanksSent ? 'checked' : ''}> Thank-you sent</label><label class="opt"><input type="checkbox" data-bind="${P}nudged" data-check="1" data-rerender="1" ${c.nudged ? 'checked' : ''}> One follow-up sent</label></div>
        <div class="rm-row" style="margin-top:8px"><button class="btn-p btn-sm" data-act="letterFor" data-id="${c.id}">Draft a letter</button><button class="btn-s btn-sm" data-act="packet" data-id="${c.id}">Print prep packet</button><button class="btn-t" data-act="removeContact" data-id="${c.id}">Remove this person</button></div></div>` : ''}</div>`;
  }

  // Ten weeks
  function vWeeks() {
    const wk = currentWeek(); const st = S.setup.start;
    return `<h1 class="rm-h1">Ten weeks</h1>
      <p class="rm-lede">${st ? 'Built from your start date.' : 'Add your first day in Campus and me to put dates on the weeks.'} If your program is eight weeks, fold weeks 9 and 10 into week 8. Tasks are suggestions, and the lab always wins.</p>
      ${WEEKS.map((w, n) => {
        const num = n + 1; const from = st ? new Date(new Date(st + 'T00:00:00').getTime() + n * 7 * 86400000) : null; const to = from ? new Date(from.getTime() + 6 * 86400000) : null;
        const cnt = from ? S.contacts.filter((c) => c.confirmedDate && new Date(c.confirmedDate) >= from && new Date(c.confirmedDate) <= new Date(to.getTime() + 86399999) && ['confirmed', 'completed', 'thanked', 'followup', 'ongoing'].indexOf(c.status) >= 0).length : 0;
        return `<div class="rm-card ${wk === num ? 'green' : ''}"><div class="rm-spread"><div><h3 class="rm-h3" style="margin:0">Week ${num}: ${esc(w.t)}</h3><div class="rm-muted">${esc(w.i)}</div></div><div class="rm-muted">${from ? esc(fmt(from.toISOString())) + ' &ndash; ' + esc(fmt(to.toISOString())) : ''}${wk === num ? ' &middot; <strong>this week</strong>' : ''}${cnt ? ' &middot; ' + cnt + ' meeting' + (cnt === 1 ? '' : 's') : ''}${cnt > WEEK_CAP ? ' <span class="chip bad">over the ' + WEEK_CAP + ' limit</span>' : ''}</div></div>
          <div style="margin-top:8px">${w.k.map((t, j) => { const id = 'w' + num + '-' + j; return `<label class="q-item"><input type="checkbox" data-act="toggleTask" data-id="${id}" ${S.done[id] ? 'checked' : ''}> <span>${esc(t)}</span></label>`; }).join('')}</div></div>`;
      }).join('')}`;
  }

  // Letters
  function ctx(c) { return { m: S.me, s: S.setup, c }; }
  function greet(c) { const n = (c.name || '').trim(); if (!n) return 'Hello'; const t = (c.title || '').toLowerCase(); const last = n.split(' ').slice(-1)[0]; if (c.kind === 'student') return 'Hi ' + n.split(' ')[0]; if (/dean/.test(t)) return 'Dear Dean ' + last; if (/professor|\bdr\b|director|chair|\bmd\b|phd/.test(t) || c.kind === 'researcher') return 'Dear Dr. ' + last; return 'Dear ' + n; }
  function me() { const m = S.me, s = S.setup; return { who: `${m.name || '[Your name]'}, a ${m.year || '[year]'} ${m.major || '[major]'} student at ${m.home || '[home university]'}`, prog: s.program || '[program]', host: s.university || '[host]', sup: s.supervisor || '[supervisor]', proj: s.project ? s.project.replace(/[.\s]+$/, '') : '[your project]', sig: [m.name, (m.year || '') + ' ' + (m.major || ''), s.program, m.email].filter((x) => x && x.trim()).join('\n') }; }
  const TPL = {
    researcher: ['Research faculty: first request', (c, r, t) => ({ s: 'Summer research discussion: ' + (c.topic || 'your work'), b: `${greet(c)},\n\nMy name is ${me().who}. I am spending the summer at ${me().host} through ${me().prog}, working with ${me().sup} on ${me().proj}.\n\n${r}\n\nWould you be available for a 20 to 30 minute conversation about your research and how undergraduates may contribute to work in this area? I am not assuming any position exists. ${t ? 'I am free ' + t + ', and' : 'I'} can work around your schedule and my required lab commitments.\n\nSincerely,\n${me().sig}` })],
    leader: ['Dean or senior leader: first request', (c, r, t) => ({ s: 'Summer undergraduate researcher seeking educational guidance', b: `${greet(c)},\n\nI am ${me().who}, taking part in ${me().prog} at ${me().host} and working with ${me().sup} on ${me().proj}.\n\n${r}\n\nMay I request 20 to 30 minutes to ask for your perspective on how an undergraduate can make this summer meaningful? This is a learning conversation, not a request about any application. I would be equally grateful for time with a colleague you recommend. ${t ? 'I am free ' + t + '.' : ''}\n\nRespectfully,\n${me().sig}` })],
    mentor: ['Program or advising staff: first request', (c, r, t) => ({ s: 'Planning responsible campus engagement this summer', b: `${greet(c)},\n\nI am ${me().who}, spending the summer in ${me().prog} with ${me().sup}.\n\n${r}\n\nCould we meet for 20 to 30 minutes? I would like to understand program expectations, appropriate introductions, and any restrictions I should follow. ${t ? 'I am free ' + t + '.' : ''}\n\nThank you,\n${me().sig}` })],
    student: ['Student: first request', (c, r, t) => ({ s: 'A quick chat? Summer undergraduate researcher', b: `${greet(c)},\n\nI am ${me().who}, doing summer research here through ${me().prog}. ${r}\n\nCould I have 20 minutes to hear about your experience? A call, a walk or a few written answers all work, whatever fits your schedule. ${t ? 'I am free ' + t + '.' : ''}\n\nThanks either way,\n${me().sig}` })],
    admissions: ['Admissions office: educational question', (c, r, t) => ({ s: 'Educational question from a summer undergraduate researcher', b: `${greet(c)},\n\nI am ${me().who}, taking part in ${me().prog} at ${me().host}.\n\n${r}\n\nI would like to ask what educational conversation, public session or resource your office considers appropriate for an undergraduate researcher. I am not asking about any application, and I will follow any guidance you have for prospective students. If a different office is the right place to ask, I would be grateful for the direction.\n\nThank you,\n${me().sig}` })],
    thanks: ['Thank-you (within 24 hours)', (c, r) => ({ s: 'Thank you: ' + (c.topic || 'our conversation'), b: `${greet(c)},\n\nThank you for speaking with me${c.confirmedDate ? ' on ' + fmt(c.confirmedDate, { weekday: 'long', month: 'long', day: 'numeric' }) : ''}. ${r}\n\nI appreciate your time and guidance.\n${me().sig}` })],
    nudge: ['One polite follow-up', (c, r) => ({ s: 'Following up: ' + (c.topic || 'my request'), b: `${greet(c)},\n\nI am following up once on my earlier note. ${r}\n\nI understand your schedule may not allow a meeting. If another colleague or a public event would be more appropriate, I would appreciate that guidance.\n\nThank you for considering it.\n${me().sig}` })],
    d30: ['30-day update', (c, r) => ({ s: 'A short update since we spoke', b: `${greet(c)},\n\nA short update, no reply needed. ${r}\n\nThank you again for the time you gave me this summer.\n${me().sig}` })],
    d60: ['60-day check-in', (c, r) => ({ s: 'A focused question, if you have a moment', b: `${greet(c)},\n\nSince we spoke, ${r}\n\nIf it is not a good time, no problem at all.\n${me().sig}` })],
    d90: ['90-day note', (c, r) => ({ s: 'A milestone and a possible next step', b: `${greet(c)},\n\nI wanted to share a milestone: ${r}\n\nIf it would be useful, I could take on one small, specific task. I understand if the timing is not right.\n${me().sig}` })],
  };
  const tplFor = (c) => ({ researcher: 'researcher', leadership: 'leader', mentor: 'mentor', student: 'student', admissions: 'admissions' })[c.kind] || 'mentor';
  const FIRST = ['researcher', 'leader', 'mentor', 'student', 'admissions'];
  function curDraft() {
    const c = S.contacts.find((x) => x.id === ui.letterFor); if (!c) return null;
    const id = ui.tpl || tplFor(c); const t = TPL[id]; if (!t) return null;
    const reason = ui.reason.trim() || '[YOUR OWN SENTENCE: the one specific reason you are writing to this person]';
    const d = t[1](c, reason, ui.times.trim());
    return { id, c, to: c.email || '', subject: d.s, body: d.b };
  }
  function vLetters() {
    if (!S.contacts.length) return `<h1 class="rm-h1">Letters</h1><div class="rm-card warn"><p style="margin:0 0 10px">Add a verified person first.</p><button class="btn-p" data-act="go" data-v="people">Go to People</button></div>`;
    if (!ui.letterFor) ui.letterFor = S.contacts[0].id;
    const c = S.contacts.find((x) => x.id === ui.letterFor) || S.contacts[0];
    const d = curDraft(); const first = FIRST.indexOf(d.id) >= 0; const ok = sentenceOk(ui.reason) && (!first || canContact(c));
    return `<h1 class="rm-h1">Letters</h1>
      <p class="rm-lede">One person, one letter, one reason. You write the specific sentence; the tool does the rest. It never sends anything: you open your own email and press send.</p>
      <div class="rm-card"><div class="rm-grid" style="grid-template-columns:repeat(auto-fill,minmax(240px,1fr))">
        <div><label class="f" for="lf">Write to</label><select id="lf" data-letter="for">${S.contacts.map((x) => `<option value="${x.id}" ${x.id === c.id ? 'selected' : ''}>${esc(x.name || 'Unnamed')} (${esc(kindLabel(x.kind))})</option>`).join('')}</select></div>
        <div><label class="f" for="lt">Letter</label><select id="lt" data-letter="tpl">${Object.entries(TPL).map(([k, v]) => `<option value="${k}" ${k === d.id ? 'selected' : ''}>${esc(v[0])}</option>`).join('')}</select></div>
        <div><label class="f" for="ltm">When you are free (optional)</label><input type="text" id="ltm" data-letter="times" value="${esc(ui.times)}" placeholder="for example: Tuesday after 3 pm"></div></div>
        ${first && !canContact(c) ? `<p class="need" style="margin-top:10px">This person is not verified yet. Add their official page in People before you write to them.</p>` : ''}
        <label class="f" for="lr">Your specific reason (required, in your own words)</label><textarea id="lr" data-letter="reason" placeholder="${first ? 'One verified detail about this person, and why it matters to you' : d.id === 'thanks' ? 'Two specific things they said, and the one thing you will do because of it' : d.id === 'd60' ? 'What you have done since, and your one focused question' : 'One specific, real thing: a result, a milestone, or new context'}">${esc(ui.reason)}</textarea>
        <p class="hint">Generic reasons mean do not send. No [brackets] may remain.</p>
        <label class="f">Preview</label><div class="preview" id="lprev"><b>To:</b> ${esc(d.to || '(add a public email, or use the office contact route)')}\n<b>Subject:</b> ${esc(d.subject)}\n\n${esc(d.body)}</div>
        <div class="rm-row"><button class="btn-p" data-act="lOutlook" ${ok ? '' : 'disabled'} data-lneeds="1">Open in Outlook (web)</button><button class="btn-s" data-act="lMail" ${ok ? '' : 'disabled'} data-lneeds="1">Open in my mail app</button><button class="btn-s" data-act="lCopy" ${ok ? '' : 'disabled'} data-lneeds="1">Copy it</button><button class="btn-s" data-act="lSent" ${ok ? '' : 'disabled'} data-lneeds="1">I sent it</button></div>
        <p class="hint">Check the details one more time, send it yourself, then tap &ldquo;I sent it&rdquo; so the tracker can remind you.</p></div>`;
  }

  // After the summer
  function vAfter() {
    const end = S.setup.end; const base = end ? new Date(end + 'T00:00:00') : null;
    const due = (n) => base ? fmt(new Date(base.getTime() + n * 86400000).toISOString(), { month: 'short', day: 'numeric', year: 'numeric' }) : 'set your last day';
    const met = S.contacts.filter((c) => MET.indexOf(c.status) >= 0);
    return `<h1 class="rm-h1">After the summer</h1>
      <p class="rm-lede">A summer becomes a mentor only if someone keeps it going. Tier your relationships, then follow up with something real each time.</p>
      <div class="rm-card green"><h3 class="rm-h3">Before you leave</h3><ul style="margin:0 0 0 18px;padding:0">${['Can research continue? Agree one specific next task, a supervisor, the hours, and any training or approvals.', 'Will it be remote or at the lab? How will progress be reviewed?', 'Is there a presentation or poster opportunity?', 'Ask each person: may I send an occasional update, and how often?'].map((x) => `<li style="margin-bottom:4px">${esc(x)}</li>`).join('')}</ul></div>
      <div class="rm-card"><h3 class="rm-h3">Your follow-up dates</h3><div class="tablewrap"><table class="rm"><thead><tr><th>When</th><th>Date</th><th>What to send</th></tr></thead><tbody>
        <tr><td>30 days</td><td>${esc(due(30))}</td><td>A short update, no ask. State what you are doing now, how the conversation changed your thinking, and one next step.</td></tr>
        <tr><td>60 days</td><td>${esc(due(60))}</td><td>Only to the two or three who offered continued guidance. One focused question.</td></tr>
        <tr><td>90 days</td><td>${esc(due(90))}</td><td>For the strongest relationships: a milestone and one small, specific way to keep contributing.</td></tr></tbody></table></div>
        <p class="hint">Every message needs a real artifact or one specific question. Never &ldquo;just checking in.&rdquo; A letter of recommendation is earned by sustained work, not by summer meetings alone.</p></div>
      <h2 class="rm-h2">Your relationships</h2>
      ${met.length ? `<div class="tablewrap"><table class="rm"><thead><tr><th>Person</th><th>Tier</th><th></th></tr></thead><tbody>${met.map((c) => { const i = S.contacts.indexOf(c); return `<tr><td>${esc(c.name)} <span class="rm-muted">${esc(kindLabel(c.kind))}</span></td><td><select data-bind="contacts.${i}.tier" aria-label="Tier"><option value="">Choose</option><option value="1" ${c.tier === '1' ? 'selected' : ''}>1: active mentor</option><option value="2" ${c.tier === '2' ? 'selected' : ''}>2: warm contact</option><option value="3" ${c.tier === '3' ? 'selected' : ''}>3: network</option></select></td><td><button class="btn-s btn-sm" data-act="letterFor" data-id="${c.id}">Draft a letter</button></td></tr>`; }).join('')}</tbody></table></div>
      <p class="hint">Tier 1: monthly if you are actively collaborating. Tier 2: every 8 to 10 weeks at most. Tier 3: once or twice a year.</p>` : '<div class="rm-card"><p class="rm-muted" style="margin:0">People you have met will appear here.</p></div>'}`;
  }

  // ---------------- prep packet ----------------
  function packet(id) {
    const c = S.contacts.find((x) => x.id === id); if (!c) return;
    const qs = (Q[c.kind] || []).map((q) => `<li>${esc(q)}<div class="lines"></div></li>`).join('');
    $('#printSheet').innerHTML = `<h1>Meeting brief: ${esc(c.name || 'Name')}</h1><p>${esc(c.title || '')}${c.dept ? ', ' + esc(c.dept) : ''}<br>${c.confirmedDate ? '<b>' + esc(fmt(c.confirmedDate, { weekday: 'long', month: 'long', day: 'numeric', hour: 'numeric', minute: '2-digit' })) + '</b>' : '(date to be set)'} ${c.place ? '&middot; ' + esc(c.place) : ''}<br>Official page: ${esc(c.source || '(add it)')}</p>
      <h2>Why this meeting</h2><p>${esc(c.why || '')}</p><h2>My objective</h2><p>${esc(c.topic || '')}</p>
      <h2>Questions (ask the top four or five)</h2><ol>${qs}</ol>
      <h2>My 30-second introduction</h2><p>${esc(intro())}</p>
      <h2>Boundaries</h2><p>${esc(BOUND[c.kind] || '')}</p>
      <h2>After</h2><ul><li>Thank-you within 24 hours, naming two specific things they said.</li><li>One action I will take. Update the tracker.</li></ul><h2>Notes</h2><div class="lines"></div><div class="lines"></div><div class="lines"></div>`;
    window.print();
  }

  // ---------------- dictation (same as the other tools) ----------------
  const SR = window.SpeechRecognition || window.webkitSpeechRecognition; let rec = null, recBtn = null; const MIC = 'Speak instead of typing';
  function addMics() { $$('textarea[data-bind], textarea[data-letter]').forEach((ta) => { if (ta.dataset.mic) return; ta.dataset.mic = '1'; if (!ta.id) ta.id = 'ta' + Math.random().toString(36).slice(2, 7); const row = document.createElement('div'); row.className = 'rm-row'; row.style.margin = '4px 0 0'; if (SR) { row.innerHTML = `<button type="button" class="btn-s btn-sm" data-act="dictate">${MIC}</button><span class="hint"></span>`; row.firstChild.dataset.target = ta.id; } else row.innerHTML = '<span class="hint">To speak instead of typing, use the microphone key on your keyboard, or open this page in Chrome, Edge or Safari.</span>'; ta.insertAdjacentElement('afterend', row); }); }
  function dictate(btn) { const ta = document.getElementById(btn.dataset.target); const hint = btn.nextElementSibling; if (rec && recBtn === btn) { rec.stop(); return; } if (rec) { try { rec.stop(); } catch (e) { /* done */ } } rec = new SR(); recBtn = btn; rec.lang = 'en-US'; rec.continuous = true; rec.interimResults = false; rec.onresult = (ev) => { let t = ''; for (let i = ev.resultIndex; i < ev.results.length; i++) if (ev.results[i].isFinal) t += ev.results[i][0].transcript; if (!t) return; ta.value = (ta.value && !/\s$/.test(ta.value) ? ta.value + ' ' : ta.value) + t.trim(); ta.dispatchEvent(new Event('input', { bubbles: true })); }; rec.onerror = (ev) => { hint.textContent = ev.error === 'not-allowed' ? 'The microphone is blocked. Allow it in your browser settings.' : 'Could not hear you. Try again.'; }; rec.onend = () => { btn.textContent = MIC; if (/^Listening/.test(hint.textContent)) hint.textContent = ''; rec = null; recBtn = null; }; btn.textContent = 'Stop'; hint.textContent = 'Listening... speak, then press Stop.'; try { rec.start(); } catch (e) { hint.textContent = 'Could not start the microphone.'; } }

  // ---------------- events ----------------
  function copy(text, msg) { const ok = () => flash(msg || 'Copied'); const fb = () => { const t = document.createElement('textarea'); t.value = text; document.body.appendChild(t); t.select(); try { document.execCommand('copy'); ok(); } catch (e) { flash('Could not copy.', true); } document.body.removeChild(t); }; if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).then(ok, fb); else fb(); }
  function handleClick(e) {
    const b = e.target.closest('[data-act]'); if (!b) return;
    if (b.tagName === 'INPUT' && b.type === 'checkbox' && b.dataset.act !== 'toggleTask') return;
    const a = b.dataset.act, id = b.dataset.id, v = b.dataset.v;
    switch (a) {
      case 'go': go(v); break;
      case 'addContact': { const c = blankContact(v); S.contacts.push(c); ui.open = c.id; save(); render(); break; }
      case 'open': ui.open = ui.open === id ? null : id; if (view !== 'people') view = 'people'; render(); break;
      case 'removeContact': if (window.confirm('Remove this person from your list?')) { S.contacts = S.contacts.filter((c) => c.id !== id); save(); render(); } break;
      case 'toggleTask': S.done[id] = !S.done[id]; save(); break;
      case 'copyIntro': copy(intro(), 'Introduction copied'); break;
      case 'letterFor': ui.letterFor = id; ui.tpl = ''; ui.reason = ''; go('letters'); break;
      case 'packet': packet(id); break;
      case 'lOutlook': { const d = curDraft(); window.open(E.outlookCompose(d), '_blank', 'noopener'); break; }
      case 'lMail': { const d = curDraft(); window.location.href = E.mailto(d); break; }
      case 'lCopy': { const d = curDraft(); copy('To: ' + d.to + '\nSubject: ' + d.subject + '\n\n' + d.body, 'Letter copied'); break; }
      case 'lSent': { const d = curDraft(); const c = d.c; if (FIRST.indexOf(d.id) >= 0) { c.status = 'sent'; c.requestDate = today(); } else if (d.id === 'thanks') { c.status = 'thanked'; c.thanksSent = true; } else if (d.id === 'nudge') { c.nudged = true; c.status = 'awaiting'; } save(); ui.reason = ''; flash('Logged. The tracker will remind you.'); render(); break; }
      case 'backup': { const bl = new Blob([JSON.stringify(S, null, 2)], { type: 'application/json' }); const a2 = document.createElement('a'); a2.href = URL.createObjectURL(bl); a2.download = 'my-summer-plan-backup.json'; document.body.appendChild(a2); a2.click(); document.body.removeChild(a2); flash('Backup saved'); break; }
      case 'wipe': if (window.confirm('Erase everything you entered here on this device? This cannot be undone unless you saved a backup file.')) { try { localStorage.removeItem(KEY); } catch (er) { /* ignore */ } S = blank(); ui = { open: null, letterFor: '', tpl: '', reason: '', times: '' }; load(); render(); flash('Erased'); } break;
      case 'dictate': dictate(b); break;
      default: break;
    }
  }
  function handleInput(e) {
    const t = e.target;
    if (t.dataset && t.dataset.letter) {
      const k = t.dataset.letter;
      if (k === 'for') { ui.letterFor = t.value; ui.tpl = ''; render(); return; }
      if (k === 'tpl') { ui.tpl = t.value; render(); return; }
      if (k === 'times') ui.times = t.value; if (k === 'reason') ui.reason = t.value;
      const d = curDraft(); const pv = $('#lprev'); if (pv && d) pv.innerHTML = '<b>To:</b> ' + esc(d.to || '(add a public email, or use the office contact route)') + '\n<b>Subject:</b> ' + esc(d.subject) + '\n\n' + esc(d.body);
      const first = d && FIRST.indexOf(d.id) >= 0; const ok = sentenceOk(ui.reason) && (!first || canContact(d.c)); $$('[data-lneeds]').forEach((x) => { x.disabled = !ok; });
      return;
    }
    if (t.id === 'restore') return;
    const path = t.dataset && t.dataset.bind; if (!path) return;
    let val = t.value; if (t.type === 'checkbox') val = t.checked;
    setPath(S, path, val); save();
    if (t.dataset.rerender && e.type === 'change') render();
  }
  function handleRestore(e) { const f = e.target.files && e.target.files[0]; if (!f) return; const r = new FileReader(); r.onload = () => { try { const g = JSON.parse(String(r.result)); if (!g || g.v !== 1) throw new Error('bad'); localStorage.setItem(KEY, JSON.stringify(g)); load(); render(); flash('Restored from your backup'); } catch (er) { flash('That file is not a valid backup.', true); } }; r.readAsText(f); }

  function boot() {
    $('#who').textContent = session.displayName || session.email || '';
    $('#logout').addEventListener('click', () => { BIOS.clearSession(); window.location.href = '/BIOS102/index.html'; });
    load();
    const v = $('#view'); v.addEventListener('click', handleClick); v.addEventListener('input', handleInput); v.addEventListener('change', (ev) => { if (ev.target.id === 'restore') handleRestore(ev); else handleInput(ev); });
    $('#steps').addEventListener('click', handleClick);
    render();
  }
  boot();
})();
