---
nav_order: 10
title: 수식과 다이어그램
description: 내장 로더, 빌드 시 렌더링, 직접 만든 로더로 Mermaid 다이어그램과 KaTeX 수식을 렌더링하는 방법과 각 방법이 CSP와 개인정보에 미치는 영향.
---
# 수식과 다이어그램

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/math-diagrams/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

```` ```math ````나 ```` ```mermaid ```` 펜스는 렌더러를 켜기 전까지 코드 블록으로 보이고, github.com에서는 GitHub가 렌더링합니다. 사이트에서 렌더링하는 방법은 세 가지입니다.

| 방법 | 동작 환경 | CSP | 브라우저 JavaScript |
|---|---|---|---|
| [내장 로더](#내장-로더): `modootoday.mermaid`, `modootoday.math` | 클래식 GitHub Pages, Jekyll 3.10과 4, 모든 호스트 | 직접 호스팅: `'self'`, CDN: CDN 출처 추가(아래 참고) | 있음, 블록이 있는 페이지에서만 |
| [빌드 시 렌더링](#빌드-시-렌더링)하고 결과물을 커밋 | 클래식 GitHub Pages, Jekyll 4, 모든 호스트 | 엄격, 추가할 것 없음 | 없음 |
| `_includes/footer-custom.html`의 [직접 만든 로더](#직접-만든-로더) | 클래식 GitHub Pages, Jekyll 4, 모든 호스트 | KaTeX는 엄격 그대로, Mermaid는 `style-src 'unsafe-inline'` 필요 | 있음 |

## 내장 로더

둘 다 기본으로 꺼져 있습니다. `_config.yml`에서 켜고, **정확한 버전**을 담은 렌더러 URL과 그 [하위 리소스 무결성](https://developer.mozilla.org/ko/docs/Web/Security/Subresource_Integrity)(SRI) 해시를 지정하거나, 사이트에 둔 사본의 경로를 지정합니다.

```yaml
modootoday:
  mermaid:
    enabled: true
    src: https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js
    integrity: sha384-…   # 그 파일의 정확한 해시
    theme: auto           # auto(페이지의 라이트·다크 모드를 따름), default, dark, neutral, forest
  math:
    enabled: true
    engine: katex
    src: https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js
    css: https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css
    integrity: {js: sha384-…, css: sha384-…}
    auto_render_src: https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js
    auto_render_integrity: sha384-…
    inline: false
```

- **필요한 곳에서만.** 블록이 있는 페이지에서만 태그를 로드합니다. Mermaid는 `language-mermaid`, 수식은 ```` ```math ```` 펜스나 `$$` 블록이 기준입니다. 한 페이지만 빼려면 front matter에 `mermaid: false`나 `math: false`를 넣습니다.
- **해시가 없으면 로드하지 않습니다.** `integrity`가 없는 CDN URL(또는 https가 아닌 URL)은 아무것도 로드하지 않고, `modootoday-check`가 오류를 보고합니다. 검사기는 URL에 정확한 버전(`@11`이나 `@latest`가 아닌 `@11.4.1`)도 요구하며, 빌드된 페이지의 다른 제3자 스크립트·스타일시트도 보고합니다.
- **직접 호스팅.** `/assets/vendor/mermaid.min.js` 같은 경로는 사이트에서 로드합니다(`relative_url` 적용, `integrity`는 선택). KaTeX는 `katex` 패키지에서 `katex.min.js`, `katex.min.css`, `fonts/` 폴더, `contrib/auto-render.min.js`를 복사합니다.
- **JavaScript 없이도 읽을 수 있습니다.** 렌더러가 바꾸기 전까지 소스가 코드 블록으로 남고, 다이어그램이나 수식을 해석하지 못하면 그대로 남습니다.
- **라이트와 다크.** `theme: auto`면 페이지가 다크일 때(테마 토글이나 방문자의 시스템 설정) Mermaid의 `dark` 테마를 쓰고, 바뀌면 다시 그립니다. 동작 줄이기를 요청하면 다이어그램 애니메이션을 끕니다. 본문보다 넓은 다이어그램은 키보드로 포커스할 수 있는 자체 영역 안에서 스크롤됩니다.
- 각 로더는 별도의 작은 스크립트(`assets/js/modootoday-mermaid.js`, `assets/js/modootoday-math.js`)이고, 코어 스크립트와 별도의 크기 예산이 있습니다.

### 수식 표기

```` ```math ```` 펜스나 한 줄을 차지하는 `$$` 블록을 쓰세요. 둘 다 표준 표기이며 github.com에서도 렌더링됩니다. `$$` 블록에는 `auto_render_src`가 필요하고, 없으면 펜스만 렌더링합니다. 인라인 `$…$`는 `inline: true`일 때만 렌더링합니다. 그렇지 않으면 일반 문장의 `$`(가격, 셸 변수)가 수식으로 바뀌기 때문입니다. `inline: false`면 `modootoday-check`가 페이지의 인라인 `$…$`에 경고합니다. 문장 안에 쓴 `$$…$$`는 kramdown이 인라인 수식으로 출력하며, `auto_render_src`가 있으면 렌더링됩니다.

### CSP와 개인정보

CDN을 쓰면 콘텐츠 보안 정책과 방문자 개인정보가 달라집니다.

- **CSP.** CDN 출처를 `script-src`(둘 다), `style-src`(KaTeX 스타일시트), `font-src`(KaTeX 글꼴)에 추가합니다. Mermaid는 각 다이어그램에 `<style>`을 쓰므로 어디서 호스팅하든 `style-src 'unsafe-inline'`이 필요합니다. 직접 호스팅하면 스크립트·스타일·글꼴 모두 `'self'`로 유지됩니다. [콘텐츠 보안 정책](../csp/)을 참고하세요.
- **개인정보.** 방문자의 브라우저가 CDN에 파일을 요청하므로, CDN은 방문자의 IP 주소, 페이지 주소(리퍼러), 시각을 받습니다. 직접 호스팅하면 이를 피할 수 있습니다. CDN을 쓴다면 개인정보 처리방침에 밝히세요.
- **가용성.** CDN을 쓰면 그 CDN에 접속할 수 있을 때만 블록이 렌더링되고, 아니면 소스 코드 블록이 남습니다.

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

## 직접 만든 로더

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
- CSP에 제3자 출처가 없거나, CDN 출처를 명시하고 `integrity`로 고정했습니다.
- 모든 다이어그램에 무엇을 보여 주는지 밝히는 대체 텍스트나 캡션이 있습니다.
- 렌더러는 필요한 페이지에서만 불러옵니다.
