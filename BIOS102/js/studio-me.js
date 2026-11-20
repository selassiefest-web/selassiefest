// BIOS102 Research-to-Grant Studio: step 1, "About you". Eight short screens, one job each:
// about you > courses you have taken (only your year's, click to mark) > skills > when you can do research >
// your classes (times fill in your busy blocks, study time is reserved for them) > your usual week (a week-at-a-glance
// timeline plus a busy grid) > days off (an epic month calendar with a plan for every day) > your hours and the
// research times that are left over.
(function (root) {
  'use strict';
  const C = root.StudioCore, D = root.STUDIO_DATA, W = root.StudioWidgets;
  let X = null;
  const ui = { showAll: false, showGened: false, sel: '' };
  const esc = (s) => C.esc(s);
  const S = () => X.S();
  const P = () => S().profile;
  const MAJORS = ['Biological Sciences', 'Molecular Biology and Bioinformatics', 'Other'];
  const DAY = 86400000;

  // What the rest of the studio reads (strings) is derived from what the student clicked.
  function derive() {
    const p = P(); p.coursesDone = p.coursesDone || []; p.coursesOther = p.coursesOther || []; p.skillsDone = p.skillsDone || [];
    const name = p.majorName === 'Other' ? (p.majorOther || '').trim() : (p.majorName || '');
    p.major = name ? name + (p.declared ? ' (declared)' : ' (not yet declared)') : '';
    p.courses = p.coursesDone.concat(p.coursesOther).join(', ');
    p.skills = p.skillsDone.concat((p.skillsOther || '').trim() ? [p.skillsOther.trim()] : []).join('; ') + (p.skillsNone ? (p.skillsDone.length || (p.skillsOther || '').trim() ? '' : 'None of these yet') : '');
  }

  const status = (st) => ' data-status="' + st + '"';
  const chip = (act, attrs, on, label) => '<button type="button" class="gs-pick' + (on ? ' on' : '') + '" aria-pressed="' + on + '" data-act="' + act + '" ' + attrs + '><i>' + (on ? '✓' : '+') + '</i>' + esc(label) + '</button>';

  // ----- pages -----
  function pAbout() {
    const p = P();
    const st = p.name && p.majorName && p.year ? 'done' : (p.name || p.majorName || p.year) ? 'part' : 'todo';
    return '<div class="gs-card"' + status(st) + '><div class="gs-two">' + X.inp('profile.name', 'Your name') + X.sel('profile.majorName', 'Your major', MAJORS, { rerender: 1 }) + X.sel('profile.year', 'Your year', D.YEARS) + '</div>' + (p.majorName === 'Other' ? X.inp('profile.majorOther', 'Type your major') : '') + X.chk('profile.declared', 'I have declared this major') + '<p class="gs-note">Some funders only accept students who have declared. That is why we ask.</p></div>';
  }
  function courseGroup(list, groups, title, done, y) {
    const vis = C.visibleCourses(list, y, ui.showAll, done);
    const body = groups.map((g) => { const re = new RegExp('^(' + g[0] + ')'); const cs = vis.filter((c) => re.test(c)); if (!cs.length) return ''; const n = cs.filter((c) => done.indexOf(c) >= 0).length; return '<div class="gs-cgroup"><h4>' + esc(g[1]) + ' <span class="gs-count">' + n + ' of ' + cs.length + ' marked</span></h4><div class="gs-picks">' + cs.map((c) => chip('course', 'data-c="' + esc(c) + '"', done.indexOf(c) >= 0, c)).join('') + '</div></div>'; }).join('');
    return body ? '<h3 style="margin:14px 0 6px">' + esc(title) + '</h3>' + body : '';
  }
  function pCourses() {
    const p = P(); const done = p.coursesDone; const y = p.year;
    if (!y) return '<div class="gs-card"' + status('todo') + '><div class="gs-warnbox">Choose your year on the previous screen first. Then you will only see the courses for your year.</div><button class="gs-btn2" data-act="mecourseshowall">Show all courses anyway</button></div>';
    const hidden = D.COURSES.science.filter((c) => !C.visibleCourses(D.COURSES.science, y, ui.showAll, done).includes(c)).length;
    const other = (p.coursesOther || []).map((c, i) => '<button type="button" class="gs-pick on" data-act="courseother-del" data-i="' + i + '" title="Remove"><i>✓</i>' + esc(c) + ' ✕</button>').join('');
    return '<div class="gs-card"' + status(done.length || (p.coursesOther || []).length ? 'done' : 'todo') + '><p style="margin-top:0">Showing science courses for a <b>' + esc(y) + '</b>. Click every one you have <b>finished</b>. <span class="gs-count">' + done.length + ' marked</span></p>' + courseGroup(D.COURSES.science, D.COURSE_GROUPS, 'Science, math and related courses', done, y) +
      '<div class="gs-row" style="margin-top:12px">' + (hidden ? '<button class="gs-btn3 gs-sm" data-act="mecourseshowall">' + (ui.showAll ? 'Show only my year’s courses' : 'Show ' + hidden + ' other courses (higher or lower levels)') + '</button>' : (ui.showAll ? '<button class="gs-btn3 gs-sm" data-act="mecourseshowall">Show only my year’s courses</button>' : '')) + '<button class="gs-btn3 gs-sm" data-act="megened">' + (ui.showGened ? 'Hide general education courses' : 'My general education courses') + '</button></div>' +
      (ui.showGened ? courseGroup(D.COURSES.gened, D.GENED_GROUPS, 'General education courses', done, y) : '') +
      '<h3 style="margin:14px 0 6px">A course that is not listed</h3><div class="gs-row"><input class="gs-in" id="cother" style="max-width:260px" placeholder="For example: BIOS 215"><button class="gs-btn2 gs-sm" data-act="courseother">Add it</button></div><div class="gs-picks" style="margin-top:8px">' + other + '</div></div>';
  }
  function pSkills() {
    const p = P(); const done = p.skillsDone;
    return '<div class="gs-card"' + status(((done.length || p.skillsNone || (p.skillsOther || '').trim()) && p.mode) ? 'done' : (done.length || p.mode) ? 'part' : 'todo') + '><h3 style="margin-top:0">Skills you already have</h3><div class="gs-picks">' + D.SKILLS.map((s) => chip('skill', 'data-k="' + esc(s) + '"', done.indexOf(s) >= 0, s)).join('') + chip('skillnone', '', !!p.skillsNone, 'None of these yet') + '</div>' + X.inp('profile.skillsOther', 'Anything else you can do (optional)') +
      '<h3 style="margin:16px 0 6px">What kind of research could you really do?</h3><div class="gs-row">' + [['field', 'Field research (outdoors)'], ['bench', 'Bench research (in a lab)'], ['data', 'Computer or existing-data research']].map((m) => '<label class="gs-opt"><input type="radio" name="mode" data-bind="profile.mode" value="' + m[0] + '"' + (p.mode === m[0] ? ' checked' : '') + '> ' + m[1] + '</label>').join('') + '</div><p class="gs-note">Existing-data research is a real option: it needs a computer, not a lab or a field site.</p>' + X.inp('profile.modeNote', 'Anything that limits you, like no car or no lab access (optional)') + '</div>';
  }
  function pWhen() {
    const p = P(); const ok = p.periods.some((x) => x.start && x.end);
    const periods = p.periods.map((x, i) => '<div class="gs-two" style="align-items:end;border-top:1px solid var(--line);padding-top:6px">' + X.inp('profile.periods.' + i + '.label', 'Name (for example Spring 2027)') + X.inp('profile.periods.' + i + '.start', 'First Monday', { type: 'date' }) + X.inp('profile.periods.' + i + '.end', 'Last day', { type: 'date' }) + '<div><button class="gs-btn3 gs-sm gs-danger" data-act="delRow" data-p="profile.periods" data-i="' + i + '">Remove</button></div></div>').join('');
    return '<div class="gs-card"' + status(ok && Number(p.weeklyHours) > 0 ? 'done' : ok || Number(p.weeklyHours) ? 'part' : 'todo') + '><div class="gs-two">' + X.inp('profile.weeklyHours', 'Hours a week you want to give to research', { num: 1, min: 1 }) + '</div><h3 style="margin:14px 0 4px">When does your research run?</h3><p class="gs-note">Add each semester or summer you would work. Some funders need two semesters, or a summer plus one semester.</p>' + periods + '<button class="gs-btn3 gs-sm" data-act="addPeriod" style="margin-top:8px">+ Add another period</button></div>';
  }
  // ----- classes -----
  const DAYK = D.DAYS.map((d) => d[0]);
  function pClasses() {
    const p = P(); p.classes = p.classes || [];
    const cards = p.classes.map((c, i) => '<div class="gs-cand" style="border-left:6px solid ' + esc(c.color || C.CLASS_COLORS[i % 8]) + '"><div class="gs-spread"><b>Class ' + (i + 1) + '</b><button class="gs-btn3 gs-sm gs-danger" data-act="clsdel" data-i="' + i + '">Remove</button></div>' +
      '<div class="gs-two"><div><label class="gs-f" for="kc-' + i + '">Course</label><input class="gs-in" id="kc-' + i + '" list="courselist" data-bind="profile.classes.' + i + '.course" value="' + esc(c.course || '') + '" placeholder="For example: CHEM 102"></div>' + X.inp('profile.classes.' + i + '.start', 'Starts', { type: 'time' }) + X.inp('profile.classes.' + i + '.end', 'Ends', { type: 'time' }) + X.inp('profile.classes.' + i + '.study', 'Study hours a week for it', { num: 1 }) + '</div>' +
      '<label class="gs-f">Days it meets</label><div class="gs-picks">' + D.DAYS.map((d) => chip('clsday', 'data-i="' + i + '" data-d="' + d[0] + '"', (c.days || []).indexOf(d[0]) >= 0, d[1].slice(0, 3))).join('') + '</div></div>').join('');
    const total = p.classes.reduce((a, c) => a + (Number(c.study) || 0), 0);
    return '<div class="gs-card"' + status(p.classes.length ? 'done' : '') + '><datalist id="courselist">' + D.COURSES.science.concat(D.COURSES.gened).map((c) => '<option value="' + esc(c) + '"></option>').join('') + '</datalist><p style="margin-top:0">Add each class you are taking during your research. Their times fill in your busy blocks by themselves, and the studio keeps study time for them so research does not eat it. No classes? Skip this screen.</p>' + (cards || '<p class="gs-note">No classes added yet.</p>') + '<div class="gs-row"><button class="gs-btn2" data-act="clsadd">+ Add a class</button><span class="gs-count">Study time reserved: ' + total + ' h a week</span></div></div>';
  }
  // ----- the usual week: a timeline plus the busy grid -----
  const HPX = 26, T0 = 480, T1 = 1320;
  function glance(pat) {
    const p = P(); const top = (m) => Math.max(0, (m - T0) / 60 * HPX), h = (a, b) => (Math.min(b, T1) - Math.max(a, T0)) / 60 * HPX;
    const lines = []; for (let m = T0; m <= T1; m += 120) lines.push('<i class="gs-gline" style="top:' + top(m) + 'px"><b>' + C.fmtMin(m).replace(':00', '') + '</b></i>');
    const cols = D.DAYS.map((d, di) => {
      const blocks = [];
      (p.weekBlack[d[0]] || []).forEach((i) => { const [a, b] = C.slotMin(i); blocks.push('<div class="gs-gb busy" style="top:' + top(a) + 'px;height:' + h(a, b) + 'px" title="Busy"></div>'); });
      pat[di].classes.forEach((k) => blocks.push('<div class="gs-gb cls" style="top:' + top(k.from) + 'px;height:' + Math.max(14, h(k.from, k.to)) + 'px;--c:' + esc(k.color) + '" title="' + esc(k.label + ' ' + k.time) + '"><span>' + esc(k.label) + '</span></div>'));
      pat[di].study.forEach((k) => blocks.push('<div class="gs-gb study" style="top:' + top(k.from) + 'px;height:' + h(k.from, k.to) + 'px;--c:' + esc(k.color) + '" title="' + esc(k.label) + '"><span>study</span></div>'));
      pat[di].research.forEach((k) => blocks.push('<div class="gs-gb research" style="top:' + top(k.from) + 'px;height:' + h(k.from, k.to) + 'px" title="Suggested research time"><span>research</span></div>'));
      return '<div class="gs-gcol"><div class="gs-gh">' + d[1].slice(0, 3) + '</div><div class="gs-gbody" style="height:' + ((T1 - T0) / 60 * HPX) + 'px">' + (di === 0 ? lines.join('') : lines.map((l) => l.replace(/<b>.*?<\/b>/, '')).join('')) + blocks.join('') + '</div></div>';
    }).join('');
    return '<div class="gs-glance" role="img" aria-label="Your usual week at a glance">' + cols + '</div><div class="gs-keyrow"><span class="gs-kchip" style="--c:#4ade80">A class</span><span class="gs-kchip study" style="--c:#a78bfa">Study time kept for a class</span><span class="gs-kchip busy">Busy (you marked it)</span><span class="gs-kchip research">Suggested research</span></div>';
  }
  function pWeek() {
    const p = P(); p.weekBlack = p.weekBlack || {}; const pat = C.weekPattern(p); const cb = C.classBusy(p); const sp = C.studyPlan(p); const free = C.freeSlots(p); const hrs = free.reduce((a, f) => a + f.length * 2, 0);
    const manual = Object.keys(p.weekBlack).some((k) => (p.weekBlack[k] || []).length);
    const head = '<tr><th></th>' + D.DAYS.map((d) => '<th>' + d[1].slice(0, 3) + '</th>').join('') + '</tr>';
    const rows = D.SLOTS.map((s, i) => '<tr><th class="gs-slot">' + s[0] + ' to ' + s[1] + '</th>' + D.DAYS.map((d, di) => {
      if (cb[di].has(i)) { const k = pat[di].classes.find((x) => { const [a, b] = C.slotMin(i); return x.from < b && x.to > a; }); return '<td><button type="button" class="gs-blk cls" style="--c:' + esc((k || {}).color || '#4ade80') + '" disabled title="From your classes">' + esc((k || {}).label || 'class') + '</button></td>'; }
      const st = sp[di].find((x) => x.slot === i); if (st) return '<td><button type="button" class="gs-blk study" style="--c:' + esc(st.color) + '" disabled title="Study time kept for ' + esc(st.course) + '">study</button></td>';
      const busy = (p.weekBlack[d[0]] || []).indexOf(i) >= 0;
      return '<td><button type="button" class="gs-blk' + (busy ? ' busy' : ' free') + '" aria-pressed="' + busy + '" aria-label="' + d[1] + ' ' + s[0] + ': ' + (busy ? 'busy' : 'free') + '" data-act="blk" data-d="' + d[0] + '" data-s="' + i + '">' + (busy ? 'busy' : 'free') + '</button></td>';
    }).join('') + '</tr>').join('');
    return '<div class="gs-card"' + status(manual || (p.classes || []).length ? 'done' : 'todo') + '><h3 style="margin-top:0">Your week at a glance</h3>' + glance(pat) + '<h3 style="margin:18px 0 4px">Mark the rest of your busy time</h3><p style="margin-top:0">Class times are already filled in. <b>Click a block when you are busy with something else</b> (work, family, travel, sleep). Whatever stays green is free. <span class="gs-count">' + hrs + ' free hours a week after classes and study</span></p><div class="gs-scroll"><table class="gs-weekgrid" role="grid">' + head + rows + '</table></div><div class="gs-row" style="margin-top:8px"><button class="gs-btn3 gs-sm" data-act="blkall" data-v="busy">Mark everything else busy</button><button class="gs-btn3 gs-sm" data-act="blkall" data-v="free">Clear what I marked</button></div></div>';
  }
  // ----- the epic month calendar -----
  const dow = (t) => (new Date(t).getUTCDay() + 6) % 7;
  function dayPanel(pat) {
    const p = P(); if (!ui.sel) return '<div class="gs-card gs-daypanel"><p class="gs-note" style="margin:0">Click any day to see its plan: classes, study time, and research time.</p></div>';
    const plan = C.dayPlan(p, ui.sel, pat); const t = C.parse(ui.sel); const title = new Date(t).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
    const mondayIso = C.iso(t - dow(t) * DAY);
    let body;
    if (!plan.inPeriod) body = '<p class="gs-note">This day is outside your research periods.</p>';
    else if (plan.blocked) body = '<div class="gs-warnbox">You blocked this day. Nothing is planned.</div>';
    else body = plan.items.length ? '<ul class="gs-agenda">' + plan.items.map((k) => '<li class="' + k.kind + '" style="--c:' + esc(k.color) + '"><b>' + C.fmtMin(k.from) + ' to ' + C.fmtMin(k.to) + '</b> ' + (k.kind === 'class' ? 'Class: ' + esc(k.label) : k.kind === 'study' ? esc(k.label) : 'Research time') + '</li>').join('') + '</ul>' : '<p class="gs-note">Nothing planned. This is a free day.</p>';
    return '<div class="gs-card gs-daypanel gs-glow"><h3 style="margin-top:0">' + esc(title) + '</h3>' + body + (plan.inPeriod ? '<div class="gs-row" style="margin-top:8px"><button class="gs-btn2 gs-sm" data-act="day" data-iso="' + ui.sel + '">' + (plan.blocked ? 'Unblock this day' : 'Block this day (I cannot work)') + '</button><button class="gs-btn3 gs-sm" data-act="blkweek" data-iso="' + mondayIso + '">Block or clear this whole week</button></div>' : '') + '</div>';
  }
  function pDays() {
    const p = P(); p.blackDates = p.blackDates || []; const black = new Set(p.blackDates); const cal = C.calendar(p); const pat = C.weekPattern(p);
    const periods = p.periods.filter((x) => !isNaN(C.parse(x.start)) && !isNaN(C.parse(x.end)));
    if (!periods.length) return '<div class="gs-card"' + status('todo') + '><div class="gs-warnbox">Enter when your research runs on the "When you can do research" screen and the calendar will appear here.</div></div>';
    const first = Math.min.apply(null, periods.map((x) => C.parse(x.start))), last = Math.max.apply(null, periods.map((x) => C.parse(x.end)));
    const inWin = (t) => periods.some((x) => t >= C.parse(x.start) && t <= C.parse(x.end));
    const capByMonday = {}; cal.allWeeks.forEach((w) => { capByMonday[w.monday] = w; });
    const months = []; let c = new Date(first); c = Date.UTC(c.getUTCFullYear(), c.getUTCMonth(), 1); while (c <= last) { months.push(c); const d = new Date(c); c = Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 1); }
    const html = months.map((m) => {
      const d0 = new Date(m); const y = d0.getUTCFullYear(), mo = d0.getUTCMonth(); const lastDay = Date.UTC(y, mo + 1, 0); let t = m - dow(m) * DAY; const rows = [];
      while (t <= lastDay) {
        let cells = ''; const wk = capByMonday[t];
        for (let k = 0; k < 7; k++) {
          const dt = t + k * DAY; const iso2 = C.iso(dt); const inMonth = new Date(dt).getUTCMonth() === mo; if (!inMonth) { cells += '<td></td>'; continue; }
          const b = black.has(iso2); const win = inWin(dt); const plan = win && !b ? pat[dow(dt)] : null;
          const cls = plan ? plan.classes.slice(0, 3).map((q) => '<i class="gs-cb" style="--c:' + esc(q.color) + '">' + esc(String(q.label).replace(/^[A-Z]+ /, '')) + '</i>').join('') : '';
          const study = plan && plan.study.length ? '<i class="gs-cs">study ' + plan.study.length * 2 + 'h</i>' : '';
          const rs = plan && plan.research.length ? '<i class="gs-cr">research ' + plan.research.reduce((a, q) => a + (q.to - q.from) / 60, 0) + 'h</i>' : '';
          cells += '<td><button type="button" class="gs-eday' + (b ? ' blk' : '') + (win ? ' win' : '') + (ui.sel === iso2 ? ' sel' : '') + '" aria-pressed="' + (ui.sel === iso2) + '" data-act="daysel" data-iso="' + iso2 + '" title="' + (b ? 'Blocked' : 'Click to see the day') + '"><span class="n">' + new Date(dt).getUTCDate() + '</span>' + cls + study + rs + '</button></td>';
        }
        rows.push('<tr><th><button type="button" class="gs-wkbtn" data-act="blkweek" data-iso="' + C.iso(t) + '" title="Block or clear the whole week">' + (wk ? (wk.capacity === 0 ? '0h' : wk.hours + 'h') : '–') + '</button></th>' + cells + '</tr>'); t += 7 * DAY;
      }
      return '<div class="gs-month"><h4>' + d0.toLocaleDateString('en-US', { month: 'long', year: 'numeric', timeZone: 'UTC' }) + '</h4><table class="gs-cal gs-ecal"><tr><th>Hours</th>' + D.DAYS.map((d) => '<th>' + d[1].slice(0, 3) + '</th>').join('') + '</tr>' + rows.join('') + '</table></div>';
    }).join('');
    const key = '<div class="gs-keyrow"><span class="gs-kchip" style="--c:#4ade80">Class (one colour per course)</span><span class="gs-kchip study" style="--c:#a78bfa">Study</span><span class="gs-kchip research">Research</span><span class="gs-kchip blk">Day you blocked</span></div>';
    return '<div class="gs-card"' + status(p.blackDates.length || ui.sel ? 'done' : '') + '><p style="margin-top:0">Every day shows its classes, study time and suggested research time. <b>Click a day</b> to see the whole plan. Block a day you cannot work, or the number at the start of a row to block a whole week. <span class="gs-count">' + p.blackDates.length + ' days blocked</span></p>' + key + dayPanel(pat) + '<div class="gs-months">' + html + '</div><p class="gs-note">The number at the start of each row is the research hours you have that week. 0h means that week is out.</p></div>';
  }
  function live() {
    const p = P(); const cal = C.calendar(p); const sg = C.suggestTimes(p); const res = C.reserve(cal.total, p.reserve); const study = (p.classes || []).reduce((a, c) => a + (Number(c.study) || 0), 0);
    return '<div class="gs-card gs-glow"><div class="gs-grid3"><div class="gs-tile"><small>Total research hours</small><b>' + cal.total + ' h</b><span>' + cal.totalWeeks + ' working weeks</span></div><div class="gs-tile"><small>Hours a week</small><b>' + cal.weeklyHours + ' h wanted</b><span>' + sg.capacity + ' h free after classes' + (study ? ' and study' : '') + '</span></div><div class="gs-tile"><small>Weeks you are out</small><b>' + cal.allWeeks.filter((w) => w.broke).length + '</b><span>blacked out completely</span></div></div>' +
      (sg.enough ? '' : '<div class="gs-warnbox" style="margin-top:12px">You want ' + sg.want + ' hours a week but only ' + sg.capacity + ' are free in a usual week. Free up time on "Your usual week", or lower the hours you want. <button class="gs-inline" data-act="wz" data-w="me" data-v="3">Change the hours I want</button></div>') +
      '<h3 style="margin:14px 0 6px">Suggested research times</h3>' + (sg.picks.length ? '<div class="gs-picks">' + sg.picks.map((x) => '<span class="gs-pick on"><i>✓</i>' + esc(x.label) + ' (' + x.hours + ' h)</span>').join('') + '</div><p class="gs-note">The longest free stretches first. Long stretches work best for research.</p>' : '<p class="gs-note">No free time is left. Clear some blocks on "Your usual week".</p>') +
      (cal.totalWeeks ? '<h3 style="margin:14px 0 6px">Your research weeks</h3>' + W.weekStrip(S(), cal) : '') + '<h3 style="margin:14px 0 6px">Where the hours go</h3>' + W.hoursDonut(res, cal.total) + '</div>';
  }
  function pHours() {
    const p = P(); const cal = C.calendar(p);
    return '<div class="gs-card"' + status(cal.total > 0 ? 'done' : 'todo') + '><div id="live"></div></div><details class="gs-ex"><summary>Change how your hours are split (optional)</summary><div class="gs-grid3">' + Object.keys(W.CAT).map((k) => X.inp('profile.reserve.' + k, W.CAT[k][0] + ' (%)', { num: 1 })).join('') + '</div><p class="gs-note">Percentages are normalized, so they need not add to exactly 100.</p></details>';
  }

  function view() {
    const p = P(); p.coursesDone = p.coursesDone || []; p.skillsDone = p.skillsDone || []; p.weekBlack = p.weekBlack || {}; p.blackDates = p.blackDates || []; p.classes = p.classes || []; derive();
    const head = '<p class="gs-kick">Step 1 of 8</p><h1 class="gs-h1">About you</h1><p class="gs-lede">Your year, courses, skills and free time decide which projects fit you and whether you qualify for funding.</p>' + X.banner();
    const pg = X.pg;
    return head + pg('About you', 'Type your name, choose your major and your year.') + pAbout() + pg('Courses you have taken', 'Click every course you have finished.') + pCourses() + pg('Skills and research type', 'Click the skills you already have, then choose the kind of research you could do.') + pSkills() +
      pg('When you can do research', 'Say how many hours a week you want to give, and add the dates when your research would run.') + pWhen() + pg('Your classes', 'Add each class you are taking: the course, the days, and the times. No classes? Press Next.') + pClasses() +
      pg('Your usual week', 'Look at your week, then click each block when you are busy with something other than class.') + pWeek() + pg('Days off', 'Click a day to see its plan. Block any day you cannot work.') + pDays() + pg('Your hours', 'Look at the suggested times and the total hours. Go back and change anything that is wrong.') + pHours();
  }

  function onClick(b) {
    const a = b.dataset.act; const p = P(); const set = (arr, v) => { const i = arr.indexOf(v); if (i >= 0) arr.splice(i, 1); else arr.push(v); };
    switch (a) {
      case 'course': set(p.coursesDone, b.dataset.c); derive(); X.save(); X.render(); return true;
      case 'courseother': { const el = document.getElementById('cother'); const v = el && el.value.trim().toUpperCase(); if (!v) return true; p.coursesOther = p.coursesOther || []; if (p.coursesOther.indexOf(v) < 0 && p.coursesDone.indexOf(v) < 0) p.coursesOther.push(v); derive(); X.save(); X.render(); return true; }
      case 'courseother-del': p.coursesOther.splice(Number(b.dataset.i), 1); derive(); X.save(); X.render(); return true;
      case 'mecourseshowall': ui.showAll = !ui.showAll; X.render(); return true;
      case 'megened': ui.showGened = !ui.showGened; X.render(); return true;
      case 'skill': set(p.skillsDone, b.dataset.k); if (p.skillsDone.length) p.skillsNone = false; derive(); X.save(); X.render(); return true;
      case 'skillnone': p.skillsNone = !p.skillsNone; if (p.skillsNone) p.skillsDone = []; derive(); X.save(); X.render(); return true;
      case 'clsadd': { const used = (p.classes || []).map((c) => c.color); const color = C.CLASS_COLORS.find((c) => used.indexOf(c) < 0) || C.CLASS_COLORS[p.classes.length % 8]; p.classes.push({ id: 'k' + Date.now(), course: '', days: ['mon', 'wed', 'fri'], start: '10:00', end: '10:50', study: 2, color }); X.save(); X.render(); return true; }
      case 'clsdel': p.classes.splice(Number(b.dataset.i), 1); X.save(); X.render(); return true;
      case 'clsday': { const c = p.classes[Number(b.dataset.i)]; c.days = c.days || []; set(c.days, b.dataset.d); X.save(); X.render(); return true; }
      case 'blk': { const arr = p.weekBlack[b.dataset.d] = p.weekBlack[b.dataset.d] || []; set(arr, Number(b.dataset.s)); X.save(); X.render(); return true; }
      case 'blkall': D.DAYS.forEach((d) => { p.weekBlack[d[0]] = b.dataset.v === 'busy' ? D.SLOTS.map((_, i) => i) : []; }); X.save(); X.render(); return true;
      case 'daysel': ui.sel = b.dataset.iso; X.render(); return true;
      case 'day': set(p.blackDates, b.dataset.iso); X.save(); X.render(); return true;
      case 'blkweek': { const m = C.parse(b.dataset.iso); const days = []; for (let k = 0; k < 7; k++) days.push(C.iso(m + k * DAY)); const allBlack = days.every((d) => p.blackDates.indexOf(d) >= 0); p.blackDates = p.blackDates.filter((d) => days.indexOf(d) < 0); if (!allBlack) p.blackDates = p.blackDates.concat(days); X.save(); X.render(); return true; }
      default: return false;
    }
  }
  function init(ctx) { X = ctx; }
  root.StudioMe = { init, view, live, onClick, derive, ui };
})(typeof window !== 'undefined' ? window : globalThis);
