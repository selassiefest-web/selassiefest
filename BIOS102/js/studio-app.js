// BIOS102 Research-to-Grant Studio: the page. Invite-only (bios102_studio_has_access). All work is saved in
// this browser (localStorage) and can be backed up to a file; nothing is sent anywhere unless the student sends it.
(function () {
  'use strict';
  const C = window.StudioCore, W = window.StudioWidgets, D = window.STUDIO_DATA, PIS = window.STUDIO_PIS, RM = window.RM_DATA;
  const esc = C.esc;
  const $ = (s, r) => (r || document).querySelector(s);
  const $$ = (s, r) => Array.from((r || document).querySelectorAll(s));
  let session = null, KEY = '';
  const ADMIN = 'harria01@uwp.edu';

  let S = null, view = 'dash', isInstructor = false, saveOk = true, saveTimer = 0, toastTimer = 0;

  // ---------- state ----------
  const clone = (o) => JSON.parse(JSON.stringify(o));
  const blankFacts = () => ({ aimCount: '', aimTitles: '', minReplicates: '', totalHours: '', startDate: '', endDate: '', deliverable: '', budgetTotal: '' });
  function blankState() {
    const ex = D.EXAMPLE;
    const paper = (role) => ({ role, doi: '', title: '', tested: '', support: '', uncertain: '', relates: '', figure: '', figureDone: false });
    const gap = (n) => ({ id: 'g' + n, title: '', a: {}, evidence: [], score: { value: 3, evidence: 3, access: 3, burden: 3, deliver: 3 }, dependencies: [], feasibleHours: true });
    return {
      v: 1, meta: {},
      profile: { name: session.displayName || '', major: '', year: '', courses: '', skills: '', mode: '', modeNote: '', weeklyHours: 6, periods: [{ label: 'Semester 1', start: '', end: '' }, { label: 'Semester 2', start: '', end: '' }], breaks: [], reserve: { training: 15, access: 15, trouble: 10, analysis: 35, reporting: 25 } },
      pi: '', identityChecks: { affiliation: { done: false, note: '' }, coauthors: { done: false, note: '' }, history: { done: false, note: '' } },
      sources: [], library: { items: [], analysis: {}, evidence: [], searches: [], screen: [] }, papers: [paper('foundational'), paper('recent')], resources: [], litChecks: [],
      gaps: [gap(1), gap(2), gap(3)], weights: {}, chosenGap: '', justification: '',
      funding: { primary: 'thomson', alt: 'urap', resolutions: {}, altAssessment: '' },
      plan: { title: '', facts: blankFacts(), sections: { observation: '', background: '', evidence: '', gap: '', question: '', answer: '', prediction: '', aims: '', variables: '', analysis: '', interpretation: '', approvals: '', handoff: '' }, experiments: [], schedule: [], fallback: { switchByWeek: 0, hoursNeeded: 0, note: '' } },
      budget: [], proposal: { facts: blankFacts(), modelNote: ex.proposal.modelNote, sections: ex.proposal.sections.map((s) => ({ id: s.id, title: s.title, limit: s.limit, text: '' })) },
      claims: [], refs: [], pending: [], defense: { gap: '', comparison: '', analysis: '', assumption: '' },
      meeting: { decisions: [], notes: '', status: 'not started', email: null }, submission: { status: 'Draft', log: [] }, review: { notes: {}, signoff: '' }, sectionStatus: {},
    };
  }
  function load() {
    try { const raw = localStorage.getItem(KEY); if (raw) { const o = JSON.parse(raw); if (o && o.v === 1) { migrate(o); S = o; (S.customFunders || []).forEach((cf) => { if (!D.FUNDERS.some((f) => f.id === cf.id)) D.FUNDERS.push(cf); }); return; } } } catch (e) { /* fall through */ }
    S = blankState();
  }
  function migrate(o) {
    o.library = o.library || { items: [], analysis: {}, evidence: [], searches: [], screen: [] }; o.library.screen = o.library.screen || [];
    o.library.items = o.library.items || []; o.library.analysis = o.library.analysis || {}; o.library.evidence = o.library.evidence || []; o.library.searches = o.library.searches || [];
    (o.gaps || []).forEach((g) => { g.evidence = g.evidence || []; });
    const ps = (o.plan && o.plan.sections) || {};
    if (o.plan && o.plan.sections) { ['observation', 'answer', 'prediction'].forEach((k) => { if (ps[k] == null) ps[k] = ''; }); if (ps.hypotheses) { ps.prediction = ps.prediction || ps.hypotheses; delete ps.hypotheses; } }
  }
  function saveNow() { try { localStorage.setItem(KEY, JSON.stringify(S)); saveOk = true; } catch (e) { saveOk = false; } }
  function save() { clearTimeout(saveTimer); saveTimer = setTimeout(saveNow, 250); }
  function toast(t) { const el = $('#toast'); el.textContent = t; el.classList.add('on'); clearTimeout(toastTimer); toastTimer = setTimeout(() => el.classList.remove('on'), 2400); }
  const getPath = (o, p) => p.split('.').reduce((a, k) => (a == null ? a : a[k]), o);
  function setPath(o, p, v) { const ks = p.split('.'); let a = o; for (let i = 0; i < ks.length - 1; i++) { if (a[ks[i]] == null) a[ks[i]] = {}; a = a[ks[i]]; } a[ks[ks.length - 1]] = v; }

  // ---------- small builders ----------
  const sid = (p) => String(p).replace(/[^A-Za-z0-9_-]/g, '_');
  const val = (p) => { const v = p.indexOf('funding.resolutions.') === 0 ? S.funding.resolutions[p.slice(20)] : getPath(S, p); return v == null ? '' : v; };
  const inp = (p, label, o) => { o = o || {}; return '<div><label class="gs-f" for="i-' + sid(p) + '">' + label + '</label><input class="gs-in" id="i-' + sid(p) + '" data-bind="' + p + '"' + (o.num ? ' data-num="1" type="number" min="' + (o.min == null ? 0 : o.min) + '"' : ' type="' + (o.type || 'text') + '"') + ' value="' + esc(val(p)) + '"' + (o.ph ? ' placeholder="' + esc(o.ph) + '"' : '') + '></div>'; };
  const ta = (p, label, o) => { o = o || {}; return '<div><label class="gs-f" for="t-' + sid(p) + '">' + label + '</label><textarea class="gs-ta" id="t-' + sid(p) + '" data-bind="' + p + '"' + (o.rows ? ' style="min-height:' + o.rows * 24 + 'px"' : '') + (o.ph ? ' placeholder="' + esc(o.ph) + '"' : '') + '>' + esc(val(p)) + '</textarea>' + (o.limit ? '<div class="gs-count" data-wc="' + p + '" data-limit="' + o.limit + '"></div>' : '') + '</div>'; };
  const sel = (p, label, opts, o) => { o = o || {}; const v = String(val(p)); return '<div><label class="gs-f" for="s-' + sid(p) + '">' + label + '</label><select class="gs-sel" id="s-' + sid(p) + '" data-bind="' + p + '"' + (o.rerender ? ' data-rerender="1"' : '') + '><option value="">Choose</option>' + opts.map((x) => { const a = Array.isArray(x) ? x : [x, x]; return '<option value="' + esc(a[0]) + '"' + (String(a[0]) === v ? ' selected' : '') + '>' + esc(a[1]) + '</option>'; }).join('') + '</select></div>'; };
  const chk = (p, label) => '<label style="display:flex;gap:8px;align-items:center;margin:8px 0"><input type="checkbox" data-bind="' + p + '" data-bool="1"' + (val(p) ? ' checked' : '') + '> <span>' + label + '</span></label>';
  const term = (k, text) => '<span class="gs-tip" tabindex="0" title="' + esc(D.GLOSSARY[k] || '') + '">' + esc(text || k) + '</span>';
  const statusSel = (key) => '<select class="gs-sel gs-sm" style="width:auto" data-status="' + key + '" aria-label="Section status">' + [['draft', 'Draft'], ['reviewed', 'Reviewed by me'], ['verified', 'Verified by me']].map((x) => '<option value="' + x[0] + '"' + (C.sectionState(S, key) === x[0] ? ' selected' : '') + '>' + x[1] + '</option>').join('') + '</select>';
  const example = (fn) => (S.meta && S.meta.example) ? '' : fn();
  const exBox = (text) => text ? '<details class="gs-ex"><summary>See the worked example for this section</summary><p>' + esc(text) + '</p></details>' : '';
  const R = () => C.readiness(S);

  // ---------- shell ----------
  const NAV = [
    ['dash', 'Mission Control', '<path d="M3 3h7v9H3zM14 3h7v5h-7zM14 12h7v9h-7zM3 16h7v5H3z"/>'],
    ['me', '1 · Me and my hours', '<circle cx="12" cy="8" r="3.5"/><path d="M4.5 21c0-4 3.4-6.5 7.5-6.5s7.5 2.5 7.5 6.5"/>'],
    ['pi', '2 · PI and lab', '<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>'],
    ['gaps', '3 · Gap arena', '<circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="3.5"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3"/>'],
    ['plan', '4 · Research plan', '<path d="M6 3h9l4 4v14H6zM14 3v5h5M9 13h7M9 17h7"/>'],
    ['fund', '5 · Funding', '<circle cx="12" cy="12" r="9"/><path d="M12 7v10M9.5 9.5c0-1.2 1.1-2 2.5-2s2.5.8 2.5 2-1.1 1.8-2.5 2-2.5.8-2.5 2 1.1 2 2.5 2 2.5-.8 2.5-2"/>'],
    ['pro', '6 · Grant proposal', '<path d="M6 3h9l4 4v14H6zM14 3v5h5M9 12l2 2 4-4"/>'],
    ['meet', '7 · Defend and meet', '<path d="M5 21V4M5 4h11l-2 4 2 4H5"/>'],
    ['after', '8 · After the meeting', '<path d="M4 12a8 8 0 1 0 3-6.2M4 4v4h4"/>'],
  ];
  function renderNav() {
    const r = R(); const steps = NAV.slice(); if (isInstructor) steps.push(['review', 'Instructor review', '<path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>']); steps.push(['data', 'Backup and data', '<path d="M12 3v12M7 10l5 5 5-5M4 20h16"/>']);
    $('#nav').innerHTML = steps.map((s) => { const own = r.items.filter((i) => i.view === s[0]); const worst = own.some((i) => i.level === 'block') ? '#fb7185' : own.some((i) => i.level === 'warn') ? '#fbbf24' : own.length ? '#4ade80' : ''; return '<li><button type="button" data-act="go" data-v="' + s[0] + '"' + (view === s[0] ? ' aria-current="page"' : '') + '><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + s[2] + '</svg><span>' + s[1] + '</span>' + (worst ? '<i class="gs-pip" style="--c:' + worst + '"></i>' : '') + '</button></li>'; }).join('');
    $('#navring').innerHTML = W.ring(r.pct, 'ready', 120);
  }
  function go(v) { view = v; render(); window.scrollTo(0, 0); }
  // One task per screen. A view is cut into screens at explicit breaks (<div class="gs-pgbreak" data-t="Title">) or, failing that,
  // at section headings and when a screen would get long. Back / Next move through the screens, and the last Next
  // goes to the next step of the studio.
  const WIZ = ['me', 'gaps', 'plan', 'fund', 'pro', 'meet', 'after'];
  const WZ = {};
  const ORDER = ['dash', 'me', 'pi', 'gaps', 'plan', 'fund', 'pro', 'meet', 'after'];
  const pg = (t, task) => '<div class="gs-pgbreak" data-t="' + esc(t) + '"' + (task ? ' data-task="' + esc(task) + '"' : '') + '></div>';
  // every chain node and gate chip jumps to the exact screen where that task is done
  const DEEP = { c_papers: ['pi', 'pi'], c_gap: ['gaps', 'Choose and justify'], c_obs: ['plan', 'Observation'], c_q: ['plan', 'Question'], c_ans: ['plan', 'Proposed answer'], c_pred: ['plan', 'Prediction'], c_mm: ['plan', 'Materials and methods'],
    me: ['me', ''], pi: ['pi', 'identity'], papers: ['pi', 'deep'], res: ['pi', 'resources'], lib: ['pi', 'pi'], screen: ['pi', 'pi'], evid: ['pi', 'evidence'], gaps: ['gaps', 'Your evidence'], choice: ['gaps', 'Choose and justify'], fund: ['fund', ''],
    chain: ['plan', 'The chain'], plan: ['plan', 'Materials and methods'], drift: ['plan', 'Schedule'], pro: ['pro', ''], claims: ['pro', ''], twin: ['plan', 'Key facts'], def: ['meet', ''], pend: ['meet', ''] };
  const STEPNAME = { me: '1 \u00b7 Me and my hours', gaps: '3 \u00b7 Gap Arena', plan: '4 \u00b7 Research plan', fund: '5 \u00b7 Funding', pro: '6 \u00b7 Grant proposal', meet: '7 \u00b7 Defend and meet', after: '8 \u00b7 After the meeting' };
  function paginate(id, html) {
    const tpl = document.createElement('template'); tpl.innerHTML = html; const nodes = Array.from(tpl.content.children);
    const isBody = (n) => n.classList.contains('gs-pgbreak') || n.classList.contains('gs-card') || n.classList.contains('gs-cand') || n.classList.contains('gs-grid') || n.tagName === 'H2';
    let first = nodes.findIndex(isBody); if (first < 0) first = nodes.length;
    const head = nodes.slice(0, first), body = nodes.slice(first); const pages = []; let cur = null; const explicit = body.some((n) => n.classList.contains('gs-pgbreak'));
    const titleOf = (n) => { const t = n.querySelector && n.querySelector('h3,h2,label,b'); return (n.tagName === 'H2' ? n.textContent : t ? t.textContent : 'More').replace(/\s+/g, ' ').trim().slice(0, 42); };
    const start = (t, task) => { cur = { t, task: task || '', nodes: [], len: 0 }; pages.push(cur); };
    body.forEach((n) => {
      if (n.classList.contains('gs-pgbreak')) { start(n.dataset.t, n.dataset.task); return; }
      if (!cur || (!explicit && ((n.tagName === 'H2' && cur.nodes.length) || cur.len > 3600))) start(titleOf(n));
      if (cur.nodes.length === 0 && cur.t === 'More') cur.t = titleOf(n);
      cur.nodes.push(n); cur.len += n.outerHTML.length;
    });
    const real = pages.filter((x) => x.nodes.length);
    if (real.length <= 1) return html;
    if (WZ.want && WZ.want.id === id) { const k = real.findIndex((x) => x.t.indexOf(WZ.want.text) >= 0); if (k >= 0) WZ[id] = k; WZ.want = null; }
    const i = Math.max(0, Math.min(WZ[id] || 0, real.length - 1)); WZ[id] = i;
    const nextView = ORDER[ORDER.indexOf(id) + 1];
    const statusOf = (x) => { let total = 0, filled = 0; x.nodes.forEach((n) => { n.querySelectorAll('input[data-bind],textarea[data-bind],select[data-bind]').forEach((el) => { if (el.type === 'range' || el.type === 'checkbox' || el.type === 'radio') return; total++; if (String(el.value || '').trim()) filled++; }); }); return total === 0 ? '' : filled === total ? 'done' : filled > 0 ? 'part' : 'todo'; };
    const SYMB = { done: '\u2713', part: '\u25d0', todo: '\u25cb' };
    const stepsList = '<ol class="gs-steps" aria-label="Screens in this step">' + real.map((x, k) => { const st = statusOf(x); return '<li><button type="button" class="' + (k === i ? 'on ' : '') + (st ? 'st-' + st : '') + '" data-act="wz" data-w="' + id + '" data-v="' + k + '" aria-current="' + (k === i ? 'step' : 'false') + '"' + (st ? ' title="' + ({ done: 'Done', part: 'In progress', todo: 'Not started' }[st]) + '"' : '') + '><b>' + (st ? SYMB[st] : k + 1) + '</b><span>' + esc(x.t) + '</span></button></li>'; }).join('') + '</ol>' + W.legend();
    const pctDone = Math.round(((i + 1) / real.length) * 100);
    const steps = '<div class="gs-here"><div class="gs-crumb">Step ' + esc(STEPNAME[id] || id) + ' \u203a Screen ' + (i + 1) + ' of ' + real.length + ': ' + esc(real[i].t) + '</div><div class="gs-task"><b>Your task here:</b> ' + esc(real[i].task || 'Fill in what is on this screen, then press Next.') + '</div><div class="gs-progress" role="progressbar" aria-valuenow="' + pctDone + '" aria-valuemin="0" aria-valuemax="100"><i style="width:' + pctDone + '%"></i></div><details class="gs-allsteps"><summary>See all ' + real.length + ' screens</summary>' + stepsList + '</details></div>';
    const foot = '<div class="gs-wizfoot"><button class="gs-btn2" data-act="wzb" data-w="' + id + '"' + (i === 0 ? ' disabled' : '') + '>\u2190 Back</button><span class="gs-count">Screen ' + (i + 1) + ' of ' + real.length + '</span><button class="gs-btn" data-act="wzn" data-w="' + id + '">' + (i === real.length - 1 ? (nextView ? 'Done here: on to the next step \u2192' : 'Finished') : 'Next: ' + esc(real[i + 1].t) + ' \u2192') + '</button></div>';
    return head.map((n) => n.outerHTML).join('') + steps + '<div class="gs-wzpage">' + real[i].nodes.map((n) => n.outerHTML).join('') + '</div>' + foot;
  }
  function render() {
    renderNav();
    const f = { dash: vDash, me: vMe, pi: vPi, gaps: vGaps, plan: vPlan, fund: vFund, pro: vPro, meet: vMeet, after: vAfter, review: vReview, data: vData }[view] || vDash;
    $('#view').innerHTML = WIZ.indexOf(view) >= 0 ? paginate(view, f()) : f();
    refreshLive(); wordCounts(); addMics();
  }
  function refreshLive() { const el = $('#live'); if (el) { const L = { me: liveMe, gaps: liveGaps, plan: livePlan, fund: liveFund, pro: livePro }[view]; if (L) el.innerHTML = L(); } renderNavLight(); }
  function renderNavLight() { const r = R(); $('#navring').innerHTML = W.ring(r.pct, 'ready', 120); $$('#nav .gs-pip').forEach((p) => p.remove()); $$('#nav button[data-v]').forEach((b) => { const own = r.items.filter((i) => i.view === b.dataset.v); if (!own.length) return; const c = own.some((i) => i.level === 'block') ? '#fb7185' : own.some((i) => i.level === 'warn') ? '#fbbf24' : '#4ade80'; b.insertAdjacentHTML('beforeend', '<i class="gs-pip" style="--c:' + c + '"></i>'); }); }
  function wordCounts() { $$('[data-wc]').forEach((el) => { const n = C.words(getPath(S, el.dataset.wc)); const lim = Number(el.dataset.limit); el.textContent = n + (lim ? ' of ' + lim + ' words' : ' words'); el.classList.toggle('over', !!lim && n > lim); }); }
  function exampleBanner() { return S.meta && S.meta.example ? '<div class="gs-demo"><strong>Worked example loaded.</strong> The student, dates, hours and budget uses are illustrative; the papers, dataset and funder facts are real and cited. Edit anything. <button class="gs-btn3 gs-sm" data-act="startMine">Start my own from scratch</button></div>' : ''; }

  // ---------- Mission Control ----------
  function vDash() {
    const r = R(); const cal = C.calendar(S.profile); const na = C.nextAction(S); const f = C.piCard(S.pi); const rk = C.rankGaps(S.gaps, S.weights);
    const totals = C.scheduleTotals(S.plan); const hasSch = (S.plan.schedule || []).length; const tot = hasSch ? totals : C.reserve(cal.total, S.profile.reserve);
    const words = (t) => C.words(t);
    const planW = Object.values(S.plan.sections).reduce((a, t) => a + words(t), 0), proW = S.proposal.sections.reduce((a, s) => a + words(s.text), 0);
    const today = Date.now(); const startMs = cal.first; const days = isNaN(startMs) ? null : Math.ceil((startMs - today) / 86400000);
    const ms = r.blocks[0] || r.warns[0];
    const funder = C.funder(S.funding.primary);
    const gate = (id) => (r.items.find((i) => i.id === id) || {}).level;
    const tile = (label, title, sub, st) => '<div class="gs-tile gs-t-' + st + '"><div class="gs-spread"><small>' + label + '</small>' + W.badge(st) + '</div><b>' + title + '</b><span>' + sub + '</span></div>';
    const nLib = S.library.items.length;
    const piSt = !S.pi ? 'todo' : gate('pi') === 'ok' ? 'done' : 'part';
    const libSt = nLib === 0 ? 'todo' : (gate('lib') === 'ok' && gate('evid') === 'ok' && gate('screen') === 'ok') ? 'done' : 'part';
    const winSt = isNaN(cal.first) ? 'todo' : gate('me') === 'ok' ? 'done' : 'part';
    const oq = r.blocks.length + r.warns.length; const oqSt = oq === 0 ? 'done' : r.blocks.length ? 'alert' : 'part';
    const docSt = planW + proW === 0 ? 'todo' : (gate('plan') === 'ok' && gate('pro') === 'ok') ? 'done' : 'part';
    const subSt = { 'Draft': 'todo', 'Revising after PI meeting': 'part', 'Ready to submit': 'part', 'Submitted': 'done', 'Awarded': 'done', 'Declined': 'alert', 'Resubmitting': 'part' }[S.submission.status] || 'todo';
    return '<p class="gs-kick">Research-to-Grant Studio · mission control</p><h1 class="gs-h1">Your mission, in one view</h1>' + exampleBanner() +
      '<div class="gs-card gs-glow gs-hero"><div>' + W.ring(r.pct, 'mission ready', 200) + '</div><div><div class="gs-next"><small>Next best action</small><p style="margin:4px 0 10px;font-size:1.05rem">' + esc(na.text) + '</p><button class="gs-btn" data-act="go" data-v="' + na.view + '">Take me there</button></div><p class="gs-note">' + r.blocks.length + ' blocked · ' + r.warns.length + ' open · ' + r.items.filter((i) => i.level === 'ok').length + ' clear. Every number on this page is computed from what you typed; nothing is entered twice.</p></div></div>' +
      W.legend() + '<div class="gs-grid3">' +
      tile('Selected PI', esc(f ? f.honorific + ' ' + f.name : 'Not chosen yet'), esc(f ? f.oneLine : 'Step 2 \u00b7 PI and lab'), piSt) +
      tile('Library', nLib + ' papers', S.library.items.filter((i) => i.coll === 'pi').length + ' PI \u00b7 ' + S.library.items.filter((i) => i.coll === 'related').length + ' related \u00b7 ' + S.library.evidence.length + ' evidence cards', libSt) +
      tile('Project window', (isNaN(cal.first) ? 'Not set' : C.fmt(cal.first) + ' \u2192 ' + C.fmt(cal.last)), cal.total + ' h over ' + cal.totalWeeks + ' weeks' + (days != null ? (days > 0 ? ' \u00b7 starts in ' + days + ' days' : ' \u00b7 under way') : ''), winSt) +
      tile('Current milestone', esc(ms ? ms.label : 'Ready to meet'), esc(ms ? ms.detail.slice(0, 90) : 'All gates clear'), ms ? 'part' : 'done') +
      tile('Open questions', String(oq), (S.pending || []).length + ' pending actions for the PI', oqSt) +
      tile('Documents', 'Plan ' + planW + ' w \u00b7 Proposal ' + proW + ' w', funder ? esc(funder.name) : 'No funder', docSt) +
      tile('Submission', esc(S.submission.status), 'You control outreach and submission', subSt) + '</div>' +
      '<h2 class="gs-h2">The research chain</h2><div class="gs-card">' + W.chain(S) + '</div><h2 class="gs-h2">Readiness gates</h2>' + W.gates(r.items) +
      '<div class="gs-grid" style="margin-top:16px"><div class="gs-card"><h3>Hours and where they go</h3>' + W.hoursDonut(tot, cal.total) + '<p class="gs-note">' + (hasSch ? 'From your week-by-week schedule.' : 'Default reserves; build your schedule in step 4.') + '</p></div>' +
      '<div class="gs-card"><h3>Candidate arena</h3>' + (rk.live.length ? W.radar(rk.live.filter((x) => (x.g.title || '').trim()), 240) : '<p class="gs-note">Name your candidates in step 3.</p>') + '</div>' +
      '<div class="gs-card"><h3>Evidence lights</h3>' + W.lights(S.resources) + '</div>' +
      '<div class="gs-card"><h3>Budget</h3>' + (S.budget.length ? W.budgetBars(S.budget) + '<p class="gs-note">Total ' + C.money(C.budgetTotals(S.budget).total) + '</p>' : '<p class="gs-note">No budget lines yet.</p>') + '</div></div>' +
      '<div class="gs-card"><h3>Project timeline</h3>' + (cal.totalWeeks ? W.weekStrip(S, cal) : '<p class="gs-note">Set your hours in step 1.</p>') + '<div class="gs-legend" style="grid-template-columns:repeat(auto-fit,minmax(150px,1fr))">' + Object.keys(W.CAT).map((k) => '<li><i style="background:' + W.CAT[k][1] + '"></i>' + W.CAT[k][0] + '</li>').join('') + '</div></div>' +
      '<div class="gs-card"><h3>Two documents, one set of facts</h3>' + twinPanel() + '</div>' +
      (isInstructor ? '' : '') + '<p class="gs-note">Studio facts checked ' + esc(D.CHECKED) + '. This is an independent course tool and is not run by the University.</p>';
  }
  function twinPanel() {
    const cc = C.crossCheck(S);
    if (!cc.length) return '<div class="gs-okbox">Aims, sample rule, hours, dates, deliverable and budget agree in the plan, the proposal and the calendar.</div>';
    return '<div class="gs-badbox"><strong>' + cc.length + ' mismatch(es).</strong></div><div class="gs-scroll"><table class="gs-t"><tr><th>Fact</th><th>Plan says</th><th>Proposal says</th><th>System says</th></tr>' + cc.map((x) => '<tr><td>' + esc(x.label) + '</td><td>' + esc(x.plan) + '</td><td>' + esc(x.proposal) + '</td><td>' + esc(x.truth) + '</td></tr>').join('') + '</table></div>';
  }

  // ---------- 1 · Me ----------
  function vMe() {
    const p = S.profile;
    const periods = p.periods.map((x, i) => '<div class="gs-two" style="align-items:end;border-top:1px solid var(--line);padding-top:6px">' + inp('profile.periods.' + i + '.label', 'Period name') + inp('profile.periods.' + i + '.start', 'Start (first Monday)', { type: 'date' }) + inp('profile.periods.' + i + '.end', 'End', { type: 'date' }) + '<div><button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="profile.periods" data-i="' + i + '">Remove</button></div></div>').join('');
    const breaks = p.breaks.map((x, i) => '<div class="gs-two" style="align-items:end;border-top:1px solid var(--line);padding-top:6px">' + inp('profile.breaks.' + i + '.label', 'Break name') + inp('profile.breaks.' + i + '.start', 'Start', { type: 'date' }) + inp('profile.breaks.' + i + '.end', 'End', { type: 'date' }) + '<div><button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="profile.breaks" data-i="' + i + '">Remove</button></div></div>').join('');
    return '<p class="gs-kick">Step 1 of 8</p><h1 class="gs-h1">Start with your real constraints</h1><p class="gs-lede">Research that fits your life gets finished. Tell the studio what you actually have; it turns that into a calendar of hours before you plan any science.</p>' + exampleBanner() + loadExample() +
      '<div class="gs-card"><h3>About you</h3><div class="gs-two">' + inp('profile.name', 'Your name') + inp('profile.major', 'Major (say "declared" if you have declared it)', { ph: 'For example: Biological Sciences (declared)' }) + sel('profile.year', 'Year', ['First-year', 'Sophomore', 'Junior', 'Senior']) + '</div>' + ta('profile.courses', 'Relevant coursework', { rows: 3 }) + ta('profile.skills', 'Skills you have (and what you have never done)', { rows: 3 }) +
      '<label class="gs-f">What kind of research can you realistically do? ' + term('secondary', '(Existing-data is a real option)') + '</label><div class="gs-row">' + [['field', 'Field research'], ['bench', 'Bench research'], ['data', 'Computational or existing-data research']].map((m) => '<label style="display:flex;gap:8px;align-items:center"><input type="radio" name="mode" data-bind="profile.mode" value="' + m[0] + '"' + (p.mode === m[0] ? ' checked' : '') + '> ' + m[1] + '</label>').join('') + '</div>' + inp('profile.modeNote', 'Note about access (optional)') + '</div>' +
      '<div class="gs-card"><h3>Your time</h3><div class="gs-two">' + inp('profile.weeklyHours', 'Hours per week you can commit', { num: 1, min: 1 }) + '</div><p class="gs-note">Weeks that overlap a break count as zero. A funder may require a minimum window (Thomson: two semesters, or a summer plus a semester).</p><h3 style="margin-top:12px">Research periods</h3>' + periods + '<button class="gs-btn3 gs-sm" data-act="addPeriod" style="margin-top:8px">+ Add a period</button><h3 style="margin-top:16px">Academic breaks and weeks you cannot work</h3>' + breaks + '<button class="gs-btn3 gs-sm" data-act="addBreak" style="margin-top:8px">+ Add a break</button></div>' +
      '<div class="gs-card"><h3>How your hours are reserved</h3><div class="gs-grid3">' + Object.keys(W.CAT).map((k) => inp('profile.reserve.' + k, W.CAT[k][0] + ' (%)', { num: 1 })).join('') + '</div><p class="gs-note">Percentages are normalized, so they need not add to exactly 100.</p></div><div id="live"></div>';
  }
  function loadExample() { return (S.meta && S.meta.example) ? '' : '<div class="gs-demo"><strong>Want to see a finished one first?</strong> The worked example is a complete journey (Dr. Rogers, an existing-data project, Thomson Fellowship) on a real public dataset. It replaces your workspace.<div style="margin-top:8px"><button class="gs-btn2 gs-sm" data-act="loadExample">Load the worked example</button></div></div>'; }
  function liveMe() {
    const cal = C.calendar(S.profile); const res = C.reserve(cal.total, S.profile.reserve);
    return '<div class="gs-card gs-glow"><h3>Your calendar</h3>' + (cal.problems.length ? '<div class="gs-badbox">' + esc(cal.problems.join(' ')) + '</div>' : '') + '<div class="gs-grid3"><div class="gs-tile"><small>Total available</small><b>' + cal.total + ' hours</b><span>' + cal.totalWeeks + ' working weeks × ' + cal.weeklyHours + ' h</span></div><div class="gs-tile"><small>Break weeks skipped</small><b>' + cal.allWeeks.filter((w) => w.broke).length + '</b><span>count as zero hours</span></div></div><div style="margin-top:12px">' + W.hoursDonut(res, cal.total) + '</div>' + (cal.totalWeeks ? W.weekStrip(S, cal) : '') + '</div>';
  }

  // ---------- 2 · PI and lab ----------
  const evClass = (id) => { const w = (PIS[id] && PIS[id].works[0]); return w && w.y >= 2024 ? ['ok', 'Active record: ' + w.y] : ['warn', 'Latest indexed paper: ' + (w ? w.y : 'none') + ' (ask)']; };
  function secIdentity() {
    const ex = D.PI_EXTRA[S.pi];
    return '<div class="gs-card"><p style="margin-top:0"><b>Why this step?</b> Before you build a project on someone’s papers, make sure the papers really are theirs. Tick each box only after you have looked, and write one line about what you saw.</p><div class="gs-warnbox"><b>What we found when we checked:</b> ' + esc(ex.identity) + '</div>' + [['affiliation', 'This person works at UW–Parkside (check their faculty page, or the author line on one of their papers)'], ['coauthors', 'Their coauthors fit their field (open the author list of two papers: do the other names look like biologists in the same area?)'], ['history', 'All the papers I plan to use are by this same person (several scientists can share one name; the papers should match the topics on the faculty page)']].map((c) => '<div style="margin:10px 0">' + chk('identityChecks.' + c[0] + '.done', '<b>' + c[1] + '</b>') + ta('identityChecks.' + c[0] + '.note', 'What did you check, and what did you find?', { rows: 2 }) + '</div>').join('') + '</div>';
  }
  function secSources() {
    return '<div class="gs-card"><p class="gs-note">Every source gets a date. Add each page you read; manual entry works for anything.</p>' + S.sources.map((s, i) => '<div class="gs-two" style="border-top:1px solid var(--line);padding-top:6px;align-items:end">' + sel('sources.' + i + '.kind', 'Type', D.SOURCE_KINDS) + inp('sources.' + i + '.title', 'Title') + inp('sources.' + i + '.url', 'Link') + inp('sources.' + i + '.date', 'Date read', { type: 'date' }) + inp('sources.' + i + '.note', 'What it told you') + '<div><button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="sources" data-i="' + i + '">Remove</button></div></div>').join('') + '<button class="gs-btn3 gs-sm" data-act="addSource" style="margin-top:8px">+ Add a source</button></div>';
  }
  function secResources() {
    let h = '<div class="gs-card"><div class="gs-okbox">Two different questions for every resource: <strong>(1)</strong> is there evidence the lab has used it? <strong>(2)</strong> can <em>you</em> use it for this project in your time window? A methods section proves the first, never the second.</div>' + W.lights(S.resources) + '</div>';
    h += S.resources.map((r, i) => '<div class="gs-cand"><div class="gs-spread"><b>' + esc(r.name || 'New resource') + '</b><button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="resources" data-i="' + i + '">Remove</button></div><div class="gs-two">' + sel('resources.' + i + '.kind', 'Kind', ['equipment', 'material', 'organism', 'dataset', 'site', 'software', 'facility', 'training']) + inp('resources.' + i + '.name', 'Name') + '</div>' + chk('resources.' + i + '.critical', 'Critical: the project fails without it') + '<div class="gs-two">' + sel('resources.' + i + '.used', '1 · Evidence the lab has used it', [['method', 'Described in methods or a dataset page'], ['profile', 'Named on a profile or website'], ['title', 'Named in a title or abstract only']]) + inp('resources.' + i + '.usedSrc', 'Source and date') + '</div>' + ta('resources.' + i + '.usedNote', 'What the source says', { rows: 2 }) + inp('resources.' + i + '.role', 'Role in the proposed work') + '<div class="gs-two">' + sel('resources.' + i + '.access', '2 · Can I use it for this project?', [['public', 'Public / open'], ['confirmed', 'Confirmed for this project'], ['unconfirmed', 'NOT confirmed']]) + inp('resources.' + i + '.accessNote', 'What is known about my access') + '</div>' + ta('resources.' + i + '.route', 'If access fails, the plan B (required for a critical, unconfirmed resource)', { rows: 2 }) + '</div>').join('');
    return h + '<button class="gs-btn2" data-act="addResource">+ Add a resource</button>';
  }
  function vPi() {
    if (S.pi) return window.StudioLab.view();
    const cards = RM.FACULTY.map((x) => { const e = evClass(x.id); return '<button type="button" class="gs-pi" data-act="pickPi" data-id="' + x.id + '" aria-pressed="' + (S.pi === x.id) + '"><img class="fac-photo" src="/BIOS102/img/researchers/' + x.id + '.webp" alt="Photo badge of ' + esc(x.honorific + ' ' + x.last) + '" width="72" height="72"><div><b>' + esc(x.honorific + ' ' + x.name) + '</b><span>' + esc(x.oneLine) + '</span><br><span class="gs-chip ' + e[0] + '">' + esc(e[1]) + '</span></div></button>'; }).join('');
    return '<p class="gs-kick">Step 2 of 8</p><h1 class="gs-h1">Choose a PI to investigate</h1><p class="gs-lede">A ' + term('PI') + ' is the faculty member who leads the research. Choose one and the studio opens that researcher\u2019s page: you will verify who they are, collect and read their papers and the closest ongoing work in your own reference library, and find the gaps worth a question. Every researcher with an active research program in the department is below.</p>' + exampleBanner() + '<div class="gs-grid3" style="grid-template-columns:repeat(auto-fill,minmax(270px,1fr))">' + cards + '</div>';
  }

  // ---------- 3 · Gap arena ----------
  function vGaps() {
    S.weights = S.weights || {};
    const ev = S.library.evidence;
    const intro = '<p class="gs-kick">Step 3 of 8 \u00b7 the core of the system</p><h1 class="gs-h1">The Gap Arena</h1><p class="gs-lede">A ' + term('gap') + ' is a specific question the sources leave open. You collected the evidence on the PI\u2019s page; here you turn it into at least three candidate contributions, screen out any that cannot work, and compare the rest by reasons you can show.</p>' + exampleBanner();
    const overview = pg('Your evidence', 'Look over the evidence you collected. Add another candidate if you need one.') + '<div class="gs-card gs-glow"><h3>What you are working from</h3><p>' + ev.length + ' evidence card(s) from ' + new Set(ev.map((e) => e.item)).size + ' paper(s). Each candidate below must cite at least one.</p>' + (ev.length ? '<div class="gs-evpick">' + ev.map((e) => { const it = S.library.items.find((x) => x.id === e.item); return '<div class="gs-evbtn"><span class="gs-chip cy">' + esc((window.StudioLab.EV_TYPES.find((t) => t[0] === e.type) || [0, e.type])[1].split(' ').slice(0, 3).join(' ')) + '</span> ' + esc(it ? window.StudioLib.citeLabel(it) : '?') + ': \u201c' + esc(e.quote.slice(0, 140)) + (e.quote.length > 140 ? '\u2026' : '') + '\u201d</div>'; }).join('') + '</div>' : '<div class="gs-warnbox">No evidence yet. Go back to the PI\u2019s page and collect some.</div>') + '<div class="gs-row" style="margin-top:10px"><button class="gs-btn3" data-act="go" data-v="pi">Back to the PI\u2019s page</button><button class="gs-btn3" data-act="addGap">+ Add another candidate</button></div></div>';
    const cands = S.gaps.map((g, i) => {
      const sc = C.gapScreen(g); const n = i + 1; const tag = (sc.out ? '<span class="gs-chip block">Screened out</span>' : '<span class="gs-chip ok">In the running</span>');
      const head = '<div class="gs-spread"><b>Candidate ' + n + '</b><span>' + tag + ' <button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="gaps" data-i="' + i + '">Remove</button></span></div>';
      const a = pg('Candidate ' + n + ': name and evidence', 'Give this idea a one-line name, and tick the evidence cards that support it.') + '<div class="gs-cand' + (sc.out ? ' out' : '') + '">' + head + inp('gaps.' + i + '.title', 'Name the contribution in one line') + evPick(g, i) + '</div>';
      const b = pg('Candidate ' + n + ': eight questions', 'Answer each question in a sentence or two. "I do not know yet" is an allowed answer.') + '<div class="gs-cand' + (sc.out ? ' out' : '') + '"><div class="gs-spread"><b>Candidate ' + n + ': ' + esc(g.title || 'untitled') + '</b>' + tag + '</div><p class="gs-note">Answer every question in your own words. Where you do not know, say so: that is an honest answer.</p>' + D.GAP_QUESTIONS.map((q) => ta('gaps.' + i + '.a.' + q[0], q[1], { rows: 2 })).join('') + '</div>';
      const c = pg('Candidate ' + n + ': needs and scores', 'List what it depends on, then score it honestly from 1 to 5.') + '<div class="gs-cand' + (sc.out ? ' out' : '') + '"><div class="gs-spread"><b>Candidate ' + n + ': ' + esc(g.title || 'untitled') + '</b>' + tag + '</div><h3 style="margin-top:8px">What it depends on</h3>' + (g.dependencies || []).map((d, k) => '<div class="gs-two" style="border-top:1px solid var(--line);padding-top:6px;align-items:end">' + inp('gaps.' + i + '.dependencies.' + k + '.text', 'Something this needs') + inp('gaps.' + i + '.dependencies.' + k + '.route', 'Route to resolve it (blank = none)') + '<div>' + chk('gaps.' + i + '.dependencies.' + k + '.critical', 'Critical') + '<button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="gaps.' + i + '.dependencies" data-i="' + k + '">Remove</button></div></div>').join('') + '<button class="gs-btn3 gs-sm" data-act="addDep" data-i="' + i + '" style="margin-top:6px">+ Add a dependency</button>' + chk('gaps.' + i + '.feasibleHours', 'It fits the hours I have, including analysis and reporting') +
        '<h3 style="margin-top:12px">Score each criterion 1 to 5 (be honest)</h3><div class="gs-two">' + D.CRITERIA.map((cr) => '<div><label class="gs-f" for="sc-' + i + cr.id + '">' + esc(cr.label) + ': <b data-sv="gaps.' + i + '.score.' + cr.id + '">' + (g.score && g.score[cr.id] || 0) + '</b></label><input id="sc-' + i + cr.id + '" type="range" min="1" max="5" step="1" data-num="1" data-bind="gaps.' + i + '.score.' + cr.id + '" value="' + (g.score && g.score[cr.id] || 3) + '"></div>').join('') + '</div>' +
        (sc.out ? '<div class="gs-badbox">' + esc(sc.why.join(' ')) + '</div>' : '<h3 style="margin-top:12px">Literature check (required for finalists)</h3>' + litForm(g, S.litChecks.find((l) => l.gapId === g.id))) + '</div>';
      return a + b + c;
    }).join('');
    const w = D.CRITERIA.map((c) => '<div><label class="gs-f" for="w-' + c.id + '">' + esc(c.label) + ': <b data-sv="weights.' + c.id + '">' + (S.weights[c.id] != null ? S.weights[c.id] : c.w) + '</b></label><input id="w-' + c.id + '" type="range" min="0" max="5" step="1" data-num="1" data-bind="weights.' + c.id + '" value="' + (S.weights[c.id] != null ? S.weights[c.id] : c.w) + '"></div>').join('');
    const compare = pg('Compare and rank', 'Move the sliders and watch the ranking. Does the winner change?') + '<div class="gs-card gs-glow"><h3>Weigh what matters (a live ranking)</h3><p class="gs-note">Move a slider and watch the order change. If the winner changes when you change a weight, the choice is fragile; say so.</p><div class="gs-two">' + w + '</div><button class="gs-btn3 gs-sm" data-act="resetWeights" style="margin-top:8px">Reset weights</button><div id="live"></div></div>';
    const choose = pg('Choose and justify', 'Pick one candidate and explain why in a few sentences.') + '<div class="gs-card"><h3>Your choice</h3>' + sel('chosenGap', 'Chosen contribution', S.gaps.map((g) => [g.id, g.title || g.id])) + ta('justification', 'Why this one, and why it fits better than the others? (at least 40 words)', { rows: 5 }) + '<div class="gs-count" data-wc="justification" data-limit="0"></div>' + exBox(!S.meta.example ? D.EXAMPLE.justification : '') + '</div>';
    return intro + overview + cands + compare + choose;
  }
  function evPick(g, i) {
    const ev = S.library.evidence; const sel2 = (g.evidence || []);
    return '<h3 style="margin-top:12px">Evidence from your library <span class="gs-count">(' + sel2.filter((id) => ev.some((e) => e.id === id)).length + ' linked)</span></h3>' + (ev.length ? '<div class="gs-evpick">' + ev.map((e) => { const it = S.library.items.find((x) => x.id === e.item); const on = sel2.indexOf(e.id) >= 0; return '<button type="button" class="gs-evbtn' + (on ? ' on' : '') + '" aria-pressed="' + on + '" data-act="toggleEv" data-i="' + i + '" data-id="' + e.id + '"><span class="gs-chip cy">' + esc((window.StudioLab.EV_TYPES.find((t) => t[0] === e.type) || [0, e.type])[1].split(' ').slice(0, 3).join(' ')) + '</span> ' + esc(it ? window.StudioLib.citeLabel(it) : '?') + ': \u201c' + esc(e.quote.slice(0, 120)) + (e.quote.length > 120 ? '\u2026' : '') + '\u201d</button>'; }).join('') + '</div>' : '<p class="gs-note">No evidence cards yet. <a href="#" data-act="go" data-v="pi">Collect evidence on the PI\u2019s page</a>.</p>');
  }
  function litForm(g, lc) {
    const i = S.litChecks.findIndex((l) => l.gapId === g.id); if (i < 0) return '<button class="gs-btn2 gs-sm" data-act="addLit" data-id="' + g.id + '">Start the literature check</button>';
    return '<button class="gs-btn3 gs-sm" data-act="fillLit" data-i="' + i + '">Fill from my search log</button><div class="gs-two">' + inp('litChecks.' + i + '.sources', 'Databases or sources searched') + inp('litChecks.' + i + '.date', 'Date searched') + '</div>' + ta('litChecks.' + i + '.terms', 'Search terms', { rows: 2 }) + ta('litChecks.' + i + '.closest', 'Closest related work you found', { rows: 2 }) + ta('litChecks.' + i + '.limits', 'The limits of your search (what you could not see)', { rows: 2 });
  }
  function liveGaps() {
    const rk = C.rankGaps(S.gaps, S.weights); const named = rk.live.filter((r) => (r.g.title || '').trim());
    return '<div class="gs-grid" style="margin-top:14px"><div><h3>Ranking</h3>' + (named.map((r) => '<div style="margin:8px 0"><div class="gs-spread"><span>#' + r.rank + ' ' + esc(r.g.title) + '</span><b>' + r.pct + '</b></div><div class="gs-bar"><i style="width:' + r.pct + '%"></i></div></div>').join('') || '<p class="gs-note">Name your candidates to rank them.</p>') + rk.out.map((r) => '<div class="gs-badbox" style="margin-top:8px"><b>Screened out: ' + esc(r.g.title || '(untitled)') + '</b><br>' + esc(r.why.join(' ')) + '</div>').join('') + '</div><div>' + (named.length ? W.radar(named, 250) : '') + '</div></div>';
  }

  // ---------- 4 · Research plan ----------
  const PLAN_LABEL = { observation: 'Observation: what I noticed in the papers (cite them with [@key])', question: 'Research question: the question that observation raises', answer: 'Proposed answer to the question (my hypothesis): "I propose that ... because ..."', prediction: 'Prediction: "If my proposed answer is correct, then ..." and what result would reject it', background: 'Background', evidence: 'Supporting evidence (cite the papers)', gap: 'The gap', question: 'Research question', aims: 'Specific aims (write "Aim 1.", "Aim 2." ...)', variables: 'Variables, units, observations, metadata, missing data, exclusions and quality checks', analysis: 'Analysis plan, planned tables and figures', interpretation: 'Interpretation: supportive, contradictory and inconclusive results', approvals: 'Training, supervision, data permissions, field access, safety and approvals', handoff: 'Final handoff to the lab' };
  function factsEditor(base, title) {
    return '<div class="gs-card gs-glow"><h3>' + title + ' · key facts (must match the other document)</h3><p class="gs-note">The studio compares these between your plan, your proposal, the calendar and the budget.</p><div class="gs-two">' + Object.keys(C.FACT_LABEL).map((k) => (k === 'aimTitles' || k === 'deliverable') ? '<div style="grid-column:1/-1">' + ta(base + '.facts.' + k, C.FACT_LABEL[k], { rows: 2 }) + '</div>' : inp(base + '.facts.' + k, C.FACT_LABEL[k], { num: (k === 'aimCount' || k === 'minReplicates' || k === 'totalHours' || k === 'budgetTotal') ? 1 : 0, type: (k === 'startDate' || k === 'endDate') ? 'date' : 'text' })).join('') + '</div><div style="margin-top:8px"><button class="gs-btn3 gs-sm" data-act="fillFacts" data-b="' + base + '">Fill the system-known facts (hours, dates, budget) from my calendar and budget</button></div></div>';
  }
  function vPlan() {
    const ex = D.EXAMPLE.plan.sections;
    const secs = (keys) => keys.map((k) => '<div class="gs-card"><div class="gs-spread"><h3>' + PLAN_LABEL[k] + '</h3>' + statusSel('plan.' + k) + '</div>' + ta('plan.sections.' + k, '', { rows: 5 }) + '<div class="gs-count" data-wc="plan.sections.' + k + '"></div>' + (S.meta.example ? '' : exBox(ex[k])) + '</div>').join('');
    const exps = S.plan.experiments.map((e, i) => '<div class="gs-cand"><div class="gs-spread"><b>Experiment or analysis ' + (i + 1) + '</b><button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="plan.experiments" data-i="' + i + '">Remove</button></div><div class="gs-two">' + inp('plan.experiments.' + i + '.title', 'Title') + inp('plan.experiments.' + i + '.aim', 'Which aim it serves (e.g. Aim 1)') + '</div>' + [['design', 'Design'], ['materials', 'Materials and quantities'], ['equip', 'Equipment or software'], ['methods', 'Methods (cite published methods; mark what needs lab-specific review)'], ['controls', 'Controls or comparison groups'], ['replication', 'Biological and technical ' + 'replication'], ['sample', 'Sample-size rationale'], ['decision', 'The decision or question that matters to the lab']].map((f) => ta('plan.experiments.' + i + '.' + f[0], f[1], { rows: 2 })).join('') + '</div>').join('');
    const sch = S.plan.schedule.map((p, i) => '<div class="gs-two" style="border-top:1px solid var(--line);padding-top:6px;align-items:end">' + inp('plan.schedule.' + i + '.from', 'From week', { num: 1, min: 1 }) + inp('plan.schedule.' + i + '.to', 'To week', { num: 1, min: 1 }) + inp('plan.schedule.' + i + '.label', 'Work') + Object.keys(W.CAT).map((k) => inp('plan.schedule.' + i + '.cat.' + k, W.CAT[k][0] + ' h', { num: 1 })).join('') + '<div><button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="plan.schedule" data-i="' + i + '">Remove</button></div></div>').join('');
    const head = '<p class="gs-kick">Step 4 of 8 \u00b7 standalone document 1</p><h1 class="gs-h1">The complete research plan</h1><p class="gs-lede">The plan follows the chain of a proposal: an observation raises a question, you propose an answer, the answer makes a prediction, and your materials and methods are the experiment that tests it. You stop at the design. Be specific enough that the PI can judge feasibility without guessing, and cite published methods.</p>' + exampleBanner();
    return head + pg('The chain', 'Look at the seven links. Each one opens the screen where you do it. Then press Next.') + chainCard() + '<div class="gs-card">' + inp('plan.title', 'Project title') + '</div>' + citeBar() +
      pg('1 \u00b7 Observation', 'Write what you noticed in the papers, in one or two sentences, with a citation.') + secs(['observation']) + pg('2 \u00b7 Question', 'Turn the observation into one question. End it with a question mark.') + secs(['question']) + pg('3 \u00b7 Proposed answer', 'Say what you think the answer is, and why: "I propose that ... because ...".') + secs(['answer']) + pg('4 \u00b7 Prediction', 'Write: "If my answer is right, then ..." and what result would show you were wrong.') + secs(['prediction']) +
      pg('Background, evidence, gap, aims') + secs(['background', 'evidence', 'gap', 'aims']) + pg('Key facts') + factsEditor('plan', 'Research plan') +
      pg('5 \u00b7 Materials and methods', 'Describe the experiment that tests the prediction. Add one experiment at a time.') + '<div class="gs-card"><h3>Materials and methods: the design that tests the prediction</h3><p class="gs-note">This is where the proposal stops. You are proposing to do this work to get the data that will show whether your proposed answer is supported.</p>' + exps + '<button class="gs-btn2" data-act="addExp">+ Add an experiment or analysis</button></div>' +
      pg('Variables, analysis, interpretation') + secs(['variables', 'analysis', 'interpretation']) +
      pg('Schedule and fallback') + '<div class="gs-card"><h3>Week-by-week schedule</h3><p class="gs-note">Each phase must use exactly the hours its weeks hold, and the phases must cover every working week once.</p>' + sch + '<button class="gs-btn3 gs-sm" data-act="addPhase" style="margin-top:8px">+ Add a phase</button></div><div class="gs-card"><h3>Fallback</h3><div class="gs-two">' + inp('plan.fallback.switchByWeek', 'Latest week you can switch and still finish', { num: 1 }) + inp('plan.fallback.hoursNeeded', 'Hours the fallback needs', { num: 1 }) + '</div>' + ta('plan.fallback.note', 'What the fallback is, and the meaningful question it still answers', { rows: 3 }) + '</div><div id="live"></div>' +
      pg('Approvals and handoff') + secs(['approvals', 'handoff']);
  }
  function chainCard() {
    return '<div class="gs-card gs-glow"><h3>The chain of a research proposal</h3>' + W.chain(S) + '<p class="gs-note">Each link comes from the one before it: an <b>observation</b> in the papers raises a <b>question</b>; you give a <b>proposed answer</b>; the answer makes a <b>prediction</b> you can measure; the <b>materials and methods</b> are the experiment that checks the prediction. You stop at the design.</p></div>';
  }
  function citeBar() {
    const items = S.library.items.slice().sort((a, b) => a.key.localeCompare(b.key));
    return '<div class="gs-card"><div class="gs-row" style="align-items:end"><div style="flex:1;min-width:220px"><label class="gs-f" for="citeSel">Cite a paper from your library</label><select class="gs-sel" id="citeSel">' + items.map((i) => '<option value="' + esc(i.key) + '">' + esc(window.StudioLib.citeLabel(i) + ' \u00b7 ' + i.title.slice(0, 70)) + '</option>').join('') + '</select></div><button class="gs-btn2" data-act="insCite">Insert at the cursor</button></div><p class="gs-note">Click in a text box first. The citation appears as [@key] and prints as (Author Year); references build themselves.</p></div>';
  }
  function livePlan() {
    const cal = C.calendar(S.profile); const sch = C.checkSchedule(S.plan, cal); const dr = C.reserveDrift(S.plan, cal, S.profile.reserve); const tot = C.scheduleTotals(S.plan);
    const fb = S.plan.fallback; const rem = cal.weeklyHours * Math.max(0, cal.totalWeeks - fb.switchByWeek);
    return '<div class="gs-card gs-glow"><h3>Schedule checks (live)</h3>' + (sch.length ? sch.map((x) => '<div class="gs-badbox">' + esc(x.text) + '</div>').join('') : '<div class="gs-okbox">The schedule covers all ' + cal.totalWeeks + ' working weeks and every phase uses exactly its hours.</div>') + (dr.length ? '<div class="gs-warnbox">Hours differ from your reserves: ' + esc(dr.map((d) => d.cat + ' planned ' + d.have + ' vs ' + d.target).join('; ')) + '</div>' : '') + (fb.switchByWeek > 0 ? '<div class="' + (fb.hoursNeeded <= rem ? 'gs-okbox' : 'gs-badbox') + '">Fallback horizon: after week ' + fb.switchByWeek + ' you have ' + rem + ' hours; the fallback needs ' + fb.hoursNeeded + (fb.hoursNeeded <= rem ? ' (margin ' + (rem - fb.hoursNeeded) + ' h).' : '. That is too late: move the switch week earlier.') + '</div>' : '') + W.hoursDonut(tot, Object.values(tot).reduce((a, b) => a + b, 0)) + (cal.totalWeeks ? W.weekStrip(S, cal) : '') + '</div>';
  }

  // ---------- 5 · Funding ----------
  function vFund() {
    const fs = D.FUNDERS.concat(S.customFunders || []);
    const row = (label, fn) => '<tr><th>' + label + '</th>' + fs.map((f) => '<td>' + fn(f) + '</td>').join('') + '</tr>';
    const cell = (v) => { const t = String(v || ''); return /^NOT STATED/.test(t) ? '<span class="gs-chip warn">UNVERIFIED</span> ' + esc(t) : esc(t); };
    const t = '<div class="gs-scroll"><table class="gs-t"><tr><th></th>' + fs.map((f) => '<th>' + esc(f.name) + '</th>').join('') + '</tr>' +
      row('Official source', (f) => '<a target="_blank" rel="noopener" href="' + esc(f.source) + '">link</a>') + row('Verified on', (f) => esc(f.verified)) + row('Cycle status', (f) => cell(f.status)) + row('Deadline', (f) => cell(f.deadline)) + row('Award period', (f) => cell(f.period)) + row('Eligible applicants', (f) => cell(f.eligibility)) + row('Award', (f) => cell(f.amount)) + row('Permitted expenses', (f) => cell(f.expenses)) + row('Submission route', (f) => cell(f.route)) + row('Mentor involvement', (f) => cell(f.mentor)) + row('Application materials', (f) => cell(f.materials)) + row('Reporting', (f) => cell(f.reporting)) + row('Student writes', (f) => cell(f.roles.writes)) + row('Submits', (f) => cell(f.roles.submits)) + row('Administers the money', (f) => cell(f.roles.administers)) + '</table></div>';
    const prim = C.funder(S.funding.primary);
    const res = prim ? (prim.unverified || []).map((u) => ta('funding.resolutions.' + prim.id + '|' + u, 'Unverified: ' + u + '. How did you resolve it?', { rows: 2 })).join('') : '';
    const bud = S.budget.map((b, i) => '<div class="gs-two" style="border-top:1px solid var(--line);padding-top:6px;align-items:end">' + inp('budget.' + i + '.item', 'Item') + inp('budget.' + i + '.amount', 'Amount ($)', { num: 1 }) + sel('budget.' + i + '.pay', 'Paid as', [['student', 'Student stipend'], ['supplies', 'Supplies (through advisor)'], ['other', 'Other']]) + inp('budget.' + i + '.linksTo', 'The activity it supports') + inp('budget.' + i + '.basis', 'Basis (call amount, or ASSUMPTION)') + '<div><button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="budget" data-i="' + i + '">Remove</button></div></div>').join('');
    return '<p class="gs-kick">Step 5 of 8</p><h1 class="gs-h1">Match the project to real funding</h1><p class="gs-lede">Three different people are involved in a grant: the one who <em>writes</em> it, the one who <em>submits</em> it, and the one who <em>administers</em> the money. Anything the official page did not state is marked UNVERIFIED until you record how you found out. If the funding rules change what is feasible, go back to the Gap Arena.</p>' + exampleBanner() + '<div class="gs-card gs-glow">' + t + '<div class="gs-row" style="margin-top:10px"><button class="gs-btn3 gs-sm" data-act="addFunder">+ Add an outside opportunity</button></div></div>' +
      '<div class="gs-card"><div class="gs-two">' + sel('funding.primary', 'Primary opportunity', fs.map((f) => [f.id, f.name]), { rerender: 1 }) + sel('funding.alt', 'Alternative to assess', fs.map((f) => [f.id, f.name]), { rerender: 1 }) + '</div>' + ta('funding.altAssessment', 'Assess the alternative against your project: duration, eligibility, budget, supervision', { rows: 4 }) + exBox(!S.meta.example ? D.EXAMPLE.funding.altAssessment : '') + res + '</div><div id="live"></div>' +
      '<h2 class="gs-h2">Budget and justification</h2><div class="gs-card">' + bud + '<button class="gs-btn3 gs-sm" data-act="addBudget" style="margin-top:8px">+ Add a budget line</button><p class="gs-note">Every line must name the activity it supports; the studio blocks the packet otherwise.</p></div>';
  }
  function liveFund() {
    const fc = C.fundingCheck(S); const bt = C.budgetTotals(S.budget);
    return '<div class="gs-card gs-glow"><h3>Eligibility and fit (live)</h3>' + (fc.length ? fc.map((x) => '<div class="' + (x.level === 'block' ? 'gs-badbox' : 'gs-warnbox') + '">' + esc(x.text) + '</div>').join('') : '<div class="gs-okbox">All checks pass.</div>') + '<p>Budget total <b>' + C.money(bt.total) + '</b> · student ' + C.money(bt.student) + ' · supplies ' + C.money(bt.supplies) + '</p>' + (S.budget.length ? W.budgetBars(S.budget) : '') + '</div>';
  }

  // ---------- 6 · Proposal ----------
  function vPro() {
    const f = C.funder(S.funding.primary); const ex = D.EXAMPLE.proposal.sections;
    const secs = S.proposal.sections.map((s, i) => { const e = ex.find((x) => x.id === s.id); return '<div class="gs-card"><div class="gs-spread"><h3>' + esc(s.title) + '</h3>' + statusSel('pro.' + s.id) + '</div>' + ta('proposal.sections.' + i + '.text', '', { rows: 6, limit: s.limit || 0 }) + (S.meta.example || !e ? '' : exBox(e.text)) + '</div>'; }).join('');
    const refRows = (window.StudioLib.refList(S).map((r) => '<div class="gs-note" style="margin:6px 0"><span class="gs-chip cy">' + esc(r.id) + '</span> ' + esc(r.cite) + (r.doi ? ' <a target="_blank" rel="noopener" href="https://doi.org/' + esc(r.doi) + '">doi:' + esc(r.doi) + '</a>' : ' <span class="gs-chip warn">no DOI</span>') + '</div>').join('')) || '<p class="gs-note">Nothing is cited yet.</p>';
    const refs0 = S.refs.map((r, i) => '<div class="gs-two" style="border-top:1px solid var(--line);padding-top:6px;align-items:end"><div style="grid-column:span 2">' + inp('refs.' + i + '.cite', 'Reference (' + esc(r.id) + ')') + '</div>' + inp('refs.' + i + '.doi', 'DOI') + '<div><button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="refs" data-i="' + i + '">Remove</button></div></div>').join('');
    const claims = S.claims.map((c, i) => '<div class="gs-two" style="border-top:1px solid var(--line);padding-top:6px;align-items:end"><div style="grid-column:span 2">' + inp('claims.' + i + '.text', 'A scientific claim you make') + '</div>' + sel('claims.' + i + '.ref', 'Source', window.StudioLib.refList(S).map((r) => [r.id, r.id + ' · ' + r.cite.slice(0, 40)])) + '<div>' + chk('claims.' + i + '.verified', 'I checked this against the source') + '<button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="claims" data-i="' + i + '">Remove</button></div></div>').join('');
    const proCite = citeBar();
    return '<p class="gs-kick">Step 6 of 8 · standalone document 2</p><h1 class="gs-h1">The grant proposal</h1><p class="gs-lede">Written for ' + esc(f ? f.name : 'your funder') + '. You must be able to explain every claim, so every claim goes in the ledger below and you tick it only after checking the source yourself.</p>' + exampleBanner() +
      proCite + '<div class="gs-warnbox">' + esc(S.proposal.modelNote) + '</div><div class="gs-card"><h3>Load the funder’s real requirements</h3><p class="gs-note">Paste the official sections, one per line, as <code>Section title | word limit</code>. Sections with the same title keep your text.</p><textarea class="gs-ta" id="reqbox" placeholder="Summary | 150&#10;Project description | 600"></textarea><div style="margin-top:8px"><button class="gs-btn2 gs-sm" data-act="loadReq">Use these sections</button></div></div>' +
      factsEditor('proposal', 'Grant proposal') + secs +
      '<h2 class="gs-h2">Budget</h2><div class="gs-card"><div id="live"></div><p class="gs-note">Edit lines in step 5. They print inside this proposal.</p></div>' +
      '<h2 class="gs-h2">References</h2><div class="gs-card"><p>References build themselves from the papers you cite with <code>[@key]</code> anywhere in your documents. To add a paper, put it in <a href="#" data-act="go" data-v="pi">the PI\u2019s library</a>.</p>' + refRows + '</div>' +
      '<h2 class="gs-h2">Claim ledger</h2><div class="gs-card">' + claims + '<button class="gs-btn3 gs-sm" data-act="addClaim" style="margin-top:8px">+ Add a claim</button></div>';
  }
  function livePro() { const bt = C.budgetTotals(S.budget); return S.budget.length ? '<div class="gs-scroll"><table class="gs-t"><tr><th>Item</th><th>Amount</th><th>Supports</th></tr>' + S.budget.map((b) => '<tr><td>' + esc(b.item) + '</td><td>' + C.money(b.amount) + '</td><td>' + esc(b.linksTo) + '</td></tr>').join('') + '<tr><th>Total</th><th>' + C.money(bt.total) + '</th><th></th></tr></table></div>' + twinPanel() : '<p class="gs-note">No budget lines yet.</p>'; }

  // ---------- 7 · Defend and meet ----------
  function vMeet() {
    const r = R(); const em = S.meeting.email || C.emailDraft(S);
    const pend = (S.pending || []).map((x, i) => '<div class="gs-row" style="margin:4px 0"><input class="gs-in" style="flex:1" data-bind="pending.' + i + '" value="' + esc(x) + '" aria-label="Pending action"><button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="pending" data-i="' + i + '">Remove</button></div>').join('');
    const blockers = r.blocks.concat(r.warns);
    return '<p class="gs-kick">Step 7 of 8</p><h1 class="gs-h1">Defend it, then ask for the meeting</h1><p class="gs-lede">The first PI conversation happens <em>after</em> both documents are complete. You are walking in able to say: <em>I studied your work, compared three possible contributions, selected this one because it fits the science and the time I have, and wrote the full proposal and research plan. Here are the decisions I need your help with before I submit.</em></p>' + exampleBanner() +
      (blockers.length ? '<div class="' + (r.blocks.length ? 'gs-badbox' : 'gs-warnbox') + '"><strong>' + (r.blocks.length ? 'Not ready to contact the PI.' : 'Almost ready.') + '</strong><ul style="margin:6px 0 0 18px">' + blockers.map((i) => '<li><a href="#" data-act="go" data-v="' + i.view + '">' + esc(i.label) + '</a>: ' + esc(i.detail) + '</li>').join('') + '</ul><p class="gs-note">You can still export, but the packet will be stamped DRAFT: NOT READY FOR OUTREACH.</p></div>' : '<div class="gs-okbox"><strong>Ready.</strong> Every gate is clear. External signatures and PI commitments stay as pending actions below.</div>') +
      '<div class="gs-card gs-glow"><h3>Oral defense: answer in your own words</h3>' + ta('defense.gap', 'Explain the gap you chose', { rows: 3 }) + ta('defense.comparison', 'Defend the proposed comparison or controls', { rows: 3 }) + ta('defense.analysis', 'Describe the analysis', { rows: 3 }) + ta('defense.assumption', 'Name the assumption most likely to change the project', { rows: 3 }) + exBox(!S.meta.example ? D.EXAMPLE.defense.gap : '') + '</div>' +
      '<div class="gs-card gs-glow"><h3>Interactive defense deck</h3><p>A full-screen, keyboard-driven walk through your work, built live from your own documents. No slides to maintain.</p><button class="gs-btn gs-bigbtn" data-act="deck">Open the defense deck</button></div>' +
      '<div class="gs-card"><h3>Pending signatures, letters and commitments</h3><p class="gs-note">List what must come from other people. Never mark these done yourself.</p>' + pend + '<button class="gs-btn3 gs-sm" data-act="addPending" style="margin-top:8px">+ Add a pending action</button></div>' +
      '<div class="gs-card"><h3>Faculty meeting packet</h3><p>Proposal · research plan · one-page decision sheet · outreach email. Your decision sheet lists ' + C.decisions(S).length + ' decisions.</p><div class="gs-row"><button class="gs-btn" data-act="printPacket">Print the full packet</button><button class="gs-btn2" data-act="dlPacket">Save packet (HTML)</button><button class="gs-btn2" data-act="printPro">Print proposal only</button><button class="gs-btn2" data-act="printPlan">Print research plan only</button><button class="gs-btn2" data-act="printDec">Print decision sheet</button><button class="gs-btn3" data-act="dlPro">Save proposal</button><button class="gs-btn3" data-act="dlPlan">Save plan</button></div><p class="gs-note">Print or choose "Save as PDF" in the print window.</p></div>' +
      '<div class="gs-card"><h3>Outreach email (you press send)</h3><div class="gs-two">' + '<div><label class="gs-f" for="em-to">To</label><input class="gs-in" id="em-to" data-em="to" value="' + esc(em.to) + '"></div><div><label class="gs-f" for="em-sub">Subject</label><input class="gs-in" id="em-sub" data-em="subject" value="' + esc(em.subject) + '"></div></div><label class="gs-f" for="em-body">Message</label><textarea class="gs-ta" id="em-body" data-em="body" style="min-height:260px">' + esc(em.body) + '</textarea><div class="gs-row" style="margin-top:8px"><a class="gs-btn" id="mailto" href="' + esc(mailtoOf(em)) + '">Open in my email app</a><button class="gs-btn2" data-act="copyEmail">Copy the message</button><button class="gs-btn3" data-act="resetEmail">Rebuild from my documents</button></div><p class="gs-note">Nothing is sent by this page. Attach the packet yourself. Outreach stays under your control.</p></div>';
  }
  const mailtoOf = (em) => 'mailto:' + encodeURIComponent(em.to || '').replace(/%40/g, '@') + '?subject=' + encodeURIComponent(em.subject || '') + '&body=' + encodeURIComponent(em.body || '');

  // ---------- 8 · After ----------
  function vAfter() {
    const dec = S.meeting.decisions.map((d, i) => '<div class="gs-cand"><div class="gs-two">' + inp('meeting.decisions.' + i + '.ask', 'Decision asked') + inp('meeting.decisions.' + i + '.said', 'What the PI said') + inp('meeting.decisions.' + i + '.change', 'Change this requires (document and section)') + '</div>' + chk('meeting.decisions.' + i + '.done', 'I made the change and re-ran the checks') + '<button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="meeting.decisions" data-i="' + i + '">Remove</button></div>').join('');
    const log = S.submission.log.map((l, i) => '<div class="gs-row" style="margin:4px 0"><span class="gs-chip cy">' + esc(l.date) + '</span> ' + esc(l.text) + ' <button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="submission.log" data-i="' + i + '">x</button></div>').join('');
    return '<p class="gs-kick">Step 8 of 8</p><h1 class="gs-h1">After the meeting: revise, submit, track</h1><p class="gs-lede">Record each decision, change both documents, and re-run the checks. You decide when to submit; the studio only keeps the record.</p>' + exampleBanner() +
      '<div class="gs-card">' + sel('meeting.status', 'Meeting status', ['not started', 'requested', 'scheduled', 'held', 'follow-up needed']) + ta('meeting.notes', 'Notes from the meeting', { rows: 4 }) + '</div><h2 class="gs-h2">Decisions and revisions</h2>' + dec + '<button class="gs-btn2" data-act="addDecision">+ Record a decision</button>' +
      '<h2 class="gs-h2">Readiness for submission</h2><div class="gs-card">' + W.gates(R().items) + '</div><h2 class="gs-h2">Submission and decision</h2><div class="gs-card">' + sel('submission.status', 'Where this stands', ['Draft', 'Revising after PI meeting', 'Ready to submit', 'Submitted', 'Awarded', 'Declined', 'Resubmitting']) + '<label class="gs-f" for="logt">Add a dated note</label><div class="gs-row"><input class="gs-in" id="logt" style="flex:1" placeholder="Submitted to the Dean’s office"><button class="gs-btn2 gs-sm" data-act="addLog">Add</button></div><div style="margin-top:10px">' + log + '</div></div>';
  }

  // ---------- instructor review ----------
  function vReview() {
    const r = R(); const rows = r.items.map((i) => '<tr><td>' + esc(i.label) + '</td><td><span class="gs-chip ' + i.level + '">' + W.LVL[i.level][1] + '</span></td><td>' + esc(i.detail) + '</td><td><input class="gs-in" data-bind="review.notes.' + i.id + '" value="' + esc(S.review.notes[i.id] || '') + '" aria-label="Instructor comment for ' + esc(i.label) + '"></td></tr>').join('');
    return '<p class="gs-kick">Instructors</p><h1 class="gs-h1">Instructor review</h1><p class="gs-lede">The same checks the student sees, with a column for your comments. To review a student, ask them for their backup file and use "Restore" in Backup and data (export your own workspace first). Comments print with the review sheet.</p><div class="gs-card"><div class="gs-scroll"><table class="gs-t"><tr><th>Gate</th><th>Status</th><th>Detail</th><th>Your comment</th></tr>' + rows + '</table></div></div><div class="gs-card">' + ta('review.signoff', 'Overall review comment and sign-off', { rows: 4 }) + '<div class="gs-row" style="margin-top:8px"><button class="gs-btn2" data-act="printReview">Print the review sheet</button></div></div>';
  }
  function vData() {
    return '<p class="gs-kick">Your data</p><h1 class="gs-h1">Backup and data</h1><p class="gs-lede">Your work is saved in this browser only. A backup file contains everything you typed, so keep it private. Use the backup to move to another computer or to share with an instructor.</p>' + '<div class="gs-card"><p>' + (saveOk ? 'Saved in this browser.' : '<strong>This browser blocked saving.</strong> Download a backup now.') + '</p><div class="gs-row"><button class="gs-btn" data-act="backup">Save a backup file</button><label class="gs-btn2" style="cursor:pointer">Restore from a backup<input type="file" id="restore" accept="application/json" hidden></label><button class="gs-btn3 gs-danger" data-act="wipe">Erase everything on this device</button></div></div>';
  }

  // ---------- actions ----------
  function printHTML(html) {
    const fr = document.createElement('iframe'); fr.style.cssText = 'position:fixed;right:0;bottom:0;width:0;height:0;border:0'; document.body.appendChild(fr);
    const d = fr.contentWindow.document; d.open(); d.write(html); d.close();
    setTimeout(() => { try { fr.contentWindow.focus(); fr.contentWindow.print(); } catch (e) { toast('Printing was blocked. Use "Save" instead.'); } setTimeout(() => fr.remove(), 4000); }, 350);
  }
  function download(name, html) { const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([html], { type: 'text/html' })); a.download = name; document.body.appendChild(a); a.click(); a.remove(); toast('Saved ' + name); }
  async function importDoi(raw) {
    const doi = String(raw || '').trim().replace(/^https?:\/\/(dx\.)?doi\.org\//i, ''); if (!/^10\.\d{4,9}\/\S+$/.test(doi)) return toast('That does not look like a DOI. Use "Add a reference" to type it by hand.');
    try { const r = await (await fetch('https://api.openalex.org/works/doi:' + encodeURIComponent(doi) + '?select=title,publication_year,authorships,primary_location')).json(); if (!r.title) throw new Error('none');
      const au = (r.authorships || []).slice(0, 3).map((a) => a.author.display_name).join(', ') + ((r.authorships || []).length > 3 ? ', et al.' : '');
      S.refs.push({ id: 'r' + (S.refs.length + 1), cite: au + '. ' + r.publication_year + '. ' + r.title + '. ' + ((r.primary_location && r.primary_location.source && r.primary_location.source.display_name) || ''), doi }); saveNow(); render(); toast('Imported. Check it against the paper.');
    } catch (e) { toast('Could not look that up (offline, or not in OpenAlex). Add it by hand instead.'); }
  }
  function onClick(e) {
    const b = e.target.closest('[data-act]'); if (!b) return; if (b.tagName === 'A') e.preventDefault();
    const a = b.dataset.act, i = Number(b.dataset.i), p = b.dataset.p;
    if (window.StudioLab && StudioLab.onClick(b)) return;
    switch (a) {
      case 'nav': { const t = DEEP[b.dataset.id]; if (!t) break; if (t[0] === 'pi') { if (S.pi && window.StudioLab) StudioLab.setStage(t[1]); } else if (t[1]) { WZ.want = { id: t[0], text: t[1] }; } go(t[0]); break; }
      case 'wz': WZ[b.dataset.w] = Number(b.dataset.v); render(); window.scrollTo(0, 0); break;
      case 'wzb': WZ[b.dataset.w] = Math.max(0, (WZ[b.dataset.w] || 0) - 1); render(); window.scrollTo(0, 0); break;
      case 'wzn': { const id = b.dataset.w; const n0 = WZ[id] || 0; const before = $('#view').querySelectorAll('.gs-steps li').length; if (n0 >= before - 1) { const nv = ORDER[ORDER.indexOf(id) + 1]; if (nv) { go(nv); break; } } WZ[id] = n0 + 1; render(); window.scrollTo(0, 0); break; }
      case 'toggleEv': { const g = S.gaps[i]; g.evidence = g.evidence || []; const k = g.evidence.indexOf(b.dataset.id); if (k >= 0) g.evidence.splice(k, 1); else g.evidence.push(b.dataset.id); saveNow(); render(); break; }
      case 'fillLit': { const lc = S.litChecks[i]; const sr = S.library.searches; if (!sr.length) return toast('Run searches on the PI\u2019s page first; they are logged automatically.'); lc.sources = Array.from(new Set(sr.map((x) => x.source))).join(', ') + ' (' + sr.length + ' searches in the log)'; lc.terms = sr.map((x) => x.mode + ': ' + x.terms).join('; '); lc.date = sr[sr.length - 1].date; saveNow(); render(); toast('Filled from your search log'); break; }
      case 'insCite': { const sel2 = $('#citeSel'); const t = window.__lastTa; if (!sel2 || !sel2.value) return toast('Add papers to your library first.'); if (!t || !document.body.contains(t)) return toast('Click inside a text box first, then press Insert.'); const tok = '[@' + sel2.value + ']'; const a0 = t.selectionStart == null ? t.value.length : t.selectionStart, b0 = t.selectionEnd == null ? a0 : t.selectionEnd; t.value = t.value.slice(0, a0) + tok + t.value.slice(b0); t.focus(); t.setSelectionRange(a0 + tok.length, a0 + tok.length); t.dispatchEvent(new Event('input', { bubbles: true })); break; }
      case 'go': go(b.dataset.v); break;
      case 'delRow': { const arr = getPath(S, p); arr.splice(i, 1); saveNow(); render(); break; }
      case 'addPeriod': S.profile.periods.push({ label: 'Period ' + (S.profile.periods.length + 1), start: '', end: '' }); saveNow(); render(); break;
      case 'addBreak': S.profile.breaks.push({ label: 'Break', start: '', end: '' }); saveNow(); render(); break;
      case 'addSource': S.sources.push({ kind: 'University profile', title: '', url: '', date: new Date().toISOString().slice(0, 10), note: '' }); saveNow(); render(); break;
      case 'addResource': S.resources.push({ id: 'x' + Date.now(), kind: 'dataset', name: '', critical: false, used: '', usedSrc: '', usedNote: '', role: '', access: 'unconfirmed', accessNote: '', route: '' }); saveNow(); render(); break;
      case 'addGap': S.gaps.push({ id: 'g' + (Date.now() % 100000), title: '', a: {}, score: { value: 3, evidence: 3, access: 3, burden: 3, deliver: 3 }, dependencies: [], feasibleHours: true }); saveNow(); render(); break;
      case 'addDep': S.gaps[i].dependencies.push({ text: '', critical: false, route: '' }); saveNow(); render(); break;
      case 'addLit': S.litChecks.push({ gapId: b.dataset.id, sources: '', terms: '', date: new Date().toISOString().slice(0, 10), closest: '', limits: '' }); saveNow(); render(); break;
      case 'resetWeights': S.weights = {}; saveNow(); render(); break;
      case 'addExp': S.plan.experiments.push({ id: 'e' + Date.now(), n: S.plan.experiments.length + 1, aim: 'Aim 1', title: '', design: '', materials: '', equip: '', methods: '', controls: '', replication: '', sample: '', decision: '' }); saveNow(); render(); break;
      case 'addPhase': { const last = S.plan.schedule[S.plan.schedule.length - 1]; const n = last ? last.to + 1 : 1; S.plan.schedule.push({ from: n, to: n, label: '', cat: { training: 0, access: 0, trouble: 0, analysis: 0, reporting: 0 } }); saveNow(); render(); break; }
      case 'addBudget': S.budget.push({ id: 'b' + Date.now(), item: '', amount: 0, linksTo: '', basis: '', pay: 'supplies' }); saveNow(); render(); break;
      case 'addRef': S.refs.push({ id: 'r' + (S.refs.length + 1), cite: '', doi: '' }); saveNow(); render(); break;
      case 'addClaim': S.claims.push({ id: 'c' + Date.now(), text: '', ref: (window.StudioLib.refList(S)[0] || {}).id || '', verified: false }); saveNow(); render(); break;
      case 'addPending': S.pending.push(''); saveNow(); render(); break;
      case 'addDecision': S.meeting.decisions.push({ ask: '', said: '', change: '', done: false }); saveNow(); render(); break;
      case 'addLog': { const t = $('#logt').value.trim(); if (t) { S.submission.log.push({ date: new Date().toISOString().slice(0, 10), text: t }); saveNow(); render(); } break; }
      case 'addFunder': { S.customFunders = S.customFunders || []; const id = 'ext' + (S.customFunders.length + 1); S.customFunders.push({ id, name: 'Outside opportunity ' + (S.customFunders.length + 1), kind: 'External', source: 'https://', verified: new Date().toISOString().slice(0, 10), status: 'NOT STATED', deadline: 'NOT STATED', period: 'NOT STATED', eligibility: 'NOT STATED', amount: 'NOT STATED', stipend: 0, supplies: 0, expenses: 'NOT STATED', route: 'NOT STATED', mentor: 'NOT STATED', materials: 'NOT STATED', reporting: 'NOT STATED', roles: { writes: 'NOT STATED', submits: 'NOT STATED', administers: 'NOT STATED' }, minSemesters: 0, unverified: ['Everything (fill in the official facts, then edit this entry)'] }); D.FUNDERS.push(S.customFunders[S.customFunders.length - 1]); saveNow(); render(); toast('Added. Edit its facts from the official page.'); break; }
      case 'pickPi': pickPi(b.dataset.id); break;
      case 'loadExample': Object.keys(WZ).forEach((k) => { WZ[k] = 0; }); if (confirm('This replaces your current workspace with the worked example. Save a backup first if you have work here. Continue?')) { S = clone(D.EXAMPLE); S.v = 1; S.weights = {}; S.customFunders = []; if (window.StudioLab) StudioLab.ui.stage = 0; saveNow(); view = 'dash'; render(); toast('Worked example loaded'); } break;
      case 'startMine': if (confirm('Start from a blank workspace? The worked example will be removed from this browser.')) { S = blankState(); saveNow(); view = 'me'; render(); } break;
      case 'fillFacts': { const base = b.dataset.b; const cal = C.calendar(S.profile), bt = C.budgetTotals(S.budget); const f = S[base].facts; f.totalHours = cal.total; f.startDate = isNaN(cal.first) ? '' : C.iso(cal.first); f.endDate = isNaN(cal.last) ? '' : C.iso(cal.last); f.budgetTotal = bt.total; saveNow(); render(); toast('Filled hours, dates and budget from the system'); break; }
      case 'loadReq': { const lines = $('#reqbox').value.split('\n').map((x) => x.trim()).filter(Boolean); if (!lines.length) return toast('Paste at least one section line.'); const old = S.proposal.sections; S.proposal.sections = lines.map((ln, k) => { const parts = ln.split('|'); const title = parts[0].trim(); const lim = parseInt((parts[1] || '').replace(/\D/g, ''), 10) || 0; const m = old.find((o) => C.norm(o.title) === C.norm(title)); return { id: m ? m.id : 'sec' + k + Date.now() % 1000, title, limit: lim, text: m ? m.text : '' }; }); S.proposal.modelNote = 'FUNDER REQUIREMENTS LOADED by the student on ' + new Date().toISOString().slice(0, 10) + '. Check each section against the official instructions before marking it verified.'; saveNow(); render(); toast('Sections replaced. Text kept for matching titles.'); break; }
      case 'importDoi': importDoi($('#doiin').value); break;
      case 'importBib': { const lines = $('#bibin').value.split('\n').map((x) => x.trim()).filter(Boolean); lines.forEach((ln) => { const m = /(10\.\d{4,9}\/[^\s"<>]+)/.exec(ln); S.refs.push({ id: 'r' + (S.refs.length + 1), cite: ln, doi: m ? m[1].replace(/[.,;)]+$/, '') : '' }); }); saveNow(); render(); toast(lines.length + ' reference(s) added. Check each one.'); break; }
      case 'deck': window.StudioDeck.open(S, { go, toast }); break;
      case 'printPacket': printHTML(C.packetHTML(S)); break;
      case 'printPro': printHTML(C.proposalHTML(S)); break;
      case 'printPlan': printHTML(C.planHTML(S)); break;
      case 'printDec': printHTML(C.decisionHTML(S)); break;
      case 'printReview': printHTML(reviewSheet()); break;
      case 'dlPacket': download('faculty-meeting-packet.html', C.packetHTML(S)); break;
      case 'dlPro': download('grant-proposal.html', C.proposalHTML(S)); break;
      case 'dlPlan': download('research-plan.html', C.planHTML(S)); break;
      case 'copyEmail': { const em = S.meeting.email || C.emailDraft(S); (navigator.clipboard ? navigator.clipboard.writeText(em.subject + '\n\n' + em.body) : Promise.reject()).then(() => toast('Copied'), () => toast('Select the text and copy it by hand')); break; }
      case 'resetEmail': S.meeting.email = null; saveNow(); render(); break;
      case 'backup': { const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([JSON.stringify(S, null, 2)], { type: 'application/json' })); a.download = 'research-to-grant-studio-backup.json'; document.body.appendChild(a); a.click(); a.remove(); toast('Backup saved to your Downloads folder'); break; }
      case 'wipe': if (confirm('Erase your whole Studio workspace on this device? This cannot be undone.')) { try { localStorage.removeItem(KEY); } catch (er) { /* ignore */ } S = blankState(); view = 'dash'; render(); toast('Erased'); } break;
      case 'wk': { const w = Number(b.dataset.w); const sch = S.plan.schedule.find((p) => w >= p.from && w <= p.to); toast('Week ' + w + (sch ? ': ' + sch.label : ': unscheduled')); break; }
      default: break;
    }
  }
  function reviewSheet() { const r = R(); return C.esc && ('<!doctype html><meta charset="utf-8"><title>Instructor review</title><style>body{font:11pt Arial;max-width:7.5in;margin:.4in auto}table{border-collapse:collapse;width:100%}td,th{border:1px solid #999;padding:5px;text-align:left;vertical-align:top}</style><h1>Instructor review</h1><p>Student: ' + esc(S.profile.name) + ' · PI: ' + esc(C.piName(S)) + '</p><table><tr><th>Gate</th><th>Status</th><th>Detail</th><th>Comment</th></tr>' + r.items.map((i) => '<tr><td>' + esc(i.label) + '</td><td>' + W.LVL[i.level][1] + '</td><td>' + esc(i.detail) + '</td><td>' + esc(S.review.notes[i.id] || '') + '</td></tr>').join('') + '</table><h2>Sign-off</h2><p>' + esc(S.review.signoff) + '</p>'); }
  function pickPi(id) {
    if (S.pi === id) return;
    const wasExample = !!(S.meta && S.meta.example);
    const had = !wasExample && S.pi && (S.library.items.length || S.papers.some((p) => p.tested) || S.gaps.some((g) => (g.title || '').trim()));
    if (had && !confirm('Changing the PI starts the PI-specific work again (library, evidence, candidate gaps, plan and proposal text). Your hours, funding choice and budget are kept. Continue?')) return;
    const b = blankState();
    if (wasExample) { S = b; } else { ['library', 'papers', 'gaps', 'litChecks', 'chosenGap', 'justification', 'plan', 'proposal', 'claims', 'defense', 'sectionStatus', 'pending', 'weights', 'identityChecks'].forEach((k) => { S[k] = b[k]; }); S.meta = {}; }
    S.pi = id;
    S.resources = (D.PI_EXTRA[id].resources || []).map((r, k) => ({ id: 'p' + k, kind: r.kind, name: r.name, critical: false, used: r.used, usedSrc: r.src.indexOf('http') === 0 ? r.src : 'doi:' + r.src, usedNote: r.note, role: '', access: 'unconfirmed', accessNote: '', route: '' }));
    Object.keys(WZ).forEach((k) => { WZ[k] = 0; });
    if (window.StudioLab) { StudioLab.ui.stage = 0; StudioLab.ui.results = []; StudioLab.ui.msg = ''; }
    saveNow(); render();
  }
  function onInput(e) {
    const t = e.target;
    if (t.dataset && t.dataset.em) { S.meeting.email = S.meeting.email || C.emailDraft(S); S.meeting.email[t.dataset.em] = t.value; save(); const m = $('#mailto'); if (m) m.href = mailtoOf(S.meeting.email); return; }
    if (t.dataset && t.dataset.status) { S.sectionStatus[t.dataset.status] = t.value; save(); refreshLive(); return; }
    if (t.id === 'restore') return;
    if (t.dataset && t.dataset.lab !== undefined && window.StudioLab && StudioLab.onInput(t)) return;
    const path = t.dataset && t.dataset.bind; if (!path) return;
    let v = t.value; if (t.dataset.bool) v = t.checked; else if (t.type === 'checkbox') v = t.checked; else if (t.type === 'radio' && !t.checked) return; else if (t.dataset.num) v = t.value === '' ? '' : Number(t.value);
    if (path.indexOf('funding.resolutions.') === 0) { S.funding.resolutions[path.slice('funding.resolutions.'.length)] = v; } else setPath(S, path, v);
    if (path.indexOf('gaps.') === 0 && path.indexOf('.title') > 0 && !S.chosenGap) { /* keep choice empty until picked */ }
    const sv = $('[data-sv="' + path + '"]'); if (sv) sv.textContent = v;
    save(); wordCounts(); refreshLive();
    if (t.tagName === 'SELECT' && /^library\.items\.\d+\.(coll|read|fulltext)$/.test(path)) { saveNow(); render(); return; }
    if (t.dataset.rerender && e.type === 'change') { if (path.indexOf('papers.') === 0 && /\.doi$/.test(path)) { const i = Number(path.split('.')[1]); const w = (PIS[S.pi] || { works: [] }).works.find((x) => x.doi === v); if (w) S.papers[i].title = w.t + ' (' + w.y + ')'; } saveNow(); render(); }
  }
  function onChange(e) { if (e.target.id === 'restore') return restore(e); if (e.target.dataset && (e.target.dataset.rerender || e.target.dataset.lab !== undefined)) onInput(e); }
  function restore(e) {
    const fl = e.target.files && e.target.files[0]; if (!fl) return; const rd = new FileReader();
    rd.onload = () => { try { const got = JSON.parse(String(rd.result)); if (!got || got.v !== 1 || !got.plan || !got.proposal) throw new Error('bad'); S = got; saveNow(); render(); toast('Restored from your backup'); } catch (er) { toast('That file is not a Studio backup'); } };
    rd.readAsText(fl);
  }
  function zoomPhotos(e) { const img = e.target.closest && e.target.closest('img.fac-photo'); if (!img) return; const ov = document.createElement('div'); ov.className = 'gs-photo-zoom'; ov.innerHTML = '<img src="' + img.src + '" alt="' + esc(img.alt) + '">'; ov.addEventListener('click', () => ov.remove()); document.body.appendChild(ov); }

  // ---------- dictation (Speak buttons use the same colors across the site) ----------
  const SR = window.SpeechRecognition || window.webkitSpeechRecognition; let rec = null, recBtn = null; const MIC = 'Speak instead of typing';
  function addMics() {
    if (!SR) return;
    $$('textarea[data-bind]').forEach((t) => { if (t.dataset.mic) return; t.dataset.mic = '1'; const row = document.createElement('div'); row.className = 'gs-row'; row.style.margin = '4px 0 0'; row.innerHTML = '<button type="button" class="gs-btn3 gs-sm gs-mic" data-mic="' + t.id + '">' + MIC + '</button><span class="gs-note"></span>'; t.insertAdjacentElement('afterend', row); });
  }
  function dictate(btn) {
    const t = document.getElementById(btn.dataset.mic), hint = btn.nextElementSibling;
    if (rec && recBtn === btn) { rec.stop(); return; } if (rec) { try { rec.stop(); } catch (e) { /* done */ } }
    rec = new SR(); recBtn = btn; rec.lang = 'en-US'; rec.continuous = true; rec.interimResults = false;
    rec.onresult = (ev) => { let s = ''; for (let i = ev.resultIndex; i < ev.results.length; i++) if (ev.results[i].isFinal) s += ev.results[i][0].transcript; if (!s) return; t.value = (t.value && !/\s$/.test(t.value) ? t.value + ' ' : t.value) + s.trim(); t.dispatchEvent(new Event('input', { bubbles: true })); };
    rec.onerror = (ev) => { btn.classList.remove('mic-live'); btn.classList.add('mic-err'); hint.textContent = ev.error === 'not-allowed' ? 'The microphone is blocked. Allow it in your browser settings.' : 'Could not hear you. Try again.'; };
    rec.onend = () => { btn.classList.remove('mic-live'); btn.textContent = MIC; if (/^Listening/.test(hint.textContent)) hint.textContent = ''; rec = null; recBtn = null; };
    btn.classList.remove('mic-err'); btn.classList.add('mic-live'); btn.textContent = 'Stop'; hint.textContent = 'Listening... speak, then press Stop.';
    try { rec.start(); } catch (e) { hint.textContent = 'Could not start the microphone.'; }
  }

  // ---------- boot ----------
  function lockScreen(msg, retry) {
    document.body.innerHTML = '<main class="gs-lock gs-card gs-glow" style="padding:30px"><p class="gs-kick">Research-to-Grant Studio</p><h1 class="gs-h1">' + (retry ? 'Could not check your access' : 'This studio is by invitation') + '</h1><p class="gs-lede" style="margin:0 auto 16px">' + msg + '</p><div class="gs-row" style="justify-content:center">' + (retry ? '<button class="gs-btn" onclick="location.reload()">Try again</button>' : '<a class="gs-btn" href="mailto:' + ADMIN + '?subject=' + encodeURIComponent('Request access: Research-to-Grant Studio') + '">Email ' + ADMIN + '</a>') + '<a class="gs-btn2" href="/BIOS102/research-match.html">Back to Research Match</a></div></main>';
  }
  // The gate (real access check) lives in startGated; run() is the app itself so it can be exercised in tests
  // with an injected session, without touching or bypassing the invitation check.
  async function startGated() {
    session = window.BIOS && BIOS.requireSession(); if (!session) return;
    let has = false;
    try { has = !!(await window.sfSupabase.bios102StudioHasAccess(session.sessionToken)); } catch (e) { return lockScreen('The studio could not confirm your invitation just now. Check your connection and try again.', true); }
    if (!has) return lockScreen('Ask <strong>' + ADMIN + '</strong> for access. Once you are on the invitation list, reload this page.');
    let ins = false; try { ins = !!(await window.sfSupabase.bios102GradesIsInstructor(session.sessionToken)); } catch (e) { ins = false; }
    run({ session, isInstructor: ins });
  }
  function run(env) {
    session = env.session; isInstructor = !!env.isInstructor; KEY = 'gs_state_v1_' + String(session.email || '').toLowerCase();
    load();
    window.StudioLab.init({ S: () => S, render, save: saveNow, toast, esc, go, sel, inp, ta, chk, sections: { identity: secIdentity, sources: secSources, resources: secResources } });
    document.addEventListener('focusin', (e) => { if (e.target && e.target.tagName === 'TEXTAREA' && e.target.dataset.bind) window.__lastTa = e.target; });
    $('#who').textContent = session.displayName || session.email || '';
    $('#logout').addEventListener('click', () => { if (window.BIOS) BIOS.clearSession(); window.location.href = '/BIOS102/index.html'; });
    const v$ = $('#view'); v$.addEventListener('click', (e) => { zoomPhotos(e); const m = e.target.closest('[data-mic]'); if (m) return dictate(m); onClick(e); }); v$.addEventListener('input', onInput); v$.addEventListener('change', onChange);
    $('#nav').addEventListener('click', onClick);
    window.addEventListener('beforeunload', saveNow);
    view = 'dash'; render();
  }
  window.__studio = { get state() { return S; }, go, render, onClick };
  window.StudioApp = { run, startGated };
})();
