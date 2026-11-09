---
lang: ko
permalink: /ko/layouts/shells/
source_rev: sha256:40b7346b1355
nav_order: 10
title: 페이지 셸
description: 홈, 오류, 리디렉션, 검색처럼 페이지 종류마다 쓰는 셸과, 각 레이아웃이 필요한 페이지에서만 따로 불러오는 선택 스타일시트를 설명합니다.
---
# 페이지 셸

페이지 front matter에서 `layout:`을 지정하세요. 아래 페이지 셸은 이 레이아웃을 쓰는 페이지에서만 추가 스타일시트 `modootoday-pages.css`를 불러오므로, 다른 페이지의 용량은 그대로입니다. JavaScript는 추가하지 않습니다.

| 레이아웃 | 용도 | 데모 |
|---|---|---|
| `minimal` | 단독 공지, 로그인 안내, 링크 모음. 헤더·페이지 정보·페이지 이동이 없습니다. | [미니멀](../demo/minimal/) |
| `wide` | 카드 그리드, 넓은 표, 갤러리. 헤더와 푸터는 있고 읽기 폭 제한이 없습니다. | [와이드](../demo/wide/) |
| `home` | 랜딩 페이지. front matter의 히어로 다음에 본문이 오고, 히어로가 없으면 최근 글 목록이 이어집니다. 히어로 제목도 본문의 `# ` 제목도 없으면 페이지 제목(없으면 사이트 제목)이 `h1`이 됩니다. WebSite 구조화 데이터를 추가합니다. | [홈](https://modootoday.github.io/jekyll-theme-modootoday-landing-starter/ "new-window") |
| `page` | Jekyll, minima, `jekyll new`가 일반 페이지에 쓰는 이름입니다. 이름만 다른 `doc` 레이아웃입니다. 다른 `doc` 페이지처럼, 본문에 `# ` 제목이 없으면 minima처럼 `title:`을 `h1`로 표시합니다. | 없음 |
| `error` | 제목과 설명이 번역된 404, 410, 500 페이지. | [오류](../demo/error/) |
| `redirect` | 옮겨진 페이지. 스크립트 없이 이동하므로 엄격한 CSP에서도 동작합니다. | [리디렉션](../demo/redirect/) |
| `search` | JavaScript 없이도 쓸 수 있는 양식이 있는 전체 검색 페이지. | [검색](../demo/search/) |

프로젝트, 구성원, 채용, 행사, 후원사, 연동 카드 목록은 [디렉터리 레이아웃](../directory/)에 있습니다.

## 홈

```yaml
---
layout: home
hero:
  title: Markdown으로 사이트 만들기
  text: 사이트를 소개하는 한 문장.
  actions:
    - {label: 시작하기, url: /ko/docs/start/}
    - {label: GitHub, url: "https://github.com/modootoday/jekyll-theme-modootoday"}
---
```

첫 번째 액션이 주 버튼이 됩니다. `hero.title`이 없으면 본문만 보여 줍니다. `home`은 본문을 쓴 그대로 보여 주고 `sections:`를 읽지 않으므로 카드, 탭, 버튼 섹션은 적용되지 않습니다. 이런 섹션이 있는 홈 페이지는 이 사이트의 홈처럼 `layout: doc`에 `hero:`와 `sections:`를 함께 씁니다. 선택 항목인 `hero.image`(경로 또는 `{path, alt, width, height, srcset}`)를 주면 액션 아래에 넓은 그림을 보여 줍니다. 장식용이면 `alt`를 비워 두세요. 히어로 비주얼 `showcase`도 같은 `hero.image` 키를 읽습니다([커스터마이즈](../../guides/customize/) 참고).

`hero:`와 `sections:`가 없는 홈 페이지는 사이트에 글이 있으면 minima처럼 본문 아래에 최근 글 목록을 보여 줍니다. 그래서 `jekyll new`가 만든 `index.md`도 목록을 그대로 유지합니다. `posts: true`는 어느 홈 페이지에나 목록을 더하고 `posts: false`는 목록을 뺍니다. `list_title:`은 목록 제목을 바꾸고, `show_excerpts:`(페이지, 그다음 `_config.yml`)는 요약을 보이거나 숨깁니다. 이 키가 없으면 요약은 `modootoday.blog.excerpt`를 따릅니다. `index.html`에서 jekyll-paginate를 쓰면 목록도 함께 페이지가 나뉘고, 그렇지 않으면 `modootoday.blog.per_page`개를 보여 준 뒤 아카이브로 연결합니다.

## 오류

```yaml
---
layout: error
status: 404
permalink: /404.html
sitemap: false
---
```

`status`는 `404`(기본값), `410`, `500` 중 하나입니다. 오류 페이지에는 Markdown 버전이 없습니다. 플러그인과 `modootoday-stubs`는 오류 페이지를 건너뛰고, `modootoday-check --twins`도 요구하지 않습니다. 제목과 설명은 테마에 내장된 23개 언어 카탈로그에서 가져옵니다. 제목을 바꾸려면 `heading:`을 지정합니다. 페이지 끝에는 항상 홈으로 가는 버튼이 있습니다. 바로가기 링크를 더하려면 링크를 공백으로 구분해 한 문단에 쓰세요. 칩 한 줄로 표시됩니다.

```markdown
[문서](/docs/) [검색](/search/) [English](/)
```

## 리디렉션

```yaml
---
layout: redirect
permalink: /old-page/
redirect_to: /new-page/
---
```

`redirect_to`에는 사이트 경로나 전체 URL을 씁니다. 이 페이지는 `noindex`로 표시되고 검색 엔진에 새 주소를 알려 줍니다.

## 검색

헤더 검색창에서 바로 결과를 볼 수 있습니다. `search` 레이아웃은 본문 아래에, JavaScript가 꺼져 있을 때 외부 검색 엔진으로 이 사이트를 검색하는 양식을 추가합니다. `_config.yml`에서 바꿀 수 있습니다.

```yaml
modootoday:
  search:
    fallback: {url: "https://duckduckgo.com/", param: q}   # 양식을 숨기려면 false
```

양식은 검색 범위를 `url:`의 호스트로 제한합니다. `url:`이 없는 사이트(`jekyll new`는 `url: ""`을 씁니다)는 제한할 호스트가 없으므로, 웹 전체를 검색하지 않도록 레이아웃이 양식을 넣지 않습니다. 양식을 쓰려면 `url:`에 사이트 주소를 적으세요. 본문에 `# ` 제목이 없으면 페이지의 `title:`이 제목으로 나오고, 양식은 레이블로 이름이 붙은 검색 랜드마크라서 헤더 검색창과 구별됩니다.
