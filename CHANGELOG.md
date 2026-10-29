# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).
The content rules have their own version header (`md-components v1 (draft)`) in [RULES.md](RULES.md).

## [Unreleased]

## [0.1.0] - Unreleased

### Added
- Gem-based Jekyll theme layout: `_layouts/{default,doc,twin,llms,llms-full}.html`, `_includes/{md-components,md-sections,head-custom}.html`, `_sass/`, `assets/`.
- Default stylesheet with CSS custom-property design tokens, light and dark (`prefers-color-scheme`) themes, callouts, status badges, sections, CTA buttons, tabs, focus-visible styles and a responsive doc layout.
- `assets/js/md-tabs.js`: Home/End keys, focusable panels (`tabindex="0"`), ids unique across several tab groups.
- `modootoday-check` executable (from the kit's `bin/check`): missing-front-matter error, unregistered alert type error, github-pages lockfile check now opt-in (`--github-pages[=VERSION]`), `--help`.
- Neutral example site (en/ko/ja) with agent-readable Markdown twins.
- Ruby tests (`test/check_test.rb`), jsdom tests (`test/tabs.test.js`), CI for the GitHub Pages stack and Jekyll 4, release workflow with RubyGems trusted publishing.

- md-components v1 amendments from the standards audit (66 fixtures in `test/fixtures/md`, built in-process by `test/build_test.rb`):
  - Alerts: case-insensitive types; standalone `<p>[!TYPE]</p>` (blank `>` line, body starting with code, list or heading); `[!TYPE]<br />` (trailing spaces).
  - Checker: case-insensitive markers, unregistered/empty/titled/formatted alerts and tab after `>` are errors, `<pre>`/`<code>` ignored when scanning build output; fence info string must be one language word; bare URL/e-mail autolinks, abbreviations and HTML comments forbidden; setext, nested, indented and commented `##` are errors; footnotes explicitly allowed.
  - `default` layout: `rel="alternate" type="text/markdown"` link to the twin and `rel="describedby"` link to the nearest `llms.txt`; example `llms.txt` files use llmstxt.org H2 link lists.

- Automatic twins and llms files: opt-in generator `plugins: [jekyll-theme-modootoday]` (`lib/`, Jekyll 3.9+/4, skipped by GitHub Pages safe mode) adds `<name>.md.txt`-equivalent twin pages and `llms.txt`/`llms-full.txt` per language; layouts `llms` and `llms-full` (with includes `md-raw-body`, `md-llms-pages`) generate those files from front-matter-only stubs on GitHub Pages. Example uses them.
- Checker `--twins`: stubs no longer required when the twin exists (plugin); clearer missing-twin hint; `twin: false`; `llms.txt` must start with an H1; `llms-full.txt` must contain every page body.
- `test/consumer_test.rb`: builds real consumer sites (theme gem with stubs, `--baseurl`, stub-less site with the plugin); CI builds the example with `remote_theme` pinned to the pushed commit.

### Fixed
- Sections split only on top-level `<h2>`; an `h2` inside a quote, list or alert no longer injects `</section><section>` into it.
- Docs: alerts are a GitHub extension outside the GFM spec; the raw-HTML ban is about portability (GitHub renders `details`/`kbd`, strips others; kramdown passes all through), not "GitHub sanitising".
- Checker messages for `##` and alerts nested in quotes/lists explain why and what to use instead.
- `required_ruby_version` raised to 3.0 (the checker uses endless methods).
- Example: `sass.silence_deprecations: [import]` for Dart Sass; `llms.txt` per language generated instead of hand-written.
- Raw `<name>.md` copies in `_site` on GitHub Pages: caused by content files without front matter (rendered by `jekyll-optional-front-matter` and also copied). Front matter is now required and checked.

[Unreleased]: https://github.com/modootoday/jekyll-theme-modootoday/compare/main...HEAD
[0.1.0]: https://github.com/modootoday/jekyll-theme-modootoday/tree/main
