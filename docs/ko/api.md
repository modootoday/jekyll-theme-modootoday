---
title: 공개 API
description: 이 테마가 안정적으로 유지하는 이름과, 폐기·제거 절차.
---
# 공개 API

> [!NOTE]
> 이 페이지는 [영어 원문](../../api/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

1.0부터 아래 이름은 [유의적 버전](https://semver.org/lang/ko/)을 따릅니다. 호환되지 않는 변경은 메이저 버전에서만 합니다. 목록에 없는 것(내부 인클루드, Sass 파셜 경로, 비공개 `--mt-p-*` 기본 토큰, 규칙에 없는 HTML 세부)은 어느 릴리스에서든 바뀔 수 있습니다.

## 안정 이름

| 영역 | 안정 이름 |
|---|---|
| 설정 | [설정](../configuration/)에 나온 `modootoday:` 아래 모든 키 |
| 디자인 토큰 | 시맨틱·컴포넌트 사용자 속성 `--mt-*` (기본 토큰 `--mt-p-*` 제외). 생성되는 `tokens.json`도 같음 |
| Markdown 규칙 | `RULES.md`의 패턴과 출력 클래스 `mt-*` |
| 레이아웃 | `default`, `doc`, `post`, `twin`, `llms`, `llms-full` |
| 덮어써도 되는 인클루드 | `head-custom.html`, `footer-custom.html` |
| 데이터 파일 | `_data/i18n/<lang>.yml` 키, `_data/nav/<name>.yml`, `_data/components.yml` |
| 검사기 | `modootoday-check` 옵션, 종료 코드 0(문제 없음)과 1(문제 또는 잘못된 사용법) |

## 폐기 정책

1. 없어질 이름은 `CHANGELOG.md`와 문서에 폐기 예정으로 표시하고, 가능한 곳에서는 검사기가 경고합니다.
2. 최소 한 번의 마이너 릴리스 동안은 계속 동작합니다.
3. 제거는 다음 메이저 릴리스에서만 합니다.

> [!IMPORTANT]
> 예전 `md-*` 클래스와 `--md-*` 속성은 `mt-*`, `--mt-*`의 별칭입니다. 1.x 동안 유지되고 1.0에서 폐기 예정으로 표시되며 2.0에서 제거됩니다. 사이트의 Sass, CSS, include, 레이아웃, 페이지가 이를 쓰면 `modootoday-check`가 경고합니다. [대응표](../upgrade/)를 참고하세요.

## 1.0에 없는 것

- `_data/components.yml`의 파라미터 검사를 넘어서는 컴포넌트 슬롯 계약은 1.x에서 계획합니다.
- 오른쪽에서 왼쪽 레이아웃, 수식, 다이어그램은 1.0의 목표가 아닙니다. [로드맵](../roadmap/)을 보세요.
