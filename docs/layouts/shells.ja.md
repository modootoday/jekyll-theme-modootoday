---
lang: ja
permalink: /ja/layouts/shells/
source_rev: sha256:40b7346b1355
title: ページシェル
description: ページの種類ごとのシェルと、レイアウト単位で読み込む任意のスタイルシートです。
nav_order: 10
---
# ページシェル

ページの front matter で `layout:` を指定します。以下のページシェルは、使うページでのみ追加のスタイルシート `modootoday-pages.css` を読み込むため、ほかのページの容量は変わりません。JavaScript は追加しません。

| レイアウト | 用途 | デモ |
|---|---|---|
| `minimal` | 単独のお知らせ、サインイン案内、リンク集。ヘッダー、ページ情報、ページ送りはありません。 | [ミニマル](../demo/minimal/) |
| `wide` | カードグリッド、幅の広い表、ギャラリー。ヘッダーとフッターはあり、読みやすさのための幅制限はありません。 | [ワイド](../demo/wide/) |
| `home` | ランディングページ。front matter のヒーローの後に本文が続き、ヒーローがないときは最新の記事一覧が続きます。ヒーローのタイトルも本文の `# ` 見出しもなければ、ページのタイトル（なければサイト名）が `h1` になります。WebSite の構造化データを追加します。 | [ホーム](https://modootoday.github.io/jekyll-theme-modootoday-landing-starter/ "new-window") |
| `page` | Jekyll、minima、`jekyll new` が通常のページに使う名前です。名前が違うだけの `doc` レイアウトです。ほかの `doc` ページと同じく、本文に `# ` の見出しがなければ minima と同じように `title:` を `h1` として表示します。 | なし |
| `error` | タイトルと説明が翻訳された 404、410、500 ページ。 | [エラー](../demo/error/) |
| `redirect` | 移動したページ。スクリプトを使わずに移動するため、厳しい CSP でも動きます。 | [リダイレクト](../demo/redirect/) |
| `search` | JavaScript なしでも使えるフォームを備えた検索ページ。 | [検索](../demo/search/) |

プロジェクト、メンバー、求人、イベント、スポンサー、連携のカード一覧は[ディレクトリレイアウト](../directory/)にあります。

## ホーム

```yaml
---
layout: home
hero:
  title: Markdown でサイトを作る
  text: サイトを紹介する一文。
  actions:
    - {label: はじめる, url: /ja/docs/start/}
    - {label: GitHub, url: "https://github.com/modootoday/jekyll-theme-modootoday"}
---
```

最初のアクションが主ボタンになります。`hero.title` がない場合は本文だけを表示します。`home` は本文を書いたとおりに表示し、`sections:` は読まないため、カード、タブ、ボタンのセクションは適用されません。こうしたセクションを使うホームページには、このサイトのホームと同じく `layout: doc` に `hero:` と `sections:` を組み合わせます。 任意の `hero.image`(パス、または `{path, alt, width, height, srcset}`)を指定すると、アクションの下に横長の画像を表示します。装飾目的なら `alt` は空にします。ヒーロー用ビジュアル `showcase` も同じ `hero.image` キーを読み込みます([カスタマイズ](../../guides/customize/)を参照)。

`hero:` と `sections:` のないホームページは、サイトに記事があれば minima と同じく本文の下に最新の記事一覧を表示します。そのため `jekyll new` が作る `index.md` も一覧を保ちます。`posts: true` はどのホームページにも一覧を加え、`posts: false` は一覧を外します。`list_title:` は見出しを置き換え、`show_excerpts:`(ページ、次に `_config.yml`)は抜粋の表示と非表示を決めます。指定がなければ抜粋は `modootoday.blog.excerpt` に従います。`index.html` で jekyll-paginate を使うと一覧もページに分かれ、使わない場合は `modootoday.blog.per_page` 件を表示してアーカイブへリンクします。

## エラー

```yaml
---
layout: error
status: 404
permalink: /404.html
sitemap: false
---
```

`status` は `404`(既定)、`410`、`500` のいずれかです。エラーページには Markdown 版がありません。プラグインと `modootoday-stubs` はエラーページを飛ばし、`modootoday-check --twins` も求めません。タイトルと説明はテーマ内蔵の 23 言語のカタログから取得します。タイトルを変えるには `heading:` を指定します。ページの最後には常にホームへのボタンがあります。クイックリンクを追加するには、リンクを空白で区切って 1 つの段落に書きます。チップの行として表示されます。

```markdown
[ドキュメント](/docs/) [検索](/search/) [English](/)
```

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

フォームは検索範囲を `url:` のホストに限定します。`url:` のないサイト（`jekyll new` は `url: ""` を書きます）には限定するホストがないため、ウェブ全体を検索しないようにレイアウトはフォームを出しません。フォームを使うには `url:` にサイトのアドレスを書いてください。本文に `# ` の見出しがなければページの `title:` が見出しになり、フォームはラベルで名前の付いた検索ランドマークなので、ヘッダーの検索ボックスと区別されます。
