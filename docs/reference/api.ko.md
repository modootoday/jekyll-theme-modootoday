---
lang: ko
permalink: /ko/reference/api/
source_rev: sha256:99f011356888
nav_order: 10
title: 공개 API
description: 이 테마가 사이트용으로 문서화한 이름, 클래스, include, 파일을 정리합니다. 이들은 메이저 버전 안에서 그대로 유지되며, 바뀌는 방식도 설명합니다.
---
# 공개 API

> [!NOTE]
> 이 페이지는 [영어 원문](../../../reference/api/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

공개 API는 이 페이지에 정리되어 있고, 변경 사항은 `CHANGELOG.md`에 기록됩니다. 목록에 없는 것(내부 include, Sass 파셜 경로, 비공개 `--mt-p-*` 기본 토큰, 규칙에 없는 HTML 세부)은 어느 릴리스에서든 바뀔 수 있습니다.

## 안정 이름

| 영역 | 안정 이름 |
|---|---|
| 설정 | [설정](../../guides/configuration/)에 나온 `modootoday:` 아래 모든 키. |
| 디자인 토큰 | `--mt-*` 사용자 속성. 기본 토큰 `--mt-p-*`는 제외. |
| Sass | 토큰 훅 `_sass/modootoday/_site.scss`와 그 덮어쓰기 맵만. [사용자 정의](../../guides/customize/#토큰-브리지) 참고. |
| Markdown 규칙 | `RULES.md`의 패턴, 그 `mt-*` 클래스, `mt-flat-list`. |
| 레이아웃 | 아래 [레이아웃](#레이아웃) 표의 모든 레이아웃. 내부용으로 표시한 하나는 API가 아닙니다. |
| 덮어써도 되는 include | `head-custom.html`, `footer-custom.html`, `modootoday/brand/logo.html`. |
| 직접 만드는 include | `visual: <name>`으로 보여 주는 `_includes/sections/<name>.html`. [사용자 정의](../../guides/customize/#섹션-비주얼과-전체-폭-페이지) 참고. |
| 모듈 도우미와 이벤트 | 사이트 `scripts`용 ES 모듈 두 개, `mt:themechange` 이벤트, `script:` 비주얼 계약. |
| 호출해도 되는 include | `modootoday/archive.html`, `modootoday/brand/icon.html`, 푸터용 include 두 개. |
| include | `modootoday/t.html`은 페이지 언어로 테마 문구를 출력합니다. |
| 데이터 파일 | `_data/i18n/<lang>.yml`, `_data/nav/<name>.yml`, `_data/navigation.yml`, `_data/authors.yml`, `_data/components.yml` |
| 검사기 | `modootoday-check` 옵션과 종료 코드. [명령줄](../cli/)에 정리되어 있습니다. |
| 정적 그림 | front matter `diagrams:`, `data-mt-src` 다이제스트 규칙, `diagram.source` 레이블. `modootoday.math.mode: static`, `_data/math/<key>.yml`, front matter `math_key:`, `math.label` 레이블. |
| 레코드 페이지 | `modootoday.records`, 레코드 front matter, 정보 목록. |
| 쇼케이스 | `modootoday.showcase`, 세션 저장소 키 `mt-showcase`, `showcase.*` 레이블. |
| 스텁 작성기 | `modootoday-stubs` 옵션([명령줄](../cli/)), 스텁 파일 이름과 front matter, 종료 코드. |

위 행의 자세한 내용:

- 디자인 토큰: 생성되는 `tokens.json`에도 같은 토큰이 들어 있습니다.
- Sass: 맵은 `$mt-overrides-base`, `$mt-overrides`, `$mt-overrides-dark`입니다. 나머지 Sass 파셜과 변수는 내부용입니다.
- Markdown 규칙: `mt-flat-list`는 그 아래 목록 항목 사이 간격을 없애는 해제용 클래스입니다.
- 레이아웃: `page`는 Jekyll과 minima가 쓰는 이름으로 부르는 `doc` 레이아웃입니다.
- include: 직접 만든 푸터에서 `modootoday/lang-switch.html`과 `modootoday/brand/logo.html`(`size` 지정 가능)을 include할 수 있습니다. 직접 그린 로고를 쓰려면 `modootoday/brand/logo.html`을 덮어쓰세요. `modootoday/archive.html`은 `by`와 `lang`을 받습니다. `modootoday/t.html`은 `key=`와 선택 `n=` / `name=`을 받습니다.
- `modootoday/brand/icon.html`은 `name`(globe, sun, moon, search, menu, copy, check, external, prev, next, chevron-right, chevron-down, note, tip, important, warning, caution, edit, link, rss, tag, folder, brand), 선택 `size`(px, 기본 18), `label`(주면 그 이름의 `role="img"`, 없으면 `aria-hidden`), `class`를 받습니다. 출력은 `currentColor`를 쓰는 `svg.mt-icon.mt-icon-<name>`이고, 방향 아이콘은 `.mt-icon-flip`이 붙어 RTL에서 뒤집힙니다.
- 모듈 도우미: `assets/js/modootoday/theme/current.js`(`currentTheme()`, 듣기를 멈추는 함수를 돌려주는 `onThemeChange(callback)`)와 `assets/js/modootoday/dom/config.js`(`readConfig(element, defaults)`)입니다. `mt:themechange` 이벤트는 [이벤트](#이벤트)를 보세요. `script:` 비주얼 계약은 `data-mt-script`, `.mt-visual-stage`, `data-mt-ready`입니다. [사용자 정의](../../guides/customize/#모듈-스크립트와-포스터) 참고.
- 데이터 파일: `_data/i18n/<lang>.yml` 키는 내장 카탈로그를 덮어쓸 때만 씁니다. `_data/navigation.yml`은 `main`을 읽습니다.
- 검사기 종료 코드: 0(문제 없음), 1(문제 또는 잘못된 사용법). `modootoday-check SRC --diagrams`는 SVG가 없거나 낡은 정적 다이어그램을 JSON(`page`, `name`, `line`, `fence`, `digest`, `files`, `reason`)으로 출력하고, 목록이 비어 있지 않으면 1로 끝납니다([다이어그램을 최신으로 유지하기](../../recipes/figures/math-diagrams/#다이어그램을-최신으로-유지하기) 참고). `modootoday-check SRC --math`는 정적 수식에 대해 같은 일을 합니다. 써야 할 `_data/math` 파일(`key`, `file`, `page`, `line`·`tex`·`digest`가 있는 `blocks`, `reason`)을 출력합니다.
- 정적 그림: `diagrams: [{name, alt, caption, width, height, min_width}]`는 페이지의 n번째 ```` ```mermaid ```` 펜스를 n번째 항목에 대응시킵니다([수식과 다이어그램](../../recipes/figures/math-diagrams/#정적-다이어그램) 참고). SVG 루트 요소의 `data-mt-src="sha256-<hex>"`는 그 SVG를 그린 펜스를 기록합니다. 값은 펜스 본문(펜스 줄 사이의 줄)의 CRLF와 CR을 LF로 바꾸고 마지막 줄바꿈을 뺀 SHA-256입니다. `data-mt-src`가 펜스의 다이제스트와 다른 SVG는 `modootoday-check`가 낡은 다이어그램(stale diagram)으로 보고합니다. `_data/i18n/<lang>.yml`의 `diagram.source`는 원본 펼침 요소의 이름입니다.
- 정적 수식: `modootoday.math.mode: static`이면 페이지의 n번째 ```` ```math ```` 펜스나 `$$` 블록이 `{src, html}` 목록인 `_data/math/<key>.yml`의 n번째 항목의 `html`로 바뀝니다([정적 수식](../../recipes/figures/math-diagrams/#정적-수식) 참고). `<key>`는 페이지의 기본 언어 원본 경로에서 확장자를 빼고 `/`를 `--`로 쓴 것입니다(front matter `math_key:`로 바꿀 수 있습니다). `src`는 구분자 사이의 TeX에 위 규칙을 적용한 블록의 다이제스트입니다. `math.label`(`수식 [n]`)이 각 블록 영역의 이름입니다.
- 레코드 페이지: `modootoday.records`([생성 페이지](../../recipes/generated-pages/) 참고), 페이지 front matter `record: <set>/<key>`와 `record_index`, 디렉터리 페이지의 `records: <set>`, 정보 목록 `dl.mt-detail-facts.mt-record-facts`.
- PWA: 레이아웃 `pages/offline`(오프라인 페이지. 보관한 페이지 목록은 `pwa/offline.js`가 채우는 `section[data-mt-offline]`), front matter `pwa: precache`, 매니페스트 링크의 `data-mt-sw`, `data-mt-scope`, `data-mt-toast-css`, `data-mt-update`, `data-mt-reload`, `data-mt-later`, `data-mt-offline-notice`, `data-mt-close` 속성, 업데이트·오프라인 알림 `div.mt-toast[role=status]`와 `.mt-toast-actions`, 캐시 이름 `mt:<baseurl>/:assets:<version>`, `mt:<baseurl>/:pages:<version>`, `mt:<baseurl>/:media`, 레이블 `pwa.offline_title`, `pwa.offline_text`, `pwa.offline_pages`, `pwa.retry`, `pwa.update`, `pwa.reload`, `pwa.later`, `pwa.offline_notice`, `pwa.close`입니다. [설치할 수 있는 사이트](../../recipes/pwa/)를 참고하세요.
- 쇼케이스: [스타터 데모 쇼케이스](../showcase/)를 참고하세요. 레이블은 `showcase.region`, `showcase.theme`, `showcase.demo`, `showcase.docs`, `showcase.docs_short`, `showcase.use`, `showcase.dismiss`, `showcase.starters.<name>`입니다. 읽는 사람이 숨기면 세션 저장소 키 `mt-showcase`에 `off`가 들어갑니다.
- 스텁 작성기: 스텁 파일은 `<name>.md.txt`, `<name>.flat.md.txt`, `<name>.html.md.txt`, 레코드 페이지 `<dir>/<key>.md`, 그리고 `--pwa`일 때 `manifest.webmanifest`(`layout: null`, `permalink: /manifest.webmanifest`, include `modootoday/pwa/manifest.json`), `sw.js`(`permalink: /sw.js`, include `modootoday/pwa/sw.js`), `offline.md`와 `offline.<lang>.md`(`layout: pages/offline`, `permalink: /offline/` 또는 `/<lang>/offline/`)입니다. 종료 코드는 0(할 일 없음, 미리보기 또는 쓰기 완료), 1(`--check`가 차이를 찾음), 2(사용법 또는 `_config.yml`), 3(데이터)입니다.

## 레이아웃

테마가 제공하는 모든 레이아웃을 front matter를 설명하는 페이지별로 나눴습니다. 이름이 `layout:` 값입니다.

| 묶음 | 레이아웃 |
|---|---|
| [레이아웃](../../layouts/) | `default`, `doc`, `page`, `post`, `archive` |
| [페이지 셸](../../layouts/shells/) | `home`, `wide`, `minimal`, `error`, `redirect`, `search` |
| [디렉터리 레이아웃](../../layouts/directory/) | `directory`, `team`, `jobs`, `events`, `sponsors`, `portfolio`, `integrations` |
| [상세 페이지](../../layouts/detail/) | `project`, `case-study`, `job`, `event`, `episode` |
| [마케팅 페이지](../../layouts/marketing/) | `feature`, `pricing`, `download`, `brand`, `links`, `contact` |
| [블로그와 뉴스](../../layouts/blog-news/) | `blog`, `news`, `news-article`, `author`, `feed` |
| [문서 확장](../../layouts/docs-extra/) | `reference`, `changelog`, `roadmap`, `glossary`, `hub`, `course`, `book` |
| [문서](../../layouts/documents/) | `legal`, `resume` |
| [AI 에이전트](../../guides/agents/) | `twin`, `llms`, `llms-full` |
| 내부용 | `detail`. 상세 페이지 레이아웃들의 바탕이니 그중 하나를 쓰세요 |

## Markdown 규칙

`md-components v1`은 `RULES.md`에 있고 [Markdown 규칙](../rules/) 페이지로 공개하는 Markdown 규칙 표준의 이름이며, CSS 접두사가 아닙니다. 출력 클래스는 `mt-*`를 씁니다.

## 컴포넌트 구조

지금 사이트 CSS에서 대상으로 삼을 수 있는 마크업입니다. 이 표의 클래스와 속성은 공개 API에 속합니다. 표에 없는 내부 요소(래퍼, 생성된 id, 자식 요소의 순서)는 안정적이지 않습니다. 각 컴포넌트가 쓰는 Markdown 부분은 [슬롯 계약](#슬롯-계약)에 정리되어 있습니다.

| 컴포넌트 | 루트 | 부분 | 상태 |
|---|---|---|---|
| 페이지 틀 | `body.mt-body` | `a.mt-skip`, `header.mt-header`, `main.mt-main`, `footer.mt-footer` > `.mt-footer-inner` | `html[data-theme=light\|dark]`, 사이드바가 있는 문서 페이지의 `body.mt-body-sidebar`(헤더, 본문, 푸터가 문서 너비를 씁니다) |
| 문서 페이지 | `article.mt-doc` | `.mt-doc-layout` > `.mt-doc-main`, `.mt-doc-aside`(`nav.mt-toc` 포함), `nav.mt-toc-mobile`, `nav.mt-breadcrumb`, `.mt-page-meta`, `.mt-page-feedback`, `nav.mt-pagination` | `.mt-toc`·`.mt-toc-mobile` 안의 `a[aria-current=location]` |
| 문서 사이드바 | `aside.mt-doc-nav` > `nav.mt-sidebar`, `details.mt-sidebar-mobile` | `.mt-sidebar-group`, `.mt-sidebar-title`, 링크 `ul` | `.mt-doc-layout.mt-has-sidebar`, 모바일 메뉴의 `[open]` |
| 페이지 도구 | `details.mt-menu.mt-page-actions` | `summary`, `button[data-mt-act=copy\|ai]`, `a[type="text/markdown"]` | `[open]` |
| 히어로 | `section.mt-hero` | `h1`, `p.mt-hero-lead`, 링크만 있는 `p`(버튼) | `.mt-hero-checks` |
| 섹션 | `section.mt-section` | `h2`와 그 내용 | `[data-section]`, `[data-c]`, `.mt-c-<c>`, `.mt-cols-<n>`, `.mt-cta` |
| 섹션 장식 | `section.mt-hero` 또는 `section.mt-section`의 `.mt-has-decor` | `.mt-section-decor[aria-hidden=true]` | — |
| 스크롤 등장 | `section.mt-hero` 또는 `section.mt-section`의 `.mt-reveal` | — | 스크롤하면 서서히 나타남 |
| 전체 폭 띠 | `section.mt-hero` 또는 `section.mt-section`의 `.mt-bleed`, `.mt-bleed-wide` | — | `--mt-bleed-bg`로 띠 색 지정 |
| 일러스트 | `figure.mt-illustration[role=img][aria-label]` | `.mt-illustration-tag` | — |
| 목록 스타일 | `ul.mt-chips`, `li > strong.mt-item-title + span.mt-item-sep` | `li > a` 칩, 제목과 구분자 | — |
| 제목 앵커 | `h2[id]`나 `h3[id]`의 마지막 자식인 `a.mt-anchor` | `svg.mt-icon-link[aria-hidden=true]` | 제목의 `:hover`, `:focus-visible`, `pointer: coarse`에서 보임 |
| 본문(`sections:` 없음) | `div.mt-prose` | 렌더된 본문 | — |
| 카드 그리드 | `section.mt-section` | `ul > li`, 맨 앞 `strong`이 제목 | `.mt-cols-2`, `.mt-cols-3`, `.mt-cols-4`, `.mt-badge-bottom` (`c: features`) |
| 탭 | `section.mt-c-tabs[data-tabs]` | `[role=tablist]`, `[role=tab]`, `[role=tabpanel]` | `[aria-selected]` |
| 아코디언 | `section.mt-c-accordion` | `h3 > button[aria-expanded]`, 그 뒤 패널 | `[aria-expanded=true\|false]` |
| 단계 / 타임라인 | `section.mt-c-steps`, `section.mt-c-timeline` | `ol > li` 또는 `h3` 항목 | — |
| 파일 트리 | `section.mt-c-filetree` | `ul[aria-label]`, 중첩 `ul`(폴더) | — |
| 세부 정보 / FAQ | `section.mt-c-details`, `section.mt-c-faq` | `details.mt-details`, `summary > h3`, 그 뒤의 내용 | `[open]` |
| 표 | `div.mt-table` | 그 안의 `table` | `table.mt-table--stack`, `table.mt-table--dl`, `table.mt-table--fixed`, `td[data-label]` |
| 매개변수 표 | `section.mt-c-params` | `th[scope=col]`, `.mt-param-required` | 좁은 화면에서 쌓임 |
| 링크 카드 | `section.mt-c-linkcards` | `ul > li > a`(카드 전체가 링크) | — |
| 인용 | `figure.mt-quote` | `blockquote`, `figcaption` | — |
| 갤러리 | `section.mt-c-gallery` | `a.mt-gallery-thumb`, `a.mt-lightbox`, `.mt-lightbox-close` | 열린 라이트박스의 `:target` |
| 요금제 | `.mt-plans` | `.mt-plan`, 그 `h3`, 링크만 있는 `p.mt-actions` | `.mt-plan-recommended`와 `.mt-plan-flag` |
| 구독 | `section.mt-c-subscribe` | `form.mt-subscribe`, `label`, `input[type=email]`, `button` | — |
| 설치 | `section.mt-c-install` | `button.mt-install`(브라우저가 설치를 제안할 때까지 `[hidden]`), `p.mt-install-hint` | 설치된 앱 안에서는 섹션에 `[hidden]` |
| 분할 | `section.mt-c-split` | `.mt-section-in` > `.mt-section-body` + `.mt-section-visual` | `.mt-split-start`, `.mt-split-5-7`, `.mt-split-code`, `.mt-split-terminal` |
| 인라인 추가 요소 | `div.mt-code`, `span.mt-progress`, `div.mt-embed` | `.mt-code-title`, `progress`, `iframe` | — |
| 로딩(선택 시트) | `.mt-spinner`, `.mt-topbar`, `.mt-skeleton` | `.mt-skeleton-text`, `-card`, `-image`, `-avatar`, `-row`; `.mt-ratio-16x9`, `-4x3`, `-1x1` | `[aria-busy=true]`, `[role=status]` |
| 배너 | `div.mt-banner` | 그 `p`와 링크, `a.mt-back-to-top` | — |
| 쇼케이스 | `a.mt-skip` 바로 뒤의 `div.mt-showcase-region[role=region]`, `.mt-showcase-bar` 또는 `.mt-showcase-pill` | `.mt-showcase-mark`, `p.mt-showcase-label`, 링크(채운 링크는 `a.mt-showcase-solid`), `button.mt-showcase-dismiss` | `html[data-mt-showcase]` = bar, pill, off; `.mt-showcase-more`(40rem 미만에서 숨김), `.mt-showcase-less`(그때만 표시) |
| 알림 | `blockquote.mt-callout[role=note]` | `p.mt-callout-title`, 본문 | `.mt-callout-<type>`, `[data-variant]` = note, tip, important, warning, caution |
| 배지 | `span.mt-badge` | 레이블(상태 배지의 점은 `::before`로 그림) | `.mt-badge-<status>`, `.mt-badge-tag`, `[data-variant]` |
| 키보드 키 | `kbd.mt-kbd` | 키마다 `kbd` | — |
| 그림 | `figure.mt-figure` | `img`, `figcaption` | — |
| 정적 수식 | `figure.mt-figure.mt-math` | `<math>` 요소나 KaTeX의 HTML을 담은 `div.mt-figure-scroll[role=region]` | — |
| 정적 다이어그램 | `figure.mt-figure.mt-figure-svg.mt-diagram` | `div.mt-figure-scroll[role=region]`, `img.mt-diagram-light`, `img.mt-diagram-dark`, `figcaption`, 그림 뒤의 `details.mt-diagram-source` | 다른 색상 모드의 이미지는 숨김 |
| 글 머리 | `header.mt-post-header` | `h1.mt-post-title`, `.mt-post-deck`, `.mt-byline`, `figure.mt-post-cover`, `nav.mt-series`, `p.mt-post-meta` | `[data-part]` = header, deck, byline, authors, dates, cover, terms |
| 글 끝 | `article.mt-doc` | `.mt-share` 버튼, `nav.mt-post-nav`, `section.mt-related`, `.mt-news-correction`, `.mt-news-sources` | `[data-part]` = share, post-nav, related, sources |
| 글 카드 | `article.mt-card-post` | `.mt-card-post-cover`, `.mt-card-post-meta`, `.mt-card-post-title`, `.mt-card-post-excerpt` | `.mt-card-post-featured`, `[data-kind=news]`, `.mt-post-list[data-variant=list\|grid\|magazine]` |
| 뉴스 첫 화면 | `div.mt-news-top` | `.mt-news-lead`, `.mt-news-secondary`, `section.mt-news-latest`, `section.mt-news-section` | `[data-category]`, `.mt-badge[data-variant=breaking\|live]` |
| 검색 | `div.mt-search[role=search]` | 입력란, `.mt-search-results` | `[data-match=terms]`, `[data-compact]`, `[data-results]` |
| 필터 | `[data-mt-filter]` | `div.mt-filter`, `.mt-filter-chips[role=group]` > `button[aria-pressed]` | `[data-facet]`, 빠진 항목의 `[hidden]` |
| 차트 | `figure.mt-chart` | `.mt-chart-canvas`(차트 모듈이 캡션을 이름으로 단 `canvas[role=img]`를 그리기 전까지 `[hidden]`), `.mt-chart-data` > `div.mt-table` > `table`(`figure.mt-chart table`, 그린 뒤에는 `details` > `summary` 안으로 접힘), `figcaption` | `[data-type]`, `[data-opts]`, 색 훅 `--mt-chart-1`~`--mt-chart-8`, `--mt-chart-grid`, `--mt-chart-text` |
| 위젯 | `section.mt-c-widget`, `.mt-widget`을 단 사이트의 custom element | `.mt-widget-fallback`(섹션 텍스트 또는 `widget.fallback` 문장, 요소가 정의되면 숨김) | `[data-props]`(props의 JSON) |

위 행에 대한 참고:

- 페이지 틀: `header.mt-header` > `.mt-header-inner` 안에 `.mt-site-title` > `.mt-site-name`(사이트 이름, 두 줄까지 보이고 긴 단어는 점 뒤에서 나뉘며 넘치면 말줄임. 로고가 있으면 제목에 `.mt-compact-title`이 붙어 30rem보다 좁을 때 이름을 화면에서만 숨김), `nav.mt-nav`, `.mt-search`, `details.mt-lang.mt-menu`, `.mt-theme-toggle`이 있습니다. `nav.mt-nav`는 64rem 이상에서 링크가 한 줄로 놓인 `ul`이고, 그보다 좁으면 `details.mt-menu.mt-nav-sheet`가 됩니다. 이 메뉴에는 `summary` 메뉴 버튼과 `.mt-nav-sheet-label` 그룹 제목이 든 `ul` 시트가 있습니다. 언어 메뉴에는 `summary` 지구본 버튼과 `a[lang][hreflang]` 링크 `ul`이 있고, 현재 언어에는 `aria-current`가 붙습니다. `html[data-theme]`는 고정 색 구성이나 전환 버튼이 정합니다.
- 문서 사이드바: `nav.mt-sidebar`는 64rem 이상에서, `details.mt-sidebar-mobile`은 그보다 좁을 때 보입니다. 현재 링크에는 `aria-current=page`가 붙습니다.
- 문서 목차: `nav.mt-toc`는 페이지의 `h2`와 `h3`를 나열하고(64rem 이상의 옆 열에는 `h2`만 보입니다), `details.mt-toc-mobile`은 64rem보다 좁을 때 같은 목록을 보여 줍니다. 페이지를 읽는 동안 `structure/toc-spy.js`가 읽고 있는 섹션의 링크에 `aria-current=location`을 붙이며, 목록마다 링크 하나만 표시합니다. 옆 열에서는 `h3` 섹션이 그 `h2`를 표시합니다. JavaScript가 없으면 두 목록 모두 표시가 없습니다.
- 페이지 도구: 버튼은 `ul` 안에 있고 JS가 돌기 전에는 숨겨집니다. `a[type="text/markdown"]`는 Markdown 보기 링크입니다.
- 히어로: 리드는 `h1` 바로 다음의 첫 `p`입니다. 링크만 있는 `p`에서는 첫 링크가 주 버튼입니다. `.mt-hero-checks`는 front matter `hero: {checks: true}`로 켜며, 첫 `ul`이 `--mt-ok` 색 ✓ 표시 줄이 됩니다.
- 섹션: `[data-section]`은 이름, `[data-c]`와 `.mt-c-<c>`는 컴포넌트입니다. `.mt-cta`는 섹션에 붙고, 섹션 안에 `[data-mt-result]` 요소가 있으면 그 요소에 붙습니다. 이때 `c: widget` 요소는 그 요소의 내용만 감쌉니다.
- 섹션 장식: front matter `decor: <include>`로 켭니다. 장식은 마지막 자식이며 `_includes/sections/<include>.html`을 담고, 위쪽 끝 모서리에 놓이며 포인터 이벤트를 받지 않습니다.
- 스크롤 등장: front matter `reveal: true`로 켭니다. CSS만 쓰며, `@supports (animation-timeline: view())`와 `prefers-reduced-motion: no-preference`일 때만 서서히 나타나고 그 밖에서는 그대로 보입니다.
- 전체 폭 띠: front matter `bleed: true` 또는 `bleed: wide`로 켭니다. 사이드바나 목차가 있는 레이아웃에서는 띠가 본문 열 안에 머뭅니다. `bleed` 시트를 씁니다.
- 일러스트: 사이트에서 만든 include입니다. 태그는 그림 위 시작 쪽에 놓이는 배지입니다. `role=img`의 자식은 읽히지 않으므로 태그 글자도 `aria-label`에 넣으세요.
- 목록 스타일: `modootoday.lists`를 켜면 쓰입니다. 칩은 높이 44px이고 텍스트 뒤에 →가 붙습니다. 구분자는 `: `입니다.
- 제목 앵커: `modootoday.heading_anchors: true`일 때 히어로, 일반 섹션, `sections:`가 없는 페이지에 붙습니다. 이름은 `anchor.label` 레이블에 제목 텍스트를 넣은 것이고, 누르는 영역은 24px 이상의 정사각형입니다. `anchor` 시트를 씁니다.
- 탭: 탭 부분은 JS가 만듭니다. JS가 없으면 `h3`와 코드 블록이 그대로 남습니다.
- 파일 트리: 중첩 `ul`이 있는 항목이 폴더입니다.
- 표: `div.mt-table`은 렌더링할 때 본문의 모든 표를 감싸며, 스크롤되고 넘치면 이름 붙은 영역이 됩니다. 본문에는 클래스를 붙이지 않습니다. 세 클래스는 사이트가 직접 만든 레이아웃과 include의 표를 위한 훅입니다(본문의 kramdown 속성 목록은 이식되지 않고 `modootoday-check`가 보고합니다). `c: params` 표와 40rem보다 좁을 때 들어가지 않는 표는 `--stack`을 받습니다. 스크립트가 쌓인 표에 레이블을 붙이면 `[data-mt-labelled]`와 `td[data-label]`가 생깁니다. 스타일은 `table`·`table-stack` 시트에 있습니다.
- 매개변수 표: 40rem 미만에서 `table.mt-table--stack`으로 쌓입니다.
- 구독: `form.mt-subscribe`는 action을 설정했을 때 나옵니다.
- 설치: `pwa/install.js`는 `modootoday.pwa.enabled: true`일 때 이 섹션이 있는 페이지에서 불러옵니다. 꺼져 있으면 버튼은 숨겨진 채로 남고 안내 문장만 보입니다.
- 분할: `.mt-section-body`에는 `h2`와 텍스트가, `.mt-section-visual`에는 `visual:` include가 들어갑니다. `hero: {c: split}`는 `section.mt-hero`를 같은 래퍼로 감싸며, `h1`, 리드 문단, 체크 행, 액션은 `.mt-section-body`에 들어갑니다. `visual: code`는 첫 코드 블록을 `div.mt-section-visual.mt-split-code`에 넣고, `chrome: terminal`은 `.mt-split-terminal`과 `div.mt-split-bar`(`aria-hidden`)를 더합니다.
- 글 머리: `.mt-byline` 안에 `.mt-byline-authors` > `.mt-post-author`와 `.mt-byline-dates` > `time`이 있고, `p.mt-post-meta`에는 태그 배지가 들어갑니다.
- 검색: 상태 값은 `modootoday.search`에서 옵니다.
- 필터: 루트는 `section.mt-section`, `div.mt-prose`, `div.mt-dir`입니다(front matter `filter:`, `filter_text:`). `div.mt-filter`에는 `input[type=search]`와 `output[aria-live]`가 있고, 스크립트가 첫 목록이나 표 앞으로 옮기기 전까지 숨겨져 있습니다. 칩은 facet이 있을 때 나오며, `[data-facet]`은 열 번호입니다. `filter` 시트를 씁니다.

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
features: {params: {cols: {allowed: [2, 3, 4]}, badge: {allowed: [bottom]}}, slots: {items: {min: 1}}, parts: [ul > li, .mt-cols-2, .mt-cols-3, .mt-cols-4, .mt-badge-bottom]}
tabs: {i18n: [tabs.label], slots: {panels: {min: 2}, code: {min: 2}}}
cta: {slots: {actions: {required: true}}, parts: [.mt-cta]}
accordion: {slots: {panels: {min: 1}}}
steps: {slots: [{items: {min: 1}}, {panels: {min: 1}}], parts: [section.mt-c-steps, ol > li]}
```

컴포넌트 항목에는 `params`, `i18n`, `slots`, `parts`만, 슬롯 규칙에는 `required`, `min`, `max`만 쓸 수 있습니다. 그 밖의 키, 알 수 없는 슬롯 이름, `max`보다 큰 `min`, 형태가 두 개 미만인 목록은 오류이며 레지스트리 기준으로 한 번만 보고합니다. `slots:`가 없는 컴포넌트는 세지 않고, 맵 하나로 쓴 `slots:`는 이전과 똑같이 동작합니다.

## 이벤트

| 이벤트 | 보내는 때 | `detail` |
|---|---|---|
| `mt:themechange` | 페이지가 라이트·다크 모드를 바꿀 때. | `{theme: "light" 또는 "dark", source: "toggle" 또는 "system"}` |

테마 전환 버튼(`theme-toggle.js`)이 `document`에 보냅니다. 버튼을 누른 뒤, 그리고 독자가 색 구성을 고르지 않은 상태에서 시스템 색 구성이 바뀐 뒤에 보냅니다. 같은 문서 안에서만 보내고, 첫 페인트 때나 전환 버튼이 없는 사이트(`color_scheme: light` 또는 `dark`)에서는 보내지 않습니다.

전환 버튼이 없어도 동작하고 실제로 바뀔 때마다 한 번만 부르려면 `assets/js/modootoday/theme/current.js`의 `onThemeChange`를 쓰세요. 이벤트와 시스템 설정을 함께 듣고, 듣기를 멈추는 함수를 돌려줍니다.

## 오른쪽에서 왼쪽 쓰기와 수식

- 아랍어, 페르시아어, 히브리어, 우르두어 등 RTL 언어 페이지는 `lang`에 따라 `dir="rtl"`을 받습니다. front matter의 `direction: rtl` 또는 `ltr`(또는 `_data/i18n/<lang>.yml`의 `direction:`)로 바꿀 수 있습니다. 컴포넌트는 논리 속성을 써서 좌우가 뒤집히고, 코드는 왼쪽에서 오른쪽으로 유지됩니다.
- 테마는 수식·다이어그램 렌더러를 포함하지 않습니다. 정적 다이어그램과 수식은 커밋한 SVG 파일과 MathML을 보여 줍니다. [수식과 다이어그램](../../recipes/figures/math-diagrams/)을 보세요.

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
