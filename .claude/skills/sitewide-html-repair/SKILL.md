---
name: sitewide-html-repair
description: Bulk-fix cross-cutting issues sitewide in this repo (dead links, missing/broken image targets, divergent nav copies) using a scripted, idempotent approach rather than manual per-file edits.
---

The repo has previously used one-off PowerShell repair scripts run from the repo root (see `repair-9.ps1`) to bulk-fix cross-cutting issues sitewide: repointing dead links, swapping missing `<img>` targets to the placeholder SVG, and syncing divergent nav copies to one canonical version.

If asked to do sitewide cleanup of this kind, a similar scripted, idempotent approach (scan all `*.html`, report counts, rewrite in place) is the established pattern here — prefer it over manually editing dozens of files by hand.
