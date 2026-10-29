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
  color_scheme: auto  # auto | light | dark
  components: [callout, badge, cta, card, tabs]
  tokens: {primary: "#4f46e5", radius: "0.5rem"}
  nav: main
```

| 키 | 기본값 | 효과 |
|---|---|---|
| `badges` | `true` | 상태 코드 스팬을 배지로 바꿈. `false`면 코드 그대로 |
| `color_scheme` | `auto` | OS를 따르거나 라이트·다크 고정 |
| `components` | 전체 | 내보낼 CSS와 JS를 제한 |
| `css_layers` | `false` | 테마 CSS를 `@layer mt.*`로 감쌈 |
| `nav` | `main` | `_data/nav/`의 내비게이션 파일. `items:`가 있는 항목은 넓은 화면에서 드롭다운 그룹이 됨 |
| `tokens`, `tokens_dark` | 테마 값 | 시맨틱 디자인 토큰을 인라인으로 덮어씀 |
| `twins` | 스텁 | 머리말 없는 쌍둥이는 `source` ([에이전트](../agents/) 참고) |
| `seo` | `true` | `false`면 내장 canonical, hreflang, Open Graph 태그를 뺌 |
| `languages` | 없음 | `hreflang`용 언어 코드, 예: `[en, ko]` 헤더의 사이트 제목은 해당 언어의 홈(`/<lang>/`)이 있으면 그곳으로 연결됩니다. |
| `language_switcher` | 없음 | `header`(지구본 버튼과 드롭다운 메뉴, 언어 수와 상관없이 폭 고정) 또는 `footer`(언어 이름 목록)로 `languages` 기반 언어 전환기를 표시. 각 링크는 이 페이지의 번역본, 없으면 그 언어의 첫 페이지로 이동. 언어가 둘 미만이면 렌더하지 않음. 메뉴는 JavaScript 없이 열리고, `menu.js`가 Esc, 화살표 키, 바깥 클릭 시 닫기를 더함 |
| `og_image` | 없음 | 기본 Open Graph 이미지. 머리말의 `image:`가 우선 |
| `feed` | `false` | `true`면 `/feed.xml` 링크 추가 (`plugins`에 `jekyll-feed` 필요) |
| `csp` | 없음 | `strict`면 사전 페인트 스크립트를 인라인 대신 파일로 불러옴 |
| `edit_url` | 없음 | "이 페이지 편집" 링크의 앞부분, `/`로 끝남 |

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

`jekyll-seo-tag`를 쓰려면 `seo: false`로 두고 `_includes/head-custom.html`에 jekyll-seo-tag의 `seo` 태그를 넣으세요. 머리말의 `last_modified_at:`으로 수정일을 표시할 수 있습니다. 엄격한 콘텐츠 보안 정책은 [CSP](../csp/)를 보세요.

## 언어

인터페이스 문자열은 `_data/i18n/<lang>.yml`에, 페이지는 `<lang>/`에 둡니다.

```yaml
language: 한국어
callout: {note: 참고, tip: 팁, important: 중요, warning: 경고, caution: 주의}
tabs: {label: 설치 방법}
status: {available: 사용 가능, partial: 일부 구현, planned: 계획}
skip: 본문으로 건너뛰기
```

없는 키는 영어로 대체됩니다.

## 컴포넌트 레지스트리

선택 파일 `_data/components.yml`이 있으면 검사기가 `sections:` 매개변수를 검증합니다.

```yaml
features: {params: {cols: {allowed: [2, 3], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```

## 다음

[모양 바꾸기](../customize/) [컴포넌트](../components/)
