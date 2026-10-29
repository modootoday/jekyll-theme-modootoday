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

## 머리말 규칙

- **모든 본문 페이지에 front matter가 있어야 합니다**(빈 `---` / `---`도 됨). 없으면 GitHub Pages에서 `jekyll-optional-front-matter`가 렌더하면서 원본도 `_site/<name>.md`로 복사합니다. 검사기가 오류로 잡습니다.
- `sections:`(선택)는 `##` 제목 순서대로 이름 또는 `{c: 컴포넌트, name: 키, ...}`를 매핑하며, 항목 수가 최상위 `## ` 수와 같아야 합니다. 인용·알림·목록 안의 `##`, setext 제목, 들여쓴 `##`은 검사 오류입니다. 코드 펜스 info string은 언어 한 단어만, 맨 URL 자동링크·약어·HTML 주석은 금지, 각주는 허용합니다.
- `badges: false`로 페이지별 배지를 끌 수 있습니다.

## 현지화와 커스터마이즈

라벨은 `_data/i18n/<lang>.yml`의 `callout.*`, `tabs.label`, `status.*`, `skip`을 씁니다(없으면 영어). 디자인 토큰은 CSS 사용자 정의 속성(`--md-accent` 등)이라 사이트 CSS에서 덮어쓰면 되고, 라이트/다크는 `prefers-color-scheme`을 따릅니다. `<head>` 추가는 `_includes/head-custom.html`.

## 검사기

```sh
bundle exec jekyll build
bundle exec modootoday-check . _site [--twins] [--github-pages[=232]] [--strict] [--gh]
```

`--github-pages`는 선택 플래그라 일반 Jekyll 사이트도 검사할 수 있습니다. 알림 마커는 대소문자를 가리지 않으며, 등록되지 않은 종류(`> [!FOO]`)·제목 붙인 알림·빈 알림은 오류입니다. `--strict`는 경고(예: `> [! NOTE]`)도 실패로 만듭니다. 레이아웃은 쌍둥이를 `rel="alternate" type="text/markdown"`, 가장 가까운 `llms.txt`를 `rel="describedby"`로 연결합니다.

컴포넌트 표, 쌍둥이 규칙, 금지 문법 전체는 [README.md](README.md)(영문)와 [RULES.md](RULES.md)에 있습니다.

## 라이선스

[MIT](LICENSE) © modootoday (모두의오늘)
