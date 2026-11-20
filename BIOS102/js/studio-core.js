// BIOS102 Research-to-Grant Studio: the logic. Pure functions, no DOM, so it can be tested in Node.
// Everything the dashboard shows (hours, rankings, mismatches, readiness) is computed here from the
// student's saved state; nothing is typed in twice.
(function (root) {
  'use strict';
  const D = (root.STUDIO_DATA) || {};
  const LIB = root.StudioLib;
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const norm = (s) => String(s == null ? '' : s).toLowerCase().replace(/\s+/g, ' ').trim();
  const words = (s) => { const t = String(s || '').trim(); return t ? t.split(/\s+/).length : 0; };
  const filled = (s) => String(s == null ? '' : s).trim().length > 0;

  // ---------- dates and the hours calendar ----------
  const DAY = 86400000;
  const parse = (s) => { const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(s || '')); return m ? Date.UTC(+m[1], +m[2] - 1, +m[3]) : NaN; };
  const iso = (t) => new Date(t).toISOString().slice(0, 10);
  const mondayOf = (t) => { const d = new Date(t).getUTCDay(); return t - ((d + 6) % 7) * DAY; };   // Monday on or before t
  const fmt = (t) => new Date(t).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric', timeZone: 'UTC' });

  const DKEYS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  const CLASS_COLORS = ['#fb7185', '#4ade80', '#fbbf24', '#60a5fa', '#a78bfa', '#f472b6', '#2dd4bf', '#fb923c'];
  const toMin = (hhmm) => { const m = /^(\d{1,2}):(\d{2})$/.exec(String(hhmm || '')); return m ? (+m[1]) * 60 + (+m[2]) : NaN; };
  const fmtMin = (m) => { const h = Math.floor(m / 60), mm = m % 60; return ((h + 11) % 12 + 1) + ':' + String(mm).padStart(2, '0') + ' ' + (h < 12 ? 'am' : 'pm'); };
  const slotMin = (i) => [480 + 120 * i, 600 + 120 * i];
  const nSlots = () => (D.SLOTS || []).length;
  // slots touched by each class meeting (a class from 10:00 to 10:50 uses the 10 to 12 block)
  function classBusy(profile) {
    const out = DKEYS.map(() => new Set());
    ((profile && profile.classes) || []).forEach((c) => { const s = toMin(c.start), e = toMin(c.end); if (isNaN(s) || isNaN(e) || e <= s) return; (c.days || []).forEach((dk) => { const d = DKEYS.indexOf(dk); if (d < 0) return; for (let i = 0; i < nSlots(); i++) { const [a, b] = slotMin(i); if (s < b && e > a) out[d].add(i); } }); });
    return out;
  }
  const baseFree = (profile) => { const cb = classBusy(profile); return DKEYS.map((k, d) => { const b = (profile && profile.weekBlack && profile.weekBlack[k]) || []; return (D.SLOTS || []).map((_, i) => i).filter((i) => b.indexOf(i) < 0 && !cb[d].has(i)); }); };
  // study time for each class goes into free weekday blocks (Monday to Friday, then Sunday), at most two blocks a day; Saturday stays free
  function studyPlan(profile) {
    const need = ((profile && profile.classes) || []).filter((c) => Number(c.study) > 0).map((c) => ({ c, left: Number(c.study) })); const out = DKEYS.map(() => []); if (!need.length) return out;
    const base = baseFree(profile);
    [0, 1, 2, 3, 4, 6].forEach((d) => { let used = 0; base[d].forEach((s) => { if (used >= 2) return; const t = need.filter((n) => n.left > 0).sort((a, b) => b.left - a.left)[0]; if (!t) return; out[d].push({ slot: s, course: t.c.course, color: t.c.color }); t.left -= 2; used++; }); });
    return out;
  }
  const freeSlots = (profile) => { const sp = studyPlan(profile); return baseFree(profile).map((f, d) => f.filter((i) => !sp[d].some((x) => x.slot === i))); };
  // Suggest the best times: long free runs first, until the hours you want are covered.
  function suggestTimes(profile) {
    const free = freeSlots(profile); const want = Number(profile && profile.weeklyHours) || 0; const runs = [];
    free.forEach((f, d) => { let i = 0; while (i < f.length) { let j = i; while (j + 1 < f.length && f[j + 1] === f[j] + 1) j++; runs.push({ d, from: f[i], to: f[j], hours: (j - i + 1) * 2 }); i = j + 1; } });
    const capacity = runs.reduce((a, r) => a + r.hours, 0); runs.sort((a, b) => b.hours - a.hours || a.d - b.d || a.from - b.from);
    const picks = []; let sum = 0;
    runs.forEach((r) => { if (sum >= want) return; const hrs = Math.min(r.hours, want - sum); const last = r.from + Math.ceil(hrs / 2) - 1; picks.push({ day: D.DAYS[r.d][1], d: r.d, fromSlot: r.from, toSlot: last, label: D.DAYS[r.d][1] + ' ' + D.SLOTS[r.from][0] + ' to ' + D.SLOTS[last][1], hours: Math.min(hrs, (last - r.from + 1) * 2) }); sum += hrs; });
    picks.sort((a, b) => a.d - b.d);
    return { picks, capacity, want, enough: capacity >= want };
  }
  function weekPattern(profile) {
    const pat = DKEYS.map(() => ({ classes: [], study: [], research: [] }));
    ((profile && profile.classes) || []).forEach((c, ci) => { const s = toMin(c.start), e = toMin(c.end); if (isNaN(s) || isNaN(e) || e <= s) return; (c.days || []).forEach((dk) => { const d = DKEYS.indexOf(dk); if (d >= 0) pat[d].classes.push({ kind: 'class', label: c.course || 'Class', from: s, to: e, color: c.color || CLASS_COLORS[ci % 8], time: fmtMin(s) + ' to ' + fmtMin(e) }); }); });
    studyPlan(profile).forEach((arr, d) => arr.forEach((x) => { const [a, b] = slotMin(x.slot); pat[d].study.push({ kind: 'study', label: 'Study ' + (x.course || ''), from: a, to: b, color: x.color }); }));
    suggestTimes(profile).picks.forEach((p) => { pat[p.d].research.push({ kind: 'research', label: 'Research', from: slotMin(p.fromSlot)[0], to: slotMin(p.toSlot)[1], color: '#22d3ee' }); });
    pat.forEach((x) => { x.all = x.classes.concat(x.study, x.research).sort((a, b) => a.from - b.from); });
    return pat;
  }
  function dayPlan(profile, isoDate, pat) {
    const t = parse(isoDate); const inPeriod = ((profile && profile.periods) || []).some((p) => { const s = parse(p.start), e = parse(p.end); return !isNaN(s) && !isNaN(e) && t >= s && t <= e; });
    const blocked = ((profile && profile.blackDates) || []).indexOf(isoDate) >= 0; const d = (new Date(t).getUTCDay() + 6) % 7; const p = pat || weekPattern(profile);
    return { inPeriod, blocked, d, items: inPeriod && !blocked ? p[d].all : [] };
  }
  const YEAR_IDX = { 'First-year': 1, 'Sophomore': 2, 'Junior': 3, 'Senior': 4 };
  const courseLevel = (code) => { const m = /\d{3}/.exec(String(code)); const n = m ? parseInt(m[0], 10) : 100; return Math.max(1, Math.min(6, Math.floor(n / 100))); };
  // Courses a student of this year is likely to have finished (this level or below), plus anything already chosen.
  function visibleCourses(list, year, showAll, done) { const y = YEAR_IDX[year] || 0; return list.filter((c) => showAll || (y && courseLevel(c) <= y) || (done || []).indexOf(c) >= 0); }
  // A "working week" is a Monday-start week that begins inside a period and is not touched by a break.
  function calendar(profile) {
    const hrs = Number(profile && profile.weeklyHours) || 0;
    const periods = (profile && profile.periods) || [];
    const breaks = ((profile && profile.breaks) || []).map((b) => [parse(b.start), parse(b.end)]).filter((b) => !isNaN(b[0]) && !isNaN(b[1]));
    const weeks = [];
    const problems = [];
    periods.forEach((p, pi) => {
      const s = parse(p.start), e = parse(p.end);
      if (isNaN(s) || isNaN(e) || e < s) { problems.push('Period ' + (pi + 1) + ' has an invalid start or end date.'); return; }
      for (let m = mondayOf(s); m <= e; m += 7 * DAY) {
        if (m < s - 3 * DAY) continue;                                 // week mostly before the period
        const fri = m + 4 * DAY;
        const hit = breaks.some((b) => b[0] <= fri && b[1] >= m);
        if (profile && profile.weekBlack) {
          const free = freeSlots(profile); const black = new Set(profile.blackDates || []); let cap = 0;
          for (let d = 0; d < 7; d++) { if (!black.has(iso(m + d * DAY))) cap += free[d].length * 2; }
          weeks.push({ n: 0, monday: m, period: pi, hours: Math.min(hrs, cap), capacity: cap, broke: cap === 0 });
        } else weeks.push({ n: 0, monday: m, period: pi, hours: hit ? 0 : hrs, capacity: hit ? 0 : hrs, broke: hit });
      }
    });
    weeks.sort((a, b) => a.monday - b.monday);
    const work = weeks.filter((w) => w.hours > 0);
    work.forEach((w, i) => { w.n = i + 1; });
    const total = work.reduce((a, w) => a + w.hours, 0);
    const first = periods.length ? parse(periods[0].start) : NaN;
    const last = periods.length ? parse(periods[periods.length - 1].end) : NaN;
    return { weeks: work, allWeeks: weeks, totalWeeks: work.length, total, weeklyHours: hrs, first, last, problems, periods: periods.length };
  }

  // Largest-remainder split of `total` hours by percent, so the pieces always add to the total.
  function reserve(total, pct) {
    const keys = ['training', 'access', 'trouble', 'analysis', 'reporting'];
    const sum = keys.reduce((a, k) => a + (Number(pct && pct[k]) || 0), 0) || 1;
    const raw = keys.map((k) => ((Number(pct && pct[k]) || 0) / sum) * total);
    const base = raw.map(Math.floor);
    let left = total - base.reduce((a, b) => a + b, 0);
    raw.map((r, i) => [r - Math.floor(r), i]).sort((a, b) => b[0] - a[0]).forEach(([, i]) => { if (left > 0) { base[i]++; left--; } });
    const out = {}; keys.forEach((k, i) => { out[k] = base[i]; }); return out;
  }

  function checkSchedule(plan, cal) {
    const out = [];
    const sch = (plan && plan.schedule) || [];
    if (!sch.length) return [{ level: 'block', text: 'The week-by-week schedule is empty.' }];
    const sorted = sch.slice().sort((a, b) => a.from - b.from);
    let expect = 1;
    sorted.forEach((p) => {
      if (p.from !== expect) out.push({ level: 'block', text: 'Schedule gap or overlap: expected a phase to start at week ' + expect + ' but "' + p.label + '" starts at week ' + p.from + '.' });
      expect = p.to + 1;
      const wk = p.to - p.from + 1;
      const hrs = cal.weeklyHours * wk;
      const cat = Object.values(p.cat || {}).reduce((a, b) => a + b, 0);
      if (cat !== hrs) out.push({ level: 'block', text: 'Weeks ' + p.from + '-' + p.to + ' hold ' + hrs + ' hours but the phase assigns ' + cat + '.' });
    });
    if (expect - 1 !== cal.totalWeeks) out.push({ level: 'block', text: 'The schedule covers ' + (expect - 1) + ' weeks but the calendar has ' + cal.totalWeeks + ' working weeks.' });
    return out;
  }
  function scheduleTotals(plan) {
    const t = { training: 0, access: 0, trouble: 0, analysis: 0, reporting: 0 };
    ((plan && plan.schedule) || []).forEach((p) => Object.keys(p.cat || {}).forEach((k) => { t[k] = (t[k] || 0) + p.cat[k]; }));
    return t;
  }
  function reserveDrift(plan, cal, pct) {
    const target = reserve(cal.total, pct), have = scheduleTotals(plan), out = [];
    Object.keys(target).forEach((k) => { const d = have[k] - target[k]; if (Math.abs(d) > Math.max(4, cal.total * 0.05)) out.push({ cat: k, target: target[k], have: have[k] }); });
    return out;
  }

  // ---------- gaps: screen, then compare ----------
  function gapAnswered(g) { return D.GAP_QUESTIONS.every((q) => filled(g.a && g.a[q[0]])); }
  function gapScreen(g) {
    const why = [];
    (g.dependencies || []).forEach((d) => { if (d.critical && !filled(d.route)) why.push('Critical dependency with no route to resolve it: ' + d.text); });
    if (g.feasibleHours === false) why.push('Does not fit the available hours.');
    return { out: why.length > 0, why };
  }
  function gapScore(g, weights) {
    const crit = D.CRITERIA; let num = 0, den = 0;
    crit.forEach((c) => { const w = (weights && weights[c.id] != null) ? weights[c.id] : c.w; const s = Number(g.score && g.score[c.id]) || 0; num += w * s; den += w * 5; });
    return den ? Math.round((num / den) * 100) : 0;
  }
  function rankGaps(gaps, weights) {
    const rows = (gaps || []).map((g) => { const sc = gapScreen(g); return { g, screened: sc.out, why: sc.why, pct: gapScore(g, weights) }; });
    const live = rows.filter((r) => !r.screened).sort((a, b) => b.pct - a.pct);
    live.forEach((r, i) => { r.rank = i + 1; });
    return { rows, live, out: rows.filter((r) => r.screened) };
  }

  // ---------- budget and funding ----------
  function budgetTotals(budget) {
    const t = { total: 0, student: 0, supplies: 0, other: 0 };
    (budget || []).forEach((b) => { const a = Number(b.amount) || 0; t.total += a; if (b.pay === 'student') t.student += a; else if (b.pay === 'supplies') t.supplies += a; else t.other += a; });
    return t;
  }
  const funder = (id) => (D.FUNDERS || []).find((f) => f.id === id);
  function fundingCheck(st) {
    const out = []; const cal = calendar(st.profile); const bt = budgetTotals(st.budget);
    const f = funder(st.funding && st.funding.primary);
    if (!f) return [{ level: 'block', text: 'No primary funding opportunity chosen.' }];
    if (f.eligibility && /declared/i.test(f.eligibility) && !/declared/i.test((st.profile && st.profile.major) || '')) out.push({ level: 'block', text: f.name + ' requires a declared major. Your profile does not say "declared".' });
    if (f.minSemesters && cal.periods < f.minSemesters) out.push({ level: 'block', text: f.name + ' funds ' + f.period + ' Your project window has ' + cal.periods + ' period(s). Extend the window or choose another funder.' });
    if (f.stipend && Math.abs(bt.student - f.stipend) > 0.5) out.push({ level: 'block', text: 'Budget student stipend is $' + bt.student + ' but the call states $' + f.stipend + '.' });
    if (f.supplies && bt.supplies > f.supplies + 0.5) out.push({ level: 'block', text: 'Budget supplies are $' + bt.supplies + ' which exceeds the $' + f.supplies + ' in the call.' });
    if (f.supplies && bt.supplies < f.supplies - 0.5) out.push({ level: 'warn', text: 'Budget supplies are $' + bt.supplies + ' but the call provides $' + f.supplies + '. Leave the rest as an advisor reserve or explain.' });
    (f.unverified || []).forEach((u) => { if (!filled(st.funding && st.funding.resolutions && st.funding.resolutions[f.id + '|' + u])) out.push({ level: 'warn', text: 'Unverified: ' + u + ' (' + f.name + '). Record how you resolved it.' }); });
    if (!st.funding.alt || st.funding.alt === st.funding.primary) out.push({ level: 'block', text: 'Choose a different alternative opportunity and assess it.' });
    else if (words(st.funding.altAssessment) < 20) out.push({ level: 'block', text: 'Write at least a short assessment of the alternative opportunity.' });
    return out;
  }

  // ---------- twin facts: plan vs proposal vs the live system ----------
  const FACT_LABEL = { aimCount: 'Number of aims', aimTitles: 'Aim statement', minReplicates: 'Minimum replicates per species', totalHours: 'Total hours', startDate: 'Start date', endDate: 'End date', deliverable: 'Final deliverable', budgetTotal: 'Total budget ($)' };
  function crossCheck(st) {
    const cal = calendar(st.profile), bt = budgetTotals(st.budget); const out = [];
    const a = (st.plan && st.plan.facts) || {}, b = (st.proposal && st.proposal.facts) || {};
    const truth = { totalHours: cal.total, startDate: isNaN(cal.first) ? '' : iso(cal.first), endDate: isNaN(cal.last) ? '' : iso(cal.last), budgetTotal: bt.total };
    Object.keys(FACT_LABEL).forEach((k) => {
      const A = norm(a[k]), B = norm(b[k]);
      if (A !== B) out.push({ field: k, label: FACT_LABEL[k], plan: a[k], proposal: b[k], truth: truth[k] });
      else if (truth[k] !== undefined && truth[k] !== '' && norm(truth[k]) !== A) out.push({ field: k, label: FACT_LABEL[k] + ' (both documents disagree with the calendar/budget)', plan: a[k], proposal: b[k], truth: truth[k] });
    });
    const planAims = (st.plan && st.plan.sections && st.plan.sections.aims) || '';
    const proAims = ((st.proposal && st.proposal.sections) || []).find((s) => s.id === 'aims');
    const n1 = (planAims.match(/\bAim\s+\d+/gi) || []).length, n2 = proAims ? (proAims.text.match(/\bAim\s+\d+/gi) || []).length : 0;
    if (proAims && n1 !== n2) out.push({ field: 'aimText', label: 'Aims written in the two documents', plan: n1 + ' aim(s) in the plan text', proposal: n2 + ' aim(s) in the proposal text', truth: '' });
    return out;
  }

  // ---------- readiness: every gate, with the reason ----------
  const SECTION_KEYS = {
    plan: ['observation', 'background', 'evidence', 'gap', 'question', 'answer', 'prediction', 'aims', 'variables', 'analysis', 'interpretation', 'approvals', 'handoff'],
  };
  function sectionState(st, key) { return (st.sectionStatus && st.sectionStatus[key]) || 'draft'; }
  function readiness(st) {
    const items = []; const add = (id, view, label, level, detail) => items.push({ id, view, label, level, detail });
    const cal = calendar(st.profile);

    // 1 constraints
    const p = st.profile || {}; const miss = ['name', 'major', 'year', 'courses', 'skills', 'mode'].filter((k) => !filled(p[k]));
    if (miss.length) add('me', 'me', 'Your constraints', 'block', 'Fill in: ' + miss.join(', '));
    else if (!(cal.total > 0)) add('me', 'me', 'Your constraints', 'block', 'The calendar has no available hours. Add a period and weekly hours.');
    else if (cal.problems.length) add('me', 'me', 'Your constraints', 'block', cal.problems.join(' '));
    else add('me', 'me', 'Your constraints', 'ok', cal.total + ' hours across ' + cal.totalWeeks + ' weeks.');

    // 2 PI and identity
    const idc = st.identityChecks || {};
    const idMiss = ['affiliation', 'coauthors', 'history'].filter((k) => !(idc[k] && idc[k].done && filled(idc[k].note)));
    if (!st.pi) add('pi', 'pi', 'PI chosen and identity verified', 'block', 'Choose a PI.');
    else if (idMiss.length) add('pi', 'pi', 'PI chosen and identity verified', 'block', 'Verify, with a note: ' + idMiss.join(', '));
    else add('pi', 'pi', 'PI chosen and identity verified', 'ok', 'Affiliation, coauthors and publication history confirmed.');

    // 3 papers
    const papers = st.papers || []; const fp = papers.find((x) => x.role === 'foundational'), rp = papers.find((x) => x.role === 'recent');
    const pOk = (x) => x && ['tested', 'support', 'uncertain', 'relates'].every((k) => filled(x[k])) && x.figureDone && filled(x.figure);
    if (!pOk(fp) || !pOk(rp)) add('papers', 'pi', 'Foundational and recent paper, with a figure each', 'block', 'Both papers need the four answers and a figure you have actually opened and annotated.');
    else add('papers', 'pi', 'Foundational and recent paper, with a figure each', 'ok', 'Both papers annotated.');

    // 4 resources: two lights
    const res = st.resources || []; const crit = res.filter((r) => r.critical);
    const noEvid = crit.filter((r) => !r.used);
    const hard = crit.filter((r) => r.access === 'unconfirmed' && !filled(r.route));
    const soft = crit.filter((r) => r.access === 'unconfirmed' && filled(r.route));
    if (!res.length) add('res', 'pi', 'Resource inventory', 'block', 'No resources listed.');
    else if (hard.length) add('res', 'pi', 'Resource inventory', 'block', 'Critical resource with unconfirmed access and no plan B: ' + hard.map((r) => r.name).join('; '));
    else if (noEvid.length) add('res', 'pi', 'Resource inventory', 'block', 'No evidence of past use recorded for: ' + noEvid.map((r) => r.name).join('; '));
    else if (soft.length) add('res', 'pi', 'Resource inventory', 'warn', soft.length + ' critical resource(s) still need confirmation: ' + soft.map((r) => r.name).join('; '));
    else add('res', 'pi', 'Resource inventory', 'ok', 'Every critical resource has evidence of use and confirmed access.');

    // 5 gaps
    const gaps = st.gaps || []; const rk = rankGaps(gaps, st.weights);
    const unans = gaps.filter((g) => !gapAnswered(g));
    if (gaps.length < 3) add('gaps', 'gaps', 'At least three candidate gaps', 'block', 'You have ' + gaps.length + '. Add ' + (3 - gaps.length) + ' more.');
    else if (unans.length) add('gaps', 'gaps', 'At least three candidate gaps', 'block', 'Unanswered questions in: ' + unans.map((g) => '"' + g.title + '"').join('; '));
    else add('gaps', 'gaps', 'At least three candidate gaps', 'ok', gaps.length + ' candidates, all eight questions answered.');
    const chosen = gaps.find((g) => g.id === st.chosenGap); const chosenOut = chosen && gapScreen(chosen).out;
    const live = rk.live.map((r) => r.g.id); const lit = st.litChecks || [];
    const noLit = live.filter((id) => { const c = lit.find((l) => l.gapId === id); return !(c && ['sources', 'terms', 'date', 'closest', 'limits'].every((k) => filled(c[k]))); });
    if (!chosen) add('choice', 'gaps', 'Chosen gap, justified', 'block', 'Choose a gap.');
    else if (chosenOut) add('choice', 'gaps', 'Chosen gap, justified', 'block', 'The chosen gap fails the screen: ' + gapScreen(chosen).why.join(' '));
    else if (words(st.justification) < 40) add('choice', 'gaps', 'Chosen gap, justified', 'block', 'Explain in at least 40 words why it beats the others.');
    else if (noLit.length) add('choice', 'gaps', 'Chosen gap, justified', 'block', 'Literature check missing or incomplete for: ' + noLit.map((id) => gaps.find((g) => g.id === id).title).join('; '));
    else add('choice', 'gaps', 'Chosen gap, justified', 'ok', 'Chosen "' + chosen.title + '"; literature checks recorded for all finalists.');

    // 6 funding
    const fc = fundingCheck(st); const fb = fc.filter((x) => x.level === 'block'), fw = fc.filter((x) => x.level === 'warn');
    if (fb.length) add('fund', 'fund', 'Funding match', 'block', fb.map((x) => x.text).join(' '));
    else if (fw.length) add('fund', 'fund', 'Funding match', 'warn', fw.length + ' item(s) unverified or open.');
    else add('fund', 'fund', 'Funding match', 'ok', 'Primary and alternative assessed; eligibility checks pass.');

    // 4b library: the PI's papers and the closest ongoing work, retrieved and kept
    const lib = (st.library && st.library.items) || [];
    const nPi = lib.filter((i) => i.coll === 'pi').length, nRel = lib.filter((i) => i.coll === 'related').length;
    if (nPi < 3 || nRel < 3) add('lib', 'pi', 'Library: PI papers and related ongoing work', 'block', 'The library holds ' + nPi + ' of the PI\u2019s papers and ' + nRel + ' related papers. Retrieve at least 3 of each.');
    else add('lib', 'pi', 'Library: PI papers and related ongoing work', 'ok', nPi + ' PI papers and ' + nRel + ' related papers in the library.');
    const scr = (st.library && st.library.screen) || []; const nEx = scr.filter((x) => x.decision === 'exclude' && filled(x.reason)).length;
    if (scr.length < 5 || nEx < 1) add('screen', 'pi', 'Screening: decided, with reasons', 'warn', 'You have decided on ' + scr.length + ' search result(s) and excluded ' + nEx + ' with a reason. Real searches turn up papers that do not belong; screen at least 5 and exclude at least one, saying why.');
    else add('screen', 'pi', 'Screening: decided, with reasons', 'ok', scr.length + ' results screened; ' + nEx + ' excluded with a reason.');
    // 5b evidence behind every candidate gap
    const ev = (st.library && st.library.evidence) || [];
    const evBad = ev.filter((e) => !filled(e.quote) || !lib.some((i) => i.id === e.item));
    const noEv = (st.gaps || []).filter((g) => filled(g.title) && !(g.evidence || []).some((id) => ev.some((e) => e.id === id)));
    if (ev.length < 3) add('evid', 'gaps', 'Gap evidence from the papers', 'block', 'The evidence board has ' + ev.length + ' card(s). Collect at least 3 quotes from papers in your library.');
    else if (evBad.length) add('evid', 'gaps', 'Gap evidence from the papers', 'block', evBad.length + ' evidence card(s) lack a quote or a source paper in the library.');
    else if (noEv.length) add('evid', 'gaps', 'Gap evidence from the papers', 'block', 'No evidence card is linked to: ' + noEv.map((g) => '"' + g.title + '"').join('; '));
    else add('evid', 'gaps', 'Gap evidence from the papers', 'ok', ev.length + ' evidence cards; every candidate cites at least one.');
    // 6b the chain: observation > question > proposed answer > prediction
    const ps0 = (st.plan && st.plan.sections) || {};
    const chainMiss = ['observation', 'question', 'answer', 'prediction'].filter((k) => !filled(ps0[k]));
    if (chainMiss.length) add('chain', 'plan', 'Observation, question, proposed answer, prediction', 'block', 'Write: ' + chainMiss.join(', '));
    else if (!/\?/.test(ps0.question)) add('chain', 'plan', 'Observation, question, proposed answer, prediction', 'block', 'The research question must be a question (end it with a question mark).');
    else if (!/\bif\b/i.test(ps0.prediction) || !/\bthen\b/i.test(ps0.prediction)) add('chain', 'plan', 'Observation, question, proposed answer, prediction', 'warn', 'Write the prediction as "If my proposed answer is correct, then ..." with a result you could measure, and say what would reject it.');
    else if (!LIB.keysIn(ps0.observation).length) add('chain', 'plan', 'Observation, question, proposed answer, prediction', 'warn', 'Cite at least one paper from your library in the observation, like [@key].');
    else add('chain', 'plan', 'Observation, question, proposed answer, prediction', 'ok', 'The chain is complete and the observation cites your library.');
    // 7 research plan
    const pl = st.plan || {}; const ps = pl.sections || {};
    const emptyPlan = SECTION_KEYS.plan.filter((k) => !filled(ps[k]));
    const exps = pl.experiments || []; const badExp = exps.filter((e) => !['aim', 'title', 'design', 'materials', 'equip', 'methods', 'controls', 'replication', 'sample', 'decision'].every((k) => filled(e[k])));
    const sch = checkSchedule(pl, cal); const drift = reserveDrift(pl, cal, p.reserve);
    const fbk = pl.fallback || {};
    const unver = SECTION_KEYS.plan.filter((k) => sectionState(st, 'plan.' + k) !== 'verified');
    if (emptyPlan.length) add('plan', 'plan', 'Research plan complete', 'block', 'Empty sections: ' + emptyPlan.join(', '));
    else if (!exps.length || badExp.length) add('plan', 'plan', 'Research plan complete', 'block', exps.length ? 'Incomplete experiment(s): ' + badExp.map((e) => '#' + e.n).join(', ') : 'No experiments or analyses listed.');
    else if (sch.length) add('plan', 'plan', 'Research plan complete', 'block', sch.map((x) => x.text).join(' '));
    else if (!(fbk.switchByWeek > 0) || !(fbk.hoursNeeded > 0)) add('plan', 'plan', 'Research plan complete', 'block', 'Set the latest week you can switch to the fallback and the hours it needs.');
    else if (fbk.hoursNeeded > cal.weeklyHours * Math.max(0, cal.totalWeeks - fbk.switchByWeek)) add('plan', 'plan', 'Research plan complete', 'block', 'After week ' + fbk.switchByWeek + ' only ' + cal.weeklyHours * Math.max(0, cal.totalWeeks - fbk.switchByWeek) + ' hours remain but the fallback needs ' + fbk.hoursNeeded + '.');
    else if (unver.length) add('plan', 'plan', 'Research plan complete', 'warn', unver.length + ' section(s) not yet marked verified by you.');
    else add('plan', 'plan', 'Research plan complete', 'ok', 'All sections written and verified; schedule matches the calendar.');
    if (drift.length) add('drift', 'plan', 'Schedule hours match your reserves', 'warn', drift.map((d) => d.cat + ': planned ' + d.have + ' vs reserve ' + d.target).join('; '));

    // 8 proposal
    const sec = (st.proposal && st.proposal.sections) || [];
    const emptyPro = sec.filter((s) => !filled(s.text)); const over = sec.filter((s) => s.limit && words(s.text) > s.limit);
    const unverP = sec.filter((s) => sectionState(st, 'pro.' + s.id) !== 'verified');
    const badClaims = (st.claims || []).filter((c) => !c.verified);
    const refs = LIB.refList(st); const refIds = refs.map((r) => r.id); const orphan = (st.claims || []).filter((c) => refIds.indexOf(c.ref) < 0);
    if (!sec.length) add('pro', 'pro', 'Grant proposal complete', 'block', 'No proposal sections.');
    else if (emptyPro.length) add('pro', 'pro', 'Grant proposal complete', 'block', 'Empty sections: ' + emptyPro.map((s) => s.title).join(', '));
    else if (over.length) add('pro', 'pro', 'Grant proposal complete', 'block', 'Over the length limit: ' + over.map((s) => s.title + ' (' + words(s.text) + '/' + s.limit + ')').join(', '));
    else if (!(st.budget || []).length || !(st.budget || []).every((b) => filled(b.item) && filled(b.linksTo) && Number(b.amount) >= 0)) add('pro', 'pro', 'Grant proposal complete', 'block', 'Every budget line needs an item, an amount and the activity it supports.');
    else if (unverP.length) add('pro', 'pro', 'Grant proposal complete', 'warn', unverP.length + ' section(s) not yet marked verified by you.');
    else add('pro', 'pro', 'Grant proposal complete', 'ok', 'All sections written, within limits and verified.');
    const unk = LIB.unknownKeys(st); const noDoi = refs.filter((r) => r.fromLibrary && !r.doi);
    if (unk.length) add('claims', 'pro', 'Citations and claims verified', 'block', 'Citation(s) that are not in your library: ' + unk.map((k) => '[@' + k + ']').join(', '));
    else if (!refs.length) add('claims', 'pro', 'Citations and claims verified', 'block', 'Nothing is cited. Cite papers from your library with [@key].');
    else if (orphan.length) add('claims', 'pro', 'Citations and claims verified', 'block', 'Claim(s) point to a reference that is not listed.');
    else if (badClaims.length) add('claims', 'pro', 'Citations and claims verified', 'warn', badClaims.length + ' claim(s) not yet checked against the source by you.');
    else if (noDoi.length) add('claims', 'pro', 'Citations and claims verified', 'warn', noDoi.length + ' cited paper(s) have no DOI to check: ' + noDoi.map((r) => r.id).join(', '));
    else add('claims', 'pro', 'Citations and claims verified', 'ok', 'Every claim checked against its source.');

    // 9 twin facts
    const cc = crossCheck(st);
    if (cc.length) add('twin', 'pro', 'Plan and proposal agree', 'block', cc.length + ' mismatch(es): ' + cc.map((x) => x.label).join('; '));
    else add('twin', 'pro', 'Plan and proposal agree', 'ok', 'Aims, sample rule, hours, dates, deliverable and budget match everywhere.');

    // 10 defense, pending actions
    const dq = ['gap', 'comparison', 'analysis', 'assumption']; const dMiss = dq.filter((k) => words(st.defense && st.defense[k]) < 15);
    if (dMiss.length) add('def', 'meet', 'Oral defense answers', 'block', 'Write at least 15 words for: ' + dMiss.join(', '));
    else add('def', 'meet', 'Oral defense answers', 'ok', 'Four defense answers written.');
    if (!(st.pending || []).length) add('pend', 'meet', 'Pending actions listed', 'block', 'List the signatures, letters and commitments still needed.');
    else add('pend', 'meet', 'Pending actions listed', 'ok', (st.pending || []).length + ' pending actions listed for the PI.');

    const score = items.reduce((a, i) => a + (i.level === 'ok' ? 1 : i.level === 'warn' ? 0.5 : 0), 0);
    const pct = Math.round((score / items.length) * 100);
    const blocks = items.filter((i) => i.level === 'block'), warns = items.filter((i) => i.level === 'warn');
    return { items, pct, blocks, warns, ready: blocks.length === 0 && warns.length === 0, canDraft: true };
  }

  function nextAction(st) {
    const r = readiness(st); const b = r.blocks[0] || r.warns[0];
    return b ? { view: b.view, text: b.label + ': ' + b.detail } : { view: 'meet', text: 'Everything checks out. Export the packet and contact the PI.' };
  }

  // ---------- documents ----------
  const money = (n) => '$' + (Number(n) || 0).toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 2 });
  let CUR = null; const rc = (t) => LIB.renderCites(esc(t), CUR || {});
  const para = (s) => String(s || '').split(/\n{2,}|\n/).filter(Boolean).map((x) => '<p>' + rc(x) + '</p>').join('') || '<p><em>(empty)</em></p>';
  const piCard = (id) => (root.RM_DATA && root.RM_DATA.FACULTY.find((f) => f.id === id)) || null;
  const piName = (st) => { const f = piCard(st.pi); return f ? f.honorific + ' ' + f.name : 'the PI'; };
  const PAGE_CSS = 'body{font:11.5pt/1.5 Georgia,serif;color:#111;max-width:7.2in;margin:0 auto;padding:.4in}h1{font:700 20pt Georgia,serif;margin:.1em 0}h2{font:700 13pt Arial,sans-serif;margin:1.1em 0 .2em;border-bottom:1px solid #999;padding-bottom:2px}h3{font:700 11pt Arial,sans-serif;margin:.8em 0 .1em}p{margin:.3em 0}table{border-collapse:collapse;width:100%;font:10pt Arial,sans-serif;margin:.5em 0}td,th{border:1px solid #999;padding:4px 6px;text-align:left;vertical-align:top}th{background:#eee}.banner{border:2px solid #b45309;background:#fff7e6;padding:8px 10px;font:700 10.5pt Arial,sans-serif;margin:0 0 12px}.ok{border-color:#15803d;background:#ecfdf3}.small{font:9pt Arial,sans-serif;color:#444}.pb{page-break-before:always}@page{margin:.6in}';
  const wrap = (title, body) => '<!doctype html><html lang="en"><head><meta charset="utf-8"><title>' + esc(title) + '</title><style>' + PAGE_CSS + '</style></head><body>' + body + '</body></html>';
  function banner(st) {
    const r = readiness(st);
    if (r.ready) return '<div class="banner ok">Prepared packet: every readiness check passes. External signatures and PI commitments are still pending (listed on the decision sheet).</div>';
    return '<div class="banner">DRAFT: NOT READY FOR OUTREACH. ' + r.blocks.length + ' blocking item(s), ' + r.warns.length + ' open warning(s): ' + esc(r.blocks.concat(r.warns).map((i) => i.label).join('; ')) + '.</div>';
  }
  function exampleBanner(st) { return st.meta && st.meta.example ? '<div class="banner">WORKED EXAMPLE: the student, dates, hours and budget uses are illustrative. The papers, dataset and funder facts are real and cited.</div>' : ''; }

  function planHTML(st) {
    CUR = st;
    const pl = st.plan, s = pl.sections, cal = calendar(st.profile);
    const L = { observation: 'Observation', answer: 'Proposed answer to the question (the hypothesis)', prediction: 'Prediction (what I expect to measure, and what would reject the answer)', background: 'Background', evidence: 'Supporting evidence', gap: 'The gap', question: 'Research question', aims: 'Specific aims', variables: 'Variables, units, metadata, missing data and quality checks', analysis: 'Analysis plan, tables and figures', interpretation: 'Interpreting supportive, contradictory and inconclusive results', approvals: 'Training, supervision, permissions, safety and approvals', handoff: 'Handoff to the lab' };
    let h = exampleBanner(st) + banner(st) + '<h1>Research plan</h1><p class="small">' + esc(pl.title || '') + '<br>Student: ' + esc(st.profile.name) + ' &middot; PI: ' + esc(piName(st)) + ' &middot; Window: ' + (isNaN(cal.first) ? '' : fmt(cal.first)) + ' to ' + (isNaN(cal.last) ? '' : fmt(cal.last)) + ' &middot; ' + cal.total + ' hours</p>';
    ['observation', 'background', 'evidence', 'gap', 'question', 'answer', 'prediction', 'aims'].forEach((k) => { h += '<h2>' + L[k] + '</h2>' + para(s[k]); });
    h += '<h2>Materials and methods: the experiments and analyses that test the prediction</h2>';
    pl.experiments.forEach((e) => {
      h += '<h3>' + e.n + '. ' + esc(e.title) + ' (' + esc(e.aim) + ')</h3><table>' + [['Design', e.design], ['Materials and quantities', e.materials], ['Equipment or software', e.equip], ['Methods', e.methods], ['Controls or comparison groups', e.controls], ['Replication', e.replication], ['Sample-size rationale', e.sample], ['Decision it informs', e.decision]].map((r) => '<tr><th style="width:1.7in">' + r[0] + '</th><td>' + rc(r[1]) + '</td></tr>').join('') + '</table>';
    });
    ['variables', 'analysis', 'interpretation'].forEach((k) => { h += '<h2>' + L[k] + '</h2>' + para(s[k]); });
    h += '<h2>Week-by-week schedule</h2><table><tr><th>Weeks</th><th>Dates</th><th>Work</th><th>Hours</th></tr>' + pl.schedule.map((p) => {
      const w1 = cal.weeks[p.from - 1], w2 = cal.weeks[p.to - 1]; const hr = Object.values(p.cat).reduce((a, b) => a + b, 0);
      return '<tr><td>' + p.from + (p.to > p.from ? '&ndash;' + p.to : '') + '</td><td>' + (w1 ? fmt(w1.monday) : '') + (w2 && p.to > p.from ? ' &ndash; ' + fmt(w2.monday) : '') + '</td><td>' + esc(p.label) + '</td><td>' + hr + '</td></tr>';
    }).join('') + '</table><p><strong>Fallback.</strong> Latest switch: end of week ' + pl.fallback.switchByWeek + '. ' + esc(pl.fallback.note) + '</p>';
    h += '<h2>Resource inventory</h2><table><tr><th>Resource</th><th>Evidence the lab has used it</th><th>Can I use it for this project?</th></tr>' + st.resources.map((r) => '<tr><td>' + esc(r.name) + (r.critical ? ' <strong>(critical)</strong>' : '') + '<br><span class="small">Role: ' + esc(r.role) + '</span></td><td>' + esc(usedLabel(r.used)) + ': ' + esc(r.usedNote) + '<br><span class="small">Source: ' + esc(r.usedSrc) + '</span></td><td><strong>' + esc(accessLabel(r.access)) + '.</strong> ' + esc(r.accessNote) + (r.route ? '<br><span class="small">If not: ' + esc(r.route) + '</span>' : '') + '</td></tr>').join('') + '</table>';
    h += '<h2>Cost inventory</h2>' + budgetTable(st);
    h += '<h2>' + L.approvals + '</h2>' + para(s.approvals) + '<h2>' + L.handoff + '</h2>' + para(s.handoff);
    return wrap('Research plan: ' + (pl.title || ''), h);
  }
  const usedLabel = (u) => ({ method: 'Described in methods or the dataset page', title: 'Named in a paper title or abstract only', profile: 'Named on a faculty profile or website', '': 'No evidence recorded' }[u || '']);
  const accessLabel = (a) => ({ public: 'Public / open', confirmed: 'Confirmed for this project', unconfirmed: 'NOT CONFIRMED', '': 'Unknown' }[a || '']);
  function budgetTable(st) {
    const t = budgetTotals(st.budget);
    return '<table><tr><th>Item</th><th>Amount</th><th>Supports (activity)</th><th>Basis</th></tr>' + st.budget.map((b) => '<tr><td>' + esc(b.item) + '</td><td>' + money(b.amount) + '</td><td>' + esc(b.linksTo) + '</td><td>' + esc(b.basis) + '</td></tr>').join('') + '<tr><th>Total</th><th>' + money(t.total) + '</th><th colspan="2">Student ' + money(t.student) + ' &middot; Supplies ' + money(t.supplies) + '</th></tr></table>';
  }
  function proposalHTML(st) {
    CUR = st;
    const f = funder(st.funding.primary); const pr = st.proposal;
    let h = exampleBanner(st) + banner(st) + '<h1>Grant proposal</h1><p class="small">' + esc(st.plan.title || '') + '<br>Applicant: ' + esc(st.profile.name) + ' &middot; Mentor: ' + esc(piName(st)) + ' &middot; Funder: ' + esc(f ? f.name : '') + '</p>';
    if (pr.modelNote) h += '<p class="small"><em>' + esc(pr.modelNote) + '</em></p>';
    pr.sections.forEach((s) => { h += '<h2>' + esc(s.title) + (s.limit ? ' <span class="small">(' + words(s.text) + ' of ' + s.limit + ' words)</span>' : '') + '</h2>' + para(s.text); if (s.id === 'budgetnote') h += budgetTable(st); });
    h += '<h2>References</h2><ul style="list-style:none;padding:0">' + LIB.refList(st).map((r) => '<li>' + esc(r.cite) + ' <span class="small">doi:' + esc(r.doi) + '</span></li>').join('') + '</ul>';
    h += '<h2>Claim ledger (student-verified)</h2><table><tr><th>Claim</th><th>Source</th><th>Checked</th></tr>' + st.claims.map((c) => '<tr><td>' + esc(c.text) + '</td><td>' + esc(c.ref) + '</td><td>' + (c.verified ? 'Yes' : 'NOT YET') + '</td></tr>').join('') + '</table>';
    h += '<h2>Pending signatures, letters and commitments</h2><ul>' + st.pending.map((x) => '<li>' + esc(x) + '</li>').join('') + '</ul>';
    return wrap('Grant proposal: ' + (st.plan.title || ''), h);
  }
  function decisions(st) {
    const out = [];
    (st.resources || []).filter((r) => r.access === 'unconfirmed').forEach((r) => out.push({ kind: 'Resource', text: 'Can I use "' + r.name + '" for this project? ' + (r.accessNote || '') }));
    const f = funder(st.funding && st.funding.primary);
    if (f) (f.unverified || []).forEach((u) => { const v = st.funding.resolutions && st.funding.resolutions[f.id + '|' + u]; if (!filled(v)) out.push({ kind: 'Funding', text: f.name + ': ' + u + ' (still unverified).' }); });
    const fb = st.plan && st.plan.fallback; if (fb) out.push({ kind: 'Scheduling', text: 'Do you agree the go/switch checkpoint should be end of week ' + fb.switchByWeek + ' (fallback needs about ' + fb.hoursNeeded + ' hours)?' });
    if (st.defense && st.defense.assumption) out.push({ kind: 'Science', text: 'The assumption most likely to change the project: ' + st.defense.assumption });
    out.push({ kind: 'Supervision', text: 'Will you supervise (weekly meeting) and review my draft? This is a commitment only you can make.' });
    (st.meeting && st.meeting.decisions || []).forEach((d) => { if (d.ask) out.push({ kind: 'Added', text: d.ask }); });
    return out;
  }
  function decisionHTML(st) {
    CUR = st;
    const rows = decisions(st);
    let h = exampleBanner(st) + banner(st) + '<h1>Decision sheet for ' + esc(piName(st)) + '</h1><p class="small">One page: the decisions I need help with before I submit. From ' + esc(st.profile.name) + '.</p><table><tr><th style="width:1in">Type</th><th>Decision requested</th><th style="width:1.6in">Your answer</th></tr>' + rows.map((r) => '<tr><td>' + esc(r.kind) + '</td><td>' + esc(r.text) + '</td><td>&nbsp;</td></tr>').join('') + '</table>';
    h += '<h2>Pending signatures, letters and commitments</h2><ul>' + st.pending.map((x) => '<li>' + esc(x) + '</li>').join('') + '</ul>';
    return wrap('Decision sheet', h);
  }
  function emailDraft(st) {
    const f = piCard(st.pi); const fu = funder(st.funding && st.funding.primary); const g = (st.gaps || []).find((x) => x.id === st.chosenGap);
    const recent = (st.papers || []).find((x) => x.role === 'recent');
    const first = (st.profile.name || '').split(' ')[0] || 'Student';
    const subject = 'Request to meet: proposed student project connected to your recent paper';
    const body = 'Dear ' + (f ? f.honorific + ' ' + f.last : 'Professor') + ',\n\n' +
      'I am a ' + (st.profile.year || '').toLowerCase() + ' in ' + (st.profile.major || 'Biological Sciences') + '. I studied your work' + (recent ? ', especially "' + recent.title.replace(/\s*\(\d{4}\)$/, '') + '"' : '') + ', compared three possible contributions, and wrote a full research plan and grant proposal for the one that fits the science and the time I have.\n\n' +
      'The contribution I propose: ' + (g ? g.title : '[chosen gap]') + '. ' + ((st.plan.sections.question) || '') + '\n\n' +
      'I plan to apply to the ' + (fu ? fu.name : '[funding opportunity]') + '. I am attaching the proposal, the research plan and a one-page decision sheet. I would be grateful for 30 minutes to ask for your scientific feedback and a few decisions only you can make, including whether you could supervise the work.\n\n' +
      'Could we meet during one of these windows? [add two or three times that work for you]\n\n' +
      'Thank you for considering this.\n\n' + (st.profile.name || first) + '\n' + (st.profile.year || '') + ', ' + (st.profile.major || '') + '\n';
    const to = f && f.email ? f.email : '';
    return { to, subject, body, mailto: 'mailto:' + encodeURIComponent(to).replace(/%40/g, '@') + '?subject=' + encodeURIComponent(subject) + '&body=' + encodeURIComponent(body) };
  }
  function packetHTML(st) {
    CUR = st;
    const strip = (h) => h.replace(/^[\s\S]*?<body>/, '').replace(/<\/body>[\s\S]*$/, '').replace(/<div class="banner[^"]*">[\s\S]*?<\/div>/g, '');
    const e = emailDraft(st);
    const cover = exampleBanner(st) + banner(st) + '<h1>Faculty meeting packet</h1><p>For ' + esc(piName(st)) + '. From ' + esc(st.profile.name) + '.</p><p class="small">Contents: (1) grant proposal, (2) research plan, (3) one-page decision sheet, (4) outreach email draft. Outreach and submission stay under the student’s control.</p>';
    return wrap('Faculty meeting packet', cover + '<div class="pb">' + strip(proposalHTML(st)) + '</div><div class="pb">' + strip(planHTML(st)) + '</div><div class="pb">' + strip(decisionHTML(st)) + '</div><div class="pb"><h1>Outreach email draft</h1><p class="small">To: ' + esc(e.to || '(add the PI’s email)') + '<br>Subject: ' + esc(e.subject) + '</p>' + para(e.body) + '</div>');
  }

  const api = { CLASS_COLORS, toMin, fmtMin, slotMin, classBusy, studyPlan, weekPattern, dayPlan, suggestTimes, freeSlots, courseLevel, visibleCourses, YEAR_IDX, esc, norm, words, filled, parse, iso, fmt, calendar, reserve, checkSchedule, scheduleTotals, reserveDrift, gapAnswered, gapScreen, gapScore, rankGaps, budgetTotals, fundingCheck, crossCheck, readiness, nextAction, sectionState, decisions, planHTML, proposalHTML, decisionHTML, emailDraft, packetHTML, funder, piCard, piName, money, FACT_LABEL, SECTION_KEYS, usedLabel, accessLabel };
  root.StudioCore = api;
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
})(typeof window !== 'undefined' ? window : globalThis);
