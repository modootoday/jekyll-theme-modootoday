---
id: adr:modootoday/20261103053805
title: search.js stays a classic script through 1.x
status: superseded
created: 2026-11-03T05:38:05Z
updated: 2026-11-04T06:19:31Z
rel:
  governs: [assets/js/modootoday/chrome/search.js]
---

# search.js stays a classic script through 1.x

## Context

The implementation design split search into ES modules (`search`, `match`, `render`). Doing so changes the script tag on every page that has search, so every such site's HTML changes in a minor release. Search options shipped without the split (adr:modootoday/20261103033053): `search.js` stays a classic script, and its match rules are repeated in `text/normalize.js`, which the filter module imports. A parity test runs the same queries through both.

## Decision

- `search.js` stays a classic script for all 1.x releases. The match rules stay duplicated, and the parity test keeps the two in step; a change to one fails the test until the other follows.
- The module split is a 2.0 change, listed in the 2.0 upgrade notes together with the tag change.

## Consequences

Sites that pin a 1.x theme keep byte-identical search markup. Contributors change matching in two places, guarded by the parity test.
