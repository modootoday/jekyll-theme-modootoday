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
- **소스 모드** (기본 GitHub Pages, 스텁 없음): 머리말 없는 페이지와 `modootoday.twins: source`. 2026-10-30에 확인한 기본 Pages 사이트에서는 원본 사본이 `text/markdown; charset=utf-8`로, 원본과 바이트 단위로 같게 제공되었습니다(표본 하나; 한계는 RULES.md §5a).

방법을 바꿔도 페이지 본문은 바뀌지 않습니다. [에이전트](../agents/)와 `RULES.md` 5a절을 보세요.

## 업그레이드

건너뛰는 모든 버전의 `CHANGELOG.md`를 읽으세요. 1.0 전에는 마이너 버전에서도 규칙이 바뀔 수 있고, 1.0 이후에는 메이저 버전에서만 바뀝니다([공개 API](../api/) 참고).

| 이전 | 이후 | 할 일 |
|---|---|---|
| 모든 0.x | 0.5 | 첫 공개 릴리스. `~> 0.5` 또는 `@v0.5.0`으로 고정 |
| 0.x | 1.0 | 사이트 CSS의 `md-*` 클래스와 `--md-*` 속성을 `mt-*`, `--mt-*`로 교체 (1.x에서는 검사기 경고와 함께 계속 동작). `modootoday-check --strict` 실행 |
| 1.x | 2.0 | `md-*` 별칭 제거 |
