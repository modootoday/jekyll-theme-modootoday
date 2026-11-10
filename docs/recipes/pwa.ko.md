---
lang: ko
permalink: /ko/recipes/pwa/
source_rev: sha256:37cbe934107c
nav_order: 29
title: 설치할 수 있는 사이트
description: 이미 있는 사이트 설정으로 만든 웹 앱 매니페스트와 선택해서 켜는 서비스 워커로 브라우저가 사이트를 앱처럼 설치하고 오프라인에서도 읽을 수 있게 하는 방법을 설명합니다.
---
# 설치할 수 있는 사이트

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/pwa/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

`modootoday.pwa`를 켜면 브라우저가 사이트를 웹 앱으로 설치할 수 있습니다. Chrome, Edge, Android는 설치 버튼을 보여 주고, iOS와 macOS의 Safari는 사이트 이름과 아이콘 그대로 홈 화면이나 Dock에 추가합니다. 테마는 이미 있는 설정으로 웹 앱 매니페스트를 만들기 때문에 같은 값을 두 번 적을 필요가 없고, 서비스 워커가 테마 파일과 독자가 방문한 페이지를 보관해 오프라인에서도 읽을 수 있게 합니다. 기본값은 꺼짐이고, 이 설정이 없는 사이트는 이전과 똑같이 빌드됩니다.

## 켜기

```yaml
modootoday:
  favicon: brand
  pwa:
    enabled: true
    short_name: Docs   # 아이콘 아래 이름. 12자 이내로
```

원격 테마는 사이트 루트에 파일을 추가할 수 없으므로 작은 파일 몇 개를 저장소에 둡니다. gem에 들어 있는 스텁 작성기로 만드세요.

```sh
modootoday-stubs . --pwa           # 만들 파일을 보여 줌
modootoday-stubs . --pwa --write   # 아래 파일 쓰기
```

| 파일 | 내용 |
|---|---|
| `manifest.webmanifest` | 웹 앱 매니페스트 |
| `sw.js` | 서비스 워커. 워커는 자기 폴더 아래 페이지만 처리하므로 사이트 루트(`baseurl` 포함)에 둡니다. |
| `offline.md` | `/offline/`의 오프라인 페이지. `modootoday.full_languages`의 언어마다 `/<lang>/offline/`에 `offline.<lang>.md`도 만듭니다. |

각 파일에는 front matter와 include 하나, 또는 front matter만 들어 있습니다. 이 파일들을 커밋하세요. 그러면 모든 페이지가 `<link rel="manifest">`로 매니페스트를 연결하고, 워커를 등록하는 작은 스크립트를 불러옵니다. 사이트를 빌드하고 `modootoday-check . _site`를 실행하면 설정, 파일이 있고 최신인지, 빌드된 매니페스트와 아이콘, 모든 페이지의 연결, 워커와 워커가 보관하는 페이지를 확인합니다.

작성기는 이 파일들을 지우지 않으며, 같은 경로에 직접 만든 파일이 있으면 덮어쓰지 않고 종료 코드 3으로 멈춥니다.

## 매니페스트에 들어가는 값

| 매니페스트 필드 | 가져오는 곳 |
|---|---|
| `name` | `pwa.name`, 없으면 사이트 `title` |
| `short_name` | `pwa.short_name`, 없으면 이름. 홈 화면은 12자 정도보다 긴 이름을 자르며, `modootoday-check`가 경고합니다. |
| `description` | `pwa.description`, 없으면 사이트 `description` |
| `lang`, `dir` | 사이트 기본 언어(`lang:`)와 그 언어의 쓰기 방향 |
| `start_url`, `id` | `pwa.start_url`, `/guides/`처럼 사이트 안의 경로(기본값 `/`)에 `baseurl`을 붙인 값. 쿼리 문자열을 넣을 수 없어서 앱이 추적 파라미터와 함께 열리지 않습니다. |
| `scope` | 언제나 `baseurl`을 붙인 사이트 루트(예: `/docs/`). 설정 키가 아닙니다. |
| `display` | `pwa.display`: `standalone`(기본값, 주소창 없는 창), `minimal-ui`, `browser` |
| `theme_color` | `modootoday.theme_color`, 브라우저 막대 태그와 같은 색: 라이트 값, `color_scheme: dark`면 다크 값. `theme_color: false`면 넣지 않습니다. |
| `background_color` | `pwa.background_color`(16진수 색), 없으면 페이지 배경: `#ffffff`, `color_scheme: dark`면 `#0a0a0a` |
| `icons` | `pwa.icons`: `brand`(기본값) 또는 직접 지정한 목록 |

## 아이콘

`icons: brand`는 `favicon: brand`처럼 테마의 마크를 씁니다. 192px 아이콘, 512px 아이콘, 그리고 Android가 원으로 잘라도 마크가 원 안에 들어가는 512px maskable 아이콘입니다. 직접 만든 아이콘을 쓰려면 사이트의 PNG 파일을 나열하세요.

```yaml
modootoday:
  pwa:
    enabled: true
    icons:
      - {src: /assets/icons/app-192.png, sizes: 192x192}
      - {src: /assets/icons/app-512.png, sizes: 512x512}
      - {src: /assets/icons/app-maskable.png, sizes: 512x512, purpose: maskable}
```

- purpose가 `any`(기본값)인 192px 아이콘과 512px 아이콘은 꼭 있어야 합니다. 둘이 없으면 브라우저가 설치를 제안하지 않습니다.
- `maskable` 아이콘을 권장합니다. 그림은 너비의 80%인 가운데 원 안에 두고, 정사각형 전체를 배경으로 채우세요.
- `sizes`는 파일과 같아야 합니다. `modootoday-check`는 빌드된 사이트에서 각 PNG의 실제 크기를 읽습니다.
- `favicon`이 `brand`가 아닌데 `icons`를 정하지 않으면, 앱에 테마 마크가 보인다는 경고가 나옵니다. `icons:`에 직접 만든 아이콘을 넣거나, 그대로 쓰려면 `icons: brand`를 적으세요.

Apple 터치 아이콘은 이전처럼 `favicon`에서 옵니다. Safari 16.4 이상도 매니페스트를 읽습니다.

## 설치할 수 있는지 확인하기

1. 사이트를 빌드하고 HTTPS나 `localhost`로 엽니다.
2. Chrome에서 개발자 도구를 열고 Application, Manifest로 갑니다. 설치할 수 있으면 Installability 항목에 아무것도 없습니다.
3. 게시하기 전에 `modootoday-check . _site --strict`를 실행합니다.

시크릿 창에서는 Chrome이 언제나 설치할 수 없다고 알립니다. 일반 창에서 확인하세요.

## 오프라인에서 읽기

워커는 범위 안에 있는 사이트 자신의 `GET` 요청만 처리합니다. 폼, 다른 사이트, 임베드, CDN 같은 나머지 요청은 이전처럼 네트워크로 가고, 워커 안에서 실패한 요청도 네트워크로 갑니다.

| 요청 | 워커가 하는 일 |
|---|---|
| `POST`, 다른 출처, 사이트 밖 경로, `Range` 헤더가 있는 요청(오디오, 동영상) | 없음. 브라우저가 평소대로 가져옵니다. |
| 테마 파일(`/assets/css/modootoday*`, `/assets/js/modootoday*`) | 보관한 사본을 주고, 없으면 가져와 보관합니다. |
| 페이지 | 독자가 최신 버전을 보도록 먼저 네트워크에서 가져옵니다. 오프라인이면 보관한 사본을, 없으면 그 페이지 언어의 오프라인 페이지를 줍니다. 서버 오류(5xx)일 때도 보관한 사본을 줍니다. 성공한 응답만, 최대 50개 페이지를 보관합니다. |
| `search.json` | 보관한 사본을 주고 다음을 위해 새 사본을 가져옵니다. |
| Markdown 버전, `llms.txt`, 피드, `sitemap.xml`, 매니페스트, `sw.js` | 없음. 항상 네트워크에서 가져옵니다. |
| 사이트 자신의 CSS와 JavaScript(`site_css`, `scripts`) | 먼저 가져오고, 오프라인이면 보관한 사본을 줍니다. |
| 이미지와 글꼴 | 보관한 사본을 주고 새 사본을 가져옵니다. 최대 60개 파일을 보관합니다. |

워커는 설치될 때 오프라인 페이지와 그 페이지가 연결하는 파일, `start_url`, `pwa.precache`의 경로, front matter에 `pwa: precache`가 있는 페이지를 저장합니다.

```yaml
modootoday:
  pwa:
    enabled: true
    precache: [/guides/, /reference/api/]   # 사이트 경로, 쿼리 문자열 없이
```

처음 방문할 때마다 이 목록을 모두 내려받으므로 짧게 유지하세요. 목록의 페이지가 빌드에 없으면 `modootoday-check`가 실패하고, 목록이 1 MiB를 넘으면 경고합니다. 독자가 처음 연 페이지는 아직 워커를 거치지 않습니다. 워커가 준비되면 그 페이지가 불러온 URL을 워커에 보내므로, 독자가 오프라인에서 사이트를 시작해도 모양이 그대로입니다.

오프라인 페이지는 오프라인 상태임을 알리고, 다시 시도(요청한 페이지를 다시 불러옴)와 홈 링크, 이 기기에 워커가 보관한 페이지 목록을 보여 줍니다. 사이트맵과 검색 색인에는 들어가지 않습니다.

### 캐시, 버전, 같은 출처를 쓰는 사이트

캐시 이름에는 사이트 경로가 들어갑니다. `mt:<baseurl>/:assets:<version>`, `mt:<baseurl>/:pages:<version>`, `mt:<baseurl>/:media`입니다. 그래서 같은 `<user>.github.io`의 프로젝트 사이트 두 개가 서로의 캐시를 건드리지 않습니다.

- 두 캐시 모두 `modootoday.asset_version`을 따릅니다([성능](../../guides/performance/#버전-붙은-자산-url) 참고). `theme`(기본값)이면 테마 버전이 바뀔 때, `build`나 `false`면 배포할 때마다 바뀝니다.
- 그래서 테마 파일이 그대로인 배포는 독자가 저장한 페이지를 그대로 둡니다. 테마를 업데이트하면 페이지 캐시도 바뀝니다. 보관한 페이지는 자기 버전의 테마 파일을 링크하기 때문입니다.
- 새 워커는 이 사이트의 이전 캐시만 지웁니다.

`sw.js`는 배포할 때마다 바뀌고, 브라우저는 이것으로 새 워커를 찾습니다. Cloudflare 같은 CDN을 사이트 앞에 두었다면 `/sw.js`를 긴 엣지 캐시에서 빼세요(그 경로의 캐시를 건너뛰는 캐시 규칙). 그렇지 않으면 엣지 사본이 만료될 때까지 방문자가 이전 워커를 씁니다.

## 끄기

파일만 지우면 안 됩니다. 이미 방문자 기기에 있는 워커가 계속 이전 사본을 보여 줍니다. 대신 다음 순서를 따르세요.

1. `enabled: kill`로 바꾸고 배포합니다. `sw.js`는 이 사이트의 캐시를 지우고 스스로를 제거한 뒤 열린 페이지를 다시 불러오는 워커가 되고, 매니페스트 연결과 등록 스크립트는 빠집니다.
2. 다시 방문하는 독자가 받아 가도록 일주일 동안 그대로 둡니다.
3. `enabled: false`로 바꾸거나 `pwa`를 지운 다음 `manifest.webmanifest`, `sw.js`, 오프라인 페이지를 지웁니다.

`enabled: false`여도 `sw.js`는 스스로를 제거하는 워커를 만들기 때문에, 이 순서 없이 설정을 꺼도 정리됩니다. 파일을 지울 때까지 `modootoday-check`가 경고합니다.

## 기기에 남는 것

설치하면 바로 가기와 앱 창이 생깁니다. 워커는 Cache Storage의 `mt:<baseurl>/:` 아래에 테마 파일, 방문한 페이지 최대 50개, 이미지와 글꼴 최대 60개를 저장하며, 쿠키나 `localStorage`에는 아무것도 더하지 않습니다. 테마는 어디에도 데이터를 보내지 않고, 푸시나 백그라운드 동기화, 영구 저장소를 요청하지 않으며, 분석 도구를 넣지 않으며, 설치 안내를 스스로 띄우지 않습니다. 설치를 제안할 때는 브라우저가 정합니다. 방문자는 다른 앱처럼 브라우저의 앱 목록이나 홈 화면에서 앱을 지우고, 브라우저 설정에서 사이트 데이터를 지워 워커가 보관한 것을 지웁니다. 브라우저가 스스로 지우기도 하므로(Safari는 몇 주 동안 방문하지 않으면) 오프라인 읽기는 최선을 다하는 기능입니다.

## 콘텐츠 보안 정책

매니페스트는 사이트 자신의 파일이라 `default-src 'self'` 정책이 허용합니다. 워커와 워커가 불러오는 스크립트도 사이트의 파일입니다. 정책의 `default-src`가 그보다 좁다면 `manifest-src 'self'`와 `worker-src 'self'`를 더하세요. [CSP](../csp/)를 보세요.
