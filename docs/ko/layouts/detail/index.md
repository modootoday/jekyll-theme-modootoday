---
title: 상세 페이지
description: 프로젝트, 사례 연구, 채용 공고, 행사, 팟캐스트 에피소드를 한 페이지에 하나씩 보여 주며 정보 목록, 행동 유도 하나, 구조화 데이터를 갖춥니다.
nav_order: 30
---
# 상세 페이지

상세 페이지는 항목 하나를 보여 줍니다. 머리말, front matter에서 읽은 정보 목록, 본문, 행동 유도 링크 하나로 구성됩니다. 이 레이아웃들은 자기 페이지에서만 `modootoday-detail.css`를 불러오고 JavaScript는 추가하지 않습니다. 같은 front matter로 schema.org 주요 개체를 출력하며, `schema:` 맵에 적은 속성이 우선합니다. 선택 항목인 `image: {path, alt, width, height}`를 주면 머리글 아래에 표지 이미지를 보여 줍니다.

| 레이아웃 | 정보 | 행동 유도 | 구조화 데이터 | 데모 |
|---|---|---|---|---|
| `project` | 고객, 역할, 연도, 기술, 링크 | `cta` | CreativeWork | [프로젝트](/jekyll-theme-modootoday/ko/layouts/detail/project/) |
| `case-study` | 고객, 역할, 연도, 기술, 링크 | `cta` | Article | [사례 연구](/jekyll-theme-modootoday/ko/layouts/detail/case-study/) |
| `job` | 근무지, 고용 형태, 급여, 게시일, 마감일 | 지원하기 (`apply`) | JobPosting | [채용](/jekyll-theme-modootoday/ko/layouts/detail/job/) |
| `event` | 시작, 종료, 장소, 온라인 | 티켓과 .ics 파일 | Event | [행사](/jekyll-theme-modootoday/ko/layouts/detail/event/) |
| `episode` | 시즌과 회차, 게시일, 길이, 오디오 플레이어 | `cta` | PodcastEpisode | [에피소드](/jekyll-theme-modootoday/ko/layouts/detail/episode/) |

## 채용 공고

```yaml
---
layout: job
title: 테크니컬 라이터
description: 제품 문서를 쓰고 관리합니다.
date: 2026-10-01          # datePosted
deadline: 2026-12-01      # validThrough
employment: full-time     # full-time, part-time, contractor, temporary, intern, volunteer, per-diem, other
location: 서울            # 또는 remote: South Korea (지원자가 거주해야 하는 국가)
salary: {min: 50000000, max: 70000000, currency: KRW, unit: year}
apply: mailto:jobs@example.com
---
```

채용 기관은 사이트 발행자(`modootoday.schema.publisher`)입니다. `date`가 없거나, `location`과 `remote`가 모두 없거나, 알 수 없는 `employment` 값이면 `modootoday-check`가 알려 줍니다.

## 행사

```yaml
---
layout: event
title: 테마 밋업
starts: 2026-11-20 19:00:00 +0900
ends: 2026-11-20 21:00:00 +0900
venue: A홀               # 장소, 온라인 URL, 또는 둘 다
address: 서울시 중구 세종대로 1
online: https://example.com/live
tickets: https://example.com/tickets
---
```

캘린더 링크는 `data:` URL에 담긴 .ics 파일이라 서버 없이 동작합니다.

## 에피소드

```yaml
---
layout: episode
title: 첫 방송
date: 2026-10-10
season: 1
episode: 3
duration: 42              # 분
audio: /media/ep3.mp3
transcript: /podcast/3/transcript/
---
```

플레이어는 브라우저 기본 `<audio controls>`이며, 재생하기 전에는 아무것도 내려받지 않습니다.

## 프로젝트와 사례 연구

```yaml
---
layout: project           # 또는 case-study (저자와 날짜가 있는 Article)
title: 아틀라스
client: ACME
role: 디자인과 개발
year: 2026
stack: [Jekyll, Sass]
links:
  - {label: 저장소, url: "https://example.com/atlas"}
cta: {label: 문의하기, url: /contact/}
---
```

## 접근성

글은 제목으로 이름이 붙고, 정보는 설명 목록(`dl`)이며, 반복되는 링크(지원하기, 티켓)는 화면 낭독기에 페이지 제목을 함께 알려 줍니다. 인쇄할 때는 행동 유도와 플레이어를 숨깁니다.
