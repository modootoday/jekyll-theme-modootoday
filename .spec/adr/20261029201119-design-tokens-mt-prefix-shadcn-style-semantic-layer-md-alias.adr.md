---
id: adr:modootoday/20261029201119
title: "Design tokens: --mt-* prefix, shadcn-style semantic layer, --md-* aliases"
status: active
created: 2026-10-29T20:11:13Z
updated: 2026-10-29T20:11:20Z
rel:
  governs: [_sass]
---

# Design tokens: --mt-* prefix, shadcn-style semantic layer, --md-* aliases

## Context

`--md-*` reads as 'markdown' and can collide with other libraries; users know shadcn/ui token names.

## Decision

Three layers: primitives `--mt-p-*`, semantic (`--mt-background`, `--mt-primary`, …), component tokens. `--md-*` properties and `md-*` classes remain as deprecated aliases for one minor version (removal planned for v0.3). Later decision: no aliases ship in 1.0.0, see [[adr:modootoday/20261029224200]].

## Consequences

Overrides target semantic tokens; aliases cost a little CSS until removal.
