---
id: adr:modootoday/20261104061804
title: "A plain jekyll new site builds unchanged: page is the doc layout and home lists the posts without a hero"
status: active
created: 2026-11-04T06:18:04Z
updated: 2026-11-04T06:19:08Z
rel:
  governs: [_layouts/page.html, _layouts/home.html, _includes/modootoday/blog/home-list.html]
---

# A plain jekyll new site builds unchanged: page is the doc layout and home lists the posts without a hero

## Context

The site `jekyll new` writes (minima) uses `layout: page` for `about.markdown` and the 404 page, and `layout: home` for an `index.markdown` with no body: minima's home draws the post list. The theme had no `page` layout, so Jekyll warned and wrote those pages bare, and on GitHub Pages jekyll-default-layout fell back from `page` to `default`, which skips the doc pipeline for front-matter-less pages. The theme's `home` drew only a hero and the body, so the switched site lost its post list.

## Decision

- `_layouts/page.html` is a new root layout whose only content is `layout: doc`. It is public API under the name Jekyll, minima and jekyll-default-layout look for. No other theme's layout names are added (see the checker ADR of the same change).
- `home` includes `blog/home-list.html` after the body. The judgement lives in `blog/home-posts.html` (sets `mt_home_posts`), which `stylesheets.html` also reads to link the blog sheet on such a page. The list shows when front matter `posts: true`, or when `posts` is unset, the page has neither `hero:` nor `sections:` and `site.posts` is not empty; `posts: false` hides it. Existing hero home pages and `sections:` pages therefore do not change.
- The list reuses `blog/select.html`, `blog/list.html` and `blog/pager.html`: jekyll-paginate's paginator on `index.html`, else `modootoday.blog.per_page` posts and an archive link. The heading is `list_title` (minima's key), else the `blog.latest` string; excerpts follow `show_excerpts` on the page, then on the site, else `modootoday.blog.excerpt`. Cards use `h3` under the list's `h2`.
- `modootoday-check` validates `posts` (true or false) and `list_title` (text) on `home` pages.
- `jekyll new` writes `url: ""`, and an empty string is truthy in Liquid. Every test for a set `site.url` (JSON-LD, canonical and Open Graph, `hreflang`, the own-site link test, `llms.txt` links) also requires it to be non-empty; the `default:` uses already treat it as unset.

## Consequences

A home page without hero or sections in a site with posts now shows them; that is a visible change shipped in a minor release with a CHANGELOG entry. Such a page loads the blog sheet (a fixed bundle with its own budget, not a registry row), as the blog layouts do; home pages without the list load nothing new.
