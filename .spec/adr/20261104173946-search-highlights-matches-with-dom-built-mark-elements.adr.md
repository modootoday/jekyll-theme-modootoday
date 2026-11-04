---
id: adr:modootoday/20261104173946
title: Search highlights matches with DOM-built mark elements
status: active
created: 2026-11-04T17:39:45Z
updated: 2026-11-04T17:40:09Z
rel:
  governs: [assets/js/modootoday/chrome/search.js]
---

# Search highlights matches with DOM-built mark elements

## Context

Header search results showed the title and a snippet without marking where the query matched, so a reader had to find the words in a 100-character snippet. The docs site runs under a strict CSP, and the result list is built from index text that sites control.

## Decision

- `chrome/search.js` fills the title and snippet spans with text nodes and wraps each case-insensitive occurrence of a query word (the whole query, or every word with `match: terms`) in a `mark` element built with `createElement` and `textContent`. No `innerHTML` and no `style` attribute, so index text that looks like markup stays text.
- The search component sheet styles `.mt-search-results mark` with the `accent` fill, inherited colour and weight 600.
- `search.js` grows from 1,279 to 1,500 bytes gzip; its cap rises from 1,408 to 1,664 bytes on its registry row (measured plus 10%). It loads on first use only, so pages that never search load nothing more.

## Consequences

A title stored in decomposed Unicode is shown as stored and is not marked, as the match itself compares in NFC. The `mark` element is part of the result markup sites may style.
