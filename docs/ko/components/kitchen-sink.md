---
nav_order: 10
title: 키친싱크
description: 구현된 모든 컴포넌트와 변형을 한 페이지에서 시각 점검합니다.
sections:
  - alerts
  - {c: features, name: cards-2, cols: 2}
  - {c: features, name: cards-3, cols: 3}
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
  - typography
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
---
# 키친싱크

테마가 제공하는 모든 컴포넌트를 모든 변형으로 보여 줍니다. 같은 파일을 github.com에서 열면 폴백 모습을 볼 수 있습니다. 한국어 줄바꿈 확인용 긴문장: 가나다라마바사아자차카타파하가나다라마바사아자차카타파하.

[Primary action](#) [Secondary](#) [Third link](#)

> [!NOTE]
> 이 페이지는 [영어 원문](../../components/kitchen-sink/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## Alerts

> [!NOTE]
> Useful information that users should know, even when skimming.

> [!TIP]
> Helpful advice for doing things better or more easily.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.

> [!NOTE]
> An alert with more content:
>
> - a list item with `inline code`
> - a second item with a link to the [components index](../)
>
> ```sh
> echo "code inside an alert"
> ```

## Cards in two columns

- **Short** — One line.
- **Longer card** — A card with a longer description that wraps over several lines to check spacing, line height and alignment across the grid.
- **With a badge** — Cards can carry status. `status:available`
- **With a link** — Read the [install guide](../../guides/install/).

## Cards in three columns

- **Alerts** — Five GitHub alert types. `status:available`
- **Tabs** — Accessible install tabs. `status:partial`
- **Search** — Example of a planned item. `status:planned`
- **Tokens** — Colors, radius and fonts. `status:available`
- **Sass** — One partial per component. `status:available`
- **Twins** — Markdown for agents. `status:available`

## Tabs with two panels

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

## Tabs with many panels

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

### A tab with a much longer name

```yaml
greeting: Hello
```

## Status badges

Inline badges: `status:available` `status:partial` `status:planned`

Tag badges: `tag:beta` `tag:experimental`

| Feature | Status |
|---|---|
| Alerts | `status:available` |
| Tabs | `status:partial` |
| Search | `status:planned` |

## Accordion

### What is the kitchen sink for?

It shows every component in one place, so visual regressions are easy to spot.

### Does it work without JavaScript?

Yes. Without JavaScript every answer stays visible under its question.

### Can an answer hold code?

```sh
bundle exec jekyll serve
```

## Steps as a list

1. Add the theme to `_config.yml`.
2. Write `index.md` in plain Markdown.
3. Run `bundle exec jekyll build`.
4. Check the result with `modootoday-check`.

## Steps as headings

### Install

Add `remote_theme` and the plugin.

### Write

Create a page with front matter.

### Publish

Push to `main` and turn on GitHub Pages.

## Figure

![A Markdown source on the left becomes a styled page on the right](../../../assets/images/sample.svg)

*An image-only paragraph followed by an emphasis-only paragraph becomes a figure with a caption.*

## Timeline

### Install

Alerts, sections, cards, tabs, status badges and the checker.

### Write

Design tokens, the `modootoday:` block, navigation and code copy.

### Check

Theme toggle, breadcrumb, table of contents, accordion, steps and figures.

### Publish

Timeline, keyboard keys, client search and the post layout.

## Timeline as a list

1. Install: alerts, sections, cards and tabs.
2. Write: design tokens and navigation.
3. Check: theme toggle, table of contents and steps.

## Keyboard keys

Open search with `kbd:Ctrl+K`, or `kbd:/` on its own. Copy with `kbd:Cmd+C`.

## Tables

| Key | Type | Default | Description |
|---|---|---|---|
| `badges` | boolean | `true` | Convert status code spans into badges |
| `color_scheme` | string | `auto` | Follow the operating system or force a scheme |
| `components` | list | all core components | Limit the CSS and JavaScript that are shipped to the browser |
| `tokens` | map | theme defaults | Override design tokens such as primary color, radius and font stacks |

| Left | Center | Right |
|:---|:---:|---:|
| a | b | 1 |
| longer cell | centered | 1,000 |

## Code

Inline `code`, a fenced block and a long line that scrolls:

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

## Typography

Paragraph text with **bold**, *italic*, ~~strikethrough~~, `code` and a link to the [components index](../). Footnotes work too.[^1]

### Heading level 3

#### Heading level 4

1. Ordered item
2. Ordered item
   - nested bullet
   - nested bullet

- [x] task done
- [ ] task open

> A plain quote that is not an alert.

---

Text after a thematic break.

[^1]: A footnote.

## Call to action

[Get started](../../guides/install/) [Read the rules](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/RULES.md)

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

`status:available` loading 또는 skeleton과 콜론으로 시작하는 코드 스팬은 스피너, 얇은 상단 막대, 자리 표시자(text, card, image, avatar, row)가 됩니다. 각각 `role="status"`와 화면 낭독기용 로딩 레이블을 가지며, 사용자가 동작 줄이기를 요청하면 움직임이 멈춥니다. 스타일은 이를 쓰는 페이지만 불러오는 선택 시트에 있습니다.

`loading:spinner`

`skeleton:avatar`
`skeleton:text`
`skeleton:card`

## 파일 트리

`status:available` `c: filetree` 섹션에서는 중첩 목록이 폴더 트리로 그려집니다. 중첩 목록을 가진 항목은 폴더입니다.

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

`status:available` `c: pricing` 섹션에서는 각 `###` 제목이 가격, 기능 목록, 링크를 가진 요금제가 됩니다. `recommended` 매개변수는 한 요금제에 추천 레이블을 붙입니다.

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
