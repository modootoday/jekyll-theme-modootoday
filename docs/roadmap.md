---
title: Roadmap
description: What 1.0 includes, what comes in 1.x, and the non-goals.
---
# Roadmap

## 1.0

- Visual polish of every component in light and dark, on the docs site and the kitchen sink. `status:partial`
- Stable [public API](../api/) and deprecation policy. `status:available`
- Canonical, hreflang and Open Graph tags; opt-in sitemap and feed. `status:available`
- English and Korean documentation. `status:available`

## 1.x

- Slot contract for `_data/components.yml` ([API](../api/#slot-contract)). `status:available`
- Tag and category archive pages for the `post` layout. `status:planned`
- Japanese documentation (the example site already has Japanese pages). `status:planned`
- Visual regression checks against reference screenshots in CI. `status:planned`

## Non-goals for 1.0

- **Right-to-left scripts.** Layouts are not mirrored. New CSS uses logical properties so RTL can follow in 1.x.
- **Math and diagrams.** The theme ships no MathJax, KaTeX or Mermaid. GitHub renders `math` and `mermaid` fences on github.com; on your site, load a renderer from `_includes/head-custom.html` or `footer-custom.html`.
