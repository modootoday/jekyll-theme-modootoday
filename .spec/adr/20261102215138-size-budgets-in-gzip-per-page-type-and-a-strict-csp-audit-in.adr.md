---
id: adr:modootoday/20261102215138
title: "Size budgets in gzip per page type, and a strict CSP audit in docs QA"
status: active
created: 2026-11-02T21:51:38Z
updated: 2026-11-04T16:35:37Z
rel:
  governs: [test/system/audit/config.mjs, test/system/audit/budgets, test/system/audit/csp.mjs]
---

# Size budgets in gzip per page type, and a strict CSP audit in docs QA

## Context

The script budget was the raw byte total of every file under `assets/js/modootoday/`, whatever a page loaded. It left about 1 KB for new features and punished code written one statement per line, while what a visitor pays is the compressed size of what one page loads. The theme also claimed to work under a strict Content Security Policy, but no check served it that way.

## Decision

- `test/system/audit/budgets/` splits the budgets by responsibility: `files.mjs` (each sheet, layout and renderer bundles, the blog bundle, and the core scripts in total as gzip bytes, `BUDGET.js_total`), `pages.mjs` (what one built page loads, with the modules its scripts import, and the core CSS each page links) and `types.mjs` (`PAGE_TYPES`: per page type, the gzip bytes of the CSS and of the JavaScript one page loads).
- The types are doc, landing, blog and showcase. The components index, the kitchen sink and the strict CSP demo link every component sheet on purpose, so they form the showcase type instead of setting the doc limit; the CSP demo also joins `SHOWCASE` for the per-page CSS cap.
- Limits are the largest measured page of each type (docs built by the Pages builder) plus 10 %, rounded up to 0.25 KiB, as for the other budgets. The core scripts measured 5,228 B gzip, so `js_total` is 5.75 KiB rather than the 8 KiB first proposed. A feature that only some pages use is budgeted on those pages when it arrives.
- `test/system/audit/csp.mjs` serves `CSP_PAGES` with `default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; worker-src 'self'; manifest-src 'self'` as a response header and fails on any `securitypolicyviolation` event, console error or page error; an injected inline style must be reported, so a blind collector fails too. A feature with a demo page adds the page to `CSP_PAGES`.
- The docs site sets `modootoday.csp: strict` so its pages can be served under that policy. The kitchen sink stays out of `CSP_PAGES`: it embeds a third-party frame, and kramdown writes aligned table columns as `style` attributes, which the policy blocks (the CSP recipe says so).

## Consequences

Formatting rules no longer fight the script budget, and a feature that adds weight only where it is used does not eat the budget of every page. Docs QA, which runs on pull requests and in the release check, now also breaks on inline script or style that the theme emits.
