---
lang: ko
permalink: /ko/layouts/blog-news/
source_rev: sha256:7be356b2032b
nav_order: 50
title: 블로그와 뉴스
description: 블로그 목록, 뉴스 첫 화면, 글의 작성자 정보, 작성자 페이지, 언어별 Atom 피드를 만드는 레이아웃과 각 레이아웃의 front matter를 설명합니다.
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

아래 데모는 문서 밖에서 레이아웃 하나로 만든 실제 페이지입니다. 여기서 열거나 새 창에서 열어 보세요. blog와 post 데모 페이지는 미리 보기를 보여 주고 blog 스타터의 라이브 데모로 연결합니다. 데모 안에서 예시 밖으로 나가는 링크는 `#`로 되어 있습니다.

| 데모 | 레이아웃 | 새 창 |
| --- | --- | --- |
| [블로그 목록](blog/) | `blog` | [라이브 데모](https://modootoday.github.io/jekyll-theme-modootoday-blog-starter/ "new-window") |
| [블로그 글](post/) | `post` | [라이브 데모](https://modootoday.github.io/jekyll-theme-modootoday-blog-starter/notes/2026/10/20/hello-blog/ "new-window") |
| [뉴스 첫 화면](news/) | `news` | [새 창에서 열기](news/ "new-window") |
| [뉴스 기사](article/) | `news-article` | [새 창에서 열기](article/ "new-window") |
| [연도별 아카이브](archive/) | `archive` | [새 창에서 열기](archive/ "new-window") |

한국어 글의 Atom 피드는 [feed.xml](../../../ko/feed.xml)에 있습니다. [영어](../../../feed.xml)와 [일본어](../../../ja/feed.xml) 피드도 따로 있습니다.

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
author: kim            # 또는 authors: [kim, lee]. _data/authors.yml의 id, 이름, {name, url, picture}를 씁니다
image: /assets/cover.png
series: launch         # 같은 series 글에는 "3편 중 2편"과 이동 링크가 붙습니다
last_modified_at: 2026-10-30
---
```

작성자 정보는 `_data/authors.yml`에 넣습니다. 이 파일에 없는 id는 쓴 그대로 나오므로 `author: Kim Lee`처럼 이름만 써도 됩니다. `author:`에는 쉼표 목록이나 `name`, `url`, `picture`가 있는 맵(jekyll-seo-tag 형식)도 쓸 수 있습니다. 둘 다 없는 글은 `modootoday.schema.author`, 그다음 사이트의 `author:`(이름, 또는 minima의 `{name, email}` 같은 맵)를 씁니다. 작성자 줄, Atom 피드, JSON-LD가 같은 목록을 읽습니다. 글마다 `BlogPosting` JSON-LD와 `article:*` Open Graph 태그가 나갑니다.

## 뉴스

`layout: news`에 `news_sections: [releases, guides]`를 넣으면 첫 화면이 됩니다. 기사는 `layout: news-article`을 쓰고 `deck:`, `breaking: true`, `live: true`, `correction:`, `sources:`, `credits:`를 넣을 수 있습니다. [예시 첫 화면](../../news/)을 보세요.

## 작성자와 피드

작성자 페이지는 `layout: author`와 `author: kim`으로 만듭니다.

피드는 `layout: feed`를 쓴 페이지입니다. 테마가 Liquid로 쓰므로 플러그인이 필요 없고 GitHub Pages에서 그대로 빌드됩니다. 사이트 루트에 front matter만 담은 `feed.xml`을 두고, 언어 폴더마다(`/ko/feed.xml`) 하나씩 두면 언어별 Atom 피드가 생깁니다. 전문을 담으려면 `feed_content: full`을 씁니다.

```yaml
---
layout: feed
---
```

`modootoday.feed: true`는 모든 페이지의 head에 그 피드(그 언어의 피드가 있으면 그 피드)를 연결할 뿐, 피드를 직접 쓰지는 않습니다. `jekyll-feed`를 함께 넣지 마세요. 그 플러그인도 `/feed.xml`을 씁니다.

변경 이력도 릴리스마다 항목 하나인 피드가 될 수 있습니다. 파일 두 개와 `feed_source:`, `releases_feed:`는 문서 확장의 [변경 이력](../docs-extra/#변경-이력)에 있습니다.

`modootoday.feed`가 `true`이면 `category`나 `tag`가 없는 블로그 목록은 그 언어의 피드를 head와 소개 아래 구독 링크로 연결합니다. 블로그, 작성자, 아카이브 페이지와 변경 이력 같은 문서 확장 페이지는 `feed:`로 자기 피드를 정합니다. 값은 `layout: feed` 페이지의 사이트 경로이고, 연결하지 않으려면 `false`입니다. 이 레이아웃들은 피드를 구독 링크로 보여 주고, 다운로드 페이지 같은 다른 페이지에서는 `feed:`가 head 링크만 더합니다. 한 작성자의 글만 담으려면 `layout: feed`와 `author: kim`을 쓴 `/authors/kim.xml` 같은 페이지를 만들고, 작성자 페이지에 `feed: /authors/kim.xml`을 적습니다. 빌드에 없는 `feed:`는 `modootoday-check`가 알려 줍니다.

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

| front matter | 레이아웃 | 뜻 |
| --- | --- | --- |
| `variant` | blog, author | `list`, `grid`, `magazine` |
| `category`, `tag` | blog, news, feed | 글을 거릅니다 |
| `feed` | blog, author, archive, changelog와 다른 문서 확장. download와 모든 페이지는 head 링크만 | head에 연결하고, 앞에 적은 레이아웃에서는 구독 링크로도 보여 줄 이 페이지의 Atom 피드. `/authors/kim.xml` 같은 사이트 경로, 또는 `false` |
| `news_sections`, `secondary`, `latest` | news | 카테고리 섹션과 기사 수 |
| `posts_lang` | blog, news, author | `all`이면 모든 언어의 글을 보여 줍니다 |
| `featured` | blog, post | 블로그 페이지에서는 `true`면 첫 카드를 크게 보여 주고, 글에서는 그 글을 머리 카드로 고정합니다 |
| `archive_url` | blog | 마지막 카드 다음의 이전 글 링크가 가는 곳. 예: `/archive/` |
| `hidden`, `list: false` | post | 목록에서 글을 뺍니다 |
| `author`, `authors` | post, author, feed | `_data/authors.yml`의 id, 이름, `{name, url, picture}`. 기본값은 사이트의 `author` |
| `series` | post | 글을 번호 붙은 연재로 묶습니다 |
| `image`, `image_alt`, `image_caption` | post | 표지(경로 또는 `{path, alt, width, height}`), 대체 텍스트, 설명 |
| `categories`, `tags` | post | 글 아래에 나오고 관련 글을 고르는 데 씁니다 |
| `last_modified_at` | post | 마지막으로 고친 날짜 |
| `deck` | post, news-article | 제목 아래 한 문장 |
| `breaking`, `live`, `correction`, `sources`, `credits` | news-article | 기사 정보 |
| `feed_lang`, `limit`, `feed_content` | feed | 피드 범위 |
| `feed_source`, `home` | feed | 변경 이력을 피드로: `data`나 `layout: changelog` 페이지 URL, 그리고 항목이 연결할 곳 |
| `releases_feed` | changelog, download, 모든 페이지 | `true`(`site.github`에서) 또는 URL. GitHub `releases.atom`을 head에 연결하고, changelog와 다른 문서 확장에서는 제목 아래에도 연결 |
