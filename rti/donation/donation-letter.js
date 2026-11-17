// Builds the signed written acknowledgment of an in-kind donation (IRS-style: what was received, and that nothing was given in exchange).
// pdf-lib 1.17.1, runs in the browser or node. Nothing is sent anywhere.
// d = { date: "November 15, 2026", donor, contact, contactTitle, donorAddr: ["line", ...], requestNo,
//       items: [{ name, qty, unit }], useLine, org: {name, ein, addr, phone, email, signer, title},
//       sigPng: Uint8Array|null, sigText: string|null }
async function buildLetter(PDFLib, d) {
  const { PDFDocument, StandardFonts, rgb } = PDFLib;
  const pdf = await PDFDocument.create();
  const reg = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  const ital = await pdf.embedFont(StandardFonts.HelveticaOblique);
  const W = 612, H = 792, M = 61, TW = W - 2 * M, INK = rgb(0.086, 0.094, 0.169), GRAY = rgb(0.28, 0.29, 0.39);
  let page, y;
  const newPage = () => {
    page = pdf.addPage([W, H]);
    const bw = W / 3;
    page.drawRectangle({ x: 0, y: H - 6, width: bw, height: 6, color: rgb(0.824, 0.161, 0.176) });
    page.drawRectangle({ x: bw, y: H - 6, width: bw, height: 6, color: rgb(0.929, 0.733, 0.18) });
    page.drawRectangle({ x: 2 * bw, y: H - 6, width: bw, height: 6, color: rgb(0.184, 0.416, 0.753) });
    y = H - 50;
  };
  const wrap = (t, f, s, mw) => {
    const out = []; let line = "";
    for (const w of String(t).split(/\s+/)) {
      const tryL = line ? line + " " + w : w;
      if (f.widthOfTextAtSize(tryL, s) > mw && line) { out.push(line); line = w; } else line = tryL;
    }
    if (line) out.push(line); return out;
  };
  const need = (h) => { if (y - h < 70) newPage(); };
  const para = (t, o = {}) => {
    const f = o.font || reg, s = o.size || 11, lh = s * 1.45;
    for (const ln of wrap(t, f, s, TW)) { need(lh); page.drawText(ln, { x: M, y, size: s, font: f, color: o.color || INK }); y -= lh; }
    y -= o.gap == null ? 9 : o.gap;
  };
  const o = d.org;
  newPage();
  page.drawText(o.name.toUpperCase(), { x: M, y, size: 16, font: bold, color: INK }); y -= 15;
  para("An Illinois not-for-profit corporation · 501(c)(3) · EIN " + o.ein, { size: 9, color: GRAY, gap: 0 });
  para(o.addr + " · " + o.phone + " · " + o.email, { size: 9, color: GRAY, gap: 20 });
  para(d.date, { gap: 12 });
  const addr = [d.donor, "Attn: " + d.contact + (d.contactTitle ? ", " + d.contactTitle : "")].concat(d.donorAddr.filter(Boolean));
  for (const l of addr) para(l, { gap: 0 }); y -= 12;
  para("Re: Written acknowledgment of in-kind donation" + (d.requestNo ? ", request " + d.requestNo : ""), { font: bold, gap: 12 });
  para("Dear " + (d.contact.trim().split(/\s+/)[0] || "Sir or Madam") + ",", { gap: 9 });
  para("On behalf of " + o.name + ", a tax-exempt organization described in section 501(c)(3) of the Internal Revenue Code (EIN " + o.ein + "), I confirm that we received the following products from " + d.donor + " at " + o.addr + ":");
  // table
  const c1 = M + 8, c2 = M + TW - 150, rh = 22;
  const row = (a, b, hdr) => {
    need(rh);
    page.drawRectangle({ x: M, y: y - rh + 6, width: TW, height: rh, borderColor: rgb(.6, .6, .6), borderWidth: .7, color: hdr ? rgb(.94, .94, .94) : undefined });
    page.drawLine({ start: { x: c2 - 8, y: y + 6 }, end: { x: c2 - 8, y: y - rh + 6 }, thickness: .7, color: rgb(.6, .6, .6) });
    page.drawText(a, { x: c1, y: y - 8, size: 10.5, font: hdr ? bold : reg, color: INK });
    page.drawText(b, { x: c2, y: y - 8, size: 10.5, font: hdr ? bold : reg, color: INK });
    y -= rh;
  };
  row("Product", "Quantity", true);
  for (const i of d.items) row(i.name, i.qty + (i.unit ? " " + i.unit : ""), false);
  y -= 14;
  para("No goods or services were received in exchange for these products.", { font: bold });
  para("The equipment will be used for " + d.useLine + ". We are grateful to " + d.donor + " and to you for making this possible. I have also enclosed a copy of our Form W-9.");
  para("With gratitude,", { gap: 4 });
  need(70);
  const sy = y - 34;
  if (d.sigPng) {
    const img = await pdf.embedPng(d.sigPng);
    const s = Math.min(170 / img.width, 42 / img.height);
    page.drawImage(img, { x: M, y: sy + 2, width: img.width * s, height: img.height * s });
  } else if (d.sigText) {
    page.drawText(d.sigText, { x: M, y: sy + 8, size: 22, font: ital, color: rgb(0.05, 0.05, 0.25) });
  }
  page.drawLine({ start: { x: M, y: sy }, end: { x: M + 216, y: sy }, thickness: .8, color: INK });
  y = sy - 14;
  para(o.signer, { gap: 0 }); para(o.title + ", " + o.name, { gap: 14 });
  para("Enclosure: Form W-9", { size: 9, color: GRAY });
  return await pdf.save();
}
if (typeof module !== "undefined") module.exports = { buildLetter };
