---
id: adr:modootoday/20261103072042
title: byte-exact folders are compared by sha256 and must be folders Jekyll copies as they are
status: active
created: 2026-11-03T07:20:41Z
updated: 2026-11-03T07:20:55Z
rel:
  governs: [lib/modootoday/check/build]
---

# byte-exact folders are compared by sha256 and must be folders Jekyll copies as they are

## Context

A site that publishes data (a small static API, downloads, a `security.txt`) needs those files served exactly as committed. Jekyll copies a file without front matter as it is, but it renders a file with front matter, converts Markdown (GitHub Pages also renders Markdown without front matter through `jekyll-optional-front-matter`) and Sass, reads `_data/` as data and skips excluded paths and names starting with `_`, `.`, `#` or `~`. Nothing told a site when one of its "raw" files stopped being raw.

## Decision

- `modootoday-check SRC SITE --byte-exact=DIR[,DIR]`: every file under each source folder must be in SITE at the same path with the same SHA-256. A missing or different file is an error that prints both digests (shortened).
- The folder itself fails when it does not exist, when a path segment starts with `_` or `.` (a `_data/` folder included) unless `include:` lists that segment, or when `exclude:` covers it.
- A file fails when its name or a parent segment would be skipped (same `include:` exception), when it starts with front matter, or when its extension is one Jekyll converts (Markdown, Textile, Sass, CoffeeScript).
- The option is a checker option only: no `_config.yml` key, because the folders are a fact about the build the site wants to prove, not a theme setting.

## Consequences

The example publishes `api/plugins.json` and CI runs the checker with `--byte-exact=api` on every Ruby stack and on the real Pages builder output. An empty folder is a warning, not an error.
