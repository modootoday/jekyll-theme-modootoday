---
id: adr:modootoday/20261103202417
title: Starter repositories are named jekyll-theme-modootoday-<name>-starter
status: active
created: 2026-11-03T20:24:17Z
updated: 2026-11-03T20:25:09Z
rel:
  governs: [example/starters.yml]
---

# Starter repositories are named jekyll-theme-modootoday-<name>-starter

## Context

The theme design fixed the starter repository names as `jekyll-theme-modootoday-<name>-starter`. The starters manifest added with [[adr:modootoday/20261103152846]] used the shorter `modootoday/<name>-starter` instead. No starter repository is published yet.

## Decision

- Every starter is published to `modootoday/jekyll-theme-modootoday-<name>-starter`, where `<name>` is the starter's `name` in `example/starters.yml`.
- This applies to docs, blog and landing, and to every starter added later.
- The manifest stays the only list of repository names.

## Consequences

- A repository name says which theme it belongs to, and the starters sort together beside the theme repository.
- The names are longer than the short form. Nothing published moves, because no starter repository exists yet.
