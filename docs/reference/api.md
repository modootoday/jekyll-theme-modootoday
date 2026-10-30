---
nav_order: 10
title: Public API
description: The names, classes and files this theme documents for your site.
---
# Public API

The public API is documented here; changes are listed in `CHANGELOG.md`. Anything not listed (internal includes, Sass partial paths, private `--mt-p-*` primitives, HTML details that no rule describes) can change in any release.

## Stable names

| Area | Stable names |
|---|---|
| Settings | every key under `modootoday:` listed in [Configuration](../../guides/configuration/) |
| Design tokens | semantic and component custom properties `--mt-*` (not the primitives `--mt-p-*`); the generated `tokens.json` mirrors them |
| Markdown rules | the patterns in `RULES.md` and their output classes `mt-*`; the opt-out class `mt-flat-list` (no gap between list items below it) |
| Layouts | `default`, `doc`, `post`, `archive`, `twin`, `llms`, `llms-full` |
| Includes you may override | `head-custom.html`, `footer-custom.html`; `modootoday/lang-switch.html` and `modootoday/brand/logo.html` (takes `size`) can be included from your footer; override `modootoday/brand/logo.html` to draw your own logo |
| Includes you provide | `_includes/sections/<name>.html`, rendered at the end of a section or the hero by `visual: <name>` (see [Customize](../../guides/customize/#section-visuals-and-full-width-pages)) |
| Includes you may call | `modootoday/archive.html` with `by` and `lang`; `modootoday/brand/icon.html` with `name` (globe, sun, moon, search, menu, copy, check, external, prev, next, chevron-right, chevron-down, note, tip, important, warning, caution, edit, rss, tag, folder, brand), optional `size` (px, default 18), `label` (makes it `role="img"` with that name; otherwise `aria-hidden`) and `class`. Output: `svg.mt-icon.mt-icon-<name>` in `currentColor`; directional icons add `.mt-icon-flip` (mirrored in RTL) |
| Includes | `modootoday/t.html` (`key=`, optional `n=` / `name=`) prints a theme label for the page language |
| Data files | `_data/i18n/<lang>.yml` keys (optional overrides of the built-in catalogs), `_data/nav/<name>.yml`, `_data/components.yml` |
| Checker | the `modootoday-check` options, exit code 0 (no problems) and 1 (problems or bad usage) |

## Markdown rules

`md-components v1` is the name of the Markdown rules standard in `RULES.md`; it is not a CSS prefix. Output classes use `mt-*`.

## Component structure

This is the markup you can target from your own CSS today. Classes and attributes in this table are part of the public API; elements inside them that the table does not name (wrappers, generated ids, the order of child elements) are not. The [slot contract](#slot-contract) names the Markdown parts each component consumes.

| Component | Root | Parts you may style | State and variants |
|---|---|---|---|
| Page shell | `body.mt-body` | `a.mt-skip`, `header.mt-header` > `.mt-header-inner` (`.mt-site-title`, `nav.mt-nav`, `.mt-search`, `details.mt-lang.mt-menu` (`summary` globe button, `ul` of `a[lang][hreflang]`, current one `aria-current`), `.mt-theme-toggle`), `main.mt-main`, `footer.mt-footer` > `.mt-footer-inner` | `html[data-theme=light\|dark]` (fixed scheme, or set by the toggle) |
| Doc page | `article.mt-doc` | `.mt-doc-layout` > `.mt-doc-main` and `.mt-doc-aside` (holds `nav.mt-toc`), `nav.mt-toc-mobile`, `nav.mt-breadcrumb`, `.mt-page-meta`, `nav.mt-pagination` | — |
| Doc sidebar | `aside.mt-doc-nav` > `nav.mt-sidebar` (from 64rem); `details.mt-sidebar-mobile` (below) | `.mt-sidebar-group`, `.mt-sidebar-title`, the `ul` of links; the current link has `aria-current=page` | `.mt-doc-layout.mt-has-sidebar`; `[open]` on the mobile menu |
| Page actions | `details.mt-menu.mt-page-actions` | `summary`, the `ul` of `button[data-mt-act=copy\|ai]` (hidden until JS runs) and the View as Markdown `a[type="text/markdown"]` | `[open]` |
| Hero | `section.mt-hero` | the `h1`, lead `p.mt-hero-lead` (the first `p` right after the `h1`), link-only `p` (CTA buttons; first link is primary) | `.mt-hero-checks` (front matter `hero: {checks: true}`: the first `ul` is a row of ✓ marks in `--mt-ok`) |
| Section | `section.mt-section` | the `h2` and its content | `[data-section]` = name; `[data-c]` and `.mt-c-<c>` = component; `.mt-cols-<n>`; `.mt-cta` (on the section, or on a `[data-mt-result]` element inside it when one is present) |
| Section decor | `.mt-has-decor` on `section.mt-hero` or `section.mt-section` (front matter `decor: <include>`) | `.mt-section-decor[aria-hidden=true]`, the last child, holding `_includes/sections/<include>.html`; placed in the top end corner, no pointer events | — |
| Scroll reveal | `.mt-reveal` on `section.mt-hero` or `section.mt-section` (front matter `reveal: true`) | — | CSS only: fades in on scroll inside `@supports (animation-timeline: view())` and `prefers-reduced-motion: no-preference`; shown as is otherwise |
| Full-width band | `.mt-bleed` on `section.mt-hero` or `section.mt-section` (front matter `bleed: true`), `.mt-bleed-wide` (`bleed: wide`) | — | `--mt-bleed-bg` sets the band colour; inside a sidebar or table-of-contents layout the band stays in the main column; `bleed` sheet |
| Illustration | `figure.mt-illustration[role=img][aria-label]` (your own include) | `.mt-illustration-tag` badge in the top start corner; its text belongs in the `aria-label` too, because the children of `role=img` are not read | — |
| List styles | `ul.mt-chips`; `li > strong.mt-item-title + span.mt-item-sep` (with `modootoday.lists`) | the `li > a` chips (44px tall, → after the text); the title and the `: ` separator | — |
| Prose (no `sections:`) | `div.mt-prose` | the rendered body | — |
| Card grid | `section.mt-section` | `ul > li`, its leading `strong` is the title | `.mt-cols-2`, `.mt-cols-3`, `.mt-cols-4`, `.mt-badge-bottom` (`c: features`) |
| Tabs | `section.mt-c-tabs[data-tabs]` | `[role=tablist]`, `[role=tab]`, `[role=tabpanel]` (built by JS; without JS the `h3` + code blocks stay) | `[aria-selected]` |
| Accordion | `section.mt-c-accordion` | `h3 > button[aria-expanded]`, the panel after it | `[aria-expanded=true\|false]` |
| Steps / Timeline | `section.mt-c-steps`, `section.mt-c-timeline` | `ol > li` or `h3` items | — |
| File tree | `section.mt-c-filetree` | `ul[aria-label]`, nested `ul` (items holding one are folders) | — |
| Details / FAQ | `section.mt-c-details`, `section.mt-c-faq` | `details.mt-details`, `summary > h3`, the content after it | `[open]` |
| Parameter table | `section.mt-c-params` | `th[scope=col]`, `.mt-param-required` | — |
| Link cards | `section.mt-c-linkcards` | `ul > li > a` (the whole card is the link target) | — |
| Quote | `figure.mt-quote` | `blockquote`, `figcaption` | — |
| Gallery | `section.mt-c-gallery` | `a.mt-gallery-thumb`, `a.mt-lightbox`, `.mt-lightbox-close` | `:target` on the open lightbox |
| Pricing | `.mt-plans` | `.mt-plan`, its `h3`, link-only `p.mt-actions` | `.mt-plan-recommended` with `.mt-plan-flag` |
| Subscribe | `section.mt-c-subscribe` | `form.mt-subscribe` (when an action is set), `label`, `input[type=email]`, `button` | — |
| Split | `section.mt-c-split` (with `.mt-split-start`, `.mt-split-5-7`) | `.mt-section-in` > `.mt-section-body` (the `h2` and text) + `.mt-section-visual` (the `visual:` include) | — |
| Inline extras | `div.mt-code`, `span.mt-progress`, `div.mt-embed` | `.mt-code-title`, `progress`, `iframe` | — |
| Loading (optional sheet) | `.mt-spinner`, `.mt-topbar`, `.mt-skeleton` | `.mt-skeleton-text`, `-card`, `-image`, `-avatar`, `-row`; `.mt-ratio-16x9`, `-4x3`, `-1x1` | `[aria-busy=true]`, `[role=status]` |
| Banner | `div.mt-banner` | its `p` and link; `a.mt-back-to-top` | — |
| Alert | `blockquote.mt-callout[role=note]` | `p.mt-callout-title`, the body | `.mt-callout-<type>`, `[data-variant]` = note, tip, important, warning, caution |
| Badge | `span.mt-badge` | the symbol (`aria-hidden`), the label | `.mt-badge-<status>`, `.mt-badge-tag`, `[data-variant]` |
| Keyboard keys | `kbd.mt-kbd` | `kbd` per key | — |
| Figure | `figure.mt-figure` | `img`, `figcaption` | — |
| Post header | `header.mt-post-header` | `h1.mt-post-title`, `.mt-post-deck`, `.mt-byline` (`.mt-byline-authors` > `.mt-post-author`, `.mt-byline-dates` > `time`), `figure.mt-post-cover`, `nav.mt-series`, `p.mt-post-meta` (tag badges) | `[data-part]` = header, deck, byline, authors, dates, cover, terms |
| Post footer | `article.mt-doc` | `.mt-share` button, `nav.mt-post-nav`, `section.mt-related`, `.mt-news-correction`, `.mt-news-sources` | `[data-part]` = share, post-nav, related, sources |
| Post card | `article.mt-card-post` | `.mt-card-post-cover`, `.mt-card-post-meta`, `.mt-card-post-title`, `.mt-card-post-excerpt` | `.mt-card-post-featured`, `[data-kind=news]`, `.mt-post-list[data-variant=list\|grid\|magazine]` |
| News front | `div.mt-news-top` | `.mt-news-lead`, `.mt-news-secondary`, `section.mt-news-latest`, `section.mt-news-section` | `[data-category]`, `.mt-badge[data-variant=breaking\|live]` |
| Search | `div.mt-search[role=search]` | the input, `.mt-search-results` | — |

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

## Right-to-left and math

- Pages in Arabic, Persian, Hebrew, Urdu and other RTL languages get `dir="rtl"` from `lang`; set `direction: rtl` or `ltr` in front matter (or `direction:` in `_data/i18n/<lang>.yml`) to override. Components use logical properties and mirror; code stays left-to-right.
- The theme bundles no math or diagram renderer; see [Math and diagrams](../../recipes/math-diagrams/).

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
