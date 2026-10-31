---
title: 문서 확장
description: 레퍼런스, 변경 이력, 로드맵, 용어집, 허브, 강좌, 책 페이지를 공유 선택 스타일시트 하나로 만듭니다.
nav_order: 50
---
# 문서 확장

설명서 주변 페이지를 만드는 레이아웃입니다. 자기 페이지에서만 `modootoday-docs-extra.css`를 불러오고 JavaScript는 추가하지 않습니다. 모든 레이아웃은 제목과 소개 문장인 `description:`을 읽으며, 본문은 생성된 부분 뒤에 옵니다.

| 레이아웃 | front matter | 구조화 데이터 | 데모 |
|---|---|---|---|
| `reference` | `members: [{name, signature, text, since, id}]` | TechArticle | [레퍼런스](/jekyll-theme-modootoday/ko/layouts/docs-extra/reference/) |
| `changelog` | `releases: [{version, date, url, added, changed, fixed, removed, security}]` | WebPage | [변경 이력](/jekyll-theme-modootoday/ko/layouts/docs-extra/changelog/) |
| `roadmap` | `items: [{title, status, text, url}]`, status는 `now`, `next`, `later` | WebPage | [로드맵](/jekyll-theme-modootoday/ko/layouts/docs-extra/roadmap/) |
| `glossary` | `terms: [{term, text, id}]` | DefinedTermSet | [용어집](/jekyll-theme-modootoday/ko/layouts/docs-extra/glossary/) |
| `hub` | `cards: [{title, text, url}]` | CollectionPage | [허브](/jekyll-theme-modootoday/ko/layouts/docs-extra/hub/) |
| `course` | `level`, `modules: [{title, lessons: [{title, url, minutes}]}]` | Course | [강좌](/jekyll-theme-modootoday/ko/layouts/docs-extra/course/) |
| `book` | `image`, `author`, `isbn`, `pages`, `chapters: [{title, url}]` | Book | [책](/jekyll-theme-modootoday/ko/layouts/docs-extra/book/) |
| `reference`에 `sidebar: true`, `packages:` | 멤버의 `group`, `packages: [{name, version, text, url, links: [{label, url}]}]`, `packages_title` | TechArticle | [API 레퍼런스](/jekyll-theme-modootoday/ko/layouts/docs-extra/api/) |

## 변경 이력

릴리스마다 변경 사항을 다섯 분류 제목 아래 정해진 순서로 보여 주며, 제목은 페이지 언어로 표시됩니다. 항목은 Markdown입니다. `modootoday-check`는 다른 키를 보고하므로 `fix:` 같은 오타가 조용히 사라지지 않습니다.

## 용어집

용어는 자동으로 정렬되고 첫 글자로 묶이며, 글자 막대는 쓰인 글자에만 연결됩니다. 용어마다 앵커(`id:` 또는 용어의 슬러그)가 붙고, 페이지 데이터에는 각각 DefinedTerm으로 들어갑니다.

## 강좌

수업의 `minutes`를 더한 값이 제목 아래 총 시간과 `timeRequired`가 됩니다. 강좌 제공자는 사이트 게시자이며 `description:`은 필수입니다.

## API 사이드바와 패키지 표

둘 다 `reference` 레이아웃에서 원할 때만 켜며, 쓰지 않은 페이지는 예전과 똑같이 그려집니다. `sidebar: true`를 주면 멤버 목록이 옆 열로 옮겨 가고 넓은 화면(64rem 이상)에서는 스크롤해도 계속 보입니다. `group:`이 같은 멤버는 그 이름 아래 모이며, 그룹은 처음 나온 순서를 따릅니다. 좁은 화면에서는 같은 목록이 본문 위에 놓입니다. `packages:`는 본문 앞에 패키지마다 한 줄씩 이름·버전·링크를 담은 표를 넣고, `text`는 이름 아래에 보입니다. 작은 화면에서는 줄마다 작은 카드처럼 쌓입니다. `packages:`가 있는 레퍼런스 페이지는 `members:`를 생략해도 됩니다. 둘 다 CSS만 씁니다.

## 검사

`modootoday-check`는 각 레이아웃의 기본 목록, 올바른 `status`, 용어마다 `text`, 중복 없는 용어, 허브 카드마다 `url`, 정수인 `minutes`와 `pages`, 10자리 또는 13자리 `isbn`을 요구합니다.
