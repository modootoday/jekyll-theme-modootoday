---
lang: ko
permalink: /ko/layouts/marketing/pricing/
source_rev: sha256:252e03b3e520
title: 요금제 레이아웃
description: "JavaScript 없이 월간과 연간을 바꾸는 요금제 카드 레이아웃입니다."
layout: layout-reference
nav_order: 2
twin: true
---
# 요금제 레이아웃

`layout: pricing`은 본문 다음에 요금제마다 카드를 하나씩 보여 줍니다. 요금제에 연간 가격이 있으면 라디오 버튼 두 개로 만든 월간/연간 전환이 CSS만으로 가격을 바꾸고, 요금제 하나를 추천으로 표시할 수 있습니다. 추천은 텍스트로도 표시됩니다. 라이브 데모는 landing 스타터의 요금제 페이지입니다.

## Front matter

| 키 | 용도 |
|---|---|
| `plans` | 카드 목록: `name`, `monthly`, `yearly`, `features`(목록), `recommended: true`, `cta: {label, url}` |
| `currency` | 모든 가격 앞에 붙는 기호(예: `$`) |
| `description` | 제목 아래의 리드 문장 |
| `actions` | 리드 아래의 버튼: `[{label, url}]` |

```yaml
---
layout: pricing
currency: $
plans:
  - {name: Free, monthly: 0, yearly: 0, features: [One site]}
  - {name: Team, monthly: 12, yearly: 120, recommended: true, features: [Ten sites, Support], cta: {label: Choose Team, url: /buy/}}
---
```

`yearly`는 모든 요금제에 쓰거나 하나도 쓰지 않습니다. 다른 마케팅 레이아웃과 front matter는 [마케팅 페이지](../)에 있습니다.
