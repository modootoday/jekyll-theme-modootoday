---
lang: ko
permalink: /ko/recipes/pwa/
source_rev: sha256:1e881fbf3bc2
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
| `shortcuts`, `screenshots` | `pwa.shortcuts`와 `pwa.screenshots`. 목록을 적었을 때만 들어갑니다(아래 참고). |

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

## 바로 가기와 스크린샷

선택 목록 두 개로 앱에 보여 줄 것을 더할 수 있습니다. 목록을 적기 전에는 둘 다 매니페스트에 들어가지 않습니다.

```yaml
modootoday:
  pwa:
    enabled: true
    shortcuts:
      - {name: 가이드, url: /guides/}
      - {name: API 레퍼런스, short_name: API, description: 모든 키와 파일, url: /reference/api/}
    screenshots:
      - {src: /assets/screens/home-wide.png, sizes: 1280x720, form_factor: wide, label: 홈 페이지}
      - {src: /assets/screens/home-phone.png, sizes: 390x844, form_factor: narrow, label: 휴대폰에서 본 홈 페이지}
```

- `shortcuts`는 앱 아이콘 메뉴의 항목입니다(Android에서는 길게 누르기, 데스크톱에서는 오른쪽 클릭). 항목마다 `name`과 `url`이 있고, `url`은 쿼리 문자열이 없는 사이트의 페이지입니다. `short_name`과 `description`은 선택입니다. 아이콘은 앱 아이콘을 씁니다.
- `screenshots`는 Chrome과 Edge의 설치 대화상자에 나옵니다. 항목마다 사이트의 PNG 파일과 그 `sizes`를 적습니다. `form_factor: wide`는 데스크톱 대화상자용, `narrow`는 휴대폰용이고, `label`은 스크린 리더를 위해 그림을 설명합니다. 한 변이 320px보다 작거나 3840px보다 크거나 한 변이 다른 변의 2.3배를 넘는 그림은 브라우저가 건너뛰고, 데스크톱 대화상자는 `wide` 그림이 하나라도 있어야 그림을 보여 줍니다. `modootoday-check`는 두 경우 모두 경고합니다.
- 바로 가기의 페이지나 스크린샷이 빌드에 없거나 스크린샷의 실제 크기가 `sizes`와 다르면 `modootoday-check`가 실패합니다.

## 설치할 수 있는지 확인하기

1. 사이트를 빌드하고 HTTPS나 `localhost`로 엽니다.
2. Chrome에서 개발자 도구를 열고 Application, Manifest로 갑니다. 설치할 수 있으면 Installability 항목에 아무것도 없습니다.
3. 게시하기 전에 `modootoday-check . _site --strict`를 실행합니다.

시크릿 창에서는 Chrome이 언제나 설치할 수 없다고 알립니다. 일반 창에서 확인하세요.

## 설치하기

사이트 설치는 브라우저가 자기 화면에서 제안하며, 테마는 설치 안내를 스스로 띄우지 않습니다. 독자에게 눈에 보이는 설치 방법을 주려면 홈 페이지나 앱 받기 페이지 같은 곳에 `c: install` 섹션을 넣습니다.

```yaml
sections:
  - {c: install, name: app}
```

```markdown
## 네트워크 없이 읽기

이 문서를 홈 화면에 두고 네트워크 없이 읽어 보세요.
```

섹션은 본문, 설치 버튼, 그리고 메뉴나 공유 메뉴에서 설치하는 브라우저를 위한 안내 문장을 출력합니다. 버튼은 브라우저가 이 사이트를 설치할 수 있다고 알릴 때(`beforeinstallprompt`)까지 숨겨져 있고, 독자가 누를 때만 브라우저의 설치 대화상자를 엽니다. 독자가 답하거나 사이트가 설치되면 버튼은 다시 숨겨집니다. 설치된 앱 안에서는 섹션 전체가 숨겨집니다. 섹션의 시트(`showcase/install.css`)와 스크립트(`pwa/install.js`)는 이 섹션이 있는 페이지에서만 불러오고, 스크립트는 `enabled: true`일 때만 불러옵니다. `enabled: true`가 아닌 사이트에서는 `modootoday-check`가 이 섹션을 경고합니다.

| 브라우저 | 독자가 사이트를 설치하는 방법 |
|---|---|
| 데스크톱과 Android의 Chrome, Edge 등 Chromium 브라우저 | 설치 버튼, 또는 주소 표시줄이나 브라우저 메뉴의 설치 아이콘 |
| iPhone과 iPad의 Safari | 공유, 홈 화면에 추가(안내 문장) |
| macOS 14 이상의 Safari | 파일, Dock에 추가(안내 문장) |
| Android의 Firefox | 브라우저 메뉴, 홈 화면에 추가(안내 문장) |
| 데스크톱의 Firefox | 지원하지 않습니다. 안내 문장은 남고 사이트는 이전처럼 동작합니다. |

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

워커는 설치될 때 오프라인 페이지와 그 페이지가 연결하는 파일, 알림의 시트와 스크립트, `start_url`, `pwa.precache`의 경로, front matter에 `pwa: precache`가 있는 페이지를 저장합니다.

```yaml
modootoday:
  pwa:
    enabled: true
    precache: [/guides/, /reference/api/]   # 사이트 경로, 쿼리 문자열 없이
```

처음 방문할 때마다 이 목록을 모두 내려받으므로 짧게 유지하세요. 목록의 페이지가 빌드에 없으면 `modootoday-check`가 실패하고, 목록이 1 MiB를 넘으면 경고합니다. 독자가 처음 연 페이지는 아직 워커를 거치지 않습니다. 워커가 준비되면 그 페이지가 불러온 URL을 워커에 보내므로, 독자가 오프라인에서 사이트를 시작해도 모양이 그대로입니다.

오프라인 페이지는 오프라인 상태임을 알리고, 다시 시도(요청한 페이지를 다시 불러옴)와 홈 링크, 이 기기에 워커가 보관한 페이지 목록을 보여 줍니다. 사이트맵과 검색 색인에는 들어가지 않습니다.

브라우저가 네트워크가 끊겼다고 알리면, 다른 페이지 아래쪽에 짧은 알림이 나타나 독자가 오프라인 상태이며 방문한 페이지는 계속 열 수 있다고 알려 줍니다. 네트워크가 돌아오면 저절로 닫히고, 닫기 버튼이나 `Esc`로도 닫을 수 있습니다. 브라우저의 판단이 틀릴 수도 있으므로(로그인 페이지가 필요한 네트워크는 온라인으로 판단합니다) 알림은 참고용이며, 오프라인 읽기는 알림과 관계없이 동작합니다.

### 캐시, 버전, 같은 출처를 쓰는 사이트

캐시 이름에는 사이트 경로가 들어갑니다. `mt:<baseurl>/:assets:<version>`, `mt:<baseurl>/:pages:<version>`, `mt:<baseurl>/:media`입니다. 그래서 같은 `<user>.github.io`의 프로젝트 사이트 두 개가 서로의 캐시를 건드리지 않습니다.

- 두 캐시 모두 `modootoday.asset_version`을 따릅니다([성능](../../guides/performance/#버전-붙은-자산-url) 참고). `theme`(기본값)이면 테마 버전이 바뀔 때, `build`나 `false`면 배포할 때마다 바뀝니다.
- 그래서 테마 파일이 그대로인 배포는 독자가 저장한 페이지를 그대로 둡니다. 테마를 업데이트하면 페이지 캐시도 바뀝니다. 보관한 페이지는 자기 버전의 테마 파일을 링크하기 때문입니다.
- 새 워커는 이 사이트의 이전 캐시만 지웁니다.

`sw.js`는 배포할 때마다 바뀌고, 브라우저는 이것으로 새 워커를 찾습니다. Cloudflare 같은 CDN을 사이트 앞에 두었다면 `/sw.js`를 긴 엣지 캐시에서 빼세요(그 경로의 캐시를 건너뛰는 캐시 규칙). 그렇지 않으면 엣지 사본이 만료될 때까지 방문자가 이전 워커를 씁니다.

## 업데이트

`sw.js`는 배포할 때마다 바뀝니다. 브라우저는 페이지를 열 때 새 `sw.js`를 찾고(스스로는 하루에 한 번까지), 설치한 앱은 며칠씩 열려 있을 수 있어서 테마는 창이 한 시간 넘게 지난 뒤 다시 보일 때도 확인을 요청합니다.

- **테마 파일이 그대로인 배포**(페이지와 사이트 파일만 바뀐 배포)는 아무것도 띄우지 않습니다. 새 워커가 바로 넘겨받고, 페이지는 어차피 네트워크에서 먼저 가져옵니다.
- **테마 파일이 바뀌는 배포**(테마 업데이트, 또는 `asset_version: build`나 `false`일 때의 모든 배포)는 독자를 기다립니다. 페이지 아래쪽에 새 버전이 준비됐다는 알림이 새로고침, 나중에 버튼과 함께 나타납니다. 새로고침은 새 워커에 넘기고 페이지를 한 번 다시 불러옵니다. 나중에나 `Esc`는 다음 페이지까지 알림을 닫습니다. 페이지가 스스로 다시 불러오는 일은 없으므로 독자가 입력하던 내용이 사라지지 않습니다.

알림을 직접 확인하려면 다음처럼 합니다.

1. `modootoday.asset_version: build`로 두어 배포할 때마다 테마 파일 URL이 바뀌게 합니다(GitHub Pages에서는 커밋, 그 밖에서는 빌드 시각이 붙습니다).
2. 배포한 뒤 사이트를 열고 페이지 하나를 끝까지 불러와 서비스 워커가 설치되게 합니다.
3. 아무 커밋으로나 다시 배포합니다.
4. 열어 둔 페이지를 다시 불러오거나, 한 시간 뒤 그 창으로 돌아옵니다. 페이지 아래쪽에 알림이 나타납니다.

로컬의 `bundle exec jekyll serve`로도 확인할 수 있습니다. 브라우저는 `localhost`에서 서비스 워커를 허용하고, `asset_version: build`에서는 파일을 저장해 다시 빌드할 때마다 배포로 칩니다. 페이지만 바꾼 배포에서는 알림이 나오지 않게 하려면, 확인한 뒤 `asset_version`을 `theme`으로 돌립니다(기본값이 `theme`이므로 지워도 됩니다).

알림은 상태 메시지라서 스크린 리더가 읽어 주고, 포커스를 가져가지 않습니다. 페이지의 맨 끝에 있으므로 키보드 사용자는 페이지의 마지막 링크 다음으로 Tab을 눌러 새로고침과 나중에 버튼에 닿습니다. `Esc`는 페이지 어디에서든 알림을 닫습니다. 시트(`chrome/toast.css`)와 스크립트(`pwa/update-toast.js`)는 알림을 띄울 때만 불러오며, 기기에 아무것도 남기지 않습니다.

사이트를 설치하지 않은 독자는 피드, 릴리스 알림, 이메일 양식으로 업데이트를 알게 됩니다. [독자에게 업데이트 알리기](../updates/)를 참고하세요.

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
