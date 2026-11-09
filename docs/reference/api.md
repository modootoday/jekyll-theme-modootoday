---
nav_order: 10
title: Public API
description: The names, classes, includes and files this theme documents for your site, which stay stable within a major version, and how they may change.
---
# Public API

The public API is documented here; changes are listed in `CHANGELOG.md`. Anything not listed (internal includes, Sass partial paths, private `--mt-p-*` primitives, HTML details that no rule describes) can change in any release.

## Stable names

| Area | Stable names |
|---|---|
| Settings | Every key under `modootoday:` in [Configuration](../../guides/configuration/). |
| Design tokens | The `--mt-*` custom properties, not the `--mt-p-*` primitives. |
| Sass | Only the token hook `_sass/modootoday/_site.scss` and its override maps. See [Customize](../../guides/customize/#token-bridge). |
| Markdown rules | The patterns in `RULES.md`, their `mt-*` classes, and `mt-flat-list`. |
| Layouts | Every layout in the [Layouts](#layouts) table below; the one marked internal is not part of the API. |
| Includes you may override | `head-custom.html`, `footer-custom.html` and `modootoday/brand/logo.html`. |
| Includes you provide | `_includes/sections/<name>.html`, shown by `visual: <name>`. See [Customize](../../guides/customize/#section-visuals-and-full-width-pages). |
| Module helpers and events | Two ES modules for your `scripts`, the `mt:themechange` event and the `script:` visual contract. |
| Includes you may call | `modootoday/archive.html`, `modootoday/brand/icon.html` and the two footer includes. |
| Includes | `modootoday/t.html` prints a theme label in the page language. |
| Data files | `_data/i18n/<lang>.yml`, `_data/nav/<name>.yml`, `_data/navigation.yml`, `_data/authors.yml`, `_data/components.yml` |
| Checker | `modootoday-check` options and exit codes, listed on [Command line](../cli/). |
| Static figures | Front matter `diagrams:`, the `data-mt-src` digest rule and the `diagram.source` label; `modootoday.math.mode: static`, `_data/math/<key>.yml`, front matter `math_key:` and the `math.label` label. |
| Record pages | `modootoday.records`, the record front matter and the facts list. |
| Showcase | `modootoday.showcase`, the session storage key `mt-showcase` and the `showcase.*` labels. |
| Stub writer | `modootoday-stubs` options (on [Command line](../cli/)), stub file names and front matter, and exit codes. |

Details for the rows above:

- Design tokens: the generated `tokens.json` mirrors them.
- Sass: the maps are `$mt-overrides-base`, `$mt-overrides` and `$mt-overrides-dark`. Every other Sass partial and variable is internal.
- Markdown rules: `mt-flat-list` is an opt-out class that removes the gap between the list items below it.
- Layouts: `page` is the `doc` layout under the name Jekyll and minima use.
- Includes: your footer can include `modootoday/lang-switch.html` and `modootoday/brand/logo.html` (takes `size`); override `modootoday/brand/logo.html` to draw your own logo. `modootoday/archive.html` takes `by` and `lang`. `modootoday/t.html` takes `key=`, optional `n=` / `name=`.
- `modootoday/brand/icon.html` takes `name` (globe, sun, moon, search, menu, copy, check, external, prev, next, chevron-right, chevron-down, note, tip, important, warning, caution, edit, rss, tag, folder, brand), optional `size` (px, default 18), `label` (makes it `role="img"` with that name; otherwise `aria-hidden`) and `class`. Output: `svg.mt-icon.mt-icon-<name>` in `currentColor`; directional icons add `.mt-icon-flip` (mirrored in RTL).
- Module helpers: `assets/js/modootoday/theme/current.js` (`currentTheme()`, `onThemeChange(callback)`, which returns a function that stops listening) and `assets/js/modootoday/dom/config.js` (`readConfig(element, defaults)`). The `mt:themechange` event is under [Events](#events). The `script:` visual contract is `data-mt-script`, `.mt-visual-stage` and `data-mt-ready`; see [Customize](../../guides/customize/#module-scripts-and-posters).
- Data files: `_data/i18n/<lang>.yml` keys are optional overrides of the built-in catalogs; `_data/navigation.yml` is read for `main`.
- Checker exit codes: 0 (no problems) and 1 (problems or bad usage). `modootoday-check SRC --diagrams` prints the static diagrams whose SVG is missing or stale as JSON (`page`, `name`, `line`, `fence`, `digest`, `files`, `reason`; see [Keep diagrams fresh](../../recipes/figures/math-diagrams/#keep-diagrams-fresh)) and exits with 1 when the list is not empty. `modootoday-check SRC --math` does the same for static math: the `_data/math` files to write (`key`, `file`, `page`, `blocks` with `line`, `tex` and `digest`, `reason`).
- Static figures: `diagrams: [{name, alt, caption, width, height}]` maps the n-th ```` ```mermaid ```` fence of a page to its n-th entry (see [Math and diagrams](../../recipes/figures/math-diagrams/#static-diagrams)). `data-mt-src="sha256-<hex>"` on an SVG's root element records the fence it was drawn from: the SHA-256 of the fence body (the lines between the fence lines) with CRLF and CR turned into LF and the final newlines removed. `modootoday-check` reports an SVG whose `data-mt-src` differs from its fence's digest as a stale diagram. `diagram.source` in `_data/i18n/<lang>.yml` names the source disclosure.
- Static math: with `modootoday.math.mode: static`, the n-th ```` ```math ```` fence or `$$` block of a page is replaced by the `html` of the n-th entry of `_data/math/<key>.yml`, a list of `{src, html}` (see [Static math](../../recipes/figures/math-diagrams/#static-math)). `<key>` is the default-language source path of the page without its extension, with `/` as `--` (front matter `math_key:` overrides it); `src` is the block's digest by the rule above, over the TeX between the delimiters. `math.label` (`Formula [n]`) names each block's region.
- Record pages: `modootoday.records` (see [Generated pages](../../recipes/generated-pages/)), the page front matter `record: <set>/<key>` and `record_index`, `records: <set>` on a directory page, and the facts list `dl.mt-detail-facts.mt-record-facts`.
- Showcase: see [Starter demo showcase](../showcase/). The labels are `showcase.region`, `showcase.theme`, `showcase.demo`, `showcase.docs`, `showcase.docs_short`, `showcase.use`, `showcase.dismiss` and `showcase.starters.<name>`; the session storage key `mt-showcase` holds `off` after a reader hides it.
- Stub writer: the stub files are `<name>.md.txt`, `<name>.flat.md.txt`, `<name>.html.md.txt` and record pages `<dir>/<key>.md`. Exit codes: 0 (nothing to do, previewed or written), 1 (`--check` found drift), 2 (usage or `_config.yml`) and 3 (data).

## Layouts

Every layout the theme ships, by the page that documents its front matter. The names are the `layout:` values.

| Group | Layouts |
|---|---|
| [Layouts](../../layouts/) | `default`, `doc`, `page`, `post`, `archive` |
| [Page shells](../../layouts/shells/) | `home`, `wide`, `minimal`, `error`, `redirect`, `search` |
| [Directory layouts](../../layouts/directory/) | `directory`, `team`, `jobs`, `events`, `sponsors`, `portfolio`, `integrations` |
| [Detail pages](../../layouts/detail/) | `project`, `case-study`, `job`, `event`, `episode` |
| [Marketing pages](../../layouts/marketing/) | `feature`, `pricing`, `download`, `brand`, `links`, `contact` |
| [Blog and news](../../layouts/blog-news/) | `blog`, `news`, `news-article`, `author`, `feed` |
| [Docs extras](../../layouts/docs-extra/) | `reference`, `changelog`, `roadmap`, `glossary`, `hub`, `course`, `book` |
| [Documents](../../layouts/documents/) | `legal`, `resume` |
| [AI agents](../../guides/agents/) | `twin`, `llms`, `llms-full` |
| Internal | `detail`, the base the detail pages extend; use one of them instead |

## Markdown rules

`md-components v1` is the name of the Markdown rules standard in `RULES.md`, published as the [Markdown rules](../rules/) page; it is not a CSS prefix. Output classes use `mt-*`.

## Component structure

This is the markup you can target from your own CSS today. Classes and attributes in this table are part of the public API; elements inside them that the table does not name (wrappers, generated ids, the order of child elements) are not. The [slot contract](#slot-contract) names the Markdown parts each component consumes.

| Component | Root | Parts | States |
|---|---|---|---|
| Page shell | `body.mt-body` | `a.mt-skip`, `header.mt-header`, `main.mt-main`, `footer.mt-footer` > `.mt-footer-inner` | `html[data-theme=light\|dark]` |
| Doc page | `article.mt-doc` | `.mt-doc-layout` > `.mt-doc-main` and `.mt-doc-aside` (holds `nav.mt-toc`), `nav.mt-toc-mobile`, `nav.mt-breadcrumb`, `.mt-page-meta`, `nav.mt-pagination` | — |
| Doc sidebar | `aside.mt-doc-nav` > `nav.mt-sidebar`; `details.mt-sidebar-mobile` | `.mt-sidebar-group`, `.mt-sidebar-title`, the `ul` of links | `.mt-doc-layout.mt-has-sidebar`; `[open]` on the mobile menu |
| Page actions | `details.mt-menu.mt-page-actions` | `summary`, `button[data-mt-act=copy\|ai]`, `a[type="text/markdown"]` | `[open]` |
| Hero | `section.mt-hero` | the `h1`, `p.mt-hero-lead`, the link-only `p` (buttons) | `.mt-hero-checks` |
| Section | `section.mt-section` | the `h2` and its content | `[data-section]`, `[data-c]`, `.mt-c-<c>`, `.mt-cols-<n>`, `.mt-cta` |
| Section decor | `.mt-has-decor` on `section.mt-hero` or `section.mt-section` | `.mt-section-decor[aria-hidden=true]` | — |
| Scroll reveal | `.mt-reveal` on `section.mt-hero` or `section.mt-section` | — | fades in on scroll |
| Full-width band | `.mt-bleed`, `.mt-bleed-wide` on `section.mt-hero` or `section.mt-section` | — | `--mt-bleed-bg` sets the color |
| Illustration | `figure.mt-illustration[role=img][aria-label]` | `.mt-illustration-tag` | — |
| List styles | `ul.mt-chips`; `li > strong.mt-item-title + span.mt-item-sep` | the `li > a` chips; the title and separator | — |
| Prose (no `sections:`) | `div.mt-prose` | the rendered body | — |
| Card grid | `section.mt-section` | `ul > li`, its leading `strong` is the title | `.mt-cols-2`, `.mt-cols-3`, `.mt-cols-4`, `.mt-badge-bottom` (`c: features`) |
| Tabs | `section.mt-c-tabs[data-tabs]` | `[role=tablist]`, `[role=tab]`, `[role=tabpanel]` | `[aria-selected]` |
| Accordion | `section.mt-c-accordion` | `h3 > button[aria-expanded]`, the panel after it | `[aria-expanded=true\|false]` |
| Steps / Timeline | `section.mt-c-steps`, `section.mt-c-timeline` | `ol > li` or `h3` items | — |
| File tree | `section.mt-c-filetree` | `ul[aria-label]`, nested `ul` (folders) | — |
| Details / FAQ | `section.mt-c-details`, `section.mt-c-faq` | `details.mt-details`, `summary > h3`, the content after it | `[open]` |
| Table | `div.mt-table` | the `table` inside it | `table.mt-table--stack`, `table.mt-table--dl`, `table.mt-table--fixed`, `td[data-label]` |
| Parameter table | `section.mt-c-params` | `th[scope=col]`, `.mt-param-required` | stacks on narrow screens |
| Link cards | `section.mt-c-linkcards` | `ul > li > a` (the whole card is the link) | — |
| Quote | `figure.mt-quote` | `blockquote`, `figcaption` | — |
| Gallery | `section.mt-c-gallery` | `a.mt-gallery-thumb`, `a.mt-lightbox`, `.mt-lightbox-close` | `:target` on the open lightbox |
| Pricing | `.mt-plans` | `.mt-plan`, its `h3`, link-only `p.mt-actions` | `.mt-plan-recommended` with `.mt-plan-flag` |
| Subscribe | `section.mt-c-subscribe` | `form.mt-subscribe`, `label`, `input[type=email]`, `button` | — |
| Split | `section.mt-c-split` | `.mt-section-in` > `.mt-section-body` + `.mt-section-visual` | `.mt-split-start`, `.mt-split-5-7`, `.mt-split-code`, `.mt-split-terminal` |
| Inline extras | `div.mt-code`, `span.mt-progress`, `div.mt-embed` | `.mt-code-title`, `progress`, `iframe` | — |
| Loading (optional stylesheet) | `.mt-spinner`, `.mt-topbar`, `.mt-skeleton` | `.mt-skeleton-text`, `-card`, `-image`, `-avatar`, `-row`; `.mt-ratio-16x9`, `-4x3`, `-1x1` | `[aria-busy=true]`, `[role=status]` |
| Banner | `div.mt-banner` | its `p` and link; `a.mt-back-to-top` | — |
| Showcase | `div.mt-showcase-region[role=region]` with `.mt-showcase-bar` or `.mt-showcase-pill`, right after `a.mt-skip` | `.mt-showcase-mark`, `p.mt-showcase-label`, its links (the filled one `a.mt-showcase-solid`), `button.mt-showcase-dismiss` | `html[data-mt-showcase]` = bar, pill, off; `.mt-showcase-more` (hidden below 40rem), `.mt-showcase-less` (shown only there) |
| Alert | `blockquote.mt-callout[role=note]` | `p.mt-callout-title`, the body | `.mt-callout-<type>`, `[data-variant]` = note, tip, important, warning, caution |
| Badge | `span.mt-badge` | the label (a status badge draws its dot with `::before`) | `.mt-badge-<status>`, `.mt-badge-tag`, `[data-variant]` |
| Keyboard keys | `kbd.mt-kbd` | `kbd` per key | — |
| Figure | `figure.mt-figure` | `img`, `figcaption` | — |
| Static math | `figure.mt-figure.mt-math` | `div.mt-figure-scroll[role=region]` holding the `<math>` element, or KaTeX's HTML | — |
| Static diagram | `figure.mt-figure.mt-figure-svg.mt-diagram` | `div.mt-figure-scroll[role=region]`, `img.mt-diagram-light`, `img.mt-diagram-dark`, `figcaption`, and after the figure `details.mt-diagram-source` | the image for the other color scheme is hidden |
| Post header | `header.mt-post-header` | `h1.mt-post-title`, `.mt-post-deck`, `.mt-byline`, `figure.mt-post-cover`, `nav.mt-series`, `p.mt-post-meta` | `[data-part]` = header, deck, byline, authors, dates, cover, terms |
| Post footer | `article.mt-doc` | `.mt-share` button, `nav.mt-post-nav`, `section.mt-related`, `.mt-news-correction`, `.mt-news-sources` | `[data-part]` = share, post-nav, related, sources |
| Post card | `article.mt-card-post` | `.mt-card-post-cover`, `.mt-card-post-meta`, `.mt-card-post-title`, `.mt-card-post-excerpt` | `.mt-card-post-featured`, `[data-kind=news]`, `.mt-post-list[data-variant=list\|grid\|magazine]` |
| News front | `div.mt-news-top` | `.mt-news-lead`, `.mt-news-secondary`, `section.mt-news-latest`, `section.mt-news-section` | `[data-category]`, `.mt-badge[data-variant=breaking\|live]` |
| Search | `div.mt-search[role=search]` | the input, `.mt-search-results` | `[data-match=terms]`, `[data-compact]`, `[data-results]` |
| Filter | `[data-mt-filter]` | `div.mt-filter`, `.mt-filter-chips[role=group]` > `button[aria-pressed]` | `[data-facet]`; `[hidden]` on items left out |
| Chart | `figure.mt-chart` | `.mt-chart-canvas` (`[hidden]` until the chart module draws a `canvas[role=img]` named by the caption in it), `.mt-chart-data` > `div.mt-table` > `table` (`figure.mt-chart table`; folded into `details` > `summary` once drawn), `figcaption` | `[data-type]`, `[data-opts]`; color hooks `--mt-chart-1` to `--mt-chart-8`, `--mt-chart-grid`, `--mt-chart-text` |
| Widget | `section.mt-c-widget`, the site's custom element with `.mt-widget` | `.mt-widget-fallback` (the section text, or the `widget.fallback` sentence; hidden once the element is defined) | `[data-props]` (the props as JSON) |

Notes on the rows above:

- Page shell: `header.mt-header` > `.mt-header-inner` holds `.mt-site-title` > `.mt-site-name` (the name: up to two lines, a long word breaking after a dot, then an ellipsis; with a logo the title also has `.mt-compact-title`, which hides the name visually below 30rem), `nav.mt-nav`, `.mt-search`, `details.mt-lang.mt-menu` and `.mt-theme-toggle`. From 64rem `nav.mt-nav` is a `ul` row of links; below 64rem it is `details.mt-menu.mt-nav-sheet` with a `summary` menu button and a `ul` sheet with `.mt-nav-sheet-label` group titles. The language menu has a `summary` globe button and a `ul` of `a[lang][hreflang]`; the current one has `aria-current`. `html[data-theme]` is set by a fixed scheme or by the toggle.
- Doc sidebar: `nav.mt-sidebar` shows from 64rem, `details.mt-sidebar-mobile` below. The current link has `aria-current=page`.
- Page actions: the buttons sit in a `ul` and stay hidden until JS runs; `a[type="text/markdown"]` is View as Markdown.
- Hero: the lead is the first `p` right after the `h1`; in the link-only `p` the first link is primary. `.mt-hero-checks` comes from front matter `hero: {checks: true}`: the first `ul` becomes a row of ✓ marks in `--mt-ok`.
- Section: `[data-section]` is the name; `[data-c]` and `.mt-c-<c>` are the component. `.mt-cta` sits on the section, or on a `[data-mt-result]` element inside it when one is present; a `c: widget` element then wraps only that element's content.
- Section decor: front matter `decor: <include>`. The decor is the last child, holds `_includes/sections/<include>.html`, sits in the top end corner and takes no pointer events.
- Scroll reveal: front matter `reveal: true`. CSS only: it fades in inside `@supports (animation-timeline: view())` and `prefers-reduced-motion: no-preference`, and is shown as is otherwise.
- Full-width band: front matter `bleed: true` or `bleed: wide`. Inside a sidebar or table-of-contents layout the band stays in the main column. It uses the `bleed` sheet.
- Illustration: your own include. The tag is a badge above the picture, at the start. Put its text in the `aria-label` too, because the children of `role=img` are not read.
- List styles: with `modootoday.lists`. The chips are 44px tall with → after the text; the separator is `: `.
- Tabs: JS builds the tab parts; without JS the `h3` and code blocks stay.
- File tree: items holding a nested `ul` are folders.
- Table: `div.mt-table` is added around every body table at render time; it scrolls, and becomes a labelled region when it overflows. `c: params` tables get `--stack`, and so does any table that does not fit below 40rem, so page bodies set no class; the three classes are hooks for tables in a site's own layouts and includes (a kramdown attribute list in a body is not portable, and `modootoday-check` reports it). Once the script has labelled a stacked table it has `[data-mt-labelled]` and `td[data-label]`. Styles come from the `table` and `table-stack` sheets.
- Parameter table: below 40rem it stacks as `table.mt-table--stack`.
- Subscribe: `form.mt-subscribe` appears when an action is set.
- Split: `.mt-section-body` holds the `h2` and text, `.mt-section-visual` the `visual:` include. `hero: {c: split}` puts `section.mt-hero` in the same wrappers, with the `h1`, lead, check row and actions in `.mt-section-body`. `visual: code` puts the first code block in `div.mt-section-visual.mt-split-code`; `chrome: terminal` adds `.mt-split-terminal` and `div.mt-split-bar` (`aria-hidden`).
- Post header: `.mt-byline` holds `.mt-byline-authors` > `.mt-post-author` and `.mt-byline-dates` > `time`; `p.mt-post-meta` holds the tag badges.
- Search: the states come from `modootoday.search`.
- Filter: the root is `section.mt-section`, `div.mt-prose` or `div.mt-dir` (front matter `filter:`, `filter_text:`). `div.mt-filter` holds `input[type=search]` and `output[aria-live]`, hidden until the script moves it before the first list or table. The chips appear with a facet; `[data-facet]` is the column. It uses the `filter` sheet.

## Slot contract

A slot is a named part of a section's Markdown. Slot names are stable under the policy above, and declaring them never changes the generated markup. `modootoday-check` counts each slot in every section whose `c:` has a `slots:` entry in `_data/components.yml`, and fails when a count is outside the declared range.

| Slot | What it counts in the section (after its `##` heading) | Renders as |
|---|---|---|
| `lead` | Plain paragraphs before the first list, `###`, code block or quote | `p` |
| `items` | List items | `ul > li` or `ol > li` (cards, steps) |
| `panels` | `###` headings | tab, accordion or step panels |
| `actions` | Link-only lines | CTA buttons (`c: cta`) |
| `code` | Fenced code blocks | `pre` (tab content) |
| `figures` | Lines that start with an image | `figure.mt-figure` |

Each slot takes `required: true` (same as `min: 1`), `min` and `max` (whole numbers, `min` not greater than `max`). For a component that has two valid shapes, `slots:` can be a list of alternative forms; a section passes when it satisfies any one of them. `parts:` lists the selectors from the [component structure](#component-structure) table that the component promises to keep; when the site has an `api.md` with that table, every part must appear in it. When Nokogiri is available (it is under `github-pages`), every part must also match inside a section of that component in the built HTML of the pages that use it; parts that component scripts add at runtime (`role=`, `aria-*`) are checked after the scripts run by the docs site QA.

```yaml
features: {params: {cols: {allowed: [2, 3, 4]}, badge: {allowed: [bottom]}}, slots: {items: {min: 1}}, parts: [ul > li, .mt-cols-2, .mt-cols-3, .mt-cols-4, .mt-badge-bottom]}
tabs: {i18n: [tabs.label], slots: {panels: {min: 2}, code: {min: 2}}}
cta: {slots: {actions: {required: true}}, parts: [.mt-cta]}
accordion: {slots: {panels: {min: 1}}}
steps: {slots: [{items: {min: 1}}, {panels: {min: 1}}], parts: [section.mt-c-steps, ol > li]}
```

A component entry takes only `params`, `i18n`, `slots` and `parts`, and a slot rule only `required`, `min` and `max`. Any other key, an unknown slot name, a `min` above `max` or a list of fewer than two forms is an error, reported once per registry. Components without `slots:` are not counted, and a single-map `slots:` behaves exactly as before.

## Events

| Event | When | `detail` |
|---|---|---|
| `mt:themechange` | The page switches between light and dark mode. | `{theme: "light" or "dark", source: "toggle" or "system"}` |

The theme toggle (`theme-toggle.js`) sends it on `document` after a click, and after a change of the system color scheme while the reader has not chosen one. It stays in the same document, is never sent on the first paint, and is not sent on sites without the toggle (`color_scheme: light` or `dark`).

For one callback per real change that also works without the toggle, use `onThemeChange` from `assets/js/modootoday/theme/current.js`: it listens to the event and to the system setting, and returns a function that stops listening.

## Right-to-left and math

- Pages in Arabic, Persian, Hebrew, Urdu and other RTL languages get `dir="rtl"` from `lang`; set `direction: rtl` or `ltr` in front matter (or `direction:` in `_data/i18n/<lang>.yml`) to override. Components use logical properties and mirror; code stays left-to-right.
- The theme bundles no math or diagram renderer; static diagrams and math show the SVG files and MathML you commit. See [Math and diagrams](../../recipes/figures/math-diagrams/).

## Posts and archives

Posts use the `post` layout: a date, author and tag line, the body, then a footer that links each category and tag to its archive section. Set the archive pages in `_config.yml`:

```yaml
modootoday:
  archive: {tags: /tags/, categories: /categories/}
```

Then add one page per taxonomy, for example `tags.md`:

```yaml
---
title: Tags
layout: archive
archive: tags        # or categories
---
```

The page shows its own body, an index of terms with post counts, and one section per term (`id="tags-<slug>"`, newest post first). To place an archive anywhere else, call the include `modootoday/archive.html` from a layout or include, with `by` set to `tags` or `categories` and an optional `lang`. Archive styles live in `modootoday-blog.css`: the `archive` and `post` layouts load it, and any other page that calls the include needs `blog_css: true` in its front matter.

- A post's language is its `lang` (or `site.lang`). An archive lists only posts in the page's language; `archive_lang: all` (or `lang="all"` on the include) lists every post. Footer links of a post whose `lang` differs from `site.lang` point at `/<lang>/tags/`, so add an archive page under each language directory.
- Labels come from `archive.tags`, `archive.categories`, `archive.posts` and `archive.empty` in `_data/i18n/<lang>.yml`, with English fallbacks.
- Limits: classic GitHub Pages runs no custom plugin, so there is one page per taxonomy with an anchor per term, not one page per term. Posts get no Markdown twin; agents find them through the archive links. Jekyll puts the folder names above `_posts/` into `categories`, so keep posts in the top-level `_posts/` and set `lang:` in front matter.
