---
id: adr:modootoday/20261029222251
title: Components docs pair each example's source with its live result
status: draft
created: 2026-10-29T22:22:51Z
updated: 2026-10-29T22:22:51Z
rel:
  governs: [docs/_layouts/examples.html, docs/components/index.md, qa/coverage.rb]
---

# Components docs pair each example's source with its live result

## Context

The owner found the Components page hard to follow with descriptions alone: every component needs its exact source next to what the theme really renders. Pages must stay plain Markdown (no Liquid, raw HTML or comments; twins byte-identical), work on github-pages (Jekyll 3.10) and Jekyll 4, stay CSP-strict and RTL-safe, and the theme CSS bundle has almost no headroom.

## Decision

- Each example is its own `##` section; a variant is a separate section. The first paragraph describes it, the rest is the example.
- A docs-only layout `docs/_layouts/examples.html` (on top of `doc`) reads the raw page with `include_relative`, and for sections listed in front matter `examples:` inserts after the description: the `sections:` entry (when the section has `c:`), the source in a highlighted code block with the theme copy button, a Result label, then the rendered HTML. The source is written once.
- Source comes before result so accordion and tabs scripts, which act on the section's `h3`s, never take it into a panel.
- Site chrome (navigation, language switcher, theme toggle, search, breadcrumb and table of contents, pagination, posts) is shown by configuration and points at this page's own chrome: a second live copy would duplicate ids and landmarks.
- Label styles live in `docs/assets/css/docs.css`, loaded from the docs `head-custom.html`, outside the theme bundle, with logical properties only.
- `qa/coverage.rb` fails when a components page in any language lacks `layout: examples`, an example per `_data/components.yml` key and per inline component, or a built source and result pair.

## Consequences

The page reads as source plus output on the site and as plain Markdown on github.com. Example sources stay in English in ko and ja so they match exactly what users paste. A new component must add an example section or QA fails.
