---
id: adr:modootoday/20261104223510
title: Error pages have no Markdown twin
status: active
created: 2026-11-04T22:35:10Z
updated: 2026-11-11T23:17:08Z
rel:
  governs: [lib/modootoday/stubs/page.rb, lib/modootoday/check/build/stubs/twins.rb]
---

# Error pages have no Markdown twin

## Context

The usability audit of the 1.5.0 candidate (audit:modootoday/20261104220950, M2) made a 404 page as Layouts > Page shells shows it: `layout: error` with `permalink: /404.html`. On Jekyll 4 with the plugin, the plugin wrote the twin at `/404.md`, while `modootoday-check --twins` looked for `/404/index.md` and told the user to enable the plugin that was already enabled. The fix that worked, `twin: false`, was documented only for record pages. A not-found or server error page has nothing an agent should read as Markdown, and its twin would also be listed in `llms.txt`.

## Decision

- A page has a twin unless it is `README.md`, sets `twin: false`, or uses `layout: error` (404, 410 and 500 pages). `Stubs::Page#twin?` is the one rule; the plugin, `modootoday-stubs --twins` and `modootoday-check --twins` all ask it, and `markdown/llms-pages.html` leaves error pages out of `llms.txt` and `llms-full.txt` the same way.
- The checker's missing-twin message also names `twin: false` for any other page that needs no twin.
- Layouts > Page shells, Install > Verify the build, Recipes > System pages and RULES.md say so, in en, ko and ja.

## Consequences

A site's `404.md` passes `--twins` on GitHub Pages and on Jekyll 4 with no stub and no front matter beyond the documented example. A site that relied on an error page's twin loses it; none is linked from the page itself, because the page actions and the alternate link appear only when a twin exists.
