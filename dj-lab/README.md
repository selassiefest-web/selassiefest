# Rainbow DJ Lab (`/dj-lab/`)

This folder holds everything for the **Rainbow DJ Lab**, the free DJ-class program proposed by Ras Tafari Inc. as part of Full Spectrum at Rainbow Beach. It includes:

1. **The family site.** Plain-language pages for parents, kids, coaches and park officials covering safety, privacy, governance and how the Lab works.
2. **The live class app** (`/dj-lab/live/`). The shared classroom screen that runs a 90-minute session, with the station board, check-ins and Passport stamps. See [`live/README.md`](live/README.md).
3. **The portal** (`/dj-lab/portal/`). Entry pages for families, coaches and kids, plus the sign-out log. See [`portal/README.md`](portal/README.md).

The Lab is **proposed**. It does not have Chicago Park District approval, no class dates are set, and no staff are hired. Every page must agree with the single source of truth, [`/rainbow-wednesdays/development/DJLAB_FACTS.md`](../rainbow-wednesdays/development/DJLAB_FACTS.md). If a fact isn't there and can't be verified from an official source, don't add it.

## Structure

```
dj-lab/
  _build/build.py          converts the .md pages below into .html
  governance/              launch checklist, board, policies, agreements, reports
  safety/                  safety overview, staff screening, incidents, grievances, report a concern
  privacy/                 privacy policy
  families/                parent and kid information
  about/                   about the Lab, community accountability
  live/                    the live class app
  portal/                  family / coach / kid / sign-out entry pages
  README.md, LICENSE, CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md   repo docs (not published as pages)
```

The backend for the live app is in the main repo at `supabase/dj-lab.sql` (tables and functions) and `supabase/functions/djlab-send-recaps/` (recap emails).

## How pages are built

Content pages are written in Markdown. Each one starts with front matter:

```
---
title: Page title
description: One sentence.
---
```

`dj-lab/_build/build.py` turns each `.md` page into an `.html` file next to it (for example, `governance/index.md` becomes `governance/index.html`). The site is static, so **the generated `.html` files must be committed.** Nothing is built in CI.

Repo docs (this README and the other uppercase files) have no front matter and are not turned into pages.

## Updating content

1. Edit the `.md` file, not the generated `.html`. Your changes to `.html` will be overwritten on the next build.
2. Check every fact against `DJLAB_FACTS.md`. Never write "approved," "licensed," "certified program," "insured," "permitted" or "guaranteed" about anything not yet done.
3. Use root-absolute links ending in `.html`, for example `/dj-lab/governance/index.html`.
4. Run the build from the repo root:
   ```
   python dj-lab/_build/build.py
   ```
5. Open the generated page in a browser (or serve the repo root with `python -m http.server`) and check it.
6. Commit both the `.md` and the `.html`.

When a launch requirement is completed, update its row on `governance/index.md` with the date and the evidence link, and update the matching status page.

Changes to safety content need the President's review. See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Deployment

This folder deploys with the main **selassiefest.com** site. GitHub Actions (`.github/workflows/pages.yml`) publishes the whole repository to GitHub Pages on every push to `main`. Whatever is committed is what goes live, at `https://selassiefest.com/dj-lab/`.

## Contact

Stephen Henry, President, Ras Tafari Inc.: stephen@selassiefest.com, 414-909-3279.
