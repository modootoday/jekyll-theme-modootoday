---
nav_order: 50
title: 로드맵
description: 테마가 지원하는 것, 동작하는 환경, 앞으로의 방향.
---
# 로드맵

> [!NOTE]
> 이 페이지는 [영어 원문](../../../reference/roadmap/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 1.0에서 지원하는 것

- 라이트·다크 모드의 컴포넌트: 알림, 섹션, 카드, 버튼, 탭, 배지, 표, 아코디언, 단계, 그림, 타임라인, 키보드 키, 브레드크럼, 목차, 테마 전환, 검색. [컴포넌트](../../components/)를 보세요.
- 확정된 콘텐츠 규칙(`md-components v1`)과 안정된 [공개 API](../api/).
- 기본으로 켜지는 canonical, `hreflang`, Open Graph 태그. 사이트맵과 피드는 플러그인을 추가하면 쓸 수 있습니다.
- 다국어 사이트용 언어 선택기와 오른쪽에서 왼쪽으로 쓰는 문자 지원([RTL 키친싱크](../../../components/kitchen-sink-rtl/)).
- 직접 만드는 `_data/components.yml`용 슬롯 계약([API](../api/#슬롯-계약)).
- AI 에이전트를 위한 Markdown 트윈과 `llms.txt`([에이전트](../../guides/agents/)).
- `post` 레이아웃용 태그·카테고리 아카이브 페이지.
- 엄격한 콘텐츠 보안 정책 지원([CSP](../../recipes/csp/))과 [수식·다이어그램 가이드](../../recipes/math-diagrams/).
- 영어, 한국어, 일본어 문서.

## 호환성

- `remote_theme`을 쓰는 GitHub Pages(`github-pages` 232, Jekyll 3.10)와 Ruby 3.2~3.4의 Jekyll 4.4. 지원하는 가장 오래된 버전은 Jekyll 3.9입니다.
- 공개 API는 [공개 API](../api/)에 정리되어 있고, 변경 사항은 CHANGELOG에 기록됩니다. [마이그레이션과 업그레이드](../../guides/upgrade/)를 보세요.

## 다음

- 새 컴포넌트와 옵션은 가능한 한 기존 사이트를 깨뜨리지 않게 추가합니다.
