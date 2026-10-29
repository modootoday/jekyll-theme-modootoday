---
title: 컴포넌트
description: 모든 컴포넌트와 그것을 만드는 Markdown.
sections:
  - {c: features, name: catalog, cols: 2}
  - status
  - {c: cta, name: next}
---
# 컴포넌트

모든 컴포넌트는 평범한 Markdown입니다. github.com에서는 기본 요소로 보입니다.

[키친싱크 열기](kitchen-sink/)

> [!NOTE]
> 이 페이지는 [영어 원문](../../components/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 목록

- **알림** — `> [!NOTE]` 등 다섯 종류가 콜아웃이 됩니다. `status:available`
- **섹션** — `sections:` front matter가 `##` 제목을 레이아웃에 연결합니다. `status:available`
- **카드** — `- **제목** — 설명` 목록이 그리드가 됩니다. `status:available`
- **버튼** — 링크만 있는 문단이 행동 유도 버튼이 됩니다. `status:available`
- **탭** — `###`과 코드 블록 쌍이 접근 가능한 탭이 됩니다. `status:available`
- **상태 배지** — status 코드 스팬이 배지가 됩니다. `status:available`
- **표** — GFM 표는 작은 화면에서 가로로 스크롤됩니다. `status:available`
- **아코디언과 단계** — `c: accordion`, `c: steps` 섹션. `status:available` `since:0.3`
- **그림** — 이미지 다음에 강조만 있는 문단. `status:available` `since:0.3`
- **브레드크럼, 목차, 테마 전환** — 레이아웃이 자동으로 붙입니다. `status:available` `since:0.3`
- **tag·since 배지** — tag, since 코드 스팬. `status:available` `since:0.3`
- **타임라인** — `c: timeline` 섹션. `status:available` `since:0.4`
- **키보드 키** — `kbd:Ctrl+K` 코드 스팬. `status:available` `since:0.4`
- **검색** — `search.json` 파일로 클라이언트 검색. `status:available` `since:0.4`
- **컴포넌트 슬롯** — `_data/components.yml` 슬롯 계약. `status:planned`

## 상태 범례

| 배지 | 의미 |
|---|---|
| `status:available` | 출시되어 안정적 |
| `status:partial` | 알려진 한계가 있음 |
| `status:planned` | 로드맵에 있음 |

## 다음

[키친싱크](kitchen-sink/) [설정](../configuration/)
