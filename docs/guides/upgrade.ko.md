---
lang: ko
permalink: /ko/guides/upgrade/
source_rev: sha256:24d887094e6f
nav_order: 60
nav_title: 이전
title: 이전과 업그레이드
description: 다른 Jekyll 테마에서 옮기기, 기존 프로젝트에 도입하기, 버전 간 업그레이드.
---
# 이전과 업그레이드

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/upgrade/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 다른 테마에서

1. `theme:` 또는 `remote_theme:`을 이 테마로 바꾸고([설치](../install/) 참고) 버전을 고정합니다.
2. `_config.yml`에서 `layout: doc`을 기본값으로 두거나, 기존 레이아웃을 유지하고 필요한 부분만 include로 불러옵니다.
3. 페이지 본문은 그대로 둡니다. GitHub 알림, 표, 코드 블록은 이미 동작합니다. 본문의 HTML과 Liquid는 가능한 만큼 빼세요. 이식성이 없는 부분은 `modootoday-check`가 알려 줍니다.
4. 색과 글꼴은 CSS 선택자를 덮어쓰는 대신 `modootoday.tokens`로 옮깁니다.
5. `jekyll build`와 `modootoday-check SRC _site`를 실행하고 보고된 내용을 고칩니다.

`jekyll new`로 만든 사이트(minima)는 두 곳을 바꿉니다. `_config.yml`의 테마 줄과 `Gemfile`의 테마 gem입니다. `gem "minima"`를 `gem "jekyll-theme-modootoday"`로 바꾸고 `bundle install`을 실행하세요. 바꾸지 않으면 Jekyll 4가 "The jekyll-theme-modootoday theme could not be found"라며 멈춥니다. GitHub Pages에서는 대신 [설치](../install/)의 `remote_theme` 두 줄을 쓰세요. 설치의 `sass: silence_deprecations` 줄도 넣으세요. 넣지 않으면 Jekyll 4 빌드가 Sass 알림을 수백 개 출력합니다. 그 밖에는 고칠 것이 없습니다. `layout: page`는 이름만 다른 `doc` 레이아웃으로 본문에 제목이 없으면 `title:`을 페이지 제목으로 표시하고(About 페이지), 홈 페이지는 사이트 제목을 제목으로 두고 글 목록을 보여 주고, 헤더는 `header_pages`나 제목이 있는 최상위 페이지를 모두 보여 주고, 글에는 사이트의 `author:`가 나옵니다. `modootoday-check`는 `.md` 페이지만 읽고, `jekyll new`가 만든 `.markdown` 파일마다 경고합니다. 검사를 받으려면 이름을 `.md`로 바꾸세요. `modootoday-check`는 사이트와 테마 어디에도 없는 레이아웃을 보고하고, `single`(`doc` 또는 `post`)이나 `splash` 같은 Minimal Mistakes 레이아웃에는 대신 쓸 레이아웃을 알려 줍니다.

흔한 대응: just-the-docs의 `layout: default`는 `layout: doc`이 됩니다. `include note.html` 태그로 만든 알림은 `> [!NOTE]`가 되고, HTML로 쓴 배지는 `` `status:available` `` 코드 스팬이 됩니다.

## 기존 프로젝트에 도입하기

| 방법 | 쓸 때 | 업데이트 |
|---|---|---|
| gem (`theme:`) | 사이트에 `Gemfile`이 있을 때 (Jekyll 4 또는 `github-pages` gem) | `bundle update jekyll-theme-modootoday` |
| `remote_theme:` | `Gemfile` 없는 기본 GitHub Pages | `@vX.Y.Z` 태그 변경 |
| 복사해 넣기 | 레이아웃을 고쳐 써야 하거나 의존성을 추가할 수 없을 때 | 릴리스 태그에서 `_layouts`, `_includes`, `_sass`, `assets`를 복사하고, 업데이트는 직접 병합 |

태그로 고정한 gem이나 `remote_theme:`을 권합니다. 복사해 넣었다면 어떤 버전을 복사했는지 기록해 두세요. 복사해 넣기는 고친 파일에 대해 업그레이드와 검사기 보장을 잃습니다.

## Markdown 버전

에이전트용 Markdown 버전을 내보내는 세 가지 방법 중 하나를 고릅니다.

- **스텁 파일** (기본, 기본 GitHub Pages): 페이지마다 작은 `<page>.md.txt` 하나.
- **플러그인** (Jekyll 4 또는 GitHub Actions): `plugins: [jekyll-theme-modootoday]`가 스텁 없이 Markdown 버전과 `llms.txt`를 만듭니다.
- **소스 모드** (기본 GitHub Pages, 스텁 없음): front matter 없는 페이지와 `modootoday.twins: source`. 기본 GitHub Pages는 원본 사본을 원본과 똑같이 `text/markdown; charset=utf-8`로 제공합니다(한계는 RULES.md §5a).

방법을 바꿔도 페이지 본문은 바뀌지 않습니다. [에이전트](../agents/)와 `RULES.md` 5a절을 보세요.

## jekyll-seo-tag에서 옮기기

`jekyll-seo-tag` 대신 킷이 SEO 태그를 쓰게 하려면 다음과 같이 합니다.

1. `plugins:`와 `Gemfile`에서 `jekyll-seo-tag`를 지우고, `_includes/head-custom.html`에서 `seo` 태그를 지웁니다.
2. `modootoday:`에서 `seo: false`와 `hreflang: true`를 지웁니다. 킷이 canonical 링크, `hreflang` alternate 링크, Open Graph를 다시 씁니다. 직접 넣은 alternate 링크는 지워서 같은 링크가 두 번 나오지 않게 합니다.
3. 브라우저 막대 색은 `modootoday.theme_color`로 정합니다([설정](../configuration/) 참고). 킷은 기본으로 라이트용과 다크용 `theme-color` 태그 두 개를 씁니다. 직접 넣은 `theme-color` 태그가 있으면 지웁니다. 남겨 두면 한 페이지에 세 개가 됩니다.
4. 킷은 `twitter:card`만 씁니다(페이지에 이미지가 있으면 `summary_large_image`). `twitter:` 설정은 읽지 않으므로 `twitter:site`가 필요하면 `_includes/head-custom.html`에 meta 태그로 넣습니다.
5. 다시 빌드하고 `modootoday-check SRC _site`를 실행합니다. jekyll-seo-tag JSON-LD에 관한 경고가 없어야 합니다.

## 업그레이드

건너뛰는 모든 버전의 `CHANGELOG.md`를 읽으세요. 문서화된 이름은 [공개 API](../../reference/api/)에 있습니다. 업그레이드한 뒤 사이트를 빌드하고 `modootoday-check . _site --strict`를 실행하세요(소스 폴더, 빌드한 사이트 순서).

| 이전 | 이후 | 할 일 |
|---|---|---|
| 1.0.0 이전에 저장소에서 빌드 | 1.0 | `~> 1.0` 또는 `@v1.0.0`으로 고정합니다. |
| 1.0 또는 1.1 | 1.2 | `~> 1.2`로 고정합니다(`remote_theme`은 최신 `v1.2.x` 태그). |
| 1.2 | 1.3 | `~> 1.3`으로 고정합니다(`remote_theme`은 `@v1.3.0`). |
| 1.3 | 1.4 | `~> 1.4`로 고정합니다(`remote_theme`은 `@v1.4.1`). |
| 1.4 | 1.5 | `~> 1.5`로 고정합니다(`remote_theme`은 `@v1.5.0`). |
| 1.5 | 1.6 | `~> 1.6`으로 고정합니다(`remote_theme`은 `@v1.6.0`). |

어느 업그레이드도 페이지를 고칠 필요가 없습니다. 버전마다 더해진 것:

- 1.2: 새 섹션·히어로 옵션(`bleed:`, `reveal:`, `visual:`과 함께 쓰는 `c: split`). 모두 선택 사항입니다.
- 1.3: `reference` 사이드바(`sidebar: true`)와 패키지 표(`packages:`). 모두 선택 사항입니다.
- 1.4: `packages_compact`와 `packages_position`(선택 사항). `reference` 페이지도 이제 `doc`처럼 알림을 변환합니다.
- 1.5: 기본 모습과 페이지가 테마 CSS·JavaScript를 불러오는 방식이 바뀝니다(아래 참고).
- 1.6: 정적 다이어그램(front matter `diagrams:`, [수식과 다이어그램](../../recipes/math-diagrams/#정적-다이어그램) 참고), 정적 수식(`modootoday.math.mode: static`, `_data/math`의 MathML, [정적 수식](../../recipes/math-diagrams/#정적-수식) 참고), Markdown 표로 만드는 차트(`modootoday.chart`, `c: chart`, `modootoday.chart.src`에 지정한 사이트의 Chart.js가 그림, [차트](../../recipes/charts/) 참고), `c: widget`이나 `widget:`으로 놓는 직접 만든 custom element인 위젯(`modootoday.scripts`의 `element:`, [위젯](../../recipes/widgets/) 참고), 모두 선택 사항. `modootoday.math.base`는 로더가 쓰는 직접 호스팅 KaTeX 경로를 줄여 줍니다. `modootoday-check`는 이제 JSON-LD 안에 하나만 들어 있는 객체(`offers`, `organizer` 등)도 검사하고, 문제는 경고로 알려 줍니다. 다음 메이저 버전부터는 오류입니다([검사](../structured-data/#검사) 참고). 빌드는 그대로 통과하지만 `--strict`에서는 실패합니다. 스타터의 데모 빌드에는 쇼케이스 막대나 알약을 표시할 수 있습니다(`modootoday.showcase`, 데모 전용 설정 파일에 넣음. [스타터 데모 쇼케이스](../configuration/#스타터-데모-쇼케이스) 참고). 이때 모든 페이지에 `noindex`가 붙습니다.

`sections:` 항목이 `##` 제목보다 적어도 되던 1.0 이전 초안을 쓰고 있었다면, 남은 제목마다 `notes` 같은 이름만 추가하세요. 이제 개수가 같아야 하고, `modootoday-check`가 페이지와 두 개수를 알려 줍니다.

`name:`을 쓴 `resume`이나 `links` 페이지는 사람 이름 대신 파일 이름(`resume.md`)을 보여 주었습니다. Jekyll이 페이지의 `name:`을 파일 이름으로 바꾸기 때문입니다. 키 이름을 `display_name:`으로 바꾸세요. 바꾸기 전에는 페이지 제목이 보이고 `modootoday-check`가 경고합니다.

### 1.5의 모습

1.5는 기본 스타일을 평면적이고 중립적으로 바꿉니다. 중립 회색 단계, 불투명한 4rem 헤더, 메뉴와 검색 결과 말고는 그림자 없음, 테두리만 있는 알림, 떠오르지 않는 버튼과 카드, 굵기 600의 제목, 줄 높이 1.75의 본문입니다. 제목은 더 작고 줄이 고르게 나뉘며(모든 너비에서 h1 2rem, h2 1.5rem, h3 1.25rem), 한국어·일본어·중국어 페이지는 언어별 글꼴 목록을 쓰고, 일본어는 브라우저가 지원하면 구절 단위로 줄을 바꿉니다. 토큰 이름은 그대로이고 값만 바뀝니다. `modootoday.theme_color`의 다크 모드 기본값도 새 페이지 배경인 `#0a0a0a`가 됩니다. 1.4의 색, 크기, 그림자를 유지하려면 토큰 브리지에 이전 값을 넣으세요.

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (heading-weight: 650, line-height: 1.7, measure: 46rem, container: 76rem, header-height: 3.75rem,
  space-section: 3rem);
$mt-overrides: (
  foreground: #1f2328, card-foreground: #1f2328, accent-foreground: #1f2328, muted: #f6f8fa, accent: #eff2f5,
  muted-foreground: #59636e, status-planned: #59636e, code-comment: #59636e, border: #d1d9e0,
  shadow-sm: 0 1px 2px rgba(31, 35, 40, 0.06), shadow: 0 6px 20px -6px rgba(31, 35, 40, 0.16)
);
$mt-overrides-dark: (
  background: #0d1117, primary-foreground: #0d1117, foreground: #e6edf3, card-foreground: #e6edf3,
  accent-foreground: #e6edf3, muted: #1a212b, card: #1a212b, accent: #151b23, muted-foreground: #9198a1,
  status-planned: #9198a1, code-comment: #9198a1, border: #3d444d,
  shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3), shadow: 0 8px 24px -6px rgba(0, 0, 0, 0.5)
);
```

`modootoday.theme_color: {light: "#ffffff", dark: "#0d1117"}`도 함께 설정하세요. 헤더의 흐림 효과, 알림의 줄무늬와 배경색, 버튼이 떠오르는 효과는 없어졌으며, 직접 만든 `site_css`로만 되살릴 수 있습니다.

헤더는 모든 너비에서 4rem 높이의 한 줄로 유지됩니다. 64rem보다 좁으면 헤더 링크가 메뉴 버튼(`.mt-nav-sheet`) 안으로 들어가고, 그룹 링크를 줄 안에 다시 늘어놓던 `.mt-nav-flat`은 없어졌습니다. `.mt-nav-flat`에 쓴 규칙은 이제 `.mt-nav-sheet`를 대상으로 바꾸세요. 제목에는 더 이상 `scroll-margin-top`이 없고, 앵커로 이동하면 페이지의 `scroll-padding-top` 덕분에 헤더 아래에 자리 잡습니다. 사이트 이름은 이제 `.mt-site-title` 안의 `span.mt-site-name`입니다. 긴 이름은 줄 안에서 두 번째 줄을 쓰고(64rem보다 좁으면 한 단계 작은 글자), 자리보다 긴 단어는 점 뒤에서("modoo." 다음 줄에 "today") 나뉘며 그래도 안 되면 아무 곳에서나 나뉩니다. 두 번째 줄을 넘는 부분은 글자가 잘리는 대신 말줄임표로 끝납니다. 제목의 `white-space`나 `text-overflow`에 쓴 규칙은 이제 `.mt-site-name`을 대상으로 바꾸세요.

콜아웃, 인용, 그림도 같은 평면 스타일을 따릅니다. 콜아웃은 안쪽 여백 1rem인 가는 테두리 상자이고, 종류 색은 16px 아이콘과 제목에만 들어갑니다. 본문 인용은 시작 쪽에 2px 선이 있고(이전 3px), `c: quote` 섹션은 배경을 채운 카드 대신 같은 선이 있는 큰 인용이 됩니다. 그림, SVG 그림 틀, 임베드의 모서리는 8px(`radius`, 이전 `radius-lg`)이고, 캡션은 14/20이며, `.mt-illustration-tag` 배지는 그림 위를 덮지 않고 그림 위쪽에 놓입니다. 콜아웃 규칙은 핵심 시트에서 빠져 `content/inline.css`로, 그림과 임베드 규칙은 `media/figure.css`로 옮겨 갔고, 이 시트들은 그중 하나가 있는 페이지만 불러옵니다. 부분 파일은 `components/core/inline/` 경로에 그대로 있으므로, 사이트에서 덮어쓴 파일도 계속 적용됩니다. `modootoday.css: bundle`에서는 핵심 시트에 그대로 들어 있습니다.

버튼, 배지, 탭, 카드도 같은 평면 스타일을 따릅니다. 버튼은 높이 40px(히어로에서는 48px)에 14/20 글자, 굵기 500이고, 주요 동작(히어로나 `c: cta` 버튼 줄의 첫 링크, 마케팅·상세 레이아웃의 첫 버튼)은 무채색입니다. 전경색으로 채우고 글자는 배경색입니다. 이제 강조색은 기본으로 아무것도 채우지 않습니다. 강조색으로 채운 버튼을 유지하려면 사이트 스타일시트에서 새 훅을 설정하세요: `:root { --mt-button-primary-bg: var(--mt-primary); --mt-button-primary-fg: var(--mt-primary-foreground); }`. 배지는 `accent` 채움 위의 20px 칩이고, 상태 배지는 색을 6px 점으로 보여 주며, 링크인 배지에는 더 이상 밑줄이 없습니다. 탭은 40px이고 선택한 탭 아래에 2px 전경색 막대가 있습니다. 기능 카드와 링크 카드는 섹션에 들어가는 만큼 16rem 열을 채우고(`cols-<n>`은 이제 창이 아니라 섹션의 너비를 기준으로 합니다), 링크 카드는 포커스 링을 카드 전체에 그립니다. 이동 경로에서는 각 화살표가 앞 항목의 끝에 붙습니다.

히어로, 요금제, `c: cta` 섹션도 평면 스타일입니다. 행동 유도 섹션에는 색을 입힌 패널이 없고, 제목과 버튼은 문서 페이지에서는 본문 열의 시작 쪽에, 그 밖의 페이지에서는 가운데에 놓입니다. 히어로 제목 크기는 새 훅 `--mt-hero-title-size`(기본값 `clamp(2.5rem, 1.5rem + 3vw, 3.5rem)`)이고 굵기는 600이며, 라틴 문자에는 -0.04em 자간을 주고 한국어, 일본어, 중국어에는 주지 않습니다. 리드 문단은 18/28이고 너비는 최대 36rem입니다. 쇼케이스 히어로는 같은 너비의 두 열로 나뉘고, 글 뒤에 그라데이션 대신 단색 패널을 두며, 두 번째 동작을 텍스트 링크로 보여 주고, 48rem 미만에서는 장면을 전체 너비 16:9 띠로 보여 줍니다. 강제 색상 모드에서는 사진과 패널을 숨깁니다. 요금제(`c: pricing`과 `pricing` 레이아웃)는 가는 구분선이 있는 하나의 테두리 격자입니다. 추천 요금제는 더 밝은 칸이고 위쪽 모서리에 레이블이 있으며(2px 테두리 없음), 모든 요금제의 버튼은 요금제 너비만큼 넓고 맨 아래에 있습니다. 44rem보다 좁은 격자에서는 요금제가 세로로 쌓입니다. 월간/연간 선택은 고른 쪽을 전경색으로 채웁니다.

글은 `narrow` 너비(40rem)에서 18/28(한국어, 일본어, 중국어는 18/32)로 읽히고, 제목은 `clamp(2.5rem, 2rem + 2vw, 3rem)`이며, 태그 푸터는 페이지 메타 줄 아래에 두 번째 선을 더하지 않습니다. 표지와 본문 이미지는 모서리 8px에 가는 테두리가 있습니다. 글 카드는 상자가 없어집니다. 16:9 표지에 모서리와 테두리가 있고, 제목은 18/28 굵기 600이며 마우스를 올리면 밑줄이 생기고, 요약은 두 줄에서 끝나며, 격자와 매거진 목록은 18rem 열과 2rem 간격을 씁니다. 블로그 목록에도 이제 글과 같은 이동 경로가 보입니다.

푸터는 채움이 없고 여백이 넓어졌으며(위 3rem, 아래 2rem), 이제 테마가 `_data/nav/footer.yml`로 푸터를 그릴 수 있습니다([커스터마이즈](../customize/#푸터) 참고). 검색 결과는 일치한 단어를 표시하고, 오류 레이아웃은 링크만 있는 본문 문단을 칩 줄로 보여 줍니다. 상태 코드는 굵기 600의 전경색입니다(이전에는 굵기 800의 강조색).

모든 레이아웃은 세 가지 너비 중 하나를 씁니다. 본문 글은 `measure`(45rem), 격자는 `container`(75rem), 법적 고지 페이지·링크 페이지·이력서·검색 양식은 `narrow`(40rem)입니다. 상세, 디렉터리, 검색, 마케팅, docs-extra 페이지의 문단과 일반 목록은 이제 컨테이너 전체로 이어지지 않고 `measure`에서 멈춥니다. 열이 넷 이상인 표에서는 첫 열 다음의 코드가 줄바꿈될 수 있어, 그런 표가 스크롤되지 않고 본문 열에 맞습니다.

### 1.5에서 페이지가 테마를 불러오는 방식

핵심 시트에는 토큰, 기본 요소 규칙, 헤더, 내비게이션, 테마 전환 버튼만 남습니다. 나머지 컴포넌트는 그것을 쓰는 페이지만 핵심 시트 바로 뒤에 연결하는 시트로 옮겨 갔고(코드, 콜아웃과 배지, 그림, 페이지 아래쪽 내비게이션, 히어로, 배너), 맥락 시트는 `assets/css/modootoday/<group>/<name>.css`로 옮겨 갔습니다. 규칙과 순서는 같으므로 페이지 모습은 바뀌지 않습니다. 테마 스크립트는 `assets/js/modootoday/<group>/<name>.js`의 ES 모듈(`<script type="module">`)이 되었고, 헤더 검색은 처음 쓸 때 불러옵니다.

- `assets/css/modootoday.scss`를 섀도잉했다면 1.5 버전을 복사하거나 사이트의 사본을 지우세요. 예전 사본도 빌드는 되지만 옮겨 간 컴포넌트가 핵심 시트에도 남아서, 페이지가 그 규칙을 두 번 불러옵니다.
- 테마 시트나 스크립트를 직접 연결했다면(예: `head-custom.html`) 새 경로를 쓰고, 스크립트에는 `type="module"`을 붙이세요.
- 사이트 스타일시트가 테마 컴포넌트를 덮어쓴다면 `site_css`로 연결하세요. 언제나 모든 테마 시트 뒤에 옵니다.
