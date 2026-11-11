---
id: adr:modootoday/20261030083001
title: "Header controls render at first paint (CSS scripting query, no new JS)"
status: active
created: 2026-10-29T23:30:00Z
updated: 2026-11-11T03:30:00Z
rel:
  governs: [_sass/modootoday/components/core/chrome/_theme-toggle.scss, _sass/modootoday/components/search/_search.scss, test/system/audit/first-paint.mjs]
---

# Header controls render at first paint

## Context

Every page load (worst on the logo click to home) flashed: the search box and the theme toggle were printed `hidden` and only shown by their deferred scripts, so the header first painted without them and then jumped (the language button moved, the search box and toggle popped in). The toggle icon also swapped after the script set `aria-pressed`. The colour scheme itself was stable (pre-paint `data-theme` script, `color-scheme` meta); there is one render-blocking stylesheet in `<head>`, no `@import`, no web fonts and no images without dimensions in the header.

## Decision

- `@media (scripting: enabled)` shows `.mt-search[hidden]` and `.mt-theme-toggle[hidden]` from the first paint; without scripting they stay hidden as before. The scripts are unchanged (no core JS bytes added).
- The toggle icon (moon or sun) follows the scheme in CSS (`data-theme` and `prefers-color-scheme`), not `aria-pressed`.
- QA `test/system/audit/first-paint.mjs` clicks the logo on a throttled network, records screencast frames and fails when the header band of the first new frame differs from the settled page, the body background changes, or CLS reaches 0.02 (light, dark, and stored dark on a light system).

## Consequences

Browsers without the `scripting` media feature (before Chrome 120, Firefox 113, Safari 17) keep the old behaviour (controls appear when the script runs).

## Amendment (2026-11-11): the audit measures a cold load, with service workers blocked

With the docs PWA on, the logo click went through the worker: theme CSS and JS came from its cache, which the CDP throttle does not slow (every resource showed `transferSize` 0), while the home HTML (20.9 KB before `</header>`) still streamed at the throttled rate. The first frame then painted a half-parsed header (title and nav, no search, language or toggle, and the title 40 px off until `.mt-has-sidebar` was parsed), and the audit failed. The `.js` route never matched either, since theme URLs end in `?v=`; and Playwright's routes do not see what a worker answers.

The same frame appears without any PWA when the CSS is in the HTTP cache (remote Chrome 152, 50 KB/s, `max-age=600` like GitHub Pages: 2,879 px in dark at 1280), so it comes from a warm cache, not from the worker's code; blocking workers in a context of the PWA build gave 0 px, as the PWA-off build did. The audit therefore runs its contexts with `serviceWorkers: "block"`: it keeps measuring what it always measured, a cold load of the page's own requests, and the worker stays covered by the PWA flows (`features/pwa/`). The script hold now matches `.js?v=` URLs, so the anchor step holds theme scripts as its comment says. Painting the header complete on a warm cache is a separate decision: adr:modootoday/20261111044513, which also adds a warm case to the audit.
