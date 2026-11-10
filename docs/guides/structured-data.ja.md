---
lang: ja
permalink: /ja/guides/structured-data/
source_rev: sha256:5d39c9e2bc0f
nav_order: 80
title: 構造化データ
description: テーマが全ページに出力する schema.org JSON-LD グラフに何が入るかと、発行者、著者、ページの種類などの値を設定する方法を説明します。
---
# 構造化データ

> [!NOTE]
> このページは[英語の原文](../../../guides/structured-data/)の翻訳です。内容が異なる場合は英語版が優先されます。

`_config.yml` に `url:` があると、全ページに schema.org の `@graph` を収めた `<script type="application/ld+json">` ブロックが 1 つ入ります。検索エンジンや AI ツールはこれでページの内容を把握します。schema.org の URL は絶対 URL である必要があるため、`url:` がなければ何も出力しません。

## グラフの構成

| ノード | `@id` | 内容 |
|---|---|---|
| `WebSite` | `<url>/#website` | サイト名、URL、言語、発行者。`schema.search_url` があれば `SearchAction` |
| `Organization` または `Person` | `<url>/#publisher` | `schema.publisher`(名前、URL、ロゴ、`same_as`) |
| ページの型(`WebPage` とその下位型) | `<page>#webpage` | 名前、URL、説明、`inLanguage`、画像、パンくず |
| 主エンティティ | `<page>#main` | ページが扱う記事、求人、イベントなど |
| `BreadcrumbList` | `<page>#breadcrumb` | 画面のパンくずと同じ内容 |

日付はサイトのタイムゾーン付き ISO 8601 で、テキストはエスケープされるため厳格な [CSP](../../recipes/csp/) でも安全です。

## レイアウトごとの型

| レイアウト | 型 |
|---|---|
| `post` | `BlogPosting`(`layout: news-article` か `kind: news` なら `NewsArticle`) |
| `doc` | `TechArticle` |
| `archive`、`blog`、`news` | `CollectionPage` |
| `author`、`profile`、`resume` | `ProfilePage` |
| `contact` | `ContactPage` |
| `search` | `SearchResultsPage` |
| `faq` | `FAQPage` |
| `c: faq` セクションがあり `schema.faq: auto` のすべてのページ | `FAQPage` |
| `glossary` | `DefinedTermSet`。`schema: {type: DefinedTerm}` のページは `DefinedTerm` 1 つ |
| `course` | `Course`。`schema.type` か `schema.layouts` で `LearningResource` |
| その他 | `WebPage` |

著者は front matter の `author`/`authors`(`_data/authors.yml` から引く id、名前、`{name, url}` のマップ)から取り、なければ `modootoday.schema.author`、次にサイトの `author:` から取ります。署名と Atom フィードも同じ人を表示します。

## 設定

```yaml
modootoday:
  schema:
    publisher:
      type: Organization        # または Person
      name: Example Inc.
      url: https://example.com/
      logo: /assets/logo.png
      same_as: [https://github.com/example]
    search_url: /search/?q={search_term_string}   # 任意: SearchAction
    faq: auto                                    # c: faq セクションから FAQPage を作る(既定は無効)
    layouts:
      landing: SoftwareApplication               # レイアウトの型を変更
```

`modootoday.schema: false`(または `schema: {enabled: false}`)で無効にし、1 ページだけなら front matter に `schema: false` を書きます。`seo: false` でも無効になります。

`seo: false` と `jekyll-seo-tag` を併用すると、プラグインが `<!-- Begin Jekyll SEO tag` と `<!-- End Jekyll SEO tag -->` のコメントの間に独自の JSON-LD を書きます。`modootoday-check` はこのブロックが正しい JSON かどうかだけを検査し、エラーではなく警告を出します。キットが書くマークアップではなく、このブロックの `WebPage` には `headline` があって `name` がないためです。schema.org はどのプロパティも必須としておらず、Google も `WebPage` に必須プロパティを定めていません。必須プロパティの一覧は、キットが書くマークアップに適用するキット独自の規則です。ページ全体を検査させるには、キットのタグに移ります（[移行とアップグレード](../upgrade/)）。

## ページごとのエンティティ

front matter に `schema.type` と schema.org のプロパティを書きます。`type:` キーは `@type` になります。`name`、`description`、`url`、`image` はページから補われます。

```yaml
schema:
  type: JobPosting
  datePosted: 2026-10-01
  hiringOrganization: {type: Organization, name: Example Inc.}
  jobLocation: {type: Place, address: {type: PostalAddress, addressCountry: KR}}
```

`SoftwareApplication`(`offers: {type: Offer, price: 0, priceCurrency: USD}`)、`Event`、`Course`、`PodcastEpisode`、`DefinedTermSet`、`ItemList`、`FAQPage`(`mainEntity:` に `Question` のリスト)も使えます。最上位の `/` で始まる URL は絶対 URL に変換されますが、入れ子の値の中の URL は最初から絶対 URL で書いてください。

## FAQ、用語、学習リソース

**ページから作る FAQPage。** 全ページに適用するには `modootoday.schema` の下に `faq: auto` を、1 ページだけなら front matter に `schema: {faq: auto}` を書きます。すると `c: faq` セクションのあるページが `FAQPage` になります。そのセクションの `###` の質問がそれぞれ `Question` になり、その下の文章が `Answer` になります。画面に見える文章が唯一の元なので、構造化データは読者が見る内容と常に一致します。回答からコードブロックは除かれ、`c: details` セクションは読みません。front matter の `schema.type` と `schema.mainEntity` があればそちらが優先され、1 ページだけ無効にするには `schema: {faq: false}` を書きます。[コンポーネント](../../components/)のページがこの設定を使っています。

**用語ごとに 1 ページ。** `schema: {type: DefinedTerm}` にすると、ページはタイトルを名前とする `DefinedTerm` になります。`term_set:` に用語集ページのパスを書くとそのページの `DefinedTermSet` につながり(絶対 URL はそのまま出力)、`term_code:` は `termCode` を加えます。用語集の `terms:` の項目に `url:` があると、その `DefinedTerm` に用語ページの URL が付きます。

```yaml
title: Token
description: A named value for one design decision.
schema: {type: DefinedTerm}
term_set: /glossary/
```

**LearningResource。** 1 ページなら `schema: {type: LearningResource}`、レイアウト全体なら `schema.layouts: {doc: LearningResource}` で指定します。course レイアウトと同じ front matter を読みます。`level`(`educationalLevel`)、`minutes`(`timeRequired`)、`teaches`、`resource_type`(`learningResourceType`)で、`provider` はサイトの発行者です。

## 検査

`modootoday-check` はビルド済みサイトの全ブロックをオフラインで検査します。ページあたり 1 ブロック、正しい JSON、schema.org にある型とプロパティ、必須プロパティ(Google 基準)、重複のない `@id`、絶対 URL、ISO 8601 の日付、`og:url`・`og:title`・`og:image`・`<html lang>` との一致を確認します。質問のない `FAQPage`、回答が空の質問、`term_set` が `DefinedTermSet` のあるビルド済みページではない `DefinedTerm` はエラーで、`auto` か `false` 以外の `modootoday.schema.faq` もエラーです。推奨プロパティの欠落も見るには `--schema-recommended` を付けます。

`offers`、`organizer`、`acceptedAnswer` のようにプロパティの下に 1 つだけあるオブジェクトも、最上位のノードと同じくその `@type` の規則で検査します。ここでの問題(必須プロパティの欠落、存在しない型やプロパティ、相対 URL、ISO 8601 ではない日付)を "(a warning in a nested object, an error in the next major version)" で終わる警告として報告し、次のメジャーバージョンからはエラーになります。`@type` のない入れ子のオブジェクトには `@type` を求めず、回答が空の質問は引き続きエラーです。たとえばイベントの `offers` に `url` だけがあり `price` と `priceCurrency` がなければ警告になります。`event` レイアウトでは `tickets: {url, price, currency}` が両方を書き、価格をページにも表示します([イベントの例](../../layouts/detail/#イベント)を参照)。ほかでは front matter に `schema: {offers: {type: Offer, price: 0, priceCurrency: KRW, url: ...}}` で販売情報を書き、価格はページにも表示して、読者に見えない内容をマークアップに書かないようにします。
