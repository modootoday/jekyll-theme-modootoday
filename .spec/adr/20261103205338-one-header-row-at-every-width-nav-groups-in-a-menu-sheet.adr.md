---
id: adr:modootoday/20261103205338
title: One header row at every width; nav groups in a menu sheet below 64rem; anchors offset by scroll-padding only
status: active
created: 2026-11-03T20:53:38Z
updated: 2026-11-03T20:53:53Z
rel:
  governs: [_sass/modootoday/components/core/chrome, _includes/modootoday/chrome]
---

# One header row at every width; nav groups in a menu sheet below 64rem; anchors offset by scroll-padding only

## Context

Below 64rem the header nav wrapped onto its own scrolling row and listed the first group's links inline (`.mt-nav-flat`), and below 30rem search took a third row. The sticky header was 105 to 139px tall depending on the layout, while headings reserved 76px with `scroll-margin-top` on top of the page's `scroll-padding-top`, so anchor targets landed under the header on phones. Between 30rem and 48rem search was `position: static`, so its icon left the field.

## Decision

- The header is one row of `header-height` (4rem) at every width: title, nav, search, language menu, theme toggle; it never wraps. The header rules live in `components/core/chrome/_header.scss`, the location the component registry will map to `chrome/header`. `_core.scss` imports it itself, through the load path like every component partial (so a site can still shadow it), so the header is always in the core sheet and is not a `modootoday.components` name; the component names test reads the partials `_core.scss` imports and exempts only those.
- From 64rem the nav is the row of links with groups as `<details>` menus. Below 64rem the row is hidden and the same `nav.mt-nav` landmark holds `details.mt-menu.mt-nav-sheet` (`_includes/modootoday/chrome/nav-sheet.html`): a 2.5rem icon button labelled by the interface string `nav.menu`, at the end of the row, opening a full-width sheet that hangs from the header with the top-level links and each group's links under its title (rows of 3rem). It reuses the `.mt-menu` styles and `menu.js` (Escape, arrows, outside click), so no script changes. `.mt-nav-flat` is removed.
- Search is always positioned. Below 48rem it is a 2.5rem icon field that covers the header row while it has focus; from 48rem a 2rem by 15rem field; from 64rem it may shrink beside the nav as before.
- Icon buttons in the header (theme toggle, language menu, menu sheet) are 2.5rem, 2.75rem on coarse pointers.
- Anchor targets are offset only by `html { scroll-padding-top }` (header height, top safe area and 1rem). No rule sets `scroll-margin-top`.

## Consequences

A site that styled `.mt-nav-flat` loses those rules (an internal class, named in the upgrade note). The sheet duplicates the nav links in the HTML of every page with a nav; only one copy is displayed at a time. The docs QA checks the header height at 360, 768, 1024 and 1440px on four layouts, the last anchor of two long pages at 360 and 1440px, and the sheet by keyboard; the visual run adds 600 and 720px. A header variant (N20) later adds `data-variant` rules to the same file.
