---
id: adr:modootoday/20261112132133
title: One include picks the share image, its alt text and size, and falls back to the hero before og_image
status: active
created: 2026-11-12T13:21:33Z
updated: 2026-11-12T15:02:05Z
rel:
  governs: [_includes/modootoday/meta/og-image.html, _includes/modootoday/head-meta.html, lib/modootoday/check/config/keys/appearance/brand.rb]
  depends_on: [adr:modootoday/20261109141321]
---

# One include picks the share image, its alt text and size, and falls back to the hero before og_image

## Context

J2 in [[adr:modootoday/20261109141321]]: link previews showed an image with no text alternative and no size, and a landing page with a hero image still shared the site-wide `og_image`. The head and JSON-LD each chose the image on their own, and the structured-data check compares the two.

## Decision

- `meta/og-image.html` is the one owner: `mt_og_img`, `mt_og_alt`, `mt_og_w`, `mt_og_h`. Order: `page.image` (a path or `{path, alt, width, height}`), the hero image, the hero poster, then `modootoday.og_image`, which now also takes `{path, alt, width, height}`. The alt comes from `page.image.alt` or `image_alt` for a page image, else from the chosen image's map.
- The head adds `og:image:width` and `og:image:height` when both are known, and `og:image:alt` and `twitter:image:alt` when there is an alt; JSON-LD reads the same include, so the two cannot disagree.
- `modootoday-check` accepts a path or the map, requires whole-number sizes, and warns when the map has no alt. No i18n, no CSS.
- The docs site uses the map form with its image's real size.

## Consequences

- Tests: `test/theme/seo/og_image_test.rb` (the site map, a page image and `image_alt`, the hero first, JSON-LD agreeing); `head_meta_test.rb` moves beside it into `test/theme/seo/`, which keeps `test/theme/` under the flat-directory limit.
