// Usage: node scripts/add-std-nav.js <page.html> [more pages...]
// Inserts the standard SelassieFest main nav (copied verbatim from /about/index.html) right after <body>,
// with a self-contained, non-sticky style block so it works on pages with their own CSS.
// Idempotent: pages that already have <nav class="main-nav"> are skipped.
const fs = require('fs');
const re = /<nav class="main-nav"[\s\S]*?<\/nav>/;
const nav = fs.readFileSync('about/index.html', 'utf8').match(re)[0];
const css = `<style id="sf-std-nav-css">
body > nav.main-nav{background:#0a0a0a;padding:12px 24px;border-bottom:1px solid rgba(255,255,255,.08);position:static;display:block;margin:0;font-family:'Jost',system-ui,sans-serif}
body > nav.main-nav ul.nav-links{display:flex;flex-wrap:wrap;justify-content:center;gap:1.25rem;list-style:none;max-width:1400px;margin:0 auto;padding:0}
body > nav.main-nav ul.nav-links li{display:list-item;margin:0;padding:0}
body > nav.main-nav ul.nav-links li a{font-weight:400;font-size:.85rem;text-transform:uppercase;letter-spacing:.1em;color:#ddd;text-decoration:none;padding:6px 0;border-bottom:2px solid transparent;background:none;transition:.2s}
body > nav.main-nav ul.nav-links li a:hover{color:#E5A93C;border-bottom-color:#E5A93C}
@media (max-width:780px){body > nav.main-nav ul.nav-links{gap:.8rem}body > nav.main-nav ul.nav-links li a{font-size:.7rem}}
</style>
`;
for (const f of process.argv.slice(2)) {
  let h = fs.readFileSync(f, 'utf8');
  if (re.test(h)) { console.log('skip (has nav):', f); continue; }
  const m = h.match(/<body[^>]*>/);
  if (!m) { console.log('NO <body>:', f); continue; }
  const crlf = h.includes('\r\n');
  let ins = '\n' + css + nav + '\n';
  if (crlf) ins = ins.replace(/\n/g, '\r\n');
  h = h.replace(m[0], m[0] + ins);
  fs.writeFileSync(f, h);
  console.log('added:', f);
}
