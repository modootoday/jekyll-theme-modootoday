---
lang: ko
permalink: /ko/components/
source_rev: sha256:48b307dfd141
nav_order: 0
layout: examples
title: 컴포넌트
description: 모든 컴포넌트를 만드는 Markdown 소스와 실제 렌더링 결과를 나란히 보여 주므로, 원하는 모양을 골라 소스를 그대로 복사해 쓸 수 있습니다.
schema: {faq: auto}
examples: [badge, kbd, loading, progress, callout, callout-content, code, code-titles, filetree, quote, embed, figure, gallery, widget, chart, params, table, accordion, details, faq, steps, steps-headings, tabs, timeline, timeline-list, cards, cards-3, cards-4, buttons, install, linkcards, pricing, split, subscribe]
sections:
  - group-text
  - badge
  - anchor
  - kbd
  - lists
  - loading
  - progress
  - badge-legend
  - group-blocks
  - callout
  - callout-content
  - code
  - code-titles
  - {c: filetree, name: filetree}
  - {c: quote, name: quote}
  - group-media
  - embed
  - figure
  - {c: gallery, name: gallery}
  - {c: widget, name: widget, widget: x-counter, props: {start: 3, label: 세기}}
  - group-data
  - {c: chart, name: chart, type: bar}
  - filter
  - {c: params, name: params}
  - table
  - group-disclosure
  - {c: accordion, name: accordion}
  - {c: details, name: details}
  - {c: faq, name: faq}
  - {c: steps, name: steps}
  - {c: steps, name: steps-headings}
  - {c: tabs, name: tabs}
  - {c: timeline, name: timeline}
  - {c: timeline, name: timeline-list}
  - group-sections
  - {c: cta, name: buttons}
  - {c: features, name: cards, cols: 2, badge: bottom}
  - {c: features, name: cards-3, cols: 3, reveal: true}
  - {c: features, name: cards-4, cols: 4}
  - {c: install, name: install}
  - {c: linkcards, name: linkcards}
  - {c: pricing, name: pricing, recommended: 2}
  - {c: split, name: split, visual: split-demo, decor: decor-demo, tag: "일러스트", side: start, ratio: "5:7", label: "제목, 텍스트 두 줄, 버튼이 있는 화면"}
  - {c: subscribe, name: subscribe, bleed: true}
  - group-chrome
  - breadcrumb-toc
  - icons
  - language-switcher
  - nav
  - posts
  - pagination
  - search
  - theme-toggle
---
# 컴포넌트

모든 컴포넌트는 평범한 Markdown입니다. 아래 예시마다 Markdown 소스와, 같은 소스로 테마가 그려 낸 실제 결과를 이어서 보여 줍니다. 결과는 지금 쓰는 라이트·다크 모드 그대로입니다. 소스 블록을 복사해 붙이면 같은 결과를 얻습니다. github.com에서는 기본 요소로 보입니다.

컴포넌트는 텍스트와 인라인부터 사이트 공통 요소까지 용도별로 묶고, 묶음 안에서는 영어 제목의 A-Z 순서로 놓습니다. 어느 언어에서나 영어 페이지와 순서가 같습니다.

[키친싱크 열기](kitchen-sink/) [설정](../guides/configuration/)

> [!NOTE]
> 이 페이지는 [영어 원문](../../components/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 텍스트와 인라인

본문 텍스트와 문단 안의 짧은 표시에 쓰는 스타일입니다.

## 배지

`status:available` 정해진 접두어가 붙은 코드 스팬이 배지가 됩니다. status(available, partial, planned)와 tag가 있습니다. 상태 배지는 이름 앞에 색 점을 표시합니다. 점은 CSS로 그리므로 스크린 리더는 이름만 읽고, 강제 색상 모드에서도 보입니다.

`status:available` `status:partial` `status:planned`

`tag:beta`

## 제목 앵커

`status:available` `modootoday.heading_anchors: true`면 문서와 글의 `##`, `###` 제목마다 끝에 그 제목 자신을 가리키는 링크가 붙어, 읽는 사람이 한 섹션의 주소를 복사할 수 있습니다. 포인터를 제목에 올리거나 키보드 포커스가 링크에 오면 보이고, 터치 화면에서는 늘 보입니다. 이 페이지의 제목에 포인터를 올려 확인해 보세요. 컴포넌트 섹션의 제목은 원래 동작을 유지하며, 스크립트는 쓰지 않습니다.

```yaml
modootoday:
  heading_anchors: true
```

## 키보드 키

`status:available` kbd와 콜론으로 시작하는 코드 스팬이 키보드 키가 됩니다. 키는 공백 없이 `+`로 잇습니다.

`kbd:Ctrl+K`를 누르거나 `kbd:/`를 누르면 검색이 열립니다.

## 목록

`status:available` `_config.yml`에 `modootoday.lists`를 두면 일반 섹션과 페이지에 목록 스타일 두 가지가 적용됩니다. `link_chips: true`는 모든 항목이 링크 하나뿐인 목록을 칩 한 줄로 바꾸고, `titled_items: true`는 굵은 제목과 콜론으로 시작하는 항목에 제목과 구분자를 따로 줍니다. `hero: {checks: true}`는 위처럼 히어로의 첫 목록을 체크 표시 줄로 바꿉니다. 컴포넌트 섹션의 목록은 원래 스타일을 유지합니다.

- [설치](../guides/install/)
- [설정](../guides/configuration/)
- [접근성](../guides/accessibility/)

제목이 있는 항목:

- **칩**: 링크만 있는 목록
- **제목 항목**: 굵은 제목, 콜론, 그다음 텍스트

## 로딩과 스켈레톤

`status:available` loading 또는 skeleton과 콜론으로 시작하는 코드 스팬은 스피너, 얇은 상단 막대, 자리 표시자(text, card, image, avatar, row)가 됩니다. 모두 `role="status"`와 스크린 리더용 로딩 레이블이 붙고, 사용자가 동작 줄이기를 켜면 움직이지 않습니다. 스타일은 별도 스타일시트에 있어 이 요소를 쓰는 페이지만 불러옵니다.

`loading:spinner`

`skeleton:avatar`
`skeleton:text`
`skeleton:card`

## 진행률

`status:available` progress와 콜론 뒤에 0부터 100까지의 정수가 오는 코드 스팬은 값을 텍스트로 함께 보여 주는 레이블 있는 진행률 막대가 됩니다.

번역 `progress:60`

## 상태 범례

| 배지 | 의미 |
|---|---|
| `status:available` | 출시되어 안정적 |
| `status:partial` | 알려진 한계가 있음 |
| `status:planned` | 로드맵에 있음 |

## 블록

문단 사이에 단독으로 놓이는 블록입니다.

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

## 코드 블록

`status:available` 펜스 코드 블록은 구문 강조가 되고, 블록 위쪽 끝(`file:` 제목이 있으면 제목 줄)에 아이콘 복사 버튼이 붙습니다. 코드가 클립보드에 복사되면 스크린 리더에 "복사됨"을 알립니다. 긴 줄은 스크롤되고 키보드로도 블록에 갈 수 있습니다.

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

## 파일 트리

`status:available` `c: filetree` 섹션에서는 중첩 목록이 폴더 트리로 그려집니다. 하위 목록이 있는 항목은 폴더입니다.

- docs
  - _config.yml
  - index.md
  - ko
    - index.md

## 인용

`status:available` `c: quote` 섹션에서는 마지막 줄이 줄표(—)로 시작하는 인용문의 그 줄이 출처가 됩니다.

> 문서가 github.com에서도 사이트에서도 잘 읽힙니다.
>
> — 테마 사용자

## 미디어

이미지, 그림, 다이어그램, 임베드 프레임, 위젯입니다.

## 임베드

`status:available` embed와 콜론, https URL, 선택 제목으로 된 코드 스팬만 있는 문단은 지연 로드되는 16:9 프레임이 되며, 로드되는 동안에도 자리를 유지합니다.

`embed:https://modootoday.github.io/jekyll-theme-modootoday/assets/images/sample.svg 샘플 페이지 그림`

## 그림

`status:available` 이미지만 있는 문단 뒤에 *강조*만 있는 문단이 오면 캡션이 붙은 그림이 됩니다. 대체 텍스트는 필수입니다.

![왼쪽 Markdown 소스가 오른쪽에서 스타일이 적용된 페이지로 바뀌는 모습](../../assets/images/sample.svg)

*왼쪽은 Markdown, 오른쪽은 렌더링된 페이지입니다.*

## 갤러리

`status:available` `c: gallery` 섹션에서는 이미지 목록이 썸네일 격자가 됩니다. 각 썸네일은 JavaScript 없이 원본 크기 보기를 엽니다. 모든 이미지에 대체 텍스트가 필요합니다.

- ![화분과 안락의자가 있는 햇살 드는 방](../../assets/images/gallery/room.webp)
- ![낮은 해 아래 분홍빛 모래 언덕](../../assets/images/gallery/dunes.webp)
- ![잔잔한 연못을 둘러싼 열대 잎](../../assets/images/gallery/leaves.webp)
- ![산속 호수의 나무 선착장](../../assets/images/news/travel-sm.webp)
- ![초록 언덕 위의 풍력 발전기와 태양광 패널](../../assets/images/news/energy-sm.webp)
- ![크림, 보라, 코랄 색 견본을 부채꼴로 펼친 모습](../../assets/images/projects/brand.webp)

## 위젯

`status:available` `c: widget` 섹션에서는 `widget:`이 가리키는 custom element(`modootoday.scripts`에 `element:`로 등록)가 제목 뒤에 오고, `props`는 `data-props`에 JSON으로 들어갑니다. 섹션 텍스트는 요소가 실행되기 전까지 보이는 대체 텍스트이고, 사이트의 모듈은 그 요소가 있는 페이지에서만 불러옵니다.

3부터 세는 카운터입니다. JavaScript가 없으면 이 문장이 대신 보입니다.

## 데이터

표와 차트, 그리고 이를 읽기 쉽게 돕는 도구입니다.

## 차트

`status:available` `c: chart` 섹션에서, 또는 `modootoday.chart.enabled`를 켰을 때 `chart:bar`만 있는 줄 뒤에서 표는 차트 figure가 됩니다. 표는 차트의 텍스트로 남습니다. `modootoday.chart.src`가 있으면 사이트의 Chart.js가 차트를 그리고 표는 그 아래로 접히며, 없으면 독자는 표를 봅니다. 표 뒤의 강조만 있는 줄은 캡션이 됩니다.

| 분기 | 문서 | 블로그 |
|---|---|---|
| 1분기 | 4,160 | 2,030 |
| 2분기 | 5,270 | 2,770 |
| 3분기 | 5,910 | 3,120 |

*분기별 방문 수*

## 필터

`status:available` `sections:` 항목에 `filter: true`를 쓰면 그 섹션의 첫 목록이나 표 위에 검색 필드가 생깁니다. 입력한 단어가 모두 들어 있는 항목만 남고, 몇 개가 보이는지 알려 줍니다. `filter: {facet: 2}`는 표의 두 번째 열 값마다 버튼도 추가합니다. `sections:`가 없는 페이지는 front matter에 `filter:`를, 디렉터리 페이지는 `filter_text: true`를 쓰세요. JavaScript가 없으면 모든 항목이 보입니다. [필터 데모](../layouts/demo/filter/)와 [검색 레시피](../recipes/search/)를 보세요.

## 매개변수 표

`status:available` `c: params` 섹션에서는 표가 옵션을 이름, 유형, 기본값, 설명으로 나열합니다. `required`만 있는 셀은 필수 배지로 표시됩니다.

| 이름 | 유형 | 기본값 | 설명 |
|---|---|---|---|
| `title` | 문자열 | `required` | 페이지 제목 |
| `cols` | 숫자 | 2 | 카드 열 수 |

## 표

`status:available` 모든 표는 테마가 페이지를 렌더링할 때 씌우는 스크롤 상자(`div.mt-table`) 안에 들어갑니다. 2~3열 표는 칸 안에서 줄을 바꾸되, 열마다 최소 5rem(마지막 열은 9rem)을 지키고 그보다 좁으면 상자가 스크롤됩니다. 40rem 이상에서는 열보다 긴 단어나 코드만 중간에서 끊깁니다. 4열 이상인 표는 열마다 9rem 정도까지 넓어진 뒤 스크롤되고, 첫 열은 화면에 남습니다. 첫 열의 코드와 오른쪽·가운데 정렬 칸은 줄을 바꾸지 않으며, 가장자리의 그림자와, 스크롤 기반 애니메이션을 지원하는 브라우저에서는 그쪽 내용이 흐려지는 효과가 더 스크롤할 내용이 있음을 알려 줍니다.

40rem보다 좁은 화면에서 `c: params` 표는 행마다 블록이 되고, 칸마다 열 이름이 레이블로 붙습니다. 다른 표도 들어가지 않으면 같은 방식으로 쌓입니다. 두세 열이면 스크롤해야 할 때, 네 열 이상이면 여섯 줄이 넘는 칸이 있을 때입니다. 그래서 페이지에는 좁은 화면을 위한 표시가 필요 없습니다.

세 클래스는 사이트가 페이지 본문 밖, 직접 만든 레이아웃이나 include에 쓰는 표를 위한 훅입니다.

```text
table.mt-table--stack  40rem 미만에서 행이 레이블 붙은 블록이 됨
table.mt-table--dl     2열 표: 40rem 미만에서 키 아래에 값
table.mt-table--fixed  같은 너비의 열, 어디서든 줄바꿈(비교표용)
```

페이지 본문에서는 붙일 수 없습니다. kramdown 속성 목록(`{: .mt-table--stack}`)은 kramdown 전용이라 GitHub은 글자 그대로 보여 주고, `modootoday-check`가 이를 알립니다. 쌓이는 형태는 JavaScript가 필요하며, 없으면 표가 스크롤됩니다. `mt-table--fixed`를 붙인 표는 쌓이지 않습니다.

| 키 | 기본값 | 설명 |
|---|---|---|
| `color_scheme` | `auto` | 운영체제 설정을 따르거나 라이트·다크 중 하나로 고정 |
| `badges` | `true` | 상태 코드 스팬을 배지로 바꿈 |

## 펼침과 순서

필요할 때 펼치거나 순서대로 읽는 내용입니다.

## 아코디언

`status:available` `c: accordion` 섹션에서 `###` 제목이 아래 내용을 펼치고 접는 버튼(`aria-expanded`)이 됩니다. Enter나 Space로 전환합니다. JavaScript가 없으면 모든 답이 보입니다.

### JavaScript 없이도 동작하나요?

네. 모든 답이 질문 아래에 펼쳐진 채로 보입니다.

### 답에 코드를 넣을 수 있나요?

```sh
bundle exec jekyll serve
```

## 세부 정보

`status:available` `c: details` 섹션에서는 각 `###` 제목이 브라우저 기본 펼침 요소가 됩니다. JavaScript 없이 열고 닫힙니다.

### 무엇이 필요한가요?

브라우저만 있으면 됩니다.

## 자주 묻는 질문

`status:available` `c: faq` 섹션은 세부 정보처럼 동작합니다. 이 페이지처럼 `schema: {faq: auto}`를 켜면 질문과 답이 페이지의 FAQPage 구조화 데이터도 됩니다([구조화 데이터](../guides/structured-data/) 참고).

### 테마는 무료인가요?

네, MIT 라이선스입니다.

### GitHub Pages에서 동작하나요?

네, github-pages gem으로 동작합니다.

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

## 페이지 섹션

`sections:` 항목과 히어로로 랜딩 페이지를 구성하는 띠 영역입니다.

## 버튼

`status:available` 링크만 있는 문단이 버튼이 되고, 첫 링크가 주 버튼입니다. 히어로(첫 `##` 앞)와 `c: cta` 섹션에서 동작합니다.

[시작하기](../guides/install/) [설정 읽기](../guides/configuration/)

## 카드

`status:available` `c: features` 섹션에서 **굵은 글씨**로 시작하는 목록 항목이 카드가 됩니다. 굵은 글씨가 카드 제목이 되고, 바로 뒤의 구분자 하나(` — `, `: `, 전각 `：`)는 표시하지 않습니다. 본문 뒤쪽의 콜론은 그대로 둡니다. `cols: 2`, `cols: 3`, `cols: 4`로 열 수를 정하며, 기준은 화면이 아니라 섹션의 폭입니다. 카드마다 16rem 이상을 지킬 수 있을 때만 열이 늘어납니다. 33rem 미만에서는 한 열, 33rem부터 두 열, `cols: 3`은 50rem부터 세 열, `cols: 4`는 67rem부터 네 열입니다. 두 열일 때 `cols: 3`의 홀수 번째 마지막 카드는 한 줄을 다 씁니다. 그래서 이 페이지 같은 본문 열에서 `cols: 3`은 카드 두 장과 한 줄짜리 카드 한 장으로, `cols: 4`는 2×2로 보이고, 넓은 화면의 문서 홈처럼 더 넓은 섹션에서는 `cols: 3`이 세 열로 보입니다.

- **평범한 Markdown** — github.com에서도 잘 읽힙니다.
- **배지 포함** — 카드에 상태를 표시할 수 있습니다. `status:available`

`badge: bottom`을 쓰면 항목 끝의 상태 배지가 카드 아래쪽에 놓여, 한 줄의 배지가 가지런히 정렬됩니다.

## 3열 카드

같은 목록을 `cols: 3`으로 쓴 예입니다. `reveal: true`를 쓰면 섹션이 화면에 들어올 때 서서히 나타납니다. 스크롤 기반 애니메이션을 지원하는 브라우저에서 사용자가 움직임을 허용한 경우에만 동작하며, 그 밖의 환경에서는 그대로 보입니다. 스크립트는 쓰지 않습니다.

- **알림** — 알림 다섯 종류.
- **탭** — 접근성을 갖춘 코드 탭.
- **검색** — 클라이언트 검색.

## 4열 카드

`cols: 4`로 쓴 예입니다. 이 본문 열에서는 2×2로, 폭이 67rem 이상인 섹션에서는 네 열로 보입니다.

- **알림** — 다섯 가지 알림 유형.
- **탭** — 접근성을 갖춘 코드 탭.
- **검색** — 클라이언트 쪽 검색.
- **카드** — 두 열에서 네 열까지의 그리드.

## 설치

`status:available` `c: install` 섹션은 본문, 설치 버튼, 안내 문장을 출력합니다. 버튼은 브라우저가 사이트 설치를 제안할 때까지 숨겨져 있고, 누를 때만 브라우저의 설치 대화상자를 엽니다. 안내 문장은 메뉴나 공유 메뉴에서 설치하는 브라우저를 위한 것입니다. 설치된 앱 안에서는 섹션이 숨겨집니다. `modootoday.pwa.enabled: true`가 필요하며 이 사이트는 켜져 있습니다. Chrome과 Edge에서는 여기에 버튼이 나타나고, 다른 브라우저에서는 안내 문장이 보입니다. [설치할 수 있는 사이트](../recipes/pwa/#설치하기)를 참고하세요.

이 문서를 홈 화면에 두고 오프라인에서도 읽을 수 있습니다.

## 링크 카드

`status:available` `c: linkcards` 섹션에서는 링크로 시작하는 목록 항목이 카드가 됩니다. 카드 전체가 링크 대상입니다.

- [설치](../guides/install/) — 사이트에 테마를 추가합니다.
- [설정](../guides/configuration/) — 모든 설정을 한곳에서 봅니다.

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

## 분할

`status:available` `c: split` 섹션은 48rem 이상에서 텍스트와 그림을 나란히 놓고, 그보다 좁으면 위아래로 쌓습니다. 그림은 `visual:` include입니다. `side: start`는 그림을 시작 쪽으로 옮기고, `ratio: "5:7"`은 그림에 넓은 열을 줍니다. 여기의 `label:`처럼 항목의 다른 키는 include에서 `include.section.label`로 받습니다. 이 그림은 일러스트입니다. `class="mt-illustration"`, `role="img"`, `aria-label`이 있는 `figure`이고, `.mt-illustration-tag` 배지의 글자도 레이블에 들어 있습니다. `decor: decor-demo`는 위쪽 모서리의 점을 `aria-hidden` 장식으로 더합니다. 히어로도 같은 형태를 쓸 수 있습니다. `hero: {c: split, visual: <이름>, side: start, ratio: "5:7"}`는 제목, 리드 문단, 체크 행, 버튼을 텍스트 열에 두고 include를 그 옆에 놓습니다.

`c: split` 섹션이나 분할 히어로의 `visual: code`는 include가 필요 없습니다. 그 섹션의 첫 코드 블록(`file:` 제목이 있으면 제목 포함)이 그림 열로 옮겨지고, 코드 스타일과 복사 버튼은 그대로입니다. `chrome: terminal`(사용하는 페이지에만 연결되는 작은 시트)은 테두리와 장식용 막대를 더하며, 스크린 리더는 이 막대를 건너뜁니다. 다른 곳에서 `visual: code`는 계속 `_includes/sections/code.html`을 뜻합니다.

한쪽에는 텍스트, 다른 쪽에는 그림이 옵니다.

## 구독

`status:available` `c: subscribe` 섹션은 텍스트와 `modootoday.subscribe.action`의 주소로 전송하는 이메일 양식을 표시합니다. 이 설정이 없으면 텍스트만 표시합니다. 여기서는 항목에 `bleed: true`도 있습니다. 모든 섹션 항목과 `hero:`에 쓸 수 있으며, 내용은 읽기 폭을 유지한 채 `--mt-bleed-bg`(기본값은 muted 표면색) 배경 띠가 화면 전체 폭으로 깔립니다. `bleed: wide`는 내용 폭도 컨테이너 폭까지 넓힙니다. 사이드바나 목차가 있는 페이지에서는 띠가 본문 열 안에 머뭅니다.

릴리스가 나오면 이메일을 한 통 받으세요.

## 사이트 공통 요소

모든 페이지가 함께 쓰는 부분으로, 페이지에 Markdown을 쓰지 않아도 레이아웃이 추가합니다.

## 이동 경로와 목차

`status:available` 문서 페이지에는 URL로 만든 이동 경로와, `##`·`###` 제목으로 만든 목차가 붙습니다. 목차는 넓은 화면에서 옆에, 좁은 화면에서는 접는 상자로 보입니다. 레이아웃이 붙이므로 따로 쓸 소스는 없습니다. 끄려면 `components`에서 `breadcrumb`이나 `toc`를 빼거나, 한 페이지에서만 `toc: false`를 쓰세요. 사이드바가 있는 페이지라면 80rem부터 본문 열이 목차 열의 자리까지 넓어집니다. 홈 페이지가 그렇습니다. JavaScript가 있으면 스크롤하는 동안 목차가 읽고 있는 섹션을 표시하고, 없으면 평범한 링크 목록입니다. 이 표시만 따로 끄는 설정은 없습니다. 표시는 목차와 함께 오므로, `components`에서 `toc`를 빼거나 `toc: false`를 쓰면 표시용 작은 스크립트도 빠집니다. 이 페이지 위쪽과 옆이 그 결과입니다.

```yaml
modootoday:
  components: [callout, badge, hero, cta, card, tabs, code-copy, nav, pagination, theme-toggle]
```

## 아이콘과 로고

`status:available` 테마의 아이콘(지구본, 해와 달, 검색, 알림 종류, 복사, 편집, 이전·다음, 외부 링크, 이동 경로 화살표)은 `currentColor`를 쓰는 인라인 SVG라서 라이트·다크 모드를 따르고 추가 요청이 없습니다. 아이콘은 스크린 리더에서 숨기고, 아이콘만 있는 버튼에는 따로 이름을 붙입니다. 방향을 가리키는 화살표는 오른쪽에서 왼쪽으로 쓰는 페이지에서 뒤집힙니다. `logo`를 정하면 사이트 제목 앞에 modootoday 마크(또는 직접 만든 이미지)가 나오고, `favicon`을 정하면 같은 모양의 브라우저 아이콘이 붙습니다. 이 페이지의 헤더와 푸터가 그 결과입니다.

```yaml
modootoday:
  logo: brand        # brand | /assets/img/logo.svg
  favicon: brand     # brand | /favicon.ico
```

## 언어 선택기

`status:available` `languages:`와 `language_switcher: header`를 설정하면 헤더에 언어 목록을 여는 지구본 버튼이 생깁니다. 언어가 늘어도 폭은 그대로입니다. 언어 이름은 각 언어로 적고, 현재 언어에는 `aria-current`가 붙습니다. 목록은 Esc로 닫습니다. 이 페이지 헤더의 지구본이 그 결과입니다.

```yaml
modootoday:
  languages: [en, ko, ja]
  language_switcher: header
```

## 내비게이션

`status:available` 헤더 메뉴는 `_data/nav/main.yml`에서 옵니다. `items:`가 있는 항목은 넓은 화면에서 드롭다운 묶음이 되고, 좁은 화면에서는 메뉴 버튼이 생깁니다. 열린 메뉴는 Esc로 닫습니다. 이 페이지의 헤더가 그 결과입니다.

```yaml
- {title: Install, url: /install/}
- {title: Components, url: /components/}
- title: More
  items:
    - {title: Public API, url: /api/}
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

## 이전·다음

`status:available` 내비게이션에 있는 페이지에는 내비게이션 순서대로 이전·다음 링크가 붙습니다. 숨기려면 front matter에 `pagination: false`를 쓰세요. 이 페이지 아래쪽이 그 결과입니다.

```yaml
---
title: Components
pagination: false
---
```

## 검색

`status:available` `search.json` 파일로 동작하는 클라이언트 검색이 헤더에 들어갑니다(`role="search"`). `kbd:Ctrl+K`나 `kbd:/`로 검색창에 갈 수 있습니다. 사이트 루트에 `search.json`을 두면 켜집니다. [이 사이트가 쓰는 파일](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/search.json)을 복사해 쓰세요. 이 페이지 헤더의 검색창이 그 결과입니다.

## 테마 전환

`status:available` 헤더 버튼으로 라이트와 다크를 바꾸고, 고른 값을 기억합니다. 한 모드로 고정하려면 `color_scheme`을 쓰세요. 이 페이지 헤더의 버튼이 그 결과입니다.

```yaml
modootoday:
  color_scheme: auto   # auto | light | dark
```
