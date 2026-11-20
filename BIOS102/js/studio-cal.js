// BIOS102 Research-to-Grant Studio: the calendar. A real calendar for the life the student is living:
// classes in colour, everything else (church, work, family, sleep, commute...) greyed out, exact times, week / day /
// month views you can page through, drag to create, click to edit. Study time and research time are drawn into
// whatever free time is left. Two pages use it: "Your usual week" (the repeating template) and "Your calendar"
// (real dates, with one-time events and days away).
(function (root) {
  'use strict';
  const E = root.StudioCal, C = root.StudioCore, D = root.STUDIO_DATA;
  let X = null;
  const T0 = 360, T1 = 1440, HPX = 34;     // the grid shows 6:00 am to midnight
  const ui = { view: 'week', anchor: '', sel: '', draft: null };
  const esc = (s) => C.esc(s);
  const P = () => X.S().profile;
  const todayIso = () => new Date().toISOString().slice(0, 10);
  const DN = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const MON = (iso) => E.addDays(iso, -E.dowOf(iso));
  const fmtDate = (iso, o) => new Date(E.parse(iso)).toLocaleDateString('en-US', Object.assign({ timeZone: 'UTC' }, o));
  const periodsOk = () => P().periods.filter((x) => !isNaN(E.parse(x.start)) && !isNaN(E.parse(x.end)));
  function anchor() { if (ui.anchor && !isNaN(E.parse(ui.anchor))) return ui.anchor; const ps = periodsOk(); const t = todayIso(); const inP = ps.find((x) => t >= x.start && t <= x.end); return inP ? t : (ps[0] ? ps[0].start : t); }
  const gaps = () => ({ pat: E.pattern(P()) });

  // ---------- one column of time ----------
  function layout(items) {
    const cols = []; items.forEach((it) => { let c = 0; while (cols[c] !== undefined && cols[c] > it.from) c++; cols[c] = it.to; it._c = c; });
    items.forEach((it) => { const ov = items.filter((o) => o.from < it.to && o.to > it.from); it._n = Math.max.apply(null, ov.map((o) => o._c)) + 1; });
  }
  const top = (m) => Math.max(0, (m - T0) / 60 * HPX), hgt = (a, b) => Math.max(12, (Math.min(b, T1) - Math.max(a, T0)) / 60 * HPX);
  function hourLines(labels) { const out = []; for (let m = T0; m <= T1; m += 60) out.push('<i class="gs-gline" style="top:' + top(m) + 'px">' + (labels && m < T1 ? '<b>' + E.fmt(m).replace(':00', '') + '</b>' : '') + '</i>'); return out; }
  function colHtml(col, p, pat, showHours) {
    const win = E.windowOf(p); const info = col.info; const timed = info.items.filter((i) => !i.allDay); layout(timed);
    const lines = hourLines(false);
    const free = info.freeRaw.map((x) => '<div class="gs-free" style="top:' + top(x.from) + 'px;height:' + hgt(x.from, x.to) + 'px" title="Free: ' + E.fmt(x.from) + ' to ' + E.fmt(x.to) + '"></div>').join('');
    const off = '<div class="gs-off" style="top:0;height:' + top(win.ws) + 'px"></div><div class="gs-off" style="top:' + top(win.we) + 'px;bottom:0"></div>';
    const blocks = timed.map((it) => {
      const w = 100 / it._n, left = it._c * w; const editable = it.ev && (it.kind === 'class' || it.kind === 'event');
      const cat = it.ev ? E.CAT[it.ev.cat] || E.CAT.other : null; const icon = it.kind === 'class' ? '' : it.kind === 'event' ? (cat.icon + ' ') : it.kind === 'study' ? '📖 ' : '🔬 ';
      const tip = (it.label || '') + ' ' + E.fmt(it.from) + ' to ' + E.fmt(it.to) + (it.tail ? ' (continues from the night before)' : '');
      const attrs = editable ? ' data-act="evedit" data-src="' + it.ev.src + '" data-idx="' + it.ev.idx + '"' : '';
      return '<button type="button" class="gs-ev ' + it.kind + '" style="top:' + top(it.from) + 'px;height:' + hgt(it.from, it.to) + 'px;left:calc(' + left + '% + 1px);width:calc(' + w + '% - 3px);--c:' + esc(it.color || '#94a3b8') + '"' + attrs + ' title="' + esc(tip) + '"><span class="t">' + icon + esc(it.label) + '</span>' + (hgt(it.from, it.to) > 34 ? '<span class="tm">' + E.fmt(it.from) + ' to ' + E.fmt(it.to) + '</span>' : '') + '</button>';
    }).join('');
    const now = (col.iso === todayIso()) ? (() => { const d = new Date(); const m = d.getHours() * 60 + d.getMinutes(); return m >= T0 ? '<i class="gs-now" style="top:' + top(m) + 'px"></i>' : ''; })() : '';
    const allday = info.items.filter((i) => i.allDay).map((it) => '<button type="button" class="gs-ad" style="--c:' + esc(it.color || '#8b8fa3') + '"' + (it.ev ? ' data-act="evedit" data-src="' + it.ev.src + '" data-idx="' + it.ev.idx + '"' : '') + '>' + ((E.CAT[it.ev.cat] || E.CAT.other).icon) + ' ' + esc(it.label) + '</button>').join('');
    const blocked = info.allDay ? ' gs-blockedday' : '';
    return '<div class="gs-wcol' + (col.iso === todayIso() ? ' today' : '') + (info.inPeriod ? '' : ' outside') + '"><div class="gs-wh"><b>' + esc(col.label) + '</b>' + (col.sub ? '<span>' + esc(col.sub) + '</span>' : '') + (allday ? '<div class="gs-adrow">' + allday + '</div>' : '') + '</div><div class="gs-wbody' + blocked + '" data-key="' + esc(col.key) + '" data-iso="' + esc(col.iso || '') + '" data-di="' + col.di + '" data-mode="' + col.mode + '" style="height:' + ((T1 - T0) / 60 * HPX) + 'px">' + lines.join('') + free + off + blocks + now + '</div></div>';
  }
  function weekCols(mode, startIso, n, pat) {
    const p = P(); const cols = [];
    for (let k = 0; k < n; k++) {
      if (mode === 'template') { const di = k; cols.push({ key: 'tpl-' + E.DAYK[di], iso: E.REF[di], label: DN[di].slice(0, 3), sub: '', di, mode, info: E.dayItems(p, E.REF[di], pat, { forcePeriod: true }) }); }
      else { const iso = E.addDays(startIso, k); const di = E.dowOf(iso); cols.push({ key: 'd-' + iso, iso, label: DN[di].slice(0, 3), sub: fmtDate(iso, { month: 'short', day: 'numeric' }), di, mode, info: E.dayItems(p, iso, pat) }); }
    }
    return cols;
  }
  function grid(cols, pat) {
    const p = P(); const hours = '<div class="gs-wcol gs-hours"><div class="gs-wh"></div><div class="gs-hbody" style="height:' + ((T1 - T0) / 60 * HPX) + 'px">' + hourLines(true).join('') + '</div></div>';
    return '<div class="gs-wscroll" id="wscroll"><div class="gs-wgrid" style="grid-template-columns:48px repeat(' + cols.length + ',minmax(' + (cols.length > 3 ? 92 : 220) + 'px,1fr))">' + hours + cols.map((c, i) => colHtml(c, p, pat, i === 0)).join('') + '</div></div>';
  }

  // ---------- chrome around the grid ----------
  function quickAdd(mode) {
    const cats = Object.keys(E.CAT).filter((k) => k !== 'class');
    return '<div class="gs-quick"><b>Add:</b> <button type="button" class="gs-qbtn cls" data-act="calnew" data-cat="class">' + E.CAT.class.icon + ' Class</button>' + cats.map((k) => '<button type="button" class="gs-qbtn" data-act="calnew" data-cat="' + k + '">' + E.CAT[k].icon + ' ' + esc(E.CAT[k].label) + '</button>').join('') + '</div>';
  }
  function legend() {
    return '<div class="gs-keyrow"><span class="gs-kchip" style="--c:#4ade80">Class (a colour for each)</span><span class="gs-kchip grey">Busy: work, church, family, sleep... (greyed out)</span><span class="gs-kchip study" style="--c:#a78bfa">Study</span><span class="gs-kchip research">Research</span><span class="gs-kchip free">Free time</span></div>';
  }
  function emptyHint(pat) { return pat.hasLife ? '' : '<div class="gs-warnbox">Nothing is entered yet, so the whole day looks free and no research times are suggested. Add your classes, work, church, family time, sleep and anything else that takes your time, and the free time left over will appear.</div>'; }
  function eventList(mode) {
    const p = P(); const rows = (p.events || []).map((e, i) => ({ e, i })).filter((x) => mode === 'template' ? (x.e.repeat || 'weekly') === 'weekly' : (x.e.repeat === 'once' || x.e.repeat === 'range'));
    const cls = mode === 'template' ? (p.classes || []).map((c, i) => ({ c, i })) : [];
    const when = (e) => e.repeat === 'once' ? fmtDate(e.date, { month: 'short', day: 'numeric', year: 'numeric' }) : e.repeat === 'range' ? fmtDate(e.from, { month: 'short', day: 'numeric' }) + ' to ' + fmtDate(e.to, { month: 'short', day: 'numeric', year: 'numeric' }) : (e.days || []).map((d) => d.slice(0, 1).toUpperCase() + d.slice(1, 3)).join(', ');
    const li = rows.map(({ e, i }) => '<li><span class="gs-dot" style="background:' + esc((E.CAT[e.cat] || E.CAT.other).color) + '"></span><b>' + esc((E.CAT[e.cat] || E.CAT.other).icon + ' ' + (e.title || E.CAT[e.cat].label)) + '</b> <span class="gs-note">' + esc(when(e)) + (e.allDay ? ' · all day' : ' · ' + E.fmt(E.toMin(e.start)) + ' to ' + E.fmt(E.toMin(e.end))) + '</span> <button class="gs-btn3 gs-sm" data-act="evedit" data-src="event" data-idx="' + i + '">Edit</button></li>').join('') + cls.map(({ c, i }) => '<li><span class="gs-dot" style="background:' + esc(c.color) + '"></span><b>📚 ' + esc(c.course || 'Class') + '</b> <span class="gs-note">' + esc((c.days || []).map((d) => d.slice(0, 1).toUpperCase() + d.slice(1, 3)).join(', ')) + ' · ' + E.fmt(E.toMin(c.start)) + ' to ' + E.fmt(E.toMin(c.end)) + '</span> <button class="gs-btn3 gs-sm" data-act="evedit" data-src="class" data-idx="' + i + '">Edit</button></li>').join('');
    return '<details class="gs-ex"' + (li ? '' : '') + '><summary>' + (mode === 'template' ? 'Everything that repeats each week' : 'One-time events and days away') + ' (' + (rows.length + cls.length) + ')</summary>' + (li ? '<ul class="gs-evlist">' + li + '</ul>' : '<p class="gs-note">Nothing here yet.</p>') + '</details>';
  }

  // ---------- the editor ----------
  const field = (id, label, inner) => '<div><label class="gs-f" for="ed-' + id + '">' + label + '</label>' + inner + '</div>';
  function editor() {
    const d = ui.draft; if (!d) return ''; const ev = d.ev; const isClass = d.src === 'class'; const mode = d.mode;
    const catSel = isClass ? '' : field('cat', 'What kind of busy time is it?', '<select class="gs-sel" id="ed-cat" data-ed="cat">' + Object.keys(E.CAT).filter((k) => k !== 'class').map((k) => '<option value="' + k + '"' + (ev.cat === k ? ' selected' : '') + '>' + E.CAT[k].icon + ' ' + esc(E.CAT[k].label) + '</option>').join('') + '</select>');
    const repeat = isClass || mode === 'template' ? '' : field('repeat', 'How often?', '<select class="gs-sel" id="ed-repeat" data-ed="repeat"><option value="once"' + (ev.repeat === 'once' ? ' selected' : '') + '>Just once</option><option value="weekly"' + (ev.repeat === 'weekly' ? ' selected' : '') + '>Every week</option><option value="range"' + (ev.repeat === 'range' ? ' selected' : '') + '>Several days in a row</option></select>');
    const days = (isClass || ev.repeat === 'weekly') ? '<div style="grid-column:1/-1"><label class="gs-f">Days</label><div class="gs-picks">' + D.DAYS.map((x) => '<button type="button" class="gs-pick' + ((ev.days || []).indexOf(x[0]) >= 0 ? ' on' : '') + '" aria-pressed="' + ((ev.days || []).indexOf(x[0]) >= 0) + '" data-act="eddays" data-d="' + x[0] + '"><i>' + ((ev.days || []).indexOf(x[0]) >= 0 ? '✓' : '+') + '</i>' + x[1].slice(0, 3) + '</button>').join('') + '</div></div>' : '';
    const dates = ev.repeat === 'once' && !isClass ? field('date', 'Date', '<input class="gs-in" type="date" id="ed-date" data-ed="date" value="' + esc(ev.date || '') + '">') : ev.repeat === 'range' && !isClass ? field('from', 'First day', '<input class="gs-in" type="date" id="ed-from" data-ed="from" value="' + esc(ev.from || '') + '">') + field('to', 'Last day', '<input class="gs-in" type="date" id="ed-to" data-ed="to" value="' + esc(ev.to || '') + '">') : '';
    const allday = isClass ? '' : '<label class="gs-opt" style="grid-column:1/-1"><input type="checkbox" data-ed="allDay"' + (ev.allDay ? ' checked' : '') + '> All day (nothing else can be planned)</label>';
    const times = ev.allDay ? '' : field('start', 'Starts', '<input class="gs-in" type="time" id="ed-start" data-ed="start" value="' + esc(ev.start || '') + '">') + field('end', 'Ends', '<input class="gs-in" type="time" id="ed-end" data-ed="end" value="' + esc(ev.end || '') + '">');
    const study = isClass ? field('study', 'Study hours a week for this class', '<input class="gs-in" type="number" min="0" id="ed-study" data-ed="study" value="' + esc(ev.study == null ? 2 : ev.study) + '">') : '';
    const note = d.err ? '<div class="gs-badbox" style="grid-column:1/-1">' + esc(d.err) + '</div>' : '';
    const overnight = !ev.allDay && ev.start && ev.end && E.toMin(ev.end) <= E.toMin(ev.start) ? '<p class="gs-note" style="grid-column:1/-1">This one runs past midnight and ends the next morning.</p>' : '';
    return '<div class="gs-card gs-glow gs-editor" id="editor"><div class="gs-spread"><h3 style="margin:0">' + (d.idx >= 0 ? 'Edit' : 'New') + ' ' + (isClass ? 'class' : 'event') + '</h3><button class="gs-btn3 gs-sm" data-act="edcancel">Close</button></div><div class="gs-two" style="margin-top:6px">' + field('title', isClass ? 'Course' : 'Title', '<input class="gs-in" id="ed-title" data-ed="title" ' + (isClass ? 'list="courselist" ' : '') + 'value="' + esc(ev.title || '') + '" placeholder="' + (isClass ? 'For example: CHEM 102' : 'For example: Sunday service') + '">') + catSel + repeat + days + dates + allday + times + study + overnight + note + '</div><div class="gs-row" style="margin-top:10px"><button class="gs-btn" data-act="edsave">Save</button>' + (d.idx >= 0 ? '<button class="gs-btn3 gs-danger" data-act="eddel">Delete</button>' : '') + '<button class="gs-btn3" data-act="edcancel">Cancel</button></div></div>';
  }
  function newDraft(cat, over) {
    const pr = E.PRESETS[cat] || {}; const mode = (over && over.mode) || 'template'; const isClass = cat === 'class';
    const ev = isClass ? { title: '', days: ['mon', 'wed', 'fri'], start: '10:00', end: '10:50', study: 2, repeat: 'weekly', cat: 'class' } : { title: pr.title || '', cat: cat || 'other', repeat: mode === 'template' ? 'weekly' : 'once', days: (pr.days || []).slice(), date: (over && over.iso) || anchor(), from: (over && over.iso) || anchor(), to: (over && over.iso) || anchor(), allDay: cat === 'travel' && mode === 'dated', start: pr.start || '09:00', end: pr.end || '10:00', note: '' };
    if (!isClass && mode === 'template' && !(ev.days || []).length) ev.days = over && over.day ? [over.day] : ['mon'];
    if (!isClass && mode === 'dated' && (pr.days || []).length && cat !== 'appt' && cat !== 'travel' && cat !== 'other') ev.repeat = 'weekly';
    Object.assign(ev, over && over.ev);
    return { src: isClass ? 'class' : 'event', idx: -1, mode, ev, err: '' };
  }
  function openDraft(d) { ui.draft = d; X.render(); setTimeout(() => { const el = document.getElementById('editor'); if (el) { el.scrollIntoView({ behavior: 'smooth', block: 'center' }); const t = document.getElementById('ed-title'); if (t) t.focus({ preventScroll: true }); } }, 30); }
  function commit() {
    const d = ui.draft; const p = P(); const ev = d.ev; d.err = '';
    const s = E.toMin(ev.start), t = E.toMin(ev.end);
    if (d.src === 'class') {
      if (!String(ev.title || '').trim()) d.err = 'Type the course (for example CHEM 102).'; else if (!(ev.days || []).length) d.err = 'Choose at least one day.'; else if (isNaN(s) || isNaN(t) || t <= s) d.err = 'A class needs a start time and a later end time.';
      if (d.err) return false;
      const c = { course: String(ev.title).trim().toUpperCase(), days: ev.days.slice(), start: ev.start, end: ev.end, study: Math.max(0, Number(ev.study) || 0) };
      p.classes = p.classes || []; if (d.idx >= 0) Object.assign(p.classes[d.idx], c); else { const used = p.classes.map((x) => x.color); p.classes.push(Object.assign({ id: 'k' + Date.now(), color: E.CLASS_COLORS.find((x) => used.indexOf(x) < 0) || E.CLASS_COLORS[p.classes.length % 8] }, c)); }
    } else {
      if (ev.repeat === 'weekly' && !(ev.days || []).length) d.err = 'Choose at least one day.';
      else if (ev.repeat === 'once' && isNaN(E.parse(ev.date))) d.err = 'Choose the date.';
      else if (ev.repeat === 'range' && (isNaN(E.parse(ev.from)) || isNaN(E.parse(ev.to)) || ev.to < ev.from)) d.err = 'Choose the first and last day (the last day cannot be before the first).';
      else if (!ev.allDay && (isNaN(s) || isNaN(t) || s === t)) d.err = 'Enter a start time and a different end time.';
      if (d.err) return false;
      const out = { id: ev.id || 'ev' + Date.now(), title: String(ev.title || '').trim() || E.CAT[ev.cat].label, cat: ev.cat, repeat: ev.repeat, allDay: !!ev.allDay, note: ev.note || '' };
      if (!out.allDay) { out.start = ev.start; out.end = ev.end; }
      if (ev.repeat === 'weekly') out.days = ev.days.slice(); else if (ev.repeat === 'once') out.date = ev.date; else { out.from = ev.from; out.to = ev.to; }
      p.events = p.events || []; if (d.idx >= 0) p.events[d.idx] = out; else p.events.push(out);
    }
    ui.draft = null; X.save(); return true;
  }

  // ---------- pages ----------
  function templatePage() {
    const p = P(); const pat = E.pattern(p); const cols = weekCols('template', '', 7, pat); const sg = E.suggestTimes(p, pat);
    return '<div class="gs-card" data-page="template" data-status="' + ((p.events || []).length || (p.classes || []).length ? 'done' : 'todo') + '"><p style="margin-top:0">This is the week you live, <b>every week</b>. Add each thing that takes your time. <b>Drag on a day to add one</b>, or use the buttons. Click anything to change it. Busy time is greyed out; classes are coloured; free time stays clear. <span class="gs-count">' + (sg.capacity).toFixed(1).replace('.0', '') + ' free hours a week after everything</span></p>' + emptyHint(pat) + quickAdd('template') + editor() + legend() + grid(cols, pat) + eventList('template') + (sg.hasLife && sg.picks.length ? '<p class="gs-note">Suggested research times, drawn in blue: ' + sg.picks.map((x) => esc(x.label)).join('; ') + '.</p>' : '') + '</div>';
  }
  function title(v, a) { return v === 'day' ? fmtDate(a, { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' }) : v === 'week' ? fmtDate(MON(a), { month: 'short', day: 'numeric' }) + ' to ' + fmtDate(E.addDays(MON(a), 6), { month: 'short', day: 'numeric', year: 'numeric' }) : fmtDate(a, { month: 'long', year: 'numeric' }); }
  function shift(v, a, dir) { if (v === 'day') return E.addDays(a, dir); if (v === 'week') return E.addDays(a, 7 * dir); const d = new Date(E.parse(a)); return E.iso(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + dir, 1)); }
  function monthView(a, pat) {
    const p = P(); const d0 = new Date(E.parse(a)); const y = d0.getUTCFullYear(), mo = d0.getUTCMonth(); const first = Date.UTC(y, mo, 1), last = Date.UTC(y, mo + 1, 0); let t = first - E.dowOf(E.iso(first)) * E.DAYMS; const rows = [];
    const cal = C.calendar(p); const cap = {}; cal.allWeeks.forEach((w) => { cap[w.monday] = w; });
    while (t <= last) {
      let cells = ''; const wk = cap[t];
      for (let k = 0; k < 7; k++) {
        const dt = t + k * E.DAYMS; const iso = E.iso(dt); const inMonth = new Date(dt).getUTCMonth() === mo; if (!inMonth) { cells += '<td></td>'; continue; }
        const info = E.dayItems(p, iso, pat); const tags = []; const evs = info.items.filter((i) => i.kind === 'class' || i.kind === 'event');
        evs.filter((i) => !i.tail).slice(0, 3).forEach((i) => tags.push(i.kind === 'class' ? '<i class="gs-mt cls" style="--c:' + esc(i.color) + '">' + esc(String(i.label).replace(/^[A-Z]+ /, '')) + '</i>' : '<i class="gs-mt ev">' + (E.CAT[i.cat] || E.CAT.other).icon + ' ' + esc(i.label) + '</i>'));
        const more = evs.filter((i) => !i.tail).length - 3; if (more > 0) tags.push('<i class="gs-mt more">+' + more + ' more</i>');
        const st = info.items.filter((i) => i.kind === 'study').length, rs = info.items.filter((i) => i.kind === 'research'); const rh = rs.reduce((x, i) => x + (i.to - i.from) / 60, 0);
        if (st) tags.push('<i class="gs-mt st">📖 ' + st + '</i>'); if (rs.length) tags.push('<i class="gs-mt rs">🔬 ' + (Math.round(rh * 10) / 10) + 'h</i>');
        cells += '<td><button type="button" class="gs-eday' + (info.allDay ? ' blk' : '') + (info.inPeriod ? ' win' : '') + (ui.sel === iso ? ' sel' : '') + (iso === todayIso() ? ' today' : '') + '" data-act="calsel" data-iso="' + iso + '" aria-pressed="' + (ui.sel === iso) + '"><span class="n">' + new Date(dt).getUTCDate() + '</span>' + tags.join('') + '</button></td>';
      }
      rows.push('<tr><th><span class="gs-wkbtn" title="Research hours that week">' + (wk ? (wk.capacity < 1 ? '0h' : wk.hours + 'h') : '–') + '</span></th>' + cells + '</tr>'); t += 7 * E.DAYMS;
    }
    return '<table class="gs-cal gs-ecal gs-bigcal"><tr><th>Research h</th>' + DN.map((d) => '<th>' + d.slice(0, 3) + '</th>').join('') + '</tr>' + rows.join('') + '</table>';
  }
  function dayPanel(pat) {
    const p = P(); if (!ui.sel) return '<div class="gs-card gs-daypanel"><p class="gs-note" style="margin:0">Click a day to see its whole plan.</p></div>';
    const info = E.dayItems(p, ui.sel, pat); const agenda = info.items.filter((i) => !i.allDay).map((k) => '<li class="' + k.kind + '" style="--c:' + esc(k.color || '#94a3b8') + '"><b>' + E.fmt(k.from) + ' to ' + E.fmt(k.to) + '</b> ' + (k.kind === 'class' ? 'Class: ' + esc(k.label) : k.kind === 'event' ? esc((E.CAT[k.cat] || E.CAT.other).icon + ' ' + k.label) + ' <span class="gs-note">(busy)</span>' : k.kind === 'study' ? '📖 ' + esc(k.label) : '🔬 Research time') + '</li>').join('');
    const ad = info.items.filter((i) => i.allDay).map((k) => '<li class="event" style="--c:' + esc(k.color || '#8b8fa3') + '"><b>All day</b> ' + esc((E.CAT[k.cat] || E.CAT.other).icon + ' ' + k.label) + '</li>').join('');
    return '<div class="gs-card gs-daypanel gs-glow"><h3 style="margin-top:0">' + esc(fmtDate(ui.sel, { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' })) + '</h3>' + (info.inPeriod ? '' : '<p class="gs-note">Outside your research periods: events still show, but no study or research is planned.</p>') + (ad || agenda ? '<ul class="gs-agenda">' + ad + agenda + '</ul>' : '<p class="gs-note">Nothing planned. A free day.</p>') + '<div class="gs-row" style="margin-top:8px"><button class="gs-btn2 gs-sm" data-act="calopen" data-iso="' + ui.sel + '">Open this day</button><button class="gs-btn3 gs-sm" data-act="calnewday" data-iso="' + ui.sel + '">+ Add an event this day</button><button class="gs-btn3 gs-sm" data-act="calblockday" data-iso="' + ui.sel + '">Block this whole day</button></div></div>';
  }
  function datedPage() {
    const p = P(); const pat = E.pattern(p); const a = anchor(); const v = ui.view;
    if (!periodsOk().length) return '<div class="gs-card" data-status="todo"><div class="gs-warnbox">Add the dates your research runs on the "When you can do research" screen, and your calendar will open at the right month.</div></div>';
    const bar = '<div class="gs-calbar"><button class="gs-btn3 gs-sm" data-act="calnav" data-d="-1" aria-label="Previous">◀</button><button class="gs-btn3 gs-sm" data-act="caltoday">Today</button><button class="gs-btn3 gs-sm" data-act="calnav" data-d="1" aria-label="Next">▶</button><b class="gs-caltitle">' + esc(title(v, a)) + '</b><span class="gs-seg" role="tablist">' + ['day', 'week', 'month'].map((x) => '<button type="button" role="tab" aria-selected="' + (v === x) + '" class="' + (v === x ? 'on' : '') + '" data-act="calview" data-v="' + x + '">' + x[0].toUpperCase() + x.slice(1) + '</button>').join('') + '</span><label class="gs-jump">Jump to <input type="date" class="gs-in" data-ed="jump" value="' + esc(a) + '"></label></div>';
    let body;
    if (v === 'month') body = monthView(a, pat) + dayPanel(pat);
    else { const cols = v === 'day' ? weekCols('dated', a, 1, pat) : weekCols('dated', MON(a), 7, pat); body = grid(cols, pat); }
    const wm = v === 'week' ? E.weekMinutes(p, E.parse(MON(a)), pat) / 60 : null;
    return '<div class="gs-card" data-page="dated" data-status="' + (((p.events || []).some((e) => e.repeat === 'once' || e.repeat === 'range')) ? 'done' : '') + '"><p style="margin-top:0">This is your real calendar, with your classes, your busy time and the study and research that fit around them. <b>Drag on a day to add something</b> (an exam, a trip, an appointment), or click any day or event. Page through the weeks to see the whole semester.</p>' + emptyHint(pat) + quickAdd('dated') + editor() + bar + legend() + (wm !== null ? '<p class="gs-note" style="margin:4px 0 8px">Free for research this week: <b>' + (Math.round(wm * 4) / 4) + ' hours</b>, after classes, study and busy time.</p>' : '') + body + eventList('dated') + '</div>';
  }

  // ---------- actions ----------
  const pageMode = (b) => { const w = b.closest && b.closest('[data-page]'); return w ? w.dataset.page : 'template'; };
  function onClick(b) {
    const a = b.dataset.act; const p = P();
    switch (a) {
      case 'calnew': openDraft(newDraft(b.dataset.cat, { mode: pageMode(b) })); return true;
      case 'calnewday': openDraft(newDraft('other', { mode: 'dated', iso: b.dataset.iso, ev: { title: '' } })); return true;
      case 'calblockday': { p.events = p.events || []; p.events.push({ id: 'ev' + Date.now(), title: 'Day off', cat: 'travel', repeat: 'once', date: b.dataset.iso, allDay: true }); X.save(); X.render(); return true; }
      case 'evedit': { const src = b.dataset.src, idx = Number(b.dataset.idx); const mode = pageMode(b);
        if (src === 'class') { const c = p.classes[idx]; openDraft({ src: 'class', idx, mode, ev: { title: c.course, days: (c.days || []).slice(), start: c.start, end: c.end, study: c.study, repeat: 'weekly', cat: 'class' }, err: '' }); } else { const e = JSON.parse(JSON.stringify(p.events[idx])); e.repeat = e.repeat || 'weekly'; e.days = e.days || []; openDraft({ src: 'event', idx, mode, ev: Object.assign({ date: anchor(), from: anchor(), to: anchor(), start: '09:00', end: '10:00' }, e), err: '' }); } return true; }
      case 'eddays': { const ev = ui.draft.ev; ev.days = ev.days || []; const i = ev.days.indexOf(b.dataset.d); if (i >= 0) ev.days.splice(i, 1); else ev.days.push(b.dataset.d); X.render(); return true; }
      case 'edsave': if (commit()) X.render(); else X.render(); return true;
      case 'eddel': { const d = ui.draft; if (d.src === 'class') p.classes.splice(d.idx, 1); else p.events.splice(d.idx, 1); ui.draft = null; X.save(); X.render(); return true; }
      case 'edcancel': ui.draft = null; X.render(); return true;
      case 'calnav': ui.anchor = shift(ui.view, anchor(), Number(b.dataset.d)); X.render(); return true;
      case 'caltoday': ui.anchor = todayIso(); X.render(); return true;
      case 'calview': ui.view = b.dataset.v; X.render(); return true;
      case 'calsel': ui.sel = b.dataset.iso; X.render(); return true;
      case 'calopen': ui.anchor = b.dataset.iso; ui.view = 'day'; X.render(); return true;
      default: return false;
    }
  }
  function onInput(t) {
    const k = t.dataset.ed; if (k === 'jump') { if (!isNaN(E.parse(t.value))) { ui.anchor = t.value; X.render(); } return true; }
    if (!ui.draft) return true; const ev = ui.draft.ev; let v = t.type === 'checkbox' ? t.checked : t.value; if (k === 'study') v = Number(v);
    ev[k] = v; if (k === 'repeat' || k === 'allDay') X.render(); return true;
  }

  // ---------- drag to create ----------
  let drag = null;
  const minuteAt = (body, y) => { const r = body.getBoundingClientRect(); return Math.max(T0, Math.min(T1, T0 + Math.round(((y - r.top) / HPX * 60) / 15) * 15)); };
  function onDown(e) {
    const body = e.target.closest && e.target.closest('.gs-wbody'); if (!body || e.target.closest('.gs-ev') || e.target.closest('.gs-ad')) return; if (e.pointerType === 'mouse' && e.button !== 0) return;
    const m = minuteAt(body, e.clientY); drag = { body, m0: m, m1: m + 60, moved: false, touch: e.pointerType === 'touch' }; if (!drag.touch) e.preventDefault();
    const g = document.createElement('div'); g.className = 'gs-ghost'; g.style.top = top(m) + 'px'; g.style.height = HPX + 'px'; body.appendChild(g); drag.ghost = g;
  }
  function onMove(e) {
    if (!drag || drag.touch) return; const m = minuteAt(drag.body, e.clientY); drag.cur = m; if (Math.abs(m - drag.m0) >= 15) drag.moved = true;
    const a = Math.min(m, drag.m0), b = Math.max(m, drag.m0 + (drag.moved ? 0 : 60)); drag.ghost.style.top = top(a) + 'px'; drag.ghost.style.height = Math.max(HPX / 4, (b - a) / 60 * HPX) + 'px';
  }
  function onUp(e) {
    if (!drag) return; const d = drag; drag = null; if (d.ghost) d.ghost.remove();
    let a = d.m0, b = d.m0 + 60; if (d.moved && d.cur !== undefined) { a = Math.min(d.m0, d.cur); b = Math.max(d.m0, d.cur); if (b - a < 15) b = a + 60; } if (b > T1) { a = T1 - 60; b = T1; }
    const mode = d.body.dataset.mode; const over = { mode, ev: { start: E.hhmm(a), end: b >= 1440 ? '23:59' : E.hhmm(b) } };
    if (mode === 'template') over.day = E.DAYK[Number(d.body.dataset.di)]; else over.iso = d.body.dataset.iso;
    openDraft(newDraft('other', over));
  }
  function afterRender() { const sc = document.getElementById('wscroll'); if (sc) sc.scrollTop = ui.st != null ? ui.st : Math.max(0, (420 - T0) / 60 * HPX - 6); }
  function init(ctx) { X = ctx; document.addEventListener('pointerdown', onDown); document.addEventListener('pointermove', onMove); document.addEventListener('pointerup', onUp); document.addEventListener('scroll', (e) => { if (e.target && e.target.id === 'wscroll') ui.st = e.target.scrollTop; }, true); }
  root.StudioCalUI = { init, templatePage, datedPage, onClick, onInput, afterRender, ui, HPX, T0, T1 };
})(typeof window !== 'undefined' ? window : globalThis);
