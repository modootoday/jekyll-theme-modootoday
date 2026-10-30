---
title: 문서
description: 법적 고지 페이지와 인쇄 우선 이력서입니다.
nav_order: 60
---
# 문서

인쇄하거나 보관하는 페이지를 위한 레이아웃 두 가지입니다. 둘 다 종이에서는 사이트 머리글, 바닥글, 배너를 숨깁니다.

| 레이아웃 | 프런트 매터 | 번들 | 구조화 데이터 | 데모 |
|---|---|---|---|---|
| `legal` | `effective`(필수), `updated`, `version`, `toc: [{title, id}]` | pages | 날짜가 있는 WebPage | [약관](/jekyll-theme-modootoday/ko/layouts/documents/legal/) |
| `resume` | `name`, `headline`, `email`, `phone`, `location`, `links`, `experience`, `education`, `skills` | resume | ProfilePage + Person | [이력서](/jekyll-theme-modootoday/ko/layouts/documents/resume/) |

## 법적 고지

```yaml
---
layout: legal
effective: 2026-01-01
updated: 2026-10-30
toc: [{title: 서비스 이용, id: use}]
---
```

각 제목에 `toc` 항목과 같은 `id`를 붙이세요(`## 서비스 이용 {#use}`). 날짜는 `datePublished`와 `dateModified`가 됩니다.

## 이력서

```yaml
experience:
  - {role: 리드 엔지니어, org: Example Docs, start: 2024-03-01}
education:
  - {degree: 학사, school: Example University, end: 2019-02-01}
skills:
  - {group: 언어, items: [Ruby, JavaScript]}
```

`end`가 없는 항목은 "현재"로 표시되고 Person의 `worksFor`가 됩니다. 학교는 `alumniOf`, 기술은 `knowsAbout`이 됩니다. 마크업에는 h-card 클래스도 들어갑니다. A4와 Letter 용지를 먼저 기준으로 배치하고 화면에서는 다시 흐릅니다.
