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
| `home` | A landing page: hero from front matter, then the body, then the latest posts when there is no hero. Without a hero title or a `# ` heading in the body, the page title, else the site title, is the `h1`. Adds WebSite structured data. | [Home](https://modootoday.github.io/jekyll-theme-modootoday-landing-starter/ "new-window") |
| `page` | The name Jekyll, minima and `jekyll new` use for a plain page. It is the `doc` layout under that name. Like every `doc` page, it prints `title:` as the `h1` when the body has no `# ` heading, as minima does. | none |
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

The first action is the primary button. Without `hero.title` the layout shows only the body. `home` renders the body as written and does not read `sections:`, so cards, tabs and buttons sections do not apply. For a rich home page with those, use `layout: doc` with `hero:` and `sections:`, as this site's home page does. An optional `hero.image` (a path, or `{path, alt, width, height, srcset}`) shows a wide picture under the actions; leave `alt` empty when it is decorative. The `showcase` hero visual reads the same `hero.image` key (see [Customize](../../guides/customize/)).

A home page without `hero:` and `sections:` lists the latest posts under its body when the site has posts, as minima does, so the `index.md` of `jekyll new` keeps its list. `posts: true` adds the list to any home page and `posts: false` removes it; `list_title:` replaces the heading, and `show_excerpts:` (on the page, then in `_config.yml`) shows or hides the excerpts, which otherwise follow `modootoday.blog.excerpt`. With jekyll-paginate on an `index.html` the list pages with it; otherwise it shows `modootoday.blog.per_page` posts and links the archive.

## Error

```yaml
---
layout: error
status: 404
permalink: /404.html
sitemap: false
---
```

`status` is `404` (default), `410` or `500`. An error page has no Markdown twin: the plugin and `modootoday-stubs` skip it, and `modootoday-check --twins` does not ask for one. The title and text come from the theme's catalogs in 23 languages; set `heading:` to replace the title. The page always ends with a button to the home page; to add quick links, write them as one paragraph of links separated by spaces, which becomes a row of chips:

```markdown
[Components](/components/) [Search](/search/) [한국어](/ko/)
```

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

The form limits the engine to the host of `url:`. A site without `url:` (`jekyll new` writes `url: ""`) has no host to limit it to, so the layout leaves the form out rather than search the whole web; set `url:` to your site's address to get it. The page prints its `title:` as the heading when the body has no `# ` heading, and the form is a search landmark named by its label, apart from the header search box.
