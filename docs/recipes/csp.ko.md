---
lang: ko
permalink: /ko/recipes/csp/
source_rev: sha256:ac360e7da233
nav_order: 20
nav_title: CSP
title: 콘텐츠 보안 정책
description: unsafe-inline 없이 엄격한 CSP에서 테마 쓰기.
---
# 콘텐츠 보안 정책

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/csp/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

테마는 CSS와 스크립트를 `assets/` 아래 파일에서 불러옵니다. 기본값에서 인라인인 것은 두 가지입니다.

| 인라인 항목 | 조건 | 엄격 옵션 |
|---|---|---|
| 사전 페인트 테마 스크립트 (잘못된 색 모드가 깜빡이는 것을 막음) | `theme-toggle`이 켜져 있고 `color_scheme: auto` | `modootoday.csp: strict`면 `assets/js/modootoday/chrome/theme-init.js`를 차단형 스크립트로 불러옴 |
| `<style id="mt-tokens">` | `modootoday.tokens` 또는 `tokens_dark` 설정 시 | 값을 토큰 브리지(`_sass/modootoday/_site.scss`, [브랜드 토큰](../brand-tokens/) 참고)로 옮기고 키를 제거 |

둘 다 처리하면 다음 정책으로 동작합니다.

```text
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:
```

`:---`, `:---:`, `---:`로 정렬한 표 열은 예외입니다. kramdown은 정렬을 `style` 속성으로 쓰는데, 이 정책은 그 속성을 막습니다. 그래서 그 열은 기본 정렬로 돌아가고 브라우저는 위반을 보고합니다. 이 정책으로 보내는 페이지에서는 열 정렬을 쓰지 마세요.

GitHub Pages는 응답 헤더를 보낼 수 없습니다. 이 지시어들은 `_includes/head-custom.html`의 `<meta http-equiv="Content-Security-Policy">` 태그로 쓸 수 있습니다. 인라인 스크립트를 유지하려면 해시로 허용하세요. 해시는 스크립트가 바뀔 때만 바뀌며 `CHANGELOG.md`에 공지합니다.

테마의 문서 QA는 [엄격한 CSP 데모](../../layouts/demo/csp/)를 비롯한 예시 페이지를 이 정책을 응답 헤더로 붙여 보내고, 위반이 하나라도 있으면 실패합니다.

이 정책에서 수식이나 다이어그램을 넣으려면 [수식과 다이어그램](../math-diagrams/)을 보세요.
