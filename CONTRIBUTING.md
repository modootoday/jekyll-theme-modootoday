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

## Releasing (maintainers)

1. Move the `Unreleased` notes in `CHANGELOG.md` under the new version and bump `spec.version` in the gemspec.
2. Push a tag `vX.Y.Z`. `.github/workflows/release.yml` runs the tests and publishes to RubyGems through trusted publishing (OIDC, no API key) in the `rubygems` GitHub environment.
