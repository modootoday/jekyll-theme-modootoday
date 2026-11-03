---
lang: ko
permalink: /ko/recipes/search/
source_rev: sha256:cf7c0dca55a3
nav_order: 25
title: 검색
description: 헤더 검색을 켜고, 색인에 담을 내용과 검색어를 맞추는 방식을 정하고, 긴 목록이나 표를 독자가 거를 수 있게 합니다.
---
# 검색

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/search/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

헤더 검색은 Liquid가 만드는 `search.json` 파일 하나를 읽습니다. 그래서 플러그인이나 외부 서비스 없이 클래식 GitHub Pages에서도 동작합니다. 스크립트는 독자가 검색창에 처음 들어갈 때 이 파일을 불러옵니다.

## 켜기

사이트 루트에 `search.json` 파일을 추가합니다. front matter에 `layout: null`을 쓰고, 본문은 `modootoday/search.json`을 include하는 한 줄입니다. [이 사이트가 쓰는 파일](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/search.json)을 복사해 쓰세요.

모든 페이지의 헤더에 검색창이 나타납니다. front matter에 `search: false`를 쓴 페이지와 제목이 없는 페이지는 빠집니다.

## 색인할 내용 정하기

```yaml
modootoday:
  search:
    words: 2000                 # 각 페이지 본문에서 색인할 단어 수. 0이면 전부(기본 300)
    collections: [skills]       # output: true인 컬렉션. 글 다음에 색인합니다
    fields: [description, tags] # 본문과 함께 검색할 front matter
    exclude: [/v1/]             # 뺄 URL 접두사. 예: 예전 버전 문서
```

본문을 길게 담을수록 더 많이 찾지만, 독자는 처음 검색할 때 색인 전체를 내려받습니다. 빌드된 `search.json`이 1.5 MB를 넘으면 `modootoday-check`가 경고합니다.

## 검색어를 맞추는 방식 정하기

```yaml
modootoday:
  search:
    match: terms   # 모든 단어를 순서와 상관없이(기본 substring은 입력한 그대로)
    compact: true  # 공백을 뺀 비교도 합니다
    results: 12    # 기본 8
```

대소문자를 구분하지 않고 텍스트를 유니코드 NFC로 맞춰 비교하므로, 두 가지 방식으로 쓴 악센트나 한글 음절도 서로 찾습니다. `compact: true`는 한국어처럼 띄어쓰기가 흔들리는 언어를 위한 설정입니다. 검색량조회로 검색량 조회를 찾고, 반대도 됩니다. 제목이 맞는 페이지가 먼저 나오고, 페이지 언어의 결과가 다른 언어보다 먼저 나옵니다. 어간 처리와 초성 검색은 하지 않습니다.

이 키가 없으면 검색은 예전과 같습니다. 입력한 그대로 찾고, 결과는 8개, 페이지마다 300단어를 색인합니다.

## 목록이나 표 거르기

한 페이지의 긴 목록이나 표는 그 `sections:` 항목에 `filter:`를 추가하거나, `sections:`가 없는 페이지라면 front matter에 추가합니다.

```yaml
sections:
  - {name: tools, filter: true}
  - {name: plans, filter: {facet: 3}}
```

그 섹션의 첫 목록이나 표 위에 필드가 생기고, 입력한 단어가 모두 들어 있는 항목만 보이며 몇 개가 보이는지 알려 줍니다. 비교 방식은 `compact: true`와 같습니다. `facet: 3`은 표의 세 번째 열 값마다 버튼을 추가합니다. 디렉터리 페이지에서는 `filter_text: true`로 카드 위에 같은 필드를 둡니다. JavaScript가 없으면 모든 항목이 보입니다. [필터 데모](../../layouts/demo/filter/)를 보세요.
