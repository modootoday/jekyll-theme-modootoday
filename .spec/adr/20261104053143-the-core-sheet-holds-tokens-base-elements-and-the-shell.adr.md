---
id: adr:modootoday/20261104053143
title: "The core sheet holds tokens, base elements and the shell; components are module sheets linked right after it"
status: active
created: 2026-11-04T05:31:43Z
updated: 2026-11-04T05:33:07Z
rel:
  governs: [_sass/modootoday, assets/css, _includes/modootoday/assets]
  depends_on: [adr:modootoday/20261029231339, adr:modootoday/20261103092701, adr:modootoday/20261104011122]
---

# The core sheet holds tokens, base elements and the shell; components are module sheets linked right after it

## Context

Every page links `assets/css/modootoday.css`, so each component in it costs every page, and features kept competing for its fixed budget. A static scan of the 67 audited docs pages (no scripts run) found that tokens, the reset, prose, the layout shell, the header, the nav and the theme toggle match 94 to 100% of pages, while the inline components, the code block rules, the page footer navigation and the banner match 0 to 73%.

Two measurements set the unit of delivery. The moved partials gzip to 2,522 bytes as one file but to 4,697 bytes as one file each (+86%), so very small files lose more than they save. Twelve files from the same origin over one HTTP/2 connection took as long as one file, within the noise; the cost is connections and round trips, not files.

## Decision

- **Core** is the tokens, the base element rules (reset, prose, bidi, interaction), the layout shell (shell, safe area), the chrome shell (header, nav, theme toggle) and the shell part of `_access.scss`. A rule belongs in core only when at least 90% of the measured pages use it. A test holds the list of partials core may import; adding one needs a new record.
- **Ownership** is per component (one partial, one registry row). **Delivery** is per family sheet, `assets/css/modootoday/<ns>/<sheet>.css`, which imports its members in registry order and skips components a site turned off. Members under about 1 KiB that usually appear together share a sheet; larger or independent ones get their own. Namespaces follow the component catalog (chrome, content, structure, showcase, marketing, data, media, docs).
- The families: `content/inline` (callout, badge, kbd), `content/extras` (footnotes, progress, reveal), `content/code` (base code, code title, copy button), `media/media` (figure, embed, SVG figure), `marketing/hero` (hero, cta), `chrome/doc-nav` (breadcrumb, pagination, page meta), `chrome/banner` (banner, back to top) and `data/table` (with the base table fallback). The flat context sheets move once to their final `<ns>/<id>` paths.
- **Triggers**: a row's body probes (one row per sheet, several probes per row), the layout chain's `mt_sheets`, section names, page `css:`, and head conditions for what the base layout itself draws after the head (page meta, pagination, the banner).
- **Link order is the old cascade order.** Moved module sheets link right after core and before the blog sheet, layout bundles, context and section sheets, in registry order, which follows the old import order. With `css_layers: true` they stay in `mt.components`.
- **Touch-target and forced-colour rules** that must win at equal specificity move from `_access.scss` to the end of the partial they override (code copy, pagination, tabs, accordion). The shell part stays in `_access.scss`.
- `modootoday.css: bundle` folds the same rows into one file in the same order. The rule multiset of the split sheets equals the bundle's, apart from repeated `@media` wrappers; a test pins it.
- Sass partial paths are a shadowing API (adr:modootoday/20261103092701) and stay through 1.x. Family sheets import the existing paths; a part outside `components/` is written with a leading slash (a path under `_sass/modootoday/`). Partials move to `components/<ns>/_<id>.scss` once, in 2.0.
- This replaces the budget sentence of adr:modootoday/20261029231339 ("core 24 KB, each component 2 KB, any page 32 KB"); budgets follow adr:modootoday/20261104053146.

## Consequences

The core sheet loses about 9 KB raw. A docs page links two to five theme sheets, a marketing page two or three; the showcase pages link more on purpose. No rule changes and the relative order of rules that can meet on one element is kept, so pages look the same. A site that shadows `assets/css/modootoday.scss` with the old import list keeps the components in core as well; the rules then appear twice with the same cascade, and the upgrade notes say how to refresh the copy.
