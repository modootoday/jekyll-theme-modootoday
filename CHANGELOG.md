# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).
The content rules have their own version header (`md-components v1 (draft)`) in [RULES.md](RULES.md).

## [Unreleased]

## [0.1.0] - Unreleased

### Added
- Gem-based Jekyll theme layout: `_layouts/{default,doc,twin}.html`, `_includes/{md-components,md-sections,head-custom}.html`, `_sass/`, `assets/`.
- Default stylesheet with CSS custom-property design tokens, light and dark (`prefers-color-scheme`) themes, callouts, status badges, sections, CTA buttons, tabs, focus-visible styles and a responsive doc layout.
- `assets/js/md-tabs.js`: Home/End keys, focusable panels (`tabindex="0"`), ids unique across several tab groups.
- `modootoday-check` executable (from the kit's `bin/check`): missing-front-matter error, unknown alert type warning (`--strict` makes warnings errors), github-pages lockfile check now opt-in (`--github-pages[=VERSION]`), `--help`.
- Neutral example site (en/ko/ja) with agent-readable Markdown twins.
- Ruby tests (`test/check_test.rb`), jsdom tests (`test/tabs.test.js`), CI for the GitHub Pages stack and Jekyll 4, release workflow with RubyGems trusted publishing.

### Fixed
- Raw `<name>.md` copies in `_site` on GitHub Pages: caused by content files without front matter (rendered by `jekyll-optional-front-matter` and also copied). Front matter is now required and checked.

[Unreleased]: https://github.com/modootoday/jekyll-theme-modootoday/compare/main...HEAD
[0.1.0]: https://github.com/modootoday/jekyll-theme-modootoday/tree/main
