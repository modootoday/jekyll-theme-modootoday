---
id: adr:modootoday/20261104173945
title: Footer columns come from _data/nav/footer files in an optional sheet
status: active
created: 2026-11-04T17:39:45Z
updated: 2026-11-04T17:40:09Z
rel:
  governs: [_includes/modootoday/chrome, assets/css/modootoday/chrome/footer.scss]
---

# Footer columns come from _data/nav/footer files in an optional sheet

## Context

The theme had no footer of its own: `footer-custom.html` printed only the language switcher when `language_switcher: footer` was set, so the starters ended without a footer and the docs site kept its own override. Sites want link columns and a copyright line without writing markup, and the later component registry will own a `chrome/footer` component.

## Decision

- `_includes/modootoday/chrome/footer.html` reads `site.data.nav["footer-<lang>"]`, else `site.data.nav.footer` (`_data/nav/footer-ko.yml`, `_data/nav/footer.yml`). The data shape is frozen: `columns: [{title, items: [{title, url}]}]` and `copyright:` (text). Each column is a list labelled by its title (`aria-labelledby` on a `p.mt-footer-title` with an id), inside the footer landmark; links go through `modootoday/link.html`. With `language_switcher: footer` the switcher closes the footer. Without data or the switcher it prints nothing.
- The theme's `footer-custom.html` includes it, so a site's own `footer-custom.html` still replaces the whole footer and can include `modootoday/chrome/footer.html` itself.
- The column styles are the `footer` component in their own sheet, `assets/css/modootoday/chrome/footer.css` (partial `components/footer/_footer.scss`), linked right after the core sheet only when the page's footer data has columns. `footer` joins `modootoday.components`; it is not always on. The base footer rules stay in the core shell, which loses its fill and gets 3rem/2rem padding.
- Amended for 1.5.0 (usability audit, round 2): the columns were `nav` landmarks named by their titles, so a column titled Docs repeated the doc sidebar landmark's name and failed axe `landmark-unique` on every page with a sidebar. A column is not a landmark of its own; the footer (`contentinfo`) already is one, so no title can collide with another landmark.
- No new configuration key until the registry's `components.footer`.

## Consequences

The docs site drops its `footer-custom.html` for `docs/_data/nav/footer{,-ko,-ja}.yml`. A site with a `modootoday.components` list that leaves out `footer` gets the footer markup without the column sheet. The data shape cannot change in 1.x.
