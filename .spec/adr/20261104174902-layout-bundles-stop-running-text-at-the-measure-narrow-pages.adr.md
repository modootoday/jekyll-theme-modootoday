---
id: adr:modootoday/20261104174902
title: Layout bundles stop running text at the measure; narrow pages use the narrow token
status: active
created: 2026-11-04T17:49:01Z
updated: 2026-11-04T17:49:31Z
rel:
  governs: [_sass/modootoday/kit]
---

# Layout bundles stop running text at the measure; narrow pages use the narrow token

## Context

The visual audit measured lines of 141 characters on detail, directory and search pages, 109 on the API reference layout and 89 to 100 on posts: the wide layouts let running text use the whole 75rem container. Legal, resume, links and the search form each had their own width (44rem, 46rem, 30rem, 40rem). The design keeps three width tokens: `measure` (45rem), `container` (75rem) and `narrow` (40rem).

## Decision

- `kit/_measure.scss` holds `mt-kit-measure($scope)`, which the layout bundles include: it caps paragraphs, quotes, `dd` and items of unclassed lists inside the layout's main at `measure`, while grids, tables, code, covers and facts keep the container. Text columns start at the container's start edge.
- The detail, directory, docs-extra, marketing and search layouts include the measure mixin. Legal pages are one centred `narrow` column (title, dates, contents and body); the search form, the link page and the resume use `narrow` too. Posts use `narrow` from the blog sheet.
- Event and job rows of the directory wrap their body under the date tile and image when the row is too narrow, and pager links break long words, which removes the four reflow failures of the audit (320px, 200% text, text spacing).

## Consequences

Each bundle grows by a few dozen bytes. Pages that relied on full-width paragraphs in those layouts get the measure; a site can widen it with the `measure` token. The docs QA checks that no paragraph or plain list item on the audited wide pages is wider than the measure at 1440px.
