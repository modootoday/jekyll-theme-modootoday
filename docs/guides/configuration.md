---
nav_order: 30
title: Configuration
description: Site-wide settings under the modootoday key in _config.yml.
sections:
  - keys
  - head
  - i18n
  - registry
  - {c: cta, name: next}
---
# Configuration

Everything is optional. Settings live under one `modootoday:` key so they never clash with other plugins.

## Keys

```yaml
modootoday:
  color_scheme: auto  # auto | auto-dark | auto-light | light | dark
  components: [callout, badge, cta, card, tabs]
  tokens: {primary: "#4f46e5", radius: "0.5rem"}
  nav: main
```

| Key | Default | Effect |
|---|---|---|
| `badges` | `true` | turn status code spans into badges; `false` keeps code |
| `color_scheme` | `auto` | `auto` follows the OS; `auto-dark` or `auto-light` starts dark or light and keeps the toggle (the reader's choice is remembered); `light` or `dark` forces one scheme without a toggle. The starting scheme is printed in the HTML, so nothing flashes |
| `components` | all | limit the CSS and JS that are shipped |
| `css_layers` | `false` | wrap the theme CSS in `@layer mt.*` |
| `nav` | `main` | navigation file in `_data/nav/`; an entry with `items:` becomes a group. Previous/next links walk the file in order: a group's own page, then its items |
| `sidebar` | `auto` | `auto` adds a sidebar to `doc` pages when the nav has groups; `true` always, `false` never. Below 64rem it folds into a menu above the page. `sidebar: false` in front matter hides it on one page |
| `page_actions` | `true` | on pages with a Markdown twin, a menu with View as Markdown, Copy page and Copy for AI (copies the source URL, then the Markdown). `false` here or in front matter turns it off; leave `page-actions` out of `components` to drop it entirely |
| `tokens`, `tokens_dark` | theme values | override semantic design tokens inline |
| `twins` | stubs | `source` for front-matter-less twins (see [Agents](../agents/)) |
| `seo` | `true` | `false` drops the built-in canonical, hreflang and Open Graph tags |
| `hreflang` | follows `seo` | `true` keeps the `hreflang` alternates when `seo: false` (for sites that bring `jekyll-seo-tag`) |
| `schema` | on when `url` is set | schema.org JSON-LD graph: `publisher`, `search_url`, `layouts`; `false` turns it off. See [Structured data](../structured-data/) |
| `languages` | none | language codes for `hreflang`, such as `[en, ko]` The header site title links to the page language's home (`/<lang>/`) when it exists. |
| `language_switcher` | none | `header` (a globe button with a dropdown menu; same width however many languages) or `footer` (a list of language names) shows a language switcher built from `languages`; each link goes to this page's translation, or that language's home page. Nothing renders with fewer than two languages. The menu opens without JavaScript; `menu.js` adds Esc, arrow keys and closing on an outside click |
| `og_image` | none | default Open Graph image; `image:` in front matter wins |
| `feed` | `false` | `true` links `/feed.xml` (add `jekyll-feed` to `plugins`) |
| `logo` | none | `brand` puts the modootoday mark before the site title in `currentColor` (the `brand` token, so it follows light and dark); a path shows your own image instead (decorative, `alt=""`). Override `modootoday/brand/logo.html` to draw something else |
| `favicon` | none | `brand` links the modootoday mark as SVG, 32 px PNG and Apple touch icon; a path links your own icon |
| `csp` | none | `strict` loads the pre-paint script from a file instead of inline |
| `viewport_fit` | `cover` | `auto` keeps the page inside the safe area instead of drawing under the notch (see [Accessibility](../accessibility/#settings)) |
| `theme_color` | page background | browser bar colour: one `"#hex"`, `{light: "#hex", dark: "#hex"}`, or `false` to drop the tags |
| `edit_url` | none | prefix for an "Edit this page" link, ending in `/` |
| `archive` | none | archive page URLs, such as `{tags: /tags/, categories: /categories/}`; post footers link here (see [Posts and archives](../../reference/api/#posts-and-archives)) |
| `blog` | none | blog settings (`per_page`, `variant`, `related`, `share`, `reading_time`, ...); see [Blog and news](../../layouts/blog-news/#settings) |
| `news` | none | news settings, such as `sections:` for the front page; see [Blog and news](../../layouts/blog-news/#settings) |

`modootoday-check` validates every key. The full list of stable names is in [Public API](../../reference/api/).

## Head and SEO

With `url:` set, every page gets a canonical link and Open Graph tags; no plugin is needed. With `languages:` set, pages that exist in several languages link each other with `hreflang`. Sitemaps and feeds are opt-in plugins that GitHub Pages allows:

```yaml
url: https://example.github.io
modootoday:
  languages: [en, ko]
  edit_url: https://github.com/OWNER/REPO/edit/main/docs/
plugins: [jekyll-remote-theme, jekyll-sitemap, jekyll-feed]
```

To use `jekyll-seo-tag` instead, set `seo: false` and put the jekyll-seo-tag `seo` tag in `_includes/head-custom.html`. A page can show its date with `last_modified_at:` in front matter. The first breadcrumb shows the home page `short_title:` (front matter) when set, otherwise its `title`. Strict Content Security Policy: see [CSP](../../recipes/csp/).

## Languages

Put interface strings in `_data/i18n/<lang>.yml` and pages in `<lang>/`:

```yaml
language: 한국어
callout: {note: 참고, tip: 팁, important: 중요, warning: 경고, caution: 주의}
tabs: {label: 설치 방법}
status: {available: 사용 가능, partial: 일부 구현, planned: 계획}
skip: 본문으로 건너뛰기
```

Set `lang:` and the theme's own labels (skip link, navigation, callouts, status badges, table of contents, pagination, code copy, search, language menu) are already localized for 23 languages: en, zh-CN, zh-TW, ja, ko, tr, ru, vi, th, de, es, fr, uk, pl, pt-BR, ar, fa, id, it, el, ml, ur-Latn, ro. Nothing needs to be copied, on GitHub Pages or with Jekyll 4. A code with a region the theme does not ship uses its base language (`pt` → pt-BR, `zh` → zh-CN); any other language shows English.

Each label is resolved in this order:

1. your `_data/i18n/<lang>.yml`, key by key
2. the theme's catalog for that language
3. English

So a site catalog only needs the keys you want to change, plus anything your own components read. Use the `.yml` extension; the checker rejects `.yaml`. To start from the theme's wording, copy a catalog and check it:

```sh
modootoday-check . _site --i18n-init=ko   # optional: copy the theme's ko.yml to edit
modootoday-check . _site --i18n           # unknown keys and placeholder mismatches
```

For a language the theme does not ship, add `_data/i18n/<code>.yml` with the keys of the English catalog and list the code in `languages`. Pages get `dir="rtl"` for Arabic, Persian, Hebrew, Urdu and other right-to-left languages (`ur-Latn` stays left-to-right); `direction: rtl` or `ltr` in a catalog or in front matter overrides it. Page content is translated as Markdown in `<lang>/`, not in the catalogs.

Some labels are your site's, not the theme's: `tabs.label` names the tab list on pages that use tabs (for example `tabs: {label: Install method}`), so screen readers announce what the tabs choose between. Put it in each language's catalog.

In your own includes, `modootoday/t.html` with `key="nav.label"` prints a label with the same resolution.

## Component registry

An optional `_data/components.yml` lets the checker validate `sections:` parameters:

```yaml
features: {params: {cols: {allowed: [2, 3], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```

## Next

[Customize the look](../customize/) [Components](../../components/)
