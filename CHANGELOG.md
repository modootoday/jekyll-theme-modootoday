# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).
The content rules have their own version header (`md-components v1 (draft)`) in [RULES.md](RULES.md).

## [Unreleased]

## [0.4.0] - Unreleased

### Added
- P2 components: timeline (`c: timeline`), keyboard keys (`` `kbd:Ctrl+K` ``), client search (`modootoday/search.json` include + `search.js`, under 1 KB compressed), `post` layout.
- Read-only DTCG `tokens.json` generated in CI from the Sass maps (`script/tokens-json`), with a consistency test against the built CSS.
- Checker: `kbd:` value format.
- Example site: i18n keys `theme.toggle`, `breadcrumb.label`, `toc.label`, `badge.since`, `search.label`, `post.date_format` (en/ko/ja).

### Deferred
- `_data/components.yml` slot contract.

## [0.3.0] - Unreleased

### Added
- P1 components: theme toggle (localStorage `mt-theme`, pre-paint script), breadcrumb, table of contents, accordion (`c: accordion`), steps (`c: steps`), figure/figcaption, `tag:`/`since:` badges. All on by default; `modootoday.components` narrows them.
- Checker: `tag:`/`since:` value format, images without alt text.

### Changed
- Status/tag/since badges are also turned off when `badge` is not in `modootoday.components`.

### Deprecated
- `md-*` class aliases remain for now (removal moved to a later minor).

## [0.2.0] - Unreleased

### Added
- Three-layer design tokens: primitives `--mt-p-*`, shadcn-style semantic tokens (`--mt-background`, `--mt-primary`, …), component tokens (`--mt-callout-accent`, `--mt-badge-*`, `--mt-card-padding`); `data-theme="light|dark"` forcing.
- Sass split into `_sass/modootoday/{_settings,_core}.scss`, `tools/`, `tokens/`, `components/<name>.scss`; `@import` only, compiles on Ruby Sass 3.7 and Dart Sass.
- `modootoday:` config: `color_scheme`, `css_layers` (`@layer mt.*`, off by default), `components` (all P0 components on by default), `nav`, `tokens`, `tokens_dark` (inlined `<style id="mt-tokens">`). Defaults in `_includes/modootoday/config.html`.
- Components: navigation (`_data/nav/*.yml`, `aria-current`), prev/next pagination, code-copy button (`assets/js/modootoday/code-copy.js`); `mt-*` classes for callout, badge, hero, CTA, card (features), tabs.
- `_includes/footer-custom.html` hook; i18n keys `nav.label`, `pagination.*`, `code.*`.
- Checker: rejects `@use`/`@forward`/`@supports selector()` in Sass and built CSS, `--x: $var` literals, undefined `var(--mt-*)`, invalid `modootoday:` settings and token values.
- Tests: theme CSS built with all/minimal/layers configs on both engines (`test/css_test.rb`).
- CI: github-pages job on Ruby 3.3.4 with the production gem set (github-pages 232, jekyll-include-cache 0.2.1, jekyll-octicons 14.2, nokogiri 1.16.7); `remote_theme:` site built by `actions/jekyll-build-pages@v1` and checked; Jekyll 4 on Ruby 3.2 and 3.4.

### Changed
- `required_ruby_version` is now `>= 3.2`.
- `badges: false` in `modootoday:` is honoured (it was swallowed by `default: true`).

### Deprecated
- `--md-*` custom properties and `md-*` classes (aliases of `--mt-*`/`mt-*`); removal planned for v0.3.

### Removed
- `_sass/modootoday/{_tokens,_base,_components}.scss` (replaced by the new partials; `_sass/modootoday.scss` still imports everything).

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
