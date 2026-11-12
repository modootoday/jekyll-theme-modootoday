---
lang: ko
permalink: /ko/guides/configuration/
source_rev: sha256:5f7f41c5a973
nav_order: 20
title: 설정
description: _config.yml의 modootoday 키 아래에 두는 사이트 전체 설정을 모두 정리하고, 각 설정의 기본값, 바뀌는 점, 자세히 설명하는 페이지를 알려 줍니다.
sections:
  - keys
  - new-window
  - head
  - i18n
  - registry
---
# 설정

모두 선택 사항입니다. 다른 플러그인과 겹치지 않도록 설정은 `modootoday:` 키 하나에 모입니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/configuration/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 키

```yaml
modootoday:
  color_scheme: auto  # auto | auto-dark | auto-light | light | dark
  components: [callout, badge, cta, card, tabs]
  tokens: {primary: "#4f46e5", radius: "0.5rem"}
  nav: main
```

| 키 | 기본값 | 하는 일 |
|---|---|---|
| `badges` | `true` | 상태 코드 스팬을 배지로 보여 줍니다. `false`면 코드 그대로 둡니다. |
| `code_theme` | `theme` | 코드 블록 색입니다. 테마 색(`theme`)이나 GitHub 색(`github`)을 고릅니다. [코드 색](../customize/#코드-색) 참고. |
| `color_scheme` | `auto` | 라이트·다크 모드입니다. `auto`는 기기를 따르고, `auto-dark`·`auto-light`는 시작 모드를, `light`·`dark`는 고정 모드를 정합니다. |
| `components` | 전체 | 사이트가 내보낼 컴포넌트 CSS와 JS를 줄입니다. |
| `css_layers` | `false` | 테마 CSS를 `@layer mt.*`로 감쌉니다. |
| `nav` | `main` | 메뉴를 만드는 `_data/nav/`의 파일입니다. `items:`가 있는 항목은 그룹이 됩니다. |
| `sidebar` | `auto` | `doc` 페이지의 사이드 메뉴입니다. `auto`는 메뉴에 그룹이 있을 때, `true`는 항상, `false`는 표시하지 않습니다. |
| `page_actions` | `true` | 페이지를 복사하거나 Markdown으로 보는 메뉴입니다. `false`면 끕니다. |
| `tokens` | 테마 값 | 테마 색 같은 디자인 토큰을 바꿉니다. 엄격한 CSP 사이트는 [토큰 브리지](../customize/#토큰-브리지)를 씁니다. |
| `tokens_dark` | 테마 값 | 같은 일을 다크 모드에서만 합니다. |
| `site_css` | 없음 | `[/assets/css/site.css]`처럼 직접 만든 스타일시트를 테마 시트 뒤에 불러옵니다. [브랜드 토큰](../../recipes/brand-tokens/) 참고. |
| `preload` | 없음 | 글꼴처럼 브라우저가 먼저 받을 파일입니다. `{href, as, type}` 목록으로 적습니다. |
| `scripts` | 없음 | 직접 만든 JavaScript 모듈입니다. `script:`로 이름을 적었거나 그 `element`(위젯)가 있는 페이지만 불러옵니다. [모듈 스크립트와 포스터](../customize/#모듈-스크립트와-포스터), [위젯](../../recipes/figures/widgets/) 참고. |
| `search` | 없음 | 헤더 검색 설정입니다. 색인할 글의 양과 검색어를 맞추는 방식을 정합니다. [검색](../../recipes/search/) 참고. |
| `twins` | 스텁 | 페이지마다 Markdown 사본을 내는 방식입니다. `source`는 front matter 없는 페이지를 씁니다. [AI 에이전트](../agents/) 참고. |
| `aliases` | 없음 | 에이전트용 추가 URL입니다. `md: true`는 `/<page>.md`를 더하고, `html: true`는 `/<page>.html`을 리다이렉트합니다. [URL 별칭](../agents/#url-별칭) 참고. |
| `records` | 없음 | `_data` 파일의 항목마다 페이지를 하나씩 만듭니다. [생성 페이지](../../recipes/generated-pages/) 참고. |
| `seo` | `true` | `false`면 내장 canonical, `hreflang`, Open Graph 태그를 뺍니다. |
| `hreflang` | `seo`를 따름 | `true`면 `seo: false`여도 `hreflang` 링크를 남깁니다. `jekyll-seo-tag`를 쓰는 사이트용입니다. |
| `schema` | `url`이 있으면 켜짐 | schema.org 구조화 데이터를 넣습니다. `false`면 끕니다. [구조화 데이터](../structured-data/) 참고. |
| `languages` | 없음 | `[en, ko]` 같은 사이트 언어 코드입니다. `hreflang`과 언어 메뉴에 쓰입니다. |
| `full_languages` | 없음 | 모든 페이지를 번역하는 언어입니다(예: `[ko, ja]`). `modootoday-check --i18n-pages`가 빠진 번역을 알려 줍니다. |
| `lists` | 없음 | `{link_chips: true, titled_items: true}`면 링크만 있는 목록은 칩으로, `**제목**:` 항목은 제목 있는 항목으로 바뀝니다. |
| `heading_anchors` | `false` | `true`면 문서와 글의 `##`, `###` 제목 끝에 그 제목 자신을 가리키는 링크가 붙습니다. 마우스를 올리거나 포커스하면 보이고, 터치 화면에서는 늘 보입니다. |
| `language_switcher` | 없음 | 언어 메뉴를 `header`(지구본 버튼)나 `footer`(언어 이름 목록)에 표시합니다. |
| `og_image` | 없음 | 링크 미리보기의 기본 이미지입니다. 경로, 또는 이미지의 대체 텍스트(`og:image:alt`)와 크기를 더하는 `{path, alt, width, height}`입니다. 페이지의 `image:`가 우선하고, 그다음은 hero 이미지나 포스터입니다. 페이지의 `image.alt`나 `image_alt`는 그 이미지의 대체 텍스트입니다. |
| `feed` | `false` | `true`면 `/feed.xml`을 연결합니다. `plugins`에 `jekyll-feed`를 넣으세요. |
| `logo` | 없음 | `brand`면 사이트 제목 앞에 테마 마크를, 경로를 주면 그 이미지를 보여 줍니다. |
| `favicon` | 없음 | `brand`면 테마 마크를, 경로를 주면 그 아이콘을 사이트 아이콘으로 씁니다. |
| `pwa` | 끔 | `enabled: true`면 사이트 제목, `theme_color`, 브랜드 마크로 만든 웹 앱 매니페스트를 연결해 브라우저가 사이트를 설치할 수 있고, 오프라인에서 읽을 수 있도록 서비스 워커를 등록합니다. `precache:`에는 더 보관할 사이트 경로를 적습니다(페이지는 front matter `pwa: precache`로 스스로 더할 수 있습니다). `shortcuts:`와 `screenshots:`는 앱 아이콘 메뉴와 설치 대화상자의 그림을 더합니다. `enabled: kill`은 스스로를 제거하는 워커를 내보냅니다. [설치할 수 있는 사이트](../../recipes/pwa/)를 보세요. |
| `header` | `{compact_title: true}` | `compact_title: false`면 휴대폰에서도 로고 옆에 사이트 이름을 보여 줍니다. |
| `csp` | 없음 | `strict`면 처음 그리기 전에 도는 테마 스크립트를 인라인 대신 파일로 불러옵니다. |
| `asset_version` | `theme` | 테마 파일 URL의 `?v=`에 붙일 값입니다. `theme`은 버전, `build`는 커밋까지, `false`는 붙이지 않습니다. [성능](../performance/#버전-붙은-자산-url) 참고. |
| `viewport_fit` | `cover` | `auto`면 휴대폰 노치를 피해 페이지를 그립니다. [접근성](../accessibility/#설정) 참고. |
| `theme_color` | 페이지 배경 | 브라우저 막대 색입니다. `"#hex"` 하나, `{light: "#hex", dark: "#hex"}`, 또는 없애려면 `false`. |
| `edit_url` | 없음 | "이 페이지 편집" 링크 URL의 앞부분입니다. `/`로 끝납니다. `auto`이면 GitHub Pages가 빌드하는 저장소, 브랜치, 폴더로 만듭니다(아래 참고). |
| `feedback` | 꺼짐 | 페이지 아래 한 줄. `issues`(`auto`, 저장소의 이슈 URL, 또는 `false`)는 "문제 신고", `helpful: true`는 답 두 개가 있는 "이 페이지가 도움이 되었나요?", `discuss`는 "토론" 링크를 더하고, `labels`는 미리 채운 이슈의 레이블입니다. front matter `feedback: false`면 그 페이지에서 숨깁니다. |
| `build_link` | `false` | `true`이면 사이트를 빌드한 커밋을 "[commit]에서 빌드"로 보여 주고 GitHub의 그 커밋으로 연결합니다. |
| `archive` | 없음 | `{tags: /tags/, categories: /categories/}`처럼 태그·카테고리 페이지 URL입니다. 글 하단 링크가 여기로 갑니다. [글과 아카이브](../../reference/api/#글과-아카이브) 참고. |
| `mermaid` | 꺼짐 | ```` ```mermaid ```` 블록을 다이어그램으로 그립니다. [다이어그램과 수식 로더](../../recipes/figures/loaders/#내장-로더) 참고. |
| `diagrams` | `{dir: /assets/diagrams/, dark: true, source: details}` | [정적 다이어그램](../../recipes/figures/math-diagrams/#정적-다이어그램)의 SVG가 있는 곳, 다크 모드용 SVG가 따로 있는지, Mermaid 원본을 페이지에 남길지 정합니다. |
| `math` | 꺼짐 | ```` ```math ````와 `$$` 블록을 브라우저에서 KaTeX로 렌더링하거나, `mode: static`이면 `_data/math`에 커밋한 MathML을 보여 줍니다. [수식과 다이어그램](../../recipes/figures/math-diagrams/#정적-수식) 참고. |
| `external_links` | 없음 | `new_window: true`면 다른 사이트로 가는 링크를 새 창에서 엽니다. [새 창으로 여는 링크](#새-창으로-여는-링크) 참고. |
| `blog` | 없음 | `per_page` 같은 블로그 설정입니다. [블로그와 뉴스](../../layouts/blog-news/#설정) 참고. |
| `authors` | `true` | `false`면 글과 글 카드의 바이라인을 숨깁니다. 저자 데이터는 `_data/authors.yml`에 그대로 둡니다. |
| `news` | 없음 | 첫 화면의 `sections:` 같은 뉴스 설정입니다. [블로그와 뉴스](../../layouts/blog-news/#설정) 참고. |
| `css` | `split` | `split`는 페이지가 쓰는 CSS만, `bundle`은 모든 것이 담긴 시트 하나를 불러옵니다. |
| `banner` | 없음 | `{text: "…", url: /path/, link: "더 보기"}`면 모든 페이지에 공지 막대를 표시합니다. `text`가 없을 때 `release: latest`는 빌드 시점에 `site.github`에서 저장소의 최신 릴리스 버전과 그 릴리스로 가는 "새 기능 보기" 링크를 알리고, `release: {version, url}`은 적은 값으로 같은 막대를 만듭니다. |
| `print` | `false` | `true`면 인쇄할 때만 불러오는 인쇄용 스타일시트를 더합니다. 머리글, 메뉴, 배너, 업데이트 알림, 설치 섹션, 페이지 아래 링크를 빼고, 흰 바탕에 검은 글자로 인쇄하며, 탭 패널을 모두 인쇄하고, 링크 뒤에 주소를 붙이고, 그림·코드·표가 페이지 사이에서 끊기지 않게 합니다. `details`, 아코디언, FAQ 항목은 독자가 먼저 열지 않으면 요약만 인쇄됩니다. |
| `back_to_top` | `false` | `true`면 모든 페이지 끝에 맨 위로 링크를 더합니다. |
| `loading` | `false` | `true`면 직접 만든 스크립트를 위해 스피너·스켈레톤 스타일을 모든 페이지에서 불러옵니다. |
| `showcase` | 꺼짐 | `{enabled: true, style: bar, starter:, docs_url:, use_url:}`: 스타터의 데모 빌드에 테마 문서로 돌아가는 막대(`style: pill`이면 떠 있는 알약)를 표시합니다. 데모 전용 설정 파일에 넣습니다. [스타터 데모 쇼케이스](../../reference/showcase/) 참고. |
| `chart` | 꺼짐 | `{enabled: true, src:, integrity:}`: 표 바로 앞에 `chart:<type>`만 있는 줄을 두면 그 표가 차트 figure가 되고, 사이트의 Chart.js(`src`)가 그립니다. [차트](../../recipes/figures/charts/) 참고. |
| `subscribe` | 없음 | `{action: https://…}`: `c: subscribe` 이메일 양식이 신청을 보내는 주소입니다. |

`modootoday-check`가 모든 키를 검사합니다. 안정 이름 전체 목록은 [공개 API](../../reference/api/)에 있습니다.

### 몇몇 키 자세히

- `color_scheme`: `auto-dark`·`auto-light`는 전환 버튼을 두고 독자의 선택을 기억합니다. `light`·`dark`에는 전환 버튼이 없습니다. 시작 색은 HTML에 들어가므로 깜빡임이 없습니다.
- `components`: `lists`, `bleed`, `terminal`, `visual`, `filter`, `table`, `table-stack`, `showcase`는 항상 포함됩니다. 그 시트는 `lists:` 또는 `hero: {checks: true}`, `bleed:`, `chrome: terminal`, `script:` 또는 `poster:`, `filter:` 또는 `filter_text:`, `modootoday.showcase`로 켜거나 본문에 표가 있는 페이지에만 연결됩니다. 목록을 줄일 때 SVG 그림 스타일(다크 톤, 가로 스크롤, 정적 수식을 감싸는 영역 포함)을 유지하려면 `figure` 옆에 `figure-svg`를, 정적 다이어그램의 밝은 모드·다크 모드 전환을 유지하려면 `diagram`을 함께 넣으세요.
- `nav`: 이전·다음 링크는 이 파일 순서(그룹 자체 페이지, 그다음 하위 항목)를 따릅니다. 이 파일이 없으면 헤더는 `_data/navigation.yml`의 `main`, 그다음 `header_pages`(minima처럼 페이지 경로 목록), 그다음 HTML 페이지가 100개 이하인 사이트에서는 `title`이 있는 최상위 페이지(`/about/` 같은)를 모두 읽습니다(`nav_order` 먼저, 그다음 제목순. `nav: false`나 `nav_exclude: true`인 페이지는 빠짐). `nav: false`는 마지막 목록을 끕니다.
- `sidebar`: 64rem보다 좁으면 본문 위의 접이식 메뉴가 됩니다. front matter의 `sidebar: false`로 한 페이지에서만 숨깁니다.
- `page_actions`: Markdown 버전이 있는 페이지에 Markdown으로 보기, 페이지 복사, AI용으로 복사(출처 URL 뒤에 Markdown) 메뉴가 나옵니다. front matter의 `page_actions: false`는 그 페이지에서만 끄고, 아예 빼려면 `components`에서 `page-actions`를 제외합니다.
- `tokens`, `tokens_dark`: 값은 인라인 `<style>`에 들어갑니다.
- `site_css`, `preload`: `site_css` 시트에는 테마 시트와 같은 `?v=` 쿼리가 붙습니다. `preload`의 `href`는 사이트 경로, `as`는 `font`, `image`, `style`, `script`, `fetch` 중 하나입니다. 글꼴과 fetch에는 `crossorigin`이 붙고 `?v=` 쿼리는 붙지 않습니다. front matter의 `site_css:`와 `preload:`는 그 페이지에만 더합니다.
- `scripts`: 항목마다 사이트 경로로 쓴 `{src, css, preload, element}`입니다. `src`는 `.js` 파일, `css`는 시트, `preload`는 `modulepreload`할 모듈, `element`는 모듈이 정의하는 사용자 정의 요소(하이픈이 들어간 소문자, `mt-`로 시작하지 않음, 요소마다 항목 하나)로, `c: widget`과 `widget:`이 페이지에 놓습니다.
- `aliases`: 스텁 파일은 `modootoday-stubs --aliases`가 쓰고 `modootoday-check --aliases`가 확인합니다. `twins: source`와는 `md`를 함께 쓸 수 없습니다.
- `records`: 세트마다 `{data, key, dir, permalink, layout, title, description, facts, labels, body, lang}`를 받습니다. 페이지는 `modootoday-stubs --records`가 쓰고 `modootoday-check`가 확인합니다.
- `schema`: 그래프 설정은 `publisher`, `search_url`, `layouts`, `faq`입니다.
- `languages`: 헤더의 사이트 제목은 해당 언어의 홈(`/<lang>/`)이 있으면 그곳으로 연결됩니다.
- `lists`: 일반 섹션과 페이지에서 링크만 있는 목록은 `ul.mt-chips`가 되고, `**제목**:`으로 시작하는 항목은 `strong.mt-item-title`을 받습니다. 선택 시트 `lists`가 이것과 `hero: {checks: true}`를 꾸미며, 사용하는 페이지에만 연결됩니다.
- `heading_anchors`: 링크는 제목 안, 텍스트 뒤에 붙는 `a.mt-anchor`이고, 이름은 페이지 언어로 된 "섹션 링크: [제목]"입니다. 스크립트는 필요 없습니다. 컴포넌트 섹션(`c:`)의 제목은 그대로 두며, 목차와 검색, Markdown 버전도 바뀌지 않습니다. `components` 목록을 쓰면 `anchor`를 넣어야 유지됩니다. 선택 시트 `anchor`가 링크를 꾸미며, 사용하는 페이지에만 연결됩니다.
- `language_switcher`: 각 링크는 이 페이지의 번역본, 없으면 그 언어의 첫 페이지로 갑니다. 헤더 메뉴는 언어 수와 상관없이 폭이 같고, 언어가 둘 미만이면 표시하지 않습니다. 메뉴는 JavaScript 없이 열리고, `menu.js`가 Esc, 화살표 키, 바깥 클릭 시 닫기를 더합니다.
- `logo`, `favicon`: `brand` 마크는 `currentColor`(`brand` 토큰이라 라이트·다크를 따라감)로 그립니다. 직접 지정한 로고 이미지는 장식용(`alt=""`)입니다. 다른 로고를 그리려면 `modootoday/brand/logo.html`을 덮어쓰세요. `brand` 파비콘은 SVG, 32px PNG, Apple 터치 아이콘을 연결합니다.
- `header`: 화면 너비가 30rem(480px)보다 좁으면 `logo`가 있는 사이트는 헤더에 로고만 보여 줍니다. 스크린 리더는 사이트 이름을 그대로 읽습니다. `logo`가 없으면 이름이 항상 보입니다.
- `diagrams`: 페이지는 front matter `diagrams:`에 ```` ```mermaid ```` 펜스마다 항목을 하나씩 나열합니다. `dir`는 사이트 경로입니다. `dark: false`면 다이어그램마다 SVG 하나를 쓰고 다른 `.svg` 그림처럼 어둡게 바꿉니다. `source: none`이면 펜스가 HTML에서 빠집니다.
- `mermaid`, `math`: 설정은 `{enabled: true, src:, integrity:, theme: auto}`와 `{enabled: true, engine: katex, src:, css:, integrity: {js:, css:}, auto_render_src:, auto_render_integrity:, inline: false}`이고, 블록이 있는 페이지에서만 불러옵니다. `src`는 버전을 고정한 https URL과 SRI `integrity` 해시, 또는 사이트 안의 경로입니다. `inline: true`면 `$…$`도 렌더링합니다. `base: /assets/vendor/katex/`는 KaTeX `dist/` 폴더를 직접 호스팅할 때 `src`, `css`, `auto_render_src`를 대신합니다. `mode: static`(기본값 `client`)은 스크립트를 로드하지 않고 각 블록을 `_data/math/<key>.yml`의 n번째 항목으로 바꿉니다. 이 파일은 `modootoday-check SRC --math`가 목록을 만들고 `script/figures/math.mjs`가 씁니다. `enabled`, `src`, `integrity`가 필요 없고, `enabled: false`면 꺼집니다. CDN을 쓰면 `script-src`(수식은 `style-src`, `font-src`도)에 그 출처가 추가되고 방문자 IP 주소가 CDN에 전달됩니다.
- `chart`: `src`는 Chart.js 4(`dist/chart.umd.min.js`)이고 URL과 `integrity` 규칙은 같습니다. Chart.js와 테마의 차트 모듈은 차트가 있는 페이지에서만 불러옵니다. `src`가 없으면 차트는 표로 남습니다.
- `banner`: 막대는 건너뛰기 링크 아래에 놓입니다.
- `loading`: Markdown에서 스피너나 스켈레톤을 쓰는 페이지는 알아서 시트를 불러옵니다.

## 새 창으로 여는 링크

새 창으로 여는 건 직접 켤 때만 동작합니다. 링크마다 켜거나, 외부 링크(사이트의 `url:`로 시작하지 않는 링크) 전체에 켤 수 있습니다.

```yaml
# _config.yml: 외부 링크 전체
modootoday:
  external_links:
    new_window: true
    icon: true        # false면 화살표를 숨깁니다
```

```yaml
# 링크마다: 메뉴, 카드, 버튼, 링크 카드, 디렉터리 항목, 요금제 버튼, 푸터 링크
- {title: "상태 페이지", url: "https://status.example.com", new_window: true}
- {title: "포럼", url: "https://forum.example.com", target: _blank}
```

```markdown
[릴리스 노트](https://github.com/modootoday/jekyll-theme-modootoday/releases "new-window")
```

이런 링크에는 `target="_blank"`, `rel="noopener noreferrer"`, CSS로 그린 작은 화살표, 그리고 스크린 리더가 `aria-describedby`로 읽는 숨은 안내("새 창에서 열림", 페이지 언어로 번역)가 붙습니다. 스크립트를 쓰지 않아서 엄격한 콘텐츠 보안 정책(CSP)에서도 그대로 동작합니다. 사이트 설정을 켰더라도 링크에 `new_window: false`를 쓰면 그 링크는 같은 창에서 열립니다.

## 헤드와 SEO

`url:`을 설정하면 모든 페이지에 canonical 링크와 Open Graph 태그가 들어가며 플러그인이 필요 없습니다. `languages:`를 설정하면 여러 언어로 있는 페이지끼리 `hreflang`으로 연결됩니다. 사이트맵과 피드는 GitHub Pages가 허용하는 플러그인으로 직접 켭니다.

```yaml
url: https://example.github.io
modootoday:
  languages: [en, ko]
  edit_url: https://github.com/OWNER/REPO/edit/main/docs/
plugins: [jekyll-remote-theme, jekyll-sitemap, jekyll-feed]
```

피드백 링크는 미리 채운 GitHub 양식을 엽니다. 이슈 제목은 페이지 제목이고(두 답에는 앞에 "Helpful: "나 "Not helpful: "가 붙습니다), 본문은 페이지 URL입니다. 테마는 스크립트를 넣지 않고 아무것도 보내지 않습니다. 독자가 누르기 전에는 브라우저가 요청을 하지 않고, 이슈를 올리기 전에 GitHub이 로그인을 요구합니다. 레이블은 독자가 그 저장소에서 레이블을 달 수 있을 때만 붙고, 없는 레이블은 무시됩니다.

`edit_url: auto`, `build_link: true`, `feedback.issues: auto`는 `site.github`를 읽습니다. GitHub Pages는 빌드하는 저장소에서 이 값을 채우고, 저장소나 커밋을 모르면 링크를 빼고 만듭니다. 다른 곳에서는 `jekyll-github-metadata` 플러그인을 쓰거나, `_config.yml`에 `repository_url`, `source: {branch, path}`, `build_revision`을 담은 `github:` 맵을 두면 그 값을 대신합니다. 이 중 아무것도 없으면 `modootoday-check`가 경고합니다. `edit_url`에 URL을 직접 쓰면 언제나 `auto`보다 앞섭니다. GitHub Pages가 저장소의 Pages 설정을 읽지 못하면(GitHub 밖의 빌드나 토큰 없는 빌드) `source`는 루트의 `gh-pages`나 `master` 브랜치로 돌아가므로, 그때는 URL을 직접 쓰세요.

`jekyll-seo-tag`를 쓰려면 `seo: false`로 두고 `_includes/head-custom.html`에 jekyll-seo-tag의 `seo` 태그를 넣으세요. front matter의 `last_modified_at:`으로 수정일을 표시할 수 있습니다. 이동 경로의 첫 항목은 홈 페이지 front matter에 `short_title:`이 있으면 그것을, 없으면 `title`을 보여 줍니다. 엄격한 콘텐츠 보안 정책은 [CSP](../../recipes/csp/)를 보세요.

## 언어

인터페이스 문자열은 `_data/i18n/<lang>.yml`에 둡니다. 번역 페이지는 원문 옆이나 `<lang>/`에 둡니다(아래 참고).

```yaml
language: 한국어
site_title: 모두의오늘 테마   # 헤더, <title>, og:site_name, JSON-LD 이름. 없으면 site.title
callout: {note: 참고, tip: 팁, important: 중요, warning: 경고, caution: 주의}
tabs: {label: 설치 방법}
status: {available: 사용 가능, partial: 일부 구현, planned: 계획}
skip: 본문으로 건너뛰기
```

`lang:`만 지정하면 테마가 표시하는 문구(본문 바로가기, 내비게이션, 알림 상자, 상태 배지, 목차, 이전/다음 페이지, 코드 복사, 검색, 언어 메뉴)가 23개 언어로 바로 현지화됩니다. 지원 언어는 en, zh-CN, zh-TW, ja, ko, tr, ru, vi, th, de, es, fr, uk, pl, pt-BR, ar, fa, id, it, el, ml, ur-Latn, ro입니다. GitHub Pages에서도, Jekyll 4에서도 아무것도 복사할 필요가 없습니다. 테마에 없는 지역 코드는 기본 언어를 따르고(`pt` → pt-BR, `zh` → zh-CN), 그 밖의 언어는 영어로 표시됩니다.

각 문구는 다음 순서로 정해집니다.

1. 사이트의 `_data/i18n/<lang>.yml` (키 단위)
2. 테마에 들어 있는 해당 언어 카탈로그
3. 영어

그래서 사이트 카탈로그에는 바꾸고 싶은 키와 직접 만든 컴포넌트가 쓰는 키만 넣으면 됩니다. 확장자는 `.yml`을 쓰세요. 검사기는 `.yaml`을 오류로 처리합니다. 테마 문구에서 시작하고 싶다면 카탈로그를 복사한 뒤 검사하세요.

```sh
modootoday-check . _site --i18n-init=ko   # optional: copy the theme's ko.yml to edit
modootoday-check . _site --i18n           # unknown keys and placeholder mismatches
```

테마가 제공하지 않는 언어는 영어 카탈로그와 같은 키로 `_data/i18n/<code>.yml`을 만들고 `languages`에 코드를 추가하세요. 아랍어, 페르시아어, 히브리어, 우르두어 같은 RTL 언어 페이지에는 `dir="rtl"`이 붙습니다(`ur-Latn`은 왼쪽에서 오른쪽). 카탈로그나 front matter의 `direction: rtl` 또는 `ltr`로 바꿀 수 있습니다. 페이지 본문은 카탈로그가 아니라 Markdown으로 번역하며, 배치는 두 가지입니다. 원문 옆에 두려면 `guides/start.md` 옆에 `guides/start.ko.md`를 만들고 front matter에 `lang: ko`와 `permalink: /ko/guides/start/`를 씁니다. Jekyll은 이 파일 이름에서 그 URL을 만들 수 없기 때문입니다. 폴더에 두려면 `ko/guides/start.md`를 만들고 `defaults` 범위(`path: ko`, `lang: ko`)를 둡니다. 홈 페이지만 번역하는 언어는 `home/index.<lang>.md`(`permalink: /<lang>/`)로 둘 수 있습니다.

경로가 다른 번역 페이지끼리는 front matter에 같은 `ref:`를 둡니다. 예를 들어 `guides/start.md`와 `ko/guides/sijak.md`에 모두 `ref: guide`를 씁니다. 그러면 `hreflang` 링크와 언어 선택기가 그 페이지를 사용합니다. `ref:`가 있는데 번역이 없는 페이지는 `hreflang`에서 빠지고, 언어 선택기는 그 언어의 홈으로 보냅니다. include와 레이아웃에서 `modootoday/link.html`에 `ref="guide"`를 주면 현재 언어의 `ref: guide` 페이지 URL을, 없으면 기본 언어 페이지 URL을 얻습니다(대체하지 않으려면 `exact=true`, 전체 URL은 `absolute=true`). 어떤 페이지에도 없는 `ref=`는 `modootoday-check`가 오류로 알립니다. `full_languages`를 설정하면 `modootoday-check . _site --i18n-pages`가 그 언어의 번역(같은 `ref:`, 페이지 옆의 `<name>.<lang>.md`, 또는 `<lang>/` 아래 같은 경로)이 없는 기본 언어 페이지를 경고로 보여 줍니다. `--strict`를 함께 쓰면 실패합니다. 글, 레코드 페이지, 레코드 목록, `/404.html`처럼 파일 URL에 있는 페이지는 페이지마다 번역하지 않으므로 빠집니다. 같은 옵션은 각 번역의 `source_rev:`도 읽습니다. 이 값은 번역의 바탕이 된 원문 리비전입니다(원문의 `title`, `description`, `nav_title`과 본문으로 만든 `sha256:`와 16진수 12자리). 이 값이 없거나 그 뒤로 원문이 바뀐 번역은 경고로 알리며, 경고에 현재 값이 함께 나옵니다. 원문 옆에 둔 번역의 `permalink`가 원문 URL 앞에 `/<lang>`을 붙인 값과 다르면 오류입니다.

테마가 아니라 사이트가 정하는 문구도 있습니다. `tabs.label`은 탭을 쓰는 페이지에서 탭 목록의 이름입니다(예: `tabs: {label: 설치 방법}`). 스크린 리더가 무엇을 고르는 탭인지 읽어 주니, 언어별 카탈로그마다 넣어 주세요.

직접 만든 include에서는 `modootoday/t.html`에 `key="nav.label"`을 넘기면 같은 순서를 따르는 문구를 출력할 수 있습니다.

## 컴포넌트 레지스트리

선택 파일 `_data/components.yml`이 있으면 검사기가 `sections:` 매개변수를 검증합니다.

```yaml
features: {params: {cols: {allowed: [2, 3, 4], required: false}, badge: {allowed: [bottom], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```
