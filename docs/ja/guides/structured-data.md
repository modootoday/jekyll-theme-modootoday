---
nav_order: 80
title: 構造化データ
description: テーマが全ページに出力する schema.org JSON-LD グラフと、その設定方法。
---
# 構造化データ

> [!NOTE]
> このページは[英語の原文](../../structured-data/)の翻訳です。内容が異なる場合は英語版が優先されます。

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
| その他 | `WebPage` |

著者は front matter の `author`/`authors` を `_data/authors.yml` から引きます。

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
    layouts:
      landing: SoftwareApplication               # レイアウトの型を変更
```

`modootoday.schema: false`(または `schema: {enabled: false}`)で無効にし、1 ページだけなら front matter に `schema: false` を書きます。`seo: false` でも無効になります。

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

## 検査

`modootoday-check` はビルド済みサイトの全ブロックをオフラインで検査します。ページあたり 1 ブロック、正しい JSON、schema.org にある型とプロパティ、必須プロパティ(Google 基準)、重複のない `@id`、絶対 URL、ISO 8601 の日付、`og:url`・`og:title`・`og:image`・`<html lang>` との一致を確認します。推奨プロパティの欠落も見るには `--schema-recommended` を付けます。
