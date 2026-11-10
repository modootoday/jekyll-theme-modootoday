---
lang: ko
permalink: /ko/guides/performance/
source_rev: sha256:6bba9c63805a
nav_order: 75
title: 성능
description: 페이지마다 불러오는 파일, CDN에 오래 캐시해 두기 위한 버전 붙은 자산 URL, CI가 지키는 크기 예산을 설명하고 사이트를 가볍게 유지하는 방법을 알려 줍니다.
---
# 성능

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/performance/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

테마는 페이지에 그 페이지가 쓰는 CSS와 JavaScript만 보냅니다. 또 테마 파일마다 버전이 붙은 URL을 쓰므로, 사이트 앞단의 CDN이 파일을 오래 캐시해도 됩니다.

## 페이지가 불러오는 파일

| 자산 | 불러오는 페이지 |
|---|---|
| `assets/css/modootoday.css` (핵심 시트: 토큰, 기본 요소, 헤더, 내비게이션, 테마 전환 버튼) | 모든 페이지 |
| 컴포넌트 시트 (`content/code`, `chrome/doc-nav`, `content/inline`, `marketing/hero`, `content/extras`, `media/figure`, `chrome/banner`, `chrome/footer`). 핵심 시트 바로 뒤에 연결 | 본문이나 페이지 아래쪽이 그 시트를 쓰는 페이지 |
| 맥락 시트 (`docs/doc`, `chrome/search`, `content/loading`, `content/lists`, `structure/bleed`, `chrome/terminal`, `media/visual`, `data/filter`, `data/table`, `data/table-stack`) | 레이아웃이나 본문이 그 시트를 쓰는 페이지 |
| 섹션 시트 (`tabs`, `faq`, `pricing` 등) | `sections:`에서 그 컴포넌트를 쓰는 페이지 |
| `chrome/menu.js`, `chrome/theme-toggle.js`, `chrome/search-keys.js` | 헤더, 테마 전환 버튼, 검색 색인이 있는 페이지 |
| `chrome/search.js`(`text/normalize.js` 포함)와 `search.json` | 독자가 검색창에 처음 들어가거나 `/`, Ctrl+K를 누를 때 |
| `content/code-copy.js` | 코드 블록이 있는 페이지와 페이지 작업 메뉴가 있는 페이지 |
| `content/scroll-region.js` | 코드 블록이나 표가 있는 페이지 |
| `data/table-stack.js` | 본문에 표가 있는 페이지 |
| `structure/tabs.js`, `structure/accordion.js`, `blog/share.js` | 탭, 아코디언, 블로그 레이아웃을 쓰는 페이지 |
| `data/filter.js`(`data/filter-chips.js`, `text/normalize.js`, `dom/config.js`를 미리 불러옴) | `filter:`나 `filter_text:`를 쓰는 페이지 |
| `data/chart.js`(`data/chart-table.js`, `theme/current.js`를 미리 불러옴), 사이트의 Chart.js 다음 | `modootoday.chart`가 사이트의 Chart.js(`src`)를 가리킬 때, 차트가 있는 페이지 |
| Mermaid와 KaTeX | 켜 두었을 때, 다이어그램이나 수식 블록이 있는 페이지 |
| `pwa/register.js`(오프라인 페이지에서는 `pwa/offline.js`도) | `modootoday.pwa.enabled: true`일 때 모든 페이지 |
| `pwa/update-toast.js`와 `chrome/toast` | 서비스 워커가 새 테마 파일을 받아 두고 기다리는 페이지 |
| 사이트의 `site_css` 시트와 `preload` 힌트 | 모든 페이지, 그리고 front matter에 더 적은 페이지 |
| 사이트의 `scripts` 모듈(그 시트와 모듈이 가져오는 테마 도우미 포함) | 히어로나 섹션이 `script:`로 이름을 적은 페이지 |

`data/table-stack.js`는 `c: params` 표, `mt-table--stack`이나 `mt-table--dl` 클래스가 붙은 표, 그리고 40rem보다 좁을 때 들어가지 않는 표를 쌓습니다.

`chrome/footer`는 `_data/nav/footer.yml`(또는 페이지 언어의 `footer-<lang>.yml`)에 열이 있을 때 불러옵니다.

테마 스크립트는 ES 모듈(`<script type="module">`)입니다. `defer`처럼 페이지를 다 읽은 뒤 순서대로 실행되므로 첫 화면 표시를 막지 않습니다. 모듈이 가져오는 파일에는 `<link rel="modulepreload">`가 붙어서, 하나씩 차례로 받지 않고 함께 받습니다. 클래식 스크립트는 `csp: strict`일 때 파일로 불러오는 작은 사전 페인트 테마 스크립트(`chrome/theme-init.js`) 하나뿐입니다. 첫 화면을 그리기 전에 실행되어야 하기 때문입니다. `modootoday.css: bundle`로 두면 모든 시트가 핵심 시트 하나에 담깁니다. [설정](../configuration/)을 보세요. `modootoday.pwa`를 켜면 서비스 워커가 `pwa/worker.js`를 한 번 불러와 테마 파일과 함께 보관하며, 페이지는 이 파일을 불러오지 않습니다([설치할 수 있는 사이트](../../recipes/pwa/#오프라인에서-읽기) 참고).

## 버전 붙은 자산 URL

테마의 스타일시트와 스크립트 URL 끝에는 `?v=`와 테마 버전이 붙습니다(예: `modootoday.css?v=X.Y.Z`). GitHub Pages는 이 쿼리를 무시하고 같은 파일을 보냅니다. CDN은 쿼리까지 캐시 키로 쓰므로, 파일을 1년 동안 캐시해도 새 테마 릴리스가 바로 방문자에게 전달됩니다.

| `modootoday.asset_version` | 쿼리 | 쓰는 경우 |
|---|---|---|
| `theme` (기본값) | `?v=X.Y.Z` | 테마 파일이 테마 버전과 함께만 바뀔 때 |
| `build` | `?v=X.Y.Z-a1b2c3d` | 사이트에서 테마 파일(Sass partial, 스크립트)도 덮어쓸 때 |
| `false` | 없음 | 자산 버전을 직접 관리할 때 |

`build`는 GitHub Pages에서는 `site.github.build_revision`의 커밋을, 다른 곳에서는 빌드 시각을 씁니다.

쿼리는 테마 자체의 CSS와 JavaScript, `site_css`에 올린 시트, 그리고 `modootoday.scripts` 항목의 `src`와 `css` 파일(히어로 모듈과 위젯)에 붙습니다. `theme`에서는 직접 만든 파일을 고쳐도 URL이 바뀌지 않으므로, 테마 릴리스 사이에 파일이 바뀐다면 `build`를 쓰세요. 그 밖의 스타일시트, 이미지, 글꼴 URL은 그대로이고 `preload` 힌트도 그렇습니다. 힌트는 페이지나 스타일시트가 요청하는 URL과 같아야 하며, 다르면 브라우저가 파일을 두 번 내려받습니다.

## CDN에서 오래 캐시하기

GitHub Pages는 `Cache-Control: max-age=600`을 보냅니다. 앞단에 CDN을 둔다면 테마 파일은 더 오래 캐시하세요. Cloudflare 캐시 규칙 예시는 다음과 같습니다.

| 항목 | 값 |
|---|---|
| 조건 | URI 경로가 `/assets/css/modootoday` 또는 `/assets/js/modootoday`로 시작하고, 쿼리 문자열에 `v=`가 있음 |
| Edge TTL | 1년, 원본의 캐시 헤더 무시 |
| Browser TTL | 1년 |
| 캐시 키 | 쿼리 문자열 포함(기본값) |

HTML은 TTL을 짧게 두어야 배포 뒤 새 `?v=`가 빨리 퍼집니다.

`?v=`는 페이지가 연결하는 파일에만 붙습니다. 그 파일이 가져오는 모듈(`text/normalize.js` 등)과 `modulepreload` 힌트에는 붙지 않아야 URL이 서로 맞으므로, 이 규칙에서는 원본의 10분 캐시를 그대로 따릅니다. 배포 뒤 그 10분 동안은 새 모듈이 캐시된 예전 모듈을 가져올 수 있습니다. 테마는 마이너 릴리스 안에서 공유 모듈이 내보내는 이름을 바꾸지 않으므로 그래도 동작합니다.

## 크기 예산

테마의 CI는 페이지를 예산보다 무겁게 만드는 변경을 실패로 처리합니다.

- 테마의 스타일시트와 스크립트 하나하나를 각자의 상한과 비교합니다(gzip 바이트). 상한은 잰 크기에 10%를 더한 값으로, 테마 자산 표에서 그 파일의 행에 적혀 있습니다. 그래서 기능이 커져도 자기 상한만 바뀝니다.
- 페이지 유형(문서, 랜딩, 블로그, 컴포넌트 페이지, 모듈 스크립트 비주얼이 있는 페이지, 목록 필터가 있는 페이지, 레코드 페이지, 차트 페이지)마다 한 페이지가 불러오는 CSS와 JavaScript(가져오는 모듈 포함) 중 테마 몫을 그 파일들의 상한 합계와 비교합니다. 한 페이지에 CSS 8 KiB, JavaScript 6 KiB, 테마 스타일시트 6개라는 목표는 경고로만 알려 줍니다(모든 컴포넌트를 일부러 불러오는 컴포넌트 페이지와, gzip 약 70 KB인 Chart.js를 싣는 차트 페이지는 빼고요).
- 예시 페이지에 [엄격한 콘텐츠 보안 정책](../../recipes/csp/)을 걸었을 때 위반 0건([데모](../../layouts/demo/csp/))
