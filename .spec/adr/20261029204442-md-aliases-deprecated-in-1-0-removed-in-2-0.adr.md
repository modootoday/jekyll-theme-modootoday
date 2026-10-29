---
id: adr:modootoday/20261029204442
title: "md-* aliases deprecated in 1.0, removed in 2.0"
status: superseded
created: 2026-10-29T20:44:42Z
updated: 2026-10-29T22:42:00Z
rel:
  supersedes: [adr:modootoday/20261029202150]
---

# md-* aliases deprecated in 1.0, removed in 2.0

## Context

The md-* class names and --md-* custom properties were kept as aliases of mt-* / --mt-* since the rename. Before 1.0 the project needs a fixed date for their removal so adopters can plan.

## Decision

md-* and --md-* stay as aliases through all 1.x releases and are marked deprecated in 1.0. They are removed in 2.0. modootoday-check warns when a site's own Sass uses md-* or --md-* names (outside the theme's own partials). The data-c and class names emitted for components are covered by the same policy.

## Consequences

Sites have the whole 1.x line to migrate, with a checker warning pointing at each use. The theme carries the alias CSS until 2.0.
