---
id: adr:modootoday/20261103033054
title: "The list and table filter is an ES module that only pages with filter: load"
status: active
created: 2026-11-03T03:30:53Z
updated: 2026-11-04T06:19:31Z
rel:
  governs: [_includes/modootoday/filter/controls.html, assets/js/modootoday/data/filter.js]
---

# The list and table filter is an ES module that only pages with filter: load

## Context

Long lists and tables (tools, plans, glossaries) need a text filter that works on classic GitHub Pages and degrades to the full list. The directory layouts already have a CSS-only facet filter by item field, and their front matter `filter:` names that field.

## Decision

- `filter: true | {facet: <column>}` is a common parameter of a `sections:` item, like `bleed` and `reveal`; on a page without `sections:` the page's `filter:` applies to its first list or table; a directory layout takes `filter_text: true`, since its `filter:` stays the field filter.
- Liquid writes `data-mt-filter` (and `data-facet`) on the root and a hidden `div.mt-filter` with the field and an `output[aria-live]` count (`filter/controls.html`, i18n `filter.label`, `filter.count`). Without JavaScript the controls stay hidden and every item is shown.
- `filter/filter.js` is an ES module that exports `initFilter(root)` and runs it on every `[data-mt-filter]`. It moves the controls before the root's first direct `ul`, `ol` or `table` and sets `hidden` on the `li` or `tbody tr` that lack a typed word. It imports the matching rules from `text/normalize.js` (compact comparison always on), `readConfig` from `dom/config.js` for `data-facet`, and the facet buttons from `filter/chips.js` (one `button[aria-pressed]` per column value, one at a time, the group named by the header cell). Escape in the field clears it.
- The asset registry gains the row kind `module` (written as `<script type="module">`); the filter's script and its `filter` sheet are turned on by the probe `<div class="mt-filter"`, so only pages with a filter load them. `filter` is an always-included component, like `visual`.
- `modootoday-check` validates the value, that the Markdown it governs has a top-level list or table, that `facet` is within the table's columns, and rejects page `filter:` together with `sections:` and `filter:` on `c: split`.

## Consequences

Pages without a filter build byte-identical HTML. The count skips items another rule hides (the directory's CSS facet) where the browser has `checkVisibility()`. Only the first list or table of a section is filtered; a second one needs its own section.
