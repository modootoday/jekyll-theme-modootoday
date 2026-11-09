---
lang: ko
permalink: /ko/layouts/blog-news/blog/
source_rev: sha256:4d561d466966
title: 블로그 레이아웃
description: "글을 목록, 격자, 매거진으로 보여 주고 페이지 나누기나 보관함 링크를 다는 레이아웃입니다."
layout: layout-reference
nav_order: 1
twin: true
---
# 블로그 레이아웃

`layout: blog`는 본문 다음에 사이트의 글을 카드로 보여 줍니다. 단순한 `list`, `grid`, 첫 글을 크게 보여 주는 `magazine` 중에서 고릅니다. 분류나 태그 하나만 보여 줄 수 있고, `jekyll-paginate`를 쓰면 새 글과 이전 글 링크가 붙습니다. 라이브 데모는 blog 스타터의 홈입니다. 이 사이트의 [블로그](../../../blog/)도 이 레이아웃을 씁니다.

## Front matter

| 키 | 용도 |
|---|---|
| `variant` | `list`(기본), `grid`, `magazine` |
| `featured` | `true`면 첫 카드를 크게 보여 줍니다 |
| `category`, `tag` | 이 분류나 태그가 붙은 글만 보여 줍니다 |
| `archive_url` | 마지막 카드 다음의 이전 글 링크가 가는 곳(예: `/archive/`) |
| `posts_lang` | `all`이면 모든 언어의 글을 섞고, 기본은 페이지 언어의 글만 보여 줍니다 |

```yaml
---
title: Blog
layout: blog
variant: grid
---
```

페이지 나누기를 쓰지 않으면 최신 글을 `modootoday.blog.per_page`개(기본 10, `_config.yml`에서 설정) 보여 줍니다.

글, 작성자, 피드는 [블로그와 뉴스](../)에서 다룹니다.
