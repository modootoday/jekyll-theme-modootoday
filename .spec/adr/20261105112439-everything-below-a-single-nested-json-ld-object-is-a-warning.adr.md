---
id: adr:modootoday/20261105112439
title: "Everything below a single nested JSON-LD object is a warning until 2.0, and untyped nested objects need no type"
status: active
created: 2026-11-05T11:24:39Z
updated: 2026-11-05T11:24:54Z
rel:
  governs: [lib/modootoday/check/build/structured_data/nested.rb, docs/layouts/detail/event.md]
---

# Everything below a single nested JSON-LD object is a warning until 2.0, and untyped nested objects need no type

## Context

adr:modootoday/20261103053804 schedules the check of single nested objects (`offers`, `organizer`, `acceptedAnswer`) for 1.6 as warnings. Before 1.6 the checker skipped such an object entirely, so not only its required properties went unchecked: its type and property names, URLs and dates did too. Objects in arrays were already walked, with errors. The theme's own event layout writes `offers` from `tickets:` with only a `url`, which the `Offer` rule reports as lacking a price.

## Decision

- Every finding below a single nested object, at any depth and including arrays inside it, is a warning ending in "fix it now (in a nested object this is an error from 2.0)". Recommended-property warnings (`--schema-recommended`) stay as they are.
- A nested object without `@type` is not asked for one; schema.org infers it from the property. Only top-level `@graph` nodes need `@type`.
- An empty answer of a `Question` stays an error, as in 1.5.
- The event layout keeps writing `offers` from `tickets:`; the Detail layouts page shows `schema: {offers: ...}` with a price, and the docs event demo uses it so the docs build has no warning. A front matter price key for events is left for later.

## Consequences

The 1.5 errors are unchanged, so no site fails a build it passed. An event page with `tickets:` and no `schema.offers` gets two warnings, and fails `--strict`, until it states a price. The 2.0 change is one line: report through the ctx instead of the demoted view.
