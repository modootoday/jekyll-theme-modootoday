---
nav_order: 40
title: 커스터마이즈
description: 토큰으로 색·모서리·글꼴을 바꾸거나 Sass 파셜을 덮어씁니다.
sections:
  - tokens
  - visuals
  - sass
  - shadow
  - {c: cta, name: next}
---
# 커스터마이즈

토큰부터 시작하세요. 토큰으로 부족할 때만 Sass 파셜을 씁니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/customize/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 디자인 토큰

테마는 CSS 사용자 정의 속성을 노출합니다. 직접 만든 스타일시트나 `modootoday.tokens`로 덮어씁니다.

```css
:root {
  --mt-primary: #0f766e;
  --mt-radius: 0.75rem;
}
```

직접 만든 스타일시트에서 덮어쓰려면 테마의 다크 스킴 선택자(`:root[data-theme]`, `prefers-color-scheme` 규칙)보다 우선해야 합니다. 지원하는 방법은 두 가지입니다.

- 값을 `modootoday.tokens`와 `modootoday.tokens_dark`에 적습니다. 테마가 자기 토큰과 같은 선택자로 출력합니다.
- `modootoday.css_layers: true`로 설정합니다. 테마 CSS가 `@layer mt.*` 안에 들어가고 레이어 밖 규칙이 이기므로, 평범한 `:root { … }`로 충분합니다.

## 섹션 비주얼과 전체 폭 페이지

`sections:` 항목에 `visual: <name>`을 쓰면 그 섹션 끝에 사이트의 `_includes/sections/<name>.html`이 렌더링됩니다. include는 항목을 `include.section`으로 받으므로 `scene:` 같은 추가 키도 전달됩니다. front matter의 `hero: {visual: <name>}`은 첫 `##` 앞부분에 같은 일을 합니다(`sections:`가 있어야 합니다). include가 없으면 `modootoday-check`가 실패합니다.

```yaml
---
full_width: true
hero: {visual: player-mock}
sections: [{c: features, name: why, visual: chart, scene: night}, faq]
---
```

테마에는 히어로 비주얼 `showcase`가 하나 들어 있습니다. 은은한 배경 이미지, 토큰 기반 오버레이, SVG로 그린 UI 장면 애니메이션을 겹쳐 보여 줍니다. 스타일시트는 이 비주얼을 쓰는 페이지에만 붙고, JavaScript 없이 5초 안에 움직임이 멈춥니다. 모션 줄이기 설정에서는 마지막 장면만 보입니다. 다크 모드에서는 같은 이미지를 CSS filter로 어둡게 하며, `--mt-img-filter-dark`로 바꿀 수 있습니다. 직접 만든 이미지를 쓰려면 `hero.image`에 경로나 `{path, srcset, width, height}`를 지정하세요. 홈 레이아웃의 히어로와 같은 `hero.image` 키입니다. [홈 화면](../../)에서 실제 모습을 볼 수 있습니다.

```yaml
hero: {visual: showcase}
# 또는: hero: {visual: showcase, image: {path: /assets/hero.webp, srcset: "/assets/hero-800.webp 800w, /assets/hero.webp 1600w", width: 1600, height: 900}}
```

`full_width: true`는 랜딩 페이지용으로 `main.mt-main`의 본문 폭 제한과 좌우 여백을 없앱니다(`.mt-main-full` 추가).

## Sass 파셜

Jekyll은 테마보다 사이트의 `_sass/`를 먼저 읽습니다. `assets/css/modootoday.scss`를 만들어 테마 뒤에 규칙을 추가하세요.

```scss
---
---
@import "modootoday";

.mt-hero h1 { letter-spacing: -0.02em; }
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
