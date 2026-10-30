---
nav_order: 10
title: 키친싱크
description: 구현된 모든 컴포넌트와 변형을 한 페이지에서 시각 점검합니다.
hero: {checks: true}
sections:
  - alerts
  - {c: features, name: cards-2, cols: 2}
  - {c: features, name: cards-3, cols: 3}
  - {c: features, name: cards-4, cols: 4}
  - {c: tabs, name: tabs-2}
  - {c: tabs, name: tabs-many}
  - badges
  - {c: accordion, name: accordion}
  - {c: steps, name: steps-list}
  - {c: steps, name: steps-headings}
  - figure
  - {c: timeline, name: timeline}
  - {c: timeline, name: timeline-list}
  - keyboard
  - tables
  - code
  - {name: typography, visual: flat-list}
  - {c: cta, name: cta}
  - code-titles
  - progress
  - embeds
  - loading
  - {c: filetree, name: filetree}
  - {c: details, name: details}
  - {c: faq, name: faq}
  - {c: params, name: params}
  - {c: linkcards, name: linkcards}
  - {c: quote, name: quote}
  - {c: gallery, name: gallery}
  - {c: pricing, name: pricing, recommended: 2}
  - {c: subscribe, name: subscribe}
  - {c: split, name: split, visual: split-demo, decor: decor-demo, tag: "일러스트", side: start, ratio: "5:7", label: "제목, 텍스트 두 줄, 버튼이 있는 화면"}
  - lists
---
# 키친싱크

테마가 제공하는 모든 컴포넌트를 모든 변형으로 보여 줍니다. 같은 파일을 github.com에서 열면 기본 렌더링 모습을 볼 수 있습니다. 한국어 줄바꿈 확인용 긴 문장: 가나다라마바사아자차카타파하가나다라마바사아자차카타파하.

- 평범한 Markdown
- github.com에서도 읽힘
- WCAG 2.2 AA

[주요 동작](#) [보조](#) [세 번째 링크](#)

> [!NOTE]
> 이 페이지는 [영어 원문](../../components/kitchen-sink/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 알림

> [!NOTE]
> 훑어보더라도 꼭 알아야 할 유용한 정보입니다.

> [!TIP]
> 더 쉽고 낫게 하는 데 도움이 되는 조언입니다.

> [!IMPORTANT]
> 목표를 이루려면 반드시 알아야 할 핵심 정보입니다.

> [!WARNING]
> 문제를 막으려면 바로 확인해야 하는 긴급한 정보입니다.

> [!CAUTION]
> 특정 동작의 위험이나 나쁜 결과를 경고합니다.

> [!NOTE]
> 내용이 많은 알림:
>
> - `inline code`가 들어간 목록 항목
> - [컴포넌트 목록](../) 링크가 있는 두 번째 항목
>
> ```sh
> echo "code inside an alert"
> ```

## 2열 카드

- **짧은 카드** — 한 줄.
- **긴 카드** — 설명이 길어 여러 줄로 넘어가는 카드로, 그리드 전체의 간격, 줄 높이, 정렬을 확인합니다.
- **배지 포함** — 카드에 상태를 표시할 수 있습니다. `status:available`
- **링크 포함** — [설치 안내](../../guides/install/)를 읽어 보세요.

## 3열 카드

- **알림** — GitHub 알림 다섯 종류. `status:available`
- **탭** — 접근성을 갖춘 설치 탭. `status:partial`
- **검색** — 계획된 항목의 예. `status:planned`
- **토큰** — 색상, 모서리 반경, 글꼴. `status:available`
- **Sass** — 컴포넌트마다 파셜 하나. `status:available`
- **Markdown 버전** — 에이전트용 Markdown. `status:available`

## 4열 카드

- **알림** — GitHub 알림 다섯 종류. `status:available`
- **탭** — 접근성을 갖춘 설치 탭. `status:partial`
- **검색** — 계획된 항목의 예. `status:planned`
- **토큰** — 색상, 모서리 반경, 글꼴. `status:available`
- **Sass** — 컴포넌트마다 파셜 하나. `status:available`
- **Markdown 버전** — 에이전트용 Markdown. `status:available`
- **그리드** — 넓은 화면에서 네 열.
- **줄** — 카드 여덟 장이 두 줄을 채웁니다.

## 패널이 두 개인 탭

### macOS

```sh
brew install ruby
gem install jekyll bundler
```

### Linux

```sh
sudo apt install ruby-full
gem install jekyll bundler
```

## 패널이 많은 탭

### Ruby

```ruby
puts "Hello"
```

### JavaScript

```js
console.log("Hello");
```

### Python

```python
print("Hello")
```

### Shell

```sh
echo Hello
```

### 이름이 훨씬 긴 탭

```yaml
greeting: Hello
```

## 상태 배지

인라인 배지: `status:available` `status:partial` `status:planned`

태그 배지: `tag:beta` `tag:experimental`

| 기능 | 상태 |
|---|---|
| 알림 | `status:available` |
| 탭 | `status:partial` |
| 검색 | `status:planned` |

## 아코디언

### 키친싱크는 어디에 쓰나요?

모든 컴포넌트를 한곳에 모아 보여 주므로 화면이 깨진 곳을 쉽게 찾을 수 있습니다.

### JavaScript 없이도 동작하나요?

네. JavaScript가 없으면 모든 답이 질문 아래에 펼쳐진 채로 보입니다.

### 답에 코드를 넣을 수 있나요?

```sh
bundle exec jekyll serve
```

## 목록으로 쓴 단계

1. `_config.yml`에 테마를 추가합니다.
2. 평범한 Markdown으로 `index.md`를 씁니다.
3. `bundle exec jekyll build`를 실행합니다.
4. `modootoday-check`로 결과를 확인합니다.

## 제목으로 쓴 단계

### 설치

`remote_theme`과 플러그인을 추가합니다.

### 작성

front matter가 있는 페이지를 만듭니다.

### 배포

`main`에 푸시하고 GitHub Pages를 켭니다.

## 그림

![왼쪽 Markdown 소스가 오른쪽에서 스타일이 적용된 페이지로 바뀌는 모습](../../../assets/images/sample.svg)

*이미지만 있는 문단 뒤에 강조만 있는 문단이 오면 캡션이 달린 그림이 됩니다.*

## 타임라인

### 설치

알림, 섹션, 카드, 탭, 상태 배지, 검사기.

### 작성

디자인 토큰, `modootoday:` 블록, 내비게이션, 코드 복사.

### 확인

테마 전환, 이동 경로, 목차, 아코디언, 단계, 그림.

### 배포

타임라인, 키보드 키, 클라이언트 검색, post 레이아웃.

## 목록으로 쓴 타임라인

1. 설치: 알림, 섹션, 카드, 탭.
2. 작성: 디자인 토큰, 내비게이션.
3. 확인: 테마 전환, 목차, 단계.

## 키보드 키

`kbd:Ctrl+K`나 `kbd:/`만 눌러도 검색이 열립니다. 복사는 `kbd:Cmd+C`입니다.

## 표

| 키 | 유형 | 기본값 | 설명 |
|---|---|---|---|
| `badges` | boolean | `true` | 상태 코드 스팬을 배지로 바꿈 |
| `color_scheme` | string | `auto` | 운영체제 설정을 따르거나 색 구성을 고정 |
| `components` | list | 모든 핵심 컴포넌트 | 브라우저로 보내는 CSS와 JavaScript를 줄임 |
| `tokens` | map | 테마 기본값 | 주 색상, 모서리 반경, 글꼴 스택 같은 디자인 토큰을 덮어씀 |

| 왼쪽 | 가운데 | 오른쪽 |
|:---|:---:|---:|
| a | b | 1 |
| 긴 셀 | 가운데 정렬 | 1,000 |

## 코드

인라인 `code`, 펜스 코드 블록, 가로로 스크롤되는 긴 줄:

```ruby
# frozen_string_literal: true
Jekyll::Hooks.register :site, :post_write do |site|
  puts "Built #{site.pages.size} pages into #{site.dest} with a deliberately long line to test horizontal scrolling"
end
```

```diff
- theme: minima
+ theme: jekyll-theme-modootoday
```

## 타이포그래피

**굵게**, *기울임*, ~~취소선~~, `code`, [컴포넌트 목록](../) 링크가 있는 문단입니다. 각주도 쓸 수 있습니다.[^1]

### 3단계 제목

#### 4단계 제목

1. 번호 항목
2. 번호 항목
   - 중첩 항목
   - 중첩 항목

- [x] 완료한 작업
- [ ] 남은 작업

> 알림이 아닌 일반 인용문입니다.

---

구분선 다음의 글입니다.

[^1]: 각주입니다.

## 행동 유도

[시작하기](../../guides/install/) [규칙 읽기](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/RULES.md)

## 코드 제목과 diff

`status:available` 펜스 코드 블록 바로 앞에 file과 콜론으로 시작하는 코드 스팬만 있는 줄을 두면 블록의 제목 표시줄이 됩니다. `diff` 블록은 추가된 줄과 삭제된 줄에 색을 입히고 더하기·빼기 기호를 유지합니다.

`file:_config.yml`

```yaml
theme: jekyll-theme-modootoday
```

```diff
- remote_theme: old/theme
+ theme: jekyll-theme-modootoday
```

## 진행률

`status:available` progress와 콜론 뒤에 0부터 100까지의 정수가 오는 코드 스팬은 값을 텍스트로 함께 보여 주는 레이블 있는 진행률 막대가 됩니다.

번역 `progress:60`

## 임베드

`status:available` embed와 콜론, https URL, 선택 제목으로 된 코드 스팬만 있는 문단은 지연 로드되는 16:9 프레임이 되며, 로드되는 동안에도 자리를 유지합니다.

`embed:https://modootoday.github.io/jekyll-theme-modootoday/assets/images/sample.svg 샘플 페이지 그림`

## 로딩과 스켈레톤

`status:available` loading 또는 skeleton과 콜론으로 시작하는 코드 스팬은 스피너, 얇은 상단 막대, 자리 표시자(text, card, image, avatar, row)가 됩니다. 모두 `role="status"`와 스크린 리더용 로딩 레이블이 붙고, 사용자가 동작 줄이기를 켜면 움직이지 않습니다. 스타일은 별도 스타일시트에 있어 이 요소를 쓰는 페이지만 불러옵니다.

`loading:spinner`

`skeleton:avatar`
`skeleton:text`
`skeleton:card`

## 파일 트리

`status:available` `c: filetree` 섹션에서는 중첩 목록이 폴더 트리로 그려집니다. 하위 목록이 있는 항목은 폴더입니다.

- docs
  - _config.yml
  - index.md
  - ko
    - index.md

## 세부 정보

`status:available` `c: details` 섹션에서는 각 `###` 제목이 브라우저 기본 펼침 요소가 됩니다. JavaScript 없이 열고 닫힙니다.

### 무엇이 필요한가요?

브라우저만 있으면 됩니다.

## 자주 묻는 질문

`status:available` `c: faq` 섹션은 세부 정보처럼 동작합니다. FAQPage 구조화 데이터가 필요하면 `schema:` 블록을 추가하세요([구조화 데이터](../../guides/structured-data/) 참고).

### 테마는 무료인가요?

네, MIT 라이선스입니다.

### GitHub Pages에서 동작하나요?

네, github-pages gem으로 동작합니다.

## 매개변수 표

`status:available` `c: params` 섹션에서는 표가 옵션을 이름, 유형, 기본값, 설명으로 나열합니다. `required`만 있는 셀은 필수 배지로 표시됩니다.

| 이름 | 유형 | 기본값 | 설명 |
|---|---|---|---|
| `title` | 문자열 | `required` | 페이지 제목 |
| `cols` | 숫자 | 2 | 카드 열 수 |

## 링크 카드

`status:available` `c: linkcards` 섹션에서는 링크로 시작하는 목록 항목이 카드가 됩니다. 카드 전체가 링크 대상입니다.

- [설치](../../guides/install/) — 사이트에 테마를 추가합니다.
- [설정](../../guides/configuration/) — 모든 설정을 한곳에서 봅니다.

## 인용

`status:available` `c: quote` 섹션에서는 마지막 줄이 줄표(—)로 시작하는 인용문의 그 줄이 출처가 됩니다.

> 문서가 github.com에서도 사이트에서도 잘 읽힙니다.
>
> — 테마 사용자

## 갤러리

`status:available` `c: gallery` 섹션에서는 이미지 목록이 썸네일 격자가 됩니다. 각 썸네일은 JavaScript 없이 원본 크기 보기를 엽니다. 모든 이미지에 대체 텍스트가 필요합니다.

- ![화분과 안락의자가 있는 햇살 드는 방](../../../assets/images/gallery/room.webp)
- ![낮은 해 아래 분홍빛 모래 언덕](../../../assets/images/gallery/dunes.webp)
- ![잔잔한 연못을 둘러싼 열대 잎](../../../assets/images/gallery/leaves.webp)
- ![산속 호수의 나무 선착장](../../../assets/images/news/travel-sm.webp)
- ![초록 언덕 위의 풍력 발전기와 태양광 패널](../../../assets/images/news/energy-sm.webp)
- ![크림, 보라, 코랄 색 견본을 부채꼴로 펼친 모습](../../../assets/images/projects/brand.webp)

## 요금제

`status:available` `c: pricing` 섹션에서는 각 `###` 제목이 가격, 기능 목록, 링크로 이루어진 요금제 카드가 됩니다. `recommended` 매개변수는 한 요금제에 추천 레이블을 붙입니다.

### 무료

**$0**

- 사이트 1개

[시작하기](#)

### 팀

**$12**

- 사이트 10개
- 지원

[팀 선택](#)

## 구독

`status:available` `c: subscribe` 섹션은 텍스트와 `modootoday.subscribe.action`의 주소로 전송하는 이메일 양식을 표시합니다. 이 설정이 없으면 텍스트만 표시합니다.

릴리스가 나오면 이메일을 한 통 받으세요.

## 분할

`status:available` `c: split` 섹션은 48rem 이상에서 텍스트와 그림을 나란히 놓고, 그보다 좁으면 위아래로 쌓습니다. 그림은 `visual:` include입니다. `side: start`는 그림을 시작 쪽으로 옮기고, `ratio: "5:7"`은 그림에 넓은 열을 줍니다. 여기의 `label:`처럼 항목의 다른 키는 include에서 `include.section.label`로 받습니다. 이 그림은 일러스트입니다. `class="mt-illustration"`, `role="img"`, `aria-label`이 있는 `figure`이고, `.mt-illustration-tag` 배지의 글자도 레이블에 들어 있습니다. `decor: decor-demo`는 위쪽 모서리의 점을 `aria-hidden` 장식으로 더합니다.

한쪽에는 텍스트, 다른 쪽에는 그림이 옵니다.

## 목록

`status:available` `_config.yml`에 `modootoday.lists`를 두면 일반 섹션과 페이지에 목록 스타일 두 가지가 적용됩니다. `link_chips: true`는 모든 항목이 링크 하나뿐인 목록을 칩 한 줄로 바꾸고, `titled_items: true`는 굵은 제목과 콜론으로 시작하는 항목에 제목과 구분자를 따로 줍니다. `hero: {checks: true}`는 위처럼 히어로의 첫 목록을 체크 표시 줄로 바꿉니다. 컴포넌트 섹션의 목록은 원래 스타일을 유지합니다.

- [설치](../../guides/install/)
- [설정](../../guides/configuration/)
- [접근성](../../guides/accessibility/)

제목이 있는 항목:

- **칩**: 링크만 있는 목록
- **제목 항목**: 굵은 제목, 콜론, 그다음 텍스트
