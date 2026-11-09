---
nav_order: 75
title: Performance
description: What each page loads, versioned asset URLs for long CDN caching, and the size budgets CI keeps.
---
# Performance

The theme sends a page only the CSS and JavaScript it uses, and gives every theme file a versioned URL so a CDN in front of your site can cache it for a long time.

## What a page loads

| Asset | Loaded on |
|---|---|
| `assets/css/modootoday.css` (core sheet: tokens, base elements, header, nav, theme toggle) | every page |
| Component sheets (`content/code`, `chrome/doc-nav`, `content/inline`, `marketing/hero`, `content/extras`, `media/figure`, `chrome/banner`, `chrome/footer`), linked right after the core sheet | pages whose body or page footer uses them |
| Context sheets (`docs/doc`, `chrome/search`, `content/loading`, `content/lists`, `structure/bleed`, `chrome/terminal`, `media/visual`, `data/filter`, `data/table`, `data/table-stack`) | pages whose layout or body uses them |
| Section sheets (`tabs`, `faq`, `pricing`, …) | pages whose `sections:` use that component |
| `chrome/menu.js`, `chrome/theme-toggle.js`, `chrome/search-keys.js` | pages with the header, the toggle, or a search index |
| `chrome/search.js` (with `text/normalize.js`) and `search.json` | the first time a reader focuses the search box or presses `/` or Ctrl+K |
| `content/code-copy.js` | pages with a code block, and pages with the page actions menu |
| `content/scroll-region.js` | pages with a code block or a table |
| `data/table-stack.js` | pages with a body table |
| `structure/tabs.js`, `structure/accordion.js`, `blog/share.js` | pages that use tabs, an accordion, or a blog layout |
| `data/filter.js` (with `data/filter-chips.js`, `text/normalize.js` and `dom/config.js`, preloaded) | pages with `filter:` or `filter_text:` |
| `data/chart.js` (with `data/chart-table.js` and `theme/current.js`, preloaded), after your Chart.js | pages with a chart, when `modootoday.chart` names your Chart.js (`src`) |
| Mermaid and KaTeX | pages with a diagram or math block, when you turn them on |
| Your `site_css` sheets and `preload` hints | every page, plus the pages whose front matter lists more |
| Your `scripts` modules (with their sheet and the theme helpers they import) | pages whose hero or a section names one with `script:` |

`data/table-stack.js` stacks `c: params` tables, tables with the `mt-table--stack` or `mt-table--dl` class, and, below 40rem, any table that does not fit.

`chrome/footer` loads when `_data/nav/footer.yml` (or the page language's `footer-<lang>.yml`) has columns.

Theme scripts are ES modules (`<script type="module">`): like `defer`, they run after the page is parsed, in order, and do not block the first paint. A module's imports get a `<link rel="modulepreload">`, so they download with it instead of one after another. The one classic script is the small pre-paint theme script that `csp: strict` loads from a file (`chrome/theme-init.js`), because it must run before the first paint. `modootoday.css: bundle` folds every sheet into the core sheet instead; see [Configuration](../configuration/).

## Versioned asset URLs

Every theme stylesheet and script URL ends in `?v=` and the theme version, such as `modootoday.css?v=X.Y.Z`. GitHub Pages ignores the query and serves the same file; a CDN keys its cache on it, so a new theme release reaches visitors at once even when the files are cached for a year.

| `modootoday.asset_version` | Query | Use when |
|---|---|---|
| `theme` (default) | `?v=X.Y.Z` | the theme files change only with the theme version |
| `build` | `?v=X.Y.Z-a1b2c3d` | you also override theme files (Sass partials, scripts) in your site |
| `false` | none | you version or fingerprint assets yourself |

With `build`, the commit comes from `site.github.build_revision` on GitHub Pages, and the build time is used elsewhere.

The theme's own CSS and JavaScript get the query, and so do the sheets you list in `site_css` and the `src` and `css` files of your `modootoday.scripts` entries (hero modules and widgets). With `theme`, editing one of your own files does not change its URL, so use `build` when your files change between theme releases. Your other stylesheets, images and fonts keep their URLs, and so do `preload` hints: a hint has to match the URL the page or stylesheet requests, or the browser downloads the file twice.

## Long caching on a CDN

GitHub Pages sends `Cache-Control: max-age=600`. With a CDN in front, cache theme files longer. For example, a Cloudflare cache rule:

| Setting | Value |
|---|---|
| When | URI path starts with `/assets/css/modootoday` or `/assets/js/modootoday`, and the query string contains `v=` |
| Edge TTL | 1 year, ignoring the origin's cache headers |
| Browser TTL | 1 year |
| Cache key | include the query string (the default) |

Keep the HTML on a short TTL, so visitors pick up the new `?v=` soon after you deploy.

Only the files a page links carry `?v=`. The modules they import (such as `text/normalize.js`) and their `modulepreload` hints do not, so their URLs match, and this rule leaves them on the origin's ten minutes. For those minutes after a deploy, a new module can meet an older cached import; within a minor release the theme keeps the names its shared modules export, so the pair still works.

## Size budgets

The theme's CI fails a change that makes pages heavier than its budgets:

- every theme stylesheet and script against its own cap, in gzip bytes: the measured size plus 10%, written on the file's row in the theme's asset table, so a feature that grows changes only its own cap;
- the CSS and JavaScript one page of each type loads (docs page, landing page, blog page, components page, page with a module script visual, page with a list filter, record page, chart page), modules they import included: the theme's part against the sum of the caps of those files. Targets of 8 KiB CSS, 6 KiB JavaScript and six theme stylesheets per page are reported as warnings (the components pages load every component on purpose and the chart page carries Chart.js, about 70 KB gzip, so both are left out);
- a [strict Content Security Policy](../../recipes/csp/) on sample pages, with zero violations ([demo](../../layouts/demo/csp/)).
