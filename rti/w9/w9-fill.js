// Fills the IRS Form W-9 (Rev. March 2024, form.pdf) in the browser with pdf-lib 1.17.1.
// Used by index.html and by the local test. Nothing is sent anywhere.
// d = { name, bizName, cls: "ind"|"c"|"s"|"p"|"trust"|"llc"|"other", llcCode, otherText, exempt, fatca, addr, cityStateZip, acct,
//       ein: "42-3036705" | null, ssn: "123-45-6789" | null, date: "11/01/2026", sigPng: Uint8Array|null, sigText: string|null }
async function fillW9(PDFLib, bytes, d) {
  const { PDFDocument, StandardFonts, rgb } = PDFLib;
  const pdf = await PDFDocument.load(bytes, { ignoreEncryption: true });
  const form = pdf.getForm();
  const P = "topmostSubform[0].Page1[0].";
  const T = (n, v) => { if (v == null || v === "") return; const f = form.getTextField(P + n); f.setText(String(v)); };
  T("f1_01[0]", d.name);
  T("f1_02[0]", d.bizName);
  const box = { ind: 0, c: 1, s: 2, p: 3, trust: 4, llc: 5, other: 6 };
  if (d.cls in box) form.getCheckBox(P + "Boxes3a-b_ReadOrder[0].c1_1[" + box[d.cls] + "]").check();
  if (d.cls === "llc") T("Boxes3a-b_ReadOrder[0].f1_03[0]", d.llcCode);
  if (d.cls === "other") T("Boxes3a-b_ReadOrder[0].f1_04[0]", d.otherText);
  T("f1_05[0]", d.exempt);
  T("f1_06[0]", d.fatca);
  T("Address_ReadOrder[0].f1_07[0]", d.addr);
  T("Address_ReadOrder[0].f1_08[0]", d.cityStateZip);
  T("f1_10[0]", d.acct);
  if (d.ein) { const m = d.ein.replace(/\D/g, ""); T("f1_14[0]", m.slice(0, 2)); T("f1_15[0]", m.slice(2)); }
  if (d.ssn) { const m = d.ssn.replace(/\D/g, ""); T("f1_11[0]", m.slice(0, 3)); T("f1_12[0]", m.slice(3, 5)); T("f1_13[0]", m.slice(5)); }
  const helv = await pdf.embedFont(StandardFonts.Helvetica);
  const helvI = await pdf.embedFont(StandardFonts.HelveticaOblique);
  form.updateFieldAppearances(helv);
  const page = pdf.getPages()[0];
  // Signature sits on the line above "Signature of U.S. person"; date above "Date". (PDF points, origin bottom-left.)
  if (d.sigPng) {
    const img = await pdf.embedPng(d.sigPng);
    const sb = { x: 125, y: 190, w: 245, h: 22 };
    const s = Math.min(sb.w / img.width, sb.h / img.height);
    page.drawImage(img, { x: sb.x, y: sb.y, width: img.width * s, height: img.height * s });
  } else if (d.sigText) {
    page.drawText(d.sigText, { x: 127, y: 194, size: 15, font: helvI, color: rgb(0.05, 0.05, 0.25) });
  }
  if (d.date) page.drawText(d.date, { x: 412, y: 196, size: 11, font: helv, color: rgb(0, 0, 0) });
  form.flatten();
  return await pdf.save();
}
if (typeof module !== "undefined") module.exports = { fillW9 };
