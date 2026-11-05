---
lang: ko
permalink: /ko/recipes/widgets/
source_rev: sha256:443928de4781
nav_order: 28
title: 위젯
description: 직접 만든 custom element를 Markdown에서 페이지에 넣고, JavaScript가 없는 독자에게는 대신 읽을 텍스트를 줍니다.
widget_props: {x-counter: {start: 10, step: 10, label: 10 더하기}}
---
# 위젯

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/widgets/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

위젯은 계산기나 실시간 상태 상자처럼 직접 만든 custom element를 Markdown에서 페이지에 넣은 것입니다. 테마는 위젯 코드를 제공하지 않습니다. 테마는 요소를 놓고, 설정을 넘기고, 그 요소가 있는 페이지에서만 모듈을 불러오며, JavaScript가 없는 독자와 github.com, 페이지의 Markdown 버전, `llms-full.txt`를 위해 대체 텍스트를 남깁니다.

## 요소 등록하기

모듈이 정의하는 요소를 적어 `modootoday.scripts`에 항목을 추가합니다.

```yaml
modootoday:
  scripts:
    counter: {src: /assets/js/widgets/x-counter.js, css: /assets/css/widgets/x-counter.css, element: x-counter}
```

- `element`는 custom element 이름입니다. 소문자로 쓰고 하이픈을 넣으며, 테마의 접두사인 `mt-`로 시작할 수 없고, `font-face`처럼 SVG와 MathML이 예약한 이름도 쓸 수 없습니다. 두 항목이 같은 요소를 가리킬 수 없습니다.
- `src`와 `css`는 사이트 안의 경로입니다. `<x-counter`가 있는 페이지는 [모듈 스크립트](../../guides/customize/#module-scripts-and-posters)와 같이 그 항목의 시트와 `<script type="module">`을 `<head>`에 한 번 받습니다. 모듈 스크립트는 `script-src 'self'`가 허용하므로 엄격한 CSP를 바꿀 필요가 없습니다.
- 요소가 없는 페이지는 아무것도 불러오지 않습니다.

## 섹션에 넣기

`c: widget` 섹션은 섹션 제목 뒤에 요소를 놓습니다. 제목 뒤의 텍스트가 대체 텍스트입니다.

```yaml
sections:
  - c: widget
    name: counter
    widget: x-counter
    props: {start: 3, label: 세기}
```

```markdown
## 카운터

카운터는 3에서 시작합니다. JavaScript가 없는 독자는 이 문단을 대신 읽습니다.
```

테마가 쓰는 마크업은 다음과 같습니다.

```html
<x-counter class="mt-widget" data-props="{&quot;start&quot;:3,&quot;label&quot;:&quot;세기&quot;}">
  <div class="mt-widget-fallback"><p>카운터는 3에서 시작합니다. …</p></div>
</x-counter>
```

- `props`는 일반 값(텍스트, 숫자, `true`, `false`)의 맵입니다. 요소는 이를 `data-props`에서 JSON으로 읽습니다.
- 섹션 제목 뒤에는 문단이 적어도 하나 있어야 합니다. 그 문단만으로도 뜻이 통하게 쓰십시오. 한 문장, 결과 표, 같은 일을 하는 페이지로 가는 링크 모두 좋습니다.

[키친싱크](../../components/kitchen-sink/#위젯)에 카운터 섹션이 있습니다.

## 문단에 넣기

`widget:<element>`만 있는 줄은 그 자리에 요소를 놓습니다.

```markdown
`widget:x-counter`
```

props는 요소 이름을 키로 해서 front matter에서 가져옵니다. `widget_props: {x-counter: {start: 10, step: 10}}`처럼 씁니다. 대체 텍스트는 테마 카탈로그의 한 문장(`widget.fallback`, 번역됨)입니다. `modootoday.scripts`에 등록한 요소만 위젯이 되고, 다른 `widget:` 줄은 코드 스팬으로 남으며 `modootoday-check`가 알려 줍니다. 이 페이지에도 하나 있습니다.

`widget:x-counter`

## 요소 만들기

테마와 모듈 사이의 약속은 다음과 같습니다.

- `customElements.define`으로 요소를 정의합니다. 그 전까지 테마는 `div.mt-widget-fallback`을 보여 주고, 요소가 정의되면(CSS `:defined`) 숨깁니다. 모듈이 실패하거나 불러와지지 않으면 대체 텍스트가 그대로 남으며, `<noscript>`는 쓰지 않습니다.
- 설정은 `data-props`에서 읽습니다. [`readConfig`](../../guides/customize/#module-scripts-and-posters)가 파싱합니다. `readConfig(this, {props: {}})`처럼 씁니다.
- 컨트롤은 대체 텍스트 뒤에 추가하고, 대체 텍스트는 요소 안에 그대로 둡니다.
- 컨트롤은 `var(--mt-primary)`, `var(--mt-border)` 같은 테마 토큰으로 꾸며 라이트와 다크 모드를 따르게 하고, 포커스가 보이게 합니다.

이 페이지의 카운터는 30줄짜리 모듈 [x-counter.js](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/assets/js/widgets/x-counter.js)와 7줄짜리 시트입니다.

## 독자가 받는 것

| 독자 | 보는 것 |
|---|---|
| 모듈을 실행하는 브라우저 | 요소 |
| JavaScript가 꺼져 있거나 모듈이 막히거나 실패한 경우 | 대체 텍스트 |
| github.com, Markdown 버전, `llms-full.txt` | 섹션 텍스트와 코드로 보이는 `widget:` 줄 |

`modootoday-check`는 어떤 항목도 등록하지 않은 요소, 일반 값이 아닌 props, 문단이 없는 `c: widget` 섹션, 브라우저가 받아들이지 않을 `element` 이름을 알려 줍니다.
