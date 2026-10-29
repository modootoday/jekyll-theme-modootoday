---
id: adr:modootoday/20261029202133
title: Inline components use code-span prefixes and section c values
status: active
created: 2026-10-29T20:21:33Z
updated: 2026-10-29T20:21:50Z
rel:
  governs: [_includes/md-components.html]
---

# Inline components use code-span prefixes and section c values

## Context

Standard Markdown has no syntax for badges, keys or grouped blocks, and the theme must render on GitHub Pages (Liquid only, no plugins) while the source still reads well on GitHub.

## Decision

Inline components are code spans with a fixed prefix (`status:`, `tag:`, `since:`, `kbd:`) whose value is one token; block components are `##` sections tagged with a `c:` value in front matter (`accordion`, `steps`, `timeline`, ...). Conversion stays in Liquid; anything that does not match is left as code. Each conversion is gated by its name in `modootoday.components` (status/tag/since by `badge`).

## Consequences

Pages degrade to plain code spans and headings on any other renderer. The checker validates prefix values so a typo fails CI instead of shipping raw code.
