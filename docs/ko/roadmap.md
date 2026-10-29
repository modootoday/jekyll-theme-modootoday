---
title: 로드맵
description: 1.0에 들어가는 모든 것과 2.0에서 바뀌는 것.
---
# 로드맵

> [!NOTE]
> 이 페이지는 [영어 원문](../../roadmap/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

1.0은 아래 항목이 모두 끝나면 나옵니다. 따로 1.x 목록은 없고, 나중으로 계획했던 일도 1.0에 들어갑니다.

## 1.0

- 모든 컴포넌트의 라이트·다크 시각 완성도, 문서 사이트와 키친싱크 포함. `status:partial`
- 확정된 규칙(`md-components v1`)과 동결된 [공개 API](../api/), 폐기 정책. `status:available`
- canonical, hreflang, Open Graph 태그와 선택형 사이트맵·피드. `status:available`
- 영어, 한국어, 일본어 문서. `status:available`
- 예제 사이트의 모든 언어에 가이드 페이지. `status:available`
- `_data/components.yml` 슬롯 계약([API](../api/#슬롯-계약)). `status:available`
- 오른쪽에서 왼쪽으로 쓰는 문자: 논리 속성, 자동 `dir="rtl"`, [RTL 키친싱크](../../components/kitchen-sink-rtl/). `status:available`
- 엄격한 CSP에서 KaTeX와 Mermaid를 쓰는 [수식·다이어그램 가이드](../math-diagrams/). 테마는 둘 다 포함하지 않음. `status:available`
- CI에서 기준 스크린숏과 비교하는 시각 회귀 검사(풀 리퀘스트에서 차단)와 Lighthouse 예산. `status:available`
- `post` 레이아웃용 태그·카테고리 아카이브 페이지. `status:planned`

## 2.0

- 폐기 예정인 `md-*` 클래스와 `--md-*` 속성을 제거합니다. [이전과 업그레이드](../upgrade/)를 보세요.
