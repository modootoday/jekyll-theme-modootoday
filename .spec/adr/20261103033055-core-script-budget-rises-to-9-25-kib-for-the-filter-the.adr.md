---
id: adr:modootoday/20261103033055
title: Core script budget rises to 9.25 KiB for the filter; the filter demo gets its own page type
status: active
created: 2026-11-03T03:30:53Z
updated: 2026-11-03T03:31:30Z
rel:
  governs: [qa/audit/config.mjs]
  depends_on: [adr:modootoday/20261103012843]
---

# Core script budget rises to 9.25 KiB for the filter; the filter demo gets its own page type

## Context

`BUDGET.js_total` sums the gzip bytes of every core file under `assets/js/modootoday/` and was 7 KiB for 6,432 bytes measured. The filter adds `filter/filter.js` (848 B gzip), `filter/chips.js` (580 B) and `text/normalize.js` (365 B), and `search.js` grows from 856 to 1,217 B. The total is 8,586 bytes. Only a page with a filter loads the filter files.

## Decision

- `js_total` becomes 9.25 KiB: 8,586 bytes plus 10%, rounded up to 0.25 KiB.
- A page type `filter` covers the filter demo (`layouts/demo/filter/`): 9,482 bytes of CSS and 6,784 of JavaScript (filter.js with chips.js, normalize.js and dom/config.js it imports), so its limits are 10.25 and 7.5 KiB. Other doc pages measure 4,484 bytes of JavaScript and keep the `doc` limit.
- The `filter` sheet gets a per-file budget of 1.25 KiB (1,066 bytes built, 442 gzip).
- The `blog` page type loads `search.js` too: its largest page measured 4,428 bytes of JavaScript, over the 4.25 KiB limit, which becomes 5 KiB. The `doc` and `landing` limits (5.25 KiB) still hold at 5,297 bytes.
- The filter demo joins `CSP_PAGES` and the audited `PAGES`.

## Consequences

The design's target of 700 bytes gzip for the filter script is not met: filter.js and chips.js are 1,428 bytes together, because the chips live in their own file and the field, the count, the Escape key and the directory recount are each a few lines. Doc pages without a filter pay only the 361 bytes `search.js` grew by.
