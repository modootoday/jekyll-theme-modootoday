---
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

흔한 대응: minima의 `layout: page`와 just-the-docs의 `layout: default`는 `layout: doc`이 됩니다. `include note.html` 태그로 만든 알림은 `> [!NOTE]`가 되고, HTML로 쓴 배지는 `` `status:available` `` 코드 스팬이 됩니다.

## 기존 프로젝트에 도입하기

| 방법 | 쓸 때 | 업데이트 |
|---|---|---|
| gem (`theme:`) | 사이트에 `Gemfile`이 있을 때 (Jekyll 4 또는 `github-pages` gem) | `bundle update jekyll-theme-modootoday` |
| `remote_theme:` | `Gemfile` 없는 기본 GitHub Pages | `@vX.Y.Z` 태그 변경 |
| 복사해 넣기 | 레이아웃을 고쳐 써야 하거나 의존성을 추가할 수 없을 때 | 태그된 릴리스에서 `_layouts`, `_includes`, `_sass`, `assets`를 복사하고 버전을 기록. 업데이트는 직접 병합 |

태그로 고정한 gem이나 `remote_theme:`을 권합니다. 복사해 넣기는 고친 파일에 대해 업그레이드와 검사기 보장을 잃습니다.

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

건너뛰는 모든 버전의 `CHANGELOG.md`를 읽으세요. 문서화된 이름은 [공개 API](../../reference/api/)에 있습니다. 업그레이드한 뒤 `modootoday-check --strict`를 실행하세요.

| 이전 | 이후 | 할 일 |
|---|---|---|
| 1.0.0 이전에 저장소에서 빌드 | 1.0 | `~> 1.0` 또는 `@v1.0.0`으로 고정하고 `modootoday-check --strict` 실행 |
| 1.0 또는 1.1 | 1.2 | `~> 1.2`(또는 `remote_theme`에서는 최신 `v1.2.x` 태그)로 고정합니다. 새 섹션·히어로 옵션(`bleed:`, `reveal:`, `visual:`과 함께 쓰는 `c: split`)은 선택 사항이라 페이지를 고칠 필요가 없습니다. `modootoday-check --strict` 실행 |
| 1.2 | 1.3 | `~> 1.3`(또는 `remote_theme`에서는 `@v1.3.0`)으로 고정합니다. `reference` 사이드바(`sidebar: true`)와 패키지 표(`packages:`)는 선택 사항이라 페이지를 고칠 필요가 없습니다. `modootoday-check --strict` 실행 |
| 1.3 | 1.4 | `~> 1.4`(또는 `remote_theme`에서는 `@v1.4.1`)으로 고정합니다. `packages_compact`와 `packages_position`은 선택 사항이고, `reference` 페이지도 이제 `doc`처럼 알림을 변환하므로 페이지를 고칠 필요가 없습니다. `modootoday-check --strict` 실행 |

`sections:` 항목이 `##` 제목보다 적어도 되던 1.0 이전 초안을 쓰고 있었다면, 남은 제목마다 `notes` 같은 이름만 추가하세요. 이제 개수가 같아야 하고, `modootoday-check`가 페이지와 두 개수를 알려 줍니다.
