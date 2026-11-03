---
id: adr:modootoday/20261103235459
title: Page CSS and page-type script budgets rise for the table sheets and stacked-table labels
status: active
created: 2026-11-03T23:54:59Z
updated: 2026-11-03T23:55:27Z
rel:
  governs: [qa/audit/config.mjs]
---

# Page CSS and page-type script budgets rise for the table sheets and stacked-table labels

## Context

The table work (adr:modootoday/20261103223545) moves the table rules out of the core sheet into `table.css` (2,318 bytes) and `table-stack.css` (914 bytes), and `scroll-region.js` now also writes roles and column labels for stacked tables, one statement per line. Measured on the docs site built by the classic Pages builder: the core sheet falls from 27,132 to 26,833 bytes, but a page with a table links one more sheet, so the largest non-showcase page (the filter demo, which has a list, a filtered table and the filter sheet) links 37,205 bytes against the 35 KiB (35,840) page cap. `scroll-region.js` grows from 482 to 850 bytes gzip, so every page type that loads it is over its JavaScript limit: doc and landing 5,718 bytes (5.25 KiB limit, 26 bytes of headroom before), showcase 6,175 (5.75 KiB), and the visual demo reaches 6,902 of 6,912.

## Decision

Limits follow the existing rule: the largest measured page plus 10%, rounded up to 0.25 KiB.

- `BUDGET.css` (core CSS one page links): 35 to 40 KiB (37,205 measured).
- `PAGE_TYPES` JavaScript: doc 5.25 to 6.25 KiB, landing 5.25 to 6.25 KiB, showcase 5.75 to 6.75 KiB, visual 6.75 to 7.5 KiB. CSS limits of the page types are unchanged (doc 9,536 of 9,984 bytes gzip).
- New `SHEETS` rows: `table.css` 3 KiB and `table-stack.css` 1 KiB.
- `js_total` (9,088 of 9,472 bytes gzip), the core sheet budget and the filter, blog and record types stay as they are.

## Consequences

The CSS a reader downloads on a page without a table falls by 299 bytes; a page with a table loads up to 3,232 more bytes raw (about 1 KiB gzip) of table rules it uses. The stacked-table labels cost 368 bytes gzip on every page with a code block or a table; a later split of the label code into its own script loaded only with `mt-table--` would win most of it back.
