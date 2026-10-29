---
id: adr:modootoday/20261029211900
title: Rules v1 final and public API frozen for 1.0; 1.0 is the complete roadmap
status: active
created: 2026-10-29T21:19:00Z
updated: 2026-10-29T21:19:12Z
rel:
  governs: [docs/api.md, RULES.md, docs/roadmap.md]
---

# Rules v1 final and public API frozen for 1.0; 1.0 is the complete roadmap

## Context

The roadmap had split work into 1.0 and 1.x: Japanese docs, the components.yml slot contract, right-to-left support, math and diagram guidance, and visual regression checks were 1.x or non-goals. RULES.md was still marked `md-components v1 (draft)`. The maintainer approved the rules and decided that 1.0 means the whole roadmap is done.

## Decision

- RULES.md is `md-components v1`, final. Every file that carried the `v1 (draft)` header now says `v1`. A rule is only removed or made stricter in a major version; new optional patterns can arrive in a minor version.
- The public API on docs/api.md is frozen for 1.0. Names can be added in 1.x minors; nothing listed is removed or changed incompatibly before 2.0. This extends [[adr:modootoday/20261029204501]].
- `md-*` classes and `--md-*` properties are deprecated as of 1.0 and removed in 2.0, as in [[adr:modootoday/20261029204442]].
- 1.0 ships only when every roadmap item is done: the former 1.x items (Japanese docs and example guides, slot contract, RTL, math and diagram guidance, visual regression baselines, post archives) move into 1.0. The roadmap page has no 1.x list.

## Consequences

The docs site gains /ja/ with the same coverage as /ko/. The roadmap page lists 1.0 items with status badges. Release tooling and the checker are unchanged by this decision.
