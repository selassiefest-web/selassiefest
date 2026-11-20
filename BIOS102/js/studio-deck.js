// BIOS102 Research-to-Grant Studio: the interactive defense deck. Built live from the student's own state:
// change a document and the deck changes. Keyboard: arrows / space move, Esc closes, T toggles the timer.
(function (root) {
  'use strict';
  const C = root.StudioCore, W = root.StudioWidgets, D = root.STUDIO_DATA, PIS = root.STUDIO_PIS;
  const esc = C.esc;
  let el = null, idx = 0, slides = [], S = null, H = null, timer = 0, t0 = 0, showTimer = false, keyFn = null, local = {};

  const clip = (s, n) => { s = String(s || ''); return s.length > n ? s.slice(0, n - 1) + '…' : s; };
  function build(st) {
    const f = C.piCard(st.pi), g = (st.gaps || []).find((x) => x.id === st.chosenGap) || {}; const fu = C.funder(st.funding && st.funding.primary);
    const cal = C.calendar(st.profile); const r = C.readiness(st); const bt = C.budgetTotals(st.budget); const pi = PIS[st.pi] || { works: [] };
    const recent = (st.papers || []).find((p) => p.role === 'recent') || {};
    const out = [];

    out.push({ id: 'hook', html: () => '<p class="gs-kick">Defense deck · ' + esc(st.profile.name || 'Student') + '</p><h2>I studied your work, compared three possible contributions, and wrote the full proposal and plan.</h2><p class="gs-big">For ' + esc(C.piName(st)) + '. Funding route: ' + esc(fu ? fu.name : 'to be chosen') + '. ' + (st.meta && st.meta.example ? '<em>(Worked example: illustrative student, real public data.)</em>' : '') + '</p><div class="gs-row" style="margin-top:18px"><span class="gs-chip ' + (r.ready ? 'ok' : 'warn') + '">' + (r.ready ? 'All gates clear' : r.blocks.length + ' blocked · ' + r.warns.length + ' open') + '</span><span class="gs-chip cy">' + cal.total + ' hours · ' + cal.totalWeeks + ' weeks</span><span class="gs-chip cy">' + C.money(bt.total) + '</span></div>' });

    out.push({ id: 'lab', html: () => {
      const ys = pi.works.map((w) => w.y); const lo = Math.min.apply(null, ys.concat([2015])), hi = Math.max.apply(null, ys.concat([2026]));
      const dots = pi.works.map((w, i) => '<button type="button" class="gs-wk" style="--c:' + (i === (local.work || 0) ? '#22d3ee' : '#a78bfa') + ';width:auto;padding:0 10px;margin:3px" data-dk="work" data-i="' + i + '" title="' + esc(w.t) + '">' + w.y + '</button>').join('');
      const w = pi.works[local.work || 0];
      return '<p class="gs-kick">The lab, with evidence</p><h2>' + esc(f ? f.honorific + ' ' + f.name : 'The PI') + '</h2><p class="gs-big">' + esc(f ? f.oneLine : '') + '</p><div class="gs-card" style="margin-top:14px"><b>Papers OpenAlex ties to this researcher (tap a year)</b><div>' + dots + '</div>' + (w ? '<p><b>' + esc(w.t) + '</b><br>' + esc(w.j) + ' · <a target="_blank" rel="noopener" href="https://doi.org/' + esc(w.doi) + '">doi:' + esc(w.doi) + '</a></p>' : '') + '</div><p class="gs-note">Identity checks I recorded: ' + ['affiliation', 'coauthors', 'history'].map((k) => '<span class="gs-chip ' + (st.identityChecks[k] && st.identityChecks[k].done ? 'ok' : 'block') + '">' + k + '</span>').join(' ') + '</p>';
    } });

    out.push({ id: 'arena', html: () => {
      const wts = {}; D.CRITERIA.forEach((c) => { wts[c.id] = local.w && local.w[c.id] != null ? local.w[c.id] : (st.weights && st.weights[c.id] != null ? st.weights[c.id] : c.w); });
      const rk = C.rankGaps(st.gaps, wts); const named = rk.live.filter((x) => (x.g.title || '').trim());
      return '<p class="gs-kick">Three candidates, compared by reasons</p><h2>Move the weights. Does the winner change?</h2><div class="gs-grid"><div>' + D.CRITERIA.map((c) => '<label class="gs-f" for="dkw-' + c.id + '">' + esc(c.label) + ': <b>' + wts[c.id] + '</b></label><input id="dkw-' + c.id + '" type="range" min="0" max="5" data-dk="w" data-c="' + c.id + '" value="' + wts[c.id] + '">').join('') + '<div style="margin-top:12px">' + named.map((x) => '<div style="margin:7px 0"><div class="gs-spread"><span>#' + x.rank + ' ' + esc(clip(x.g.title, 70)) + (x.g.id === st.chosenGap ? ' <span class="gs-chip ok">my choice</span>' : '') + '</span><b>' + x.pct + '</b></div><div class="gs-bar"><i style="width:' + x.pct + '%"></i></div></div>').join('') + rk.out.map((x) => '<div class="gs-badbox" style="margin-top:8px"><b>Screened out: ' + esc(clip(x.g.title, 70)) + '</b><br>' + esc(x.why.join(' ')) + '</div>').join('') + '</div></div><div>' + (named.length ? W.radar(named, 280) : '') + '</div></div>';
    } });

    out.push({ id: 'choice', html: () => '<p class="gs-kick">The contribution</p><h2>' + esc(g.title || 'Chosen gap') + '</h2><div class="gs-grid3" style="grid-template-columns:repeat(auto-fit,minmax(260px,1fr))">' + [['What is open', g.a && g.a.open], ['What I would do', g.a && g.a.action], ['How it helps the lab', g.a && g.a.help], ['If the result does not appear', g.a && g.a.null]].map((x) => '<div class="gs-tile"><small>' + x[0] + '</small><span style="color:var(--ink)">' + esc(clip(x[1], 330)) + '</span></div>').join('') + '</div><p class="gs-note" style="margin-top:12px">Why this beat the others: ' + esc(clip(st.justification, 420)) + '</p>' });

    out.push({ id: 'time', html: () => {
      const w = local.wk || 1; const sch = (st.plan.schedule || []).find((p) => w >= p.from && w <= p.to); const used = w * cal.weeklyHours; const fb = st.plan.fallback || {};
      return '<p class="gs-kick">Time</p><h2>Scrub the calendar: where am I in week ' + w + '?</h2>' + W.weekStrip(st, cal, { cursor: w }) + '<div class="gs-card"><b>Week ' + w + (cal.weeks[w - 1] ? ' · ' + C.fmt(cal.weeks[w - 1].monday) : '') + '</b><p style="margin:6px 0">' + esc(sch ? sch.label : 'Not scheduled') + '</p><div class="gs-bar"><i style="width:' + Math.round(used / Math.max(1, cal.total) * 100) + '%"></i></div><p class="gs-note">' + used + ' of ' + cal.total + ' hours used by the end of this week.' + (fb.switchByWeek ? (w <= fb.switchByWeek ? ' Fallback still available (last safe switch: week ' + fb.switchByWeek + ').' : ' Past the fallback horizon (week ' + fb.switchByWeek + ').') : '') + '</p></div>';
    } });

    out.push({ id: 'lights', html: () => '<p class="gs-kick">Resources: two different questions</p><h2>Has the lab used it? Can I use it?</h2><div class="gs-card">' + W.lights(st.resources) + '</div>' + (st.resources.filter((x) => x.access === 'unconfirmed').length ? '<div class="gs-warnbox">' + st.resources.filter((x) => x.access === 'unconfirmed').map((x) => '<b>' + esc(clip(x.name, 60)) + '</b>: ' + esc(clip(x.accessNote || 'Not confirmed.', 200))).join('<br>') + '</div>' : '') });

    out.push({ id: 'money', html: () => '<p class="gs-kick">Money</p><h2>' + C.money(bt.total) + ', every dollar tied to an activity</h2>' + W.budgetBars(st.budget) + '<div class="gs-scroll"><table class="gs-t" style="margin-top:12px"><tr><th>Item</th><th>$</th><th>Supports</th></tr>' + st.budget.map((b) => '<tr><td>' + esc(b.item) + '</td><td>' + C.money(b.amount) + '</td><td>' + esc(b.linksTo) + '</td></tr>').join('') + '</table></div>' });

    out.push({ id: 'risk', html: () => '<p class="gs-kick">What could go wrong</p><h2>The assumption most likely to change the project</h2><button class="gs-btn2 gs-bigbtn" data-dk="reveal">' + (local.reveal ? 'Hide' : 'Reveal my answer') + '</button>' + (local.reveal ? '<div class="gs-card gs-glow" style="margin-top:14px"><p class="gs-big">' + esc(st.defense.assumption) + '</p></div>' : '') + '<div class="gs-card"><b>Fallback.</b> ' + esc((st.plan.fallback || {}).note) + '</div>' });

    out.push({ id: 'ask', html: () => '<p class="gs-kick">What I need from you</p><h2>Decisions before I submit</h2><ol class="gs-big" style="padding-left:1.2em">' + C.decisions(st).map((d) => '<li style="margin:7px 0"><span class="gs-chip cy">' + esc(d.kind) + '</span> ' + esc(clip(d.text, 230)) + '</li>').join('') + '</ol><p class="gs-note">Pending signatures and letters are listed on the decision sheet. I am not asking for any of them to be assumed.</p>' });

    out.push({ id: 'drill', html: () => {
      const qa = [['Why this gap and not another?', st.justification], ['Explain the gap', st.defense.gap], ['Defend your comparison or controls', st.defense.comparison], ['Describe the analysis', st.defense.analysis], ['What assumption could change the project?', st.defense.assumption], ['What if you get a null result?', g.a && g.a.null], ['What if a critical dependency fails?', g.a && g.a.fallback]];
      return '<p class="gs-kick">Practice</p><h2>Tap a card, answer out loud first, then reveal</h2><div class="gs-grid3" style="grid-template-columns:repeat(auto-fit,minmax(260px,1fr))">' + qa.map((x, i) => '<div class="gs-flip' + (local.flip && local.flip[i] ? ' on' : '') + '"><button type="button" data-dk="flip" data-i="' + i + '"><span class="q">' + esc(x[0]) + '</span><span class="a">' + esc(clip(x[1], 420)) + '</span></button></div>').join('') + '</div>';
    } });
    return out;
  }

  function draw() {
    const s = slides[idx];
    el.querySelector('.gs-dk-stage').innerHTML = '<section class="gs-slide" aria-label="Slide ' + (idx + 1) + ' of ' + slides.length + '">' + s.html() + '</section>';
    el.querySelector('.gs-dots').innerHTML = slides.map((x, i) => '<button type="button" data-dk="to" data-i="' + i + '" aria-label="Slide ' + (i + 1) + '" aria-current="' + (i === idx) + '"></button>').join('');
    el.querySelector('.gs-dk-n').textContent = (idx + 1) + ' / ' + slides.length;
  }
  function tick() { const s = Math.floor((Date.now() - t0) / 1000); const t = el.querySelector('.gs-dk-t'); t.textContent = showTimer ? String(Math.floor(s / 60)).padStart(2, '0') + ':' + String(s % 60).padStart(2, '0') : ''; }
  function close() { clearInterval(timer); if (keyFn) document.removeEventListener('keydown', keyFn); if (el) el.remove(); el = null; document.body.style.overflow = ''; }
  function open(st, helpers) {
    close(); S = st; H = helpers || {}; idx = 0; local = {}; slides = build(st); t0 = Date.now(); showTimer = false;
    el = document.createElement('div'); el.className = 'gs-deck'; el.setAttribute('role', 'dialog'); el.setAttribute('aria-label', 'Defense deck'); el.setAttribute('aria-modal', 'true');
    el.innerHTML = '<div class="gs-dk-top"><span>RESEARCH-TO-GRANT STUDIO · DEFENSE</span><span><span class="gs-dk-t"></span> <span class="gs-dk-n"></span></span><span><button class="gs-btn3 gs-sm" data-dk="timer">Timer</button> <button class="gs-btn3 gs-sm" data-dk="full">Full screen</button> <button class="gs-btn3 gs-sm" data-dk="close">Close (Esc)</button></span></div><div class="gs-dk-stage"></div><div class="gs-dk-bot"><button class="gs-btn2" data-dk="prev">Back</button><div class="gs-dots"></div><button class="gs-btn" data-dk="next">Next</button></div>';
    document.body.appendChild(el); document.body.style.overflow = 'hidden'; draw();
    el.addEventListener('click', (e) => { const b = e.target.closest('[data-dk]'); if (!b) return; act(b); });
    el.addEventListener('input', (e) => { const b = e.target.closest('[data-dk="w"]'); if (b) { local.w = local.w || {}; local.w[b.dataset.c] = Number(b.value); draw(); const again = el.querySelector('#dkw-' + b.dataset.c); if (again) again.focus(); } });
    let sx = 0; el.addEventListener('touchstart', (e) => { sx = e.touches[0].clientX; }, { passive: true }); el.addEventListener('touchend', (e) => { const dx = e.changedTouches[0].clientX - sx; if (Math.abs(dx) > 70) act({ dataset: { dk: dx < 0 ? 'next' : 'prev' } }); }, { passive: true });
    keyFn = (e) => { if (e.key === 'Escape') close(); else if (e.key === 'ArrowRight' || (e.key === ' ' && e.target === document.body)) { e.preventDefault(); act({ dataset: { dk: 'next' } }); } else if (e.key === 'ArrowLeft') act({ dataset: { dk: 'prev' } }); else if (e.key.toLowerCase() === 't' && !/INPUT|TEXTAREA|SELECT/.test((e.target.tagName || ''))) act({ dataset: { dk: 'timer' } }); };
    document.addEventListener('keydown', keyFn); timer = setInterval(tick, 1000); tick();
    const first = el.querySelector('[data-dk="next"]'); if (first) first.focus();
  }
  function act(b) {
    const d = b.dataset.dk, i = Number(b.dataset.i);
    if (d === 'close') return close();
    if (d === 'next') { idx = Math.min(slides.length - 1, idx + 1); draw(); }
    else if (d === 'prev') { idx = Math.max(0, idx - 1); draw(); }
    else if (d === 'to') { idx = i; draw(); }
    else if (d === 'work') { local.work = i; draw(); }
    else if (d === 'reveal') { local.reveal = !local.reveal; draw(); }
    else if (d === 'flip') { local.flip = local.flip || {}; local.flip[i] = !local.flip[i]; draw(); }
    else if (d === 'timer') { showTimer = !showTimer; tick(); }
    else if (d === 'full') { if (document.fullscreenElement) document.exitFullscreen(); else if (el && el.requestFullscreen) el.requestFullscreen(); }
    else if (d === 'wk') { /* handled below */ }
  }
  // week strip buttons use data-act="wk" inside the deck: route them to the scrubber
  document.addEventListener('click', (e) => { const b = e.target.closest && e.target.closest('.gs-deck [data-act="wk"]'); if (b && el) { e.stopPropagation(); local.wk = Number(b.dataset.w); draw(); } }, true);

  root.StudioDeck = { open, close, build };
})(typeof window !== 'undefined' ? window : globalThis);
