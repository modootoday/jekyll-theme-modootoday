---
lang: ko
permalink: /ko/recipes/site-types/
source_rev: sha256:5bd64dd18a0c
title: 사이트 유형
description: 제품, 회사, 문서, 개인, 커뮤니티 사이트를 어떤 레이아웃으로 만드는지, 그리고 모든 사이트에 필요한 시스템 페이지를 정리합니다.
nav_order: 30
---
# 사이트 유형

각 절은 한 종류의 사이트를 이루는 레이아웃과 그 조합 방법을 알려 줍니다. 절마다 연결한 레이아웃 그룹에 모든 front matter 키와 레이아웃별 라이브 데모가 있습니다.

## 제품 사이트

`/`를 `feature` 페이지로 만들고 `actions:`로 `/pricing/`과 `/download/`에 연결하세요. 모든 요금제는 `pricing` 페이지 하나에 두고, `download`의 `version`과 `date`는 릴리스에 맞춰 설정한 뒤 바닥글에서 `brand` 페이지로 연결하세요. 네 페이지가 `modootoday-marketing.css`를 함께 쓰므로 방문자는 한 번만 내려받습니다.

레이아웃: `feature`, `pricing`, `download`, `brand`. [마케팅 페이지](../../layouts/marketing/)에 있습니다.

## 회사 페이지

사람은 `team`, 채용은 `jobs`와 공고마다 `job` 페이지 하나, 연락 방법은 `contact`, 약관과 개인정보 처리방침은 `effective` 날짜를 넣은 `legal`로 만드세요. 사이트 `publisher`를 한 번만 정하면 모든 페이지의 구조화 데이터가 같은 Organization을 가리킵니다.

레이아웃: `team`과 `jobs`는 [디렉터리 레이아웃](../../layouts/directory/), `job`은 [상세 페이지](../../layouts/detail/), `contact`는 [마케팅 페이지](../../layouts/marketing/), `legal`은 [문서](../../layouts/documents/)에 있습니다.

## 문서 사이트

문서 홈은 섹션마다 카드 하나가 있는 `hub`로 만드세요. `reference`의 members는 CLI나 API에서 생성하고, 릴리스마다 `changelog`에 추가하며, 공통 낱말은 `glossary` 하나에 모아 가이드에서 `/glossary/#term`으로 연결하세요. 이 페이지들은 `modootoday-docs-extra.css`를 불러오고 가이드 페이지는 기본 시트만 씁니다.

레이아웃: `hub`, `reference`, `changelog`, `glossary`. [문서 확장](../../layouts/docs-extra/)에 있습니다.

## 개인 사이트

`/`에 `links` 페이지, `/cv/`에 `resume`, 작업물은 `portfolio`와 `project` 페이지로 두세요. 링크 페이지와 이력서에 같은 `display_name`을 쓰면 두 ProfilePage가 한 Person을 설명합니다. 이력서는 브라우저에서 인쇄하면 깔끔한 PDF가 됩니다.

레이아웃: `links`는 [마케팅 페이지](../../layouts/marketing/), `resume`은 [문서](../../layouts/documents/), `portfolio`는 [디렉터리 레이아웃](../../layouts/directory/), `project`는 [상세 페이지](../../layouts/detail/)에 있습니다.

## 커뮤니티 사이트

모임은 `events`와 행사마다 `event` 페이지로 나열하고, 계획은 `now`, `next`, `later`로 나눈 `roadmap`에 공유하며, 후원자에게는 `sponsors`로 감사하세요. 로드맵 항목을 이슈에 연결하면 독자가 진행 상황을 따라갈 수 있습니다.

레이아웃: `events`와 `sponsors`는 [디렉터리 레이아웃](../../layouts/directory/), `event`는 [상세 페이지](../../layouts/detail/), `roadmap`은 [문서 확장](../../layouts/docs-extra/)에 있습니다.

## 시스템 페이지

`layout: error`로 `404.md`를 추가하고, 옮긴 페이지는 `redirect`를 쓰며, 검색은 `layout: search`로 별도 페이지를 두세요. 이 페이지들은 작은 `pages` 선택 시트를 씁니다. 오류 페이지에는 `sitemap: false`를 넣어 사이트맵에서 빼세요. 오류 페이지는 Markdown 버전이 없고 `llms.txt`에도 실리지 않으므로, `modootoday-check --twins`는 스텁 없이 통과합니다.

레이아웃: `error`, `redirect`, `search`. [페이지 셸](../../layouts/shells/)에 있습니다.
