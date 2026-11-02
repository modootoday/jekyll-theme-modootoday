---
nav_order: 15
nav_title: 브랜드 토큰
title: 브랜드 토큰
description: 토큰 브리지로 브랜드의 색과 글꼴을 테마에 입히고, 사이트 스타일시트와 미리 불러오는 글꼴까지 엄격한 CSP에서 씁니다.
site_css: [/assets/css/brand-demo.css]
preload:
  - {href: /assets/fonts/fraunces/fraunces-600-latin.woff2, as: font, type: font/woff2}
---
# 브랜드 토큰

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/brand-tokens/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

이 페이지에는 가상의 청록색 브랜드와 자체 호스팅한 제목 글꼴을 입혔습니다. 라이트와 다크를 바꿔 가며 두 팔레트를 확인해 보세요. 나머지 문서는 기본 모습을 그대로 유지합니다.

## 토큰 브리지

사이트에 `_sass/modootoday/_site.scss`를 만듭니다. 테마가 이 파일을 자기 설정보다 먼저 가져오므로, 여기서 설정한 맵이 core 시트와 모든 선택 시트의 토큰을 바꿉니다. 인라인으로 나가는 것이 없고, `assets/css/modootoday.scss`를 섀도잉할 필요도 없습니다.

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (font-heading: ("Fraunces", var(--mt-font-sans)), heading-weight: 600);
$mt-overrides: (
  primary: #0f766e, primary-foreground: #ffffff, link: #0f766e, link-hover: #115e59,
  background: #fbfdfc, foreground: #10302c, muted: #eef6f4, muted-foreground: #4b635f, border: #cfe3df
);
$mt-overrides-dark: (
  primary: #2dd4bf, primary-foreground: #042f2b, link: #5eead4, link-hover: #99f6e4,
  background: #0b1615, foreground: #e3f2ef, muted: #13211f, muted-foreground: #9db5b0, border: #24403b
);
```

| 맵 | 토큰 | 출력 위치 |
|---|---|---|
| `$mt-overrides-base` | `font-sans`, `font-mono`, `font-heading`, `heading-weight`, `font-size`, `line-height`, `measure`, `radius` 등 색 구성표와 무관한 토큰 | `:root` |
| `$mt-overrides` | `primary`, `link`, `link-hover`, `background`, `foreground`, `border` 같은 색 토큰 | `:root`(라이트) |
| `$mt-overrides-dark` | 다크 모드의 같은 색 토큰 | 다크 구성표 선택자 |

색은 두 맵에 모두 지정하세요. 다크 선택자는 모든 색 토큰을 다시 출력하므로, `$mt-overrides`에만 둔 값은 다크 모드에 반영되지 않습니다.

이 파일에는 이 세 맵만 둘 수 있습니다. 다른 문장이나 테마에 없는 토큰 이름이 있으면 `modootoday-check`가 실패하므로, 오타가 그대로 지나가지 않습니다.

> [!TIP]
> `font-heading`과 `heading-weight`는 `h1`~`h4`에, `link`와 `link-hover`는 본문 링크에 적용됩니다. 기본값은 각각 `font-sans`, 650, `primary`를 따르므로, `primary`만 바꾼 사이트에서는 달라지는 것이 없습니다.

## 사이트 스타일시트와 글꼴

```yaml
modootoday:
  site_css: [/assets/css/site.css]
  preload:
    - {href: /assets/fonts/fraunces-600-latin.woff2, as: font, type: font/woff2}
```

- `site_css`는 사이트의 시트를 테마 시트 뒤, `modootoday.tokens`와 `head-custom.html` 앞에 연결합니다. 테마 파일과 같은 `?v=` 쿼리가 붙습니다. 페이지 front matter에 `site_css:`를 적으면 그 페이지에만 시트를 연결하며, 이 페이지가 그렇게 합니다. `css_layers: true`와 함께 쓰면 사이트 규칙이 언제나 테마 규칙을 이깁니다.
- `preload`는 스타일시트 앞에 `<link rel="preload">`를 내서, 브라우저가 CSS를 읽는 동안 글꼴을 먼저 받기 시작하게 합니다. 글꼴에는 `crossorigin`이 붙습니다. URL에는 `?v=` 쿼리가 붙지 않습니다. `@font-face`의 `url()`과 같아야 하며, 다르면 브라우저가 글꼴을 두 번 내려받습니다. front matter의 `preload:`도 페이지별로 동작합니다.

```scss
@font-face {
  font-family: "Fraunces";
  src: url("/assets/fonts/fraunces-600-latin.woff2") format("woff2");
  font-weight: 500 800;
  font-display: swap;
}
```

두 키 모두 사이트 경로만 받습니다. 외부 시트는 `head-custom.html`에서 불러오세요.

## 대비

배포 전에 두 팔레트를 모두 확인하세요. 배경과 `muted` 위의 본문, 배경 위의 `primary`와 `link`, `primary` 위의 `primary-foreground`는 4.5:1 이상이어야 합니다. 테마의 문서 QA가 같은 기준으로 이 페이지를 라이트와 다크 모드에서 잽니다.

## 엄격한 CSP에서

브리지, `site_css`, `preload`는 모두 파일이므로 `default-src 'self'; style-src 'self'`로 충분합니다([CSP](../csp/) 참고). `modootoday.tokens`는 인라인 `<style>`로 출력되므로, 엄격한 CSP 사이트에서는 그 값을 브리지로 옮기세요.

## 데모 글꼴

이 페이지의 제목 글꼴은 [Fraunces](https://github.com/undercasetype/Fraunces)이며 SIL Open Font License 1.1을 따릅니다. 문서에는 굵기 600 인스턴스 하나를 라틴 문자로 줄여 넣었습니다. 라이선스와 출처는 파일 옆 `docs/assets/fonts/fraunces/` 폴더에 있습니다. 다른 문자의 제목은 `font-sans`로 표시됩니다.
