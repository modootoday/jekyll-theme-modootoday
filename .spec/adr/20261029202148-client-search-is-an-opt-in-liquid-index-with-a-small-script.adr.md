---
id: adr:modootoday/20261029202148
title: Client search is an opt-in Liquid index with a small script
status: active
created: 2026-10-29T20:21:48Z
updated: 2026-10-29T20:21:50Z
rel:
  governs: [_includes/modootoday/search.json]
---

# Client search is an opt-in Liquid index with a small script

## Context

Docs sites want search, but GitHub Pages cannot run plugins and a gem theme cannot add pages on Jekyll 3.10.

## Decision

The theme ships `_includes/modootoday/search.json`; a site opts in by adding a `search.json` page that includes it. The header search box and `search.js` render only when `/search.json` exists. `search.js` does substring matching on title and text, loads the index on first focus, and must stay under 1 KB compressed (tested).

## Consequences

No external service or build step. Large sites may outgrow substring search; a heavier engine can be added later without changing the index URL.
