---
lang: ko
permalink: /ko/layouts/directory/
source_rev: sha256:ee066a8fdb56
title: 디렉터리 레이아웃
description: 프로젝트, 구성원, 채용, 행사, 후원사, 연동을 카드 목록으로 보여 주고, JavaScript 없이 동작하는 필터로 독자가 원하는 카드만 골라 보게 합니다.
nav_order: 20
---
# 디렉터리 레이아웃

디렉터리 페이지는 본문 뒤에 카드 목록이 붙습니다. 카드는 front matter의 `items:`나 `_data`의 파일에서 가져옵니다. 이 레이아웃들은 자기 페이지에서만 `modootoday-directory.css`를 불러오고 텍스트 필터를 켜지 않으면 JavaScript는 추가하지 않습니다.

| 레이아웃 | 카드 내용 | 필터 기준 | 구조화 데이터 | 데모 |
|---|---|---|---|---|
| `portfolio` | 이미지, 제목, 설명, 태그 | `tags` | ItemList | [포트폴리오](portfolio/) |
| `team` | 둥근 사진, 이름, 역할 | `group` | Person 목록 | [팀](team/) |
| `jobs` | 직무, 근무지, 고용 형태 | `department` | ItemList | [채용](jobs/) |
| `events` | 날짜 타일, 제목, 장소, 캘린더 파일 | 없음 | Event 목록 | [행사](events/) |
| `sponsors` | 로고, 이름, 등급 | `tier` | ItemList | [후원사](sponsors/) |
| `integrations` | 로고, 이름, 분류, 설명 | `category` | ItemList | [연동](integrations/) |

`layout: directory`는 기본형입니다. `preset:`에 위 이름 중 하나를 쓰거나, 생략하면 단순한 카드가 됩니다.

다른 테마에서 온 사이트는 `defaults`에서 컬렉션에 같은 이름의 레이아웃을 붙이는 경우가 많습니다. 그래서 `_portfolio/atlas.md`는 `portfolio`가 됩니다. `items:`, `data:`, `records:`가 없는 문서는 목록이 아니라 항목 하나이므로, 이 레이아웃들은 그 문서를 짝이 되는 상세 페이지로 그립니다. `portfolio`는 `project`, `jobs`는 `job`, `events`는 `event`, 나머지는 `detail`이 되고 구조화 데이터도 그 페이지를 따릅니다. 레이아웃이 아예 없는 컬렉션 문서는 테마 없이 출력됩니다(jekyll-default-layout은 페이지와 글에만 레이아웃을 붙입니다). `modootoday-check`가 이를 경고하고 `defaults`에 넣을 레이아웃을 알려 줍니다.

## front matter

| 키 | 용도 |
|---|---|
| `items` | 카드 목록: `title` 또는 `name`, `url`, `text`, `image`, `alt`, `width`, `height`, 아래의 프리셋 필드 |
| `data` | `items` 대신 카드를 읽어 올 `_data` 파일 이름 |
| `records` | `modootoday.records`의 레코드 세트. 카드마다 레코드 페이지로 연결됩니다 |
| `preset` | `layout: directory`에서 위 표의 레이아웃 이름 하나 |
| `filter` | `false`면 필터 버튼을 숨기고, 다른 필드 이름을 주면 그 필드로 거릅니다 |
| `filter_text` | `true`면 입력하는 대로 카드를 좁히는 검색 칸을 더합니다 |

## 항목

```yaml
---
layout: team
items:
  - {name: 김에이다, role: 창업자, group: 경영, image: /assets/ada.jpg, alt: "", url: /about/ada/}
  - {name: 이토 벤, role: 디자이너, group: 디자인}
---
```

항목마다 `title`이나 `name`이 필요합니다. 모든 항목에 `url`, `text`, `image`, `alt`, `width`, `height`를 쓸 수 있으며, 사진이 이름을 반복할 뿐이면 `alt: ""`로 두세요. 프리셋별 필드:

- `team`: `role`, `group`
- `jobs`: `department`, `location`, `type`
- `events`: `date`(필수, `YYYY-MM-DD HH:MM`), `end`, `location`, 온라인 행사면 `online: true`(이때 `url`이 행사 장소)
- `sponsors`: `tier`
- `integrations`: `category`
- `portfolio`: `tags`(목록)

여러 페이지에서 같은 목록을 쓰려면 `_data/team.yml`에 두고 `items:` 대신 `data: team`이라고 쓰세요. 항목마다 페이지도 따로 두려면 레코드 세트를 선언하고 `records: <set>`이라고 쓰세요. 그러면 카드마다 레코드 페이지로 연결됩니다([생성 페이지](../../recipes/generated-pages/) 참고).

## 필터

필터 필드의 값이 두 개 이상이면 카드 위에 버튼 줄이 나타납니다. 라디오 버튼 묶음이라 키보드로 조작할 수 있고 스크린 리더가 선택을 읽어 줍니다. 값은 12개까지 보입니다. 숨기려면 `filter: false`, 다른 필드로 거르려면 `filter: <필드>`를 쓰세요. `:has()`를 지원하지 않는 브라우저에서는 모든 카드가 보입니다.

카드 위에 검색 필드도 두려면 `filter_text: true`를 쓰세요. 입력한 단어가 모두 들어 있는 카드만 보이고 그 개수를 알려 주며, 필드 필터와 함께 동작합니다. JavaScript가 필요하고, JavaScript가 없으면 모든 카드가 보입니다.

## 행사

행사마다 페이지에 들어 있는 `.ics` 파일 링크가 있어 서버 없이 캘린더에 추가할 수 있습니다. 날짜는 사이트의 `timezone`을 따릅니다.
