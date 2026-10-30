---
title: 블로그와 뉴스
nav_order: 50
description: 블로그 목록, 뉴스 첫 화면, 작성자 정보, 작성자 페이지, Atom 피드를 만듭니다.
---
# 블로그와 뉴스

레이아웃 다섯 개로 테마를 블로그나 뉴스 사이트로 쓸 수 있습니다. 모두 Liquid만 쓰기 때문에 기본 GitHub Pages와 Jekyll 4에서 그대로 빌드됩니다. `modootoday-blog.css`와 `share.js`는 이 레이아웃을 쓰는 페이지에서만 불러옵니다. 문서 페이지는 두 파일을 받지 않습니다.

| 레이아웃 | 용도 |
| --- | --- |
| `blog` | 글 목록과 페이지 이동. `list`, `grid`, `magazine` 중에서 고릅니다 |
| `post` | 글 하나. 작성자 정보, 읽는 시간, 표지, 시리즈, 이전·다음 글, 관련 글이 붙습니다 |
| `news` | 첫 화면. 머리기사, 보조 기사, 최신 목록, 카테고리별 섹션이 나옵니다 |
| `news-article` | 부제, 속보·라이브 배지, 정정, 출처가 붙는 기사 |
| `author` | 작성자 소개와 작성자의 글 |
| `feed` | 언어 하나의 Atom 피드 |

## 데모

아래 데모는 문서 밖에서 레이아웃 하나로 만든 실제 페이지입니다. 여기서 열거나 새 창에서 열어 보세요. 데모 안에서 예시 밖으로 나가는 링크는 `#`로 되어 있습니다.

| 데모 | 레이아웃 | 새 창 |
| --- | --- | --- |
| [블로그 목록](blog/) | `blog` | [새 창에서 열기](blog/ "new-window") |
| [블로그 글](post/) | `post` | [새 창에서 열기](post/ "new-window") |
| [뉴스 첫 화면](news/) | `news` | [새 창에서 열기](news/ "new-window") |
| [뉴스 기사](article/) | `news-article` | [새 창에서 열기](article/ "new-window") |
| [연도별 아카이브](archive/) | `archive` | [새 창에서 열기](archive/ "new-window") |

한국어 글의 Atom 피드는 [feed.xml](../../feed.xml)에 있습니다. [영어](../../../feed.xml)와 [일본어](../../../ja/feed.xml) 피드도 따로 있습니다.

## 블로그 목록

```markdown
---
title: 블로그
layout: blog
variant: grid      # list | grid | magazine
category: guides   # 필요할 때만 넣습니다. tag: 도 쓸 수 있습니다
---
```

[예시 블로그](../../blog/)에서 이 사이트의 글로 렌더링한 모습을 볼 수 있습니다.


## 글

```markdown
---
title: 1.0 출시
author: kim            # 또는 authors: [kim, lee]. _data/authors.yml의 id를 씁니다
image: /assets/cover.png
series: launch         # 같은 series 글에는 "3편 중 2편"과 이동 링크가 붙습니다
last_modified_at: 2026-10-30
---
```

작성자 정보는 `_data/authors.yml`에 넣습니다. 글마다 `BlogPosting` JSON-LD와 `article:*` Open Graph 태그가 나갑니다.

## 뉴스

`layout: news`에 `news_sections: [releases, guides]`를 넣으면 첫 화면이 됩니다. 기사는 `layout: news-article`을 쓰고 `deck:`, `breaking: true`, `live: true`, `correction:`, `sources:`, `credits:`를 넣을 수 있습니다. [예시 첫 화면](../../news/)을 보세요.

## 작성자와 피드

작성자 페이지는 `layout: author`와 `author: kim`으로 만듭니다. 언어 폴더마다 `layout: feed`인 `feed.xml`을 두면 언어별 Atom 피드가 생기고, head에 자동으로 연결됩니다.

## 설정

```yaml
modootoday:
  blog:
    variant: list
    per_page: 10
    excerpt: true
    reading_time: true
    related: 3          # 0이면 관련 글을 숨깁니다
    share: true
```

front matter 항목 전체는 [영어 안내](../../../layouts/blog-news/#settings)의 표를 보세요.
