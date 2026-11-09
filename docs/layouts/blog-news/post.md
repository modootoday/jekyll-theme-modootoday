---
title: Post layout
description: "One post with a byline, reading time, a cover, series links, tags, share links and related posts."
layout: layout-reference
nav_order: 2
---
# Post layout

`layout: post` is what a file in `_posts` gets by default. Above the text it prints the title, a deck, the byline with the authors, the dates and the reading time, and the cover image; below it, the series, tags and categories, share links, the previous and next posts and related posts. The page carries `BlogPosting` structured data and `article:*` Open Graph tags. The live demo is a post of the blog starter.

## Front matter

| Key | Use |
|---|---|
| `author` or `authors` | Ids from `_data/authors.yml`, a name, or `{name, url, picture}` |
| `image` | The cover: a path, or `{path, alt, width, height}` |
| `image_alt`, `image_caption` | The cover's text alternative and caption |
| `deck` | A sentence under the title |
| `series` | Posts with the same series get "Part 2 of 3" and links to each other |
| `categories`, `tags` | Listed under the post and used to pick related posts |
| `last_modified_at` | The date of the last update |

```yaml
---
title: Shipping 1.0
author: kim
image: {path: /assets/cover.webp, alt: The release dashboard, width: 1024, height: 576}
series: launch
tags: [release]
---
```

[Blog and news](../) covers author data and feeds.
