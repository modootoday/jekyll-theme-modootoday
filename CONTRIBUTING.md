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

Changes to `docs/` or the theme's look: `qa/site/build-docs.sh docs/_site && npm run qa` takes screenshots (4 widths, light and dark, every language) and runs axe, token contrast and size budgets; CI runs the same job and uploads `qa-out/`.

### Visual regression

`npm run qa:visual` screenshots four pages (home, kitchen sink, configuration, Korean home) at 360, 1024 and 1440 px in light and dark mode and compares each shot with a PNG in `qa/visual/baseline/` (git-ignored; baselines are never committed) using [pixelmatch](https://github.com/mapbox/pixelmatch). A shot fails when more than 0.1 % of its pixels differ by more than the colour threshold 0.1, or when its size changed; the failing shot and a diff image go to `qa-out/visual/`. Animations, the caret and the "Last updated" date are frozen.

```sh
qa/site/build-docs.sh docs/_site
npm run qa:visual            # compare
npm run qa:visual:update     # accept the current look as the new baseline
node qa/visual/visual.mjs docs/_site --baseline DIR --out DIR --threshold 0.1 --max-diff 0.001 --report
```

Fonts and anti-aliasing differ between operating systems, so a baseline is only comparable on the machine image that made it. Make and compare baselines on one machine; to compare two versions, run `--update` on the old build and compare the new build in the same place. The CI workflow `visual.yml` does exactly that: it builds `docs/` at the base commit and at the head commit on the same runner and compares them, listing differences in the job summary with the images in the `visual` artifact.

- **Pull requests:** blocking. If the change is intended, review the diff images and add the `visual-ok` label; the check re-runs and passes in report mode.
- **Pushes to `main`:** report only.

### Lighthouse budget

`qa/lighthouse/lighthouse.sh` runs Lighthouse on seven docs pages, mobile and desktop, and `qa/lighthouse/budget.mjs` checks the median of the runs against `qa/lighthouse/budget.json`: accessibility, best practices and SEO must be 100, performance at least 90 (desktop) and 80 (mobile). The `lighthouse.yml` workflow runs it three times per page and blocks on a miss.

```sh
qa/site/build-docs.sh docs/_site
RUNS=3 CHROME_PATH=$(command -v google-chrome) qa/lighthouse/lighthouse.sh   # needs network for npx lighthouse
node qa/lighthouse/budget.mjs qa-out/lighthouse
```

## Conduct, security and releases

- This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
- Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md), not in public issues.
- Releases follow [RELEASING.md](RELEASING.md).
