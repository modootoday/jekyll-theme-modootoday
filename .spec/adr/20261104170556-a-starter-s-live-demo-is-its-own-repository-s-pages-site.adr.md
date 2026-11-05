---
id: adr:modootoday/20261104170556
title: A starter's live demo is its own repository's Pages site
status: active
created: 2026-11-04T17:05:56Z
updated: 2026-11-05T13:16:01Z
rel:
  governs: [example/starters.yml]
  evidence: [research:modootoday/20261104170510]
---

# A starter's live demo is its own repository's Pages site

## Context

[[adr:modootoday/20261103202417]] names the starter repositories. [[adr:modootoday/20261104170401]] turns starter demos into the theme's live demos with a showcase bar. That left open where a demo is hosted and what its address is.

Options weighed:
- A separate demo repository per starter: twice the repositories and two copies of the content.
- Subpaths of the docs site built by the theme's CI: a heavier docs build, and not the starter a visitor would actually copy.
- Each starter repository's own Pages site.

The maintainer chose the last.

## Decision

- A starter's live demo is the GitHub Pages site of its own repository: `https://modootoday.github.io/jekyll-theme-modootoday-<name>-starter/`, where `<name>` is the starter's `name` in `example/starters.yml`. There are no separate demo repositories.
- **Showcase on the demo only:** the repository's Pages workflow builds with `--config _config.yml,_config.demo.yml`. `_config.demo.yml` holds only the showcase settings, and a site generated from the starter builds without it.
- **Template repositories:**
  - Every starter repository is marked as a template repository.
  - The showcase's `use_url` is `https://github.com/modootoday/jekyll-theme-modootoday-<name>-starter/generate`.
- **Links from the docs:**
  - The docs link a demo by that address, opening in a new tab.
  - The demo address and the generate address are derived from the manifest name, never written by hand elsewhere.

## Consequences

- One repository per starter carries its source, its template and its demo, and the names follow [[adr:modootoday/20261103202417]] without a second naming rule.
- `rake starters:render` writes `_config.demo.yml` and a Pages workflow that layers it.
- Publishing a starter repository (and turning on its Pages site and template flag) is a maintainer step, after 1.5.0, as the starter plan already says.
- Until a starter repository is published, the docs keep their own demo pages; the move happens in the change that publishes the starters.

## Amendment: how the demo build layers its config (1.6.0)

- **Merge, not a config list.** The published workflow builds with `actions/jekyll-build-pages`, which takes no list of config files ([[adr:modootoday/20261104171142]]). The rendered `pages.yml` therefore copies `_config.yml` aside, merges `_config.demo.yml` into it (a deep merge, as Jekyll merges a config list), builds, and moves the copy back before `modootoday-check`. The check then reads the starter's own `_config.yml`, so it does not warn that the showcase is on in `_config.yml`. The `jekyll4` tree uses the same two steps.
- **The guard.** Both steps carry `if: github.repository == '<repo>'`. A fork or a repository created from the template keeps `_config.demo.yml` but never merges it.
- **The checker** reports pages without `noindex` only in a build that shows the showcase, since such a copy keeps `_config.demo.yml` and builds without it.
- **Manifest.** `example/starters.yml` holds the documentation address once (`demo.docs_url`); per starter, a one-line `description` (the repository description), `showcase: {style}` and the `qa:` pages of its demo build. The repository's website is the demo address and its topics are `jekyll`, `jekyll-theme`, `github-pages`, `starter-template` and the starter's name; `rake starters:repos` prints them.
