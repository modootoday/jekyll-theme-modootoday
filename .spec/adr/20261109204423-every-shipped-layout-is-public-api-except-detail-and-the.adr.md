---
id: adr:modootoday/20261109204423
title: "Every shipped layout is public API except detail, and the Public API page lists each one"
status: active
created: 2026-11-09T20:44:22Z
updated: 2026-11-09T20:44:43Z
rel:
  governs: [docs/reference/api.md]
---

# Every shipped layout is public API except detail, and the Public API page lists each one

## Context

The Public API page named 8 stable layouts while `_layouts/` ships 47 and the Layouts section documents almost all of them as ready to use ([[audit:modootoday/20261109200220]] O1). Readers could not tell whether `layout: pricing` was safe to depend on. Rule R6 of [[adr:modootoday/20261109200230]] says every shipped layout is in the Public API list or explicitly marked internal.

## Decision

- Every layout in `_layouts/` is public API under the existing deprecation policy, except `detail`, the base that the five detail-page layouts extend. `detail` is marked internal: a site uses one of the detail layouts instead.
- The Public API page has a Layouts table: one row per page that documents the layouts' front matter, then an Internal row. The Stable names table points at it.
- A docs check compares the table's layout names with `_layouts/`; a new layout lands with its row.

## Consequences

- Layout names and their documented front matter change only through the deprecation policy.
- A new base layout that sites should not use directly is added to the Internal row in the same change.
