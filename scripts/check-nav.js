// Usage: node scripts/check-nav.js   (run from repo root, before pushing)
// Lists every page whose <nav class="main-nav"> differs from the canonical SelassieFest nav (taken from /about/index.html).
// Skips sub-sites that intentionally have their own nav.
const fs = require('fs'), path = require('path');
const root = process.cwd();
const skip = /^(Claude outputs|node_modules|\.git|SelassieFest-|JamaicaVillageGH|ventures|BIOS102|dj-lab|legal|clrwf|pickney-time|sponsors\/manateerecords)/;
const re = /<nav class="main-nav"[\s\S]*?<\/nav>/;
const norm = s => s.replace(/\s+/g, ' ').replace(/ class="active"| aria-current="page"/g, '');
const canon = norm(fs.readFileSync('about/index.html', 'utf8').match(re)[0]);
let checked = 0; const bad = [];
(function walk(d) {
  for (const e of fs.readdirSync(d, { withFileTypes: true })) {
    const p = path.join(d, e.name), rel = path.relative(root, p).split(path.sep).join('/');
    if (e.isDirectory()) { if (!skip.test(rel)) walk(p); continue; }
    if (!e.name.endsWith('.html') || skip.test(rel)) continue;
    const m = fs.readFileSync(p, 'utf8').match(re);
    if (!m) continue;
    checked++;
    if (norm(m[0]) !== canon) bad.push(rel);
  }
})(root);
console.log(`Checked ${checked} pages with a main-nav.`);
if (bad.length) { console.log('DIFFERENT from canonical nav:\n  ' + bad.join('\n  ')); process.exit(1); }
console.log('All identical.');
