---
id: adr:modootoday/20261105073859
title: "The docs site follows main, not the latest release tag"
status: active
created: 2026-11-05T07:38:59Z
updated: 2026-11-05T08:57:32Z
rel:
  governs: [docs/_config.yml]
---

# The docs site follows main, not the latest release tag

## Context

RELEASING step 8 said to switch `docs/_config.yml` from `remote_theme: …@main` to the new tag after each release. No release ever did it: from the first docs site through 1.5.0 the line has read `@main`. The docs site is also the theme's dogfooding site and the target of the docs QA suite. It documents and demonstrates features as they land on `main`, so a site pinned to the last tag would render the next release's pages without the theme code they describe.

## Decision

- The docs site keeps `remote_theme: modootoday/jekyll-theme-modootoday@main`.
- RELEASING step 8 only checks the gem page and the GitHub Release.
- What a release pins is in the install examples, the README and the starters, which the version commit updates (`~> X.Y`, `@vX.Y.Z`).
- Pages that describe something not yet released say which version adds it.

## Consequences

- The live docs can describe an unreleased feature between two releases. The upgrade guide and the CHANGELOG `[Unreleased]` section name the version, so a reader on the latest gem can tell.
- No commit after a release touches the docs pin.
