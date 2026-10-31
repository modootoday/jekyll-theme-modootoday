# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).
The content rules have their own version header (`md-components v1`) in [RULES.md](RULES.md).

## [Unreleased]

### Fixed

- The `redirect` layout reads the target from `page.redirect.to`, where jekyll-redirect-from 0.16 puts it, as well as from `redirect_to`; redirect stubs had an empty refresh `url=`, an empty canonical and an empty "Continue to the new page" link. The refresh, canonical and link use the same target, and the docs audit flags empty ones.
- On a site without search the header's language menu and theme toggle sit at the inline end of the row (the first trailing control takes `margin-inline-start: auto`), in LTR and RTL; headers with search are unchanged. The docs audit checks the gap at 1440px and 390px.

## [1.2.2] - 2026-10-31

### Fixed

- Long inline code (`:not(pre) > code`) wraps inside the column with `overflow-wrap: anywhere` in paragraphs, lists, links, headings, callouts, quotes and table cells, so narrow screens such as 390px no longer scroll sideways; fenced code blocks keep their own horizontal scroll. The docs audit adds a 360px inline-code wrap check.

## [1.2.1] - 2026-10-31

### Fixed

- `hero.c` with a site's own component name (such as `c: cta` or `c: prose`) passes `modootoday-check` and renders the plain hero with no extra sheet, as in 1.1.1; the split checks (`visual:`, `side`, `ratio`) and the split sheet apply only to `hero: {c: split}`, whose wrong values are still errors.
- With a `modootoday.components` list, the `lists`, `bleed` and `terminal` sheets were empty unless the list named them, so `chrome: terminal`, `bleed:` and `modootoday.lists` lost their styles. These three names are now always included; their sheets are linked only by pages that use them, so other pages are unchanged.

## [1.2.0] - 2026-10-31

### Added

- `bleed: true` / `bleed: wide` on `hero:` or a section item (`.mt-bleed`, `.mt-bleed-wide`): a full-width background band in `--mt-bleed-bg` with the content kept in its column (`wide` widens it up to the container); no wrapper, so existing markup and selectors are unchanged and the default is as before; its own optional `bleed` sheet. `modootoday-check` accepts only true, false or wide.
- `hero: {c: split, visual: <name>, side: start|end, ratio: "1:1"|"5:7"}`: the hero in the split wrappers (`.mt-c-split`, `.mt-section-in`, `.mt-section-body`, `.mt-section-visual`), with the title, lead (`.mt-hero-lead`), check row and actions in the text column; heroes without `c:` render as before. Split sheet only; `modootoday-check` checks `c`, `visual:`, `side` and `ratio` on `hero:`.
- `visual: code` on a `c: split` section or a split hero: the first fenced block (with its `file:` title) moves into `.mt-section-visual.mt-split-code`, keeping the code styles, copy button and focusable `pre`; optional `chrome: terminal` adds a border and a decorative `aria-hidden` bar from a terminal sheet linked only by pages that use it. No include needed; elsewhere `visual: code` still names `_includes/sections/code.html`. `modootoday-check` requires a fence and checks `chrome`.

## [1.1.1] - 2026-10-31

### Added

- Release workflow: after the gem is pushed to RubyGems, a GitHub Release is created for the tag with its `CHANGELOG.md` entry as the notes (`script/release-notes`); skipped when the Release already exists.
- `mt-flat-list`: put it on an ancestor of an unclassed Markdown list that a layout makes a grid or flex row (`.c-body > ul`) to drop the gap between list items (RULES.md §6, Customize).
- `badge: bottom` on a `c: features` section (`.mt-badge-bottom`): a status badge at the end of a card item sits at the card's bottom edge, so badges line up across a row.
- `reveal: true` on `hero:` or a section item (`.mt-reveal`): a CSS-only fade-in on scroll, inside `@supports (animation-timeline: view())` and `prefers-reduced-motion: no-preference`. Without support, or when the reader prefers less motion, the content is shown as is. No script.
- Optional list styles: `modootoday.lists: {link_chips: true, titled_items: true}` turns link-only lists on plain sections and pages into `ul.mt-chips` and `- **Title**: text` items into `strong.mt-item-title` + `span.mt-item-sep`; `hero: {checks: true}` makes the hero's first list a row of ✓ marks (`--mt-ok`). They use a new `lists` sheet (under 1.25 KiB) linked only where used; core CSS is unchanged. The hero lead paragraph gets `.mt-hero-lead`.
- `decor: <include>` on `hero:` or a section item: an `aria-hidden` ornament in `.mt-section-decor`, placed in the top end corner. `modootoday-check` reports a missing include.
- `.mt-illustration` convention: `figure[role=img]` with a non-empty `aria-label` and an optional `.mt-illustration-tag` badge; `modootoday-check` reports any other markup in the built site.
- `ref:` in front matter links translations that live under different paths: `hreflang` and the language switcher use it, and `modootoday/link.html` with `ref=` gives that page's URL in the current language, or in the default language. `modootoday-check` reports a `ref=` that no page defines.
- `modootoday.full_languages` and `modootoday-check --i18n-pages`: warnings for default-language pages with no translation in those languages; `--strict` makes them fail.
- `c: split` section: text and its `visual:` include side by side from 48rem, stacked below; params `side: start|end` and `ratio: "1:1"|"5:7"`, inner wrappers `.mt-section-in`, `.mt-section-body`, `.mt-section-visual` (split only, so other sections keep their markup), its own section sheet. `modootoday-check` requires `visual:` on a split.
- `visual:` include: any other key on the section item reaches the include as `include.section.<key>`, and `modootoday-check` accepts such keys on a section that has `visual:`.
- Docs: moving from `jekyll-seo-tag` to the kit's SEO tags (Migrate), and what to run when `modootoday-check` is not on `PATH` after `gem install` (Install).

### Changed

- Brand: the visible site name is now **modoo.today theme** (Korean **모두의오늘 테마**, Japanese **modoo.today テーマ**, other languages localized) in the docs header, `<title>`, `og:site_name`, JSON-LD and breadcrumbs, so it is not confused with the modoo.today service. A new optional `site_title` in `_data/i18n/<lang>.yml` sets the header name per language and falls back to `site.title`. The gem name, repository paths, CSS classes, config keys and `modootoday-check` are unchanged.
- Size budgets have a little more headroom (QA, `qa/audit/config.mjs`): core CSS sheet 24 → 27 KiB, core JS 10 → 11 KiB, CSS one page links 32 → 35 KiB, `loading.css` 2 → 2.5 KiB, `figure.css` 1 → 1.25 KiB, each renderer script 2 → 2.5 KiB. Section sheets stay at 2 KiB. The built sizes did not grow (core CSS 24531 B, core JS 10227 B).

### Fixed

- Checker: specfold value markers with arguments after the name (`<!-- spec:graph format=mermaid source=tutorial -->`, `<!-- spec:count rows="All commands" -->`) are no longer reported as HTML comments (RULES.md, HTML comments row). The HTML comment error now quotes the first comment it found.
- Checker: JSON-LD between the `jekyll-seo-tag` comments (sites with `seo: false` that bring the plugin) is checked only for valid JSON and reported as a warning, so its `WebPage` without `name` is no longer an error; the kit's own block is still checked in full and not counted as a second block (Structured data).

## [1.1.0] - 2026-10-31

### Added

- Checker: one-line specfold value markers `<!-- spec:name -->` and `<!-- /spec:name -->` are allowed in page bodies, on their own line or inline in a sentence (RULES.md, HTML comments row).
- Cards: `cols: 4` for `c: features` sections (`.mt-cols-4`): four columns from 64rem, two from 48rem, one below.
- Diagrams: `modootoday.mermaid` (off by default) renders ```` ```mermaid ```` fences on the pages that have one, from a version-pinned URL with SRI `integrity` or a self-hosted path, through the separate `assets/js/modootoday-mermaid.js` bundle. Light or dark Mermaid theme follows the page, reduced motion is honoured, a wide diagram scrolls in a labelled focusable region (`diagram.label`, all 23 catalogs), and the source stays readable without JavaScript. Front matter `mermaid: false` skips a page.
- Math: `modootoday.math` (off by default) renders ```` ```math ```` fences and `$$` blocks with KaTeX (`inline: true` adds `$…$`) on the pages that have one, through `assets/js/modootoday-math.js`. Front matter `math: false` skips a page.
- Checker: validates `modootoday.mermaid` and `modootoday.math` (https, exact version, SRI hashes), reports any third-party script or stylesheet in built pages unless it is a declared renderer URL with matching `integrity` and `crossorigin="anonymous"`, and warns about inline `$…$` when `math.inline` is false.
- Figures: an `.svg` figure (a diagram) reads in dark mode from one file (`--mt-diagram-filter-dark`, built on `--mt-img-filter-dark`; `none` turns it off, a `#light` path keeps one image as drawn) and, on narrow screens, keeps `--mt-figure-min-width` and scrolls sideways in a focusable region named by its alt text. Raster figures are unchanged. The rules live in the optional `assets/css/modootoday/figure.css` sheet, linked only by pages with an SVG figure.
- Budgets: each `assets/js/modootoday-<name>.js` bundle has its own 2 KB budget and does not count toward the core script.

### Documentation

- Math and diagrams: the built-in loaders, math notation, and their CSP and privacy impact (CDN origin in `script-src`, `style-src`, `font-src`; visitors' IP addresses go to the CDN; self-hosting avoids both).
- Install guide: running `modootoday-check` on a `remote_theme` site (gem install, CI step) and the harmless `github-pages` warnings (`faraday-retry`, Sass `@import` notices).
- Page shells: `home` renders the body as written and does not read `sections:`; use `layout: doc` with `hero:` and `sections:` for a home page with sections.
- Twins: `twin_of` examples, relative to the stub; a path from the site root fails the build (RULES.md, agents guide).

## [1.0.0] - 2026-10-30

First public release, published on RubyGems on 2026-10-30. Nothing was published on RubyGems before 1.0.0. The changes directly below were made last; [Pre-release history](#pre-release-history) lists the earlier development milestones (0.1 to 0.5), which were internal and never released.

### Added
- **Links that open a new window:** `new_window: true` or `target: _blank` on nav items, cards, buttons, link cards, directory items, pricing calls to action and footer links, `[text](url "new-window")` on Markdown links (portable; kramdown `{: .mt-new-window}` also works), and `modootoday.external_links.new_window: true` for every external link. Each gets `rel="noopener noreferrer"`, a translated hidden hint (`new_window.hint`, in all 23 catalogs) through `aria-describedby`, and a CSS-only arrow (`external_links.icon: false` hides it). No script, so a strict CSP keeps working. Bare `#` sample links now stay `#` instead of pointing at the site root.
- **Blog and news demos:** blog index, blog post, news front page, news article and yearly archive (`layout: archive` with `archive: years`) demo pages in en/ko/ja, each with an Open in new window link. Demo pages are `noindex` and left out of the sitemap, search and sidebar.
- **Screen readers:** search results are announced (`aria-live`). `modootoday-check` reports `<img>` without `alt`, empty links and duplicate ids as errors, and empty Markdown alt, vague link text ("click here") and skipped heading levels as warnings. The [Accessibility page](docs/accessibility.md) has an authoring checklist (images, links, headings, tables, ids, language).
- **Accessibility:** safe areas on notched phones (`viewport-fit=cover` with `--mt-safe-top|right|bottom|left` padding the header, side gutters and footer; `modootoday.viewport_fit: auto` opts out), `theme-color` meta tags matching the light and dark background (`modootoday.theme_color`), 44 px touch targets and 16 px search text on touch screens, forced-colors borders on icon buttons and search. Keyboard: `/` and `Ctrl`/`Cmd`+`K` focus search, arrow keys and `Esc` in results, wide code blocks and tables become labelled focusable regions, focus rings drawn inside tabs and scroll regions. Labels `code.label` and `table.label` ship in all 23 catalogs. See the [Accessibility page](docs/accessibility.md).
- **Docs site structure:** pages are grouped by context into Guides, Components, Layouts, Recipes and Reference, each with an index page. The sidebar collapses groups you are not reading and shows at most three levels. Old page addresses such as `/install/` now live under their section, such as `/guides/install/`.
- **Structured data:** every page gets one schema.org JSON-LD `@graph` (WebSite, publisher, WebPage subtype per layout, main entity, BreadcrumbList) with stable `@id`s, `inLanguage`, ISO 8601 dates and absolute URLs, printed only when `url:` is set. Configure with `modootoday.schema` (`publisher`, `search_url`, `layouts`), extend per page with front matter `schema:`, turn off with `schema: false`. `modootoday-check` validates the blocks offline against the schema.org vocabulary and Google's required properties (`--schema-recommended` for recommended ones). See the Structured data docs page.
- **Per-component stylesheets:** the CSS is split into a core sheet (under 24 KiB) plus context sheets (`doc`, `search`, `loading`; the blog bundle stays separate) and one sheet per section component (each under 2 KiB). A page links only what it uses. `modootoday.css: bundle` links one combined sheet instead.
- **Content components:** file tree, details, FAQ (with FAQPage data), parameter table, link cards, quote, gallery (`:target` lightbox, no script), pricing (`recommended`), subscribe form; inline code titles (`file:`), progress (`progress:`), embeds (`embed:`), accessible footnote back-links; site banner and back-to-top link. Each has en/ko/ja docs examples, i18n keys in all 23 catalogs, a checker rule and a slot entry.
- **Loading and skeleton UI:** CSS-only spinner, thin top bar and skeletons (text, card, image, avatar, row) with `role="status"` and a translated label, reserved aspect-ratio placeholders (`.mt-ratio-*`, embeds, gallery thumbnails, sized images), reduced-motion, forced-colors and RTL support, in an optional `loading` sheet.
- Tabs and accordion scripts load only on pages that use them.
- **Page shells:** layouts `minimal`, `wide`, `home`, `error` (`status: 404 | 410 | 500`), `redirect` (`redirect_to:`) and `search` (no-JS fallback form, `modootoday.search.fallback`). They load the optional `modootoday-pages.css` bundle through `mt_bundle`; core CSS and JS do not grow. Labels in all 23 catalogs; `modootoday-check` checks their front matter. See [Layouts](docs/layouts/shells.md).
- **Detail layouts:** `project`, `case-study`, `job`, `event` and `episode` on one `detail` engine: header with kicker and lead, a facts list from front matter, the body and one call to action (Apply, Tickets with an `.ics` file, or `cta:`); episodes get the browser's own audio player. JSON-LD main entity from the same front matter: `CreativeWork`, `Article`, `JobPosting` (hiring organization = publisher, `employmentType`, `validThrough`, place or remote with `applicantLocationRequirements`, `baseSalary`), `Event` (place and/or `VirtualLocation`, attendance mode, offers) and `PodcastEpisode`; `schema:` overrides any property. Styles are the optional `modootoday-detail.css` bundle; `modootoday-check` checks the front matter. See [Detail pages](docs/layouts/detail/index.md).
- **Marketing layouts:** `feature`, `pricing`, `download`, `brand`, `links` and `contact` with the optional `modootoday-marketing.css` bundle and no JavaScript. Pricing reuses the pricing component cards with a CSS-only Monthly/Yearly radio switch; brand swatches are SVG fills (no inline style under CSP); `links` drops the site chrome and prints a `ProfilePage` whose Person/Organization `sameAs` lists the links; `contact` prints a `ContactPage` and a labelled form posting to an external https `form.action`. A new `mt_css:` layout list lets a layout load component sheets. `modootoday-check` checks plans, colors, downloads, links and the form. See [Marketing pages](docs/layouts/marketing/index.md).
- **Docs extras:** `reference` (member list with signatures and anchors, TechArticle), `changelog` (releases with Added/Changed/Fixed/Removed/Security in the page language), `roadmap` (now/next/later columns), `glossary` (sorted terms with a letter bar, DefinedTermSet), `hub` (card grid, CollectionPage with `hasPart`), `course` (modules, lessons and total time, Course with provider and `timeRequired`) and `book` (cover, author, ISBN, chapters, Book). Styles are the optional `modootoday-docs-extra.css` bundle; `modootoday-check` checks statuses, terms, cards, minutes, pages and ISBNs. See [Docs extras](docs/layouts/docs-extra/index.md).
- **Documents:** `legal` (required `effective` date, `updated`, `version`, contents list; `datePublished`/`dateModified`; in the pages bundle) and `resume` (print-first CV in its own `modootoday-resume.css` bundle with `@page` margins and h-card markup; ProfilePage whose Person gets `worksFor`, `alumniOf` and `knowsAbout`). Both hide the site chrome when printed. See [Documents](docs/layouts/documents/index.md).
- **Recipes by site type:** product, company, documentation, personal, community and system page sets in en/ko/ja under `docs/recipes/`.
- **Directory layouts:** `directory` with presets `portfolio`, `team`, `jobs`, `events`, `sponsors` and `integrations`: a card grid from `items:` or `data:` (a file in `_data`), with a filter made of radio buttons that needs no JavaScript (`filter: <field> | false`, up to 12 values), round team photos, event date tiles with an `.ics` file in a `data:` link, and schema.org `ItemList` of `Person` or `Event` (online events get `VirtualLocation`). Styles are the optional `modootoday-directory.css` bundle; `modootoday-check` checks the items. See [Directory layouts](docs/layouts/directory/index.md).
- **Doc sidebar:** `doc` pages get a sidebar built from the nav groups (`modootoday.sidebar: auto | true | false`, default `auto` = on when the nav has groups; `sidebar: false` in front matter). From 64rem it is a sticky column; below, a collapsed menu above the page shows the current group, replacing the horizontally scrolling link row. With a sidebar the header drops the flat group links.
- **Page actions:** on pages with a Markdown twin, a menu offers View as Markdown, Copy page and Copy for AI (source URL, then the Markdown). `modootoday.page_actions: false`, front matter `page_actions: false`, or leaving `page-actions` out of `components` removes it. Labels (`page_actions.*`, `sidebar.label`) ship in all 23 catalogs.
- `color_scheme: auto-dark` and `auto-light` start in that scheme and keep the toggle; the start is printed as `data-theme` in the HTML, so there is no flash and no `head-custom.html` script.
- **Blog and news layouts:** `blog` (paginated index of post cards with `variant: list | grid | magazine`, featured first, per-language), `news` (front page with lead, secondary stories and `news_sections` blocks), `news-article` (dateline, deck, breaking/live badges, correction, sources), `author` (profile and posts) and `feed` (per-language Atom). The `post` layout gains a byline from `_data/authors.yml` (`author:` or `authors:`), published/updated dates, reading time, cover image, series box, previous/next, related posts, a share button, `BlogPosting`/`NewsArticle` JSON-LD and OG `article:*` tags. Settings live under `modootoday.blog` and `modootoday.news`; labels are translated in all 23 catalogs. Liquid only (classic GitHub Pages and Jekyll 4). The styles (`modootoday-blog.css`) and `share.js` are a separate optional bundle loaded only by these layouts, with their own size budgets; the core bundles are unchanged. `modootoday-check` validates the settings, `_data/authors.yml` and post front matter. See [Blog and news](docs/layouts/blog-news.md).
- **Result container for CTA sections:** when a `c: cta` section holds an element with `data-mt-result`, the `.mt-cta` box (centering, gradient, border) goes on that element instead of the whole section. Sections without one render exactly as before. The docs Components page uses it, so the Buttons example card matches the other cards and only its result is framed.
- `visual: <name>` on a `sections:` item and `hero: {visual: <name>}` render a site-provided `_includes/sections/<name>.html`; `modootoday-check` fails when it is missing.
- `full_width: true` front matter removes the reading-column width of `main` (`.mt-main-full`).
- Breadcrumb: the home crumb uses the home page `short_title:` when set.
- `modootoday-check` accepts tool region markers alone on a line (`<!-- spec:toc:begin -->` / `<!-- spec:toc:end -->`); other HTML comments are still errors.
- `modootoday.hreflang` keeps `hreflang` alternates when `seo: false`.
- **Icons:** `modootoday/brand/icon.html` renders inline SVG icons (`name`, `size`, `label`, `class`) in `currentColor`, decorative unless labelled, with directional icons mirrored in RTL. Every former text, emoji or CSS-drawn icon (language globe, theme sun/moon, search, nav chevron and external link, breadcrumb separators, alert types, copy/check, edit link, previous/next, tag and category badges) now uses it. See the [API page](docs/reference/api.md#stable-names).
- **Logo and favicon:** `modootoday.logo: brand | <path>` shows the modootoday mark (or your image) before the site title through the overridable `modootoday/brand/logo.html`; `modootoday.favicon: brand | <path>` links an SVG, 32 px PNG and Apple touch icon. The docs site uses both.
- **Built-in translations:** set `lang:` and the theme's labels (skip link, navigation, callouts, status badges, table of contents, pagination, code copy, search, language menu) are localized for 23 languages with nothing to copy, on GitHub Pages and Jekyll 4. A site `_data/i18n/<lang>.yml` overrides individual keys; unknown languages use English. `modootoday/t.html` prints a label by key. `modootoday-check --i18n-init` copies a catalog to edit, and `--i18n` checks keys and placeholders; `.yaml` catalogs are rejected.
- **Language switcher:** `modootoday.language_switcher: header | footer` renders a theme-level switcher from `languages` (the same alternates as `hreflang`), linking to the translation of the current page or that language's home page. In the header it is a globe button with a `<details>` dropdown (localized accessible name, `aria-current`, `lang`/`hreflang` on each link) that keeps the same width however many languages there are; in the footer, a list. Nothing renders with fewer than two languages. `modootoday/lang-switch.html` can be included from a custom footer. The docs site uses the header menu in place of its footer list.
- `menu.js` (small, CSP-safe): Esc closes a `<details class="mt-menu">` and returns focus, arrow keys move between items, an outside click or opening another menu closes it. Used by the language menu and the nav "More" group.
- On screens under 30rem, search takes its own row under the site title.
- **Tag and category archives:** the `archive` layout (`archive: tags | categories`) and the `modootoday/archive.html` include list terms with post counts and one anchored section per term, filtered by language (`archive_lang: all` for every post). With `modootoday.archive: {tags: /tags/, categories: /categories/}` the `post` layout adds a footer linking each tag and category. Liquid only, so it works on classic GitHub Pages; one page per taxonomy, not per term. `modootoday-check` validates `modootoday.archive` and skips twins for `_posts/`. The post and archive styles ship in the optional `modootoday-blog.css` bundle (loaded by the `post`, `archive` and blog/news layouts; `blog_css: true` opts any other page in, for example one that uses the `modootoday/archive.html` include). See the [API page](docs/api.md#posts-and-archives).
- Slot contract: `slots:` in `_data/components.yml` declares the named parts of a section (`lead`, `items`, `panels`, `actions`, `code`, `figures`) with `required`/`min`/`max`; `modootoday-check` counts them per section. Markup is unchanged. See the [API page](docs/api.md#slot-contract).
- Slot contract: `slots:` can be a list of alternative forms (a section passes when it satisfies one; `steps` and `timeline` accept a list or `###` panels), and `parts:` declares the stable selectors of a component, checked against the component structure table of `api.md` when the site has one. See the [API page](docs/api.md#slot-contract).
- **Right-to-left:** `dir="rtl"` from `lang` for RTL languages, `direction:` front matter override, logical properties in component CSS, LTR code inside RTL text, RTL-aware tab arrow keys, and an RTL kitchen sink checked in docs QA.
- [Math and diagrams](docs/recipes/math-diagrams.md) guide (en, ko, ja): KaTeX and Mermaid under a strict CSP, rendered at build time or self-hosted. The theme bundles neither.
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

[Unreleased]: https://github.com/modootoday/jekyll-theme-modootoday/compare/v1.2.2...HEAD
[1.2.2]: https://github.com/modootoday/jekyll-theme-modootoday/releases/tag/v1.2.2
[1.2.1]: https://github.com/modootoday/jekyll-theme-modootoday/releases/tag/v1.2.1
[1.2.0]: https://github.com/modootoday/jekyll-theme-modootoday/releases/tag/v1.2.0
[1.1.1]: https://github.com/modootoday/jekyll-theme-modootoday/releases/tag/v1.1.1
[1.1.0]: https://github.com/modootoday/jekyll-theme-modootoday/releases/tag/v1.1.0
[1.0.0]: https://github.com/modootoday/jekyll-theme-modootoday/releases/tag/v1.0.0
