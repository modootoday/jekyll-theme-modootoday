---
id: adr:modootoday/20261102203210
title: Maintainer work pushes to main; the release is the quality gate
status: active
created: 2026-11-02T20:32:10Z
updated: 2026-11-02T20:33:33Z
rel:
  governs: [CONTRIBUTING.md, RELEASING.md, .github/workflows/ci.yml, .github/workflows/lighthouse.yml, .github/workflows/visual.yml]
  supersedes: [adr:modootoday/20261102183359]
---

# Maintainer work pushes to main; the release is the quality gate

## Context

The previous decision sent output-changing maintainer work through pull requests so the visual check could block before `main` moved. In practice the repository has one maintainer, no forks and no known site that follows `main` untagged; sites pin a release tag. Every push also ran about 35 minutes of browser jobs (docs QA, Lighthouse, visual regression) on top of the four-minute build matrix. Releases already wait for green CI and a maintainer approval of the publish environment.

## Decision

- The maintainer pushes to `main` directly. Pull requests are for outside contributors and for changes the maintainer wants reviewed.
- A push to `main` runs the fast jobs only: the Ruby and Jekyll matrix, the classic Pages builder, JS and tokens. A newer push cancels the older run.
- Docs QA, Lighthouse and visual regression run on pull requests and on manual runs. Before a tag, `RELEASING.md` step 3 starts all three on the release commit, and the visual run compares it with the latest release tag.

## Consequences

A visual or accessibility regression can sit on `main` until the next release check, so it is caught per release instead of per push. The release check compares a whole release's worth of change at once, and every difference has to be explained there.
