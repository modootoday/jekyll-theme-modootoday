---
lang: ko
permalink: /ko/layouts/directory/integrations/
source_rev: sha256:4ed08212de50
title: 연동 레이아웃
description: "연동이나 플러그인을 로고, 분류와 함께 카드로 보여 주고 분류로 거르는 레이아웃입니다."
layout: layout-reference
nav_order: 6
twin: true
---
# 연동 레이아웃

`layout: integrations`는 연동, 플러그인, 확장 기능을 카드로 나열합니다. 카드마다 로고, 이름, 분류, 한 줄 설명이 들어갑니다. 카드는 `items:`, `_data`의 파일, 레코드 묶음에서 만들 수 있고, 레코드 묶음이면 카드마다 자기 레코드 페이지로 연결됩니다. 분류가 두 개 이상이면 JavaScript 없이 카드를 거르는 버튼 줄이 나타납니다. 라이브 데모는 레코드 다섯 개로 만든 docs 스타터의 플러그인 목록입니다.

## Front matter

| 키 | 용도 |
|---|---|
| `items` | 카드 목록: `name` 또는 `title`, `category`, `text`, `url`, `image`, `alt`, `width`, `height` |
| `data` | `items` 대신 카드를 읽을 `_data` 파일 이름 |
| `records` | `modootoday.records`의 레코드 묶음. 카드마다 레코드 페이지로 연결됩니다 |
| `filter` | `false`면 분류 버튼을 숨기고, 다른 필드 이름을 쓰면 그 필드로 거릅니다 |
| `filter_text` | `true`면 입력하는 대로 카드를 좁히는 검색 칸을 더합니다 |

페이지는 구조화 데이터에 `ItemList`를 넣습니다. 모든 디렉터리 레이아웃의 항목, 필터, 레코드 묶음은 [디렉터리 레이아웃](../)에, 레코드마다 페이지를 만드는 방법은 [생성 페이지](../../../recipes/generated-pages/)에 있습니다.
