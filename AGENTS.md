# AGENTS.md

Instructions for coding agents (and people) working on this repository. [CONTRIBUTING.md](CONTRIBUTING.md) is the long form; when the two differ, CONTRIBUTING wins and this file is fixed.

## Project

`jekyll-theme-modootoday` is a Jekyll theme gem. Page bodies stay plain GitHub Flavored Markdown; layouts, includes, Sass and small scripts add the design. It must build unchanged on GitHub Pages (`github-pages` 232, Jekyll 3.10, `remote_theme`, no custom plugins) and on Jekyll 4. The repository also ships two executables (`modootoday-check`, `modootoday-stubs`), the docs site in `docs/` and three starter sites in `example/` (git submodules).

## Commands

Set up once (the starters are submodules):

```sh
git submodule update --init
BUNDLE_GEMFILE=gemfiles/github-pages.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle install
npm ci
```

Tests on both stacks, the JS tests and the gem:

```sh
BUNDLE_GEMFILE=gemfiles/github-pages.gemfile bundle exec rake test
BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle exec rake test
npm test
gem build jekyll-theme-modootoday.gemspec
```

Generated files: never edit their output. `bundle exec rake fix` runs every generator in write mode and lists what changed, to commit (translation stamps stay a deliberate `ruby script/docs-index --stamp`). Each `--check` fails on stale output, and CI runs them all:

```sh
bundle exec rake fix
ruby script/i18n-build --check
ruby script/docs-index --check
ruby script/readme-commands --check
ruby script/version-include --check
bundle exec rake starters:check
```

Docs site build, checker and browser audits:

```sh
test/system/site/build-docs.sh docs/_site
bundle exec ruby exe/modootoday-check docs docs/_site --twins
npm run qa
```

The fast checks before a push (a few seconds); opt in once per clone so `git push` runs them:

```sh
script/hooks/pre-push
git config core.hooksPath script/hooks
```

## Rules

- **Plain GFM bodies.** Pages use only the Markdown in `RULES.md` (`md-components v1`); design comes from front matter, layouts and includes. Liquid only, and it must work on Jekyll 3.10 and 4.
- **Strict CSP.** Theme output must work under `script-src 'self'; style-src 'self'` with `modootoday.csp: strict` (see `docs/recipes/csp.md`): scripts and styles load from files, never as inline code, style attributes or event handlers. A feature with a demo page adds it to `CSP_PAGES` in `test/system/audit/config.mjs`; the CSP audit stays at zero violations.
- **Byte budgets.** Every theme CSS and JS file has a gzip cap on its row in `_includes/modootoday/assets/registry.html`: the measured size plus 10 %, rounded up to 128 bytes, changed in the same diff as the file. A page type's limit is the sum of the caps it loads. The guide targets, the Lighthouse budget and the docs and layout limits change only with an ADR.
- **Context sheets.** The core sheet holds tokens, base and shell only. Component CSS goes in its own module sheet with a registry row, and code is grouped by the context it serves (no `utils` or `helpers` grab-bags).
- **Small files.** Code files hold at most 150 lines, tests 300, and a directory at most 12 tracked files (`test/project/layout_test.rb`).
- **Decisions in `.spec/`.** A decision that sets a rule, a limit, an exception or a public behaviour is an ADR under `.spec/adr/`, made with the spec CLI (`npm` package `@modootoday/specfold`, command `spec`), not left in a commit message or a chat. Cite it by id (`adr:modootoday/<timestamp>`); every cited id must name a committed document.
- **Docs in English, Korean and Japanese together.** English is canonical. The same change updates the English page and its `.ko.md` and `.ja.md` translations, then stamps them with `ruby script/docs-index --stamp`. User docs never name a future version.
- **Docs consistency (adr:modootoday/20261109200230).** One canonical page per topic (others link it, never repeat it); one term per concept; the front matter contract; no past versions outside Upgrade and Changelog; docs match the code registries (config keys, layouts, components, CLI); groups of 12 or fewer with no orphans; relative links.
- **CHANGELOG.** Generated: `## [Unreleased]` is git-cliff's render of the commits since the last tag (`ruby script/changelog`, part of `rake fix`; commit, regenerate, amend). Never edit it by hand; a released entry is never edited either (`test/project/changelog_test.rb`).
- **Commits.** Conventional Commit subjects. The footers `Changelog: <text>` (or `Changelog: none`), `Refs: adr:...`, `Visual: <text>` and `Migration: <text>` feed the CHANGELOG that `cliff.toml` generates (table in CONTRIBUTING, "Commits and the changelog"). A commit that touches shipped paths has a Conventional subject, and a left-out type there carries a `Changelog:` footer; `ruby script/commit-check` checks the unpushed commits.
- **Public repository.** Commit nothing private: no local paths, e-mail addresses, tokens or internal notes.

```sh
spec new adr --governs <path> --title "<decision>" --write
spec set <id> status=active --write
spec check
```

## Where things live

| Path | What |
| --- | --- |
| `_layouts/`, `_includes/modootoday/`, `_sass/modootoday/`, `assets/` | the theme (shipped in the gem) |
| `_includes/modootoday/assets/registry.html` | optional assets and their byte caps |
| `i18n/` | interface catalogs (source of the generated includes) |
| `lib/modootoday/`, `exe/` | the checker and the stub writer |
| `script/` | generators and tools, not shipped |
| `test/` | minitest suites (`rake test`), `test/js/` (`npm test`), `test/system/` (docs and browser audits) |
| `docs/` | the docs site; `docs/generated/` is tool output |
| `example/` | the starter sites (`example/starters.yml`) |
| `.spec/` | ADRs, audits, research and sources of truth |

Done means the checks in the "Definition of done" table of [CONTRIBUTING.md](CONTRIBUTING.md) pass for the kind of change.
