---
lang: ko
permalink: /ko/guides/customize/
source_rev: sha256:308b03f8a9c4
nav_order: 40
title: 커스터마이즈
description: 토큰과 토큰 브리지로 색·모서리·글꼴을 바꾸고, 직접 만든 스타일시트를 더하거나 Sass 파셜을 덮어씁니다.
sections:
  - tokens
  - bridge
  - code
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

직접 만든 스타일시트에서 덮어쓰려면 테마의 다크 스킴 선택자(`:root[data-theme]`, `prefers-color-scheme` 규칙)보다 우선해야 합니다. 지원하는 방법은 세 가지입니다.

- [토큰 브리지](#토큰-브리지)에 값을 둡니다(권장). 테마가 자기 토큰 규칙에 넣어 컴파일하므로 인라인으로 나가는 것이 없습니다.
- 값을 `modootoday.tokens`와 `modootoday.tokens_dark`에 적습니다. 테마가 자기 토큰과 같은 선택자로 인라인 `<style>`에 출력하므로, 엄격한 CSP에서는 막힙니다.
- `modootoday.css_layers: true`로 설정합니다. 테마 CSS가 `@layer mt.*` 안에 들어가고 레이어 밖 규칙이 이기므로, 평범한 `:root { … }`로 충분합니다.

다크 모드의 이미지: 사진은 `--mt-img-filter-dark`를, `.svg` 그림(다이어그램)은 색상을 유지한 채 반전한 뒤 `--mt-img-filter-dark`를 적용하는 `--mt-diagram-filter-dark`를 씁니다. 둘 다 토큰에서 바꿀 수 있습니다. 예를 들어 `--mt-diagram-filter-dark: none`이면 모든 다이어그램을 그린 그대로 둡니다. 이미지 하나의 경로 끝에 `#light`를 붙이면(`flow.svg#light`) 그 이미지만 그대로 둡니다. [수식과 다이어그램](../../recipes/math-diagrams/#다이어그램)을 참고하세요.

## 토큰 브리지

사이트에 `_sass/modootoday/_site.scss`를 만들고 맵을 최대 세 개까지 설정합니다. 테마가 이 파일을 설정보다 먼저 가져오므로, core 시트와 모든 선택 시트가 라이트와 다크 모드에서 이 값을 씁니다.

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (font-sans: (Inter, system-ui, sans-serif), font-heading: (Fraunces, Georgia, serif));
$mt-overrides: (primary: #0f766e, link: #0f766e);
$mt-overrides-dark: (primary: #2dd4bf, link: #5eead4);
```

`$mt-overrides-base`는 색 구성표와 무관한 토큰(글꼴, 크기, 모서리)을, 나머지 둘은 라이트와 다크 모드의 색을 받습니다. 기존 토큰 외에 `h1`~`h4`용 `font-heading`과 `heading-weight`, 본문 링크용 `link`와 `link-hover`가 있습니다. 기본값은 각각 `font-sans`, 600, `primary`를 따릅니다. 이 파일에는 이 세 맵만, 테마가 정의한 토큰 이름으로만 쓸 수 있습니다. 그 밖의 내용은 `modootoday-check`가 알려 줍니다.

사이트가 `lang`이나 `modootoday.languages`에 선언한 한국어, 일본어, 중국어 페이지는 언어마다 따로 `font-sans` 목록을 받습니다. 그 문자의 시스템 글꼴이며, 한국어는 사이트가 Pretendard를 불러오면 그것을 먼저 씁니다(테마는 Pretendard를 싣지 않습니다). 영어만 쓰는 사이트에는 하나도 출력되지 않습니다. 브리지나 `modootoday.tokens`에서 `font-sans`를 지정하면 이 목록은 꺼지고, 지정한 글꼴이 모든 언어에 쓰입니다.

설정 두 개로 사이트의 파일을 테마 파일 옆에 붙입니다.

```yaml
modootoday:
  site_css: [/assets/css/site.css]   # 테마 시트 뒤에 연결. front matter site_css:는 그 페이지에만 시트를 더함
  preload:                           # 스타일시트 앞의 <link rel="preload">. front matter preload:는 페이지별
    - {href: /assets/fonts/inter.woff2, as: font, type: font/woff2}
```

색 팔레트, 자체 호스팅 글꼴, 대비 검사를 갖춘 예제는 [브랜드 토큰](../../recipes/brand-tokens/)에 있습니다.

## 코드 색

코드 블록은 `--mt-code-*` 토큰에서 색을 가져옵니다. `modootoday.code_theme: github`를 설정하면 GitHub의 라이트·다크 팔레트로 바뀝니다([데모](../../layouts/demo/code-github/)).

```yaml
modootoday:
  code_theme: github   # theme (default) or github
```

색은 GitHub의 편집기 테마(github-light-default, github-dark-default)에서 가져왔습니다. Rouge는 편집기와 다른 기준으로 토큰을 나누므로, 팔레트는 GitHub와 같아도 단어 하나의 색은 다를 수 있습니다. 토큰은 `code-background`, `code-foreground`, `code-keyword`, `code-string`, `code-comment`, `code-function`, `code-constant`, `code-variable`, `code-type`, `code-number`, `code-operator`, `code-tag`, `code-attribute`, `code-inserted`, `code-deleted`입니다. 기본값 `theme`에서는 새로 생긴 열 개가 기존 다섯 개를 따르므로 코드가 전과 똑같이 보입니다. 토큰 브리지는 프리셋 다음에 적용되므로 `$mt-overrides: (code-comment: #57606a)`처럼 색 하나만 바꿀 수 있습니다. 코드 색은 Jekyll 기본값인 Rouge(`kramdown.syntax_highlighter`)가 있어야 하며, 다른 하이라이터를 설정하면 `modootoday-check`가 경고합니다.

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

### 모듈 스크립트와 포스터

캔버스나 움직이는 SVG처럼 JavaScript가 필요한 비주얼은 ES 모듈을 `modootoday.scripts`에 한 번 등록하고, 히어로나 섹션 항목에서 `script:`로 이름을 적습니다. 그 이름을 적은 페이지만 모듈을 불러옵니다. 테마는 항목의 `css` 시트, `preload` 경로마다 `<link rel="modulepreload">`, `<script type="module">`을 `<head>`에 페이지당 한 번씩 넣습니다. 경로는 모두 사이트 경로입니다. 모듈 스크립트는 지연 실행되고 `script-src 'self'`로 허용되므로 엄격한 CSP를 바꿀 필요가 없습니다. `preload`에는 모듈이 가져오는 모듈이 다시 가져오는 모듈(두 단계 아래)만 적으세요. 직접 가져오는 모듈에는 힌트가 필요 없습니다.

```yaml
# _config.yml
modootoday:
  scripts:
    orbit: {src: /assets/js/hero/orbit.js, css: /assets/css/orbit.css, preload: [/assets/js/hero/scene.js]}
```

```yaml
hero: {c: split, visual: orbit-stage, script: orbit, poster: {path: /assets/hero/orbit-960.webp, srcset: "/assets/hero/orbit-640.webp 640w, /assets/hero/orbit-960.webp 960w", width: 960, height: 960}}
```

`poster:`는 `hero.image`와 같은 꼴입니다. 경로를 쓰거나 `{path, srcset, sizes, width, height}`를 씁니다. 이미지가 오기 전에 자리를 잡아 두도록 `width`와 `height`는 꼭 적어야 합니다. 테마는 포스터를 비주얼 열 맨 앞에 `img.mt-visual-poster`로 넣습니다. 히어로에서는 높은 우선순위로 받으므로 대개 페이지의 최대 콘텐츠 페인트(LCP)가 되고, 섹션에서는 지연 로딩됩니다. 분할 항목에 `script:`나 `poster:`가 있으면 `visual:`이 없어도 됩니다. 분할이 아니면 포스터와 include가 `div.mt-visual` 안에 들어갑니다. 비주얼 열에는 `data-mt-script="<name>"`이 붙습니다.

모듈이 지켜야 할 계약:

- `prefers-reduced-motion: reduce`이면 아무것도 하지 않습니다. 포스터가 남습니다. JavaScript가 꺼져 있거나 모듈이 실패해도 포스터가 남습니다.
- 포스터 뒤에 있는 `mt-visual-stage` 클래스 요소에 그립니다. 이 요소는 `visual:` include에서 낼 수 있고, 포스터 자리를 덮습니다.
- 첫 장면을 그린 뒤 `[data-mt-script]` 열에 `data-mt-ready`를 붙입니다. 그러면 테마가 포스터를 숨깁니다.
- 설정은 `readConfig`(`/assets/js/modootoday/dom/config.js`)로 `data-*` 속성에서 읽고, 라이트와 다크 전환은 `onThemeChange`(`/assets/js/modootoday/theme/current.js`, [이벤트](../../reference/api/#이벤트) 참고)로 따라갑니다. `../modootoday/dom/config.js`처럼 상대 경로로 가져오세요.

[히어로 모듈 데모](../../layouts/demo/orbit/)는 이 계약을 따르는 40줄짜리 모듈입니다.

`full_width: true`는 랜딩 페이지용으로 `main.mt-main`의 본문 폭 제한과 좌우 여백을 없앱니다(`.mt-main-full` 추가).

## Sass 파셜

직접 쓸 규칙은 사이트의 스타일시트에 적고 `site_css`에 올리세요. 테마 시트 뒤에 불러오므로 같은 선택자라면 이 규칙이 이깁니다.

```scss
---
---
.mt-hero h1 { letter-spacing: -0.02em; }
```

Jekyll은 테마보다 사이트의 `_sass/`를 먼저 읽습니다. 이미 `assets/css/modootoday.scss`를 섀도잉한 사이트도 그대로 동작하고, 토큰 훅도 그대로 적용됩니다. 테마가 훅을 core 파셜에서 가져오기 때문입니다.

> [!WARNING]
> `@use`가 아니라 `@import`를 쓰세요. GitHub Pages는 Ruby Sass로 컴파일하며 `@use`를 그대로 출력합니다.

## 레이아웃과 include 섀도잉

테마의 `_layouts/`, `_includes/`, `assets/` 파일은 사이트에 같은 경로의 파일을 두면 대체됩니다. `_sass/`에서는 테마가 Sass 로드 경로로 가져오는 파셜만 그렇습니다. 토큰 훅 `_sass/modootoday/_site.scss`, `_sass/modootoday/_access.scss`, `_sass/modootoday/components/` 아래의 컴포넌트 파셜입니다(FAQ 시트는 그래도 테마의 `_details.scss`를 읽습니다). 나머지 파셜(설정, 도구, 토큰, 기본 스타일, 레이아웃, 레이아웃별 시트)은 그 파셜을 쓰는 테마 파일을 기준으로 상대 경로로 가져오므로, GitHub Pages와 Jekyll 4 모두 Sass가 테마의 파일을 읽고 사이트의 파일은 무시합니다. `_core.scss`, `_sheet.scss`, 레이아웃별 `_index.scss`를 복사해 두면 상대 경로로 가져오는 파일이 옆에 없어서 빌드가 실패합니다. 컴포넌트 파셜은 내부 API라서 섀도잉하면 테마를 업데이트할 때 깨질 수 있습니다. 나머지를 바꾸려면 `site_css`로 규칙을 더하거나 `assets/css/` 아래의 스타일시트를 섀도잉하세요.

페이지 head에 태그를 넣으려면 `_includes/head-custom.html`을 쓰세요.

```html
<link rel="icon" href="/favicon.svg">
```

> [!CAUTION]
> 섀도잉한 파일은 테마 업데이트를 받지 못합니다. 토큰과 `head-custom.html`을 먼저 쓰세요.

class가 없는 목록은 항목 사이에 작은 간격이 생깁니다. 레이아웃이나 include에서 class가 없는 Markdown 목록을 grid나 flex 행으로 바꾸면(예: `.c-body > ul`) `<div class="c-body mt-flat-list">`처럼 상위 요소에 `mt-flat-list`를 붙입니다. 그러면 첫 항목이 나머지 항목과 맞게 정렬됩니다. 자체 class가 있는 목록에는 간격이 생기지 않습니다.

## 다음

[에이전트용 Markdown](../agents/) [설정](../configuration/)
