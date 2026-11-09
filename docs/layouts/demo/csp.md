---
nav_exclude: true
title: Strict CSP demo
twin: false
sitemap: false
edit: false
description: Core components on one page, checked under a strict Content Security Policy.
sections:
  - alerts
  - {c: tabs, name: tabs}
  - {c: accordion, name: accordion}
  - {c: steps, name: steps}
  - {c: faq, name: faq}
  - figure
  - tables
  - code
  - inline
---
# Strict CSP demo

This page holds the core components, code, tables and a figure. The docs QA serves it with a strict `Content-Security-Policy` header and fails on any violation; see [Content Security Policy](../../../recipes/csp/).

- Plain Markdown
- No inline script or style

[Read the CSP recipe](../../../recipes/csp/) [Performance](../../../guides/performance/)

## Alerts

> [!NOTE]
> Alerts are blockquotes with a class; nothing inline.

> [!WARNING]
> An alert can hold `inline code` and a link to the [layout demos](../).

## Tabs

### npm

```sh
npm install
```

### gem

```sh
gem install jekyll-theme-modootoday
```

## Accordion

### Does the accordion need inline script?

No. `accordion.js` is a file under `assets/js/`.

### Does the copy button work here?

Yes. `code-copy.js` loads because the page has a code block.

## Steps

1. Build the site.
2. Serve it with the policy.
3. Count the violations.

## FAQ

### Which policy?

`default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:`, plus `worker-src` and `manifest-src`.

## Figure

![A Markdown source on the left becomes a styled page on the right](../../../assets/images/sample.svg)

*An SVG figure scrolls inside a focusable region without inline styles.*

## Tables

| Item | Loaded from | Inline |
|---|---|---|
| Theme CSS | `assets/css/` | no |
| Theme scripts | `assets/js/` | no |
| Pre-paint script | `theme-init.js` with `csp: strict` | no |

## Code

`file:_config.yml`

```yaml
modootoday:
  csp: strict
```

## Inline

Badges `status:available` `tag:beta`, keys `kbd:Ctrl+K`, progress `progress:60` and a spinner `loading:spinner`.
