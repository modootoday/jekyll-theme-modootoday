---
title: 성능
nav_order: 75
description: 페이지마다 불러오는 파일, CDN에 오래 캐시하기 위한 버전 붙은 자산 URL, CI가 지키는 크기 예산.
---
# 성능

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/performance/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

테마는 페이지에 그 페이지가 쓰는 CSS와 JavaScript만 보냅니다. 또 테마 파일마다 버전이 붙은 URL을 쓰므로, 사이트 앞단의 CDN이 파일을 오래 캐시해도 됩니다.

## 페이지가 불러오는 파일

| 자산 | 불러오는 페이지 |
|---|---|
| `assets/css/modootoday.css` (핵심 시트) | 모든 페이지 |
| 맥락 시트 (`doc`, `search`, `loading`, `figure`, `lists`, `bleed`, `terminal`, `visual`) | 레이아웃이나 본문이 그 시트를 쓰는 페이지 |
| 섹션 시트 (`tabs`, `faq`, `pricing` 등) | `sections:`에서 그 컴포넌트를 쓰는 페이지 |
| `menu.js`, `theme-toggle.js`, `search.js` | 헤더, 테마 전환 버튼, 검색 색인이 있는 페이지 |
| `code-copy.js` | 코드 블록이 있는 페이지와 페이지 작업 메뉴가 있는 페이지 |
| `scroll-region.js` | 코드 블록이나 표가 있는 페이지 |
| `tabs.js`, `accordion.js`, `share.js` | 탭, 아코디언, 블로그 레이아웃을 쓰는 페이지 |
| Mermaid와 KaTeX | 켜 두었을 때, 다이어그램이나 수식 블록이 있는 페이지 |
| 사이트의 `site_css` 시트와 `preload` 힌트 | 모든 페이지, 그리고 front matter에 더 적은 페이지 |
| 사이트의 `scripts` 모듈(그 시트와 모듈이 가져오는 테마 도우미 포함) | 히어로나 섹션이 `script:`로 이름을 적은 페이지 |

스크립트는 `defer`로 불러오므로 첫 화면 표시를 막지 않습니다. 예외는 `csp: strict`일 때 파일로 불러오는 작은 사전 페인트 테마 스크립트 하나입니다. `modootoday.css: bundle`로 두면 모든 시트가 핵심 시트 하나에 담깁니다. [설정](../configuration/)을 보세요.

## 버전 붙은 자산 URL

테마의 스타일시트와 스크립트 URL 끝에는 `?v=`와 테마 버전이 붙습니다(예: `modootoday.css?v=X.Y.Z`). GitHub Pages는 이 쿼리를 무시하고 같은 파일을 보냅니다. CDN은 쿼리까지 캐시 키로 쓰므로, 파일을 1년 동안 캐시해도 새 테마 릴리스가 바로 방문자에게 전달됩니다.

| `modootoday.asset_version` | 쿼리 | 쓰는 경우 |
|---|---|---|
| `theme` (기본값) | `?v=X.Y.Z` | 테마 파일이 테마 버전과 함께만 바뀔 때 |
| `build` | `?v=X.Y.Z-a1b2c3d` | 사이트에서 테마 파일(Sass partial, 스크립트)도 덮어쓸 때. GitHub Pages에서는 `site.github.build_revision`의 커밋을, 다른 곳에서는 빌드 시각을 씁니다 |
| `false` | 없음 | 자산 버전을 직접 관리할 때 |

쿼리는 테마 자체의 CSS와 JavaScript, 그리고 `site_css`에 올린 시트에 붙습니다. 그 밖의 스타일시트, 이미지, 글꼴 URL은 그대로이고 `preload` 힌트도 그렇습니다. 힌트는 페이지나 스타일시트가 요청하는 URL과 같아야 하며, 다르면 브라우저가 파일을 두 번 내려받습니다.

## CDN에서 오래 캐시하기

GitHub Pages는 `Cache-Control: max-age=600`을 보냅니다. 앞단에 CDN을 둔다면 테마 파일은 더 오래 캐시하세요. Cloudflare 캐시 규칙 예시는 다음과 같습니다.

| 항목 | 값 |
|---|---|
| 조건 | URI 경로가 `/assets/css/modootoday` 또는 `/assets/js/modootoday`로 시작하고, 쿼리 문자열에 `v=`가 있음 |
| Edge TTL | 1년, 원본의 캐시 헤더 무시 |
| Browser TTL | 1년 |
| 캐시 키 | 쿼리 문자열 포함(기본값) |

HTML은 TTL을 짧게 두어야 배포 뒤 새 `?v=`가 빨리 퍼집니다.

## 크기 예산

테마의 CI는 페이지를 예산보다 무겁게 만드는 변경을 실패로 처리합니다.

- 스타일시트 하나하나, 한 페이지가 연결하는 핵심 CSS, 핵심 스크립트 전체(gzip)
- 페이지 유형(문서, 랜딩, 블로그, 컴포넌트 쇼케이스, 모듈 스크립트 비주얼이 있는 페이지)마다 한 페이지가 불러오는 CSS와 JavaScript의 gzip 바이트(가져오는 모듈 포함)
- 예시 페이지에 [엄격한 콘텐츠 보안 정책](../../recipes/csp/)을 걸었을 때 위반 0건([데모](../../layouts/demo/csp/))
