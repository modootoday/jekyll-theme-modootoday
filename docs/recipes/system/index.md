---
title: System pages
description: Not-found, error, moved and search pages that every site needs.
nav_order: 80
---
# System pages

Add `404.md` with `layout: error`, use `redirect` for pages that moved, and give search its own page with `layout: search`. These pages use the small pages bundle; set `sitemap: false` on error pages so they stay out of the sitemap. Error pages have no Markdown twin and stay out of `llms.txt`, so `modootoday-check --twins` passes without a stub for them.

Layouts: `error`, `redirect`, `search`.
