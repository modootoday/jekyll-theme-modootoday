---
id: adr:modootoday/20261103074357
title: A record page type budget at 9.25 KiB CSS and 3.5 KiB JavaScript; the records list joins the filter type
status: superseded
created: 2026-11-03T07:43:57Z
updated: 2026-11-04T05:33:07Z
rel:
  governs: [qa/audit/config.mjs]
---

# A record page type budget at 9.25 KiB CSS and 3.5 KiB JavaScript; the records list joins the filter type

## Context

Record pages are a new kind of page that sites may have by the thousand, so they get their own page-type budget like the other kinds (`PAGE_TYPES` in `qa/audit/config.mjs`). The docs site now has a records demo: a list at `recipes/records/` and five record pages under it. Built from the docs site, the record page `recipes/records/lantern/` loads 8,425 bytes of CSS (core, the detail bundle, search, docs) and 3,076 bytes of JavaScript (core scripts only), the same files as the `project` detail demo. The list loads 9,637 bytes of CSS and 5,376 bytes of JavaScript, including the filter modules.

## Decision

- A page type `record` covers `recipes/records/lantern/` with limits of 9.25 KiB CSS and 3.5 KiB JavaScript: the measured values plus 10%, rounded up to 0.25 KiB.
- The records list joins the existing `filter` type, whose limits (10.25 and 7.5 KiB) it already meets; no limit changes.
- Both demo pages join `CSP_PAGES` and the English-only audited pages (`EN_ONLY`): the demo data is English and has no translated pages.

## Consequences

Records add no stylesheet or script. A later change that makes a record page load more fails the `record` budget instead of hiding under the larger `filter` or `showcase` limits.
