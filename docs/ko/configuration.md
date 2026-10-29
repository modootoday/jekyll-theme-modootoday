---
title: 설정
description: _config.yml의 modootoday 키 아래 사이트 전체 설정.
sections:
  - keys
  - head
  - i18n
  - registry
  - {c: cta, name: next}
---
# 설정

모두 선택 사항입니다. 다른 플러그인과 겹치지 않도록 설정은 `modootoday:` 키 하나에 모입니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../../configuration/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 키

```yaml
modootoday:
  color_scheme: auto  # auto | auto-dark | auto-light | light | dark
  components: [callout, badge, cta, card, tabs]
  tokens: {primary: "#4f46e5", radius: "0.5rem"}
  nav: main
```

| 키 | 기본값 | 효과 |
|---|---|---|
| `badges` | `true` | 상태 코드 스팬을 배지로 바꿈. `false`면 코드 그대로 |
| `color_scheme` | `auto` | `auto`는 OS를 따름. `auto-dark`·`auto-light`는 다크·라이트로 시작하고 전환 버튼을 유지(독자의 선택은 기억). `light`·`dark`는 전환 버튼 없이 고정. 시작 색은 HTML에 들어가므로 깜빡임이 없음 |
| `components` | 전체 | 내보낼 CSS와 JS를 제한 |
| `css_layers` | `false` | 테마 CSS를 `@layer mt.*`로 감쌈 |
| `nav` | `main` | `_data/nav/`의 내비게이션 파일. `items:`가 있는 항목은 그룹이 됨. 이전·다음 링크는 이 파일 순서(그룹 자체 페이지, 그다음 하위 항목)를 따름 |
| `sidebar` | `auto` | `auto`면 내비게이션에 그룹이 있을 때 `doc` 페이지에 사이드바를 붙임. `true`는 항상, `false`는 끔. 64rem보다 좁으면 본문 위의 접이식 메뉴가 됨. 머리말의 `sidebar: false`로 한 페이지에서만 숨김 |
| `page_actions` | `true` | Markdown 쌍둥이가 있는 페이지에 Markdown으로 보기, 페이지 복사, AI용으로 복사(출처 URL 뒤에 Markdown) 메뉴를 표시. 여기나 머리말에서 `false`면 끔. 아예 빼려면 `components`에서 `page-actions`를 제외 |
| `tokens`, `tokens_dark` | 테마 값 | 시맨틱 디자인 토큰을 인라인으로 덮어씀 |
| `twins` | 스텁 | 머리말 없는 쌍둥이는 `source` ([에이전트](../agents/) 참고) |
| `seo` | `true` | `false`면 내장 canonical, hreflang, Open Graph 태그를 뺌 |
| `hreflang` | `seo`를 따름 | `true`면 `seo: false`여도 `hreflang` 대체 링크를 유지 (`jekyll-seo-tag`를 쓰는 사이트용) |
| `languages` | 없음 | `hreflang`용 언어 코드, 예: `[en, ko]` 헤더의 사이트 제목은 해당 언어의 홈(`/<lang>/`)이 있으면 그곳으로 연결됩니다. |
| `language_switcher` | 없음 | `header`(지구본 버튼과 드롭다운 메뉴, 언어 수와 상관없이 폭 고정) 또는 `footer`(언어 이름 목록)로 `languages` 기반 언어 전환기를 표시. 각 링크는 이 페이지의 번역본, 없으면 그 언어의 첫 페이지로 이동. 언어가 둘 미만이면 렌더하지 않음. 메뉴는 JavaScript 없이 열리고, `menu.js`가 Esc, 화살표 키, 바깥 클릭 시 닫기를 더함 |
| `og_image` | 없음 | 기본 Open Graph 이미지. 머리말의 `image:`가 우선 |
| `feed` | `false` | `true`면 `/feed.xml` 링크 추가 (`plugins`에 `jekyll-feed` 필요) |
| `logo` | 없음 | `brand`면 사이트 제목 앞에 modootoday 마크를 `currentColor`(`brand` 토큰이라 라이트·다크를 따라감)로 표시. 경로를 주면 그 이미지를 표시(장식용, `alt=""`). 다른 로고는 `modootoday/brand/logo.html`을 덮어쓰기 |
| `favicon` | 없음 | `brand`면 modootoday 마크를 SVG, 32px PNG, Apple 터치 아이콘으로 연결. 경로를 주면 그 아이콘을 연결 |
| `csp` | 없음 | `strict`면 사전 페인트 스크립트를 인라인 대신 파일로 불러옴 |
| `viewport_fit` | `cover` | `auto`면 노치 아래까지 그리지 않고 페이지를 안전 영역 안에 둠 ([접근성](../accessibility/#설정) 참고) |
| `theme_color` | 페이지 배경 | 브라우저 막대 색: `"#hex"` 하나, `{light: "#hex", dark: "#hex"}`, 또는 태그를 빼려면 `false` |
| `edit_url` | 없음 | "이 페이지 편집" 링크의 앞부분, `/`로 끝남 |
| `archive` | 없음 | 아카이브 페이지 URL, 예: `{tags: /tags/, categories: /categories/}`. 글 하단 링크가 여기로 이어짐([글과 아카이브](../api/#글과-아카이브) 참고) |

`modootoday-check`가 모든 키를 검사합니다. 안정 이름 전체 목록은 [공개 API](../api/)에 있습니다.

## 헤드와 SEO

`url:`을 설정하면 모든 페이지에 canonical 링크와 Open Graph 태그가 들어가며 플러그인이 필요 없습니다. `languages:`를 설정하면 여러 언어로 있는 페이지끼리 `hreflang`으로 연결됩니다. 사이트맵과 피드는 GitHub Pages가 허용하는 플러그인으로 직접 켭니다.

```yaml
url: https://example.github.io
modootoday:
  languages: [en, ko]
  edit_url: https://github.com/OWNER/REPO/edit/main/docs/
plugins: [jekyll-remote-theme, jekyll-sitemap, jekyll-feed]
```

`jekyll-seo-tag`를 쓰려면 `seo: false`로 두고 `_includes/head-custom.html`에 jekyll-seo-tag의 `seo` 태그를 넣으세요. 머리말의 `last_modified_at:`으로 수정일을 표시할 수 있습니다. 브레드크럼의 첫 항목은 홈 페이지 머리말에 `short_title:`이 있으면 그것을, 없으면 `title`을 보여 줘요. 엄격한 콘텐츠 보안 정책은 [CSP](../csp/)를 보세요.

## 언어

인터페이스 문자열은 `_data/i18n/<lang>.yml`에, 페이지는 `<lang>/`에 둡니다.

```yaml
language: 한국어
callout: {note: 참고, tip: 팁, important: 중요, warning: 경고, caution: 주의}
tabs: {label: 설치 방법}
status: {available: 사용 가능, partial: 일부 구현, planned: 계획}
skip: 본문으로 건너뛰기
```

`lang:`만 지정하면 테마가 표시하는 문구(본문 바로가기, 내비게이션, 알림 상자, 상태 배지, 목차, 이전/다음 페이지, 코드 복사, 검색, 언어 메뉴)가 23개 언어로 바로 현지화돼요. 지원 언어는 en, zh-CN, zh-TW, ja, ko, tr, ru, vi, th, de, es, fr, uk, pl, pt-BR, ar, fa, id, it, el, ml, ur-Latn, ro예요. GitHub Pages에서도, Jekyll 4에서도 아무것도 복사할 필요가 없어요. 테마에 없는 지역 코드는 기본 언어를 따르고(`pt` → pt-BR, `zh` → zh-CN), 그 밖의 언어는 영어로 표시돼요.

각 문구는 다음 순서로 정해져요.

1. 사이트의 `_data/i18n/<lang>.yml` (키 단위)
2. 테마에 들어 있는 해당 언어 카탈로그
3. 영어

그래서 사이트 카탈로그에는 바꾸고 싶은 키와 직접 만든 컴포넌트가 쓰는 키만 넣으면 돼요. 확장자는 `.yml`을 쓰세요. 검사기는 `.yaml`을 오류로 처리해요. 테마 문구에서 시작하고 싶다면 카탈로그를 복사한 뒤 검사하세요.

```sh
modootoday-check . _site --i18n-init=ko   # optional: copy the theme's ko.yml to edit
modootoday-check . _site --i18n           # unknown keys and placeholder mismatches
```

테마가 제공하지 않는 언어는 영어 카탈로그와 같은 키로 `_data/i18n/<code>.yml`을 만들고 `languages`에 코드를 추가하세요. 아랍어, 페르시아어, 히브리어, 우르두어 같은 RTL 언어 페이지에는 `dir="rtl"`이 붙어요(`ur-Latn`은 왼쪽에서 오른쪽). 카탈로그나 front matter의 `direction: rtl` 또는 `ltr`로 바꿀 수 있어요. 페이지 본문은 카탈로그가 아니라 `<lang>/` 아래 Markdown으로 번역해요.

테마가 아니라 사이트가 정하는 문구도 있어요. `tabs.label`은 탭을 쓰는 페이지에서 탭 목록의 이름이에요(예: `tabs: {label: 설치 방법}`). 화면 낭독기가 무엇을 고르는 탭인지 읽어 주니, 언어별 카탈로그마다 넣어 주세요.

직접 만든 include에서는 `modootoday/t.html`에 `key="nav.label"`을 넘기면 같은 순서를 따르는 문구를 출력할 수 있어요.

## 컴포넌트 레지스트리

선택 파일 `_data/components.yml`이 있으면 검사기가 `sections:` 매개변수를 검증합니다.

```yaml
features: {params: {cols: {allowed: [2, 3], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```

## 다음

[모양 바꾸기](../customize/) [컴포넌트](../components/)
