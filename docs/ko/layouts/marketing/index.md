---
title: 마케팅 페이지
description: 기능, 요금, 다운로드, 브랜드, 링크, 문의 페이지를 공유 선택 스타일시트 하나로 만듭니다.
nav_order: 40
---
# 마케팅 페이지

제품을 둘러싼 페이지를 만드는 레이아웃입니다. 무엇을 하는지, 얼마인지, 어디서 받는지, 어떻게 보여 줄지, 어떻게 연락하는지를 다룹니다. 자기 페이지에서만 `modootoday-marketing.css`를 불러오고 JavaScript는 추가하지 않습니다. 모든 레이아웃은 제목, 소개 문장인 `description:`, 선택 사항인 `actions: [{label, url}]` 버튼을 읽습니다.

| 레이아웃 | front matter | 구조화 데이터 | 데모 |
|---|---|---|---|
| `feature` | `features: [{title, text}]`, `cta` | WebPage | [기능](/jekyll-theme-modootoday/ko/layouts/marketing/feature/) |
| `pricing` | `plans`, `currency` | WebPage | [요금](/jekyll-theme-modootoday/ko/layouts/marketing/pricing/) |
| `download` | `version`, `date`, `downloads: [{label, url, size, checksum}]` | WebPage | [다운로드](/jekyll-theme-modootoday/ko/layouts/marketing/download/) |
| `brand` | `colors: [{name, hex}]`, `assets: [{label, url, format}]` | WebPage | [브랜드](/jekyll-theme-modootoday/ko/layouts/marketing/brand/) |
| `links` | `image`, `name`, `links: [{label, url}]` | ProfilePage | [링크](/jekyll-theme-modootoday/ko/layouts/marketing/links/) |
| `contact` | `contacts: [{label, value, url}]`, `form: {action, fields}` | ContactPage | [문의](/jekyll-theme-modootoday/ko/layouts/marketing/contact/) |

제품 정보를 구조화 데이터로 내보내려면 `schema:` 맵(예: `type: SoftwareApplication`과 `offers`)을 추가하세요. 주요 개체로 출력됩니다.

## 요금

```yaml
---
layout: pricing
currency: ₩
plans:
  - {name: 무료, monthly: 0, yearly: 0, features: [사이트 1개]}
  - {name: 팀, monthly: "15,000", yearly: "150,000", recommended: true, features: [사이트 10개, 지원], cta: {label: 팀 요금제 선택, url: /buy/}}
---
```

요금제 카드는 요금 컴포넌트 스타일을 씁니다. 요금제에 `yearly`가 있으면 라디오 버튼 두 개로 만든 월간/연간 전환이 CSS만으로 가격을 바꿉니다. `yearly`는 모든 요금제에 넣거나 하나도 넣지 마세요. `recommended`는 하나만 지정할 수 있고 글자로 표시됩니다.

## 링크

링크 페이지에는 사이트 머리글이 없습니다. `links:`는 큰 버튼이 되고, 전체 URL은 ProfilePage 데이터의 Person(또는 `profile: organization`)에 `sameAs`로 들어갑니다.

## 문의

```yaml
---
layout: contact
contacts:
  - {label: 이메일, value: hello@example.com, url: "mailto:hello@example.com"}
form:
  action: https://forms.example.com/your-form   # 외부 폼 서비스, https만
  fields: [name, email, message]
---
```

GitHub Pages는 폼 전송을 받을 수 없으므로 `form.action`을 지정해야 폼이 나타납니다. 모든 입력란에는 보이는 레이블과 `autocomplete`가 있습니다.

## 브랜드

색상 견본은 SVG 채우기라서 엄격한 콘텐츠 보안 정책(CSP)에서도 인라인 스타일이 필요 없고, 색마다 16진수 코드를 글자로도 보여 줍니다. `#rgb`나 `#rrggbb`가 아닌 색은 `modootoday-check`가 알려 줍니다.
