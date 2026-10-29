---
id: adr:modootoday/20261029210930
title: "Docs site QA gate: deterministic checks in CI, Lighthouse local only"
status: superseded
created: 2026-10-29T21:09:30Z
updated: 2026-10-29T21:19:06Z
rel:
  governs: [qa]
---

# Docs site QA gate: deterministic checks in CI, Lighthouse local only

## Context

The docs site and kitchen sink are the theme's showcase and its test bed. Visual quality, accessibility, broken links and page weight need checks that block regressions, but browser performance scores vary with CI runner load and external links fail for reasons outside the repository.

## Decision

The docs-qa CI job builds docs/ with this checkout's theme on the github-pages 232 stack and runs only deterministic gates: modootoday-check with twins, qa/links.rb (every internal href and src must resolve inside the baseurl and every #fragment must match an id on the target page; external URLs are never fetched and are listed with --external for manual review, so there is no external-link cache), kitchen-sink coverage of every registered component, and Playwright screenshots with axe, contrast pairs and size budgets. Lighthouse is not a CI gate; qa/lighthouse.sh runs it locally against the built site at the Pages baseurl, and scores are recorded at each release review. The docs site links the brand favicon through `modootoday.favicon: brand` (theme `assets/modootoday/`) so the browser never requests /favicon.ico outside the baseurl.

## Consequences

CI stays stable and fast; a broken internal link or anchor fails the build. External link rot and performance drift are caught only by manual review before a release, which the release checklist covers. A pinned Lighthouse budget in CI can be added later if runner variance proves small.
