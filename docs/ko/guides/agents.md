---
nav_order: 50
nav_title: 에이전트
title: 에이전트용
description: AI 에이전트를 위한 Markdown 쌍둥이, llms.txt, llms-full.txt.
sections:
  - twins
  - llms
  - {c: cta, name: next}
---
# 에이전트가 읽는 Markdown

모든 페이지는 두 번 게시됩니다. 사람을 위한 HTML과 에이전트를 위한 원본 Markdown입니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/agents/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## Markdown 쌍둥이

`guide.md` 페이지는 `/guide/index.md`에서도 본문과 바이트 단위로 똑같이 제공됩니다. Jekyll 4에서는 테마 플러그인이 쌍둥이를 자동으로 만듭니다.

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

`twin_of`는 스텁 파일 기준의 상대 경로예요(`include_relative`로 읽어요). 스텁을 페이지와 같은 폴더에 두거나 `../` 경로를 쓰세요. 사이트 소스 밖이나 `_` 폴더는 가리킬 수 없어요.

각 HTML 페이지는 `rel="alternate" type="text/markdown"`으로 쌍둥이를 연결합니다.

## llms.txt

`/llms.txt`는 [llmstxt.org](https://llmstxt.org) 형식으로 한 언어의 모든 페이지를 나열합니다. `/llms-full.txt`는 모든 페이지 본문을 이어 붙입니다. 둘 다 한 줄짜리 스텁으로 만듭니다.

```yaml
---
layout: llms
---
```

이 사이트에서 확인해 보세요: [llms.txt](../../llms.txt), [llms-full.txt](../../llms-full.txt).

## 다음

[변경 기록](../../reference/changelog/) [홈](../../)
