---
id: adr:modootoday/20261029202149
title: Publish DTCG tokens.json as a read-only CI artifact generated from Sass
status: active
created: 2026-10-29T20:21:48Z
updated: 2026-10-29T20:21:50Z
rel:
  governs: [script/tokens-json]
---

# Publish DTCG tokens.json as a read-only CI artifact generated from Sass

## Context

Design tools and other stacks want tokens in the DTCG format, but keeping two sources of truth drifts.

## Decision

The Sass maps stay the only source. `script/tokens-json` derives a DTCG `tokens.json` (groups primitive, base, light, dark; aliases as `{primitive.*}`); CI uploads it as an artifact and it is not committed or shipped in the gem. A test checks it against the built CSS custom properties.

## Consequences

Consumers get a stable machine-readable file per commit; editing the JSON by hand has no effect. Dimensions are emitted as strings, a simplification of the latest DTCG draft.
