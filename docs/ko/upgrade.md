---
title: 이전과 업그레이드
description: 다른 Jekyll 테마에서 옮기기, 기존 프로젝트에 도입하기, 버전 간 업그레이드.
---
# 이전과 업그레이드

> [!NOTE]
> 이 페이지는 [영어 원문](../../upgrade/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 다른 테마에서

1. `theme:` 또는 `remote_theme:`을 이 테마로 바꾸고([설치](../install/) 참고) 버전을 고정합니다.
2. `_config.yml`에서 `layout: doc`을 기본값으로 두거나, 기존 레이아웃을 유지하고 필요한 부분만 인클루드합니다.
3. 페이지 본문은 그대로 둡니다. GitHub 알림, 표, 코드 블록은 이미 동작합니다. 본문의 HTML과 Liquid는 가능한 만큼 빼세요. 이식성이 없는 부분은 `modootoday-check`가 알려 줍니다.
4. 색과 글꼴은 CSS 선택자를 덮어쓰는 대신 `modootoday.tokens`로 옮깁니다.
5. `jekyll build`와 `modootoday-check SRC _site`를 실행하고 보고된 내용을 고칩니다.

흔한 대응: minima의 `layout: page`와 just-the-docs의 `layout: default`는 `layout: doc`이 됩니다. `include note.html` 태그로 만든 알림은 `> [!NOTE]`가 되고, HTML로 쓴 배지는 `` `status:available` `` 코드 스팬이 됩니다.

## 기존 프로젝트에 도입하기

| 방법 | 쓸 때 | 업데이트 |
|---|---|---|
| gem (`theme:`) | 사이트에 `Gemfile`이 있을 때 (Jekyll 4 또는 `github-pages` gem) | `bundle update jekyll-theme-modootoday` |
| `remote_theme:` | `Gemfile` 없는 기본 GitHub Pages | `@vX.Y.Z` 태그 변경 |
| 복사해 넣기 | 레이아웃을 고쳐 써야 하거나 의존성을 추가할 수 없을 때 | 태그된 릴리스에서 `_layouts`, `_includes`, `_sass`, `assets`를 복사하고 버전을 기록. 업데이트는 직접 병합 |

태그로 고정한 gem이나 `remote_theme:`을 권합니다. 복사해 넣기는 고친 파일에 대해 업그레이드와 검사기 보장을 잃습니다.

## Markdown 쌍둥이

각 페이지의 에이전트용 쌍둥이를 내보내는 세 가지 방법 중 하나를 고릅니다.

- **스텁 파일** (기본, 기본 GitHub Pages): 페이지마다 작은 `<page>.md.txt` 하나.
- **플러그인** (Jekyll 4 또는 GitHub Actions): `plugins: [jekyll-theme-modootoday]`가 스텁 없이 쌍둥이와 `llms.txt`를 만듭니다.
- **소스 모드** (기본 GitHub Pages, 스텁 없음): 머리말 없는 페이지와 `modootoday.twins: source`. 기본 GitHub Pages는 원본 사본을 원본과 똑같이 `text/markdown; charset=utf-8`로 제공합니다(한계는 RULES.md §5a).

방법을 바꿔도 페이지 본문은 바뀌지 않습니다. [에이전트](../agents/)와 `RULES.md` 5a절을 보세요.

## 업그레이드

건너뛰는 모든 버전의 `CHANGELOG.md`를 읽으세요. 1.0부터 규칙과 공개 API는 메이저 버전에서만 호환되지 않게 바뀝니다([공개 API](../api/) 참고).

| 이전 | 이후 | 할 일 |
|---|---|---|
| 1.0.0 이전에 저장소에서 빌드 | 1.0 | `~> 1.0` 또는 `@v1.0.0`으로 고정. 사이트 CSS의 `md-*` 클래스와 `--md-*` 속성을 `mt-*`, `--mt-*`로 교체 (1.x에서는 검사기 경고와 함께 계속 동작). `modootoday-check --strict` 실행 |
| 1.x | 2.0 | `md-*` 별칭 제거 |

### `md-*`에서 `mt-*`로

`md-*` 클래스와 `--md-*` 사용자 정의 속성은 1.0에서 폐기 예정으로 표시되고 2.0에서 제거됩니다. 사이트의 Sass, CSS, include, 레이아웃, 페이지가 이를 쓰면 `modootoday-check`가 경고합니다(코드 블록은 제외). `--strict`를 주면 경고가 오류가 됩니다. 아래 표에 따라 `mt-*` 이름으로 바꾸세요. 테마에 다른 `md-*` 이름은 없습니다.

사이트 검색: `grep -rnE '(\.|class=.*)md-[a-z]|--md-' _sass _includes _layouts assets`

클래스:

| 이전 | 새 이름 |
|---|---|
| `.md-body` | `.mt-body` |
| `.md-header` | `.mt-header` |
| `.md-site-title` | `.mt-site-title` |
| `.md-skip` | `.mt-skip` |
| `.md-main` | `.mt-main` |
| `.md-doc` | `.mt-doc` |
| `.md-hero` | `.mt-hero` |
| `.md-section` | `.mt-section` |
| `.md-c-<c>` | `.mt-c-<c>` |
| `.md-cta` | `.mt-cta` |
| `.md-prose` | `.mt-prose` |
| `.md-callout` | `.mt-callout` |
| `.md-callout-<type>` | `.mt-callout-<type>` |
| `.md-callout-title` | `.mt-callout-title` |
| `.md-badge` | `.mt-badge` |
| `.md-badge-<value>` | `.mt-badge-<value>` |

사용자 정의 속성:

| 이전 | 새 이름 |
|---|---|
| `--md-font-sans` | `--mt-font-sans` |
| `--md-font-mono` | `--mt-font-mono` |
| `--md-font-size` | `--mt-font-size` |
| `--md-line-height` | `--mt-line-height` |
| `--md-measure` | `--mt-measure` |
| `--md-space` | `--mt-space` |
| `--md-radius` | `--mt-radius` |
| `--md-bg` | `--mt-background` |
| `--md-bg-subtle` | `--mt-muted` |
| `--md-fg` | `--mt-foreground` |
| `--md-fg-muted` | `--mt-muted-foreground` |
| `--md-border` | `--mt-border` |
| `--md-accent` | `--mt-primary` |
| `--md-accent-fg` | `--mt-primary-foreground` |
| `--md-focus` | `--mt-ring` |
| `--md-note` | `--mt-note` |
| `--md-tip` | `--mt-tip` |
| `--md-important` | `--mt-important` |
| `--md-warning` | `--mt-warning` |
| `--md-caution` | `--mt-caution` |
| `--md-available` | `--mt-status-available` |
| `--md-partial` | `--mt-status-partial` |
| `--md-planned` | `--mt-status-planned` |

`--md-*`의 `bg-subtle`, `fg`, `accent` 등은 접두사만이 아니라 이름도 바뀌었습니다. 오른쪽 열의 `mt-` 이름은 [공개 API](../api/)에 속합니다.
