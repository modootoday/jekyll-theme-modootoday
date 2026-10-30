---
nav_order: 10
title: 공개 API
description: 이 테마가 사이트용으로 문서화한 이름, 클래스, 파일.
---
# 공개 API

> [!NOTE]
> 이 페이지는 [영어 원문](../../../reference/api/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

공개 API는 이 페이지에 정리되어 있고, 변경 사항은 `CHANGELOG.md`에 기록됩니다. 목록에 없는 것(내부 include, Sass 파셜 경로, 비공개 `--mt-p-*` 기본 토큰, 규칙에 없는 HTML 세부)은 어느 릴리스에서든 바뀔 수 있습니다.

## 안정 이름

| 영역 | 안정 이름 |
|---|---|
| 설정 | [설정](../../guides/configuration/)에 나온 `modootoday:` 아래 모든 키 |
| 디자인 토큰 | 시맨틱·컴포넌트 사용자 속성 `--mt-*` (기본 토큰 `--mt-p-*` 제외). 생성되는 `tokens.json`도 같음 |
| Markdown 규칙 | `RULES.md`의 패턴과 출력 클래스 `mt-*` |
| 레이아웃 | `default`, `doc`, `post`, `archive`, `twin`, `llms`, `llms-full` |
| 덮어써도 되는 include | `head-custom.html`, `footer-custom.html`; 직접 만든 푸터에서 `modootoday/lang-switch.html`과 `modootoday/brand/logo.html`(`size` 지정 가능)을 include할 수 있음; 직접 그린 로고를 쓰려면 `modootoday/brand/logo.html`을 덮어쓰기 |
| 직접 만드는 include | `_includes/sections/<name>.html`. `visual: <name>`을 쓴 섹션이나 히어로 끝에 렌더링됨 ([사용자 정의](../../guides/customize/#섹션-비주얼과-전체-폭-페이지) 참고) |
| 호출해도 되는 include | `modootoday/archive.html`(`by`, `lang`); `modootoday/brand/icon.html`(`name`: globe, sun, moon, search, menu, copy, check, external, prev, next, chevron-right, chevron-down, note, tip, important, warning, caution, edit, rss, tag, folder, brand. 선택: `size`(px, 기본 18), `label`(주면 그 이름의 `role="img"`, 없으면 `aria-hidden`), `class`). 출력은 `currentColor`를 쓰는 `svg.mt-icon.mt-icon-<name>`이고, 방향 아이콘은 `.mt-icon-flip`이 붙어 RTL에서 뒤집힘 |
| include | `modootoday/t.html`(`key=`, 선택 `n=` / `name=`)은 페이지 언어의 테마 문구를 출력합니다 |
| 데이터 파일 | `_data/i18n/<lang>.yml` 키(내장 카탈로그를 덮어쓸 때만), `_data/nav/<name>.yml`, `_data/components.yml` |
| 검사기 | `modootoday-check` 옵션, 종료 코드 0(문제 없음)과 1(문제 또는 잘못된 사용법) |

## Markdown 규칙

`md-components v1`은 `RULES.md`에 있는 Markdown 규칙 표준의 이름이며, CSS 접두사가 아닙니다. 출력 클래스는 `mt-*`를 씁니다.

## 컴포넌트 구조

지금 사이트 CSS에서 대상으로 삼을 수 있는 마크업입니다. 이 표의 클래스와 속성은 공개 API에 속합니다. 표에 없는 내부 요소(래퍼, 생성된 id, 자식 요소의 순서)는 안정적이지 않습니다. 각 컴포넌트가 쓰는 Markdown 부분은 [슬롯 계약](#슬롯-계약)에 정리되어 있습니다.

| 컴포넌트 | 루트 | 스타일을 줄 수 있는 부분 | 상태와 변형 |
|---|---|---|---|
| 페이지 틀 | `body.mt-body` | `a.mt-skip`, `header.mt-header` > `.mt-header-inner` (`.mt-site-title`, `nav.mt-nav`, `.mt-search`, `details.mt-lang.mt-menu` (`summary` globe button, `ul` of `a[lang][hreflang]`, current one `aria-current`), `.mt-theme-toggle`), `main.mt-main`, `footer.mt-footer` > `.mt-footer-inner` | `html[data-theme=light\|dark]` (고정 색 구성 또는 토글이 설정) |
| 문서 페이지 | `article.mt-doc` | `.mt-doc-layout` > `.mt-doc-main`, `.mt-doc-aside`(`nav.mt-toc` 포함), `nav.mt-toc-mobile`, `nav.mt-breadcrumb`, `.mt-page-meta`, `nav.mt-pagination` | — |
| 문서 사이드바 | `aside.mt-doc-nav` > `nav.mt-sidebar`(64rem 이상), `details.mt-sidebar-mobile`(그보다 좁을 때) | `.mt-sidebar-group`, `.mt-sidebar-title`, 링크 `ul`. 현재 링크는 `aria-current=page` | `.mt-doc-layout.mt-has-sidebar`, 모바일 메뉴의 `[open]` |
| 페이지 도구 | `details.mt-menu.mt-page-actions` | `summary`, `button[data-mt-act=copy\|ai]`(JS가 돌기 전엔 숨김)와 Markdown 보기 `a[type="text/markdown"]`가 든 `ul` | `[open]` |
| 히어로 | `section.mt-hero` | `h1`, 리드 `p`, 링크만 있는 `p`(CTA 버튼, 첫 링크가 주 버튼) | — |
| 섹션 | `section.mt-section` | `h2`와 그 내용 | `[data-section]` = 이름, `[data-c]`와 `.mt-c-<c>` = 컴포넌트, `.mt-cols-<n>`, `.mt-cta`(섹션 안에 `[data-mt-result]` 요소가 있으면 그 요소에) |
| 본문(`sections:` 없음) | `div.mt-prose` | 렌더된 본문 | — |
| 카드 그리드 | `section.mt-section` | `ul > li`, 맨 앞 `strong`이 제목 | `.mt-cols-2`, `.mt-cols-3` (`c: features`) |
| 탭 | `section.mt-c-tabs[data-tabs]` | `[role=tablist]`, `[role=tab]`, `[role=tabpanel]`(JS가 만듦, JS 없으면 `h3`와 코드 블록 유지) | `[aria-selected]` |
| 아코디언 | `section.mt-c-accordion` | `h3 > button[aria-expanded]`, 그 뒤 패널 | `[aria-expanded=true\|false]` |
| 단계 / 타임라인 | `section.mt-c-steps`, `section.mt-c-timeline` | `ol > li` 또는 `h3` 항목 | — |
| 파일 트리 | `section.mt-c-filetree` | `ul[aria-label]`, 중첩 `ul`(하위 목록이 있는 항목은 폴더) | — |
| 세부 정보 / FAQ | `section.mt-c-details`, `section.mt-c-faq` | `details.mt-details`, `summary > h3`, 그 뒤의 내용 | `[open]` |
| 매개변수 표 | `section.mt-c-params` | `th[scope=col]`, `.mt-param-required` | — |
| 링크 카드 | `section.mt-c-linkcards` | `ul > li > a`(카드 전체가 링크 대상) | — |
| 인용 | `figure.mt-quote` | `blockquote`, `figcaption` | — |
| 갤러리 | `section.mt-c-gallery` | `a.mt-gallery-thumb`, `a.mt-lightbox`, `.mt-lightbox-close` | 열린 라이트박스의 `:target` |
| 요금제 | `.mt-plans` | `.mt-plan`, 그 `h3`, 링크만 있는 `p.mt-actions` | `.mt-plan-recommended`와 `.mt-plan-flag` |
| 구독 | `section.mt-c-subscribe` | `form.mt-subscribe`(action 설정 시), `label`, `input[type=email]`, `button` | — |
| 인라인 추가 요소 | `div.mt-code`, `span.mt-progress`, `div.mt-embed` | `.mt-code-title`, `progress`, `iframe` | — |
| 로딩(선택 시트) | `.mt-spinner`, `.mt-topbar`, `.mt-skeleton` | `.mt-skeleton-text`, `-card`, `-image`, `-avatar`, `-row`; `.mt-ratio-16x9`, `-4x3`, `-1x1` | `[aria-busy=true]`, `[role=status]` |
| 배너 | `div.mt-banner` | 그 `p`와 링크; `a.mt-back-to-top` | — |
| 알림 | `blockquote.mt-callout[role=note]` | `p.mt-callout-title`, 본문 | `.mt-callout-<type>`, `[data-variant]` = note, tip, important, warning, caution |
| 배지 | `span.mt-badge` | 기호(`aria-hidden`), 레이블 | `.mt-badge-<status>`, `.mt-badge-tag`, `[data-variant]` |
| 키보드 키 | `kbd.mt-kbd` | 키마다 `kbd` | — |
| 그림 | `figure.mt-figure` | `img`, `figcaption` | — |
| 글 머리 | `header.mt-post-header` | `h1.mt-post-title`, `.mt-post-deck`, `.mt-byline`(`.mt-byline-authors` > `.mt-post-author`, `.mt-byline-dates` > `time`), `figure.mt-post-cover`, `nav.mt-series`, `p.mt-post-meta`(태그 배지) | `[data-part]` = header, deck, byline, authors, dates, cover, terms |
| 글 끝 | `article.mt-doc` | `.mt-share` 버튼, `nav.mt-post-nav`, `section.mt-related`, `.mt-news-correction`, `.mt-news-sources` | `[data-part]` = share, post-nav, related, sources |
| 글 카드 | `article.mt-card-post` | `.mt-card-post-cover`, `.mt-card-post-meta`, `.mt-card-post-title`, `.mt-card-post-excerpt` | `.mt-card-post-featured`, `[data-kind=news]`, `.mt-post-list[data-variant=list\|grid\|magazine]` |
| 뉴스 첫 화면 | `div.mt-news-top` | `.mt-news-lead`, `.mt-news-secondary`, `section.mt-news-latest`, `section.mt-news-section` | `[data-category]`, `.mt-badge[data-variant=breaking\|live]` |
| 검색 | `div.mt-search[role=search]` | 입력란, `.mt-search-results` | — |

## 슬롯 계약

슬롯은 섹션 Markdown 안의 이름 붙은 부분입니다. 슬롯 이름은 위 정책에 따라 안정적이며, 선언해도 생성되는 마크업은 바뀌지 않습니다. `_data/components.yml`에서 `slots:`가 있는 `c:`를 쓰는 섹션마다 `modootoday-check`가 슬롯 개수를 세고, 선언한 범위를 벗어나면 실패합니다.

| 슬롯 | 섹션(`##` 제목 뒤)에서 세는 것 | 렌더 결과 |
|---|---|---|
| `lead` | 첫 목록, `###`, 코드 블록, 인용 앞의 일반 문단 | `p` |
| `items` | 목록 항목 | `ul > li` 또는 `ol > li`(카드, 단계) |
| `panels` | `###` 제목 | 탭, 아코디언, 단계 패널 |
| `actions` | 링크만 있는 줄 | CTA 버튼(`c: cta`) |
| `code` | 펜스 코드 블록 | `pre`(탭 내용) |
| `figures` | 이미지로 시작하는 줄 | `figure.mt-figure` |

슬롯마다 `required: true`(`min: 1`과 같음), `min`, `max`를 쓸 수 있습니다(정수, `min`은 `max`보다 클 수 없음). 올바른 형태가 두 가지인 컴포넌트는 `slots:`를 대안 형태의 목록으로 쓸 수 있고, 섹션이 그중 하나를 만족하면 통과합니다. `parts:`에는 [컴포넌트 구조](#컴포넌트-구조) 표에서 그 컴포넌트가 유지하기로 약속한 셀렉터를 적습니다. 사이트에 그 표가 있는 `api.md`가 있으면 모든 파트가 표에 있어야 합니다. Nokogiri를 쓸 수 있으면(`github-pages`에는 포함) 그 컴포넌트를 쓰는 페이지의 빌드된 HTML에서 해당 컴포넌트 섹션 안에 모든 파트가 실제로 있어야 합니다. 컴포넌트 스크립트가 실행 중에 붙이는 파트(`role=`, `aria-*`)는 문서 사이트 QA가 스크립트 실행 후에 확인합니다.

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
- 테마는 수식·다이어그램 렌더러를 포함하지 않습니다. [수식과 다이어그램](../../recipes/math-diagrams/)을 보세요.

## 글과 아카이브

글은 `post` 레이아웃을 씁니다. 날짜·작성자·태그 줄, 본문, 그리고 각 카테고리와 태그를 아카이브의 해당 구역으로 잇는 하단 영역이 붙습니다. `_config.yml`에 아카이브 페이지를 지정합니다.

```yaml
modootoday:
  archive: {tags: /tags/, categories: /categories/}
```

그다음 분류 종류마다 페이지를 하나씩 만듭니다. 예를 들어 `tags.md`는 다음과 같습니다.

```yaml
---
title: 태그
layout: archive
archive: tags        # 또는 categories
---
```

이 페이지에는 본문, 글 개수가 붙은 분류 목록, 분류마다 하나의 구역(`id="tags-<slug>"`, 최신 글 먼저)이 표시됩니다. 다른 곳에 아카이브를 넣으려면 레이아웃이나 include에서 `modootoday/archive.html`을 호출하고 `by`에 `tags` 또는 `categories`를, 필요하면 `lang`을 지정합니다. 아카이브 스타일은 `modootoday-blog.css`에 있습니다. `archive`와 `post` 레이아웃은 이 파일을 불러오고, 다른 페이지에서 include를 호출할 때는 front matter에 `blog_css: true`를 넣습니다.

- 글의 언어는 `lang`(없으면 `site.lang`)입니다. 아카이브는 페이지와 같은 언어의 글만 보여 주고, `archive_lang: all`(include에서는 `lang="all"`)이면 모든 글을 보여 줍니다. `lang`이 `site.lang`과 다른 글의 하단 링크는 `/<lang>/tags/`로 이어지므로 언어 디렉터리마다 아카이브 페이지를 두세요.
- 레이블은 `_data/i18n/<lang>.yml`의 `archive.tags`, `archive.categories`, `archive.posts`, `archive.empty`에서 가져오고, 없으면 영어를 씁니다.
- 한계: 클래식 GitHub Pages는 사용자 플러그인을 실행하지 않으므로 분류마다 페이지를 만들지 않고, 분류 종류마다 한 페이지에 분류별 앵커를 둡니다. 글에는 Markdown 버전이 없고, 에이전트는 아카이브 링크로 글을 찾습니다. Jekyll은 `_posts/` 위의 폴더 이름을 `categories`에 넣으므로 글은 최상위 `_posts/`에 두고 front matter에 `lang:`을 지정하세요.
