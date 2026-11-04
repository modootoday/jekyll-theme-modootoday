---
id: adr:modootoday/20261104061807
title: A directory layout rendering a collection document draws its family's detail page
status: active
created: 2026-11-04T06:18:07Z
updated: 2026-11-04T06:19:09Z
rel:
  governs: [_includes/modootoday/directory/self.html, _layouts/directory.html, _includes/modootoday/detail/page.html, _layouts/detail.html]
---

# A directory layout rendering a collection document draws its family's detail page

## Context

jekyll-default-layout, on by default on GitHub Pages, gives a collection document without a layout the layout named like its collection. The theme has list layouts named `portfolio`, `team`, `jobs`, `events`, `sponsors`, `integrations` and `directory`, so `_portfolio/atlas.md` rendered as an empty card list. `_portfolio` is a common collection name.

## Decision

- Each directory layout declares its detail counterpart in front matter, `mt_self_detail`: `project` for `portfolio`, `job` for `jobs`, `event` for `events`, `detail` for the others. The layout file is the one owner; the checker reads it from there.
- `_includes/modootoday/directory/self.html` sets `mt_self_detail` when the merged layout has one, the page is a collection document other than a post, and it has no `items:`, `data:` or `records:` source. It is the one judgement, included by `directory.html` (draw the detail instead of the list), `default.html` (the `mt-detail` main class) and `jsonld/type.html` (the detail layout's schema.org type).
- The `detail` layout's markup moves to `_includes/modootoday/detail/page.html`, which takes `kind`; `detail.html` calls it with `layout.mt_kind`, so detail pages render byte for byte as before.
- The checker warns about such a collection until `defaults` name its layout (see the checker ADR of the same change).

## Consequences

Collection documents on GitHub Pages render as items without configuration. `stylesheets.html` also includes `directory/self.html` and links the `detail` bundle in place of the layout chain's `directory` on a self-detail page, so it loads exactly what a `detail` page loads. Future context layouts live under `_layouts/<group>/`, whose names contain a slash and can never match a collection label, so this rule covers only the existing root list layouts.
