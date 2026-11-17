// Signs Serato's "Student Data and Mandatory Set Up Guidelines Policy" (3-page PDF, signature block on page 2).
// The block is four short rules with the label below each: institution (y 379), signature (y 272), name (y 192), date (y 112).
// pdf-lib 1.17.1, runs in the browser or node. Nothing is sent anywhere.
// d = { institution, name, date, sigPng: Uint8Array|null, sigText: string|null }
async function signStudentPolicy(PDFLib, bytes, d) {
  const { PDFDocument, StandardFonts, rgb } = PDFLib;
  const pdf = await PDFDocument.load(bytes, { ignoreEncryption: true });
  if (pdf.getPageCount() < 2) throw new Error("that does not look like Serato's Student Data Policy (it should be 3 pages)");
  const page = pdf.getPages()[1];
  const helv = await pdf.embedFont(StandardFonts.Helvetica);
  const ital = await pdf.embedFont(StandardFonts.HelveticaOblique);
  const ink = rgb(0.03, 0.03, 0.2);
  const X = 64;
  page.drawText(d.institution, { x: X, y: 383, size: 10.5, font: helv, color: ink });
  if (d.sigPng) {
    const img = await pdf.embedPng(d.sigPng);
    const s = Math.min(150 / img.width, 36 / img.height);
    page.drawImage(img, { x: X, y: 275, width: img.width * s, height: img.height * s });
  } else if (d.sigText) {
    page.drawText(d.sigText, { x: X, y: 277, size: 16, font: ital, color: ink });
  }
  page.drawText(d.name, { x: X, y: 195, size: 10.5, font: helv, color: ink });
  page.drawText(d.date, { x: X, y: 115, size: 10.5, font: helv, color: ink });
  return await pdf.save();
}
if (typeof module !== "undefined") module.exports = { signStudentPolicy };
