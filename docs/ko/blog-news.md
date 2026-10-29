---
title: 블로그와 뉴스
description: 블로그 목록, 뉴스 첫 화면, 작성자 정보, 작성자 페이지, Atom 피드를 만들어요.
---
# 블로그와 뉴스

레이아웃 다섯 개로 테마를 블로그나 뉴스 사이트로 쓸 수 있어요. 모두 Liquid만 쓰기 때문에 기본 GitHub Pages와 Jekyll 4에서 그대로 빌드돼요. `modootoday-blog.css`와 `share.js`는 이 레이아웃을 쓰는 페이지에서만 불러와요. 문서 페이지는 두 파일을 받지 않아요.

| 레이아웃 | 용도 |
| --- | --- |
| `blog` | 글 목록과 페이지 이동. `list`, `grid`, `magazine` 중에서 골라요 |
| `post` | 글 하나. 작성자 정보, 읽는 시간, 표지, 시리즈, 이전·다음 글, 관련 글이 붙어요 |
| `news` | 첫 화면. 머리기사, 보조 기사, 최신 목록, 카테고리별 섹션이 나와요 |
| `news-article` | 부제, 속보·라이브 배지, 정정, 출처가 붙는 기사 |
| `author` | 작성자 소개와 작성자의 글 |
| `feed` | 언어 하나의 Atom 피드 |

## 블로그 목록

```markdown
---
title: 블로그
layout: blog
variant: grid      # list | grid | magazine
category: guides   # 필요할 때만 넣어요. tag: 도 쓸 수 있어요
---
```

[예시 블로그](../blog/)에서 이 사이트의 글로 렌더링한 모습을 볼 수 있어요.


## 글

```markdown
---
title: 1.0 출시
author: kim            # 또는 authors: [kim, lee]. _data/authors.yml의 id를 써요
image: /assets/cover.png
series: launch         # 같은 series 글에는 "3편 중 2편"과 이동 링크가 붙어요
last_modified_at: 2026-10-30
---
```

작성자 정보는 `_data/authors.yml`에 넣어요. 글마다 `BlogPosting` JSON-LD와 `article:*` Open Graph 태그가 나가요.

## 뉴스

`layout: news`에 `news_sections: [releases, guides]`를 넣으면 첫 화면이 돼요. 기사는 `layout: news-article`을 쓰고 `deck:`, `breaking: true`, `live: true`, `correction:`, `sources:`, `credits:`를 넣을 수 있어요. [예시 첫 화면](../news/)을 보세요.

## 작성자와 피드

작성자 페이지는 `layout: author`와 `author: kim`으로 만들어요. 언어 폴더마다 `layout: feed`인 `feed.xml`을 두면 언어별 Atom 피드가 생기고, head에 자동으로 연결돼요.

## 설정

```yaml
modootoday:
  blog:
    variant: list
    per_page: 10
    excerpt: true
    reading_time: true
    related: 3          # 0이면 관련 글을 숨겨요
    share: true
```

머리말 항목 전체는 [영어 안내](../../blog-news/#settings)의 표를 보세요.
