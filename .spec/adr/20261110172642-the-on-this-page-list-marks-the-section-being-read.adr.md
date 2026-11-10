---
id: adr:modootoday/20261110172642
title: The On this page list marks the section being read
status: active
created: 2026-11-10T17:26:42Z
updated: 2026-11-10T17:27:16Z
rel:
  governs: [_includes/modootoday/toc.html]
---

# The On this page list marks the section being read

## Context

The "On this page" list (`toc.html`, component `toc`) is a sticky column from 64rem and a collapsed `<details>` below it. It links the page's h2 and h3, but it does not show where the reader is: on a long guide the column gives no sense of position, which the docs themes the theme is measured against all show. The operator asked for it on 2026-11-10, recorded before it is built. Pages without JavaScript, strict CSP, the core CSS headroom and the budget rules stay as they are.

## Decision

- **What is marked.** The section being read is the last listed heading whose top has passed an activation line: the sticky header's bottom plus 1rem. Before the first heading, nothing is marked. When the page cannot scroll further, the last heading whose top is in view is marked, so short final sections are reachable. Following a TOC link or loading with a hash marks that heading at once.
- **How it is marked.** The link gets `aria-current="location"`; at most one link per list carries it. The sticky column hides h3, so there an active h3 marks its h2; the mobile list marks the exact item. Nothing is announced (no live region): the state is read when a screen-reader user reaches the link.
- **Where it runs.** A theme module `assets/js/modootoday/structure/toc-spy.js`, registry row `toc-spy|module|/assets/js/modootoday/structure/toc-spy.js|class="mt-toc||<cap>`, loaded only on pages that render a TOC. It uses `IntersectionObserver` to wake and reads heading positions with `getBoundingClientRect` in one `requestAnimationFrame`; it never handles every scroll event. It never scrolls the page; when the marked link leaves the visible part of the sticky column, it sets that column's `scrollTop` (instant, no smooth scrolling).
- **Styles.** `.mt-toc a[aria-current]` and `.mt-toc-mobile a[aria-current]` take the foreground color, weight 500 and, in the column, the start border in the primary color; under `forced-colors` the border uses `Highlight`. They go in the TOC partial, which builds the `doc` context sheet, not the core sheet.
- **No new setting.** The mark is part of the `toc` component: `toc: false` on a page or `toc` left out of the components hides the list and loads no module. Without JavaScript the list is plain links, as today.
- **Budget.** The module's cap is its measured gzip size plus 10%, rounded up to the next 128 B, set in the same commit; the `doc` sheet cap moves only if the measured sheet passes it, with the number added to this record. Measured on the docs build (Jekyll 4, github-pages 232 bundle): the module is 1,623 B gzip, cap 1,792 B; the `doc` sheet is 1,254 B gzip with the mark rules, under its 1,280 B cap. The starter demo builds measure the same sheet at 1,307 B gzip (their Sass output differs from the docs build), past the cap, so the cap moves to 1,536 B, the value the audit names for 1,307 B.

## Consequences

- Work item 16d of 1.7.0, after 16a and before 16b. CHANGELOG Added: "The On this page list marks the section you are reading."
- Tests: a node test with a fake document (activation line, page end, hash, h3 to h2 in the column, one mark per list); a docs QA check that scrolls a long guide and reads `aria-current`, with axe 0. The visual baseline at the page top should not change; any change is listed under Visual.
- Docs: components index (TOC), accessibility guide (the mark, and that nothing is announced), api (`[aria-current="location"]` in `.mt-toc`), in en, ko and ja.
