---
id: adr:modootoday/20261103012843
title: Core script budget rises to 7 KiB for the module helpers; the hero demo gets its own page type
status: active
created: 2026-11-03T01:28:42Z
updated: 2026-11-03T01:43:23Z
rel:
  governs: [qa/audit/config.mjs]
---

# Core script budget rises to 7 KiB for the module helpers; the hero demo gets its own page type

## Context

`BUDGET.js_total` sums the gzip bytes of every file under `assets/js/modootoday/` (renderer bundles and the blog script excepted) and was 5.75 KiB, the 5,228 bytes measured plus 10%. The two helper modules (`theme/current.js`, `dom/config.js`) and the rewritten toggle bring it to 6,432 bytes. No theme page loads the helpers by itself; only a page whose site module imports them does.

## Decision

- `js_total` becomes 7 KiB: 6,432 bytes plus 10%, rounded up to 0.25 KiB, the rule the other budgets follow.
- A page type `visual` covers the hero module demo (`layouts/demo/orbit/`): it measured 9,444 bytes of CSS and 6,120 of JavaScript (the site module and the helpers included), so its limits are 10.25 and 6.75 KiB. A page type is used rather than the `FEATURE_JS` allowance sketched in the design, because the page-type check already follows module imports and needs no new rule.
- The new `visual` sheet gets a per-file budget of 1 KiB (244 bytes built).

## Consequences

The other page types keep their limits, since the helpers reach no other page. A later feature that adds theme JavaScript raises `js_total` again with its own record.
