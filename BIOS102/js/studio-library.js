// BIOS102 Research-to-Grant Studio: the reference library engine (our own "Zotero"): items, collections, tags,
// duplicate finding, BibTeX / RIS / CSV import and export, citation keys, and the OpenAlex retrieval calls.
// Pure functions where possible so they can be tested in Node. Standard features follow Zotero (the free
// general-purpose standard): collections, tags, notes, duplicate merge, import/export, cite-by-key.
(function (root) {
  'use strict';
  const OA = 'https://api.openalex.org';
  const PARKSIDE = 'I183437572';
  const SEL = 'id,doi,title,publication_year,authorships,primary_location,cited_by_count,abstract_inverted_index,related_works,referenced_works,type,open_access';
  const COLLECTIONS = [['pi', 'The PI’s papers'], ['related', 'Related work (ongoing)'], ['background', 'Background'], ['methods', 'Methods and statistics'], ['mine', 'Unsorted']];

  const strip = (s) => String(s || '').normalize('NFD').replace(/[̀-ͯ]/g, '');
  const normTitle = (t) => strip(t).toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
  const cleanDoi = (d) => String(d || '').trim().replace(/^https?:\/\/(dx\.)?doi\.org\//i, '').replace(/^doi:\s*/i, '').replace(/[.,;)\s]+$/, '').toLowerCase();
  const lastName = (a) => { const t = String(a || '').trim(); if (t.indexOf(',') > 0) return t.split(',')[0].trim(); return t.split(/[\s‐-―]+/).pop() || t; };
  const makeKey = (used, authors, year) => { const base = (strip(lastName((authors || [])[0] || 'anon')).toLowerCase().replace(/[^a-z]/g, '') || 'anon') + (year || ''); let k = base, n = 0; while (used.indexOf(k) >= 0) k = base + String.fromCharCode(97 + (n++ % 26)) + (n > 26 ? n : ''); return k; };
  const citeLabel = (it) => { if (!it) return '?'; const a = it.authors || []; const l = a.map(lastName); const who = !l.length ? 'Anon.' : l.length === 1 ? l[0] : l.length === 2 ? l[0] + ' and ' + l[1] : l[0] + ' et al.'; return who + ' ' + (it.year || 'n.d.'); };

  function decodeAbstract(idx) { if (!idx) return ''; const a = []; Object.keys(idx).forEach((w) => idx[w].forEach((p) => { a[p] = w; })); return a.join(' '); }
  function fromOpenAlex(w, coll, st) {
    const used = st.items.map((i) => i.key);
    const authors = (w.authorships || []).map((a) => a.author.display_name);
    const it = { id: 'L' + Date.now().toString(36) + Math.floor(Math.random() * 1e4).toString(36), title: String(w.title || '').replace(/\s+/g, ' ').trim(), authors, year: w.publication_year, journal: (w.primary_location && w.primary_location.source && w.primary_location.source.display_name) || '', doi: cleanDoi(w.doi), type: w.type || 'article', abstract: decodeAbstract(w.abstract_inverted_index), coll: coll || 'mine', oa: String(w.id || '').split('/').pop(), cited: w.cited_by_count || 0, tags: [], notes: '', read: 'unread', origin: 'openalex', oaUrl: (w.open_access && w.open_access.oa_url) || '', related: (w.related_works || []).slice(0, 12).map((x) => x.split('/').pop()) };
    it.key = makeKey(used, authors, it.year); return it;
  }
  const findDup = (st, it) => st.items.find((x) => (it.doi && x.doi === it.doi) || (it.oa && x.oa === it.oa) || (normTitle(x.title) && normTitle(x.title) === normTitle(it.title)));
  function dupes(items) {
    const seen = new Set(); const out = [];
    items.forEach((a, i) => { if (seen.has(a)) return; const g = [a]; for (let j = i + 1; j < items.length; j++) { const b = items[j]; if (seen.has(b)) continue; if ((a.doi && a.doi === b.doi) || (normTitle(a.title) && normTitle(a.title) === normTitle(b.title))) { g.push(b); seen.add(b); } } if (g.length > 1) { seen.add(a); out.push(g); } });
    return out;
  }
  function merge(st, keepId, dropId) {
    const a = st.items.find((x) => x.id === keepId), b = st.items.find((x) => x.id === dropId); if (!a || !b || a === b) return;
    a.tags = Array.from(new Set((a.tags || []).concat(b.tags || []))); a.notes = [a.notes, b.notes].filter(Boolean).join('\n'); ['abstract', 'doi', 'journal'].forEach((f) => { if (!a[f] && b[f]) a[f] = b[f]; });
    (st.evidence || []).forEach((e) => { if (e.item === dropId) e.item = keepId; }); if (st.analysis && st.analysis[dropId] && !st.analysis[keepId]) st.analysis[keepId] = st.analysis[dropId];
    delete (st.analysis || {})[dropId]; st.items.splice(st.items.indexOf(b), 1);
  }

  // ---- export ----
  const bibEsc = (s) => String(s || '').replace(/[{}]/g, '').replace(/\s+/g, ' ');
  const toBibtex = (items) => items.map((i) => '@' + (i.type === 'book-chapter' ? 'incollection' : i.type === 'preprint' ? 'misc' : i.type === 'dataset' ? 'misc' : 'article') + '{' + i.key + ',\n  title = {' + bibEsc(i.title) + '},\n  author = {' + (i.authors || []).map(bibEsc).join(' and ') + '},\n  year = {' + (i.year || '') + '},\n  journal = {' + bibEsc(i.journal) + '},\n  doi = {' + (i.doi || '') + '}\n}').join('\n\n');
  const toRis = (items) => items.map((i) => ['TY  - ' + (i.type === 'preprint' ? 'UNPB' : i.type === 'dataset' ? 'DATA' : i.type === 'book-chapter' ? 'CHAP' : 'JOUR'), 'TI  - ' + i.title].concat((i.authors || []).map((a) => 'AU  - ' + a), ['PY  - ' + (i.year || ''), 'JO  - ' + (i.journal || ''), 'DO  - ' + (i.doi || ''), 'AB  - ' + (i.abstract || ''), 'ER  - ']).join('\n')).join('\n\n');
  const csvEsc = (v) => '"' + String(v == null ? '' : v).replace(/"/g, '""') + '"';
  const toCsv = (items) => ['key,title,authors,year,journal,doi,collection,tags,read,notes'].concat(items.map((i) => [i.key, i.title, (i.authors || []).join('; '), i.year, i.journal, i.doi, i.coll, (i.tags || []).join('; '), i.read, i.notes].map(csvEsc).join(','))).join('\n');
  const apa = (i) => { const a = i.authors || []; const names = a.slice(0, 6).map((n) => { const p = String(n).trim().split(/\s+/); const last = p.pop(); return last + ', ' + p.map((x) => x[0] + '.').join(' '); }); return names.join(', ') + (a.length > 6 ? ', et al.' : '') + ' (' + (i.year || 'n.d.') + '). ' + i.title + '. ' + (i.journal ? i.journal + '. ' : '') + (i.doi ? 'https://doi.org/' + i.doi : ''); };
  const toText = (items) => items.map(apa).join('\n\n');

  // ---- import ----
  function parseBibtex(txt) {
    const out = []; const re = /@(\w+)\s*\{\s*([^,\s]*)\s*,([\s\S]*?)\n\}/g; let m;
    const field = (body, name) => { const r = new RegExp(name + '\\s*=\\s*(\\{([^]*?)\\}|"([^"]*)")\\s*,?\\s*(?:\\n|$)', 'i').exec(body); return r ? (r[2] != null ? r[2] : r[3]).replace(/\s+/g, ' ').trim() : ''; };
    while ((m = re.exec(txt))) { const b = m[3]; out.push({ title: field(b, 'title'), authors: field(b, 'author').split(/\s+and\s+/i).map((a) => a.trim()).filter(Boolean), year: parseInt(field(b, 'year'), 10) || '', journal: field(b, 'journal') || field(b, 'booktitle'), doi: cleanDoi(field(b, 'doi')), type: 'article' }); }
    return out;
  }
  function parseRis(txt) {
    const out = []; let cur = null;
    String(txt).split(/\r?\n/).forEach((ln) => { const m = /^([A-Z][A-Z0-9])\s{1,2}-\s?(.*)$/.exec(ln); if (!m) return; const t = m[1], v = m[2].trim();
      if (t === 'TY') cur = { title: '', authors: [], year: '', journal: '', doi: '', abstract: '', type: 'article' };
      else if (!cur) return; else if (t === 'TI' || t === 'T1') cur.title = v; else if (t === 'AU' || t === 'A1') cur.authors.push(v); else if (t === 'PY' || t === 'Y1') cur.year = parseInt(v, 10) || ''; else if (t === 'JO' || t === 'T2' || t === 'JF') cur.journal = cur.journal || v; else if (t === 'DO') cur.doi = cleanDoi(v); else if (t === 'AB') cur.abstract = v;
      else if (t === 'ER') { out.push(cur); cur = null; } });
    return out;
  }

  // ---- retrieval from OpenAlex (live; the page falls back to manual entry when offline) ----
  async function jget(u) { const r = await fetch(u); if (!r.ok) throw new Error('OpenAlex ' + r.status); return r.json(); }
  const retrieve = {
    piWorks: async (piOa) => (await jget(OA + '/works?filter=author.id:' + piOa + ',authorships.institutions.lineage:' + PARKSIDE + '&sort=publication_date:desc&per_page=50&select=' + SEL)).results || [],
    byName: async (name) => (await jget(OA + '/works?filter=raw_author_name.search:' + encodeURIComponent(name) + '&sort=publication_date:desc&per_page=25&select=' + SEL)).results || [],
    keyword: async (q, fromYear) => (await jget(OA + '/works?search=' + encodeURIComponent(q) + '&filter=type:article' + (fromYear ? ',from_publication_date:' + fromYear + '-01-01' : '') + '&per_page=25&select=' + SEL)).results || [],
    related: async (oaIds) => (oaIds && oaIds.length ? (await jget(OA + '/works?filter=openalex:' + oaIds.slice(0, 15).join('|') + '&per_page=15&select=' + SEL)).results : []) || [],
    citedBy: async (oa) => (await jget(OA + '/works?filter=cites:' + oa + '&sort=publication_date:desc&per_page=25&select=' + SEL)).results || [],
    references: async (oa) => { const w = await jget(OA + '/works/' + oa + '?select=referenced_works'); const ids = (w.referenced_works || []).slice(0, 25).map((x) => x.split('/').pop()); return ids.length ? (await jget(OA + '/works?filter=openalex:' + ids.join('|') + '&per_page=25&select=' + SEL)).results || [] : []; },
    byDoi: async (doi) => jget(OA + '/works/doi:' + encodeURIComponent(cleanDoi(doi)) + '?select=' + SEL),
    abstractOf: async (oa) => decodeAbstract((await jget(OA + '/works/' + oa + '?select=abstract_inverted_index')).abstract_inverted_index),
  };

  // ---- PubMed (NCBI E-utilities, free, no key) ----
  const EU = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils';
  async function pubmed(term, retmax) {
    const s1 = await jget(EU + '/esearch.fcgi?db=pubmed&retmode=json&sort=pub_date&retmax=' + (retmax || 25) + '&term=' + encodeURIComponent(term));
    const ids = (s1.esearchresult && s1.esearchresult.idlist) || []; if (!ids.length) return [];
    const sm = await jget(EU + '/esummary.fcgi?db=pubmed&retmode=json&id=' + ids.join(','));
    const abs = {}; try {
      const xml = await (await fetch(EU + '/efetch.fcgi?db=pubmed&retmode=xml&id=' + ids.join(','))).text(); const d = new DOMParser().parseFromString(xml, 'text/xml');
      Array.from(d.getElementsByTagName('PubmedArticle')).forEach((a) => { const id = (a.getElementsByTagName('PMID')[0] || {}).textContent; abs[id] = Array.from(a.getElementsByTagName('AbstractText')).map((x) => x.textContent).join(' '); });
    } catch (e) { /* abstracts are optional */ }
    return ids.map((id) => { const r = sm.result[id]; if (!r) return null; const doi = ((r.articleids || []).find((x) => x.idtype === 'doi') || {}).value || ''; return { pmid: id, title: String(r.title || '').replace(/\.$/, ''), authors: (r.authors || []).map((a) => a.name), year: parseInt(String(r.pubdate || '').slice(0, 4), 10) || '', journal: r.fulljournalname || r.source || '', doi: cleanDoi(doi), abstract: abs[id] || '' }; }).filter(Boolean);
  }
  function fromPubmed(r, coll, st) {
    const used = st.items.map((i) => i.key);
    return { id: 'L' + Date.now().toString(36) + Math.floor(Math.random() * 1e4).toString(36), key: makeKey(used, r.authors, r.year), title: r.title, authors: r.authors, year: r.year, journal: r.journal, doi: r.doi, type: 'article', abstract: r.abstract, coll: coll || 'mine', pmid: r.pmid, tags: [], notes: '', read: 'unread', origin: 'pubmed' };
  }
  const pubmedTerm = (f) => f.last + ' ' + f.first[0] + '[Author] AND (Wisconsin Parkside[Affiliation] OR Parkside[Affiliation])';

  // ---- getting the full text: open access link, then the UWP Library (links read from the library page Nov 19, 2026) ----
  const LIBRARY = { home: 'https://www.uwp.edu/learn/library/', ill: 'https://libguides.uwp.edu/c.php?g=1411066', databases: 'https://libguides.uwp.edu/az.php', account: 'https://wisconsin-uwp.primo.exlibrisgroup.com/discovery/account?vid=01UWI_PL:PARK&section=overview', askus: 'AskUs@uwp.edu', reserve: 'https://libguides.uwp.edu/Reserve' };
  function fullTextRequest(it, who) {
    const cite = apa(it) + (it.pmid ? ' PMID: ' + it.pmid : '');
    const subject = 'Full-text request: ' + String(it.title).slice(0, 90);
    const body = ['Hello,', '', 'I am a UW–Parkside biology student working on a research proposal. Could you help me get the full text of this article?', '', cite, '', 'Thank you,', who || ''].join('\n');
    return { subject, body, mailto: 'mailto:' + LIBRARY.askus + '?subject=' + encodeURIComponent(subject) + '&body=' + encodeURIComponent(body), doi: it.doi ? 'https://doi.org/' + it.doi : '', pubmed: it.pmid ? 'https://pubmed.ncbi.nlm.nih.gov/' + it.pmid + '/' : '', oa: it.oaUrl || '' };
  }

  // ---- citations inside the student's writing: [@key] ----
  const CITE_RE = /\[@([A-Za-z0-9_:-]+)\]/g;
  const keysIn = (t) => { const out = []; String(t || '').replace(CITE_RE, (m, k) => { out.push(k); return m; }); return out; };
  function textsOf(st) {
    const t = [];
    Object.keys((st.plan && st.plan.sections) || {}).forEach((k) => t.push(st.plan.sections[k]));
    ((st.plan && st.plan.experiments) || []).forEach((e) => ['design', 'materials', 'equip', 'methods', 'controls', 'replication', 'sample', 'decision'].forEach((f) => t.push(e[f])));
    ((st.proposal && st.proposal.sections) || []).forEach((s) => t.push(s.text));
    (st.gaps || []).forEach((g) => Object.keys(g.a || {}).forEach((k) => t.push(g.a[k])));
    t.push(st.justification); Object.keys(st.defense || {}).forEach((k) => t.push(st.defense[k]));
    return t;
  }
  const citedKeys = (st) => Array.from(new Set(textsOf(st).reduce((a, t) => a.concat(keysIn(t)), []).concat((st.claims || []).map((c) => c.ref).filter(Boolean))));
  const itemByKey = (st, k) => ((st.library && st.library.items) || []).find((i) => i.key === k);
  const renderCites = (htmlEscaped, st) => String(htmlEscaped).replace(CITE_RE, (m, k) => { const it = itemByKey(st, k); return it ? '(' + citeLabel(it) + ')' : '[?' + k + ']'; });
  function refList(st) {
    const keys = citedKeys(st); const out = [];
    keys.forEach((k) => { const it = itemByKey(st, k); if (it) out.push({ id: k, cite: apa(it).replace(/ https:\/\/doi\.org\/\S+$/, ''), doi: it.doi || '', fromLibrary: true }); });
    (st.refs || []).forEach((r) => { if (!out.some((o) => o.id === r.id)) out.push(r); });
    return out;
  }
  const unknownKeys = (st) => citedKeys(st).filter((k) => !itemByKey(st, k) && !(st.refs || []).some((r) => r.id === k));

  // ---- the skill of reading a result: who is the PI in this paper, and what kind of paper is it? ----
  // In biology the first author usually did the hands-on work, the LAST author is usually the senior author who
  // leads the lab and holds the funding, and everyone between contributed. A lab's own project papers therefore
  // usually carry the PI's name last (or first, in a small group). A middle position often means a collaborator.
  function rawAuthors(raw, src) { return src === 'pubmed' ? (raw.authors || []).map((n) => ({ name: String(n).replace(/^(.+)\s+([A-Z]{1,3})$/, '$2 $1'), id: '' })) : (raw.authorships || []).map((a) => ({ name: a.author.display_name, id: String(a.author.id || '').split('/').pop() })); }
  function piPosition(authors, pi) {
    const n = authors.length; if (!n || !pi) return { pos: '', n, at: -1 };
    const ini = (pi.first || '').slice(0, 1).toLowerCase(), last = strip(pi.last || '').toLowerCase();
    const at = authors.findIndex((a) => (pi.oa && a.id === pi.oa) || (strip(lastName(a.name)).toLowerCase() === last && (!ini || strip(a.name).toLowerCase().replace(/[^a-z]/g, '').indexOf(ini) >= 0 || /^[A-Za-z]{1,3}$/.test(String(a.name).trim().split(/\s+/).pop()))));
    if (at < 0) return { pos: '', n, at };
    return { pos: n === 1 ? 'only' : at === 0 ? 'first' : at === n - 1 ? 'last' : 'middle', n, at };
  }
  const POS_NOTE = { only: ['Sole author', 'cy', 'Written by the PI alone.'], last: ['Last author: senior author', 'ok', 'The PI is last: usually the senior author who leads the lab. This is very likely a project from the PI’s own lab, so it shows the lab’s research direction.'], first: ['First author: did the main work', 'ok', 'The PI is first: usually the person who did most of the work. Common in small groups and in older papers.'], middle: ['Middle author: contributor', 'warn', 'The PI is somewhere in the middle: usually a collaborator on someone else’s project. Do not assume this is the PI’s own research direction.'], '': ['PI not found in the author list', 'block', 'The PI’s name was not matched. This can mean a different person with a similar name, or a different spelling. Check the identity step before you use this paper.'] };
  function kindOf(p) {
    const t = String(p.title || ''), ty = String(p.type || ''), j = String(p.journal || '');
    if (/^abstract\s*[\w-]*\d+/i.test(t) || /meeting abstract|supplement/i.test(j + ' ' + t)) return { key: 'abstract', label: 'Conference abstract', cls: 'warn', note: 'A one-paragraph summary of a poster or talk, not a full paper. It has little detail and is not a full peer-reviewed article. Look for the full paper by the same group.' };
    if (ty === 'preprint' || /biorxiv|medrxiv|arxiv|research square|preprint|ssrn|zenodo/i.test(j)) return { key: 'preprint', label: 'Preprint', cls: 'warn', note: 'Posted before peer review. Useful and recent, but not yet checked by other scientists. Say so if you cite it.' };
    if (ty === 'dataset' || /dryad|figshare/i.test(j)) return { key: 'dataset', label: 'Dataset', cls: 'cy', note: 'Data you may be able to reuse. Read the README before you plan around it.' };
    if (ty === 'review') return { key: 'review', label: 'Review article', cls: 'cy', note: 'Summarises many studies. Great for background; the gaps it lists are a good place to look.' };
    if (ty === 'book-chapter') return { key: 'chapter', label: 'Book chapter', cls: 'cy', note: 'Often a summary written for a book.' };
    return { key: 'article', label: 'Research article', cls: 'ok', note: 'A full paper in a journal.' };
  }
  const SCREEN_REASONS = ['Not about the PI’s current research direction', 'PI is only a minor contributor', 'Conference abstract only (too little detail)', 'Preprint (not yet peer reviewed)', 'Too old for the question I am asking', 'Different organism or system', 'Different method, not useful for my design', 'Already have it (duplicate)', 'Other (write it in the notes)'];

  const api = { rawAuthors, piPosition, POS_NOTE, kindOf, SCREEN_REASONS, OA, PARKSIDE, COLLECTIONS, normTitle, cleanDoi, lastName, makeKey, citeLabel, decodeAbstract, fromOpenAlex, findDup, dupes, merge, toBibtex, toRis, toCsv, toText, apa, parseBibtex, parseRis, retrieve, pubmed, fromPubmed, pubmedTerm, LIBRARY, fullTextRequest, CITE_RE, keysIn, citedKeys, itemByKey, renderCites, refList, unknownKeys, textsOf };
  root.StudioLib = api;
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
})(typeof window !== 'undefined' ? window : globalThis);
