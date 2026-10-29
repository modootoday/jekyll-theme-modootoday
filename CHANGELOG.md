# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).
The content rules have their own version header (`md-components v1 (draft)`) in [RULES.md](RULES.md).

## [Unreleased]

### Deprecated
- **Notice:** the `md-*` classes and `--md-*` custom properties will be marked deprecated in 1.0 and removed in 2.0. They work unchanged until then. Move to the `mt-*` / `--mt-*` names now with the mapping table in the [upgrade guide](docs/upgrade.md).

### Added
- Slot contract: `slots:` in `_data/components.yml` declares the named parts of a section (`lead`, `items`, `panels`, `actions`, `code`, `figures`) with `required`/`min`/`max`; `modootoday-check` counts them per section. Markup is unchanged. See the [API page](docs/api.md#slot-contract).

### Changed
- `modootoday-check` also warns on `md-*` classes and `var(--md-*)` in the site's own includes, layouts, CSS and pages (code is ignored), not only in Sass.

## [0.5.0] - Unreleased

First public release. It combines the internal milestones 0.1 to 0.4, which were never published, and the governance and SEO work for 0.5. Nothing below was available on RubyGems before 0.5.0.

### Release readiness

#### Changed
- Layout: header, content and footer share one alignment line; footer text no longer truncates; kitchen sink sections are separated by rules; aside TOC lists h2 only; dark `muted`/`card` raised to `#1a212b` for contrast; footnotes styled.

#### Added
- Brand colour: `primary` and `ring` use the 모두의오늘 brand red (light `#b94022`, dark `#e96346`); new semantic `brand` token (`#d94925`) for the logo mark. Nav entries with `items:` render as a dropdown group at 64rem and up and as flat links below.
- Head metadata on by default: canonical URL (when `url` is set), `hreflang` from `modootoday.languages`, Open Graph and Twitter card tags; `modootoday.seo: false` turns them off for sites that use jekyll-seo-tag. Sitemap and feed stay opt-in plugins (`modootoday.feed: true` adds the feed link).
- `modootoday.csp: strict` loads the pre-paint script from `assets/js/modootoday/theme-init.js`, so no inline script is needed; CSP guide.
- Optional "Last updated" (`last_modified_at`) and edit link (`modootoday.edit_url`, `edit: false` per page).
- Checker validates `seo`, `feed`, `csp`, `languages` and `edit_url`, and warns on `md-*` names in site Sass.
- Docs: public API and deprecation policy, migrate/upgrade guide, CSP guide, roadmap with non-goals (RTL, math, Mermaid), 404 page; the docs site uses sitemap, `hreflang` and edit links.
- SECURITY.md (private vulnerability reporting), CODE_OF_CONDUCT.md (Contributor Covenant 2.1), issue and pull request templates, Dependabot for Actions, Bundler and npm, RELEASING.md.
- CI job for the Jekyll 3.9 floor.

#### Deprecated
- `md-*` classes and `--md-*` properties: deprecated in 1.0, removed in 2.0. Use `mt-*` / `--mt-*`.

### Milestone 0.5

#### Added
- Front-matter-less twin mode (`modootoday.twins: source`): on classic GitHub Pages, `jekyll-optional-front-matter` renders a page without front matter and copies the raw file to its own path, which becomes the twin without a stub. The `default` layout and `llms.txt` link to it; the generator skips such pages; the checker verifies the rendered page and the byte-identical raw copy and rejects `remove_originals`, `require_front_matter` and redundant stubs. Example site in `example/source-mode/`, built in CI on github-pages and Jekyll 4.
- Checker: `modootoday.twins` value check; directories listed in `exclude:` are skipped.
- Visual refresh: wide container (`container` 76rem) with a sticky, blurred header and a right-hand sticky table of contents from 64rem (a collapsible "On this page" below that); site footer; Rouge syntax-highlighting colors (`code-*` tokens); tinted, rounded alerts; white shadowed cards with hover; neutral secondary buttons; gradient CTA box; soft status badges; styled page meta line (last updated, edit link); polished tabs, accordion, steps, timeline, pagination, kbd and tables.
- Tokens: `line-height`, `container`, `header-height`, `space-section`, `radius-lg`, `shadow-sm`, `shadow`, `code-keyword|string|comment|function|constant`; primitives `radius-lg`, `orange-400/600`, `teal-400/600`, `space-10`, `space-16`.

### Fixed
- An alert (or any paragraph with text) inside a hero no longer turns into a CTA row with its text hidden; only paragraphs made of links alone become action rows (`modootoday/actions.html`).
- Feature cards no longer show a stray "—" before the description.
- Header nav no longer wraps into several lines on narrow screens; it scrolls horizontally instead.

### Changed
- QA CSS budget raised from 20 KB to 32 KB (uncompressed, as built); the built CSS is about 28 KB (5.7 KB gzip).

### Milestone 0.4

#### Added
- P2 components: timeline (`c: timeline`), keyboard keys (`` `kbd:Ctrl+K` ``), client search (`modootoday/search.json` include + `search.js`, under 1 KB compressed), `post` layout.
- Read-only DTCG `tokens.json` generated in CI from the Sass maps (`script/tokens-json`), with a consistency test against the built CSS.
- Checker: `kbd:` value format.
- Example site: i18n keys `theme.toggle`, `breadcrumb.label`, `toc.label`, `badge.since`, `search.label`, `post.date_format` (en/ko/ja).

#### Deferred
- `_data/components.yml` slot contract.

### Milestone 0.3

#### Added
- P1 components: theme toggle (localStorage `mt-theme`, pre-paint script), breadcrumb, table of contents, accordion (`c: accordion`), steps (`c: steps`), figure/figcaption, `tag:`/`since:` badges. All on by default; `modootoday.components` narrows them.
- Checker: `tag:`/`since:` value format, images without alt text.

#### Changed
- Status/tag/since badges are also turned off when `badge` is not in `modootoday.components`.

#### Deprecated
- `md-*` class aliases remain for now (removal moved to a later minor).

### Milestone 0.2

#### Added
- Three-layer design tokens: primitives `--mt-p-*`, shadcn-style semantic tokens (`--mt-background`, `--mt-primary`, …), component tokens (`--mt-callout-accent`, `--mt-badge-*`, `--mt-card-padding`); `data-theme="light|dark"` forcing.
- Sass split into `_sass/modootoday/{_settings,_core}.scss`, `tools/`, `tokens/`, `components/<name>.scss`; `@import` only, compiles on Ruby Sass 3.7 and Dart Sass.
- `modootoday:` config: `color_scheme`, `css_layers` (`@layer mt.*`, off by default), `components` (all P0 components on by default), `nav`, `tokens`, `tokens_dark` (inlined `<style id="mt-tokens">`). Defaults in `_includes/modootoday/config.html`.
- Components: navigation (`_data/nav/*.yml`, `aria-current`), prev/next pagination, code-copy button (`assets/js/modootoday/code-copy.js`); `mt-*` classes for callout, badge, hero, CTA, card (features), tabs.
- `_includes/footer-custom.html` hook; i18n keys `nav.label`, `pagination.*`, `code.*`.
- Checker: rejects `@use`/`@forward`/`@supports selector()` in Sass and built CSS, `--x: $var` literals, undefined `var(--mt-*)`, invalid `modootoday:` settings and token values.
- Tests: theme CSS built with all/minimal/layers configs on both engines (`test/css_test.rb`).
- CI: github-pages job on Ruby 3.3.4 with the production gem set (github-pages 232, jekyll-include-cache 0.2.1, jekyll-octicons 14.2, nokogiri 1.16.7); `remote_theme:` site built by `actions/jekyll-build-pages@v1` and checked; Jekyll 4 on Ruby 3.2 and 3.4.

#### Changed
- `required_ruby_version` is now `>= 3.2`.
- `badges: false` in `modootoday:` is honoured (it was swallowed by `default: true`).

#### Deprecated
- `--md-*` custom properties and `md-*` classes (aliases of `--mt-*`/`mt-*`); removal planned for v0.3.

#### Removed
- `_sass/modootoday/{_tokens,_base,_components}.scss` (replaced by the new partials; `_sass/modootoday.scss` still imports everything).

### Milestone 0.1

#### Added
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

#### Fixed
- Sections split only on top-level `<h2>`; an `h2` inside a quote, list or alert no longer injects `</section><section>` into it.
- Docs: alerts are a GitHub extension outside the GFM spec; the raw-HTML ban is about portability (GitHub renders `details`/`kbd`, strips others; kramdown passes all through), not "GitHub sanitising".
- Checker messages for `##` and alerts nested in quotes/lists explain why and what to use instead.
- `required_ruby_version` raised to 3.0 (the checker uses endless methods).
- Example: `sass.silence_deprecations: [import]` for Dart Sass; `llms.txt` per language generated instead of hand-written.
- Raw `<name>.md` copies in `_site` on GitHub Pages: caused by content files without front matter (rendered by `jekyll-optional-front-matter` and also copied). Front matter is now required and checked.

[Unreleased]: https://github.com/modootoday/jekyll-theme-modootoday/compare/main...HEAD
[0.5.0]: https://github.com/modootoday/jekyll-theme-modootoday/tree/main
