---
lang: ko
permalink: /ko/guides/agents/
source_rev: sha256:ada23255a862
nav_order: 60
title: AI 에이전트
description: 페이지마다 Markdown 버전, URL 별칭, llms.txt, llms-full.txt를 게시해 AI 에이전트가 사이트를 쓴 그대로 읽게 합니다.
sections:
  - twins
  - aliases
  - llms
---
# AI 에이전트

모든 페이지는 두 번 게시됩니다. 사람을 위한 HTML과 에이전트를 위한 원본 Markdown입니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/agents/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## Markdown 버전

`guide.md` 페이지는 `/guide/index.md`에서도 본문과 바이트 단위로 똑같이 제공됩니다. Markdown 버전을 게시하는 세 가지 방법 중 하나를 고르세요. 방법을 바꿔도 페이지 본문은 바뀌지 않습니다.

- **스텁 파일** (기본, 기본 GitHub Pages): 페이지마다 작은 `<page>.md.txt` 하나. 아래에서 설명합니다.
- **플러그인** (Jekyll 4 또는 GitHub Actions): `plugins: [jekyll-theme-modootoday]`가 스텁 없이 Markdown 버전과 `llms.txt`를 만듭니다.
- **소스 모드** (기본 GitHub Pages, 스텁 없음): front matter 없는 페이지와 `modootoday.twins: source`. 기본 GitHub Pages는 원본 사본을 원본과 똑같이 `text/markdown; charset=utf-8`로 제공합니다. 한계는 [Markdown 규칙](../../reference/rules/) 5a절에 있습니다.

Jekyll 4에서는 테마 플러그인이 Markdown 버전을 자동으로 만듭니다.

```yaml
plugins: [jekyll-theme-modootoday]
```

기본 GitHub Pages 빌드는 플러그인을 실행할 수 없으므로, 각 페이지 옆에 스텁을 둡니다.

```yaml
# guide.md.txt
---
layout: twin
twin_of: guide.md
permalink: /guide/index.md
---
```

`twin_of`는 스텁 파일 기준의 상대 경로입니다(`include_relative`로 읽습니다). 스텁을 페이지와 같은 폴더에 두거나 `../` 경로를 쓰세요. 사이트 소스 밖이나 `_` 폴더는 가리킬 수 없습니다.

```yaml
# guides/install.md 옆의 스텁 guides/install.md.txt
twin_of: install.md          # 올바름: 스텁 기준 상대 경로
twin_of: guides/install.md   # 틀림: 사이트 루트 기준 경로는 "Could not locate the included file" 오류가 납니다
```

각 HTML 페이지는 `rel="alternate" type="text/markdown"`으로 Markdown 버전을 연결합니다.

스텁은 `modootoday-stubs`가 대신 씁니다. `--write`가 없으면 만들거나 고치거나 지울 파일을 보여 주기만 합니다. CI에서는 스텁이 없거나, 내용이 낡았거나, 페이지를 지운 뒤에도 남아 있으면 `--check`가 실패합니다.

```sh
modootoday-stubs . --twins           # list missing, stale and orphan stubs
modootoday-stubs . --twins --write   # write them
modootoday-stubs . --twins --check   # CI: exit 1 when anything would change
```

## URL 별칭

어떤 에이전트는 `/guide/` 대신 `/guide.md`나 `/guide.html`을 요청합니다. 원하는 별칭을 `_config.yml`에 적으세요.

```yaml
modootoday:
  aliases: {md: true, html: true}
```

그다음 `modootoday-stubs . --aliases --write`가 URL이 디렉터리인 페이지마다 스텁을 두 개까지 만듭니다(홈 페이지는 없음).

- `guide.flat.md.txt`는 같은 Markdown 버전을 `/guide.md`에서도 같은 바이트로 제공합니다.
- `guide.html.md.txt`는 `redirect` 레이아웃을 씁니다. `/guide.html`은 meta refresh로 `/guide/`에 보내고, `/guide/`를 canonical로 밝히며 `noindex`이므로 검색 엔진에는 URL 하나만 남습니다. 플러그인도 스크립트도 필요 없어 기본 GitHub Pages와 엄격한 CSP에서도 동작합니다.

`modootoday-check . _site --aliases`는 모든 별칭이 빌드에 있고 제 페이지를 가리키는지 확인합니다. 두 페이지가 같은 별칭을 쓰거나 별칭이 다른 파일의 경로와 겹치면 오류입니다. front matter 없는 페이지가 이미 `/guide.md`에 나오는 `twins: source`와는 `.md` 별칭을 함께 쓸 수 없습니다.

## llms.txt

`/llms.txt`는 [llmstxt.org](https://llmstxt.org) 형식으로 한 언어의 모든 페이지를 나열합니다. `/llms-full.txt`는 모든 페이지 본문을 이어 붙입니다. 플러그인이 둘 다 추가하고, 기본 GitHub Pages에서는 사이트 루트에 front matter만 담은 파일 두 개, `llms.txt`와 `llms-full.txt`로 만듭니다.

```yaml
# llms.txt (llms-full.txt는 layout: llms-full로 같게)
---
layout: llms
---
```

페이지가 있는 다른 언어마다 그 언어 폴더에 같은 두 파일을 두고 `lang:`을 적습니다. 예를 들어 `ko/llms.txt`에는 `layout: llms`와 `lang: ko`를 씁니다. 빠진 파일은 `modootoday-check --twins`가 알려 줍니다.

이 사이트에서 확인해 보세요: [llms.txt](../../llms.txt), [llms-full.txt](../../llms-full.txt). 내 사이트에서 검사하는 법은 [설치 > 빌드 확인](../install/)에 있습니다.
