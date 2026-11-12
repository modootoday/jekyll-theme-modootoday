---
id: adr:modootoday/20261112153723
title: An opt-in print sheet, loaded only for printing, prints the content black on white without the site chrome
status: active
created: 2026-11-12T15:37:23Z
updated: 2026-11-12T16:08:11Z
rel:
  governs: [_sass/modootoday/print/_sheet.scss, assets/css/modootoday/chrome/print.scss, _includes/modootoday/stylesheets.html]
  depends_on: [adr:modootoday/20261109141321]
---

# An opt-in print sheet, loaded only for printing, prints the content black on white without the site chrome

## Context

A5 in [[adr:modootoday/20261109141321]]: a printed docs page carried the header, menus, banner and footer, printed dark-theme colours, hid all but one tab panel, and lost every link's address. Spike S3 found seven scattered `@media print` rules (directory, table, figure, docs-extra, detail, legal, resume); legal pages already print their link addresses.

## Decision

- `modootoday.print: true` links `/assets/css/modootoday/chrome/print.css` with `media="print"` after every other sheet, in split and bundle mode, so it never blocks rendering on screen. Its own budget row (`print|sheet|…|768`).
- The sheet is unlayered, so it wins over the layered theme. It hides the skip link, header, menus, banner, showcase bar, sidebar and page columns' asides, page actions, the update notice (`.mt-toast`), the install section (`.mt-c-install`), heading anchors, the feedback row, pagination, search and the footer; shows every tab panel with its heading; prints black on white whatever the theme; adds a link's address after external links in the content, except inside `.mt-legal-body`, which prints its own; and avoids breaks inside figures, code, callouts, tables and images.
- `details`, accordion and FAQ items print only their summary unless the reader opens them first: there is no script to open them, a documented limit.
- The docs site turns it on.

## Consequences

- No change on screen. Configuration guide in en, ko and ja.
- Tests: `test/theme/chrome/print_test.rb` (linked last with media=print only when opted in, unlayered), and the docs QA's print emulation on four pages (`test/system/audit/features/print.mjs`: hidden chrome, tab panels, black on white in the dark theme, link addresses, no CSP violation).
