# Contributing

1. Fork and branch from `main`. Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:` …).
2. Keep layouts and includes **Liquid only** — no custom Ruby plugins — so the theme keeps working with `remote_theme` on GitHub Pages.
3. Rule changes (`RULES.md`) need a matching change in the includes, the checker and the tests, plus a CHANGELOG entry.
4. Run the checks for both stacks before opening a PR:

```sh
BUNDLE_GEMFILE=gemfiles/github-pages.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/github-pages.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle exec rake
npm ci && npm test
gem build jekyll-theme-modootoday.gemspec
```

## Releasing (maintainers)

1. Move the `Unreleased` notes in `CHANGELOG.md` under the new version and bump `spec.version` in the gemspec.
2. Push a tag `vX.Y.Z`. `.github/workflows/release.yml` runs the tests and publishes to RubyGems through trusted publishing (OIDC, no API key) in the `rubygems` GitHub environment.
