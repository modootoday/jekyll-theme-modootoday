# jekyll-theme-modootoday

[English](README.md)

본문은 GitHub에서도 그대로 보이는 **표준 마크다운(GFM)** 과 GitHub 알림 확장(GFM 스펙 외, 다른 파서에선 인용문으로 강등)만 쓰고, 디자인은 레이아웃·인클루드·CSS·선택적 JS가 입히는 Jekyll 문서 테마입니다.

- GitHub 알림(`> [!NOTE]` 등) → 스타일이 들어간 알림 상자
- 상태 코드 스팬(`` `status:available` ``) → 배지
- `##` 섹션을 컴포넌트(기능 카드, 설치 탭, CTA)로 매핑
- 에이전트·LLM용 바이트 동일 마크다운 쌍둥이(`/guide/index.md`, `llms.txt`)
- `modootoday-check`로 원문과 빌드 결과 검사

GitHub Pages 표준 스택(`github-pages` gem, Jekyll 3.10)과 Jekyll 4에서 모두 동작합니다. 레이아웃과 인클루드는 Liquid만 쓰므로 GitHub Pages의 `remote_theme`도 됩니다.

> [!NOTE]
> 규칙 버전은 `md-components v1 (draft)`이며 v1 확정 전까지 바뀔 수 있습니다. [RULES.md](RULES.md) 참고.

## 설치

gem 방식: `Gemfile`에 `gem "jekyll-theme-modootoday", "~> 0.1"`, `_config.yml`에 `theme: jekyll-theme-modootoday`.

Gemfile 없는 GitHub Pages:

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v0.1.0
plugins:
  - jekyll-remote-theme
```

Gemfile 없는 방식에서는 `modootoday-check`를 쓸 수 없고, 쌍둥이·`llms.txt`는 아래 스텁 파일이 필요합니다. Jekyll 4에서는 `sass: {silence_deprecations: [import]}`로 Dart Sass의 `@import` 경고를 끌 수 있습니다.

## 마크다운 쌍둥이와 llms.txt (선택)

`guide.md`마다 본문과 바이트가 같은 `/guide/index.md`, 그리고 `/`와 각 `/<lang>/`에 `llms.txt`·`llms-full.txt`를 만듭니다.

- **자동(Jekyll 4 또는 GitHub Actions로 빌드하는 Pages):** `_config.yml`에 `plugins: [jekyll-theme-modootoday]`. 스텁 파일이 필요 없고, 결과는 스텁 방식과 바이트 단위로 같습니다. 손으로 만든 스텁이 우선하며 `twin: false` 페이지와 `README.md`는 건너뜁니다. `modootoday: {twins: false, llms: false}`로 끌 수 있습니다.
- **기존 GitHub Pages 빌드(`remote_theme`):** 허용 목록 밖 플러그인은 실행되지 않고 Liquid만으로는 새 출력 파일을 만들 수 없으므로, 페이지마다 스텁 `guide.md.txt`(`layout: twin`, `twin_of: guide.md`, `permalink: /guide/index.md`)가 필요합니다. `llms.txt`/`llms-full.txt`는 언어 디렉터리마다 front matter에 `layout: llms` / `layout: llms-full`만 적으면 레이아웃이 내용을 생성합니다(언어별 제목·설명은 `_data/i18n/<lang>.yml`의 `title`/`description`).

`modootoday-check --twins`가 어느 방식이든 결과를 검증합니다.

## 머리말 규칙

- **모든 본문 페이지에 front matter가 있어야 합니다**(빈 `---` / `---`도 됨). 없으면 GitHub Pages에서 `jekyll-optional-front-matter`가 렌더하면서 원본도 `_site/<name>.md`로 복사합니다. 검사기가 오류로 잡습니다.
- `sections:`(선택)는 `##` 제목 순서대로 이름 또는 `{c: 컴포넌트, name: 키, ...}`를 매핑하며, 항목 수가 최상위 `## ` 수와 같아야 합니다. 인용·알림·목록 안의 `##`, setext 제목, 들여쓴 `##`은 검사 오류입니다(알림 안 소제목은 `###` 사용). 목록·인용 안에 중첩된 알림도 GitHub에서 일반 인용으로 보이므로 오류입니다. 코드 펜스 info string은 언어 한 단어만, 맨 URL 자동링크·약어·HTML 주석은 금지, 각주는 허용합니다.
- `badges: false`로 페이지별 배지를 끌 수 있습니다.

## 현지화와 커스터마이즈

라벨은 `_data/i18n/<lang>.yml`의 `callout.*`, `tabs.label`, `status.*`, `skip`을 씁니다(없으면 영어). `nav.label`, `pagination.*`, `code.copy`/`code.copied`도 있습니다.

`_config.yml`의 `modootoday:` 블록(모두 선택): `color_scheme`(auto/light/dark), `css_layers`(true면 `@layer mt.*`), `components`(기본은 전부: callout, badge, hero, cta, card, tabs, code-copy, nav, pagination), `nav`(`_data/nav/<이름>.yml`), `tokens`/`tokens_dark`(시맨틱 토큰 덮어쓰기, 인라인 `<style id="mt-tokens">`로 출력). 기본값은 Liquid(`_includes/modootoday/config.html`)에 있습니다. Jekyll 3.10(GitHub Pages)은 테마의 `_config.yml`을 병합하지 않기 때문입니다.

디자인 토큰은 3단계 CSS 사용자 정의 속성입니다. 기본 팔레트 `--mt-p-*`, shadcn식 이름의 시맨틱 토큰(`--mt-background`, `--mt-primary`, `--mt-muted-foreground` 등), 컴포넌트 토큰(`--mt-callout-accent` 등)이 있습니다. v0.1의 `--md-*`와 `md-*` 클래스는 별칭으로 남고 v0.3에서 없어집니다. Sass는 `@import`만 씁니다. `@use`/`@forward`는 GitHub Pages의 Ruby Sass에서 그대로 CSS에 남기 때문에 검사기가 오류로 잡습니다.

지원 환경: GitHub Pages(Ruby 3.3.4, github-pages 232, Jekyll 3.10.0, `theme:`와 `remote_theme:` 모두 CI에서 `actions/jekyll-build-pages`로 확인)와 Jekyll 4.4(Ruby 3.2, 3.4). `required_ruby_version`은 `>= 3.2`입니다. `<head>` 추가는 `_includes/head-custom.html`.

## 검사기

```sh
bundle exec jekyll build
bundle exec modootoday-check . _site [--twins] [--github-pages[=232]] [--strict] [--gh]
```

`--twins`는 모든 페이지의 바이트 동일 쌍둥이, 스텁 형식, 언어별 `llms.txt`(`# `로 시작)·`llms-full.txt`(모든 본문 포함)를 검사합니다. `--github-pages`는 선택 플래그라 일반 Jekyll 사이트도 검사할 수 있습니다. 알림 마커는 대소문자를 가리지 않으며, 등록되지 않은 종류(`> [!FOO]`)·제목 붙인 알림·빈 알림은 오류입니다. `--strict`는 경고(예: `> [! NOTE]`)도 실패로 만듭니다. 레이아웃은 쌍둥이를 `rel="alternate" type="text/markdown"`, 가장 가까운 `llms.txt`를 `rel="describedby"`로 연결합니다.

컴포넌트 표, 쌍둥이 규칙, 금지 문법 전체는 [README.md](README.md)(영문)와 [RULES.md](RULES.md)에 있습니다.

## 라이선스

[MIT](LICENSE) © modootoday (모두의오늘)
