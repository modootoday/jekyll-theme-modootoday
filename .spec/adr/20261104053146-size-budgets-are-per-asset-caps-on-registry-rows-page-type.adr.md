---
id: adr:modootoday/20261104053146
title: Size budgets are per-asset caps on registry rows; page-type limits are derived and guide targets only warn
status: active
created: 2026-11-04T05:31:46Z
updated: 2026-11-04T16:35:37Z
rel:
  governs: [test/system/audit]
  depends_on: [adr:modootoday/20261102215138]
  supersedes: [adr:modootoday/20261103012843, adr:modootoday/20261103033055, adr:modootoday/20261103074357, adr:modootoday/20261103235459]
---

# Size budgets are per-asset caps on registry rows; page-type limits are derived and guide targets only warn

## Context

The budgets in `test/system/audit/config.mjs` mixed three kinds of number, each kept by hand. `js_total` summed the gzip bytes of every theme script (9,258 of 9,472 bytes), although no page loads all of them: the largest page loads 6,934 bytes. Every new script raised it with a record, as did most page-type limits (adr:modootoday/20261103012843, adr:modootoday/20261103033055, adr:modootoday/20261103074357, adr:modootoday/20261103235459). `BUDGET.css` and `css_showcase` capped the raw core CSS one page links, `SHEETS` and `SECTION_SHEET` capped each sheet, and the blog and layout bundles had caps of their own. A feature kept competing with every other feature for one shared headroom.

## Decision

- **Each theme CSS and JS file has one cap**: gzip bytes, the sixth column of its row in `_includes/modootoday/assets/registry.html`, the owner of the asset list. Rows the layouts link themselves (the core sheet, the blog sheet, layout bundles, renderer scripts, `theme-init.js`) sit in a second list there that Liquid never reads.
- **A cap is the measured gzip size plus 10%, rounded up to 128 bytes.** `test/system/audit/budgets/modules.mjs` measures each row on the built site:
  - a row without a cap fails, and the message prints the measured size and the cap to paste;
  - a file over its cap fails for that file only;
  - a cap above twice the measured size warns that it is loose;
  - a built file under `assets/css/modootoday*` or `assets/js/modootoday*` without a row fails.
- **Page-type limits are derived**: for each page of `PAGE_TYPES`, the limit is the sum of the caps of what the page loads (stylesheets, scripts and the modules they import). `PAGE_TYPES` keeps only its page lists.
- **Guide targets warn and never fail**: CSS at most 8 KiB and JavaScript at most 6 KiB gzip, and at most 6 render-blocking theme sheets, on every page type except `showcase`, whose pages load every component on purpose.
- `js_total`, `BUDGET.css`, `css_showcase`, `SHEETS`, `SECTION_SHEET`, the bundle caps and the hand-kept page-type limits are removed. A new asset is a registry row with a cap, reviewed in the diff, without a record.
- This supersedes adr:modootoday/20261103012843, adr:modootoday/20261103033055, adr:modootoday/20261103074357 and adr:modootoday/20261103235459, whose decisions were limits. The page types, page lists and CSP pages they added stay. The gzip page-type idea and the strict CSP audit of adr:modootoday/20261102215138 stay; its `js_total` does not.

## Consequences

A feature changes only its own cap, so features no longer block each other. A shared module that grows past its cap fails on its own row. Page totals still fail when a page starts loading an asset it did not load before without a row, and the guide targets show when a page type drifts.
