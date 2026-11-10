---
id: adr:modootoday/20261110093030
title: Browser audits read a page only after its scripts have seen the last viewport change
status: active
created: 2026-11-10T09:30:30Z
updated: 2026-11-10T09:30:42Z
rel:
  governs: [test/system/site/viewport.mjs]
---

# Browser audits read a page only after its scripts have seen the last viewport change

## Context

`scroll-region.js` makes an overflowing code block, table wrapper or figure scroller a labelled tab stop and takes the tab stop away again when it fits. It learns about a new width from a `ResizeObserver`, whose callbacks run in the browser's next rendering update, before that frame is painted, so a reader never meets a scroller without a tab stop.

The docs audit (`test/system/audit/pages.mjs`) restored 1024px after its layout checks and ran axe at once. On `guides/agents/` the `modootoday-stubs` block fits at 1440px and overflows at 1024px; the last check before axe goes from 1440px to 1024px, so axe could read the page between the layout and the observer callback and report `scrollable-region-focusable` on a block the theme was about to mark. It failed in one colour scheme and passed in the other on the same build.

## Decision

The theme keeps its behaviour. A browser audit that reads scripted state after a viewport change first waits for the width, then for the frame after the rendering update: `settle(page, width)` in `test/system/site/viewport.mjs`, the one helper for this. `pages.mjs` settles at 1024px before axe; the table checks settle at each width, as before.

## Consequences

Axe results no longer depend on frame timing, on the docs site and on every starter demo build that uses the same page checks. A jsdom test (`test/js/site/viewport.test.js`) delivers resize callbacks a frame late, as a browser does, and checks that a settled read sees the region and that `pages.mjs` settles before axe.
