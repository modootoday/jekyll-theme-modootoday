---
id: adr:modootoday/20261029203024
title: Front-matter-less source mode as a third twin option
status: active
created: 2026-10-29T20:30:24Z
updated: 2026-10-29T20:45:05Z
rel:
  governs: [lib]
---

# Front-matter-less source mode as a third twin option

## Context

ADR 20261029201116 treated one stub per page as unavoidable on classic GitHub Pages. Further research found that `jekyll-optional-front-matter`, a GitHub Pages default plugin, turns a `.md` file without front matter into a rendered page and keeps the original static file unless `remove_originals: true`. One source file then yields both the HTML page and a verbatim copy at its own path. Measured on github-pages 232 (Jekyll 3.10) and Jekyll 4.4.1 with the plugin listed.

## Decision

Add an opt-in third twin mode, `modootoday.twins: source`, beside stubs and the generator. In this mode a front-matter-less page is its own twin (`/<name>.md`, `/<dir>/index.md`). The checker accepts it only when the mode is set, requires the rendered page and a byte-identical raw copy, and rejects `remove_originals`, `require_front_matter` and redundant stubs. Without the mode, missing front matter stays an error. Layouts and `llms.txt` link to the raw copy when it exists; the generator skips such pages.

## Consequences

Classic Pages sites can drop stubs if they accept no per-page front matter: settings move to path-based `defaults:`, titles come from the first heading, per-page `sections:` is unavailable, and `.md` links in bodies point at the raw twin. Local builds must list `jekyll-optional-front-matter` and `jekyll-titles-from-headings` in `plugins:`. Stubs and the generator stay supported.

Observed on 2026-10-30 (one classic GitHub Pages site with remote_theme, single check): the raw copy at /<name>.md and /<dir>/index.md is served as text/markdown; charset=utf-8 and is byte-identical to the source; llms.txt is text/plain; charset=utf-8; the HTML page carries the alternate text/markdown and describedby links; remote_theme of the public theme works from a private repository, whose Pages site is still public unless access control is set. Cache/CDN behaviour, other extensions and non-English pages were not verified.
