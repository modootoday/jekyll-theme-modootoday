---
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
  color_scheme: auto  # auto | light | dark
  components: [callout, badge, cta, card, tabs]
  tokens: {primary: "#4f46e5", radius: "0.5rem"}
  nav: main
```

| Key | Default | Effect |
|---|---|---|
| `badges` | `true` | turn status code spans into badges; `false` keeps code |
| `color_scheme` | `auto` | follow the OS or force light or dark |
| `components` | all | limit the CSS and JS that are shipped |
| `css_layers` | `false` | wrap the theme CSS in `@layer mt.*` |
| `nav` | `main` | navigation file in `_data/nav/`; an entry with `items:` becomes a dropdown group on wide screens |
| `tokens`, `tokens_dark` | theme values | override semantic design tokens inline |
| `twins` | stubs | `source` for front-matter-less twins (see [Agents](../agents/)) |
| `seo` | `true` | `false` drops the built-in canonical, hreflang and Open Graph tags |
| `languages` | none | language codes for `hreflang`, such as `[en, ko]` The header site title links to the page language's home (`/<lang>/`) when it exists. |
| `language_switcher` | none | `header` (a globe button with a dropdown menu; same width however many languages) or `footer` (a list of language names) shows a language switcher built from `languages`; each link goes to this page's translation, or that language's home page. Nothing renders with fewer than two languages. The menu opens without JavaScript; `menu.js` adds Esc, arrow keys and closing on an outside click |
| `og_image` | none | default Open Graph image; `image:` in front matter wins |
| `feed` | `false` | `true` links `/feed.xml` (add `jekyll-feed` to `plugins`) |
| `csp` | none | `strict` loads the pre-paint script from a file instead of inline |
| `edit_url` | none | prefix for an "Edit this page" link, ending in `/` |

`modootoday-check` validates every key. The full list of stable names is in [Public API](../api/).

## Head and SEO

With `url:` set, every page gets a canonical link and Open Graph tags; no plugin is needed. With `languages:` set, pages that exist in several languages link each other with `hreflang`. Sitemaps and feeds are opt-in plugins that GitHub Pages allows:

```yaml
url: https://example.github.io
modootoday:
  languages: [en, ko]
  edit_url: https://github.com/OWNER/REPO/edit/main/docs/
plugins: [jekyll-remote-theme, jekyll-sitemap, jekyll-feed]
```

To use `jekyll-seo-tag` instead, set `seo: false` and put the jekyll-seo-tag `seo` tag in `_includes/head-custom.html`. A page can show its date with `last_modified_at:` in front matter. Strict Content Security Policy: see [CSP](../csp/).

## Languages

Put interface strings in `_data/i18n/<lang>.yml` and pages in `<lang>/`:

```yaml
language: 한국어
callout: {note: 참고, tip: 팁, important: 중요, warning: 경고, caution: 주의}
tabs: {label: 설치 방법}
status: {available: 사용 가능, partial: 일부 구현, planned: 계획}
skip: 본문으로 건너뛰기
```

Missing keys fall back to English.

## Component registry

An optional `_data/components.yml` lets the checker validate `sections:` parameters:

```yaml
features: {params: {cols: {allowed: [2, 3], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```

## Next

[Customize the look](../customize/) [Components](../components/)
