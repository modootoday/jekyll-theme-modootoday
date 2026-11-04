---
id: adr:modootoday/20261104061809
title: Plain Jekyll fixtures pin the adoption step and nested layout paths on both stacks and remote_theme
status: active
created: 2026-11-04T06:18:09Z
updated: 2026-11-04T06:19:09Z
rel:
  governs: [test/fixtures/sites]
---

# Plain Jekyll fixtures pin the adoption step and nested layout paths on both stacks and remote_theme

## Context

The first step of adopting the theme is changing one line in an existing Jekyll site; nothing tested that. New context layouts are planned under `_layouts/<group>/<name>.html` (`layout: group/name`), which Jekyll's documentation does not describe; Jekyll 3.10 and 4.4 read layouts recursively in `LayoutReader` and name them by path, for the site and the theme alike.

## Decision

- `test/fixtures/sites/minima-shaped/` is the site `jekyll new` writes, verbatim except the theme line and a fixed post date. `test/consumer/minima_shaped_test.rb` adds minima's `author:` key, builds it on the active bundle without `-q` and asserts no layout warning, the About link in the header, the home post list, the doc pipeline on `about` and the 404 page, the post's author and date, and a clean `modootoday-check`. jekyll-feed stays in the plugins only where the bundle has it.
- `test/fixtures/sites/nested-layouts/` has site layouts `docs/endpoint` (on the theme's `doc`) and `learn/lesson` (on `docs/endpoint`), used from front matter and from `defaults`; `test/layouts/families/nested_layout_test.rb` builds it and checks that the child's layout values win along the chain. A second test runs Jekyll's `LayoutReader` against a theme root with layouts in a subfolder, so the theme side is pinned without shipping a nested layout yet.
- CI runs both on github-pages 232 and Jekyll 4 (`rake test` in `ci.yml`), and the starters workflow builds both fixtures with `remote_theme` pinned to the commit.

## Consequences

The registry phase can add `_layouts/<group>/` files on a tested fact. The acceptance covers the pieces shipped now; the feed link, social links and SEO keys of the same adoption step come with the site variable resolvers and get their assertions then.
