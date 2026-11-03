---
id: adr:modootoday/20261103223545
title: Body tables are wrapped at render time and styled by a context sheet
status: active
created: 2026-11-03T22:35:45Z
updated: 2026-11-03T23:55:26Z
rel:
  governs: [_includes/modootoday/links/content.html, _sass/modootoday/components/table]
---

# Body tables are wrapped at render time and styled by a context sheet

## Context

Tables were `display: block` scrollers styled in the core sheet. The table research of 2026-11-03 measured the live docs site at 360 and 390px and found that a block table shrinks its columns instead of overflowing whenever a cell may break anywhere: Korean text (`overflow-wrap: anywhere` on `:lang(ko)`) and inline code (`anywhere` since 1.2.2) collapsed columns to one glyph, giving 18 to 45-line cells, and a table that did scroll showed no cue that it did. A sticky first column, edge shades and a stacked layout need a scroll box around the table, which kramdown does not write and Markdown cannot express portably. The core sheet had about 500 bytes of headroom, and most pages have no table.

## Decision

- `links/content.html`, which already filters every page's rendered body in the `default` layout, wraps each `<table` in `<div class="mt-table">`. Theme layouts that print their own tables (download, reference packages) drop their wrapper `div` and put their class on the `table`, so nothing is wrapped twice.
- The table rules move to a context sheet, `table.css`, a registry row with the body probe `<table`. The core keeps a fallback for tables outside the body (the old scroller, without borders). `modootoday.components` gains `table` and `table-stack`, always included, so `css: bundle` folds both sheets in.
- The wrapper scrolls; the table is `display: table`, `max-content` wide and capped at the wrapper. Local background gradients cover two edge shades until the box scrolls. Cells use `overflow-wrap: break-word` and inherit the language's `word-break`.
- Two or three columns: later cells may break long words but never below 5rem, the last one 9rem, so the box scrolls before a column collapses. Four or more columns: the table may grow to `max(100%, 36rem)`, 45rem and 54rem for four, five and six, code stays whole, and the first column is sticky with an end hairline (mirrored with `:dir(rtl)`, `Canvas` in forced colours). First-column code and right or centre aligned cells never wrap.
- Variants are classes on the `table`: `mt-table--stack` and `mt-table--dl` (blocks below 40rem, with column labels for stack) and `mt-table--fixed` (equal columns), in a second sheet `table-stack.css`, probed by `class="mt-table--` and ` mt-table--` (a variant class, first or not, but not the class name in prose or code). A site adds them with a kramdown attribute list; `c: params` tables get `mt-table--stack` by default. The stacked forms apply only after `scroll-region.js` has written explicit table roles and `data-label`s, because `display: block` drops a table's implicit roles; without JavaScript the table scrolls.
- `scroll-region.js` makes the overflowing wrapper the labelled focusable region; `filter.js` finds a table inside its wrapper and puts its controls before the wrapper.
- This supersedes the 1.2.2 choice of `overflow-wrap: anywhere` for inline code inside table cells; outside tables it stays.

## Consequences

Every page with a table loads one more stylesheet; pages without one load less CSS. The built HTML of every page with a table changes. Attribute lists are kramdown-only, so `modootoday-check` still reports them and the docs site documents the variants without using them; a portable opt-in (a section or page key) is a later decision. The docs QA adds `layout/table-reflow.mjs` at 320, 360 and 390px.
