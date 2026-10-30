---
nav_order: 0
layout: examples
title: 컴포넌트
description: 모든 컴포넌트를 만드는 Markdown 소스와 실제 렌더링 결과를 함께 보여 줍니다.
examples: [alerts, alerts-content, cards, cards-3, buttons, tabs, badges, keyboard, accordion, steps, steps-headings, timeline, timeline-list, figure, tables, code, code-titles, progress, embeds, loading, filetree, details, faq, params, linkcards, quote, gallery, pricing, subscribe, split]
sections:
  - alerts
  - alerts-content
  - {c: features, name: cards, cols: 2, badge: bottom}
  - {c: features, name: cards-3, cols: 3, reveal: true}
  - {c: features, name: cards-4, cols: 4}
  - {c: cta, name: buttons}
  - {c: tabs, name: tabs}
  - badges
  - keyboard
  - {c: accordion, name: accordion}
  - {c: steps, name: steps}
  - {c: steps, name: steps-headings}
  - {c: timeline, name: timeline}
  - {c: timeline, name: timeline-list}
  - figure
  - tables
  - code
  - code-titles
  - progress
  - embeds
  - loading
  - {c: filetree, name: filetree}
  - {c: details, name: details}
  - {c: faq, name: faq}
  - {c: params, name: params}
  - {c: linkcards, name: linkcards}
  - {c: quote, name: quote}
  - {c: gallery, name: gallery}
  - {c: pricing, name: pricing, recommended: 2}
  - {c: subscribe, name: subscribe}
  - {c: split, name: split, visual: split-demo, decor: decor-demo, tag: "일러스트", side: start, ratio: "5:7", label: "제목, 텍스트 두 줄, 버튼이 있는 화면"}
  - lists
  - navigation
  - language-switcher
  - theme-toggle
  - icons
  - search
  - breadcrumb-toc
  - pagination
  - posts
  - status
  - {c: cta, name: next}
---
# 컴포넌트

모든 컴포넌트는 평범한 Markdown입니다. 아래 예시마다 Markdown 소스와, 같은 소스로 테마가 그려 낸 실제 결과를 이어서 보여 줍니다. 결과는 지금 쓰는 라이트·다크 모드 그대로입니다. 소스 블록을 복사해 붙이면 같은 결과를 얻습니다. github.com에서는 기본 요소로 보입니다.

[키친싱크 열기](kitchen-sink/) [설정](../guides/configuration/)

> [!NOTE]
> 이 페이지는 [영어 원문](../../components/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 알림

`status:available` GitHub 알림이 언어에 맞는 제목이 붙은 콜아웃이 됩니다. 종류는 note, tip, important, warning, caution 다섯 가지입니다. 스크린 리더는 각각을 노트(`role="note"`)로 읽습니다.

> [!NOTE]
> 훑어보더라도 꼭 알아야 할 유용한 정보입니다.

> [!TIP]
> 더 쉽고 낫게 하는 데 도움이 되는 조언입니다.

> [!IMPORTANT]
> 목표를 이루려면 반드시 알아야 할 핵심 정보입니다.

> [!WARNING]
> 문제를 막으려면 바로 확인해야 하는 긴급한 정보입니다.

> [!CAUTION]
> 특정 동작의 위험이나 나쁜 결과를 경고합니다.

## 내용이 있는 알림

알림 안에 목록과 코드를 넣을 수 있습니다. 표시가 있는 줄에는 다른 글자를 쓰지 마세요.

> [!TIP]
> 게시하기 전에:
>
> - `modootoday-check` 실행
> - `bundle exec jekyll serve`로 미리 보기

## 카드

`status:available` `c: features` 섹션에서 **굵은 글씨**로 시작하는 목록 항목이 카드가 됩니다. `cols: 2`, `cols: 3`, `cols: 4`로 열 수를 정하고, 좁은 화면에서는 한 열로 보입니다. `cols: 4`는 중간 너비 화면에서 두 열로 보입니다.

- **평범한 Markdown** — github.com에서도 잘 읽힙니다.
- **배지 포함** — 카드에 상태를 표시할 수 있습니다. `status:available`

`badge: bottom`을 쓰면 항목 끝의 상태 배지가 카드 아래쪽에 놓여, 한 줄의 배지가 가지런히 정렬됩니다.

## 3열 카드

같은 목록을 `cols: 3`으로 쓴 예입니다. `reveal: true`를 쓰면 섹션이 화면에 들어올 때 서서히 나타납니다. 스크롤 기반 애니메이션을 지원하는 브라우저에서 사용자가 움직임을 허용한 경우에만 동작하며, 그 밖의 환경에서는 그대로 보입니다. 스크립트는 쓰지 않습니다.

- **알림** — 알림 다섯 종류.
- **탭** — 접근성을 갖춘 코드 탭.
- **검색** — 클라이언트 검색.

## 4열 카드

넓은 화면에서 `cols: 4`로 쓴 예입니다.

- **알림** — 다섯 가지 알림 유형.
- **탭** — 접근성을 갖춘 코드 탭.
- **검색** — 클라이언트 쪽 검색.
- **카드** — 두 열에서 네 열까지의 그리드.

## 버튼

`status:available` 링크만 있는 문단이 버튼이 되고, 첫 링크가 주 버튼입니다. 히어로(첫 `##` 앞)와 `c: cta` 섹션에서 동작합니다.

[시작하기](../guides/install/) [설정 읽기](../guides/configuration/)

## 탭

`status:available` `c: tabs` 섹션에서 `###` 제목과 바로 뒤 코드 블록이 탭 하나가 됩니다. 두 개 이상 쓰세요. 방향키로 탭을 옮기고 Home·End로 처음과 끝으로 갑니다. JavaScript가 없으면 모든 블록이 제목 아래에 그대로 보입니다.

### macOS

```sh
brew install ruby
```

### Linux

```sh
sudo apt install ruby-full
```

## 배지

`status:available` 정해진 접두어가 붙은 코드 스팬이 배지가 됩니다. status(available, partial, planned)와 tag가 있습니다. 상태 기호는 스크린 리더에서 숨기고 이름을 읽습니다.

`status:available` `status:partial` `status:planned`

`tag:beta`

## 키보드 키

`status:available` kbd와 콜론으로 시작하는 코드 스팬이 키보드 키가 됩니다. 키는 공백 없이 `+`로 잇습니다.

`kbd:Ctrl+K`를 누르거나 `kbd:/`를 누르면 검색이 열립니다.

## 아코디언

`status:available` `c: accordion` 섹션에서 `###` 제목이 아래 내용을 펼치고 접는 버튼(`aria-expanded`)이 됩니다. Enter나 Space로 전환합니다. JavaScript가 없으면 모든 답이 보입니다.

### JavaScript 없이도 동작하나요?

네. 모든 답이 질문 아래에 펼쳐진 채로 보입니다.

### 답에 코드를 넣을 수 있나요?

```sh
bundle exec jekyll serve
```

## 단계

`status:available` `c: steps` 섹션에서 번호 목록이 번호 붙은 단계가 됩니다.

1. `_config.yml`에 테마를 추가합니다.
2. 평범한 Markdown으로 `index.md`를 씁니다.
3. `bundle exec jekyll build`를 실행합니다.

## 제목으로 쓰는 단계

단계 하나에 여러 줄이 필요하면 목록 대신 `###` 제목을 쓰세요.

### 설치

`remote_theme`과 플러그인을 추가합니다.

### 배포

`main`에 푸시하고 GitHub Pages를 켭니다.

## 타임라인

`status:available` `c: timeline` 섹션에서 `###` 제목이 선 위의 지점이 됩니다.

### 설치

알림, 섹션, 카드, 탭.

### 확인

테마 전환, 이동 경로, 목차.

## 목록으로 쓰는 타임라인

번호 목록으로도 쓸 수 있습니다.

1. 설치: 알림, 섹션, 카드.
2. 작성: 디자인 토큰, 내비게이션.
3. 확인: 테마 전환, 단계.

## 그림

`status:available` 이미지만 있는 문단 뒤에 *강조*만 있는 문단이 오면 캡션이 붙은 그림이 됩니다. 대체 텍스트는 필수입니다.

![왼쪽 Markdown 소스가 오른쪽에서 스타일이 적용된 페이지로 바뀌는 모습](../../assets/images/sample.svg)

*왼쪽은 Markdown, 오른쪽은 렌더링된 페이지입니다.*

## 표

`status:available` GFM 표는 작은 화면에서 페이지를 넘치지 않고 가로로 스크롤됩니다.

| 키 | 기본값 | 설명 |
|---|---|---|
| `color_scheme` | `auto` | 운영체제 설정을 따르거나 라이트·다크 중 하나로 고정 |
| `badges` | `true` | 상태 코드 스팬을 배지로 바꿈 |

## 코드 블록

`status:available` 펜스 코드 블록은 구문 강조가 되고 첫 줄 끝에 복사 버튼이 붙습니다. 긴 줄은 스크롤되고 키보드로도 블록에 갈 수 있습니다.

```ruby
Jekyll::Hooks.register :site, :post_write do |site|
  puts "Built #{site.pages.size} pages"
end
```

## 코드 제목과 diff

`status:available` 펜스 코드 블록 바로 앞에 file과 콜론으로 시작하는 코드 스팬만 있는 줄을 두면 블록의 제목 표시줄이 됩니다. `diff` 블록은 추가된 줄과 삭제된 줄에 색을 입히고 더하기·빼기 기호를 유지합니다.

`file:_config.yml`

```yaml
theme: jekyll-theme-modootoday
```

```diff
- remote_theme: old/theme
+ theme: jekyll-theme-modootoday
```

## 진행률

`status:available` progress와 콜론 뒤에 0부터 100까지의 정수가 오는 코드 스팬은 값을 텍스트로 함께 보여 주는 레이블 있는 진행률 막대가 됩니다.

번역 `progress:60`

## 임베드

`status:available` embed와 콜론, https URL, 선택 제목으로 된 코드 스팬만 있는 문단은 지연 로드되는 16:9 프레임이 되며, 로드되는 동안에도 자리를 유지합니다.

`embed:https://modootoday.github.io/jekyll-theme-modootoday/assets/images/sample.svg 샘플 페이지 그림`

## 로딩과 스켈레톤

`status:available` loading 또는 skeleton과 콜론으로 시작하는 코드 스팬은 스피너, 얇은 상단 막대, 자리 표시자(text, card, image, avatar, row)가 됩니다. 모두 `role="status"`와 스크린 리더용 로딩 레이블이 붙고, 사용자가 동작 줄이기를 켜면 움직이지 않습니다. 스타일은 별도 스타일시트에 있어 이 요소를 쓰는 페이지만 불러옵니다.

`loading:spinner`

`skeleton:avatar`
`skeleton:text`
`skeleton:card`

## 파일 트리

`status:available` `c: filetree` 섹션에서는 중첩 목록이 폴더 트리로 그려집니다. 하위 목록이 있는 항목은 폴더입니다.

- docs
  - _config.yml
  - index.md
  - ko
    - index.md

## 세부 정보

`status:available` `c: details` 섹션에서는 각 `###` 제목이 브라우저 기본 펼침 요소가 됩니다. JavaScript 없이 열고 닫힙니다.

### 무엇이 필요한가요?

브라우저만 있으면 됩니다.

## 자주 묻는 질문

`status:available` `c: faq` 섹션은 세부 정보처럼 동작합니다. FAQPage 구조화 데이터가 필요하면 `schema:` 블록을 추가하세요([구조화 데이터](../guides/structured-data/) 참고).

### 테마는 무료인가요?

네, MIT 라이선스입니다.

### GitHub Pages에서 동작하나요?

네, github-pages gem으로 동작합니다.

## 매개변수 표

`status:available` `c: params` 섹션에서는 표가 옵션을 이름, 유형, 기본값, 설명으로 나열합니다. `required`만 있는 셀은 필수 배지로 표시됩니다.

| 이름 | 유형 | 기본값 | 설명 |
|---|---|---|---|
| `title` | 문자열 | `required` | 페이지 제목 |
| `cols` | 숫자 | 2 | 카드 열 수 |

## 링크 카드

`status:available` `c: linkcards` 섹션에서는 링크로 시작하는 목록 항목이 카드가 됩니다. 카드 전체가 링크 대상입니다.

- [설치](../guides/install/) — 사이트에 테마를 추가합니다.
- [설정](../guides/configuration/) — 모든 설정을 한곳에서 봅니다.

## 인용

`status:available` `c: quote` 섹션에서는 마지막 줄이 줄표(—)로 시작하는 인용문의 그 줄이 출처가 됩니다.

> 문서가 github.com에서도 사이트에서도 잘 읽힙니다.
>
> — 테마 사용자

## 갤러리

`status:available` `c: gallery` 섹션에서는 이미지 목록이 썸네일 격자가 됩니다. 각 썸네일은 JavaScript 없이 원본 크기 보기를 엽니다. 모든 이미지에 대체 텍스트가 필요합니다.

- ![화분과 안락의자가 있는 햇살 드는 방](../../assets/images/gallery/room.webp)
- ![낮은 해 아래 분홍빛 모래 언덕](../../assets/images/gallery/dunes.webp)
- ![잔잔한 연못을 둘러싼 열대 잎](../../assets/images/gallery/leaves.webp)
- ![산속 호수의 나무 선착장](../../assets/images/news/travel-sm.webp)
- ![초록 언덕 위의 풍력 발전기와 태양광 패널](../../assets/images/news/energy-sm.webp)
- ![크림, 보라, 코랄 색 견본을 부채꼴로 펼친 모습](../../assets/images/projects/brand.webp)

## 요금제

`status:available` `c: pricing` 섹션에서는 각 `###` 제목이 가격, 기능 목록, 링크로 이루어진 요금제 카드가 됩니다. `recommended` 매개변수는 한 요금제에 추천 레이블을 붙입니다.

### 무료

**$0**

- 사이트 1개

[시작하기](#)

### 팀

**$12**

- 사이트 10개
- 지원

[팀 선택](#)

## 구독

`status:available` `c: subscribe` 섹션은 텍스트와 `modootoday.subscribe.action`의 주소로 전송하는 이메일 양식을 표시합니다. 이 설정이 없으면 텍스트만 표시합니다.

릴리스가 나오면 이메일을 한 통 받으세요.


## 분할

`status:available` `c: split` 섹션은 48rem 이상에서 텍스트와 그림을 나란히 놓고, 그보다 좁으면 위아래로 쌓습니다. 그림은 `visual:` include입니다. `side: start`는 그림을 시작 쪽으로 옮기고, `ratio: "5:7"`은 그림에 넓은 열을 줍니다. 여기의 `label:`처럼 항목의 다른 키는 include에서 `include.section.label`로 받습니다. 이 그림은 일러스트입니다. `class="mt-illustration"`, `role="img"`, `aria-label`이 있는 `figure`이고, `.mt-illustration-tag` 배지의 글자도 레이블에 들어 있습니다. `decor: decor-demo`는 위쪽 모서리의 점을 `aria-hidden` 장식으로 더합니다.

한쪽에는 텍스트, 다른 쪽에는 그림이 옵니다.

## 목록

`status:available` `_config.yml`에 `modootoday.lists`를 두면 일반 섹션과 페이지에 목록 스타일 두 가지가 적용됩니다. `link_chips: true`는 모든 항목이 링크 하나뿐인 목록을 칩 한 줄로 바꾸고, `titled_items: true`는 굵은 제목과 콜론으로 시작하는 항목에 제목과 구분자를 따로 줍니다. `hero: {checks: true}`는 위처럼 히어로의 첫 목록을 체크 표시 줄로 바꿉니다. 컴포넌트 섹션의 목록은 원래 스타일을 유지합니다.

- [설치](../guides/install/)
- [설정](../guides/configuration/)
- [접근성](../guides/accessibility/)

제목이 있는 항목:

- **칩**: 링크만 있는 목록
- **제목 항목**: 굵은 제목, 콜론, 그다음 텍스트

## 내비게이션

`status:available` 헤더 메뉴는 `_data/nav/main.yml`에서 옵니다. `items:`가 있는 항목은 넓은 화면에서 드롭다운 묶음이 되고, 좁은 화면에서는 메뉴 버튼이 생깁니다. 열린 메뉴는 Esc로 닫습니다. 이 페이지의 헤더가 그 결과입니다.

```yaml
- {title: Install, url: /install/}
- {title: Components, url: /components/}
- title: More
  items:
    - {title: Public API, url: /api/}
```

## 언어 선택기

`status:available` `languages:`와 `language_switcher: header`를 설정하면 헤더에 언어 목록을 여는 지구본 버튼이 생깁니다. 언어가 늘어도 폭은 그대로입니다. 언어 이름은 각 언어로 적고, 현재 언어에는 `aria-current`가 붙습니다. 목록은 Esc로 닫습니다. 이 페이지 헤더의 지구본이 그 결과입니다.

```yaml
modootoday:
  languages: [en, ko, ja]
  language_switcher: header
```

## 테마 전환

`status:available` 헤더 버튼으로 라이트와 다크를 바꾸고, 고른 값을 기억합니다. 한 모드로 고정하려면 `color_scheme`을 쓰세요. 이 페이지 헤더의 버튼이 그 결과입니다.

```yaml
modootoday:
  color_scheme: auto   # auto | light | dark
```

## 아이콘과 로고

`status:available` 테마의 아이콘(지구본, 해와 달, 검색, 알림 종류, 복사, 편집, 이전·다음, 외부 링크, 이동 경로 화살표)은 `currentColor`를 쓰는 인라인 SVG라서 라이트·다크 모드를 따르고 추가 요청이 없습니다. 아이콘은 스크린 리더에서 숨기고, 아이콘만 있는 버튼에는 따로 이름을 붙입니다. 방향을 가리키는 화살표는 오른쪽에서 왼쪽으로 쓰는 페이지에서 뒤집힙니다. `logo`를 정하면 사이트 제목 앞에 modootoday 마크(또는 직접 만든 이미지)가 나오고, `favicon`을 정하면 같은 모양의 브라우저 아이콘이 붙습니다. 이 페이지의 헤더와 푸터가 그 결과입니다.

```yaml
modootoday:
  logo: brand        # brand | /assets/img/logo.svg
  favicon: brand     # brand | /favicon.ico
```

## 검색

`status:available` `search.json` 파일로 동작하는 클라이언트 검색이 헤더에 들어갑니다(`role="search"`). `kbd:Ctrl+K`나 `kbd:/`로 검색창에 갈 수 있습니다. 사이트 루트에 `search.json`을 두면 켜집니다. [이 사이트가 쓰는 파일](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/search.json)을 복사해 쓰세요. 이 페이지 헤더의 검색창이 그 결과입니다.

## 이동 경로와 목차

`status:available` 문서 페이지에는 URL로 만든 이동 경로와, `##`·`###` 제목으로 만든 목차가 붙습니다. 목차는 넓은 화면에서 옆에, 좁은 화면에서는 접는 상자로 보입니다. 레이아웃이 붙이므로 따로 쓸 소스는 없습니다. 끄려면 `components`에서 `breadcrumb`이나 `toc`를 빼세요. 이 페이지 위쪽과 옆이 그 결과입니다.

```yaml
modootoday:
  components: [callout, badge, hero, cta, card, tabs, code-copy, nav, pagination, theme-toggle]
```

## 이전·다음

`status:available` 내비게이션에 있는 페이지에는 내비게이션 순서대로 이전·다음 링크가 붙습니다. 숨기려면 front matter에 `pagination: false`를 쓰세요. 이 페이지 아래쪽이 그 결과입니다.

```yaml
---
title: Components
pagination: false
---
```

## 글과 아카이브

`status:available` `layout: post`는 날짜, 글쓴이, 태그를 보여 줍니다(`p.mt-post-meta`).

```yaml
---
layout: post
title: Hello
date: 2026-10-30
author: Won
tags: [release]
---
```

## 상태 범례

| 배지 | 의미 |
|---|---|
| `status:available` | 출시되어 안정적 |
| `status:partial` | 알려진 한계가 있음 |
| `status:planned` | 로드맵에 있음 |

## 다음

[키친싱크](kitchen-sink/) [설정](../guides/configuration/)
