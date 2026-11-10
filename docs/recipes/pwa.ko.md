---
lang: ko
permalink: /ko/recipes/pwa/
source_rev: sha256:512b037912d3
nav_order: 29
title: 설치할 수 있는 사이트
description: 이미 있는 사이트 설정으로 웹 앱 매니페스트를 만들어 브라우저가 사이트를 앱처럼 설치할 수 있게 하는 방법과 아이콘, 설치 가능 여부를 확인하는 방법을 설명합니다.
---
# 설치할 수 있는 사이트

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/pwa/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

`modootoday.pwa`를 켜면 브라우저가 사이트를 웹 앱으로 설치할 수 있습니다. Chrome, Edge, Android는 설치 버튼을 보여 주고, iOS와 macOS의 Safari는 사이트 이름과 아이콘 그대로 홈 화면이나 Dock에 추가합니다. 테마는 이미 있는 설정으로 웹 앱 매니페스트를 만들기 때문에 같은 값을 두 번 적을 필요가 없습니다. 기본값은 꺼짐이고, 이 설정이 없는 사이트는 이전과 똑같이 빌드됩니다.

## 켜기

```yaml
modootoday:
  favicon: brand
  pwa:
    enabled: true
    short_name: Docs   # 아이콘 아래 이름. 12자 이내로
```

원격 테마는 사이트 루트에 파일을 추가할 수 없으므로 작은 파일 하나를 저장소에 둡니다. gem에 들어 있는 스텁 작성기로 만드세요.

```sh
modootoday-stubs . --pwa           # 만들 파일을 보여 줌
modootoday-stubs . --pwa --write   # manifest.webmanifest 쓰기
```

`manifest.webmanifest`에는 front matter와 include 하나만 들어 있습니다. 이 파일을 커밋하세요. 그러면 모든 페이지가 `<link rel="manifest">`로 이 파일을 연결합니다. 사이트를 빌드하고 `modootoday-check . _site`를 실행하면 설정, 파일이 있고 최신인지, 빌드된 매니페스트와 아이콘, 모든 페이지의 연결을 확인합니다.

작성기는 이 파일을 지우지 않으며, 같은 경로에 직접 만든 파일이 있으면 덮어쓰지 않고 종료 코드 3으로 멈춥니다.

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

## 기기에 남는 것

설치하면 바로 가기와 앱 창이 생길 뿐 매니페스트 자체는 아무것도 저장하지 않습니다. 테마는 어디에도 데이터를 보내지 않고, 분석 도구를 넣지 않으며, 설치 안내를 스스로 띄우지 않습니다. 설치를 제안할 때는 브라우저가 정합니다. 방문자는 다른 앱처럼 브라우저의 앱 목록이나 홈 화면에서 앱을 지웁니다.

## 콘텐츠 보안 정책

매니페스트는 사이트 자신의 파일이라 `default-src 'self'` 정책이 허용합니다. 정책의 `default-src`가 그보다 좁다면 `manifest-src 'self'`를 더하세요. [CSP](../csp/)를 보세요.
