# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).
The content rules have their own version header (`md-components v1`) in [RULES.md](RULES.md).

## [1.0.0] - Unreleased

First public release. Nothing was published on RubyGems before 1.0.0. The changes directly below were made last; [Pre-release history](#pre-release-history) lists the earlier development milestones (0.1 to 0.5), which were internal and never released.

### Added
- **Accessibility:** safe areas on notched phones (`viewport-fit=cover` with `--mt-safe-top|right|bottom|left` padding the header, side gutters and footer; `modootoday.viewport_fit: auto` opts out), `theme-color` meta tags matching the light and dark background (`modootoday.theme_color`), 44 px touch targets and 16 px search text on touch screens, forced-colors borders on icon buttons and search. Keyboard: `/` and `Ctrl`/`Cmd`+`K` focus search, arrow keys and `Esc` in results, wide code blocks and tables become labelled focusable regions, focus rings drawn inside tabs and scroll regions. Labels `code.label` and `table.label` ship in all 23 catalogs. See the [Accessibility page](docs/accessibility.md).
- **Doc sidebar:** `doc` pages get a sidebar built from the nav groups (`modootoday.sidebar: auto | true | false`, default `auto` = on when the nav has groups; `sidebar: false` in front matter). From 64rem it is a sticky column; below, a collapsed menu above the page shows the current group, replacing the horizontally scrolling link row. With a sidebar the header drops the flat group links.
- **Page actions:** on pages with a Markdown twin, a menu offers View as Markdown, Copy page and Copy for AI (source URL, then the Markdown). `modootoday.page_actions: false`, front matter `page_actions: false`, or leaving `page-actions` out of `components` removes it. Labels (`page_actions.*`, `sidebar.label`) ship in all 23 catalogs.
- `color_scheme: auto-dark` and `auto-light` start in that scheme and keep the toggle; the start is printed as `data-theme` in the HTML, so there is no flash and no `head-custom.html` script.
- **Blog and news layouts:** `blog` (paginated index of post cards with `variant: list | grid | magazine`, featured first, per-language), `news` (front page with lead, secondary stories and `news_sections` blocks), `news-article` (dateline, deck, breaking/live badges, correction, sources), `author` (profile and posts) and `feed` (per-language Atom). The `post` layout gains a byline from `_data/authors.yml` (`author:` or `authors:`), published/updated dates, reading time, cover image, series box, previous/next, related posts, a share button, `BlogPosting`/`NewsArticle` JSON-LD and OG `article:*` tags. Settings live under `modootoday.blog` and `modootoday.news`; labels are translated in all 23 catalogs. Liquid only (classic GitHub Pages and Jekyll 4). The styles (`modootoday-blog.css`) and `share.js` are a separate optional bundle loaded only by these layouts, with their own size budgets; the core bundles are unchanged. `modootoday-check` validates the settings, `_data/authors.yml` and post front matter. See [Blog and news](docs/blog-news.md).
- **Result container for CTA sections:** when a `c: cta` section holds an element with `data-mt-result`, the `.mt-cta` box (centering, gradient, border) goes on that element instead of the whole section. Sections without one render exactly as before. The docs Components page uses it, so the Buttons example card matches the other cards and only its result is framed.
- `visual: <name>` on a `sections:` item and `hero: {visual: <name>}` render a site-provided `_includes/sections/<name>.html`; `modootoday-check` fails when it is missing.
- `full_width: true` front matter removes the reading-column width of `main` (`.mt-main-full`).
- Breadcrumb: the home crumb uses the home page `short_title:` when set.
- `modootoday-check` accepts tool region markers alone on a line (`<!-- spec:toc:begin -->` / `<!-- spec:toc:end -->`); other HTML comments are still errors.
- `modootoday.hreflang` keeps `hreflang` alternates when `seo: false`.
- **Icons:** `modootoday/brand/icon.html` renders inline SVG icons (`name`, `size`, `label`, `class`) in `currentColor`, decorative unless labelled, with directional icons mirrored in RTL. Every former text, emoji or CSS-drawn icon (language globe, theme sun/moon, search, nav chevron and external link, breadcrumb separators, alert types, copy/check, edit link, previous/next, tag and category badges) now uses it. See the [API page](docs/api.md#stable-names).
- **Logo and favicon:** `modootoday.logo: brand | <path>` shows the modootoday mark (or your image) before the site title through the overridable `modootoday/brand/logo.html`; `modootoday.favicon: brand | <path>` links an SVG, 32 px PNG and Apple touch icon. The docs site uses both.
- **Built-in translations:** set `lang:` and the theme's labels (skip link, navigation, callouts, status badges, table of contents, pagination, code copy, search, language menu) are localized for 23 languages with nothing to copy, on GitHub Pages and Jekyll 4. A site `_data/i18n/<lang>.yml` overrides individual keys; unknown languages use English. `modootoday/t.html` prints a label by key. `modootoday-check --i18n-init` copies a catalog to edit, and `--i18n` checks keys and placeholders; `.yaml` catalogs are rejected.
- **Language switcher:** `modootoday.language_switcher: header | footer` renders a theme-level switcher from `languages` (the same alternates as `hreflang`), linking to the translation of the current page or that language's home page. In the header it is a globe button with a `<details>` dropdown (localized accessible name, `aria-current`, `lang`/`hreflang` on each link) that keeps the same width however many languages there are; in the footer, a list. Nothing renders with fewer than two languages. `modootoday/lang-switch.html` can be included from a custom footer. The docs site uses the header menu in place of its footer list.
- `menu.js` (small, CSP-safe): Esc closes a `<details class="mt-menu">` and returns focus, arrow keys move between items, an outside click or opening another menu closes it. Used by the language menu and the nav "More" group.
- On screens under 30rem, search takes its own row under the site title.
- **Tag and category archives:** the `archive` layout (`archive: tags | categories`) and the `modootoday/archive.html` include list terms with post counts and one anchored section per term, filtered by language (`archive_lang: all` for every post). With `modootoday.archive: {tags: /tags/, categories: /categories/}` the `post` layout adds a footer linking each tag and category. Liquid only, so it works on classic GitHub Pages; one page per taxonomy, not per term. `modootoday-check` validates `modootoday.archive` and skips twins for `_posts/`. The post and archive styles ship in the optional `modootoday-blog.css` bundle (loaded by the `post`, `archive` and blog/news layouts; `blog_css: true` opts any other page in, for example one that uses the `modootoday/archive.html` include). See the [API page](docs/api.md#posts-and-archives).
- Slot contract: `slots:` in `_data/components.yml` declares the named parts of a section (`lead`, `items`, `panels`, `actions`, `code`, `figures`) with `required`/`min`/`max`; `modootoday-check` counts them per section. Markup is unchanged. See the [API page](docs/api.md#slot-contract).
- Slot contract: `slots:` can be a list of alternative forms (a section passes when it satisfies one; `steps` and `timeline` accept a list or `###` panels), and `parts:` declares the stable selectors of a component, checked against the component structure table of `api.md` when the site has one. See the [API page](docs/api.md#slot-contract).
- **Right-to-left:** `dir="rtl"` from `lang` for RTL languages, `direction:` front matter override, logical properties in component CSS, LTR code inside RTL text, RTL-aware tab arrow keys, and an RTL kitchen sink checked in docs QA.
- [Math and diagrams](docs/math-diagrams.md) guide (en, ko, ja): KaTeX and Mermaid under a strict CSP, rendered at build time or self-hosted. The theme bundles neither.
- Japanese documentation on the docs site (`/ja/`), with hreflang, Markdown twins, `llms.txt` and a footer language switcher on the docs site.
- Guide pages in Korean and Japanese on the example site, with twins and `llms.txt` entries.

### Fixed
- Pages no longer flash on load: the header search box and light/dark toggle are drawn from the first paint instead of popping in when their scripts run (the header used to jump, most visibly after clicking the logo), and the toggle icon matches the colour scheme immediately. QA checks the first frames after a logo click.
- Tabs: the tab list no longer shows a vertical scrollbar (the active-tab underline overflowed it by 1px); it scrolls sideways only, and the focus ring sits inside each tab. QA fails on any tabs scrollbar at 360/768/1280px.
- Search on a page whose language has no other pages (the RTL sample) now prefers the site's default language instead of every language.
- The table of contents sits a fixed gap after the text at wide widths instead of being pushed to the far edge; the narrow-screen menu row fades at its end to show it scrolls; inline code in cards no longer breaks inside a file name; figures are dimmed slightly in dark mode.
- The header site title links to the current language's home (`/<lang>/`, with `baseurl`) instead of the default-language root, for every language in `languages` including right-to-left ones; it falls back to the site root when that language has no home page.

### Changed
- **Previous/next follows the nav:** pagination walks `_data/nav` in order, a group's own page and then its items, instead of top-level entries only.
- Doc-only includes live under `_includes/modootoday/doc/` (`pagination.html`, `sidebar.html`, `page-actions.html`, `twin.html`); the page-actions script is part of `code-copy.js`.
- **One prefix, no aliases:** every class and custom property is `mt-*` / `--mt-*`; the `md-*` classes, `--md-*` properties, `$mt-md-aliases` and the checker's alias warnings are gone (they were never released). The skip-link target is `#mt-main`.
- Theme includes and scripts live under `modootoday/`: `_includes/modootoday/markdown/{components,sections,raw-body,llms-pages}.html` and `assets/js/modootoday/tabs.js` (were `_includes/md-*.html` and `assets/js/md-tabs.js`); tab ids are `mt-tabs-*`.
- `since:` version badges are not part of 1.0: they are no longer rendered and `modootoday-check` reports any `` `since:…` `` code span as an error.
- The docs site and the README quick start build CSS with `sass: {style: compressed}` (Ruby Sass 3.7 and Dart Sass): the stylesheet is about 10 % smaller with identical rendering. `qa/css-sizes.rb` reports the size of the core and each component.
- Header, navigation, search, theme toggle and code copy use logical properties, so they mirror in right-to-left pages; the code Copy button sits at the inline end and never covers code. The docs navigation lists the math and diagrams guide.
- `modootoday-check` validates `_data/components.yml` itself: unknown keys in a component entry (allowed: `params`, `i18n`, `slots`, `parts`) or a slot rule (allowed: `required`, `min`, `max`), non-integer or negative counts and `min` greater than `max` are errors, reported once per registry instead of once per section. Registries that use only these keys are unaffected.
- `modootoday-check` also looks up each `parts:` selector in the built HTML of the pages that use the component (inside its `section[data-c]`), when Nokogiri is available as it is under `github-pages`; parts added by component scripts (`role=`, `aria-*`) are checked after the scripts run by the docs site QA. The kitchen sink now shows `timeline` in both forms.
- The `caution` token is now rose (`#b8174a` light, `#ff7b9c` dark) instead of red, so caution alerts no longer read as the orange-red brand link colour. New primitives `--mt-p-rose-400/600`.
- Search results show the current language first, title matches before body matches, and a muted text snippet; on narrow screens the results panel spans the header width.
- Footnotes are rendered after the last section instead of inside it (they no longer land in a call-to-action card).
- On screens under 48rem, code blocks with a Copy button start below the button so it never covers the first line.
- The rules are final: `RULES.md` and every file header now say `md-components v1` instead of `md-components v1 (draft)`. No rule changed.
- The public API is documented on the docs site; changes are listed in this CHANGELOG.
- `modootoday-check` also warns on `md-*` classes and `var(--md-*)` in the site's own includes, layouts, CSS and pages (code is ignored), not only in Sass.

### Pre-release history

Internal development milestones, never released. They are all part of 1.0.0.

#### Release readiness

##### Changed
- Layout: header, content and footer share one alignment line; footer text no longer truncates; kitchen sink sections are separated by rules; aside TOC lists h2 only; dark `muted`/`card` raised to `#1a212b` for contrast; footnotes styled.

##### Added
- Brand colour: `primary` and `ring` use the 모두의오늘 brand red (light `#b94022`, dark `#e96346`); new semantic `brand` token (`#d94925`) for the logo mark. Nav entries with `items:` render as a dropdown group at 64rem and up and as flat links below.
- Head metadata on by default: canonical URL (when `url` is set), `hreflang` from `modootoday.languages`, Open Graph and Twitter card tags; `modootoday.seo: false` turns them off for sites that use jekyll-seo-tag. Sitemap and feed stay opt-in plugins (`modootoday.feed: true` adds the feed link).
- `modootoday.csp: strict` loads the pre-paint script from `assets/js/modootoday/theme-init.js`, so no inline script is needed; CSP guide.
- Optional "Last updated" (`last_modified_at`) and edit link (`modootoday.edit_url`, `edit: false` per page).
- Checker validates `seo`, `feed`, `csp`, `languages` and `edit_url`, and warns on `md-*` names in site Sass.
- Docs: public API, migrate/upgrade guide, CSP guide, roadmap with non-goals (RTL, math, Mermaid), 404 page; the docs site uses sitemap, `hreflang` and edit links.
- SECURITY.md (private vulnerability reporting), CODE_OF_CONDUCT.md (Contributor Covenant 2.1), issue and pull request templates, Dependabot for Actions, Bundler and npm, RELEASING.md.
- CI job for the Jekyll 3.9 floor.


#### Milestone 0.5

##### Added
- Front-matter-less twin mode (`modootoday.twins: source`): on classic GitHub Pages, `jekyll-optional-front-matter` renders a page without front matter and copies the raw file to its own path, which becomes the twin without a stub. The `default` layout and `llms.txt` link to it; the generator skips such pages; the checker verifies the rendered page and the byte-identical raw copy and rejects `remove_originals`, `require_front_matter` and redundant stubs. Example site in `example/source-mode/`, built in CI on github-pages and Jekyll 4.
- Checker: `modootoday.twins` value check; directories listed in `exclude:` are skipped.
- Visual refresh: wide container (`container` 76rem) with a sticky, blurred header and a right-hand sticky table of contents from 64rem (a collapsible "On this page" below that); site footer; Rouge syntax-highlighting colors (`code-*` tokens); tinted, rounded alerts; white shadowed cards with hover; neutral secondary buttons; gradient CTA box; soft status badges; styled page meta line (last updated, edit link); polished tabs, accordion, steps, timeline, pagination, kbd and tables.
- Tokens: `line-height`, `container`, `header-height`, `space-section`, `radius-lg`, `shadow-sm`, `shadow`, `code-keyword|string|comment|function|constant`; primitives `radius-lg`, `orange-400/600`, `teal-400/600`, `space-10`, `space-16`.

##### Fixed
- An alert (or any paragraph with text) inside a hero no longer turns into a CTA row with its text hidden; only paragraphs made of links alone become action rows (`modootoday/actions.html`).
- Feature cards no longer show a stray "—" before the description.
- Header nav no longer wraps into several lines on narrow screens; it scrolls horizontally instead.

##### Changed
- QA CSS budget raised from 20 KB to 32 KB (uncompressed, as built); the built CSS is about 28 KB (5.7 KB gzip).

#### Milestone 0.4

##### Added
- P2 components: timeline (`c: timeline`), keyboard keys (`` `kbd:Ctrl+K` ``), client search (`modootoday/search.json` include + `search.js`, under 1 KB compressed), `post` layout.
- Read-only DTCG `tokens.json` generated in CI from the Sass maps (`script/tokens-json`), with a consistency test against the built CSS.
- Checker: `kbd:` value format.
- Example site: i18n keys `theme.toggle`, `breadcrumb.label`, `toc.label`, `search.label`, `post.date_format` (en/ko/ja).

##### Deferred
- `_data/components.yml` slot contract.

#### Milestone 0.3

##### Added
- P1 components: theme toggle (localStorage `mt-theme`, pre-paint script), breadcrumb, table of contents, accordion (`c: accordion`), steps (`c: steps`), figure/figcaption, `tag:` badges. All on by default; `modootoday.components` narrows them.
- Checker: `tag:` value format, images without alt text.

##### Changed
- Status/tag badges are also turned off when `badge` is not in `modootoday.components`.


#### Milestone 0.2

##### Added
- Three-layer design tokens: primitives `--mt-p-*`, shadcn-style semantic tokens (`--mt-background`, `--mt-primary`, …), component tokens (`--mt-callout-accent`, `--mt-badge-*`, `--mt-card-padding`); `data-theme="light|dark"` forcing.
- Sass split into `_sass/modootoday/{_settings,_core}.scss`, `tools/`, `tokens/`, `components/<name>.scss`; `@import` only, compiles on Ruby Sass 3.7 and Dart Sass.
- `modootoday:` config: `color_scheme`, `css_layers` (`@layer mt.*`, off by default), `components` (all P0 components on by default), `nav`, `tokens`, `tokens_dark` (inlined `<style id="mt-tokens">`). Defaults in `_includes/modootoday/config.html`.
- Components: navigation (`_data/nav/*.yml`, `aria-current`), prev/next pagination, code-copy button (`assets/js/modootoday/code-copy.js`); `mt-*` classes for callout, badge, hero, CTA, card (features), tabs.
- `_includes/footer-custom.html` hook; i18n keys `nav.label`, `pagination.*`, `code.*`.
- Checker: rejects `@use`/`@forward`/`@supports selector()` in Sass and built CSS, `--x: $var` literals, undefined `var(--mt-*)`, invalid `modootoday:` settings and token values.
- Tests: theme CSS built with all/minimal/layers configs on both engines (`test/css_test.rb`).
- CI: github-pages job on Ruby 3.3.4 with the production gem set (github-pages 232, jekyll-include-cache 0.2.1, jekyll-octicons 14.2, nokogiri 1.16.7); `remote_theme:` site built by `actions/jekyll-build-pages@v1` and checked; Jekyll 4 on Ruby 3.2 and 3.4.

##### Changed
- `required_ruby_version` is now `>= 3.2`.
- `badges: false` in `modootoday:` is honoured (it was swallowed by `default: true`).


##### Removed
- `_sass/modootoday/{_tokens,_base,_components}.scss` (replaced by the new partials; `_sass/modootoday.scss` still imports everything).

#### Milestone 0.1

##### Added
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

##### Fixed
- Sections split only on top-level `<h2>`; an `h2` inside a quote, list or alert no longer injects `</section><section>` into it.
- Docs: alerts are a GitHub extension outside the GFM spec; the raw-HTML ban is about portability (GitHub renders `details`/`kbd`, strips others; kramdown passes all through), not "GitHub sanitising".
- Checker messages for `##` and alerts nested in quotes/lists explain why and what to use instead.
- `required_ruby_version` raised to 3.0 (the checker uses endless methods).
- Example: `sass.silence_deprecations: [import]` for Dart Sass; `llms.txt` per language generated instead of hand-written.
- Raw `<name>.md` copies in `_site` on GitHub Pages: caused by content files without front matter (rendered by `jekyll-optional-front-matter` and also copied). Front matter is now required and checked.

[1.0.0]: https://github.com/modootoday/jekyll-theme-modootoday/tree/main
