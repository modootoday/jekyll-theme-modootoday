---
id: adr:modootoday/20261029201118
title: Sass uses @import only (Ruby Sass 3.7 and Dart Sass intersection)
status: active
created: 2026-10-29T20:11:13Z
updated: 2026-10-29T20:11:20Z
rel:
  governs: [_sass]
---

# Sass uses @import only (Ruby Sass 3.7 and Dart Sass intersection)

## Context

github-pages 232 compiles with Ruby Sass 3.7.4 (no module system; `@use` passes through silently); Jekyll 4 uses Dart Sass, which deprecates `@import`.

## Decision

Write only the common subset: `@import`, global functions, maps, mixins, `#{}` for custom-property values; no `@use`/`@forward`/`@supports selector()`. The checker rejects them in Sass and built CSS. Jekyll 4 sites may set `sass: {silence_deprecations: [import]}`.

## Consequences

Revisit when Dart Sass 3 drops `@import` or classic Pages support ends.
