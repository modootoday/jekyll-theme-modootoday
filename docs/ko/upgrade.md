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
| 1.0.0 이전에 저장소에서 빌드 | 1.0 | `~> 1.0` 또는 `@v1.0.0`으로 고정하고 `modootoday-check --strict` 실행 |

`sections:` 항목이 `##` 제목보다 적어도 되던 1.0 이전 초안을 쓰고 있었다면, 남은 제목마다 `notes` 같은 이름만 추가하세요. 이제 개수가 같아야 하고, `modootoday-check`가 페이지와 두 개수를 알려 줘요.
