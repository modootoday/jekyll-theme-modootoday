---
title: 로드맵
description: 1.0에 들어가는 것, 1.x에 올 것, 목표가 아닌 것.
---
# 로드맵

> [!NOTE]
> 이 페이지는 [영어 원문](../../roadmap/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 1.0

- 모든 컴포넌트의 라이트·다크 시각 완성도, 문서 사이트와 키친싱크 포함. `status:partial`
- 안정된 [공개 API](../api/)와 폐기 정책. `status:available`
- canonical, hreflang, Open Graph 태그와 선택형 사이트맵·피드. `status:available`
- 영어와 한국어 문서. `status:available`

## 1.x

- `_data/components.yml` 슬롯 계약([API](../api/#슬롯-계약)). `status:available`
- `post` 레이아웃용 태그·카테고리 아카이브 페이지. `status:planned`
- 일본어 문서 (예제 사이트에는 이미 일본어 페이지가 있음). `status:planned`
- CI에서 기준 스크린숏과 비교하는 시각 회귀 검사. `status:planned`

## 1.0의 목표가 아닌 것

- **오른쪽에서 왼쪽으로 쓰는 문자.** 레이아웃을 뒤집지 않습니다. 새 CSS는 논리 속성을 써서 1.x에서 RTL을 이어 갈 수 있게 합니다.
- **수식과 다이어그램.** 테마는 MathJax, KaTeX, Mermaid를 포함하지 않습니다. github.com은 `math`, `mermaid` 코드 블록을 렌더링하고, 사이트에서는 `_includes/head-custom.html`이나 `footer-custom.html`에서 렌더러를 불러오세요.
