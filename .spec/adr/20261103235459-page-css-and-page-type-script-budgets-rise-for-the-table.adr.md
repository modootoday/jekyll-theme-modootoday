---
id: adr:modootoday/20261103235459
title: Page CSS and page-type script budgets rise for the table sheets and stacked-table labels
status: active
created: 2026-11-03T23:54:59Z
updated: 2026-11-04T01:10:00Z
rel:
  governs: [qa/audit/config.mjs]
---

# Page CSS and page-type script budgets rise for the table sheets and stacked-table labels

## Context

The table work (adr:modootoday/20261103223545) moves the table rules out of the core sheet into `table.css` (2,318 bytes) and `table-stack.css` (914 bytes). Measured on the docs site built by the classic Pages builder, the core sheet falls from 27,132 to 26,833 bytes. A page with a table links one more sheet, though, so the largest non-showcase page links 37,205 bytes against the 35 KiB (35,840) page cap. That page is the filter demo, with a list, a filtered table and the filter sheet.

The first version put the stacked-table roles and labels into `scroll-region.js`, which grew from 482 to 850 bytes gzip. Every page with a code block or a table paid for it, and the doc, landing and showcase types went over their limits. The labels now live in `table-stack.js` (519 bytes gzip). It is a registry row with the same probes as `table-stack.css`, so only pages with a stacked table load it: `c: params` or a `mt-table--` class on a table. `scroll-region.js` is 501 bytes (+19).

## Decision

Limits follow the existing rule: the largest measured page plus 10%, rounded up to 0.25 KiB. All figures come after the split.

- `BUDGET.css` (core CSS one page links): 35 to 40 KiB. The filter demo still links 37,205 bytes, because the split moves script only, not CSS.
- `PAGE_TYPES` JavaScript:

  | Page type | Measured (bytes gzip) | Old limit | New limit |
  | --- | --- | --- | --- |
  | doc | 5,369 | 5.25 KiB | 6 KiB |
  | landing | 5,369 | 5.25 KiB | 6 KiB |
  | showcase (components and kitchen sink load `table-stack.js`) | 6,345 | 5.75 KiB | 7 KiB |
  | visual | 6,553 | 6.75 KiB | 7.25 KiB |

  The doc limit had 7 bytes of headroom left. The page-type CSS limits do not change; doc CSS is 9,536 of 9,984 bytes gzip.
- New `SHEETS` rows: `table.css` 3 KiB and `table-stack.css` 1 KiB.
- `js_total` (9,258 of 9,472 bytes gzip with `table-stack.js`), the core sheet budget, and the filter, blog and record types stay as they are.

## Consequences

A page without a table loads 299 bytes less CSS and 19 bytes more script. A page with a table loads up to 3,232 bytes raw (about 1 KiB gzip) more CSS. Only pages with a stacked table load the 519-byte label script. `js_total` has 214 bytes of headroom, so the next script added raises it under the same rule.
