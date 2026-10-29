---
id: change:modootoday/20261029202153
title: "P1 and P2 components, search, post layout and DTCG tokens (0.3.0, 0.4.0)"
status: active
created: 2026-10-29T20:21:53Z
updated: 2026-10-29T20:21:53Z
---

# P1 and P2 components, search, post layout and DTCG tokens (0.3.0, 0.4.0)

## Change

0.3.0 adds theme toggle, breadcrumb, table of contents, accordion, steps, figure and `tag:`/`since:` badges. 0.4.0 adds timeline, `kbd:` keys, opt-in client search, the `post` layout and a CI-generated read-only DTCG `tokens.json`. All components are on by default; `modootoday.components` narrows them. Decisions: adr:modootoday/20261029202133, adr:modootoday/20261029202148, adr:modootoday/20261029202149, adr:modootoday/20261029202150.

## Migration

Nothing required. Status/tag/since badges now also follow the `badge` entry in `modootoday.components`. For search, add a `search.json` page that includes `modootoday/search.json`. Add i18n keys `theme.toggle`, `breadcrumb.label`, `toc.label`, `badge.since`, `search.label`, `post.date_format` to localise new labels. `md-*` aliases stay for now.
