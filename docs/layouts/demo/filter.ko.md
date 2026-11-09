---
lang: ko
permalink: /ko/layouts/demo/filter/
source_rev: sha256:d9a038f1e026
nav_exclude: true
title: 필터 데모
twin: false
sitemap: false
edit: false
description: 입력해서 좁혀 보는 목록과 표, 그리고 표의 값마다 붙는 버튼입니다. 섹션 파라미터 filter:로 필터를 설정하는 방법을 실제 페이지로 보여 줍니다.
sections: [{name: tools, filter: true}, {name: plans, filter: {facet: 3}}, setup]
---
# 필터 데모

목록이나 표 위의 필드에 입력해 보세요. 입력한 단어가 모두 들어 있는 항목만 남습니다. 대소문자, 두 가지 방식으로 쓴 악센트, 한국어 띄어쓰기는 구분하지 않습니다. JavaScript가 없으면 모든 항목이 보입니다.

[검색 레시피](../../../recipes/search/)

## 도구

- **검색량 조회**: 띄어 쓰지 않고 "검색량조회"로 입력해도 찾습니다
- **순위 추적**: 페이지 순위가 시간에 따라 어떻게 바뀌는지 봅니다
- **트렌드 차트**: 지난 1년 동안의 관심도
- **연관 검색어**: 함께 검색하는 단어
- **Keyword volume**: 영어 항목도 대소문자 구분 없이 찾습니다

## 요금제

| 요금제 | 가격 | 종류 |
|---|---|---|
| 스타터 | 0 | 무료 |
| 팀 | 9 | 유료 |
| 보관 | 0 | 무료 |
| 비즈니스 | 29 | 유료 |

## 설정

```yaml
# front matter
sections:
  - {name: tools, filter: true}
  - {name: plans, filter: {facet: 3}}
  - setup
```

`filter: true`는 그 섹션의 첫 목록이나 표를 거릅니다. `{facet: 3}`은 세 번째 열의 값마다 버튼도 추가합니다. 버튼을 누르면 그 값의 행만 보이고, 다시 누르면 전부 보입니다. `sections:`가 없는 페이지에서는 front matter에 `filter:`를 쓰세요. 필터가 있는 페이지만 `filter.js`와 그 시트를 불러옵니다.
