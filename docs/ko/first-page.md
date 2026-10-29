---
title: 첫 페이지
description: front matter, 섹션, 알림으로 페이지를 씁니다.
sections:
  - front-matter
  - body
  - rules
  - {c: cta, name: next}
---
# 첫 페이지 쓰기

페이지는 작은 front matter가 붙은 Markdown 파일입니다. 나머지는 테마가 합니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../first-page/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## Front matter

```yaml
---
title: 시작하기
description: 검색 결과와 llms.txt에 표시됩니다
sections:
  - {c: features, name: highlights}
  - {c: cta, name: next}
---
```

`sections:` 항목은 최상위 `##` 제목에 순서대로 하나씩 대응합니다. 일반 글이면 `sections:`를 빼세요.

## 본문

```markdown
# 시작하기

페이지를 설명하는 한 문장.

## 특징

- **빠름** — 1초 안에 빌드됩니다.
- **평범함** — GitHub에서 그대로 읽힙니다.

## 다음

[설치](../install/)
```

> [!NOTE]
> 첫 `##` 앞의 내용은 히어로가 됩니다. 링크만 있는 문단은 버튼이 됩니다.

## 1분 규칙 요약

| 허용 | 금지 |
|---|---|
| GFM 표, 목록, 작업 목록 | 원시 HTML과 HTML 주석 |
| 언어 한 단어의 코드 펜스 | 본문의 Liquid 태그 |
| 최상위 GitHub 알림 | kramdown 속성과 `{#id}` |
| `<https://…>` 자동 링크 | 맨 URL |

전체 목록은 [RULES.md](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/RULES.md)에 있습니다.

## 다음

[컴포넌트 살펴보기](../components/) [설치로 돌아가기](../install/)
