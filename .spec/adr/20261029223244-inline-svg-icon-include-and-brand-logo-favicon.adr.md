---
id: adr:modootoday/20261029223244
title: Inline SVG icon include, brand logo and favicon
status: active
created: 2026-10-29T22:32:44Z
updated: 2026-10-29T22:32:44Z
rel:
  governs: [_includes/modootoday/icon.html, _includes/modootoday/logo.html, _includes/modootoday/head-meta.html, assets/modootoday/, test/icon_test.rb]
---

# Inline SVG icon include, brand logo and favicon

## Context

Icons were text glyphs, emoji or CSS-drawn shapes (globe, sun/moon, chevrons, separators, copy, edit, alert types). They rendered differently per font and OS, could not be mirrored in RTL reliably, and some read aloud. The project also had no logo or favicon. Constraints: Liquid only (github-pages), CSP-strict (no external requests, no inline styles), currentColor for light/dark, a CSS bundle budget of 32768 B.

## Decision

- One include, `modootoday/icon.html` (`name`, `size` default 18, `label`, `class`), outputs inline SVG with `currentColor`; sizing lives in SVG attributes, not CSS. Decorative by default (`aria-hidden`, `focusable=false`); `label` makes it `role=img` with a name. Unknown names render nothing; a test fails when the theme or docs use an undefined name.
- Directional icons carry `.mt-icon-flip`, mirrored by one rule under `[dir=rtl]`.
- The parameter is read as `include["size"]`: `include.size` returns the hash's size in Liquid.
- Icon-only buttons (theme toggle, language menu) keep their accessible name on the control, at least 24 px targets.
- `modootoday.logo: brand | <path>` renders through an overridable `modootoday/logo.html` (the mark as filled SVG in the `brand` token, or a decorative `img`). `modootoday.favicon: brand | <path>` links SVG, 32 px PNG and a 180 px apple-touch icon generated from the same mark.
- The code-copy script builds the copy/check SVG strings itself (same paths) because JS cannot call an include.

## Consequences

Icons look the same everywhere and follow theme colours and direction. Adding an icon means adding a `when` branch; removing one is a breaking change for callers (public API). Status badge symbols stay text glyphs because they are the label's visual shorthand, not controls.
