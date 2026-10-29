# Releasing

The first release is **1.0.0** (tag `v1.0.0`). No earlier version was published; the 0.x milestones are only recorded under "Pre-release history" in `CHANGELOG.md`.

Releases are published only from a `v*` tag by `.github/workflows/release.yml`, through the protected `rubygems` environment (a maintainer approves the run) and RubyGems trusted publishing (OIDC, no API key).

## Checklist

1. **Version.** Check the packaged files with `gem build` and `gem spec jekyll-theme-modootoday-X.Y.Z.gem files` (only `_layouts`, `_includes`, `_sass`, `assets`, `exe`, `lib`, LICENSE, READMEs, RULES.md and CHANGELOG.md; no `.spec/`, `RELEASING.md`, `docs/` or `example/`). `spec.version` in the gemspec, the `## [X.Y.Z]` heading and link in `CHANGELOG.md`, and the install snippets in `README.md`, `README.ko.md`, `docs/guides/install.md`, `docs/index.md` and their `ko/` pages agree (`test/version_test.rb` enforces this).
2. **Changelog.** Change `## [X.Y.Z] - Unreleased` to `## [X.Y.Z] - YYYY-MM-DD` (for 1.0.0: `## [1.0.0] - YYYY-MM-DD`); list public API changes (see the public API page). Point the `[X.Y.Z]` link at the tag (`…/releases/tag/vX.Y.Z`) and add `[Unreleased]: …/compare/vX.Y.Z...HEAD` with an empty `## [Unreleased]` section.
3. **CI green on `main`** with no warnings: GitHub Pages stack, Jekyll 4 (oldest and newest Ruby), the Jekyll 3.9 floor, JS, tokens and docs QA, plus the `Lighthouse` budget workflow (median of 3 runs) and the `Visual regression` report for the last pushes.
4. **Visual review.** Open the docs site and the kitchen sink in light and dark at phone and desktop widths, in English, Korean and Japanese; compare with the QA screenshots artifact. `RULES.md` says `md-components v1` and Status final (done 2026-10-30).
5. **Trusted publisher.** On rubygems.org, the gem (or, before the first release, a *pending* trusted publisher) must point at this repository, workflow `release.yml` and environment `rubygems`. For 1.0.0 this is the pending publisher: open rubygems.org → Trusted publishers and check it is still listed and not expired (a pending publisher expires if no gem is pushed in time); register it again with the same values if it has.
6. **Tag.** `git tag vX.Y.Z && git push origin vX.Y.Z` (first release: `git tag v1.0.0 && git push origin v1.0.0`). The workflow checks that the tag equals the gem version.
7. **Approve** the `rubygems` environment deployment when the run asks for it.
8. **After release.** Check the gem page, and switch `docs/_config.yml` from `remote_theme: …@main` to `@vX.Y.Z`.
