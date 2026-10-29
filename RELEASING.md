# Releasing

Releases are published only from a `v*` tag by `.github/workflows/release.yml`, through the protected `rubygems` environment (a maintainer approves the run) and RubyGems trusted publishing (OIDC, no API key).

## Checklist

1. **Version.** `spec.version` in the gemspec, the `## [X.Y.Z]` heading and link in `CHANGELOG.md`, and the install snippets in `README.md`, `README.ko.md`, `docs/install.md`, `docs/index.md` and their `ko/` pages agree (`test/version_test.rb` enforces this).
2. **Changelog.** Move the Unreleased entries under `## [X.Y.Z] - YYYY-MM-DD`; list deprecations (see the public API page).
3. **CI green on `main`** with no warnings: GitHub Pages stack, Jekyll 4 (oldest and newest Ruby), the Jekyll 3.9 floor, JS, tokens and docs QA.
4. **Visual review.** Open the docs site and the kitchen sink in light and dark at phone and desktop widths, in English and Korean; compare with the QA screenshots artifact.
5. **Trusted publisher.** On rubygems.org, the gem (or, before the first release, a *pending* trusted publisher) must point at this repository, workflow `release.yml` and environment `rubygems`. A pending publisher expires if no gem is pushed in time; register it again if it has expired.
6. **Tag.** `git tag vX.Y.Z && git push origin vX.Y.Z`. The workflow checks that the tag equals the gem version.
7. **Approve** the `rubygems` environment deployment when the run asks for it.
8. **After release.** Check the gem page, switch `docs/_config.yml` from `remote_theme: …@main` to `@vX.Y.Z`, and open an Unreleased section.
