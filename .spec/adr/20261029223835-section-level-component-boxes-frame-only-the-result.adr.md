---
id: adr:modootoday/20261029223835
title: Section-level component boxes frame only the result container
status: active
created: 2026-10-29T22:38:35Z
updated: 2026-10-29T22:38:35Z
rel:
  governs: [_includes/md-sections.html, docs/_layouts/examples.html, qa/qa.mjs]
---

# Section-level component boxes frame only the result container

## Context

On the Components docs page the Buttons example card was centered and drawn on the CTA gradient, unlike every other card. Root cause: `md-sections.html` puts `.mt-cta` (a section-level box: centered text, gradient, border, large top margin) on the `<section>` of a `c: cta` entry, and the examples layout puts the description, front matter, source and Result label inside that same section. Every other component styles direct children (`> ul`, `> ol`, `h3`), so only CTA leaked onto the whole card.

## Decision

- Additive API: when a `c: cta` section holds an element with `data-mt-result`, `.mt-cta` (and `.md-cta`) go on that element, not on the section. `mt-c-cta`, `data-c` and `data-section` stay on the section. Sections without it render exactly as before, so the frozen 1.0 class and path contract is unchanged.
- The docs examples layout wraps a CTA result in `<div class="docs-ex-out mt-cta" data-mt-result>`. Other results stay in place, because their child-combinator styles and tabs/accordion scripts need them as direct children of the section.
- A broader isolation layer (wrapping every result and moving all component classes) was rejected for 1.0: it would change the selectors' structure that users may rely on.
- `qa/qa.mjs` fails when any example card on a components page (any language, light and dark) has a computed text-align or background different from the first card.

## Consequences

All example cards look the same; only the Buttons result is framed as a CTA. Showcase pages can reuse `data-mt-result` for the same purpose.
