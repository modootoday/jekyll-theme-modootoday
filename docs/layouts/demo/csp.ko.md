---
lang: ko
permalink: /ko/layouts/demo/csp/
source_rev: sha256:048d7062e0e6
nav_exclude: true
title: 엄격한 CSP 데모
twin: false
sitemap: false
edit: false
description: 핵심 컴포넌트를 한 페이지에 모아, 인라인 스크립트와 스타일을 막는 엄격한 콘텐츠 보안 정책 아래에서도 제대로 보이는지 확인합니다.
sections:
  - alerts
  - {c: tabs, name: tabs}
  - {c: accordion, name: accordion}
  - {c: steps, name: steps}
  - {c: faq, name: faq}
  - figure
  - tables
  - code
  - inline
  - {c: install, name: install}
---
# 엄격한 CSP 데모

이 페이지에는 핵심 컴포넌트와 코드, 표, 그림이 있습니다. 문서 QA는 이 페이지를 엄격한 `Content-Security-Policy` 헤더와 함께 보내고, 위반이 하나라도 있으면 실패합니다. [콘텐츠 보안 정책](../../../recipes/csp/)을 보세요.

- 일반 Markdown
- 인라인 스크립트와 스타일 없음

[CSP 레시피 읽기](../../../recipes/csp/) [성능](../../../guides/performance/)

## 알림

> [!NOTE]
> 알림은 클래스가 붙은 인용문이며 인라인 요소가 없습니다.

> [!WARNING]
> 알림 안에 `inline code`와 [레이아웃 데모](../) 같은 링크를 넣을 수 있습니다.

## 탭

### npm

```sh
npm install
```

### gem

```sh
gem install jekyll-theme-modootoday
```

## 아코디언

### 아코디언에 인라인 스크립트가 필요한가요?

아닙니다. `accordion.js`는 `assets/js/` 아래의 파일입니다.

### 여기서도 복사 버튼이 동작하나요?

네. 페이지에 코드 블록이 있으므로 `code-copy.js`를 불러옵니다.

## 단계

1. 사이트를 빌드합니다.
2. 정책을 붙여 사이트를 제공합니다.
3. 위반 건수를 셉니다.

## FAQ

### 어떤 정책인가요?

`default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:`에 `worker-src`와 `manifest-src`를 더한 정책입니다.

## 그림

![왼쪽의 Markdown 원본이 오른쪽에서 스타일이 적용된 페이지가 됩니다](../../../../assets/images/sample.svg)

*SVG 그림은 인라인 스타일 없이 포커스할 수 있는 영역 안에서 스크롤됩니다.*

## 표

| 항목 | 불러오는 곳 | 인라인 |
|---|---|---|
| 테마 CSS | `assets/css/` | 아니요 |
| 테마 스크립트 | `assets/js/` | 아니요 |
| 사전 페인트 스크립트 | `csp: strict`일 때 `theme-init.js` | 아니요 |

## 코드

`file:_config.yml`

```yaml
modootoday:
  csp: strict
```

## 인라인

배지 `status:available` `tag:beta`, 키 `kbd:Ctrl+K`, 진행률 `progress:60`, 스피너 `loading:spinner`.

## 설치

이 문서를 홈 화면에 두고 네트워크 없이 읽을 수 있습니다. 버튼은 브라우저가 설치를 제안할 때만 나타납니다.
