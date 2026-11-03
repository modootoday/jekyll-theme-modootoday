---
lang: ko
permalink: /ko/guides/structured-data/
source_rev: sha256:424690582723
nav_order: 80
title: 구조화 데이터
description: 테마가 모든 페이지에 넣는 schema.org JSON-LD 그래프와 설정 방법.
---
# 구조화 데이터

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/structured-data/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

`_config.yml`에 `url:`이 있으면 모든 페이지에 schema.org `@graph`를 담은 `<script type="application/ld+json">` 블록이 하나 들어갑니다. 검색 엔진과 AI 도구는 이것으로 페이지가 무엇인지 파악합니다. schema.org URL은 절대 주소여야 하므로 `url:`이 없으면 아무것도 출력하지 않습니다.

## 그래프 구성

| 노드 | `@id` | 내용 |
|---|---|---|
| `WebSite` | `<url>/#website` | 사이트 이름, URL, 언어, 발행자. `schema.search_url`이 있으면 `SearchAction` |
| `Organization` 또는 `Person` | `<url>/#publisher` | `schema.publisher`(이름, URL, 로고, `same_as`) |
| 페이지 유형(`WebPage`와 하위 유형) | `<page>#webpage` | 이름, URL, 설명, `inLanguage`, 이미지, 이동 경로 |
| 주 엔터티 | `<page>#main` | 페이지가 다루는 글, 채용 공고, 행사 등 |
| `BreadcrumbList` | `<page>#breadcrumb` | 화면의 이동 경로와 같은 내용 |

날짜는 사이트 시간대를 붙인 ISO 8601이고, 텍스트는 이스케이프되어 엄격한 [CSP](../../recipes/csp/)에서도 안전합니다.

## 레이아웃별 유형

| 레이아웃 | 유형 |
|---|---|
| `post` | `BlogPosting`(`layout: news-article`이나 `kind: news`이면 `NewsArticle`) |
| `doc` | `TechArticle` |
| `archive`, `blog`, `news` | `CollectionPage` |
| `author`, `profile`, `resume` | `ProfilePage` |
| `contact` | `ContactPage` |
| `search` | `SearchResultsPage` |
| `faq` | `FAQPage` |
| `c: faq` 섹션이 있고 `schema.faq: auto`인 모든 페이지 | `FAQPage` |
| `glossary` | `DefinedTermSet`. `schema: {type: DefinedTerm}`인 페이지는 `DefinedTerm` 하나 |
| `course` | `Course`. `schema.type`이나 `schema.layouts`로 `LearningResource` |
| 그 밖 | `WebPage` |

저자는 front matter의 `author`/`authors`를 `_data/authors.yml`에서 찾아 넣습니다.

## 설정

```yaml
modootoday:
  schema:
    publisher:
      type: Organization        # 또는 Person
      name: Example Inc.
      url: https://example.com/
      logo: /assets/logo.png
      same_as: [https://github.com/example]
    search_url: /search/?q={search_term_string}   # 선택: SearchAction
    faq: auto                                    # c: faq 섹션으로 FAQPage 만들기(기본은 끔)
    layouts:
      landing: SoftwareApplication               # 레이아웃의 유형 바꾸기
```

`modootoday.schema: false`(또는 `schema: {enabled: false}`)로 끄고, 한 페이지만 끄려면 front matter에 `schema: false`를 씁니다. `seo: false`도 함께 끕니다.

`seo: false`와 `jekyll-seo-tag`를 함께 쓰면 플러그인이 `<!-- Begin Jekyll SEO tag`와 `<!-- End Jekyll SEO tag -->` 주석 사이에 자체 JSON-LD를 씁니다. `modootoday-check`는 이 블록이 올바른 JSON인지만 검사하고 오류 대신 경고를 냅니다. 킷이 쓰는 마크업이 아니고, 이 블록의 `WebPage`에는 `headline`만 있고 `name`이 없기 때문입니다. schema.org는 어떤 속성도 필수로 정하지 않고, Google도 `WebPage`의 필수 속성을 두지 않습니다. 필수 속성 목록은 킷이 쓰는 마크업에 적용하는 킷 자체 규칙입니다. 페이지 전체를 검사하게 하려면 킷의 태그로 옮깁니다([이전과 업그레이드](../upgrade/)).

## 페이지별 엔터티

front matter에 `schema.type`과 schema.org 속성을 적습니다. `type:` 키는 `@type`이 됩니다. `name`, `description`, `url`, `image`는 페이지에서 채웁니다.

```yaml
schema:
  type: JobPosting
  datePosted: 2026-10-01
  hiringOrganization: {type: Organization, name: Example Inc.}
  jobLocation: {type: Place, address: {type: PostalAddress, addressCountry: KR}}
```

`SoftwareApplication`(`offers: {type: Offer, price: 0, priceCurrency: USD}`), `Event`, `Course`, `PodcastEpisode`, `DefinedTermSet`, `ItemList`, `FAQPage`(`mainEntity:`에 `Question` 목록)도 쓸 수 있습니다. 최상위의 `/`로 시작하는 URL은 절대 주소로 바뀌지만, 중첩된 값 안의 URL은 처음부터 절대 주소로 적어야 합니다.

## FAQ, 용어, 학습 자료

**페이지에서 만드는 FAQPage.** 모든 페이지에 적용하려면 `modootoday.schema` 아래에 `faq: auto`를, 한 페이지에만 적용하려면 front matter에 `schema: {faq: auto}`를 씁니다. 그러면 `c: faq` 섹션이 있는 페이지가 `FAQPage`가 됩니다. 그 섹션의 `###` 질문마다 `Question`이 되고, 그 아래 글이 `Answer`가 됩니다. 화면에 보이는 글이 유일한 원천이므로 구조화 데이터가 독자가 보는 내용과 늘 같습니다. 답에서 코드 블록은 빠지고, `c: details` 섹션은 읽지 않습니다. front matter의 `schema.type`과 `schema.mainEntity`가 있으면 그것이 우선하고, 한 페이지만 끄려면 `schema: {faq: false}`를 씁니다. [컴포넌트](../../components/) 페이지가 이 설정을 씁니다.

**용어마다 한 페이지.** `schema: {type: DefinedTerm}`이면 페이지가 제목을 이름으로 하는 `DefinedTerm`이 됩니다. `term_set:`에 용어집 페이지 경로를 적으면 그 페이지의 `DefinedTermSet`에 연결되고(절대 URL은 그대로 출력), `term_code:`는 `termCode`를 더합니다. 용어집의 `terms:` 항목에 `url:`이 있으면 그 `DefinedTerm`에 용어 페이지 URL이 붙습니다.

```yaml
title: Token
description: A named value for one design decision.
schema: {type: DefinedTerm}
term_set: /glossary/
```

**LearningResource.** 한 페이지는 `schema: {type: LearningResource}`로, 레이아웃 전체는 `schema.layouts: {doc: LearningResource}`로 지정합니다. course 레이아웃과 같은 front matter를 읽습니다. `level`(`educationalLevel`), `minutes`(`timeRequired`), `teaches`, `resource_type`(`learningResourceType`)이고, `provider`는 사이트 발행자입니다.

## 검사

`modootoday-check`는 빌드된 사이트의 모든 블록을 오프라인으로 검사합니다. 페이지당 블록 하나, 올바른 JSON, schema.org에 있는 유형과 속성, 필수 속성(Google 기준), 겹치지 않는 `@id`, 절대 URL, ISO 8601 날짜, `og:url`·`og:title`·`og:image`·`<html lang>`과의 일치를 봅니다. 질문이 없는 `FAQPage`, 답이 빈 질문, `term_set`이 `DefinedTermSet`이 있는 빌드된 페이지가 아닌 `DefinedTerm`은 오류이고, `auto`나 `false`가 아닌 `modootoday.schema.faq`도 오류입니다. 권장 속성 누락까지 보려면 `--schema-recommended`를 붙입니다.
