---
title: Blog and news
nav_order: 50
description: Blog indexes, news front pages, article bylines, author pages and Atom feeds.
---
# Blog and news

Five layouts turn the theme into a blog or a newsroom. They are Liquid only, so they build on classic GitHub Pages and on Jekyll 4. They load `modootoday-blog.css` and `share.js` on their own pages only. Docs pages do not download either file.

| Layout | Use it for |
| --- | --- |
| `blog` | A list of posts, with pagination, in `list`, `grid` or `magazine` style |
| `post` | One post: byline, reading time, cover, series, previous and next, related posts |
| `news` | A front page: lead story, secondary stories, the latest list, one section per category |
| `news-article` | A post with a deck, breaking or live badge, corrections and sources |
| `author` | One author's bio and posts |
| `feed` | An Atom feed for one language |

## Demos

Each demo below is a real page built with one layout, outside the docs. Open it here or in a new window. Links inside the demos that would leave the sample point to `#`.

| Demo | Layout | New window |
| --- | --- | --- |
| [Blog index](blog/) | `blog` | [Open in new window](blog/ "new-window") |
| [Blog post](post/) | `post` | [Open in new window](post/ "new-window") |
| [News front page](news/) | `news` | [Open in new window](news/ "new-window") |
| [News article](article/) | `news-article` | [Open in new window](article/ "new-window") |
| [Yearly archive](archive/) | `archive` | [Open in new window](archive/ "new-window") |

The Atom feed for English posts is at [feed.xml](../../feed.xml); [Korean](../../ko/feed.xml) and [Japanese](../../ja/feed.xml) have their own.

## Blog index

```markdown
---
title: Blog
layout: blog
variant: grid      # list | grid | magazine
category: guides   # optional filter; tag: works too
---
```

See it rendered on the [sample blog](../../blog/), which lists the posts on this site.


With `jekyll-paginate` on and `paginate:` set, the root `index.html` blog page shows pager links. Otherwise the page shows `per_page` posts and a link to `archive_url`.

## Posts

```markdown
---
title: Shipping 1.0
author: kim            # or authors: [kim, lee], ids from _data/authors.yml
image: /assets/cover.png
image_alt: The release dashboard
series: launch         # posts with the same series get "Part 2 of 3" and links
last_modified_at: 2026-10-30
---
```

Author data lives in `_data/authors.yml`:

```yaml
kim: {name: Kim, url: "https://example.com", page: /authors/kim/, bio: Writes the docs.}
```

Each post emits `BlogPosting` JSON-LD and `article:*` Open Graph tags. Related posts are scored by shared tags and categories.

## News

```markdown
---
title: News
layout: news
news_sections: [releases, guides]
---
```

An article uses `layout: news-article` and adds `deck:`, `breaking: true` or `live: true`, `correction:`, `sources: [...]` and `credits:`. It emits `NewsArticle` JSON-LD. See the [sample front page](../../news/) and the [sample article](../../releases/2026/10/29/blog-news-layouts/).

## Authors and feeds

```markdown
---
layout: author
author: kim
---
```

Add a `feed.xml` page with `layout: feed` in each language folder (`/ko/feed.xml`) to get one Atom feed per language. The head links to it. Set `feed_content: full` for full text.

## Settings

```yaml
modootoday:
  blog:
    variant: list       # default list style
    per_page: 10
    excerpt: true
    reading_time: true
    related: 3          # 0 hides related posts
    share: true         # copy-link button
  news:
    sections: [releases]  # default news_sections
```

| Front matter | Layouts | Meaning |
| --- | --- | --- |
| `variant` | blog, author | `list`, `grid` or `magazine` |
| `category`, `tag` | blog, news, feed | Filter posts |
| `news_sections`, `secondary`, `latest` | news | Category sections and story counts |
| `posts_lang` | blog, news, author | `all` lists every language |
| `featured` | post | Pins the post as the lead card |
| `hidden`, `list: false` | post | Leaves the post out of lists |
| `author`, `authors` | post, author | Ids from `_data/authors.yml` |
| `series` | post | Groups posts into numbered parts |
| `deck`, `breaking`, `live`, `correction`, `sources`, `credits` | news-article | News details |
| `feed_lang`, `limit`, `feed_content` | feed | Feed scope |
