---
title: Roadmap
description: Everything 1.0 includes, and what changes in 2.0.
---
# Roadmap

1.0 ships when every item below is done. There is no separate 1.x list: work that was planned for later is part of 1.0.

## 1.0

- Visual polish of every component in light and dark, on the docs site and the kitchen sink. `status:partial`
- Final rules (`md-components v1`) and a frozen [public API](../api/) with a deprecation policy. `status:available`
- Canonical, hreflang and Open Graph tags; opt-in sitemap and feed. `status:available`
- English, Korean and Japanese documentation. `status:available`
- Guide pages in every language of the example site. `status:available`
- Slot contract for `_data/components.yml` ([API](../api/#slot-contract)). `status:available`
- Right-to-left scripts: logical properties, automatic `dir="rtl"`, an [RTL kitchen sink](../components/kitchen-sink-rtl/). `status:available`
- A [math and diagrams guide](../math-diagrams/) for KaTeX and Mermaid under a strict CSP; the theme bundles neither. `status:available`
- Visual regression checks against reference screenshots in CI, blocking on pull requests, and a Lighthouse budget. `status:available`
- Tag and category archive pages for the `post` layout. `status:planned`

## 2.0

- The deprecated `md-*` classes and `--md-*` properties are removed. See [Migrate and upgrade](../upgrade/).
