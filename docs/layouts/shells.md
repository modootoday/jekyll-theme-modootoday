---
title: Page shells
description: Page shells for every kind of page, each with its own optional stylesheet.
nav_order: 10
---
# Page shells

Set `layout:` in a page's front matter. The page shells below load an extra stylesheet, `modootoday-pages.css`, only on the pages that use them, so other pages stay as light as before. None of them adds JavaScript.

| Layout | Use it for | Demo |
|---|---|---|
| `minimal` | Standalone notices, sign-in notes, link pages. No header, page meta or pagination. | [Minimal](/jekyll-theme-modootoday/layouts/demo/minimal/) |
| `wide` | Card grids, wide tables and galleries. Full header and footer, no reading-width cap. | [Wide](/jekyll-theme-modootoday/layouts/demo/wide/) |
| `home` | A landing page: hero from front matter, then the body. Adds WebSite structured data. | [Home](/jekyll-theme-modootoday/layouts/demo/home/) |
| `error` | 404, 410 and 500 pages with localized title and text. | [Error](/jekyll-theme-modootoday/layouts/demo/error/) |
| `redirect` | A moved page. Sends visitors on without script, so it works under a strict CSP. | [Redirect](/jekyll-theme-modootoday/layouts/demo/redirect/) |
| `search` | A full search page with a form that also works without JavaScript. | [Search](/jekyll-theme-modootoday/layouts/demo/search/) |

Card lists for projects, people, jobs, events, sponsors and integrations are on [Directory layouts](/jekyll-theme-modootoday/layouts/directory/).

## Home

```yaml
---
layout: home
hero:
  title: Build a site from Markdown
  text: One sentence about the site.
  actions:
    - {label: Get started, url: /install/}
    - {label: GitHub, url: "https://github.com/modootoday/jekyll-theme-modootoday"}
---
```

The first action is the primary button. Without `hero.title` the layout shows only the body. An optional `hero.image` (a path, or `{path, alt, width, height, srcset}`) shows a wide picture under the actions; leave `alt` empty when it is decorative. The `showcase` hero visual reads the same `hero.image` key (see [Customize](../../guides/customize/)).

## Error

```yaml
---
layout: error
status: 404
permalink: /404.html
sitemap: false
---
```

`status` is `404` (default), `410` or `500`. The title and text come from the theme's catalogs in 23 languages; set `heading:` to replace the title, and write a body to add your own links.

## Redirect

```yaml
---
layout: redirect
permalink: /old-page/
redirect_to: /new-page/
---
```

`redirect_to` takes a site path or a full URL. The page is marked `noindex` and points search engines to the new address.

## Search

The header search box gives instant results. Below the page body, the `search` layout adds a form that searches this site through an external engine when JavaScript is off. Change it in `_config.yml`:

```yaml
modootoday:
  search:
    fallback: {url: "https://duckduckgo.com/", param: q}   # or false to hide the form
```
