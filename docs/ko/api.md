---
title: 공개 API
description: 이 테마가 안정적으로 유지하는 이름과, 폐기·제거 절차.
---
# 공개 API

> [!NOTE]
> 이 페이지는 [영어 원문](../../api/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

1.0부터 아래 이름은 [유의적 버전](https://semver.org/lang/ko/)을 따릅니다. 호환되지 않는 변경은 메이저 버전에서만 합니다. 목록에 없는 것(내부 인클루드, Sass 파셜 경로, 비공개 `--mt-p-*` 기본 토큰, 규칙에 없는 HTML 세부)은 어느 릴리스에서든 바뀔 수 있습니다.

## 안정 이름

| 영역 | 안정 이름 |
|---|---|
| 설정 | [설정](../configuration/)에 나온 `modootoday:` 아래 모든 키 |
| 디자인 토큰 | 시맨틱·컴포넌트 사용자 속성 `--mt-*` (기본 토큰 `--mt-p-*` 제외). 생성되는 `tokens.json`도 같음 |
| Markdown 규칙 | `RULES.md`의 패턴과 출력 클래스 `mt-*` |
| 레이아웃 | `default`, `doc`, `post`, `twin`, `llms`, `llms-full` |
| 덮어써도 되는 인클루드 | `head-custom.html`, `footer-custom.html`; 직접 만든 푸터에서 `modootoday/lang-switch.html`을 인클루드할 수 있음 |
| 데이터 파일 | `_data/i18n/<lang>.yml` 키, `_data/nav/<name>.yml`, `_data/components.yml` |
| 검사기 | `modootoday-check` 옵션, 종료 코드 0(문제 없음)과 1(문제 또는 잘못된 사용법) |

## 폐기 정책

1. 없어질 이름은 `CHANGELOG.md`와 문서에 폐기 예정으로 표시하고, 가능한 곳에서는 검사기가 경고합니다.
2. 최소 한 번의 마이너 릴리스 동안은 계속 동작합니다.
3. 제거는 다음 메이저 릴리스에서만 합니다.

이 목록은 1.0에서 동결됩니다. 1.x 릴리스는 이름을 추가할 수 있지만, 위 이름을 2.0 전에 제거하거나 호환되지 않게 바꾸지 않습니다. Markdown 규칙은 `RULES.md`의 `md-components v1`로 확정되었습니다.

> [!IMPORTANT]
> 예전 `md-*` 클래스와 `--md-*` 속성은 `mt-*`, `--mt-*`의 별칭입니다. 1.0부터 폐기 예정이며, 1.x 동안 계속 동작하고 2.0에서 제거됩니다. 사이트의 Sass, CSS, include, 레이아웃, 페이지가 이를 쓰면 `modootoday-check`가 경고합니다. [대응표](../upgrade/)를 참고하세요.

## 컴포넌트 구조 {#component-structure}

지금 사이트 CSS에서 대상으로 삼을 수 있는 마크업입니다. 이 표의 클래스와 속성은 위 정책에 따라 안정적입니다. 표에 없는 내부 요소(래퍼, 생성된 id, 자식 요소의 순서)는 안정적이지 않습니다. 각 컴포넌트가 쓰는 Markdown 부분은 [슬롯 계약](#슬롯-계약)에 정리되어 있습니다.

| 컴포넌트 | 루트 | 스타일을 줄 수 있는 부분 | 상태와 변형 |
|---|---|---|---|
| 페이지 틀 | `body.mt-body` | `a.mt-skip`, `header.mt-header` > `.mt-header-inner` (`.mt-site-title`, `nav.mt-nav`, `.mt-search`, `details.mt-lang.mt-menu` (`summary` globe button, `ul` of `a[lang][hreflang]`, current one `aria-current`), `.mt-theme-toggle`), `main.mt-main`, `footer.mt-footer` > `.mt-footer-inner` | `html[data-theme=light\|dark]` (고정 색 구성 또는 토글이 설정) |
| 문서 페이지 | `article.mt-doc` | `.mt-doc-layout` > `.mt-doc-main`, `.mt-doc-aside`(`nav.mt-toc` 포함), `nav.mt-toc-mobile`, `nav.mt-breadcrumb`, `.mt-page-meta`, `nav.mt-pagination` | — |
| 히어로 | `section.mt-hero` | `h1`, 리드 `p`, 링크만 있는 `p`(CTA 버튼, 첫 링크가 주 버튼) | — |
| 섹션 | `section.mt-section` | `h2`와 그 내용 | `[data-section]` = 이름, `[data-c]`와 `.mt-c-<c>` = 컴포넌트, `.mt-cols-<n>`, `.mt-cta` |
| 본문(`sections:` 없음) | `div.mt-prose` | 렌더된 본문 | — |
| 카드 그리드 | `section.mt-section` | `ul > li`, 맨 앞 `strong`이 제목 | `.mt-cols-2`, `.mt-cols-3` (`c: features`) |
| 탭 | `section.mt-c-tabs[data-tabs]` | `[role=tablist]`, `[role=tab]`, `[role=tabpanel]`(JS가 만듦, JS 없으면 `h3`와 코드 블록 유지) | `[aria-selected]` |
| 아코디언 | `section.mt-c-accordion` | `h3 > button[aria-expanded]`, 그 뒤 패널 | `[aria-expanded=true\|false]` |
| 단계 / 타임라인 | `section.mt-c-steps`, `section.mt-c-timeline` | `ol > li` 또는 `h3` 항목 | — |
| 알림 | `blockquote.mt-callout[role=note]` | `p.mt-callout-title`, 본문 | `.mt-callout-<type>`, `[data-variant]` = note, tip, important, warning, caution |
| 배지 | `span.mt-badge` | 기호(`aria-hidden`), 레이블 | `.mt-badge-<status>`, `.mt-badge-tag`, `.mt-badge-since`, `[data-variant]` |
| 키보드 키 | `kbd.mt-kbd` | 키마다 `kbd` | — |
| 그림 | `figure.mt-figure` | `img`, `figcaption` | — |
| 글 메타 | `p.mt-post-meta` | `time`, `.mt-post-author`, 태그 배지 | — |
| 검색 | `div.mt-search[role=search]` | 입력란, `.mt-search-results` | — |

페이지 틀, 문서, 히어로, 섹션, 본문, 알림, 배지 요소에는 2.0까지 폐기 예정인 `md-*` 클래스도 함께 붙습니다([이전과 업그레이드](../upgrade/) 참고).

## 슬롯 계약

`since:1.0` 슬롯은 섹션 Markdown 안의 이름 붙은 부분입니다. 슬롯 이름은 위 정책에 따라 안정적이며, 선언해도 생성되는 마크업은 바뀌지 않습니다. `_data/components.yml`에서 `slots:`가 있는 `c:`를 쓰는 섹션마다 `modootoday-check`가 슬롯 개수를 세고, 선언한 범위를 벗어나면 실패합니다.

| 슬롯 | 섹션(`##` 제목 뒤)에서 세는 것 | 렌더 결과 |
|---|---|---|
| `lead` | 첫 목록, `###`, 코드 블록, 인용 앞의 일반 문단 | `p` |
| `items` | 목록 항목 | `ul > li` 또는 `ol > li`(카드, 단계) |
| `panels` | `###` 제목 | 탭, 아코디언, 단계 패널 |
| `actions` | 링크만 있는 줄 | CTA 버튼(`c: cta`) |
| `code` | 펜스 코드 블록 | `pre`(탭 내용) |
| `figures` | 이미지로 시작하는 줄 | `figure.mt-figure` |

슬롯마다 `required: true`(`min: 1`과 같음), `min`, `max`를 쓸 수 있습니다(정수, `min`은 `max`보다 클 수 없음). 올바른 형태가 두 가지인 컴포넌트는 `slots:`를 대안 형태의 목록으로 쓸 수 있고, 섹션이 그중 하나를 만족하면 통과합니다. `parts:`에는 [컴포넌트 구조](#component-structure) 표에서 그 컴포넌트가 유지하기로 약속한 셀렉터를 적습니다. 사이트에 그 표가 있는 `api.md`가 있으면 모든 파트가 표에 있어야 합니다. Nokogiri를 쓸 수 있으면(`github-pages`에는 포함) 그 컴포넌트를 쓰는 페이지의 빌드된 HTML에서 해당 컴포넌트 섹션 안에 모든 파트가 실제로 있어야 합니다. 컴포넌트 스크립트가 실행 중에 붙이는 파트(`role=`, `aria-*`)는 문서 사이트 QA가 스크립트 실행 후에 확인합니다.

```yaml
features: {params: {cols: {allowed: [2, 3]}}, slots: {items: {min: 1}}, parts: [ul > li, .mt-cols-2, .mt-cols-3]}
tabs: {i18n: [tabs.label], slots: {panels: {min: 2}, code: {min: 2}}}
cta: {slots: {actions: {required: true}}, parts: [.mt-cta]}
accordion: {slots: {panels: {min: 1}}}
steps: {slots: [{items: {min: 1}}, {panels: {min: 1}}], parts: [section.mt-c-steps, ol > li]}
```

컴포넌트 항목에는 `params`, `i18n`, `slots`, `parts`만, 슬롯 규칙에는 `required`, `min`, `max`만 쓸 수 있습니다. 그 밖의 키, 알 수 없는 슬롯 이름, `max`보다 큰 `min`, 형태가 두 개 미만인 목록은 오류이며 레지스트리 기준으로 한 번만 보고합니다. `slots:`가 없는 컴포넌트는 세지 않고, 맵 하나로 쓴 `slots:`는 이전과 똑같이 동작합니다.

## 오른쪽에서 왼쪽 쓰기와 수식

- 아랍어, 페르시아어, 히브리어, 우르두어 등 RTL 언어 페이지는 `lang`에 따라 `dir="rtl"`을 받습니다. front matter의 `direction: rtl` 또는 `ltr`(또는 `_data/i18n/<lang>.yml`의 `direction:`)로 바꿀 수 있습니다. 컴포넌트는 논리 속성을 써서 좌우가 뒤집히고, 코드는 왼쪽에서 오른쪽으로 유지됩니다.
- 테마는 수식·다이어그램 렌더러를 포함하지 않습니다. [수식과 다이어그램](../math-diagrams/)을 보세요.
