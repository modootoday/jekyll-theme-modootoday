# Contributing

English is the canonical language. `README.md`, `RULES.md` and the English pages in `docs/` are the source of truth; `README.ko.md` and the `docs/ko/` (and `docs/ja/`) pages are translations and start with a note saying so. Change the English text first, then update the translations in the same pull request when you can. When they differ, English wins.


1. Fork and branch from `main`. Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:` …).
2. Keep layouts and includes **Liquid only** — no custom Ruby plugins — so the theme keeps working with `remote_theme` on GitHub Pages.
3. `README.md` and `README.ko.md` keep the same sections (checked by `test/readme_test.rb`). The Commands table is generated from `exe/modootoday-check`: run `script/readme-commands` after changing an option.
4. Rule changes (`RULES.md`) need a matching change in the includes, the checker and the tests, plus a CHANGELOG entry.
5. Run the checks for both stacks before opening a PR:

```sh
BUNDLE_GEMFILE=gemfiles/github-pages.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/github-pages.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle exec rake
npm ci && npm test
gem build jekyll-theme-modootoday.gemspec
```

Changes to `docs/` or the theme's look: `qa/build-docs.sh docs/_site && npm run qa` takes screenshots (4 widths, light and dark, every language) and runs axe, token contrast and size budgets; CI runs the same job and uploads `qa-out/`.

### Visual regression

`npm run qa:visual` screenshots four pages (home, kitchen sink, configuration, Korean home) at 360, 1024 and 1440 px in light and dark mode and compares each shot with a PNG in `qa/visual-baseline/` using [pixelmatch](https://github.com/mapbox/pixelmatch). A shot fails when more than 0.1 % of its pixels differ by more than the colour threshold 0.1, or when its size changed; the failing shot and a diff image go to `qa-out/visual/`. Animations, the caret and the "Last updated" date are frozen.

```sh
qa/build-docs.sh docs/_site
npm run qa:visual            # compare
npm run qa:visual:update     # accept the current look as the new baseline
node qa/visual.mjs docs/_site --baseline DIR --out DIR --threshold 0.1 --max-diff 0.001 --report
```

Fonts and anti-aliasing differ between operating systems, so a baseline is only comparable on the machine image that made it. Make and compare baselines on one machine; to compare two versions, run `--update` on the old build and compare the new build in the same place. The CI workflow `visual.yml` does exactly that: it builds `docs/` at the base commit and at the pushed commit on the same runner, compares them and lists the differences in the job summary with the images in the `visual` artifact. It is report-only and never fails the build; review the diffs when you change the theme's look.

## Releasing (maintainers)

1. Move the `Unreleased` notes in `CHANGELOG.md` under the new version and bump `spec.version` in the gemspec.
2. Push a tag `vX.Y.Z`. `.github/workflows/release.yml` runs the tests and publishes to RubyGems through trusted publishing (OIDC, no API key) in the `rubygems` GitHub environment.

## Conduct, security and releases

- This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
- Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md), not in public issues.
- Releases follow [RELEASING.md](RELEASING.md).
