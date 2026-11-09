---
lang: ko
permalink: /ko/layouts/documents/legal/
source_rev: sha256:ff251ffedd04
title: 약관 레이아웃
description: "날짜, 버전, 목차가 있는 약관과 정책 페이지 레이아웃입니다. 인쇄를 먼저 고려합니다."
layout: layout-reference
nav_order: 1
---
# 약관 레이아웃

`layout: legal`은 이용약관, 개인정보 처리방침처럼 보관하거나 인쇄하는 페이지에 씁니다. 본문 위에 시행일, 마지막 수정일, 버전을 보여 주고, `##`와 `###` 제목으로 목차를 만들며, 인쇄할 때는 사이트 헤더, 푸터, 배너를 숨깁니다. 라이브 데모는 landing 스타터의 개인정보 처리방침입니다.

## Front matter

| 키 | 용도 |
|---|---|
| `effective` | 시행일, `YYYY-MM-DD`(필수) |
| `updated` | 마지막 수정일 |
| `version` | 버전 표시(예: `"3"`) |
| `toc` | `false`면 목차를 숨깁니다 |

```yaml
---
title: Privacy policy
layout: legal
effective: 2026-01-01
updated: 2026-10-30
version: "1"
---
```

날짜는 페이지 구조화 데이터의 `datePublished`와 `dateModified`가 됩니다. 이력서 레이아웃은 [문서](../)에서 다룹니다.
