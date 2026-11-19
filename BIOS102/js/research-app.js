// BIOS102 Research Match: the page. Requires a BIOS102 session (same sign-in as the
// rest of the Lab Companion). State is one object saved per student through
// bios102_rm_save (see supabase/bios102-research-match.sql), mirrored in
// localStorage so a flaky connection never loses work.
(function () {
  const D = window.RM_DATA;
  const E = window.RM_ENGINE;
  const esc = (s) => BIOS.escapeHtml(s);
  const session = BIOS.requireSession();
  if (!session) return;

  const $ = (sel, root) => (root || document).querySelector(sel);
  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));
  const F = Object.fromEntries(D.FACULTY.map((f) => [f.id, f]));
  const LS_KEY = 'rm_state_v1_' + String(session.email || '').toLowerCase();
  const MAX_LIST = 4;

  let S = blank();
  let view = 'home';
  let isInstructor = false;
  let ui = { open: {}, panel: {}, filter: '' };
  let saveTimer = null;

  function blank() {
    return { v: 1, stage: 'home', profileDone: false, answers: { ratings: {}, choices: {}, constraints: {}, free: {} }, shortlist: [], outreach: {}, matchTop: [], final: {}, _t: 0 };
  }

  // ---------- state helpers ----------
  function O(id) {
    if (!S.outreach[id]) S.outreach[id] = { status: 'none' };
    return S.outreach[id];
  }
  function setPath(obj, path, val) {
    const parts = path.split('.');
    let o = obj;
    for (let i = 0; i < parts.length - 1; i++) {
      if (typeof o[parts[i]] !== 'object' || o[parts[i]] === null) o[parts[i]] = {};
      o = o[parts[i]];
    }
    o[parts[parts.length - 1]] = val;
  }
  function getPath(obj, path) {
    return path.split('.').reduce((o, k) => (o == null ? undefined : o[k]), obj);
  }
  function student() {
    const k = S.answers.constraints || {};
    const stageMap = { first: 'a first-year student', second: 'a second-year student', third: 'a third-year or later student', undecided: 'still deciding on a major' };
    return { name: session.displayName || '', email: session.email || '', hours: k.hours, stage: stageMap[k.stage] || '' };
  }

  // ---------- saving ----------
  function flash(msg, err) {
    const el = $('#saved');
    el.textContent = msg;
    el.className = 'saved show' + (err ? ' err' : '');
    clearTimeout(flash.t);
    if (!err) flash.t = setTimeout(() => { el.className = 'saved'; }, 1400);
  }
  function save(now) {
    S._t = Date.now();
    try { localStorage.setItem(LS_KEY, JSON.stringify(S)); } catch (e) { /* private mode: server copy still works */ }
    clearTimeout(saveTimer);
    saveTimer = setTimeout(pushServer, now ? 0 : 900);
  }
  async function pushServer() {
    try {
      await window.sfSupabase.bios102RmSave(session.sessionToken, S);
      flash('Saved');
    } catch (e) {
      flash('Could not save to the server. Your work is kept on this device.', true);
    }
  }
  async function load() {
    let local = null;
    try { local = JSON.parse(localStorage.getItem(LS_KEY) || 'null'); } catch (e) { local = null; }
    let remote = null;
    try { remote = await window.sfSupabase.bios102RmLoad(session.sessionToken); } catch (e) { remote = null; }
    const pick = (remote && remote.v ? remote : null);
    if (pick && local && local._t > (pick._t || 0)) S = Object.assign(blank(), local);
    else if (pick) S = Object.assign(blank(), pick);
    else if (local) S = Object.assign(blank(), local);
    S.answers = Object.assign({ ratings: {}, choices: {}, constraints: {}, free: {} }, S.answers || {});
    if (local && pick && local._t > (pick._t || 0)) save(true);
    try { isInstructor = !!(await window.sfSupabase.bios102GradesIsInstructor(session.sessionToken)); } catch (e) { isInstructor = false; }
  }

  // ---------- navigation ----------
  const STEPS = [
    { id: 'home', label: 'Start', n: '' },
    { id: 'know', label: 'Know yourself', n: 1 },
    { id: 'matches', label: 'Your matches', n: 2 },
    { id: 'meet', label: 'The researchers', n: 3 },
    { id: 'interview', label: 'Interviews', n: 4 },
    { id: 'decide', label: 'Decide and ask', n: 5 },
  ];
  function stepDone(id) {
    const list = S.shortlist || [];
    const doneIv = list.some((i) => E.outreachOf(S, i).status === 'done');
    return { know: !!S.profileDone, matches: !!S.profileDone && list.length > 0, meet: list.length > 0,
      interview: doneIv, decide: !!(S.final && S.final.askSentAt) }[id] || false;
  }
  function go(v) {
    view = v;
    S.stage = v;
    render();
    window.scrollTo(0, 0);
  }
  function renderSteps() {
    const steps = STEPS.slice();
    if (isInstructor) steps.push({ id: 'class', label: 'Class view', n: '' });
    $('#steps').innerHTML = steps.map((s) => `<li><button type="button" data-act="go" data-v="${s.id}" class="${stepDone(s.id) ? 'done' : ''}" ${view === s.id ? 'aria-current="step"' : ''}>${s.n ? `<span class="n">${stepDone(s.id) ? '&#10003;' : s.n}</span>` : ''}${esc(s.label)}</button></li>`).join('');
  }

  // ---------- views ----------
  function render() {
    const fn = { home: vHome, know: vKnow, matches: vMatches, meet: vMeet, interview: vInterview, decide: vDecide, class: vClass }[view] || vHome;
    renderSteps();
    const out = fn();
    if (typeof out === 'string') { $('#view').innerHTML = out; if (view === 'know') refreshKnow(); }
    else out.then((h) => { $('#view').innerHTML = h; });
  }

  // --- Home ---
  function vHome() {
    const next = E.nextActions(S)[0];
    const first = esc((session.displayName || '').split(' ')[0] || 'there');
    const steps = [
      ['know', '1', 'Know yourself', 'Rate 14 real research activities and answer a few quick questions. About 8 minutes. Nothing here is graded.'],
      ['matches', '2', 'See your matches', 'The researchers whose work fits what you told us, with the reasons shown, so you can argue with them.'],
      ['interview', '4', 'Set up your own interviews', 'You write the email, you send it, you ask the questions. We give you the drafts, the question bank and a prep sheet.'],
      ['decide', '5', 'Decide and ask', 'Compare what you learned and ask for a place in the lab that fits. Includes the real programs that can pay you or give you credit.'],
    ];
    return `
      <h1 class="rm-h1">Hi ${first}. Let&rsquo;s find the research that fits you.</h1>
      <p class="rm-lede">UW&ndash;Parkside&rsquo;s biology faculty run real labs and field projects, and the department openly invites students to schedule an appointment with any of them to talk about research. This page walks you through doing exactly that: figure out what you care about, see who studies it, then set up and run your own interviews.</p>
      ${next ? `<div class="rm-card green"><div class="rm-spread"><div><div class="band s1">Your next step</div><p style="margin:4px 0 0;font-size:18px">${esc(next.text)}</p></div><button class="btn-p" data-act="go" data-v="${next.stage === 'debrief' ? 'decide' : next.stage === 'know' ? 'know' : next.stage}">Go</button></div></div>` : ''}
      <div class="rm-grid">
        ${steps.map(([id, n, t, d]) => `<div class="rm-card" style="margin:0"><div class="rm-row"><span class="rank">${n}</span><h3 class="rm-h3" style="margin:0">${t}</h3>${stepDone(id) ? '<span class="chip g">done</span>' : ''}</div><p style="margin:8px 0 12px" class="rm-muted">${d}</p><button class="btn-s btn-sm" data-act="go" data-v="${id}">${stepDone(id) ? 'Review' : 'Open'}</button></div>`).join('')}
      </div>
      <h2 class="rm-h2">Ground rules</h2>
      <div class="rm-card tint">
        <ul style="margin:0 0 0 18px;padding:0">
          <li><strong>You are asking for a conversation, not a job.</strong> Twenty minutes to hear about their work. That is what the department invites.</li>
          <li><strong>You write and send every email yourself</strong>, from your Rangers account. This site never emails a professor for you.</li>
          <li><strong>Be specific.</strong> Each draft makes you add one sentence about their actual work. Generic emails get ignored.</li>
          <li><strong>Talk to two or three people, not all of them.</strong> Faculty are busy and your classmates are doing this too. The page stops you at ${MAX_LIST}.</li>
          <li><strong>A no, or no reply, is normal.</strong> It is about their time, not your worth. The tracker tells you when to follow up once and when to move on.</li>
        </ul>
      </div>
      <p class="rm-muted">Stuck? Your instructor, ${esc(D.DEPT.instructor.name)} (<a href="mailto:${D.DEPT.instructor.email}">${D.DEPT.instructor.email}</a>), is the right person to ask how to get started. Department office: ${esc(D.DEPT.office)}.</p>`;
  }

  // --- Know yourself ---
  function ratingLabel(v) { return ['', 'No thanks', 'Meh', 'Maybe', 'Sounds good', 'Love it'][v]; }
  function vKnow() {
    const a = S.answers;
    const rated = E.answeredCount(a);
    const cards = D.CARDS.map((c, i) => {
      const cur = Number(a.ratings[c.id]) || 0;
      return `<div class="card-q" data-card="${c.id}"><p><span class="rm-muted">${i + 1} of ${D.CARDS.length}</span><br>${esc(c.text)}</p>
        <div class="scale" role="group" aria-label="${esc(c.text)}">${[1, 2, 3, 4, 5].map((v) => `<button type="button" data-act="rate" data-id="${c.id}" data-v="${v}" aria-pressed="${cur === v}"><b>${v}</b>${ratingLabel(v)}</button>`).join('')}</div></div>`;
    }).join('');
    const radio = (path, opts, cur) => opts.map(([v, label]) => `<label class="opt ${cur === v ? 'on' : ''}"><input type="radio" name="${path}" data-bind="${path}" value="${esc(v)}" ${cur === v ? 'checked' : ''}> ${esc(label)}</label>`).join('');
    const choices = D.CHOICES.map((q) => `<div class="rm-card"><h3 class="rm-h3">${esc(q.text)}</h3>${radio('answers.choices.' + q.id, q.options.map((o) => [o.v, o.label]), a.choices[q.id])}</div>`).join('');
    const K = D.CONSTRAINTS;
    const cons = Object.entries(K).map(([id, q]) => `<div class="rm-card"><h3 class="rm-h3">${esc(q.text)}</h3>${radio('answers.constraints.' + id, q.options, (a.constraints || {})[id])}</div>`).join('');
    const free = D.FREE.map((q) => `<div class="rm-card"><label class="f" for="free-${q.id}" style="margin-top:0">${esc(q.text)} <span class="rm-muted">(optional, but it makes your emails better)</span></label><textarea id="free-${q.id}" data-bind="answers.free.${q.id}" placeholder="${esc(q.hint)}">${esc((a.free || {})[q.id] || '')}</textarea></div>`).join('');
    return `
      <h1 class="rm-h1">Know yourself first</h1>
      <p class="rm-lede">Rate each activity from 1 to 5 by how much you would want to spend a week doing it. Go with your gut. You are not choosing a career, only finding where to start talking to people.</p>
      <div class="progress"><div class="rm-muted" id="know-count">${rated} of ${D.CARDS.length} rated</div><div class="bar"><i id="know-bar" style="width:${Math.round(rated / D.CARDS.length * 100)}%"></i></div></div>
      ${cards}
      <h2 class="rm-h2">A few quick questions</h2>
      ${choices}${cons}
      <h2 class="rm-h2">In your own words</h2>
      ${free}
      <div class="rm-card green"><div class="rm-spread"><div><strong id="know-status"></strong><div class="rm-muted">Your answers save as you go. You can come back and change them any time.</div></div><button class="btn-p" id="know-done" data-act="finishKnow">See my matches</button></div></div>`;
  }
  function refreshKnow() {
    const a = S.answers;
    const rated = E.answeredCount(a);
    const cnt = $('#know-count'); if (!cnt) return;
    cnt.textContent = rated + ' of ' + D.CARDS.length + ' rated';
    $('#know-bar').style.width = Math.round(rated / D.CARDS.length * 100) + '%';
    const ok = E.profileComplete(a);
    $('#know-done').disabled = !ok;
    $('#know-status').textContent = ok ? 'Ready. Your matches are waiting.' : 'Finish all the cards and the multiple-choice questions to see your matches.';
    $$('label.opt').forEach((l) => { const r = $('input', l); l.classList.toggle('on', !!(r && r.checked)); });
  }

  // --- Matches ---
  function matchesNow() { return E.matchAll(S.answers); }
  function vMatches() {
    if (!S.profileDone) {
      return `<h1 class="rm-h1">Your matches</h1><div class="rm-card warn"><p style="margin:0 0 12px">Answer the interest cards first. The match is built from your answers.</p><button class="btn-p" data-act="go" data-v="know">Start with the cards</button></div>`;
    }
    const m = matchesNow();
    const ids = m.map((x) => x.f.id);
    if (JSON.stringify(ids) !== JSON.stringify(S.matchTop || [])) { S.matchTop = ids; save(); }
    const fp = E.fingerprint(S.answers, 5);
    const bandCls = (b) => (b === 'Strongest match' ? 's1' : b === 'Strong match' ? 's2' : b === 'Worth a conversation' ? 's3' : 's4');
    const rows = m.map((x) => {
      const f = x.f; const on = S.shortlist.indexOf(f.id) >= 0;
      return `<div class="fac" style="margin-bottom:14px"><div class="rm-spread"><div class="rm-row"><span class="rank">${x.rank}</span><div><div class="band ${bandCls(x.band)}">${esc(x.band)}</div><h3>${esc(f.honorific)} ${esc(f.name)}</h3><div class="t">${esc(f.title)}</div></div></div>
        <button class="btn-${on ? 's' : 'p'} btn-sm" data-act="toggleList" data-id="${f.id}">${on ? 'On my interview list ✓' : 'Add to my interview list'}</button></div>
        <div class="bar" title="Relative to your best match"><i style="width:${Math.round(x.rel * 100)}%"></i></div>
        <p class="one">${esc(f.oneLine)}</p>
        ${x.reasons.length && x.band !== 'Less likely a fit' ? `<div><strong>Why it fits you</strong><ul class="why" style="margin:4px 0 4px 18px;padding:0">${x.reasons.map((r) => `<li>You liked: ${esc(r)}</li>`).join('')}</ul></div>` : ''}
        ${x.cautions.map((c) => `<div class="caution">&#9888; ${esc(c)}</div>`).join('')}
        <div>${evidenceChips(f)}</div>
        <div><button class="btn-t" data-act="openFac" data-id="${f.id}">${ui.open[f.id] ? 'Hide details' : 'What would I actually do? Read more'}</button></div>
        ${ui.open[f.id] ? facDetail(f) : ''}</div>`;
    }).join('');
    return `
      <h1 class="rm-h1">Your matches</h1>
      <p class="rm-lede">These are conversation starters, not verdicts. The point of an interview is to find out whether the day-to-day work suits you.</p>
      <div class="rm-card tint"><strong>What you told us pulls you toward:</strong> ${fp.length ? fp.map((t) => `<span class="chip b">${esc(t)}</span>`).join('') : '<span class="rm-muted">Not enough strong preferences yet. Try rating a few cards 1 or 5.</span>'}
        <div style="margin-top:6px"><button class="btn-t" data-act="go" data-v="know">Change my answers</button></div></div>
      <details class="rm-card"><summary><strong>How is this calculated?</strong></summary>
        <p>Each card you rated becomes a vote: a 5 adds a lot of weight to the topics that card touches, a 1 subtracts. Every professor has a profile of what their work involves (for example outdoors, bench work, animals, data), built only from their own faculty page and the student projects they have supervised. Your match is how well your votes line up with theirs. If you said you would rather not work with live animals, or cannot travel, the labs that involve those are pushed down and flagged. Labs with a record of supervising student projects get a small nudge that only breaks near-ties. The bar compares each professor to your best match, so it is not a percentage of anything. Different answers give different results, so retake the cards if a result surprises you.</p></details>
      ${rows}
      <div class="rm-card"><strong>Also on the Biological Sciences directory</strong>
        <p class="rm-muted">Instructors and lecturers without a research program, who are still good people to ask for advice.</p>
        ${D.OTHERS.map((o) => `<p style="margin:0 0 8px"><strong>${esc(o.name)}</strong> (${esc(o.role)}). ${esc(o.note)} <a href="${o.profile}" target="_blank" rel="noopener">Profile</a></p>`).join('')}</div>
      ${(S.shortlist || []).length ? `<div class="rm-card green rm-spread"><div><strong>${S.shortlist.length} on your interview list.</strong> <span class="rm-muted">Two or three is the sweet spot.</span></div><button class="btn-p" data-act="go" data-v="interview">Set up my interviews</button></div>` : ''}`;
  }

  function evidenceChips(f) {
    const lvl = { strong: ['Strong record of mentoring students', 'g'], good: ['Has mentored students', 'g'], some: ['Some student projects listed', 'b'], few: ['One student project listed', 'w'], pathway: ['Starts through a class project', 'b'] }[f.mentorship.level];
    return `<span class="chip ${lvl[1]}">${lvl[0]}</span>` + (f.animals ? '<span class="chip w">Works with live animals</span>' : '') + (f.outdoors ? '<span class="chip b">Outdoor fieldwork</span>' : '') + (f.summerTravel ? '<span class="chip w">Summer travel</span>' : '') + (f.unverifiedNote ? '<span class="chip w">Profile is thin: confirm in your interview</span>' : '');
  }

  function facDetail(f) {
    return `<div class="detail">
      <h4>What they study</h4><p>${esc(f.plain)}</p>
      <h4>What a student might do</h4><p>${esc(f.day)}</p>
      ${f.projects.length ? `<h4>Recent student projects they supervised</h4><ul>${f.projects.map((p) => `<li><span class="rm-muted">${esc(p[0])}:</span> ${esc(p[1])}</li>`).join('')}</ul>` : ''}
      <h4>Mentoring record</h4><p>${esc(f.mentorship.note)}</p>
      <h4>Read this before you write</h4><p>${esc(f.readFirst)}</p>
      <h4>Good questions for them</h4><ul>${f.ask.map((q) => `<li>${esc(q)}</li>`).join('')}</ul>
      ${f.unverifiedNote ? `<p class="caution">${esc(f.unverifiedNote)}</p>` : ''}
      <p class="rm-muted">Contact: <a href="mailto:${f.email}">${f.email}</a> &middot; ${esc(f.phone)} &middot; <a href="${f.profile}" target="_blank" rel="noopener">Official profile</a>${f.website ? ` &middot; <a href="${esc(f.website)}" target="_blank" rel="noopener">Website</a>` : ''}</p></div>`;
  }

  // --- Researchers (browse) ---
  const FILTERS = [['', 'Everyone'], ['field', 'Outdoors'], ['wetlab', 'Lab bench'], ['computing', 'Data and code'], ['animals', 'Animals'], ['plants', 'Plants and algae'], ['microbes', 'Microbes'], ['ecology', 'Ecology'], ['evolution', 'Evolution'], ['health', 'Health']];
  function vMeet() {
    const list = D.FACULTY.filter((f) => !ui.filter || (f.tags[ui.filter] || 0) >= 2);
    const cards = list.map((f) => {
      const on = S.shortlist.indexOf(f.id) >= 0;
      return `<div class="fac"><h3>${esc(f.honorific)} ${esc(f.name)}</h3><div class="t">${esc(f.title)}</div><p class="one">${esc(f.oneLine)}</p>
        <div>${f.areas.slice(0, 3).map((a) => `<span class="chip">${esc(a)}</span>`).join('')}</div><div>${evidenceChips(f)}</div>
        <div class="rm-row"><button class="btn-s btn-sm" data-act="openFac" data-id="${f.id}">${ui.open[f.id] ? 'Hide' : 'Read more'}</button><button class="btn-${on ? 's' : 'p'} btn-sm" data-act="toggleList" data-id="${f.id}">${on ? 'On my list ✓' : 'Add to my list'}</button></div>
        ${ui.open[f.id] ? facDetail(f) : ''}</div>`;
    }).join('');
    const opps = D.OPPORTUNITIES.map((o) => `<div class="rm-card"><div class="rm-row"><h3 class="rm-h3" style="margin:0">${esc(o.name)}</h3>${o.verified ? '<span class="chip g">checked on uwp.edu</span>' : '<span class="chip w">not confirmed: ask</span>'}</div>
      <p>${esc(o.what)}</p><p><strong>Who:</strong> ${esc(o.who)}</p><p><strong>Next step:</strong> ${esc(o.next)}</p>${o.url ? `<a href="${o.url}" target="_blank" rel="noopener">Official page</a>` : ''}</div>`).join('');
    return `
      <h1 class="rm-h1">The researchers</h1>
      <p class="rm-lede">Everyone below is on the official Biological Sciences directory and has either a research program or a record of supervising student projects. Descriptions restate their own faculty pages in plain English. Checked ${esc(D.CHECKED)}.</p>
      <div class="rm-row" style="margin-bottom:14px" role="group" aria-label="Filter">${FILTERS.map(([v, l]) => `<button type="button" class="chip ${ui.filter === v ? 'on' : ''}" data-act="filter" data-v="${v}">${esc(l)}</button>`).join('')}</div>
      <div class="rm-grid">${cards}</div>
      <h2 class="rm-h2">Real ways to get involved</h2>
      <p class="rm-muted">Pulled from the department pages. Ask your mentor which one applies to you.</p>
      ${opps}`;
  }

  // --- Interviews ---
  const TRACK = [['none', 'Not started'], ['drafted', 'Drafted'], ['sent', 'Sent'], ['scheduled', 'Scheduled'], ['done', 'Done']];
  function trackBar(status) {
    const idx = Math.max(0, TRACK.findIndex((t) => t[0] === status));
    if (status === 'declined' || status === 'noreply') return `<div class="track"><span class="on" style="background:var(--ink-2)">${esc(E.STATUS[status])}</span></div>`;
    return `<div class="track">${TRACK.map((t, i) => `<span class="${i < idx ? 'past' : i === idx ? 'on' : ''}">${t[1]}</span>`).join('')}</div>`;
  }
  function sentenceHint(f) {
    const p = f.projects[0];
    return p ? `Mention one specific thing. For example: "I saw that a student studied ${p[1].replace(/\s*\(MS\)$/, '')}, and I would love to understand how that kind of work is done." Use your own words.`
      : `Mention one specific thing from their profile, and say why it caught your attention. Use your own words.`;
  }
  function vInterview() {
    if (!S.profileDone || !(S.shortlist || []).length) {
      return `<h1 class="rm-h1">Interviews</h1><div class="rm-card warn"><p style="margin:0 0 12px">${S.profileDone ? 'Choose two or three professors first.' : 'Finish the interest cards and pick who you want to talk to.'}</p><button class="btn-p" data-act="go" data-v="${S.profileDone ? 'matches' : 'know'}">${S.profileDone ? 'See my matches' : 'Start with the cards'}</button></div>`;
    }
    const cards = S.shortlist.map((id) => interviewCard(F[id])).join('');
    return `
      <h1 class="rm-h1">Set up your interviews</h1>
      <p class="rm-lede">You are asking each professor for 20 minutes. You write the email, you send it from your Rangers account, you run the conversation. Each card below walks you through one professor.</p>
      <details class="rm-card tint"><summary><strong>Email etiquette (read this once)</strong></summary><ul style="margin:8px 0 0 18px;padding:0">
        <li>Send from your @rangers.uwp.edu address and sign with your full name.</li>
        <li>Keep it short. One specific sentence about their work beats a paragraph of flattery.</li>
        <li>Offer two or three time windows, and say you can work around office hours.</li>
        <li>Wait a week, then send one polite follow-up. Then move on. Visiting office hours in person also works.</li>
        <li>Show up on time, with your questions. Thank them by email within 24 hours.</li>
        <li>Do not email several professors in the same lab group, and do not ask for a position in the first message.</li></ul></details>
      ${cards}
      <div class="rm-card green rm-spread"><div><strong>Done with an interview?</strong> <span class="rm-muted">Write it up while it is fresh.</span></div><button class="btn-p" data-act="go" data-v="decide">Debrief and decide</button></div>`;
  }

  function draftFor(id) {
    const f = F[id], o = O(id);
    return E.interviewRequest(student(), f, { customLine: o.customLine, times: o.times, stage: student().stage });
  }
  function interviewCard(f) {
    const o = O(f.id);
    const panel = ui.panel[f.id] || null;
    const d = E.daysSince(o.sentAt);
    const canFollow = o.status === 'sent' && d !== null && d >= 7;
    let body = '';
    if (panel === 'email') {
      const ok = (o.customLine || '').trim().length >= 25;
      const draft = draftFor(f.id);
      body = `<div class="detail"><h4>Your interview request</h4>
        <label class="f" for="cl-${f.id}">Your own sentence (required)</label>
        <textarea id="cl-${f.id}" data-bind="outreach.${f.id}.customLine" data-live="${f.id}">${esc(o.customLine || '')}</textarea><p class="hint">${esc(sentenceHint(f))}</p>
        <label class="f" for="tm-${f.id}">When you are free</label>
        <input type="text" id="tm-${f.id}" data-bind="outreach.${f.id}.times" data-live="${f.id}" value="${esc(o.times || '')}" placeholder="for example: Tuesdays after 2 pm or Thursdays before noon" />
        <p class="hint">Read their profile first: <a href="${f.profile}" target="_blank" rel="noopener">${esc(f.honorific + ' ' + f.last)}</a>. ${esc(f.readFirst)}</p>
        <label class="f">Preview</label><div class="preview" id="prev-${f.id}"><b>To:</b> ${esc(draft.to)}\n<b>Subject:</b> ${esc(draft.subject)}\n\n${esc(draft.body)}</div>
        <p class="need" id="need-${f.id}" ${ok ? 'hidden' : ''}>Write your own sentence (at least a full sentence) to unlock the buttons.</p>
        <div class="rm-row"><button class="btn-p" data-act="mailDraft" data-id="${f.id}" ${ok ? '' : 'disabled'} data-needs="${f.id}">Open in my email app</button>
        <button class="btn-s" data-act="copyDraft" data-id="${f.id}" ${ok ? '' : 'disabled'} data-needs="${f.id}">Copy the email</button>
        <button class="btn-s" data-act="markSent" data-id="${f.id}" ${ok ? '' : 'disabled'} data-needs="${f.id}">I sent it</button></div>
        <p class="hint">Your email app opens with the message ready. Check that it is going from your Rangers address, then press send there. Come back and tap &ldquo;I sent it.&rdquo;</p></div>`;
    } else if (panel === 'follow') {
      const fu = E.followUp(student(), f, o);
      body = `<div class="detail"><h4>One polite follow-up</h4><div class="preview"><b>To:</b> ${esc(fu.to)}\n<b>Subject:</b> ${esc(fu.subject)}\n\n${esc(fu.body)}</div>
        <div class="rm-row"><button class="btn-p" data-act="mailFollow" data-id="${f.id}">Open in my email app</button><button class="btn-s" data-act="copyFollow" data-id="${f.id}">Copy it</button><button class="btn-s" data-act="setStatus" data-id="${f.id}" data-v="noreply">No reply, I am moving on</button></div>
        <p class="hint">Visiting their office hours in person is a good second try. After one follow-up, move on to someone else on your list.</p></div>`;
    } else if (panel === 'schedule') {
      body = `<div class="detail"><h4>They said yes</h4>
        <label class="f" for="dt-${f.id}">Date and time</label><input type="datetime-local" id="dt-${f.id}" data-bind="outreach.${f.id}.interviewDate" value="${esc(o.interviewDate || '')}" />
        <label class="f" for="pl-${f.id}">Where (office, room or video link)</label><input type="text" id="pl-${f.id}" data-bind="outreach.${f.id}.place" value="${esc(o.place || '')}" placeholder="for example: Greenquist 3xx, or the Zoom link they sent" />
        <div class="rm-row" style="margin-top:12px"><button class="btn-p" data-act="confirmSchedule" data-id="${f.id}">Save the interview</button><button class="btn-s" data-act="setStatus" data-id="${f.id}" data-v="declined">They said not now</button></div></div>`;
    } else if (panel === 'prep') {
      const picked = new Set(o.questions || []);
      const qcheck = (q) => `<label class="q-item"><input type="checkbox" data-act="pickQ" data-id="${f.id}" data-q="${esc(q)}" ${picked.has(q) ? 'checked' : ''}> <span>${esc(q)}</span></label>`;
      body = `<div class="detail"><h4>Pick the questions you will bring (about 8)</h4><p class="hint">Start with the ones written for ${esc(f.honorific + ' ' + f.last)}, then add from the bank. Questions you can answer by reading their page are wasted minutes.</p>
        <div class="q-cat">Specific to ${esc(f.last)}</div>${f.ask.map(qcheck).join('')}
        ${D.QUESTIONS.map((g) => `<div class="q-cat">${esc(g.cat)}</div>${g.items.map(qcheck).join('')}`).join('')}
        <label class="f" for="oq-${f.id}">Your own questions</label><textarea id="oq-${f.id}" data-bind="outreach.${f.id}.ownQ" placeholder="Anything you really want to know">${esc(o.ownQ || '')}</textarea>
        <div class="rm-row" style="margin-top:12px"><button class="btn-p" data-act="printPrep" data-id="${f.id}">Print my prep sheet</button><span class="rm-muted" id="qcount-${f.id}">${picked.size} picked</span></div></div>`;
    }
    const acts = [];
    if (o.status === 'none' || o.status === 'drafted') acts.push(`<button class="btn-p btn-sm" data-act="panel" data-id="${f.id}" data-v="email">${panel === 'email' ? 'Hide the draft' : 'Draft my email'}</button>`);
    if (o.status === 'sent') {
      acts.push(`<button class="btn-p btn-sm" data-act="panel" data-id="${f.id}" data-v="schedule">They replied: schedule it</button>`);
      acts.push(`<button class="btn-s btn-sm" data-act="panel" data-id="${f.id}" data-v="follow">${canFollow ? 'Send the follow-up' : 'Follow-up draft'}</button>`);
      acts.push(`<button class="btn-t" data-act="panel" data-id="${f.id}" data-v="email">View my email</button>`);
    }
    if (o.status === 'scheduled') {
      acts.push(`<button class="btn-p btn-sm" data-act="panel" data-id="${f.id}" data-v="prep">Prep sheet and questions</button>`);
      acts.push(`<button class="btn-s btn-sm" data-act="ics" data-id="${f.id}">Add to my calendar</button>`);
      acts.push(`<button class="btn-s btn-sm" data-act="setStatus" data-id="${f.id}" data-v="done">Interview done</button>`);
      acts.push(`<button class="btn-t" data-act="panel" data-id="${f.id}" data-v="schedule">Change time</button>`);
    }
    if (o.status === 'done') acts.push(`<button class="btn-p btn-sm" data-act="go" data-v="decide">Write my debrief</button>`);
    if (o.status === 'declined' || o.status === 'noreply') acts.push(`<button class="btn-s btn-sm" data-act="setStatus" data-id="${f.id}" data-v="none">Try again</button>`);
    const removable = ['none', 'drafted', 'declined', 'noreply'].indexOf(o.status) >= 0;
    return `<div class="rm-card" id="iv-${f.id}"><div class="rm-spread"><div><h3 class="rm-h3" style="font-size:19px;color:var(--green)">${esc(f.honorific)} ${esc(f.name)}</h3><div class="rm-muted">${esc(f.title)}</div></div>${removable ? `<button class="btn-t" data-act="toggleList" data-id="${f.id}">Remove from my list</button>` : ''}</div>
      ${trackBar(o.status)}
      ${o.status === 'scheduled' && o.interviewDate ? `<p><strong>${esc(E.fmtDateTime(o.interviewDate))}</strong>${o.place ? ' &middot; ' + esc(o.place) : ''}</p>` : ''}
      ${canFollow ? `<div class="caution">&#9888; Sent ${d} days ago with no reply. Time for one follow-up.</div>` : ''}
      <div class="rm-row">${acts.join('')}</div>${body}</div>`;
  }

  // --- Decide ---
  const FIT = [['science', 'The science excites me'], ['culture', 'I liked the lab’s vibe and the people'], ['mentor', 'They would be a good mentor for me'], ['fit', 'The time and logistics work for me'], ['dayone', 'I can picture myself doing the first-month work']];
  function overallFit(o) {
    const f = o.fit || {};
    const v = FIT.map(([k]) => Number(f[k]) || 0).filter(Boolean);
    return v.length === FIT.length ? Math.round(v.reduce((a, b) => a + b, 0) / v.length * 10) / 10 : 0;
  }
  function vDecide() {
    const done = S.shortlist.filter((id) => E.outreachOf(S, id).status === 'done');
    if (!done.length) {
      return `<h1 class="rm-h1">Decide and ask</h1><div class="rm-card warn"><p style="margin:0 0 12px">This opens after your first interview. Until then, use your time on the interviews, or read about the programs that can fund or credit research.</p><button class="btn-p" data-act="go" data-v="interview">Back to my interviews</button> <button class="btn-s" data-act="go" data-v="meet">Ways to get involved</button></div>`;
    }
    const debrief = done.map((id) => {
      const f = F[id], o = O(id);
      const ty = E.thankYou(student(), f, o);
      return `<div class="rm-card"><h3 class="rm-h3" style="font-size:19px;color:var(--green)">${esc(f.honorific)} ${esc(f.name)}</h3>
        <p class="rm-muted">Rate each from 1 (not at all) to 5 (completely) while the conversation is fresh.</p>
        ${FIT.map(([k, label]) => `<label class="f" for="ft-${id}-${k}">${esc(label)}</label><select id="ft-${id}-${k}" data-bind="outreach.${id}.fit.${k}" data-fit="${id}"><option value="">Choose</option>${[1, 2, 3, 4, 5].map((n) => `<option value="${n}" ${Number((o.fit || {})[k]) === n ? 'selected' : ''}>${n}</option>`).join('')}</select>`).join('')}
        <label class="f" for="n1-${id}">What would a typical week for a student look like?</label><textarea id="n1-${id}" data-bind="outreach.${id}.notes.week">${esc((o.notes || {}).week || '')}</textarea>
        <label class="f" for="n2-${id}">What would they have me do first, and what do they expect (hours, courses, timing)?</label><textarea id="n2-${id}" data-bind="outreach.${id}.notes.expect">${esc((o.notes || {}).expect || '')}</textarea>
        <label class="f" for="n3-${id}">One thing you learned or found interesting</label><textarea id="n3-${id}" data-bind="outreach.${id}.notes.learned">${esc((o.notes || {}).learned || '')}</textarea>
        <label class="f" for="n4-${id}">The next step they suggested</label><input type="text" id="n4-${id}" data-bind="outreach.${id}.notes.nextStep" value="${esc((o.notes || {}).nextStep || '')}" />
        <label class="f">After this conversation, would you want to work with them?</label>
        ${[['yes', 'Yes'], ['maybe', 'Maybe'], ['no', 'No']].map(([v, l]) => `<label class="opt ${o.would === v ? 'on' : ''}"><input type="radio" name="w-${id}" data-bind="outreach.${id}.would" value="${v}" ${o.would === v ? 'checked' : ''}> ${l}</label>`).join('')}
        <h4 style="margin:16px 0 4px;color:var(--green)">Thank-you note (send within 24 hours)</h4>
        <div class="preview" id="ty-${id}"><b>To:</b> ${esc(ty.to)}\n<b>Subject:</b> ${esc(ty.subject)}\n\n${esc(ty.body)}</div>
        <div class="rm-row"><button class="btn-p btn-sm" data-act="mailThanks" data-id="${id}">Open in my email app</button><button class="btn-s btn-sm" data-act="copyThanks" data-id="${id}">Copy it</button>${o.thanked ? '<span class="chip g">thank-you sent</span>' : `<button class="btn-s btn-sm" data-act="markThanked" data-id="${id}">I sent it</button>`}</div></div>`;
    }).join('');

    const m = matchesNow();
    const rank = E.finalRanking(S, m);
    const fin = S.final || {};
    const table = `<div class="tablewrap"><table class="rm"><thead><tr><th>Professor</th><th>Match before</th><th>Interview rating</th><th>Would you go?</th><th>Combined</th><th>My first choice</th></tr></thead><tbody>${rank.map((r) => `<tr><td>${esc(r.f ? r.f.honorific + ' ' + r.f.last : r.id)}</td><td>${Math.round(r.pre * 100)}</td><td>${r.post === null ? '<span class="rm-muted">not rated</span>' : (r.post * 5).toFixed(1) + ' / 5'}</td><td>${esc(r.would || '')}</td><td><strong>${Math.round(r.score * 100)}</strong></td><td><input type="radio" name="firstchoice" data-bind="final.faculty" value="${r.id}" ${fin.faculty === r.id ? 'checked' : ''} aria-label="First choice ${esc(r.f ? r.f.last : r.id)}"></td></tr>`).join('')}</tbody></table></div>
      <p class="rm-muted">Combined = 30% how well they matched your interests before + 70% how the interview actually felt (50% of the match score until you have rated an interview). The number is a nudge for your own thinking. If your gut disagrees with it, listen to your gut and find out why.</p>`;
    let ask = '';
    if (fin.faculty && F[fin.faculty]) {
      const f = F[fin.faculty];
      const pathName = (D.OPPORTUNITIES.find((x) => x.id === fin.path) || {}).name || '';
      const draft = E.askEmail(student(), f, { askWhy: fin.askWhy, askStart: fin.askStart }, pathName);
      ask = `<h2 class="rm-h2">Ask ${esc(f.honorific + ' ' + f.last)}</h2>
        <div class="rm-card"><label class="f" for="path" style="margin-top:0">Which route will you ask about?</label>
        <select id="path" data-bind="final.path" data-redraft="1"><option value="">I will ask them what the options are</option>${D.OPPORTUNITIES.filter((x) => ['thomson', 'indep', 'mbb'].indexOf(x.id) >= 0).map((x) => `<option value="${x.id}" ${fin.path === x.id ? 'selected' : ''}>${esc(x.name)}</option>`).join('')}</select>
        <label class="f" for="aw">Why this lab, in your own words (required)</label><textarea id="aw" data-bind="final.askWhy" data-redraft="1">${esc(fin.askWhy || '')}</textarea>
        <label class="f" for="as">When you could start</label><input type="text" id="as" data-bind="final.askStart" data-redraft="1" value="${esc(fin.askStart || '')}" placeholder="for example: next spring semester" />
        <label class="f">Preview</label><div class="preview" id="ask-prev"><b>To:</b> ${esc(draft.to)}\n<b>Subject:</b> ${esc(draft.subject)}\n\n${esc(draft.body)}</div>
        <p class="need" id="ask-need" ${(fin.askWhy || '').trim().length >= 25 ? 'hidden' : ''}>Write your own reason (at least a sentence) to unlock the buttons.</p>
        <div class="rm-row"><button class="btn-p" data-act="mailAsk" ${(fin.askWhy || '').trim().length >= 25 ? '' : 'disabled'} data-needs="ask">Open in my email app</button><button class="btn-s" data-act="copyAsk" ${(fin.askWhy || '').trim().length >= 25 ? '' : 'disabled'} data-needs="ask">Copy it</button>${fin.askSentAt ? '<span class="chip g">sent</span>' : `<button class="btn-s" data-act="markAsk" ${(fin.askWhy || '').trim().length >= 25 ? '' : 'disabled'} data-needs="ask">I sent it</button>`}</div></div>
        <h2 class="rm-h2">Your next 30 days</h2>${planHtml()}
        <div class="rm-card green rm-spread"><div><strong>Want this plan in your inbox?</strong><div class="rm-muted">We email it only to your own roster address.</div></div><div class="rm-row"><button class="btn-p" data-act="emailPlan" id="emailPlanBtn">Email me my plan</button><button class="btn-s" data-act="printPlan">Print it</button></div></div>`;
    }
    return `
      <h1 class="rm-h1">Decide and ask</h1>
      <p class="rm-lede">Write up each interview, compare them honestly, and choose where to ask for a place.</p>
      <h2 class="rm-h2">Debrief</h2>${debrief}
      <h2 class="rm-h2">Compare</h2>${table}
      ${ask}
      <h2 class="rm-h2">Money, credit and programs</h2>
      ${D.OPPORTUNITIES.filter((o) => ['thomson', 'indep', 'prehealth'].indexOf(o.id) >= 0).map((o) => `<div class="rm-card tint"><strong>${esc(o.name)}</strong><p style="margin:6px 0">${esc(o.what)}</p><p style="margin:0"><strong>Next step:</strong> ${esc(o.next)}</p></div>`).join('')}`;
  }

  function planItems() {
    const items = [];
    const today = new Date();
    const add = (days, text) => { const d = new Date(today.getTime() + days * 86400000); items.push({ d, text }); };
    const fin = S.final || {};
    const f = F[fin.faculty];
    if (!fin.askSentAt && f) add(0, 'Send your ask to ' + f.honorific + ' ' + f.last + ', then tap "I sent it".');
    add(7, 'If there is no reply, send one short follow-up. Visit office hours if you can.');
    if (f) add(10, 'Ask ' + f.honorific + ' ' + f.last + ' how to register for independent study or credit, and the deadline for next semester.');
    const k = S.answers.constraints || {};
    add(14, 'Email Dr. Higgs (' + F.higgs.email + ') about the Thomson Research Fellowship: when applications are due, and whether you need to have declared the major.');
    if (k.goal === 'health') add(14, 'Book a Pre-Health advising appointment (Lisa Lee, Greenquist 302) and ask which research experiences matter for your target program.');
    add(21, 'Meet with your academic advisor and put the research course or independent study on your spring plan.');
    add(28, 'If this lab did not work out, move to your second choice. You already have the interview.');
    (S.shortlist || []).forEach((id) => {
      const o = E.outreachOf(S, id);
      if (o.status === 'done' && !o.thanked) add(1, 'Send your thank-you to ' + F[id].honorific + ' ' + F[id].last + ' (within 24 hours of the interview).');
    });
    return items.sort((a, b) => a.d - b.d);
  }
  function planHtml() {
    return `<div class="rm-card"><ol style="margin:0 0 0 18px;padding:0">${planItems().map((i) => `<li style="margin-bottom:8px"><strong>${esc(i.d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }))}</strong>: ${esc(i.text)}</li>`).join('')}</ol></div>`;
  }

  // --- Class view (instructor) ---
  async function vClass() {
    let data;
    try { data = await window.sfSupabase.bios102RmOverview(session.sessionToken); } catch (e) { return `<h1 class="rm-h1">Class view</h1><div class="rm-card warn">Instructors only.</div>`; }
    const st = data.students || [];
    const n = st.length;
    const started = st.filter((s) => s.started).length;
    const profile = st.filter((s) => s.profileDone).length;
    const listed = st.filter((s) => (s.shortlist || []).length).length;
    const stat = (s, set) => Object.values(s.outreach || {}).some((o) => set.indexOf(o.status) >= 0);
    const emailed = st.filter((s) => stat(s, ['sent', 'scheduled', 'done'])).length;
    const interviewed = st.filter((s) => stat(s, ['done'])).length;
    const decided = st.filter((s) => s.final).length;
    const demand = D.FACULTY.map((f) => ({ f, listed: st.filter((s) => (s.shortlist || []).indexOf(f.id) >= 0).length,
      sent: st.filter((s) => ['sent', 'scheduled', 'done'].indexOf((s.outreach || {})[f.id] && s.outreach[f.id].status) >= 0).length,
      done: st.filter((s) => ((s.outreach || {})[f.id] || {}).status === 'done').length })).sort((a, b) => b.listed - a.listed);
    const stage = (s) => !s.started ? 'Not started' : s.final ? 'Decided' : Object.values(s.outreach || {}).some((o) => o.status === 'done') ? 'Interviewed' : Object.values(s.outreach || {}).some((o) => ['sent', 'scheduled'].indexOf(o.status) >= 0) ? 'Emailed' : (s.shortlist || []).length ? 'Has a list' : s.profileDone ? 'Has matches' : 'In the cards';
    return `
      <h1 class="rm-h1">Class view</h1>
      <p class="rm-lede">Progress only. You cannot see anyone&rsquo;s written answers or interview notes. Use the demand table to keep any one professor from being swamped.</p>
      <div class="rm-grid" style="grid-template-columns:repeat(auto-fill,minmax(140px,1fr))">
        ${[['On the roster', n], ['Opened it', started], ['Finished cards', profile], ['Picked professors', listed], ['Emailed', emailed], ['Interviewed', interviewed], ['Decided', decided]].map(([l, v]) => `<div class="rm-card" style="margin:0;text-align:center"><div class="rank" style="font-size:32px">${v}</div><div class="rm-muted">${l}</div></div>`).join('')}
      </div>
      <h2 class="rm-h2">Demand by professor</h2>
      <div class="tablewrap"><table class="rm"><thead><tr><th>Professor</th><th>On a student&rsquo;s list</th><th>Emailed</th><th>Interviewed</th></tr></thead><tbody>${demand.map((d) => `<tr><td>${esc(d.f.honorific + ' ' + d.f.name)}</td><td>${d.listed}${d.listed >= 6 ? ' <span class="chip w">crowded</span>' : ''}</td><td>${d.sent}</td><td>${d.done}</td></tr>`).join('')}</tbody></table></div>
      <h2 class="rm-h2">Students</h2>
      <div class="tablewrap"><table class="rm"><thead><tr><th>Name</th><th>Where they are</th><th>List</th></tr></thead><tbody>${st.map((s) => `<tr><td>${esc(s.name)}</td><td>${esc(stage(s))}</td><td>${esc((s.shortlist || []).map((i) => (F[i] ? F[i].last : i)).join(', '))}</td></tr>`).join('')}</tbody></table></div>
      <p class="rm-muted">To add students, put their rows in <code>bios102_students</code> (see <code>supabase/bios102-add-students.sql</code>). They sign in with the same email link as the rest of the Lab Companion.</p>`;
  }

  // ---------- actions ----------
  function toggleList(id) {
    const i = S.shortlist.indexOf(id);
    if (i >= 0) { S.shortlist.splice(i, 1); }
    else {
      if (S.shortlist.length >= MAX_LIST) { flash('Your list is full (' + MAX_LIST + '). Remove one first. Professors are busy and your classmates are asking too.', true); return; }
      S.shortlist.push(id); O(id);
    }
    save(); render();
  }
  function copy(text, msg) {
    const done = () => flash(msg || 'Copied');
    if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).then(done, () => fallbackCopy(text, done));
    else fallbackCopy(text, done);
  }
  function fallbackCopy(text, cb) {
    const t = document.createElement('textarea'); t.value = text; document.body.appendChild(t); t.select();
    try { document.execCommand('copy'); cb(); } catch (e) { flash('Could not copy. Select the preview and copy it by hand.', true); }
    document.body.removeChild(t);
  }
  function asText(d) { return 'To: ' + d.to + '\nSubject: ' + d.subject + '\n\n' + d.body; }
  function draftedMark(id) { const o = O(id); if (o.status === 'none') { o.status = 'drafted'; save(); } }
  function downloadICS(id) {
    const f = F[id], o = O(id);
    if (!o.interviewDate) { flash('Add a date and time first.', true); return; }
    const ics = E.icsEvent({ title: 'Research interview: ' + f.honorific + ' ' + f.last, start: o.interviewDate, minutes: 20, location: o.place || '', description: 'BIOS102 research mentor interview. Bring your questions. Thank-you email within 24 hours.' });
    const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([ics], { type: 'text/calendar' })); a.download = 'interview-' + f.last.toLowerCase() + '.ics';
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
  }
  function printSheet(id) {
    const f = F[id], o = O(id);
    const qs = (o.questions || []).concat((o.ownQ || '').split('\n').map((x) => x.trim()).filter(Boolean));
    $('#printSheet').innerHTML = `<h1>Interview prep: ${esc(f.honorific + ' ' + f.name)}</h1>
      <p>${esc(f.title)}<br>${esc(f.email)} &middot; ${esc(f.phone)}<br>${o.interviewDate ? '<b>' + esc(E.fmtDateTime(o.interviewDate)) + '</b>' : ''} ${o.place ? '&middot; ' + esc(o.place) : ''}</p>
      <h2>What they study</h2><p>${esc(f.oneLine)}</p><p><b>Read first:</b> ${esc(f.readFirst)}</p>
      <h2>My questions</h2><ol>${qs.map((q) => `<li>${esc(q)}<div class="lines"></div></li>`).join('') || '<li>(none picked)</li>'}</ol>
      <h2>Before I walk in</h2><ul><li>Arrive 5 minutes early. Silence my phone.</li><li>Open with 30 seconds on who I am and why I asked for this meeting.</li><li>Take notes. Ask what the next step is.</li><li>Thank them by email within 24 hours.</li></ul>
      <h2>Notes</h2><div class="lines"></div><div class="lines"></div><div class="lines"></div><div class="lines"></div>`;
    window.print();
  }
  function printPlan() {
    $('#printSheet').innerHTML = `<h1>My research plan</h1><h2>Next 30 days</h2><ol>${planItems().map((i) => `<li><b>${esc(i.d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }))}</b>: ${esc(i.text)}</li>`).join('')}</ol>`;
    window.print();
  }

  function handleClick(e) {
    const b = e.target.closest('[data-act]');
    if (!b || b.tagName === 'INPUT' && b.type === 'checkbox') return;
    const act = b.dataset.act, id = b.dataset.id, v = b.dataset.v;
    switch (act) {
      case 'go': go(v); break;
      case 'filter': ui.filter = v; render(); break;
      case 'openFac': ui.open[id] = !ui.open[id]; render(); break;
      case 'toggleList': toggleList(id); break;
      case 'rate': {
        S.answers.ratings[id] = Number(v);
        $$('[data-card="' + id + '"] .scale button').forEach((x) => x.setAttribute('aria-pressed', String(x.dataset.v === v)));
        save(); refreshKnow(); break;
      }
      case 'finishKnow':
        if (!E.profileComplete(S.answers)) return;
        S.profileDone = true; save(true); go('matches'); break;
      case 'panel': ui.panel[id] = ui.panel[id] === v ? null : v; render(); break;
      case 'mailDraft': draftedMark(id); window.location.href = E.mailto(draftFor(id)); break;
      case 'copyDraft': draftedMark(id); copy(asText(draftFor(id)), 'Email copied'); break;
      case 'markSent': { const o = O(id); if (o.status !== 'sent') { o.status = 'sent'; o.sentAt = new Date().toISOString(); } ui.panel[id] = null; save(); render(); flash('Marked as sent'); break; }
      case 'mailFollow': { const o = O(id); o.followedUp = new Date().toISOString(); save(); window.location.href = E.mailto(E.followUp(student(), F[id], o)); break; }
      case 'copyFollow': copy(asText(E.followUp(student(), F[id], O(id))), 'Follow-up copied'); break;
      case 'setStatus': { const o = O(id); o.status = v; if (v === 'done') o.doneAt = new Date().toISOString(); ui.panel[id] = null; save(); render(); break; }
      case 'confirmSchedule': {
        const o = O(id); if (!o.interviewDate) { flash('Pick a date and time first.', true); return; }
        o.status = 'scheduled'; ui.panel[id] = 'prep'; save(); render(); break;
      }
      case 'ics': downloadICS(id); break;
      case 'printPrep': printSheet(id); break;
      case 'mailThanks': window.location.href = E.mailto(E.thankYou(student(), F[id], O(id))); break;
      case 'copyThanks': copy(asText(E.thankYou(student(), F[id], O(id))), 'Thank-you copied'); break;
      case 'markThanked': O(id).thanked = new Date().toISOString(); save(); render(); break;
      case 'mailAsk': window.location.href = E.mailto(askDraft()); break;
      case 'copyAsk': copy(asText(askDraft()), 'Ask copied'); break;
      case 'markAsk': S.final.askSentAt = new Date().toISOString(); save(); render(); flash('Marked as sent'); break;
      case 'printPlan': printPlan(); break;
      case 'emailPlan': emailPlan(b); break;
      default: break;
    }
  }
  function askDraft() {
    const fin = S.final || {};
    const path = (D.OPPORTUNITIES.find((x) => x.id === fin.path) || {}).name || '';
    return E.askEmail(student(), F[fin.faculty], { askWhy: fin.askWhy, askStart: fin.askStart }, path);
  }
  async function emailPlan(btn) {
    btn.disabled = true; btn.textContent = 'Sending...';
    try {
      await pushServer();
      await window.sfSupabase.bios102RmEmailPlan(session.sessionToken);
      btn.textContent = 'Sent. Check your inbox.';
    } catch (e) { btn.disabled = false; btn.textContent = 'Email me my plan'; flash(e.message || 'Could not send. Try again in a minute.', true); }
  }

  function updateLive(id) {
    const o = O(id);
    const ok = (o.customLine || '').trim().length >= 25;
    const draft = draftFor(id);
    const p = $('#prev-' + id);
    if (p) p.innerHTML = '<b>To:</b> ' + esc(draft.to) + '\n<b>Subject:</b> ' + esc(draft.subject) + '\n\n' + esc(draft.body);
    $$('[data-needs="' + id + '"]').forEach((x) => { x.disabled = !ok; });
    const n = $('#need-' + id); if (n) n.hidden = ok;
  }
  function updateAsk() {
    const fin = S.final || {};
    const ok = (fin.askWhy || '').trim().length >= 25;
    const d = askDraft();
    const p = $('#ask-prev'); if (p) p.innerHTML = '<b>To:</b> ' + esc(d.to) + '\n<b>Subject:</b> ' + esc(d.subject) + '\n\n' + esc(d.body);
    $$('[data-needs="ask"]').forEach((x) => { x.disabled = !ok; });
    const n = $('#ask-need'); if (n) n.hidden = ok;
  }

  function handleInput(e) {
    const t = e.target;
    if (t.dataset && t.dataset.act === 'pickQ' && t.type === 'checkbox') {
      const o = O(t.dataset.id); const q = t.dataset.q;
      const set = new Set(o.questions || []);
      if (t.checked) set.add(q); else set.delete(q);
      o.questions = Array.from(set);
      const c = $('#qcount-' + t.dataset.id); if (c) c.textContent = set.size + ' picked';
      save(); return;
    }
    const path = t.dataset && t.dataset.bind;
    if (!path) return;
    let val = t.value;
    if (t.type === 'radio' && !t.checked) return;
    setPath(S, path, val);
    if (path.indexOf('answers.') === 0) refreshKnowIfOpen();
    if (t.dataset.live) updateLive(t.dataset.live);
    if (t.dataset.fit) { const o = O(t.dataset.fit); o.fit = o.fit || {}; o.fit.overall = overallFit(o); }
    if (t.dataset.redraft) updateAsk();
    if (path.indexOf('.would') > 0 || path === 'final.faculty' || t.dataset.fit) { if (e.type === 'change') { save(); render(); return; } }
    save();
  }
  function refreshKnowIfOpen() { if (view === 'know') refreshKnow(); }

  // ---------- boot ----------
  async function boot() {
    $('#who').textContent = session.displayName || session.email || '';
    $('#checked').textContent = D.CHECKED;
    $('#logout').addEventListener('click', () => { BIOS.clearSession(); window.location.href = '/BIOS102/index.html'; });
    await load();
    view = (S.stage && ['home', 'know', 'matches', 'meet', 'interview', 'decide', 'class'].indexOf(S.stage) >= 0) ? S.stage : 'home';
    if (view === 'class' && !isInstructor) view = 'home';
    const view$ = $('#view');
    view$.addEventListener('click', handleClick);
    view$.addEventListener('input', handleInput);
    view$.addEventListener('change', handleInput);
    $('#steps').addEventListener('click', handleClick);
    document.addEventListener('visibilitychange', () => { if (document.hidden && saveTimer) { clearTimeout(saveTimer); pushServer(); } });
    render();
    if (view === 'know') refreshKnow();
  }

  boot();
})();
