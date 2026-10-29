---
id: adr:modootoday/20261029231927
title: "Blog and news layouts: Liquid-only, separate optional bundle"
status: active
created: 2026-10-29T23:19:27Z
updated: 2026-10-29T23:19:27Z
rel:
  governs: [_layouts/blog.html, _layouts/news.html, _layouts/news-article.html, _layouts/author.html, _layouts/feed.html, _layouts/post.html, _includes/modootoday/blog, _includes/modootoday/meta, _includes/modootoday/news, _sass/modootoday/blog, _layouts/archive.html, assets/css/modootoday-blog.scss, assets/js/modootoday/share.js, qa/audit/budgets.mjs]
---

# Blog and news layouts: Liquid-only, separate optional bundle

## Context

The theme served documentation only. Users also run blogs and newsrooms on it and asked for those layouts, with reach and extensibility first. They must build on classic GitHub Pages (Jekyll 3.10, no custom plugins) and on Jekyll 4, and work in all 23 languages and in RTL. Size budgets are nearly used up: the main JS was 10,229 of 10,240 B and core CSS 31,889 of 32,768 B compressed. Docs pages must not pay for blog features.

## Decision

Five layouts (blog, news, news-article, author, feed) and an upgraded post layout are Liquid only. Small includes do the work: blog/select, card, list, pager and reading-time; meta/byline, series, post-nav, related, share and jsonld; news/front, badge and notes. Each include can be shadowed. Card variants are list, grid and magazine. Authors live in _data/authors.yml. Settings live under modootoday.blog and modootoday.news, and front matter overrides them. The news front page reads news_sections, because the docs layout already uses sections. Feeds are Atom, one page per language. jekyll-paginate is used when it is on; otherwise a page shows per_page posts and links to an archive.

Styles ship as a separate bundle, assets/css/modootoday-blog.css (from _sass/modootoday/blog), and the copy-link script ships as standalone assets/js/modootoday/share.js. default.html links them only for the post, blog, news, news-article, author and archive layouts, or when a page sets blog_css: true. The core bundles do not change. qa/audit/budgets.mjs counts the core and blog bundles apart: core css 32 KiB, core js 10 KiB, blog-css 8 KiB and blog-js 1 KiB, raw bytes as built compressed. test/blog checks the same limits. At integration of the 1.0 branches (first-paint, accessibility, blog) the core CSS reached 33,144 B with the docs-site docs.css, so the post meta and archive styles (formerly the `post` entry of modootoday.components) moved from the core into this bundle and the archive layout now loads it. Budgets after the move: core css 32,768 B, core js 10,240 B, blog-css 8,192 B, blog-js 1,024 B; none was raised.

## Consequences

Docs pages download nothing extra. Blog pages make one extra CSS request and one deferred script request. Front-page sections and related posts loop over site.posts, which costs posts x sections at build time but is fine for hundreds of posts. Search engines get BlogPosting or NewsArticle JSON-LD and article Open Graph tags. Byline, card and front-page markup, their data-part names, the blog.* i18n keys and the front matter keys are public API. Each bundle must fit its own budget, so growth in one cannot hide in the other.

## Note: component registry

`_data/components.yml` registers section components selected with `c:` and its `parts:` are tied to kitchen-sink sections. The blog and news parts are layout-level, not sections, so they are not registered there. Their stable selectors and `[data-part]` names are listed in the Component structure table of `api.md` (Post header, Post footer, Post card, News front), and `modootoday-check` (`check/blog.rb`) validates the settings and front matter instead.
