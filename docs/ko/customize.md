---
title: 커스터마이즈
description: 토큰으로 색·모서리·글꼴을 바꾸거나 Sass 파셜을 덮어씁니다.
sections:
  - tokens
  - sass
  - shadow
  - {c: cta, name: next}
---
# 커스터마이즈

토큰부터 시작하세요. 토큰으로 부족할 때만 Sass 파셜을 씁니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../customize/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 디자인 토큰

테마는 CSS 사용자 정의 속성을 노출합니다. 직접 만든 스타일시트나 `modootoday.tokens`로 덮어씁니다.

```css
:root {
  --mt-primary: #0f766e;
  --mt-radius: 0.75rem;
}
```

## Sass 파셜

Jekyll은 테마보다 사이트의 `_sass/`를 먼저 읽습니다. `assets/css/modootoday.scss`를 만들어 테마 뒤에 규칙을 추가하세요.

```scss
---
---
@import "modootoday";

.md-hero h1 { letter-spacing: -0.02em; }
```

> [!WARNING]
> `@use`가 아니라 `@import`를 쓰세요. GitHub Pages는 Ruby Sass로 컴파일하며 `@use`를 그대로 출력합니다.

## 레이아웃과 include 섀도잉

테마의 `_layouts/`, `_includes/`, `_sass/` 파일은 사이트에 같은 경로의 파일을 두면 대체됩니다. 페이지 head에 태그를 넣으려면 `_includes/head-custom.html`을 쓰세요.

```html
<link rel="icon" href="/favicon.svg">
```

> [!CAUTION]
> 섀도잉한 파일은 테마 업데이트를 받지 못합니다. 토큰과 `head-custom.html`을 먼저 쓰세요.

## 다음

[에이전트용 Markdown](../agents/) [설정](../configuration/)
