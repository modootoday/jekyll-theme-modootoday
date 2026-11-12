---
id: adr:modootoday/20261112023954
title: "edit_url: auto and build_link read site.github through one include, and an explicit URL wins"
status: active
created: 2026-11-12T02:39:54Z
updated: 2026-11-12T02:40:09Z
rel:
  governs: [_includes/modootoday/meta/github.html, _includes/modootoday/page-meta.html, lib/modootoday/check/config/keys/pages/edit_url.rb]
  depends_on: [adr:modootoday/20261109141321]
---

# edit_url: auto and build_link read site.github through one include, and an explicit URL wins

## Context

G1 and G3 in [[adr:modootoday/20261109141321]]: a site on GitHub Pages had to write its own "Edit this page" prefix, although Pages already knows the repository, branch and folder it builds, and a reader had no way to see which commit a page came from. Spike S1 read the gem sources: `site.github` comes from jekyll-github-metadata; `repository_url`, `build_revision` and the `source` branch and path need only the repository name, but `source` falls back to `gh-pages` or `master` at the root when the Pages API cannot be read, and the plugin raises `NoRepositoryError` when it has no repository name at all.

## Decision

- `_includes/modootoday/meta/github.html` is the one owner of GitHub-derived URLs: `mt_gh_repo`, `mt_gh_edit` (repository, `/edit/`, source branch, source folder ending in `/`) and `mt_gh_rev`. It reads `site.github` only when `edit_url: auto` or `build_link: true` asks, so a site that uses neither never touches the plugin.
- `edit_url` takes `auto` as well as a URL; an explicit URL always wins. `build_link: true` adds "Built from <7-character commit>" to the page footer line, linked to the commit, only when both the repository and the commit are known. Either is left out quietly when `site.github` is empty. The footer row's sheet follows the same resolved values.
- A `github:` map in `_config.yml` stands in for the plugin outside GitHub Pages. `modootoday-check` warns when `auto` or `build_link` is set without `--github-pages`, the jekyll-github-metadata plugin or a `github:` map.
- New label `page.built` ("Built from [commit]") in all 23 catalogs; no new CSS.
- The docs site keeps its explicit `edit_url` and leaves `build_link` off: its CI builds have no Pages token, so `source` would fall back, and a build commit would change the visual baselines on every run.

## Consequences

- Configuration guide (en, ko, ja): `auto`, `build_link`, the `github:` map and the fallback caveat.
- Tests: `test/theme/chrome/page_meta_test.rb` (auto from the source folder and from the root, an explicit URL winning, `edit: false`, the build link, nothing without `site.github`); the checker's message snapshot and config test.
