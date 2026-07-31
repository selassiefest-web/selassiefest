// Regenerates assets/data/search-index.json, the data file the sitewide
// search (assets/js/site-search.js) and the calendar's games-archive search
// (calendar/index.html) both fetch at runtime. Re-run this (`node
// generate-search-index.mjs` from the repo root) whenever pages are added,
// removed, or have their <title>/<meta description>/<h1> changed, then
// commit the updated JSON -- there's no build step, so nothing does this
// automatically.
import fs from 'fs';
import path from 'path';

const ROOT = process.cwd();

const IN_SCOPE_DIRS = [
  'about', 'festival', 'sound-system-yard', 'main-stage', 'higher-learning-roots',
  'ital-marketplace', 'reasoning-circle', 'healing-grove', 'heritage-village',
  'marketplace', 'tickets', 'contact', 'calendar', 'silent-auction', 'donate', 'legal',
  'media', 'sponsors', 'youth-village', 'scholarship', 'pickney-time', 'founding-partners',
];

const SECTION_LABELS = {
  about: 'About', festival: 'Festival', 'sound-system-yard': 'Sound System Yard',
  'main-stage': 'Main Stage', 'higher-learning-roots': 'Higher Learning Roots',
  'ital-marketplace': 'Ital Marketplace', 'reasoning-circle': 'Reasoning Circle',
  'healing-grove': 'Healing Grove', 'heritage-village': 'Heritage Village',
  marketplace: 'Marketplace', tickets: 'Tickets', contact: 'Contact',
  calendar: 'Calendar', 'silent-auction': 'Silent Auction', donate: 'Donate', legal: 'Legal',
  media: 'Media', sponsors: 'Sponsors', 'youth-village': 'Youth Village',
  scholarship: 'Scholarship', 'pickney-time': 'Pickney Time',
  'founding-partners': 'Founding Partners', '.': 'Home',
};

function walk(dir, exclude) {
  let results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (exclude(full)) continue;
    if (entry.isDirectory()) {
      results = results.concat(walk(full, exclude));
    } else if (entry.name.endsWith('.html')) {
      results.push(full);
    }
  }
  return results;
}

function toUrlPath(filePath) {
  return '/' + filePath.split(path.sep).join('/');
}

function decodeEntities(s) {
  return s
    .replace(/&amp;/g, '&')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>');
}

let files = [];
for (const dir of IN_SCOPE_DIRS) {
  const full = path.join(ROOT, dir);
  if (!fs.existsSync(full)) continue;
  files = files.concat(
    walk(full, (f) => toUrlPath(path.relative(ROOT, f)).startsWith('/calendar/promotions/'))
  );
}
if (fs.existsSync(path.join(ROOT, 'index.html'))) files.push(path.join(ROOT, 'index.html'));

const index = [];
let missingTitle = 0;

for (const file of files) {
  const content = fs.readFileSync(file, 'utf8');
  const titleMatch = content.match(/<title>([^<]*)<\/title>/i);
  if (!titleMatch) { missingTitle++; continue; }
  const title = decodeEntities(titleMatch[1].trim());

  const descMatch = content.match(/<meta\s+name=["']description["']\s+content=(["'])([\s\S]*?)\1\s*\/?>/i);
  let description = descMatch ? decodeEntities(descMatch[2].trim()) : '';

  const h1Match = content.match(/<h1[^>]*>([\s\S]*?)<\/h1>/i);
  const heading = h1Match ? decodeEntities(h1Match[1].replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim()) : '';

  const urlPath = toUrlPath(path.relative(ROOT, file));
  const relParts = path.relative(ROOT, file).split(path.sep);
  const topDir = relParts.length > 1 ? relParts[0] : '.';
  const section = SECTION_LABELS[topDir] || topDir;

  index.push({ title, description, heading, section, url: urlPath });
}

fs.writeFileSync(
  path.join(ROOT, 'assets', 'data', 'search-index.json'),
  JSON.stringify(index),
  'utf8'
);

console.log(`Indexed ${index.length} pages (skipped ${missingTitle} with no <title>)`);
