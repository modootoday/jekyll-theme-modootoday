---
id: adr:modootoday/20261030083000
title: Header controls render at first paint (CSS scripting query, no new JS)
status: active
created: 2026-10-29T23:30:00Z
updated: 2026-10-29T23:30:00Z
rel:
  governs: [_sass/modootoday/components/_theme-toggle.scss, _sass/modootoday/components/_search.scss, qa/audit/first-paint.mjs]
---

# Header controls render at first paint

## Context

Every page load (worst on the logo click to home) flashed: the search box and the theme toggle were printed `hidden` and only shown by their deferred scripts, so the header first painted without them and then jumped (the language button moved, the search box and toggle popped in). The toggle icon also swapped after the script set `aria-pressed`. The colour scheme itself was stable (pre-paint `data-theme` script, `color-scheme` meta); there is one render-blocking stylesheet in `<head>`, no `@import`, no web fonts and no images without dimensions in the header.

## Decision

- `@media (scripting: enabled)` shows `.mt-search[hidden]` and `.mt-theme-toggle[hidden]` from the first paint; without scripting they stay hidden as before. The scripts are unchanged (no core JS bytes added).
- The toggle icon (moon or sun) follows the scheme in CSS (`data-theme` and `prefers-color-scheme`), not `aria-pressed`.
- QA `qa/audit/first-paint.mjs` clicks the logo on a throttled network, records screencast frames and fails when the header band of the first new frame differs from the settled page, the body background changes, or CLS reaches 0.02 (light, dark, and stored dark on a light system).

## Consequences

Browsers without the `scripting` media feature (before Chrome 120, Firefox 113, Safari 17) keep the old behaviour (controls appear when the script runs).
