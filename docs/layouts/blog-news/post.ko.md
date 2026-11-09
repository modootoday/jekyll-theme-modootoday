---
lang: ko
permalink: /ko/layouts/blog-news/post/
source_rev: sha256:0c9a316a44ca
title: 글 레이아웃
description: "작성자, 읽는 시간, 표지, 시리즈, 태그, 공유 링크, 관련 글이 있는 글 한 편의 레이아웃입니다."
layout: layout-reference
nav_order: 2
---
# 글 레이아웃

`layout: post`는 `_posts`의 파일에 기본으로 붙는 레이아웃입니다. 본문 위에는 제목, 덱, 작성자와 날짜와 읽는 시간이 든 바이라인, 표지 이미지를 보여 주고, 본문 아래에는 시리즈, 태그와 분류, 공유 링크, 이전 글과 다음 글, 관련 글을 보여 줍니다. 페이지에는 `BlogPosting` 구조화 데이터와 `article:*` Open Graph 태그가 들어갑니다. 라이브 데모는 blog 스타터의 글입니다.

## Front matter

| 키 | 용도 |
|---|---|
| `author` 또는 `authors` | `_data/authors.yml`의 id, 이름, 또는 `{name, url, picture}` |
| `image` | 표지: 경로 또는 `{path, alt, width, height}` |
| `image_alt`, `image_caption` | 표지의 대체 텍스트와 캡션 |
| `deck` | 제목 아래의 한 문장 |
| `series` | 같은 시리즈의 글에 "3편 중 2편"과 서로의 링크가 붙습니다 |
| `categories`, `tags` | 글 아래에 표시되고 관련 글을 고르는 데 쓰입니다 |
| `last_modified_at` | 마지막 수정일 |

```yaml
---
title: Shipping 1.0
author: kim
image: {path: /assets/cover.webp, alt: The release dashboard, width: 1024, height: 576}
series: launch
tags: [release]
---
```

작성자 데이터와 피드는 [블로그와 뉴스](../)에서 다룹니다.
