---
title: Performance
nav_order: 75
description: What each page loads, versioned asset URLs for long CDN caching, and the size budgets CI keeps.
---
# Performance

The theme sends a page only the CSS and JavaScript it uses, and gives every theme file a versioned URL so a CDN in front of your site can cache it for a long time.

## What a page loads

| Asset | Loaded on |
|---|---|
| `assets/css/modootoday.css` (core sheet) | every page |
| Context sheets (`doc`, `search`, `loading`, `figure`, `lists`, `bleed`, `terminal`, `visual`, `filter`, `table`, `table-stack`) | pages whose layout or body uses them |
| Section sheets (`tabs`, `faq`, `pricing`, …) | pages whose `sections:` use that component |
| `menu.js`, `theme-toggle.js`, `search.js` | pages with the header, the toggle, or a search index |
| `code-copy.js` | pages with a code block, and pages with the page actions menu |
| `scroll-region.js` | pages with a code block or a table |
| `tabs.js`, `accordion.js`, `share.js` | pages that use tabs, an accordion, or a blog layout |
| `filter/filter.js` (an ES module, with `chips.js`, `text/normalize.js` and `dom/config.js`) | pages with `filter:` or `filter_text:` |
| Mermaid and KaTeX | pages with a diagram or math block, when you turn them on |
| Your `site_css` sheets and `preload` hints | every page, plus the pages whose front matter lists more |
| Your `scripts` modules (with their sheet and the theme helpers they import) | pages whose hero or a section names one with `script:` |

Scripts load with `defer` and do not block the first paint; the one exception is the small pre-paint theme script that `csp: strict` loads from a file. `modootoday.css: bundle` folds every sheet into the core sheet instead; see [Configuration](../configuration/).

## Versioned asset URLs

Every theme stylesheet and script URL ends in `?v=` and the theme version, such as `modootoday.css?v=X.Y.Z`. GitHub Pages ignores the query and serves the same file; a CDN keys its cache on it, so a new theme release reaches visitors at once even when the files are cached for a year.

| `modootoday.asset_version` | Query | Use when |
|---|---|---|
| `theme` (default) | `?v=X.Y.Z` | the theme files change only with the theme version |
| `build` | `?v=X.Y.Z-a1b2c3d` | you also override theme files (Sass partials, scripts) in your site; the commit comes from `site.github.build_revision` on GitHub Pages, and the build time elsewhere |
| `false` | none | you version or fingerprint assets yourself |

The theme's own CSS and JavaScript get the query, and so do the sheets you list in `site_css`. Your other stylesheets, images and fonts keep their URLs, and so do `preload` hints: a hint has to match the URL the page or stylesheet requests, or the browser downloads the file twice.

## Long caching on a CDN

GitHub Pages sends `Cache-Control: max-age=600`. With a CDN in front, cache theme files longer. For example, a Cloudflare cache rule:

| Setting | Value |
|---|---|
| When | URI path starts with `/assets/css/modootoday` or `/assets/js/modootoday`, and the query string contains `v=` |
| Edge TTL | 1 year, ignoring the origin's cache headers |
| Browser TTL | 1 year |
| Cache key | include the query string (the default) |

Keep the HTML on a short TTL, so visitors pick up the new `?v=` soon after you deploy.

## Size budgets

The theme's CI fails a change that makes pages heavier than its budgets:

- each stylesheet, the core CSS one page links, and all core scripts together (gzip);
- the gzip bytes of the CSS and JavaScript one page of each type loads (docs page, landing page, blog page, component showcase, page with a module script visual, page with a list filter, record page), modules they import included;
- a [strict Content Security Policy](../../recipes/csp/) on sample pages, with zero violations ([demo](../../layouts/demo/csp/)).
