---
title: Blog layout
description: "Posts as a list, a grid or a magazine, with pagination or a link to the archive."
layout: layout-reference
nav_order: 1
---
# Blog layout

`layout: blog` prints your text, then the site's posts as cards: a plain `list`, a `grid`, or a `magazine` whose first post leads. It can show one category or tag, and with `jekyll-paginate` it adds newer and older links. The live demo is the home page of the blog starter. This site's own [blog](../../../blog/) uses the layout too.

## Front matter

| Key | Use |
|---|---|
| `variant` | `list` (default), `grid` or `magazine` |
| `featured` | `true` makes the first card lead |
| `category`, `tag` | Show only the posts with this category or tag |
| `archive_url` | Where the older-posts link after the last card goes, such as `/archive/` |
| `posts_lang` | `all` mixes languages; by default only posts in the page's language are listed |

```yaml
---
title: Blog
layout: blog
variant: grid
---
```

Without pagination the page shows the newest `modootoday.blog.per_page` posts (10 by default, set in `_config.yml`).

[Blog and news](../) covers posts, authors and feeds.
