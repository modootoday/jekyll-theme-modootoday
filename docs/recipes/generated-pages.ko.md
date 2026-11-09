---
lang: ko
permalink: /ko/recipes/generated-pages/
source_rev: sha256:a2be5639b5f5
nav_order: 27
title: 생성 페이지
description: JSON이나 YAML 데이터 파일의 레코드마다 클래식 GitHub Pages에서 페이지를 하나씩 주고, 전체를 거를 수 있는 목록을 만들고, 파일을 바이트 그대로 게시합니다.
---
# 생성 페이지

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/generated-pages/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

카탈로그, 플러그인 목록, 용어집은 데이터 파일 하나에서 시작하는 경우가 많습니다. Jekyll 4 플러그인은 레코드마다 페이지를 만들 수 있지만, 클래식 GitHub Pages는 사이트의 플러그인을 실행하지 않으므로 페이지마다 저장소에 파일이 있어야 합니다. `modootoday-stubs --records`가 그 파일을 대신 씁니다. 레코드마다 front matter만 있는 짧은 페이지를 하나씩 만들고, 나머지 내용은 사이트를 빌드할 때 레이아웃이 데이터 파일에서 읽습니다.

[docs 스타터의 플러그인 목록](https://modootoday.github.io/jekyll-theme-modootoday-docs-starter/plugins/ "new-window")에서 볼 수 있습니다. JSON 파일 하나에 든 레코드 다섯 개마다 페이지가 있고, 전체를 거를 수 있는 목록도 있습니다.

## 레코드 세트 선언

레코드는 `_data/plugins.json`(또는 `.yml`)에 둡니다. 객체의 목록이거나 `items` 목록이 있는 맵이어야 합니다. 레코드마다 URL에 써도 안전한 키(영문 소문자, 숫자, `.`, `_`, `-`)와 제목이 있어야 합니다.

```json
[
  {"slug": "lantern", "name": "Lantern", "summary": "Highlights the section a reader came to.", "category": "Reading", "version": "2.1.0", "tags": ["search"], "readme": "Lantern reads the words a reader searched for..."}
]
```

그다음 `_config.yml`에 세트 이름을 적습니다.

```yaml
modootoday:
  records:
    plugins: {title: name, description: summary, facts: [category, version, tags], body: readme}
```

| 설정 | 기본값 | 의미 |
|---|---|---|
| `data` | 세트 이름 | 확장자를 뺀 `_data` 안의 파일 이름 |
| `key` | `slug` | 레코드를 가리키는 필드. 파일 이름과 URL이 됨 |
| `dir` | 세트 이름 | 페이지를 둘 폴더 |
| `permalink` | `/<dir>/:key/` | 페이지 URL. `:key`는 레코드 키로 바뀜 |
| `layout` | `detail` | `detail`, `reference`, 또는 `project`, `job` 같은 상세 레이아웃 |
| `title` | `title` | 페이지 제목으로 복사할 필드 |
| `description` | `description` | 페이지 설명으로 복사할 필드 |
| `facts` | 없음 | 제목 아래 정보 목록으로 보여 줄 필드. 목록 값은 태그로 보임 |
| `labels` | 필드 이름 | 정보 항목의 이름표. 예: `{version: 버전}` |
| `body` | 없음 | 페이지 본문으로 변환할 Markdown 필드 |
| `lang` | 없음 | 폴더가 언어를 정하지 않을 때 쓸 페이지 언어 |

## 페이지 쓰기

```sh
modootoday-stubs . --records           # list the pages it would create, update or delete
modootoday-stubs . --records --write   # write them
modootoday-stubs . --records --check   # CI: exit 1 when a page is missing, out of date or left over
```

페이지 하나는 `plugins/lantern.md`입니다.

```yaml
---
layout: detail
title: "Lantern"
description: "Highlights the section a reader came to."
permalink: /plugins/lantern/
record: plugins/lantern
record_index: 0
twin: false
---
```

제목과 설명을 복사하는 이유는 페이지 제목, 링크 미리보기, 구조화된 데이터, 검색 색인이 레이아웃보다 먼저 이 값을 읽기 때문입니다. `record_index`는 목록에서 레코드의 위치입니다. 그래서 페이지는 다른 레코드를 읽지 않고 자기 레코드를 찾습니다. 목록 순서가 바뀌었는데 페이지를 다시 쓰지 않았다면, 페이지는 조금 느리게라도 레코드를 찾고 `--check`는 그 페이지가 낡았다고 알립니다. 사라진 레코드의 페이지는 지웁니다(`--no-prune`이면 남깁니다). 직접 쓴 페이지는 절대 덮어쓰지 않습니다.

`--records=plugins,team`은 이름을 적은 세트만 씁니다. 레코드 페이지에는 Markdown 버전이 없습니다.

커밋할 때마다 이 명령을 실행하세요. 예를 들어 Git pre-commit 훅에서 실행할 수 있습니다.

```sh
#!/bin/sh
modootoday-stubs . --records --write --quiet && git add -A -- plugins
```

## 레코드 목록

디렉터리 페이지는 `items:`나 `data:` 대신 `records:`로 세트를 나열합니다. 카드마다 레코드 페이지로 연결되고, 세트에 적은 필드에서 제목과 글을 가져옵니다.

```yaml
---
title: Plugins
layout: integrations
records: plugins
filter_text: true
---
```

`layout: integrations`는 `category`마다 버튼을 더하고, `filter_text: true`는 글자 필터를 더합니다. [디렉터리 레이아웃](../../layouts/directory/)을 참고하세요.

## 사이트 확인

`modootoday-check`는 페이지가 없는 레코드, 레코드가 없는 페이지, 낡은 페이지를 `modootoday-stubs --records --check`와 같은 기준으로 알립니다. CI에서는 둘 다 실행하세요.

```sh
modootoday-stubs . --records --check
modootoday-check . _site
```

## 파일을 바이트 그대로 게시

front matter가 없는 파일은 그대로 복사되므로, JSON 파일이 든 `api/` 폴더는 작은 정적 API가 됩니다. `modootoday-check . _site --byte-exact=api`가 이를 증명합니다. `api/` 아래 모든 파일이 SHA-256이 같은 채로 빌드에 있어야 합니다. `_data/` 아래 폴더, `exclude:`에 적은 폴더, `_`나 `.`으로 시작하는 폴더(`include:`에 적지 않은 경우), front matter가 있는 파일, Markdown이나 Sass 파일은 실패합니다. Jekyll이 이런 파일은 그대로 복사하지 않기 때문입니다.

## 한계

- 레코드마다 저장소에 파일이 하나씩 있습니다. CI는 테마가 바뀔 때마다 GitHub Pages 빌더로 레코드 1,000개를 빌드하고, Pages 한도의 절반인 300초를 넘으면 실패합니다.
- 목록 끝이 아닌 곳에 레코드를 더하면 그 뒤 페이지들의 `record_index`가 바뀌어 `--write`가 그 페이지들을 다시 씁니다. 커밋을 작게 하려면 새 레코드를 끝에 더하세요.
- 검색 색인에는 레코드 페이지의 제목, 설명, front matter 필드가 들어가고 본문 필드는 들어가지 않습니다.
