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
- **`JamaicaVillageGH/`** — see `JamaicaVillageGH/CLAUDE.md`.
- **`ventures/`** — see `ventures/history/CLAUDE.md`.
- **Supabase backend** (`assets/js/supabase-client.js`, `supabase/schema.sql`, `supabase/functions/`) — despite being a static site, dynamic bits (forms, auction/donation entries, live-edited proposal pages, restaurant outreach) are backed by a real Supabase project via the public anon key. Convention: a locked-down base table (RLS enabled, no anon policies) holds anything sensitive, paired with a `*_public` view exposing only safe columns to anon; anything the public submits goes into a write-only table (anon can insert, never select) whose `AFTER INSERT` trigger calls the shared `notify_submission_webhook()` function to email staff via the `notify-submission` Edge Function. That trigger function embeds a secret and is deliberately not committed to `schema.sql` — new tables just add a trigger referencing it, plus a formatter in `notify-submission/index.ts`. `schema.sql` is a hand-maintained full-schema reference (no `supabase/migrations/` folder); apply new blocks to the live project with `supabase db query --linked -f <file>` for a targeted change, not by re-running the whole file (some sections are unconditional `update`s that would stomp on since-edited live content).

For the sitewide bulk-repair workflow (dead links, missing images, divergent nav copies), see the `sitewide-html-repair` skill.
