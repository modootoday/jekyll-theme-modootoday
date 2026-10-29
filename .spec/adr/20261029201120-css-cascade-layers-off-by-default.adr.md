---
id: adr:modootoday/20261029201120
title: CSS cascade layers off by default
status: active
created: 2026-10-29T20:11:13Z
updated: 2026-10-29T20:11:20Z
rel:
  governs: [_sass]
---

# CSS cascade layers off by default

## Context

`@layer` lets site CSS win without specificity fights, but browsers without layer support ignore whole layer blocks.

## Decision

`modootoday.css_layers` (`@layer mt.*`) is opt-in, default false.

## Consequences

Default output is safe on older browsers; sites that want layers turn them on.
