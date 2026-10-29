---
title: 설정
description: _config.yml의 modootoday 키 아래 사이트 전체 설정.
sections:
  - keys
  - i18n
  - registry
  - {c: cta, name: next}
---
# 설정

모두 선택 사항입니다. 다른 플러그인과 겹치지 않도록 설정은 `modootoday:` 키 하나에 모입니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../configuration/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 키

```yaml
modootoday:
  badges: true        # 코드 스팬을 상태 배지로
  color_scheme: auto  # auto | light | dark
  components: [callout, badge, cta, card, tabs]
  tokens: {primary: "#4f46e5", radius: "0.5rem"}
```

| 키 | 기본값 | 효과 |
|---|---|---|
| `badges` | `true` | status 코드 스팬을 배지로 바꿈. `false`면 코드 그대로 |
| `color_scheme` | `auto` | OS를 따르거나 라이트·다크 고정 |
| `components` | 핵심 전체 | 내보내는 CSS와 JS를 줄임 |
| `tokens` | 테마 값 | 디자인 토큰을 인라인으로 덮어씀 |

> [!NOTE]
> `badges` 외의 키는 v0.2부터 동작합니다. 그 전에는 안전하게 무시됩니다.

## 언어

인터페이스 문자열은 `_data/i18n/<lang>.yml`에, 페이지는 `<lang>/`에 둡니다.

```yaml
language: 한국어
callout: {note: 참고, tip: 팁, important: 중요, warning: 경고, caution: 주의}
tabs: {label: 설치 방법}
status: {available: 사용 가능, partial: 일부 구현, planned: 계획}
skip: 본문으로 건너뛰기
```

없는 키는 영어로 대체됩니다.

## 컴포넌트 레지스트리

선택 파일 `_data/components.yml`이 있으면 검사기가 `sections:` 매개변수를 검증합니다.

```yaml
features: {params: {cols: {allowed: [2, 3], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```

## 다음

[모양 바꾸기](../customize/) [컴포넌트](../components/)
