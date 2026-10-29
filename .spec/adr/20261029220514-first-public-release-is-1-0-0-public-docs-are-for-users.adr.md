---
id: adr:modootoday/20261029220514
title: First public release is 1.0.0; public docs are for users
status: active
created: 2026-10-29T22:05:14Z
updated: 2026-10-29T22:05:21Z
rel:
  governs: [jekyll-theme-modootoday.gemspec]
  supersedes: [adr:modootoday/20261029204503]
---

# First public release is 1.0.0; public docs are for users

## Context

The owner decided there is no 0.5 release: 1.0 is the point where the whole roadmap is done, and it is the first version published on RubyGems. The public docs still announced 0.5.0, pointed `since:` badges at milestones that were never released, and mixed in development status and QA detail.

## Decision

- The first published version is 1.0.0 (tag `v1.0.0`). The gemspec, CHANGELOG (`## [1.0.0]`) and install snippets (`~> 1.0`, `@v1.0.0`) agree, enforced by `test/version_test.rb`.
- The internal milestones 0.1 to 0.5 are kept in CHANGELOG.md under "Pre-release history" inside the 1.0.0 entry; the docs changelog shows only 1.0.0.
- Every `since:` badge in the docs names 1.0.
- README and `docs/` are for users: what the theme does, how to use it, compatibility and migration. Development status, QA detail and release procedure live in CONTRIBUTING.md, RELEASING.md and `.spec/`. The roadmap page lists supported features, compatibility and direction.
- The governance files from the superseded decision stay.

## Consequences

Users never see a version that was not published. Sites that built from `main` before 1.0.0 follow the upgrade table row for pre-1.0 builds.
