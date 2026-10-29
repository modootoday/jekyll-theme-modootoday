---
id: adr:modootoday/20261029202150
title: Keep md-* aliases past v0.3
status: active
created: 2026-10-29T20:21:48Z
updated: 2026-10-29T20:21:50Z
rel:
  governs: [_sass/modootoday/tokens/_aliases.scss]
---

# Keep md-* aliases past v0.3

## Context

The CHANGELOG planned to remove the deprecated `--md-*` and `md-*` aliases in v0.3, but sites built on v0.1 have not had a release that carries the `mt-` names yet.

## Decision

Keep the aliases through v0.3 and v0.4; removal moves to a later minor after a release with the new names, announced in the CHANGELOG.

## Consequences

Slightly larger CSS and HTML for now; no breaking change for v0.1 sites.
