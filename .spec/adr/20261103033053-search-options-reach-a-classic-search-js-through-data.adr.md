---
id: adr:modootoday/20261103033053
title: Search options reach a classic search.js through data attributes; its limit is 1.2 KiB
status: active
created: 2026-11-03T03:30:53Z
updated: 2026-11-03T03:31:29Z
rel:
  governs: [_includes/modootoday/search.json, assets/js/modootoday/search.js]
  supersedes: [adr:modootoday/20261029202148]
---

# Search options reach a classic search.js through data attributes; its limit is 1.2 KiB

## Context

The header search indexed 300 words of each page and post and matched the whole query as one substring. Content sites need longer text, collection documents, front matter such as descriptions and tags, and Korean queries whose spacing varies. The design proposed turning `search.js` into an ES module split into search, match and render files. That changes the script tag on every page with search, and `search-keys.js` reads `box.mtRender` from it, so it would have to become a module too.

## Decision

- The theme still ships `_includes/modootoday/search.json` and a site opts in with a `search.json` page; the index URL and the box markup are unchanged.
- `modootoday.search` shapes the index in Liquid (`words`, `0` for all; `collections` with output, after the posts; `fields` before the text; `exclude` URL prefixes) and the matching (`match: terms`, `compact: true`, `results`). The matching keys reach the script as `data-match`, `data-compact` and `data-results` on `.mt-search`, written only when set.
- `search.js` stays a classic deferred script, so pages without the keys keep their HTML byte for byte and `search-keys.js` keeps working as before. It carries its own few lines of the rules in `text/normalize.js` (NFC, lower case, every word, the compact comparison); a test runs both on the same queries.
- Every comparison is in NFC, also by default; for text already in NFC the results are the same as before.
- `search.js` must stay within 1.2 KiB compressed (it is 1,205 bytes deflated, 1,217 gzip).
- `modootoday-check` validates the keys and warns when the built `search.json` is over 1.5 MB.

## Consequences

The default search is the old one. Search by initial consonants and stemming stay out of scope; a heavier engine can still be added later without changing the index URL. A change to the matching rules is made in both `search.js` and `text/normalize.js`, which the parity test enforces.
