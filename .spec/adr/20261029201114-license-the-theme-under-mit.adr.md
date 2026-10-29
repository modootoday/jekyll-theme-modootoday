---
id: adr:modootoday/20261029201114
title: License the theme under MIT
status: active
created: 2026-10-29T20:11:13Z
updated: 2026-10-29T20:11:20Z
rel:
  governs: [LICENSE]
---

# License the theme under MIT

## Context

A theme is copied into user sites; a permissive license matches Jekyll, minima and most gem themes.

## Decision

MIT; `LICENSE` ships in the gem; gemspec `license = "MIT"`.

## Consequences

Anyone may reuse layouts, Sass and JS with attribution.
