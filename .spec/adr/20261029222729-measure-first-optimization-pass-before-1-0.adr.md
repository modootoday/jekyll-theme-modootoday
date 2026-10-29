---
id: adr:modootoday/20261029222729
title: Measure-first optimization pass before 1.0
status: draft
created: 2026-10-29T22:27:29Z
updated: 2026-10-29T22:27:29Z
---

# Measure-first optimization pass before 1.0

## Context

Before 1.0 we optimise only what a measurement shows. The site will grow from 3 to 23 languages. Measurements are from the docs site built with github-pages 232 (Jekyll 3.10), `jekyll build --profile`, on one local machine.

| Measure | Before | After |
| --- | --- | --- |
| `head-meta.html` render, 44 pages, 3 languages | 0.41 s | 0.19 s |
| Full docs build, 3 languages | 2.46-2.56 s | 2.24-2.39 s |
| Full docs build, 23 languages configured | 5.49 s | 2.44 s |
| `head-meta.html` render, 23 languages | 3.17 s | 0.22 s |
| Docs QA (`npm run qa`, 280 screenshots plus axe) | 101 s | 29 s |
| Built HTML output | unchanged (byte-identical) | |
| Gem package | 58 KB, runtime files only | unchanged |
| CSS / JS as built | 29.3 KB (6.4 KB gzip) / 9.2 KB (4.4 KB gzip) | unchanged |
| `search.json` | 96 KB, all languages, fetched on first focus | unchanged |

## Decision

- Hreflang links and the language switcher look up pages through one URL index per page render (`site.pages | map: "url" | join`) and a string `contains`. Before, they ran `site.pages | where` once per language, which costs O(pages² × languages).
- `qa/qa.mjs` checks pages concurrently, `QA_JOBS` pages per colour scheme (default 4). It sorts failures and axe results so the report stays stable.
- No budget changes.

## Consequences

The build time no longer grows with the number of languages. The CI docs QA job is shorter. Candidates we measured but have not changed yet:

- Split `search.json` by language, because the index grows with every translation.
- Cache the Playwright browser in CI.
- Load each component script only on pages that use the component.
- Leave `404.html` out of the search index.
