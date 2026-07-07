# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A plain static HTML/CSS/JS site for SelassieFest (a roots reggae & cultural festival, run by Ras Tafari Inc, a 501c3). There is no build system, no package manager, and no server-side rendering — every page is a hand-authored, self-contained `.html` file, typically with its CSS inlined in a `<style>` block in the `<head>`. There is nothing to `npm install`, build, lint, or test in the traditional sense.

## Working on the site

- **Preview changes**: open the HTML file directly in a browser, or serve the repo root with any static file server (e.g. `python -m http.server`). No dev server is configured.
- **Deployment**: GitHub Actions (`.github/workflows/pages.yml`) deploys the entire repo root as-is to GitHub Pages on every push to `main` (or via manual `workflow_dispatch`). There is no build step in CI — whatever is committed is what ships. The custom domain (`selassiefest.com`) is set via `CNAME`.
- **Links are root-absolute**: internal navigation uses paths like `/festival/`, `/tickets/`, `/JamaicaVillageGH/about/history.html` — not relative paths. Preserve this convention when adding links so they resolve correctly both locally under Pages and on the custom domain.
- **No shared includes/templating**: header, nav, and footer markup is duplicated verbatim across every page in the main site rather than pulled from a partial/include. When changing global nav or footer content, you generally need to update it in every page that has it (grep for the markup, e.g. `<nav class="main-nav">`, across `*.html`). Watch for nav "drift" — different pages can accumulate slightly different copies of the same nav over time (see `repair-9.ps1` for a past example of consolidating divergent copies back to one canonical version).
- **Images**: pages reference local images via root-absolute `<img src="/...">`. When adding images, verify the file actually exists on disk at that path — broken image links are a known recurring issue on this site. A fallback placeholder exists at `/assets/images/placeholder.svg`.
- **Sitemap/robots**: `sitemap.xml` and `robots.txt` are maintained by hand at the repo root and should be updated when pages are added or removed.

## Repo structure

- **Root site** (`/`, `/about`, `/festival`, `/tickets`, `/main-stage`, `/marketplace`, `/sponsors`, `/organization`, etc.) — the primary SelassieFest site. `index.html` is the canonical example of the page structure/CSS variables (dark theme, `--roots-green` / `--gold-accent` / `--red-accent` custom properties, Jost font, Font Awesome via CDN).
- **`assets/`** — shared images, PDFs, video, and `js/site.js` (currently a near-empty stub reserved for a future "heritage archive" feature) used by the root site.
- **Chapter microsites** (`SelassieFest-Ghana/`, `SelassieFest-Jamaica/`, `SelassieFest-NewYork/`, `SelassieFest-Global/`) — regional variants of the festival site, each with its own `css/`, `js/`, and `img/` directories mirroring the root site's section layout (`about`, `festival`, `main-stage`, `marketplace`, etc.). Each (except Global) has a `chapter.config.js` (`window.CHAPTER_CONFIG`) defining that chapter's name, city, brand colors, festival date, contact email, and social links — read/update this when a chapter's branding or basic info changes rather than hunting through markup.
- **`JamaicaVillageGH/`** — a distinct sub-project (an investment/education hub, not a festival chapter) with its own `assets/css/styles.css` and `assets/js/scripts.js`, and sections for `about`, `contact`, `invest`, `lessons`, `media`. Its nav is meant to be canonical/identical across all its pages.
- **`ventures/`** — separate business ventures info (e.g. `ventures/restaurant`, `ventures/6227-prairie`), including a `history/artifacts/` area with poster images.

## History/maintenance notes

- The repo has previously used one-off PowerShell repair scripts run from the repo root (see `repair-9.ps1`) to bulk-fix cross-cutting issues sitewide: repointing dead links, swapping missing `<img>` targets to the placeholder SVG, and syncing divergent nav copies to one canonical version. If asked to do sitewide cleanup of this kind, a similar scripted, idempotent approach (scan all `*.html`, report counts, rewrite in place) is the established pattern here — prefer it over manually editing dozens of files by hand.
