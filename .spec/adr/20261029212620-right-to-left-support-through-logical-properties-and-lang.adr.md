---
id: adr:modootoday/20261029212620
title: Right-to-left support through logical properties and lang-derived dir
status: active
created: 2026-10-29T21:26:19Z
updated: 2026-10-29T21:26:19Z
rel:
  governs: [_sass]
---

# Right-to-left support through logical properties and lang-derived dir

## Context

The theme used physical left/right properties, so pages in Arabic, Hebrew or Persian rendered with mirrored text but unmirrored components (callout bars, step rails, TOC rules on the wrong side).

## Decision

Component and base CSS use logical properties (margin/padding/border/inset-inline-start/end, text-align start/end). The base layout sets dir="rtl" when the first subtag of the page language is one of ar fa he ur yi ps sd ug dv ckb; front matter direction: (or an i18n direction: key) overrides. Code blocks, inline code and keyboard keys stay left-to-right; tab arrow keys follow visual order. The docs site has an Arabic RTL kitchen sink that docs QA screenshots, runs axe on and checks for mirrored callout and steps and LTR code. The page key is direction, not dir, because Jekyll already defines page.dir.

## Consequences

RTL works on classic GitHub Pages with no configuration. Logical properties need browsers from 2021 or later, which the theme already requires. Header and navigation layout is mirrored by the flex direction; any new CSS must use logical properties, which review and the RTL QA page catch.
