---
lang: ko
permalink: /ko/layouts/documents/
source_rev: sha256:f8255e834611
title: 문서
description: 법적 고지 페이지와 인쇄 우선 이력서입니다.
nav_order: 60
---
# 문서

인쇄하거나 보관하는 페이지를 위한 레이아웃 두 가지입니다. 둘 다 종이에서는 사이트 머리글, 바닥글, 배너를 숨깁니다.

| 레이아웃 | front matter | 번들 | 구조화 데이터 | 데모 |
|---|---|---|---|---|
| `legal` | `effective`(필수), `updated`, `version`, `toc: false` | pages | 날짜가 있는 WebPage | [약관](/jekyll-theme-modootoday/ko/layouts/documents/legal/) |
| `resume` | `display_name`, `headline`, `email`, `phone`, `location`, `links`, `experience`, `education`, `skills` | resume | ProfilePage + Person | [이력서](/jekyll-theme-modootoday/ko/layouts/documents/resume/) |

## 법적 고지

```yaml
---
layout: legal
effective: 2026-01-01
updated: 2026-10-30
---
```

목차는 본문의 `##`, `###` 제목으로 만들어지며 `toc: false`로 숨길 수 있습니다. 날짜는 `datePublished`와 `dateModified`가 됩니다.

## 이력서

```yaml
display_name: Ada Example
experience:
  - {role: 리드 엔지니어, org: Example Docs, start: 2024-03-01}
education:
  - {degree: 학사, school: Example University, end: 2019-02-01}
skills:
  - {group: 언어, items: [Ruby, JavaScript]}
```

`display_name`은 제목이자 Person의 `name`이 되고, 없으면 페이지 제목을 씁니다. `name:`은 쓰지 마세요. Jekyll이 페이지 파일 이름으로 바꾸므로 `modootoday-check`가 경고합니다.

`end`가 없는 항목은 "현재"로 표시되고 Person의 `worksFor`가 됩니다. 학교는 `alumniOf`, 기술은 `knowsAbout`이 됩니다. 마크업에는 h-card 클래스도 들어갑니다. A4와 Letter 용지를 먼저 기준으로 배치하고 화면에서는 다시 흐릅니다.
