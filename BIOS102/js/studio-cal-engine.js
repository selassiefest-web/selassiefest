// BIOS102 Research-to-Grant Studio: the calendar engine. Pure functions (no DOM) so it can be tested in Node.
// The student's life is a list of events with exact times: classes (coloured), and everything else (work, church,
// family, sleep, commute, sports, appointments, trips) greyed out as "busy". Events can repeat weekly, happen once,
// or span a range of dates (a vacation). From that we compute, to the minute, what time is really free; where study
// time for each class goes (90-minute blocks); and which stretches are left for research.
(function (root) {
  'use strict';
  const DAYK = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  const DAYMS = 86400000;
  const REF = ['2001-01-01', '2001-01-02', '2001-01-03', '2001-01-04', '2001-01-05', '2001-01-06', '2001-01-07'];   // a Monday to a Sunday
  const CLASS_COLORS = ['#fb7185', '#4ade80', '#fbbf24', '#60a5fa', '#a78bfa', '#f472b6', '#2dd4bf', '#fb923c'];
  const CAT = {
    class: { label: 'Class', icon: '📚', color: '#4ade80', grey: false },
    work: { label: 'Work', icon: '💼', color: '#94a3b8', grey: true },
    faith: { label: 'Church or faith', icon: '⛪', color: '#a8a29e', grey: true },
    family: { label: 'Family and home', icon: '🏠', color: '#9ca3af', grey: true },
    sleep: { label: 'Sleep', icon: '😴', color: '#64748b', grey: true },
    commute: { label: 'Commute', icon: '🚌', color: '#a1a1aa', grey: true },
    activity: { label: 'Sports or club', icon: '🏃', color: '#9ca3af', grey: true },
    appt: { label: 'Appointment', icon: '🩺', color: '#a3a3a3', grey: true },
    travel: { label: 'Trip or day off', icon: '✈️', color: '#8b8fa3', grey: true },
    other: { label: 'Other busy time', icon: '⏸️', color: '#94a3b8', grey: true },
  };
  // sensible starting points for the quick-add buttons
  const PRESETS = {
    work: { title: 'Work', days: ['mon', 'tue', 'wed', 'thu', 'fri'], start: '09:00', end: '17:00' },
    faith: { title: 'Church', days: ['sun'], start: '09:00', end: '12:00' },
    family: { title: 'Family time', days: ['sat'], start: '12:00', end: '18:00' },
    sleep: { title: 'Sleep', days: DAYK.slice(), start: '22:00', end: '07:00' },
    commute: { title: 'Commute', days: ['mon', 'tue', 'wed', 'thu', 'fri'], start: '08:00', end: '08:45' },
    activity: { title: 'Practice or club', days: ['tue', 'thu'], start: '18:00', end: '19:30' },
    appt: { title: 'Appointment', days: [], start: '10:00', end: '11:00' },
    travel: { title: 'Trip or day off', days: [], start: '09:00', end: '17:00' },
    other: { title: 'Busy', days: [], start: '12:00', end: '13:00' },
  };

  const toMin = (s) => { const m = /^(\d{1,2}):(\d{2})$/.exec(String(s || '')); return m ? (+m[1]) * 60 + (+m[2]) : NaN; };
  const hhmm = (m) => String(Math.floor(m / 60) % 24).padStart(2, '0') + ':' + String(m % 60).padStart(2, '0');
  const fmt = (m) => { m = ((m % 1440) + 1440) % 1440; const h = Math.floor(m / 60), mm = m % 60; return ((h + 11) % 12 + 1) + ':' + String(mm).padStart(2, '0') + ' ' + (h < 12 ? 'am' : 'pm'); };
  const parse = (s) => { const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(s || '')); return m ? Date.UTC(+m[1], +m[2] - 1, +m[3]) : NaN; };
  const iso = (t) => new Date(t).toISOString().slice(0, 10);
  const dowOf = (s) => (new Date(parse(s)).getUTCDay() + 6) % 7;
  const addDays = (s, n) => iso(parse(s) + n * DAYMS);

  function allEvents(p) {
    const ev = ((p && p.events) || []).map((e, i) => Object.assign({ repeat: 'weekly' }, e, { src: 'event', idx: i }));
    const cls = ((p && p.classes) || []).map((c, i) => ({ id: c.id, title: c.course || 'Class', cat: 'class', repeat: 'weekly', days: c.days || [], start: c.start, end: c.end, color: c.color || CLASS_COLORS[i % 8], study: Number(c.study) || 0, src: 'class', idx: i }));
    return ev.concat(cls);
  }
  function applies(e, d) {
    if (e.repeat === 'once') return e.date === d;
    if (e.repeat === 'range') return !!e.from && !!e.to && e.from <= d && d <= (e.to || e.from);
    if ((e.days || []).indexOf(DAYK[dowOf(d)]) < 0) return false;
    if (e.since && d < e.since) return false; if (e.until && d > e.until) return false; return true;
  }
  // the pieces of events that fall on one date (an event that runs past midnight spills into the next date)
  function segs(events, d) {
    const out = []; const prev = addDays(d, -1);
    events.forEach((e) => {
      if (applies(e, d)) { if (e.allDay) out.push({ from: 0, to: 1440, ev: e }); else { const s = toMin(e.start), t = toMin(e.end); if (!isNaN(s) && !isNaN(t)) { if (t > s) out.push({ from: s, to: t, ev: e }); else if (t < s) out.push({ from: s, to: 1440, ev: e }); } } }
      if (!e.allDay && applies(e, prev)) { const s = toMin(e.start), t = toMin(e.end); if (!isNaN(s) && !isNaN(t) && t < s) out.push({ from: 0, to: t, ev: e, tail: true }); }
    });
    return out;
  }
  const windowOf = (p) => { const a = toMin((p && p.dayStart) || '07:00'), b = toMin((p && p.dayEnd) || '22:00'); return { ws: isNaN(a) ? 420 : a, we: isNaN(b) || b <= (isNaN(a) ? 420 : a) ? 1320 : b }; };
  const merge = (list) => { const s = list.map((x) => ({ from: x.from, to: x.to })).filter((x) => x.to > x.from).sort((a, b) => a.from - b.from); const out = []; s.forEach((x) => { const l = out[out.length - 1]; if (l && x.from <= l.to) l.to = Math.max(l.to, x.to); else out.push(x); }); return out; };
  const clip = (list, win) => list.map((x) => ({ from: Math.max(x.from, win.ws), to: Math.min(x.to, win.we) })).filter((x) => x.to > x.from);
  const complement = (busy, win, minLen) => { const out = []; let c = win.ws; merge(clip(busy, win)).forEach((b) => { if (b.from > c) out.push({ from: c, to: b.from }); c = Math.max(c, b.to); }); if (c < win.we) out.push({ from: c, to: win.we }); return out.filter((x) => x.to - x.from >= (minLen || 0)); };
  const subtract = (pieces, busy, minLen) => { let out = pieces.slice(); merge(busy).forEach((b) => { const next = []; out.forEach((x) => { if (b.to <= x.from || b.from >= x.to) next.push(x); else { if (b.from > x.from) next.push({ from: x.from, to: b.from }); if (b.to < x.to) next.push({ from: b.to, to: x.to }); } }); out = next; }); return out.filter((x) => x.to - x.from >= (minLen == null ? 30 : minLen)); };
  const minBlock = (p) => Math.max(15, Number(p && p.minBlock) || 60);

  // ---- a usual week: weekly events only, then study blocks, then the research that is left ----
  function pattern(p) {
    const evs = allEvents(p).filter((e) => e.repeat !== 'once' && e.repeat !== 'range').map((e) => Object.assign({}, e, { since: null, until: null }));
    const win = windowOf(p); const minB = minBlock(p);
    const days = REF.map((ref) => { const sg = segs(evs, ref); return { segs: sg, busy: merge(clip(sg, win)), free: [], study: [], research: [] }; });
    days.forEach((d) => { d.free = complement(d.busy, win, minB); d.after = d.free.map((x) => ({ from: x.from, to: x.to })); });
    // study: 90-minute blocks for each class, in free weekday time (Monday to Friday, then Sunday), at most two a day
    const need = ((p && p.classes) || []).filter((c) => Number(c.study) > 0).map((c, i) => ({ course: c.course || 'class', color: c.color || CLASS_COLORS[i % 8], left: Number(c.study) * 60 }));
    if (need.length) [0, 1, 2, 3, 4, 6].forEach((d) => {
      let placed = 0;
      while (placed < 2) {
        const iv = days[d].after.find((x) => x.to - x.from >= minB); const t = need.filter((n) => n.left > 0).sort((a, b) => b.left - a.left)[0]; if (!iv || !t) break;
        const dur = Math.min(90, iv.to - iv.from, t.left); if (dur < 30) break;
        days[d].study.push({ from: iv.from, to: iv.from + dur, label: 'Study ' + t.course, course: t.course, color: t.color }); t.left -= dur; iv.from += dur; placed++;
      }
      days[d].after = days[d].after.filter((x) => x.to - x.from >= minB);
    });
    // research: the longest free stretches first, until the hours you want are covered
    const want = (Number(p && p.weeklyHours) || 0) * 60; let rem = want; const runs = [];
    days.forEach((d, di) => d.after.forEach((x) => runs.push({ d: di, from: x.from, to: x.to })));
    const capacity = runs.reduce((a, r) => a + (r.to - r.from), 0) / 60;
    runs.sort((a, b) => (b.to - b.from) - (a.to - a.from) || a.d - b.d || a.from - b.from);
    runs.forEach((r) => { if (rem <= 0) return; const dur = Math.min(r.to - r.from, rem, 240); if (dur < 30) return; days[r.d].research.push({ from: r.from, to: r.from + dur, label: 'Research', color: '#22d3ee' }); rem -= dur; });
    return { days, capacity, want: want / 60, enough: capacity * 60 >= want, hasLife: ((p && p.events) || []).length + ((p && p.classes) || []).length > 0 };
  }
  function suggestTimes(p, pat) {
    pat = pat || pattern(p); const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']; const picks = [];
    pat.days.forEach((d, di) => d.research.forEach((r) => picks.push({ d: di, day: names[di], from: r.from, to: r.to, label: names[di] + ' ' + fmt(r.from) + ' to ' + fmt(r.to), hours: (r.to - r.from) / 60 })));
    return { picks, capacity: pat.capacity, want: pat.want, enough: pat.enough, hasLife: pat.hasLife };
  }
  // ---- one date: its events, plus the study and research that fit around them ----
  function dayItems(p, d, pat, opt) {
    pat = pat || pattern(p); const evs = allEvents(p); const win = windowOf(p); const di = dowOf(d); const force = !!(opt && opt.forcePeriod);
    const inPeriod = force || ((p && p.periods) || []).some((x) => { const s = parse(x.start), e = parse(x.end), t = parse(d); return !isNaN(s) && !isNaN(e) && t >= s && t <= e; });
    const sg = segs(evs, d); const items = [];
    sg.forEach((s) => items.push({ kind: s.ev.cat === 'class' ? 'class' : 'event', ev: s.ev, label: s.ev.title || (CAT[s.ev.cat] || CAT.other).label, cat: s.ev.cat, from: s.from, to: s.to, color: s.ev.color || (CAT[s.ev.cat] || CAT.other).color, tail: !!s.tail, allDay: !!s.ev.allDay }));
    const busyAll = merge(clip(sg, win));
    if (inPeriod && pat.hasLife) {
      pat.days[di].study.forEach((b) => subtract([{ from: b.from, to: b.to }], busyAll).forEach((x) => items.push({ kind: 'study', label: b.label, course: b.course, from: x.from, to: x.to, color: b.color })));
      pat.days[di].research.forEach((b) => subtract([{ from: b.from, to: b.to }], busyAll).forEach((x) => items.push({ kind: 'research', label: 'Research', from: x.from, to: x.to, color: b.color })));
    }
    items.sort((a, b) => a.from - b.from || a.to - b.to);
    const studyBlocks = items.filter((x) => x.kind === 'study').map((x) => ({ from: x.from, to: x.to }));
    const free = complement(busyAll.concat(studyBlocks), win, minBlock(p));
    const freeRaw = complement(busyAll, win, minBlock(p));
    return { iso: d, d: di, inPeriod, items, free, freeRaw, allDay: sg.some((s) => s.ev.allDay) };
  }
  // the research hours really available in one week (Monday-start), after every event and the study blocks
  function weekMinutes(p, mondayMs, pat) {
    pat = pat || pattern(p); let total = 0;
    for (let k = 0; k < 7; k++) { const dd = dayItems(p, iso(mondayMs + k * DAYMS), pat, { forcePeriod: true }); total += dd.free.reduce((a, x) => a + (x.to - x.from), 0); }
    return total;
  }
  // older saves used a grid of two-hour blocks and a list of blocked dates: turn them into events
  function fromLegacy(p) {
    const ev = []; const SL = (root.STUDIO_DATA && root.STUDIO_DATA.SLOTS) || [];
    DAYK.forEach((k) => { const idx = ((p.weekBlack || {})[k] || []).slice().sort((a, b) => a - b); let i = 0; while (i < idx.length) { let j = i; while (j + 1 < idx.length && idx[j + 1] === idx[j] + 1) j++; ev.push({ id: 'm' + k + i, title: 'Busy', cat: 'other', repeat: 'weekly', days: [k], start: hhmm(480 + 120 * idx[i]), end: hhmm(600 + 120 * idx[j]) }); i = j + 1; } });
    const dates = ((p.blackDates || []).slice().sort()); let i = 0; while (i < dates.length) { let j = i; while (j + 1 < dates.length && addDays(dates[j], 1) === dates[j + 1]) j++; ev.push({ id: 'b' + i, title: 'Day off', cat: 'travel', repeat: 'range', from: dates[i], to: dates[j], allDay: true }); i = j + 1; }
    return ev;
  }

  root.StudioCal = { DAYK, REF, CAT, PRESETS, CLASS_COLORS, DAYMS, toMin, hhmm, fmt, parse, iso, dowOf, addDays, allEvents, applies, segs, windowOf, merge, complement, subtract, minBlock, pattern, suggestTimes, dayItems, weekMinutes, fromLegacy };
  if (typeof module !== 'undefined' && module.exports) module.exports = root.StudioCal;
})(typeof window !== 'undefined' ? window : globalThis);
