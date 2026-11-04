---
id: adr:modootoday/20261104115652
title: Below 40rem a body table that does not fit stacks into labelled blocks
status: active
created: 2026-11-04T11:56:52Z
updated: 2026-11-04T16:35:37Z
rel:
  governs: [assets/js/modootoday/data/table-stack.js, _sass/modootoday/components/table-stack, test/system/audit/layout/table-reflow.mjs]
---

# Below 40rem a body table that does not fit stacks into labelled blocks

## Context

adr:modootoday/20261103223545 gave two- and three-column tables column floors (5rem, the last 9rem) and let the box scroll past them, and gave four-column tables a wider budget with a sticky first column. A visual review at 360 and 390px found both limits failing on real content. On the configuration key tables the code-only first column, which never breaks, takes about 165px, so the 9rem description column starts near the right edge and about 60px of it shows before scrolling; the floors are met, so the reflow audit passed. On the API reference the four-column component table has 7 to 15-line cells, and that page was not audited. The stacked form (`mt-table--stack`) already exists, but only as a kramdown attribute list, which portable Markdown cannot use and the docs site does not.

Options weighed: letting first-column code break (cut keys were the earlier complaint); capping the first column (the code then overflows its cell); stacking every three-column table below 40rem (also stacks the tables that fit); rewriting the docs tables (fixes the docs, not the sites that use the theme).

## Decision

- Below 40rem, `table-stack.js` stacks a plain body table (one with a header row and no `mt-table--` class) that does not fit: with two or three columns, when its box scrolls; with four or more, when a cell is over six lines (the audit's line count). It adds `mt-table--stack` and labels the table as for the opt-in class, so the stacked layout, roles and labels are the existing ones. Tables that fit stay tables. A window that later narrows below 40rem stacks then; one that widens shows the table again, because the stacked rules sit in the 40rem media query.
- The table-stack sheet and script are probed by `<table`, as the table sheet is, so every page with a body table loads them.
- In a stacked table, code may break (`overflow-wrap: anywhere`), since each cell is a full-width block.
- The reflow audit also fails a two- or three-column table that shows less than 9rem (or its full width) of its last column before scrolling, and covers `reference/api/`, which joins the audited pages.

## Consequences

Every page with a table loads the table-stack sheet and script (each capped at 640 B gzip). Without JavaScript, or while the table is hidden (a closed details or an inactive tab), a table that does not fit scrolls as before. The `mt-table--stack` and `mt-table--dl` classes keep their meaning; `mt-table--fixed` opts a table out of stacking.
