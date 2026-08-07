# Handoff: Bongo Beach PAC Presentation Architecture — for whoever builds the live site

This folder is a working static-site prototype of a "presentation architecture tied
to authority" — a searchable, clickable system that gives every audience in the
63rd Street Bongo Beach Park Advisory Council (BBPAC) recognition campaign its own
tailored presentation, all generated from one master case so facts never drift out
of sync between decks. It's meant to be handed to a developer (or to Claude Code) to
harden into the final live implementation.

## Important context before you touch anything

**This content has nothing to do with Selassiefest.** It is a completely separate
campaign — a push to get the Chicago Park District to recognize 63rd Street Beach
as a distinct park/administrative unit so it can have its own Park Advisory Council.
It is being delivered through the same Cowork session that otherwise supports
Selassiefest's site work, and the person who requested it said it would be hosted
on `selassiefest.com` — presumably as a separate section/subdomain/path unrelated to
festival content, not integrated into festival pages. **Confirm with whoever owns
the deployment where this should actually live** (a subdirectory, a subdomain, or
a wholly separate repo) before wiring it into any existing GitHub Pages workflow.
Nothing in this system should be linked from Selassiefest's festival navigation.

**The content itself needs a legal and factual review before it goes live or is
sent to anyone at the Chicago Park District, a Board member, or an Alderman's
office.** See `sources.html` and `evidence-status.html` in this system — they are
not boilerplate, they are load-bearing. Read them before you ship this.

## What this is, architecturally

One master case ("the Global Presentation") plus 16 tailored derivative
presentations, a shared Precedent Library, a Stakeholder/Authority Routing Matrix,
and an Evidence/Verification dashboard — all static HTML/CSS/vanilla JS, no build
step, no framework, no server. It is designed to drop into a GitHub Pages–style
deployment as-is.

```
index.html                      System overview / entry point
matrix.html                     Stakeholder & Authority Routing Matrix (searchable table)
precedents.html                 Shared Precedent Library (every "has CPD done this before" argument)
evidence-status.html            Evidence & Verification Status dashboard
sources.html                    Methodology, honesty disclosures, what needs legal review
global/
  master-presentation.html      The 20-section master case + FAQ — everything else derives from this
departments/                    7 CPD department decks (lca, planning, law, operations,
                                 natural-resources-aquatics, facilities-revenue, budget)
decision-makers/                4 decision-maker decks (superintendent, board-of-commissioners,
                                 alderman-yancy, mayor-city-council)
partners/                       4 partner/peer-org decks (jpac, south-shore-cca,
                                 friends-of-the-parks, chicago-parks-foundation)
community/                      1 plain-language public deck
assets/
  css/style.css                 The ONLY stylesheet — everything shares it
  js/nav.js                     Single source of truth for site nav — edit here to add a page
  js/search.js                  Client-side full-text search over assets/data/search-index.json
  js/matrix.js                  Renders matrix.html from assets/data/matrix.json
  js/precedents.js              Renders precedents.html from assets/data/precedents.json
  js/evidence-status.js         Renders evidence-status.html from assets/data/evidence.json
  data/matrix.json               35-row stakeholder matrix — single source of truth
  data/precedents.json           Precedent Library content + verification statuses
  data/evidence.json             Gate 0 dossier checklist + verification statuses
  data/search-index.json         Generated search index (see "Regenerating" below)
```

## Design discipline to preserve

Every deck **links into** the Precedent Library and Evidence/Verification pages
rather than repeating their content. If you add a new department/decision-maker
deck later, follow the same rule: one fact, one place, everything else links to it.
Breaking this discipline is how a 24-page site quietly starts contradicting itself.

Every page follows the same shell: `<div id="site-nav"></div>` near the top of
`<body>`, `<footer id="site-footer"></footer>` near the bottom, and two script tags
(`nav.js`, `search.js`) at the end. `<html data-root="..." data-page="...">`
controls relative pathing and nav "active" highlighting — see the comment block at
the top of `assets/js/nav.js` for exact instructions on adding a new page.

## Data model quick reference

- **`matrix.json`** — one object per stakeholder: `name`, `department`,
  `organization`, `tier`, `authority` (D/R/T/G/C/A/S/P — see the legend on
  `matrix.html`), `interest`, `infoNeeded`, `infoNotNeeded`, `ask`, `approachedBy`,
  `presentationHref`, `presentationLabel`, `followUp`, `status`.
- **`precedents.json`** — `bucketA` (park-reorganization precedents), `bucketB`
  (beach-as-independent-park precedents), `voidedProperties`, and `paperTrail` (the
  7-question park-number research program). Each precedent item has `id` (used as
  the HTML anchor), `rating` (1–5), `whatHappened`, `whyItMatters`,
  `verificationStatus` (`confirmed`/`partial`/`pending`), `verificationNote`.
- **`evidence.json`** — flat array of dossier/campaign items with `item`,
  `category`, `status` (`confirmed`/`partial`/`pending`), `owner`, `next`.

Edit the JSON, reload the page — no rebuild needed. This is intentional so
non-technical staff can update status/content without touching HTML or JS.

## Regenerating the search index

`assets/data/search-index.json` is generated, not hand-written. It was built by a
one-off Python script that walks every `.html` file, extracts each `<h2>` section
and each FAQ `<summary>`/`<div class="faq-answer">` pair, and writes them out as
flat `{title, page, href, text}` records. That script was NOT included in this
delivery (it lived outside the deployed site). If content changes meaningfully,
either recreate an equivalent script (straightforward — see the shape of the
existing JSON for the target format) or wire index generation into whatever build
step you introduce. Until then, the existing index will drift slightly out of date
as pages are edited, but nothing will break — search will just miss newer content.

## Verified vs. QA'd — what's actually been checked

- All internal links resolve to real files (checked programmatically).
- No unbalanced `<div>`/`<details>` tags in any page (checked programmatically).
- All 22 pages load with zero browser console errors (checked with headless
  Chromium/Playwright).
- The stakeholder matrix's search/filter/sort, the precedent library's anchor deep
  links, the evidence dashboard's live counts, and the site-wide search all work
  end-to-end (checked with headless Chromium/Playwright).
- No horizontal overflow on a 390px-wide mobile viewport on any of the 22 pages
  (checked with headless Chromium/Playwright, fixed twice during QA — nav wrapping
  and table overflow).

What has **not** been checked: real-device testing, screen-reader testing beyond
basic semantic HTML (skip link, `<details>`/`<summary>` for FAQs, alt text — there
are no images to caption), cross-browser testing beyond Chromium, or load testing
(irrelevant at this content size, but worth a mention).

## Deployment notes

- Pure static files — works unmodified on GitHub Pages, Netlify, S3, or any static
  host. No environment variables, no server-side code, no database.
- If this ends up in the same repo as the Selassiefest site, put it in its own
  top-level directory (e.g. `/bbpac/`) so GitHub Pages serves it at
  `selassiefest.com/bbpac/` without touching the festival's existing pages or
  workflow. Do not merge its nav into the festival site's nav.
- If GitHub Pages Actions build step already exists for the festival
  (`.github/workflows/pages.yml`), this folder needs zero changes to that workflow
  — it's just more static files to publish.
- No dependency installs, no `node_modules`, no `package.json` — nothing to break
  a "no build system" policy.

## What's genuinely unfinished (do not silently ship over these)

See `evidence-status.html` for the live, itemized version of this list. In short:
the Conditions & Neglect Dossier, the Representation Gap Analysis, the Community
Support Petition, Organizational Endorsements, Elected-Official Support Letters,
Founders & Leadership Roster, Draft BBPAC Bylaws, and the actual FOIA filings have
**not** been produced — they're tracked as open items, not finished deliverables.
Treat the "Drafted — pending legal & fact review" status on every deck in
`matrix.json` literally: nothing here should go to an external recipient without
that review happening first.
