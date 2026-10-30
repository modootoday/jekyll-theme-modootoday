---
title: 페이지 셸
description: 페이지 종류별 셸과 레이아웃마다 따로 불러오는 선택 스타일시트입니다.
nav_order: 10
---
# 페이지 셸

페이지 front matter에서 `layout:`을 지정하세요. 아래 페이지 셸은 이 레이아웃을 쓰는 페이지에서만 추가 스타일시트 `modootoday-pages.css`를 불러오므로, 다른 페이지의 용량은 그대로입니다. JavaScript는 추가하지 않습니다.

| 레이아웃 | 용도 | 데모 |
|---|---|---|
| `minimal` | 단독 공지, 로그인 안내, 링크 모음. 헤더·페이지 정보·페이지 이동이 없습니다. | [미니멀](/jekyll-theme-modootoday/ko/layouts/demo/minimal/) |
| `wide` | 카드 그리드, 넓은 표, 갤러리. 헤더와 푸터는 있고 읽기 폭 제한이 없습니다. | [와이드](/jekyll-theme-modootoday/ko/layouts/demo/wide/) |
| `home` | 랜딩 페이지. front matter의 히어로 다음에 본문이 오고 WebSite 구조화 데이터를 추가합니다. | [홈](/jekyll-theme-modootoday/ko/layouts/demo/home/) |
| `error` | 제목과 설명이 번역된 404, 410, 500 페이지. | [오류](/jekyll-theme-modootoday/ko/layouts/demo/error/) |
| `redirect` | 옮겨진 페이지. 스크립트 없이 이동하므로 엄격한 CSP에서도 동작합니다. | [리디렉션](/jekyll-theme-modootoday/ko/layouts/demo/redirect/) |
| `search` | JavaScript 없이도 쓸 수 있는 양식이 있는 전체 검색 페이지. | [검색](/jekyll-theme-modootoday/ko/layouts/demo/search/) |

프로젝트, 구성원, 채용, 행사, 후원사, 연동 카드 목록은 [디렉터리 레이아웃](/jekyll-theme-modootoday/ko/layouts/directory/)에 있습니다.

## 홈

```yaml
---
layout: home
hero:
  title: Markdown으로 사이트 만들기
  text: 사이트를 소개하는 한 문장.
  actions:
    - {label: 시작하기, url: /ko/install/}
    - {label: GitHub, url: "https://github.com/modootoday/jekyll-theme-modootoday"}
---
```

첫 번째 액션이 주 버튼이 됩니다. `hero.title`이 없으면 본문만 보여 줍니다. 선택 항목인 `hero.image`(경로 또는 `{path, alt, width, height, srcset}`)를 주면 액션 아래에 넓은 그림을 보여 줍니다. 장식용이면 `alt`를 비워 두세요. 히어로 비주얼 `showcase`도 같은 `hero.image` 키를 읽습니다([커스터마이즈](../../guides/customize/) 참고).

## 오류

```yaml
---
layout: error
status: 404
permalink: /404.html
sitemap: false
---
```

`status`는 `404`(기본값), `410`, `500` 중 하나입니다. 제목과 설명은 테마에 내장된 23개 언어 카탈로그에서 가져옵니다. 제목을 바꾸려면 `heading:`을 지정하고, 본문을 쓰면 링크를 더할 수 있습니다.

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
