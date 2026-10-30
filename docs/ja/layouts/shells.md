---
title: ページシェル
description: ページの種類ごとのシェルと、レイアウト単位で読み込む任意のスタイルシートです。
nav_order: 10
---
# ページシェル

ページの front matter で `layout:` を指定します。以下のページシェルは、使うページでのみ追加のスタイルシート `modootoday-pages.css` を読み込むため、ほかのページの容量は変わりません。JavaScript は追加しません。

| レイアウト | 用途 | デモ |
|---|---|---|
| `minimal` | 単独のお知らせ、サインイン案内、リンク集。ヘッダー、ページ情報、ページ送りはありません。 | [ミニマル](/jekyll-theme-modootoday/ja/layouts/demo/minimal/) |
| `wide` | カードグリッド、幅の広い表、ギャラリー。ヘッダーとフッターはあり、読みやすさのための幅制限はありません。 | [ワイド](/jekyll-theme-modootoday/ja/layouts/demo/wide/) |
| `home` | ランディングページ。front matter のヒーローの後に本文が続き、WebSite の構造化データを追加します。 | [ホーム](/jekyll-theme-modootoday/ja/layouts/demo/home/) |
| `error` | タイトルと説明が翻訳された 404、410、500 ページ。 | [エラー](/jekyll-theme-modootoday/ja/layouts/demo/error/) |
| `redirect` | 移動したページ。スクリプトを使わずに移動するため、厳しい CSP でも動きます。 | [リダイレクト](/jekyll-theme-modootoday/ja/layouts/demo/redirect/) |
| `search` | JavaScript なしでも使えるフォームを備えた検索ページ。 | [検索](/jekyll-theme-modootoday/ja/layouts/demo/search/) |

プロジェクト、メンバー、求人、イベント、スポンサー、連携のカード一覧は[ディレクトリレイアウト](/jekyll-theme-modootoday/ja/layouts/directory/)にあります。

## ホーム

```yaml
---
layout: home
hero:
  title: Markdown でサイトを作る
  text: サイトを紹介する一文。
  actions:
    - {label: はじめる, url: /ja/install/}
    - {label: GitHub, url: "https://github.com/modootoday/jekyll-theme-modootoday"}
---
```

最初のアクションが主ボタンになります。`hero.title` がない場合は本文だけを表示します。`home` は本文を書いたとおりに表示し、`sections:` は読まないため、カード、タブ、ボタンのセクションは適用されません。こうしたセクションを使うホームページには、このサイトのホームと同じく `layout: doc` に `hero:` と `sections:` を組み合わせます。 任意の `hero.image`(パス、または `{path, alt, width, height, srcset}`)を指定すると、アクションの下に横長の画像を表示します。装飾目的なら `alt` は空にします。ヒーロー用ビジュアル `showcase` も同じ `hero.image` キーを読み込みます([カスタマイズ](../../guides/customize/)を参照)。

## エラー

```yaml
---
layout: error
status: 404
permalink: /404.html
sitemap: false
---
```

`status` は `404`(既定)、`410`、`500` のいずれかです。タイトルと説明はテーマ内蔵の 23 言語のカタログから取得します。タイトルを変えるには `heading:` を指定し、本文を書くとリンクを追加できます。

## リダイレクト

```yaml
---
layout: redirect
permalink: /old-page/
redirect_to: /new-page/
---
```

`redirect_to` にはサイト内のパスか完全な URL を指定します。このページは `noindex` になり、検索エンジンに新しいアドレスを伝えます。

## 検索

ヘッダーの検索ボックスですぐに結果が表示されます。`search` レイアウトは本文の下に、JavaScript がオフのときに外部の検索エンジンでこのサイトを検索するフォームを追加します。`_config.yml` で変更できます。

```yaml
modootoday:
  search:
    fallback: {url: "https://duckduckgo.com/", param: q}   # フォームを隠すには false
```
