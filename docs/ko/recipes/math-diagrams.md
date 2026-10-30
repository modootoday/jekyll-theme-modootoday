---
nav_order: 10
title: 수식과 다이어그램
description: 테마에 번들하지 않고, 엄격한 CSP를 깨지 않고 KaTeX 수식과 Mermaid 다이어그램을 넣는 방법.
---
# 수식과 다이어그램

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/math-diagrams/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

테마는 수식·다이어그램 렌더러를 포함하지 않습니다. ```` ```math ````나 ```` ```mermaid ```` 펜스는 사이트에서 코드 블록으로 보이고, github.com에서는 GitHub가 렌더링합니다. 사이트에서도 렌더링하려면 아래 두 방법 중 하나를 고르세요. 둘 다 [엄격한 CSP](../csp/) `default-src 'self'; script-src 'self'; style-src 'self'`와 함께 동작합니다.

| 방법 | 동작 환경 | CSP | 브라우저 JavaScript |
|---|---|---|---|
| 빌드 시 렌더링하고 결과물을 커밋 | 클래식 GitHub Pages, Jekyll 4, 모든 호스트 | 엄격, 추가할 것 없음 | 없음 |
| 렌더러를 직접 호스팅하고 `_includes/footer-custom.html`에서 로드 | 클래식 GitHub Pages, Jekyll 4, 모든 호스트 | KaTeX는 엄격 그대로, Mermaid는 `style-src 'unsafe-inline'` 필요 | 있음 |

렌더러를 CDN에서 불러오지 마세요. `script-src`에 제3자 출처가 추가되고, 페이지가 그 출처의 가용성에 의존하게 됩니다.

## 빌드 시 렌더링

권장하는 방법입니다. 페이지가 정적 SVG를 내보내므로 JavaScript 없이 동작하고, 인쇄가 깔끔하며, 엄격한 CSP를 통과합니다.

### 다이어그램

Mermaid 원본을 Mermaid CLI로 SVG로 렌더링해 커밋하고, 그림(figure)으로 참조합니다. 다시 생성할 수 있도록 원본을 옆에 둡니다.

```sh
npx -y @mermaid-js/mermaid-cli -i assets/diagrams/flow.mmd -o assets/diagrams/flow.svg -b transparent
```

```markdown
![Markdown becomes a page, then the checker verifies the build](../../../assets/diagrams/flow.svg)

*The build flow.*
```

이미지만 있는 문단 뒤에 강조만 있는 문단이 오면 캡션이 달린 그림이 됩니다. 대체 텍스트에는 "다이어그램"이 아니라 다이어그램의 의미를 쓰세요. 다크 모드에서는 `-t dark`로 SVG를 하나 더 만들어 `<picture>`와 `prefers-color-scheme`으로 고르거나, 투명 배경에 양쪽에서 읽히는 중간 톤 색을 쓰세요.

### 수식

커밋 전에 실행하는 스크립트나 GitHub Actions의 Jekyll 4 빌드에서 KaTeX로 수식을 한 번 HTML로 렌더링합니다. 그다음 KaTeX의 CSS와 폰트를 사이트에서 직접 제공합니다. 예시의 `/your-base`는 사이트의 `baseurl`로 바꾸세요(또는 Jekyll의 `relative_url` 필터를 쓰세요).

```sh
npm install katex
mkdir -p assets/katex && cp -r node_modules/katex/dist/katex.min.css node_modules/katex/dist/fonts assets/katex/
```

```html
<!-- _includes/head-custom.html -->
<link rel="stylesheet" href="/your-base/assets/katex/katex.min.css">
```

KaTeX의 정적 출력은 일반 HTML과 CSS 클래스이므로 `style-src 'self'`로 충분합니다.

## 렌더러 직접 호스팅

빌드 단계를 추가할 수 없을 때 씁니다. 렌더러 파일을 사이트에 복사하고 `_includes/footer-custom.html`에서 불러옵니다. 태그를 Liquid `if page.math`(또는 `if page.mermaid`) 블록으로 감싸서 front matter에 그 키를 둔 페이지에서만 로드되게 하세요.

### 브라우저에서 KaTeX

```html
<link rel="stylesheet" href="/your-base/assets/katex/katex.min.css">
<script defer src="/your-base/assets/katex/katex.min.js"></script>
<script defer src="/your-base/assets/js/math.js"></script>
```

```js
// assets/js/math.js: render ```math fences (kramdown: pre > code.language-math)
document.querySelectorAll("code.language-math").forEach((code) => {
  const box = document.createElement("div");
  katex.render(code.textContent, box, { displayMode: true, throwOnError: false });
  code.closest("div.highlighter-rouge, pre").replaceWith(box);
});
```

페이지 front matter에 `math: true`를 추가합니다. 스크립트가 파일이므로 `script-src 'self'`로 충분합니다.

### 브라우저에서 Mermaid

Mermaid는 각 SVG에 `<style>` 요소를 써 넣으므로 엄격한 `style-src 'self'`에서는 스타일이 막힙니다. 빌드 시 렌더링(위)을 쓰거나, 해당 페이지에서만 인라인 스타일을 허용하고 스크립트는 엄격하게 유지하세요.

```html
<script defer src="/your-base/assets/mermaid/mermaid.min.js"></script>
<script defer src="/your-base/assets/js/diagrams.js"></script>
```

```js
// assets/js/diagrams.js
document.querySelectorAll("code.language-mermaid").forEach((code) => {
  const box = document.createElement("pre");
  box.className = "mermaid";
  box.textContent = code.textContent;
  code.closest("div.highlighter-rouge, pre").replaceWith(box);
});
const dark = document.documentElement.dataset.theme === "dark" || (!document.documentElement.dataset.theme && matchMedia("(prefers-color-scheme: dark)").matches);
mermaid.initialize({ startOnLoad: false, theme: dark ? "dark" : "default", securityLevel: "strict" });
mermaid.run();
```

`securityLevel: "strict"`를 유지하세요. 다이어그램 안의 클릭 핸들러와 HTML 레이블을 끕니다.

## 점검 목록

- 원본이 Markdown에 남아 있어 github.com과 [Markdown 버전](../../guides/agents/)을 읽는 에이전트도 볼 수 있습니다.
- CSP에 제3자 출처가 없습니다.
- 모든 다이어그램에 무엇을 보여 주는지 밝히는 대체 텍스트나 캡션이 있습니다.
- 렌더러는 필요한 페이지에서만 불러옵니다.
