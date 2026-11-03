# Contributing

English is the canonical language. `README.md`, `RULES.md` and the English pages in `docs/` are the source of truth; `README.ko.md` and the pages beside each English page in `docs/` (`install.ko.md`, `install.ja.md`, and the home pages in `docs/home/`) are translations and start with a note saying so. Change the English text first, then update the translations in the same pull request when you can. When they differ, English wins.

Translations are localized, not literal: follow the tone, glossary and spacing rules in [TRANSLATING.md](TRANSLATING.md).


1. Fork and branch from `main`. Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:` …).
2. Keep layouts and includes **Liquid only** — no custom Ruby plugins — so the theme keeps working with `remote_theme` on GitHub Pages.
3. `README.md` and `README.ko.md` keep the same sections (checked by `test/project/readme_test.rb`). The Commands tables are generated from `exe/modootoday-check` and `exe/modootoday-stubs`: run `script/readme-commands` after changing an option.
4. Rule changes (`RULES.md`) need a matching change in the includes, the checker and the tests, plus a CHANGELOG entry.
5. Run the checks for both stacks before opening a PR:

```sh
BUNDLE_GEMFILE=gemfiles/github-pages.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/github-pages.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle exec rake
npm ci && npm test
gem build jekyll-theme-modootoday.gemspec
```

Changes to `docs/` or the theme's look: `qa/site/build-docs.sh docs/_site && npm run qa` takes screenshots (4 widths, light and dark, every language) and runs axe, token contrast, size budgets and the CSP audit; CI runs the same job and uploads `qa-out/`. The budgets in `qa/audit/config.mjs` cover each file, the core CSS one page links, all core scripts (gzip) and, per page type (`PAGE_TYPES`), the gzip bytes one page loads; limits are the measured value plus about 10 %. The CSP audit serves `CSP_PAGES` with a strict `Content-Security-Policy` header and fails on any violation or console error; a new feature adds its demo page there.

### Visual regression

`npm run qa:visual` screenshots five pages (home, kitchen sink, configuration, Korean home, the hero module demo) at 360, 600, 720, 1024 and 1440 px in light and dark mode, with reduced motion (so a script visual shows its poster) and compares each shot with a PNG in `qa/visual/baseline/` (git-ignored; baselines are never committed) using [pixelmatch](https://github.com/mapbox/pixelmatch). A shot fails when more than 0.1 % of its pixels differ by more than the colour threshold 0.1, or when its size changed; the failing shot and a diff image go to `qa-out/visual/`. Animations, the caret and the "Last updated" date are frozen.

```sh
qa/site/build-docs.sh docs/_site
npm run qa:visual            # compare
npm run qa:visual:update     # accept the current look as the new baseline
node qa/visual/visual.mjs docs/_site --baseline DIR --out DIR --threshold 0.1 --max-diff 0.001 --report
```

Fonts and anti-aliasing differ between operating systems, so a baseline is only comparable on the machine image that made it. Make and compare baselines on one machine; to compare two versions, run `--update` on the old build and compare the new build in the same place. The CI workflow `visual.yml` does exactly that: it builds `docs/` at the base commit and at the head commit on the same runner and compares them, listing differences in the job summary with the images in the `visual` artifact.

- **Pull requests:** blocking. If the change is intended, review the diff images and add the `visual-ok` label; the check re-runs and passes in report mode.
- **Release check:** a manual run (`gh workflow run visual.yml`) compares `main` with the latest release tag and reports the differences. Pushes to `main` do not run it.

### Lighthouse budget

`qa/lighthouse/lighthouse.sh` runs Lighthouse on eight docs pages (among them the hero module demo, whose largest contentful paint is its poster), mobile and desktop, and `qa/lighthouse/budget.mjs` checks the median of the runs against `qa/lighthouse/budget.json`: accessibility, best practices and SEO must be 100, performance at least 90 (desktop) and 80 (mobile). The `lighthouse.yml` workflow runs it three times per page and blocks on a miss; it runs on pull requests and in the release check (`gh workflow run lighthouse.yml`), not on pushes to `main`.

```sh
qa/site/build-docs.sh docs/_site
RUNS=3 CHROME_PATH=$(command -v google-chrome) qa/lighthouse/lighthouse.sh   # needs network for npx lighthouse
node qa/lighthouse/budget.mjs qa-out/lighthouse
```

### Starter sites

`example/` is the source of three starter sites: `docs` (a guide, records with a byte-exact API folder, Korean and Japanese pages in `ko/` and `ja/`), `blog` (posts, a news article, an author page and the feed) and `landing` (a home hero, pricing and a legal page). `example/starters.yml` lists them with the repository each one is published to, its languages, its stacks and its `modootoday-check` flags. Each folder is a Jekyll site that holds only what a person writes. `bundle exec rake starters:render` writes each starter for each of its stacks to `pkg/starters/<stack>/<name>/` and adds what the theme owns:

- `_config.yml`: on the `github-pages` stack, the `theme:` line becomes `remote_theme:` pinned to the gemspec version.
- `Gemfile` from the gem lines of `gemfiles/<stack>.gemfile`; `README.md` and `.github/workflows/pages.yml` from `script/starters/templates/`, shared by every starter.
- The twin, record and alias stubs `modootoday-stubs` writes. No interface catalog is copied: the theme ships every language a starter may list, and a starter's `_data/i18n/<lang>.yml` holds only the strings that site changes (a test fails on one that repeats the theme's).

Do not commit those files in a starter folder; the tests fail on a committed stub. `rake starters:check` fails when `pkg/starters/` differs from a fresh render, and `rake starters:build[NAME]` builds the starters with the current bundle and runs the checker with their manifest flags (plain `rake` runs it after the tests). The `starters.yml` workflow renders, builds and checks every starter on github-pages 232, Jekyll 4 and the GitHub Pages builder image. Publishing a rendered starter to its repository comes after 1.5.0; until then it is uploaded by hand. Sites that only tests use, such as the front-matter-less one, live in `test/fixtures/sites/`.

## Project layout

These rules apply to everything in the repository: theme files, tools, tests, QA and new code. `test/project/layout_test.rb` enforces the measurable parts.

1. **Standards first.** Where Jekyll, RubyGems, Bundler, Rake, minitest or npm fix a place or a name, use it (`_layouts/`, `_includes/`, `_sass/`, `assets/`, `lib/`, `exe/`, `test/**/*_test.rb`, `package.json` scripts).
2. **One responsibility per file.** A file does one job. When it grows a second one, split it; do not append unrelated code.
3. **Assembling file next to its parts.** A file that only wires parts together sits beside a directory of the same name holding the parts: `lib/modootoday/check.rb` with `lib/modootoday/check/`, `qa/audit.mjs` with `qa/audit/`.
4. **Group by context, not flat.** A directory holds at most 12 tracked files; beyond that, group them in subdirectories named after what they are about (`test/checker/`, `test/theme/`, `qa/lighthouse/`). Directories whose shape a standard fixes (Jekyll pages, the repository root), or that are pending a regroup, are listed with a reason in `FLAT_OK`.
5. **Short code files.** Code under `lib/`, `qa/`, `exe/`, `script/`, `assets/js/` and test helpers stays at 150 lines or fewer; a test file at 300 or fewer. Data files there (`.json`, `.txt`) are not code and have no limit. Exceptions are listed with a reason in `LONG_OK`, and the test fails when an exception no longer applies.

Where things live:

| Path | Context |
| --- | --- |
| `lib/modootoday/check.rb`, `lib/modootoday/check/` | `modootoday-check`: `cli.rb` and `context.rb` at the top; rule groups in `config/` (`_config.yml` settings; one file per key group under `config/keys/`, in `appearance/`, `pages/` and `serving/`, report order = load order in `config/keys.rb`), `page/` (page sources), `build/` (the built site), `registry/` (`_data/components.yml`, i18n catalogs), `source/` (Sass, `Gemfile.lock`, `gh` rendering) and `layouts/` (layout front matter) |
| `lib/modootoday/markdown.rb` | Markdown source text (front matter, fences, code spans, comments): the one front matter parser for both executables, `script/` and `qa/docs/` |
| `lib/modootoday/stubs.rb`, `lib/modootoday/stubs/` | `modootoday-stubs`: `page.rb` (a page and its URL, also used by `modootoday-check --aliases` and `script/docs`), `source.rb` (the pages), one generator per stub kind (`twins.rb`, `aliases.rb`, `records.rb`), `plan.rb`, `writer.rb`, `report.rb` and `cli.rb`; `script/docs-index` uses `Twins` (with `dir: "generated"`) for the docs site, and `modootoday-check` uses the records plan for its verdict |
| `test/stubs/` | `modootoday-stubs` plans, idempotence and the command line |
| `test/checker/` | `modootoday-check` rules, in the same context subdirectories; `messages_snapshot_test.rb` pins the full output (`SNAPSHOT_UPDATE=1` refreshes `test/fixtures/checker/`) |
| `test/theme/` | layouts, includes, Sass and tokens built with Jekyll |
| `test/layouts/` | layout families (`families/`) and page features (`features/`), built from a starter site plus extra pages |
| `test/support/` | helpers several test directories share (`starters.rb` renders each starter once per run; `layout_site.rb` builds one with extra pages) |
| `test/consumer/` | sites that use the gem: the starters with stubs or with the plugin, the docs starter's guides, the front-matter-less site |
| `test/starters/` | the starter manifest, the sources, rendering, drift and the generated workflow |
| `example/` | the starter sources (`starters.yml` and one folder per starter); see Starter sites above |
| `script/starters/` | the starter renderer: `manifest.rb`, `theme.rb` (what it reads from the gemspec, `gemfiles/`, `i18n/` and the executables), `site.rb`, `render.rb` and `templates/` |
| `test/project/` | README, version, community files, this layout and the docs generator (`script/docs-index`) |
| `test/js/` | browser scripts (`node --test`) |
| `test/fixtures/` | inputs shared by the tests |
| `docs/generated/` | tool output: the docs site's twin stubs and per-language `llms.txt` / `llms-full.txt` stubs, written by `ruby script/docs-index` (`--check` fails when they are stale). Do not edit by hand; each stub sets `path:` to where it would sit beside its page and `permalink:` to its URL |
| `qa/site/` | building and serving the docs site |
| `qa/audit.mjs`, `qa/audit/` | screenshots, axe, contrast, size budgets (`budgets/`: per file, per page, per page type in gzip), keyboard flows (`keyboard/`), registry parts, strict CSP (`npm run qa`) |
| `qa/visual/` | visual regression (`npm run qa:visual`) |
| `qa/lighthouse/` | Lighthouse runs and budget |
| `qa/docs/` | link check and kitchen-sink coverage |
| `qa/css/` | per-partial CSS sizes |
| `qa/bench/` | the records benchmark: a synthetic site of N records (`fixture.rb`) built with the GitHub Pages builder image (`records.rb`, Docker); CI fails over 300 s for 1,000 records |

## Conduct, security and releases

- This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
- Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md), not in public issues.
- Releases follow [RELEASING.md](RELEASING.md).
