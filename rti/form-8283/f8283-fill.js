// Adds the donee's Part V "Donee Acknowledgment" to IRS Form 8283 (Rev. 12-2025) in the browser with pdf-lib 1.17.1.
// Works on the blank form.pdf or on a donor's already-filled 8283. Nothing is sent anywhere.
// d = { dateReceived, unrelatedUse: "yes"|"no", name, ein, addr, cityStateZip, title, date, sigPng: Uint8Array|null, sigText: string|null }
async function fillF8283(PDFLib, bytes, d) {
  const { PDFDocument, StandardFonts, rgb } = PDFLib;
  const pdf = await PDFDocument.load(bytes, { ignoreEncryption: true });
  const form = pdf.getForm();
  const P = "Form8283[0].Page2[0].";
  const T = (n, v) => { if (v == null || v === "") return; form.getTextField(P + n).setText(String(v)); };
  T("f2_18[0]", d.dateReceived);
  T("f2_19[0]", d.name);
  T("f2_20[0]", d.ein);
  T("f2_21[0]", d.addr);
  T("f2_22[0]", d.cityStateZip);
  T("f2_23[0]", d.title);
  form.getCheckBox(P + "c2_4[" + (d.unrelatedUse === "yes" ? 0 : 1) + "]").check();
  const helv = await pdf.embedFont(StandardFonts.Helvetica);
  const helvI = await pdf.embedFont(StandardFonts.HelveticaOblique);
  form.updateFieldAppearances(helv);
  const page = pdf.getPages()[1];
  // The authorized signature line is bottom-left of page 2 (no field there); the date has no field either.
  if (d.sigPng) {
    const img = await pdf.embedPng(d.sigPng);
    const sb = { x: 40, y: 37, w: 240, h: 16 };
    const s = Math.min(sb.w / img.width, sb.h / img.height);
    page.drawImage(img, { x: sb.x, y: sb.y, width: img.width * s, height: img.height * s });
  } else if (d.sigText) {
    page.drawText(d.sigText, { x: 42, y: 38, size: 12, font: helvI, color: rgb(0.05, 0.05, 0.25) });
  }
  if (d.date) page.drawText(d.date, { x: 466, y: 40, size: 10, font: helv, color: rgb(0, 0, 0) });
  return await pdf.save();
}
if (typeof module !== "undefined") module.exports = { fillF8283 };
