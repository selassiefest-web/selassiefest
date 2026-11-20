// BIOS102 Research-to-Grant Studio: the instrument-panel widgets (pure SVG/HTML string builders).
(function (root) {
  'use strict';
  const C = root.StudioCore; const esc = C.esc;
  const CAT = { training: ['Training', '#a78bfa'], access: ['Data access', '#22d3ee'], trouble: ['Troubleshooting', '#fbbf24'], analysis: ['Analysis', '#4ade80'], reporting: ['Reporting', '#f472b6'] };
  const LVL = { ok: ['#4ade80', 'Clear'], warn: ['#fbbf24', 'Open'], block: ['#fb7185', 'Blocked'] };

  // Readiness ring: a glowing arc with the percent in the middle.
  function ring(pct, label, size) {
    const s = size || 190, r = s / 2 - 16, c = 2 * Math.PI * r, off = c * (1 - Math.max(0, Math.min(100, pct)) / 100);
    return '<svg class="gs-ring" viewBox="0 0 ' + s + ' ' + s + '" width="' + s + '" height="' + s + '" role="img" aria-label="' + esc(label || 'Readiness') + ' ' + pct + ' percent">' +
      '<defs><linearGradient id="gsg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#22d3ee"/><stop offset=".55" stop-color="#a78bfa"/><stop offset="1" stop-color="#f472b6"/></linearGradient><filter id="gsglow"><feGaussianBlur stdDeviation="3.5" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs>' +
      '<circle cx="' + s / 2 + '" cy="' + s / 2 + '" r="' + r + '" fill="none" stroke="rgba(255,255,255,.09)" stroke-width="12"/>' +
      '<circle cx="' + s / 2 + '" cy="' + s / 2 + '" r="' + (r - 15) + '" fill="none" stroke="rgba(255,255,255,.05)" stroke-width="2" stroke-dasharray="3 7"/>' +
      '<circle class="gs-ring-arc" cx="' + s / 2 + '" cy="' + s / 2 + '" r="' + r + '" fill="none" stroke="url(#gsg)" stroke-width="12" stroke-linecap="round" stroke-dasharray="' + c.toFixed(1) + '" stroke-dashoffset="' + off.toFixed(1) + '" transform="rotate(-90 ' + s / 2 + ' ' + s / 2 + ')" filter="url(#gsglow)"/>' +
      '<text x="50%" y="48%" text-anchor="middle" class="gs-ring-n" style="font-size:' + Math.round(46 * s / 190) + 'px">' + pct + '<tspan class="gs-ring-u">%</tspan></text><text x="50%" y="62%" text-anchor="middle" class="gs-ring-l">' + esc(label || 'ready') + '</text></svg>';
  }

  // Hours donut by category.
  function hoursDonut(totals, total) {
    const keys = Object.keys(CAT); const s = 150, r = 52, c = 2 * Math.PI * r; let acc = 0;
    const segs = keys.map((k) => { const v = totals[k] || 0; const len = total ? (v / total) * c : 0; const seg = '<circle cx="75" cy="75" r="' + r + '" fill="none" stroke="' + CAT[k][1] + '" stroke-width="20" stroke-dasharray="' + len.toFixed(1) + ' ' + (c - len).toFixed(1) + '" stroke-dashoffset="' + (-acc).toFixed(1) + '" transform="rotate(-90 75 75)"><title>' + CAT[k][0] + ': ' + v + ' h</title></circle>'; acc += len; return seg; }).join('');
    return '<div class="gs-donut"><svg viewBox="0 0 ' + s + ' ' + s + '" width="' + s + '" height="' + s + '" role="img" aria-label="Hours by activity, ' + total + ' hours total"><circle cx="75" cy="75" r="' + r + '" fill="none" stroke="rgba(255,255,255,.07)" stroke-width="20"/>' + segs + '<text x="75" y="72" text-anchor="middle" class="gs-don-n">' + total + '</text><text x="75" y="90" text-anchor="middle" class="gs-don-l">hours</text></svg><ul class="gs-legend">' + keys.map((k) => '<li><i style="background:' + CAT[k][1] + '"></i>' + CAT[k][0] + ' <b>' + (totals[k] || 0) + '</b></li>').join('') + '</ul></div>';
  }

  // Week strip: one cell per working week, coloured by the phase it belongs to; the checkpoint and the fallback horizon are marked.
  function weekStrip(st, cal, opt) {
    const sch = (st.plan && st.plan.schedule) || []; const fb = st.plan && st.plan.fallback; const cur = opt && opt.cursor;
    let cells = '';
    for (let w = 1; w <= cal.totalWeeks; w++) {
      const ph = sch.find((p) => w >= p.from && w <= p.to); let col = 'rgba(255,255,255,.12)', tip = 'Week ' + w + ': unscheduled';
      if (ph) { const k = Object.keys(ph.cat).sort((a, b) => ph.cat[b] - ph.cat[a])[0]; col = CAT[k][1]; tip = 'Week ' + w + ': ' + ph.label; }
      const wk = cal.weeks[w - 1];
      cells += '<button type="button" class="gs-wk' + (fb && w === fb.switchByWeek ? ' gs-wk-fb' : '') + (cur === w ? ' gs-wk-cur' : '') + '" style="--c:' + col + '" data-act="wk" data-w="' + w + '" title="' + esc(tip + (wk ? ' (' + C.fmt(wk.monday) + ')' : '')) + '" aria-label="' + esc(tip) + '"><span>' + w + '</span></button>';
    }
    return '<div class="gs-strip" role="group" aria-label="Weeks of the project">' + cells + '</div>' + (fb ? '<p class="gs-note"><span class="gs-dot gs-dot-fb"></span> Fallback horizon: the latest week you can switch and still finish is week ' + fb.switchByWeek + '.</p>' : '');
  }

  // Radar of the five comparison criteria for each live candidate.
  function radar(rows, size) {
    const s = size || 260, cx = s / 2, cy = s / 2, R = s / 2 - 42; const crit = C.STUDIO_CRIT || root.STUDIO_DATA.CRITERIA; const n = crit.length;
    const pt = (i, v) => { const a = -Math.PI / 2 + (i * 2 * Math.PI) / n; return [cx + Math.cos(a) * R * (v / 5), cy + Math.sin(a) * R * (v / 5)]; };
    const COL = ['#22d3ee', '#f472b6', '#a3e635', '#fbbf24', '#a78bfa'];
    let g = '';
    [1, 2, 3, 4, 5].forEach((v) => { g += '<polygon points="' + crit.map((_, i) => pt(i, v).map((x) => x.toFixed(1)).join(',')).join(' ') + '" fill="none" stroke="rgba(255,255,255,' + (v === 5 ? '.22' : '.08') + ')"/>'; });
    crit.forEach((c, i) => { const p = pt(i, 5.9); g += '<line x1="' + cx + '" y1="' + cy + '" x2="' + pt(i, 5)[0].toFixed(1) + '" y2="' + pt(i, 5)[1].toFixed(1) + '" stroke="rgba(255,255,255,.1)"/><text x="' + p[0].toFixed(1) + '" y="' + p[1].toFixed(1) + '" text-anchor="middle" class="gs-rad-l">' + esc(c.short || c.label) + '</text>'; });
    rows.forEach((r, k) => { const col = COL[k % COL.length]; const pts = crit.map((c, i) => pt(i, Number(r.g.score && r.g.score[c.id]) || 0).map((x) => x.toFixed(1)).join(',')).join(' '); g += '<polygon points="' + pts + '" fill="' + col + '" fill-opacity=".16" stroke="' + col + '" stroke-width="2"><title>' + esc(r.g.title) + '</title></polygon>'; });
    return '<svg class="gs-radar" viewBox="-26 0 ' + (s + 52) + ' ' + s + '" role="img" aria-label="Radar chart comparing candidate contributions">' + g + '</svg>' +
      '<ul class="gs-legend">' + rows.map((r, k) => '<li><i style="background:' + COL[k % COL.length] + '"></i>' + esc(r.g.title.length > 52 ? r.g.title.slice(0, 50) + '…' : r.g.title) + '</li>').join('') + '</ul>';
  }

  // Two-light evidence grid: left = "lab has used it", right = "I can use it".
  function lights(resources) {
    const usedC = { method: ['#4ade80', 'Described in methods or dataset page'], profile: ['#22d3ee', 'On a profile or website'], title: ['#fbbf24', 'Title or abstract only: confirm in Methods'], '': ['#fb7185', 'No evidence recorded'] };
    const accC = { public: ['#4ade80', 'Public / open'], confirmed: ['#4ade80', 'Confirmed for this project'], unconfirmed: ['#fb7185', 'NOT confirmed'], '': ['#94a3b8', 'Unknown'] };
    if (!resources.length) return '<p class="gs-note">No resources listed yet.</p>';
    return '<div class="gs-lights">' + resources.map((r) => {
      const u = usedC[r.used || ''], a = accC[r.access || ''];
      return '<div class="gs-light-row"><span class="gs-lamp" style="--c:' + u[0] + '" title="Lab has used it: ' + esc(u[1]) + '"></span><span class="gs-lamp" style="--c:' + a[0] + '" title="I can use it: ' + esc(a[1]) + '"></span><span class="gs-light-name">' + esc(r.name.length > 70 ? r.name.slice(0, 68) + '…' : r.name) + (r.critical ? ' <em>critical</em>' : '') + '</span></div>';
    }).join('') + '</div><p class="gs-note">Left light: evidence the lab has used it. Right light: can <em>I</em> use it for this project?</p>';
  }

  // Gate chips (readiness items).
  function gates(items) {
    return '<div class="gs-gates">' + items.map((i) => '<button type="button" class="gs-gate gs-' + i.level + '" data-act="go" data-v="' + i.view + '" title="' + esc(i.detail) + '"><span class="gs-gdot" style="--c:' + LVL[i.level][0] + '"></span><span class="gs-gt">' + esc(i.label) + '</span><span class="gs-gs">' + LVL[i.level][1] + '</span></button>').join('') + '</div>';
  }

  // Budget donut by pay type or item.
  function budgetBars(budget) {
    const tot = C.budgetTotals(budget).total || 1; const COL = ['#22d3ee', '#a78bfa', '#f472b6', '#fbbf24', '#4ade80', '#fb7185'];
    return '<div class="gs-bbar">' + budget.map((b, i) => '<span style="flex:' + Math.max(0.5, (Number(b.amount) || 0) / tot * 100).toFixed(1) + ';background:' + COL[i % COL.length] + '" title="' + esc(b.item + ': ' + C.money(b.amount)) + '"></span>').join('') + '</div><ul class="gs-legend">' + budget.map((b, i) => '<li><i style="background:' + COL[i % COL.length] + '"></i>' + esc(b.item.length > 48 ? b.item.slice(0, 46) + '…' : b.item) + ' <b>' + C.money(b.amount) + '</b></li>').join('') + '</ul>';
  }

  root.StudioWidgets = { CAT, LVL, ring, hoursDonut, weekStrip, radar, lights, gates, budgetBars };
  if (typeof module !== 'undefined' && module.exports) module.exports = root.StudioWidgets;
})(typeof window !== 'undefined' ? window : globalThis);
