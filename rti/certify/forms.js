/* Fills the City of Chicago's official M/WBE forms from the Certification Hub profile.
   Needs pdf-lib (global PDFLib). Templates are the City's unaltered PDFs in ./forms/.
   Coordinates were measured against the official PDFs (PDF points, origin bottom-left).
   NEVER written: SSN, driver's license number, date of birth, signatures, True/False attestations. */
(function (root) {
  'use strict';
  var INK = null;
  function clean(s) { return String(s == null ? '' : s).replace(/[‘’]/g, "'").replace(/[“”]/g, '"').replace(/[–—]/g, '-').replace(/…/g, '...').replace(/[^\x20-\x7E\n]/g, ''); }
  function has(x) { return x !== undefined && x !== null && String(x).trim() !== ''; }
  function num(x) { var v = parseFloat(String(x == null ? '' : x).replace(/[^0-9.\-]/g, '')); return isNaN(v) ? 0 : v; }
  function money(x) { return has(x) ? '$' + num(x).toLocaleString('en-US') : ''; }
  function today() { var d = new Date(); return (d.getMonth() + 1) + '/' + d.getDate() + '/' + d.getFullYear(); }

  async function load(url) { var r = await fetch(url); if (!r.ok) throw new Error('Could not load ' + url); return PDFLib.PDFDocument.load(await r.arrayBuffer(), { ignoreEncryption: true }); }

  function widthOf(font, t, size) { return font.widthOfTextAtSize(t, size); }
  /* single line, shrinks to fit; returns true when it had to truncate */
  function fit(page, text, font, x, y, maxW, size, min) {
    text = clean(text).replace(/\n/g, ' '); if (!text) return false;
    var s = size || 9, m = min || 5.5;
    while (widthOf(font, text, s) > maxW && s > m) s -= 0.25;
    var cut = false;
    if (widthOf(font, text, s) > maxW) { cut = true; while (text.length > 4 && widthOf(font, text + '...', s) > maxW) text = text.slice(0, -1); text += '...'; }
    page.drawText(text, { x: x, y: y, size: s, font: font, color: INK }); return cut;
  }
  function wrapWords(text, font, size, w) {
    var words = clean(text).replace(/\n/g, ' \n ').split(/ +/), lines = [], cur = '';
    words.forEach(function (wd) {
      if (wd === '\n') { lines.push(cur); cur = ''; return; }
      var t = cur ? cur + ' ' + wd : wd;
      if (widthOf(font, t, size) <= w) cur = t; else { if (cur) lines.push(cur); cur = wd; }
    });
    if (cur) lines.push(cur);
    return lines;
  }
  /* flows text into fixed one-line slots; returns the leftover text that did not fit */
  function flow(page, text, font, size, slots) {
    var words = clean(text).replace(/\s+/g, ' ').trim().split(' ').filter(Boolean), i = 0;
    for (var s = 0; s < slots.length; s++) {
      var line = '';
      while (i < words.length) {
        var t = line ? line + ' ' + words[i] : words[i];
        if (widthOf(font, t, size) <= slots[s].w) { line = t; i++; } else break;
      }
      if (line) page.drawText(line, { x: slots[s].x, y: slots[s].y, size: size, font: font, color: INK });
    }
    return words.slice(i).join(' ');
  }
  function addContinuation(pdf, font, bold, title, items) {
    var pend = items.filter(function (it) { return has(it.text); });
    if (!pend.length) return;
    var page = pdf.addPage([612, 792]), y = 740;
    page.drawText(clean(title), { x: 54, y: y, size: 13, font: bold, color: PDFLib.rgb(0, 0, 0) }); y -= 24;
    pend.forEach(function (it) {
      if (y < 80) { page = pdf.addPage([612, 792]); y = 740; }
      page.drawText(clean(it.label), { x: 54, y: y, size: 10, font: bold, color: PDFLib.rgb(0, 0, 0) }); y -= 15;
      wrapWords(it.text, font, 10, 500).forEach(function (l) { if (y < 60) { page = pdf.addPage([612, 792]); y = 740; } page.drawText(l, { x: 54, y: y, size: 10, font: font, color: INK }); y -= 13; });
      y -= 12;
    });
  }
  function yearsSince(d) { if (!d) return ''; var t = new Date(d + 'T00:00:00'); if (isNaN(t)) return ''; var y = (Date.now() - t.getTime()) / 31557600000; return y < 1 ? 'Less than 1' : String(Math.floor(y)); }

  /* ---------- Attachment 1: Individual Statement of Ownership (flat PDF, overlay) ---------- */
  async function attachment1(P, idx) {
    var o = (P.owners || [])[idx || 0] || {}, b = P.biz || {};
    var pdf = await load('forms/chi-attach1-individual-statement-of-ownership.pdf');
    var font = await pdf.embedFont(PDFLib.StandardFonts.Helvetica), bold = await pdf.embedFont(PDFLib.StandardFonts.HelveticaBold);
    INK = PDFLib.rgb(0.05, 0.1, 0.5);
    var p1 = pdf.getPages()[0], p2 = pdf.getPages()[1], more = [];
    fit(p1, b.legalName, font, 118, 664, 470, 10);
    fit(p1, o.name, font, 125, 644, 190, 10);
    fit(p1, o.formerName, font, 415, 644, 170, 10);
    fit(p1, [o.homeStreet, o.homeCSZ].filter(has).join(', '), font, 100, 623, 485, 10);
    /* row of identity cells. SSN (23-150), license (150-252) and date of birth (481-596) are intentionally left blank. */
    var origin = [o.ethnicity, /^united states$/i.test(String(o.nationalOrigin || '').trim()) ? 'U.S.' : o.nationalOrigin].filter(has).join(' / ');
    fit(p1, origin, font, 255, 560.5, 109, 7, 5.5);
    fit(p1, o.gender, font, 370, 560.5, 108, 8);
    fit(p1, yearsSince(o.ownerSince) ? yearsSince(o.ownerSince) + ' (since ' + o.ownerSince + ')' : '', font, 27, 523.5, 183, 9);
    fit(p1, has(o.pct) ? o.pct + '%' : '', font, 218, 523.5, 183, 9);
    fit(p1, money(o.salary), font, 408, 523.5, 183, 9);
    /* 1. responsibilities */
    var left1 = flow(p1, [o.title, o.duties].filter(has).join('. '), font, 8, [{ x: 403, y: 400.5, w: 170 }, { x: 75, y: 386, w: 495 }, { x: 75, y: 369.5, w: 495 }]);
    if (left1) more.push({ label: '1. Responsibilities (continued)', text: [o.title, o.duties].filter(has).join('. ') });
    /* 2. contributions */
    if (has(o.capAmt)) {
      fit(p1, 'Cash' + (o.capDate ? ' (' + o.capDate + ')' : ''), font, 73, 277.5, 150, 8);
      fit(p1, money(o.capAmt), font, 231, 277.5, 92, 8);
      fit(p1, (o.capSource || '') + (has(o.capNote) ? ' (see attached)' : ''), font, 330, 277.5, 250, 8);
      if (has(o.capNote)) more.push({ label: '2. Source of contribution: ' + (o.capSource || ''), text: o.capNote + ' Bank records attached: ______________________' });
    }
    /* 3. expertise and control */
    var q3 = [(has(o.years) ? o.years + ' years in the trade.' : ''), (has(o.education) ? 'Education/training: ' + o.education + '.' : ''), (has(o.trades) ? 'Licenses: ' + o.trades + '.' : ''),
      'Works ' + (o.hours || '?') + ' hrs/week; signs checks and contracts alone: ' + (o.signs || '?') + '. Resume attached.'].filter(has).join(' ');
    var left3 = flow(p1, q3, font, 8, [{ x: 70, y: 188, w: 500 }, { x: 70, y: 171.5, w: 500 }]);
    if (left3) more.push({ label: '3. Expertise, management and control (full text)', text: q3 });
    /* 4. family */
    if (has(o.family)) {
      if (/^none\b/i.test(o.family.trim())) fit(p1, 'None', font, 63, 108.5, 240, 9);
      else { fit(p1, 'See attached', font, 63, 108.5, 240, 9); more.push({ label: '4. Family relationships', text: o.family }); }
    }
    /* 5. other businesses (page 2) */
    if (has(b.affiliates)) {
      if (/^none\b/i.test(b.affiliates.trim())) fit(p2, 'None', font, 63, 631.5, 98, 9);
      else { fit(p2, 'See attached', font, 63, 631.5, 98, 9); more.push({ label: '5. Other businesses owned', text: b.affiliates }); }
    }
    addContinuation(pdf, font, bold, 'Attachment 1 continuation: ' + (o.name || '') + ' / ' + (b.legalName || ''), more);
    return pdf.save();
  }

  /* ---------- Attachment 2: Personal Net Worth Statement (flat PDF, overlay) ---------- */
  async function attachment2(P, idx) {
    var o = (P.owners || [])[idx || 0] || {}, b = P.biz || {}, E = root.CertEngine;
    var pdf = await load('forms/chi-attach2-personal-net-worth.pdf');
    var font = await pdf.embedFont(PDFLib.StandardFonts.Helvetica);
    INK = PDFLib.rgb(0.05, 0.1, 0.5);
    var p = pdf.getPages()[0], nw = E.netWorth(o);
    fit(p, today(), font, 450, 687, 100, 10);
    fit(p, b.legalName, font, 134, 640, 330, 9);
    fit(p, o.name, font, 134, 628, 165, 9);
    fit(p, b.phone, font, 414, 628, 158, 9);
    fit(p, o.homeStreet, font, 134, 615.5, 165, 9);
    fit(p, o.homePhone, font, 414, 615.5, 158, 9);
    fit(p, o.homeCSZ, font, 134, 603.5, 165, 9);
    fit(p, o.ownerEmail, font, 414, 603.5, 158, 8);
    var amt = function (v) { return has(v) ? Math.round(num(v)).toLocaleString('en-US') : ''; };
    var L = [[216, 570, o.a_cash], [216, 545.5, o.a_savings], [216, 521, o.a_recv], [216, 497, o.a_life], [216, 473, o.a_stocks], [216, 448.5, o.a_auto],
      [486, 570, o.l_payable], [486, 545.5, o.l_notes], [486, 521, o.l_instAuto], [486, 473, o.l_instOther], [486, 425, o.l_loanLife], [486, 400, o.l_taxes], [486, 379, o.l_other]];
    L.forEach(function (r) { if (has(r[2])) fit(p, amt(r[2]), font, r[0], r[1], 85, 8); });
    fit(p, Math.round(nw.assets).toLocaleString('en-US'), font, 216, 358, 85, 8);
    fit(p, Math.round(nw.liabilities).toLocaleString('en-US'), font, 486, 358, 85, 8);
    fit(p, Math.round(nw.net).toLocaleString('en-US'), font, 486, 339, 85, 8);
    return pdf.save();
  }

  /* ---------- IRS Form 4506-T (City copy; real form fields) ---------- */
  async function form4506T(P) {
    var b = P.biz || {}, f = P.fin || {}, pdf = await load('forms/chi-attach5-irs-4506t.pdf'), form = pdf.getForm();
    var pre = 'topmostSubform[0].Page1[0].';
    function t(n, v) { if (has(v)) form.getTextField(pre + n + '[0]').setText(clean(v)); }
    t('p1-t1', b.legalName);
    t('p1-t2', b.ein);
    t('p1-t7', [b.legalName, [b.address, b.city, b.state, b.zip].filter(has).join(', ')].filter(has).join(', '));
    t('p1-t10', (f.taxForm || '').replace(/\s*\(.*\)/, ''));
    form.getCheckBox(pre + 'p1-cb1[0]').check();
    var yrs = (f.taxYears || '').split(/[,;\s]+/).filter(function (x) { return /^\d{4}$/.test(x); }).sort().reverse().slice(0, 4).reverse();
    ['p1-t11', 'p1-t14', 'p1-t17', 'p1-t20'].forEach(function (n, i) { if (yrs[i]) t(n, '12/31/' + yrs[i]); });
    t('p1-t38', String(b.phone || '').replace(/\D/g, '').replace(/^1?(\d{3})(\d{3})(\d{4})$/, '$1-$2-$3'));
    form.updateFieldAppearances(await pdf.embedFont(PDFLib.StandardFonts.Helvetica));
    return pdf.save();
  }

  var api = { attachment1: attachment1, attachment2: attachment2, form4506T: form4506T };
  root.CertForms = api;
})(window);
