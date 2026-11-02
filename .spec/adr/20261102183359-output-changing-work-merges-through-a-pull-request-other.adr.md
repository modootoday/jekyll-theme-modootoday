---
id: adr:modootoday/20261102183359
title: Output-changing work merges through a pull request; other changes push to main
status: active
created: 2026-11-02T18:33:59Z
updated: 2026-11-02T18:34:31Z
rel:
  governs: [CONTRIBUTING.md]
---

# Output-changing work merges through a pull request; other changes push to main

## Context

The maintainer works alone, and `main` has no branch protection or required reviewers. A pull request therefore adds no review wait; what it adds is CI ordering. The visual regression check blocks only on pull requests and only reports on pushes to `main`. Sites that use `remote_theme` without a tag pick up `main` as soon as it moves, so a change that alters the built HTML or CSS should pass the Ruby/Jekyll matrix, the classic Pages builder and the screenshot diff before it lands.

## Decision

- Changes that can alter what a site renders or ships merge through a pull request: `_includes`, `_layouts`, `_sass`, `assets`, `lib`, `exe`, `i18n`, the gemspec and dependency updates. The pull request merges as soon as every check passes; nobody waits for a review.
- Changes that cannot alter site output (tests, `docs/`, `.spec/`, `qa/`, CI workflows, repository metadata) push straight to `main`.
- When unsure, use a pull request.

## Consequences

Contributors from forks still use pull requests for everything, as `CONTRIBUTING.md` says. A direct push to `main` still runs CI after the fact, so a broken docs or test change shows up there instead of before it lands.
