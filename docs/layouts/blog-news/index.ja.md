---
lang: ja
permalink: /ja/layouts/blog-news/
source_rev: sha256:7be356b2032b
nav_order: 50
title: ブログとニュース
description: ブログ一覧、ニュースのトップページ、記事の署名、著者ページ、言語ごとの Atom フィードを作るレイアウトと、それぞれの front matter を説明します。
---
# ブログとニュース

5 つのレイアウトで、テーマをブログやニュースサイトとして使えます。すべて Liquid だけで動くため、標準の GitHub Pages でも Jekyll 4 でもビルドできます。`modootoday-blog.css` と `share.js` は、これらのレイアウトのページでだけ読み込みます。ドキュメントページではどちらも読み込みません。

| レイアウト | 用途 |
| --- | --- |
| `blog` | 記事一覧とページ送り。`list`、`grid`、`magazine` から選べます |
| `post` | 記事 1 件。署名、読了時間、カバー、シリーズ、前後の記事、関連記事が付きます |
| `news` | トップページ。トップ記事、サブ記事、最新一覧、カテゴリーごとのセクション |
| `news-article` | リード文、速報・ライブバッジ、訂正、出典が付く記事 |
| `author` | 著者の紹介と記事 |
| `feed` | 1 言語分の Atom フィード |

## デモ

以下のデモは、ドキュメントの外でレイアウトをひとつ使って作った実際のページです。ここで開くか、新しいウィンドウで開いてください。blog と post のデモページはプレビューを表示し、blog スターターのライブデモにリンクします。デモ内でサンプルの外に出てしまうリンクは `#` にしてあります。

| デモ | レイアウト | 新しいウィンドウ |
| --- | --- | --- |
| [ブログ一覧](blog/) | `blog` | [ライブデモ](https://modootoday.github.io/jekyll-theme-modootoday-blog-starter/ "new-window") |
| [ブログ記事](post/) | `post` | [ライブデモ](https://modootoday.github.io/jekyll-theme-modootoday-blog-starter/notes/2026/10/20/hello-blog/ "new-window") |
| [ニューストップ](news/) | `news` | [新しいウィンドウで開く](news/ "new-window") |
| [ニュース記事](article/) | `news-article` | [新しいウィンドウで開く](article/ "new-window") |
| [年別アーカイブ](archive/) | `archive` | [新しいウィンドウで開く](archive/ "new-window") |

日本語の記事の Atom フィードは [feed.xml](../../../ja/feed.xml) にあります。[英語](../../../feed.xml)と[韓国語](../../../ko/feed.xml)のフィードも別にあります。

## ブログ一覧

```markdown
---
title: ブログ
layout: blog
variant: grid      # list | grid | magazine
category: guides   # 任意の絞り込み。tag: も使えます
---
```

[サンプルのブログ](../../blog/)で、このサイトの記事を表示した例を見られます。


## 記事

```markdown
---
title: 1.0 リリース
author: kim            # または authors: [kim, lee]。_data/authors.yml の id、名前、{name, url, picture}
image: /assets/cover.png
series: launch         # 同じ series の記事に「全 3 回中 2 回目」とリンクが付きます
last_modified_at: 2026-10-30
---
```

著者情報は `_data/authors.yml` に書きます。このファイルにない id は書いたとおりに表示されるので、`author: Kim Lee` のように名前だけでも使えます。`author:` にはカンマ区切りの一覧や、`name`、`url`、`picture` のあるマップ(jekyll-seo-tag の形)も書けます。どちらもない記事は `modootoday.schema.author`、次にサイトの `author:`(名前、または minima の `{name, email}` のようなマップ)を使います。署名、Atom フィード、JSON-LD は同じ一覧を読みます。各記事は `BlogPosting` JSON-LD と `article:*` Open Graph タグを出力します。

## ニュース

`layout: news` に `news_sections: [releases, guides]` を書くとトップページになります。記事は `layout: news-article` を使い、`deck:`、`breaking: true`、`live: true`、`correction:`、`sources:`、`credits:` を指定できます。[サンプルのトップページ](../../news/)をご覧ください。

## 著者とフィード

著者ページは `layout: author` と `author: kim` で作ります。

フィードは `layout: feed` のページです。テーマが Liquid で書くので、プラグインは要らず GitHub Pages でそのままビルドできます。サイトのルートに front matter だけの `feed.xml` を置き、言語フォルダーごとに(`/ko/feed.xml`)一つずつ置くと、言語別の Atom フィードができます。全文を載せるには `feed_content: full` を指定します。

```yaml
---
layout: feed
---
```

`modootoday.feed: true` はすべてのページの head にそのフィード(その言語のフィードがあればそちら)をリンクするだけで、フィード自体は書きません。`jekyll-feed` を一緒に入れないでください。このプラグインも `/feed.xml` を書きます。

変更履歴も、リリースごとに一つの項目があるフィードにできます。二つのファイルと `feed_source:`、`releases_feed:` は、ドキュメント拡張の[変更履歴](../docs-extra/#変更履歴)にあります。

`modootoday.feed` が `true` なら、`category` も `tag` もないブログ一覧は、その言語のフィードを head と紹介文の下の購読リンクでリンクします。ブログ、著者、アーカイブのページと、変更履歴などのドキュメント拡張のページは `feed:` で自分のフィードを決めます。値は `layout: feed` のページのサイト内パスで、リンクしないなら `false` です。これらのレイアウトはフィードを購読リンクで示し、ダウンロードのページなどほかのページでは `feed:` は head のリンクだけを加えます。一人の著者の記事だけにするには、`layout: feed` と `author: kim` を書いた `/authors/kim.xml` のようなページを作り、著者ページに `feed: /authors/kim.xml` を書きます。ビルドにない `feed:` は `modootoday-check` が報告します。

## 設定

```yaml
modootoday:
  blog:
    variant: list
    per_page: 10
    excerpt: true
    reading_time: true
    related: 3          # 0 で関連記事を非表示
    share: true
```

| front matter | レイアウト | 意味 |
| --- | --- | --- |
| `variant` | blog, author | `list`、`grid`、`magazine` |
| `category`, `tag` | blog, news, feed | 記事を絞り込みます |
| `feed` | blog, author, archive, changelog とほかのドキュメント拡張。download と任意のページは head のリンクだけ | head にリンクし、先に挙げたレイアウトでは購読リンクでも示すこのページの Atom フィード。`/authors/kim.xml` のようなサイト内パス、または `false` |
| `news_sections`, `secondary`, `latest` | news | カテゴリーのセクションと記事数 |
| `posts_lang` | blog, news, author | `all` ですべての言語の記事を並べます |
| `featured` | blog, post | ブログのページでは `true` で最初のカードを大きくし、記事ではその記事を先頭のカードに固定します |
| `archive_url` | blog | 最後のカードの後にある過去の記事へのリンク先。例: `/archive/` |
| `hidden`, `list: false` | post | 記事を一覧から外します |
| `author`, `authors` | post, author, feed | `_data/authors.yml` の id、名前、`{name, url, picture}`。既定はサイトの `author` |
| `series` | post | 記事を番号付きの連載にまとめます |
| `image`, `image_alt`, `image_caption` | post | カバー（パスまたは `{path, alt, width, height}`）、代替テキスト、キャプション |
| `categories`, `tags` | post | 記事の下に表示し、関連記事を選ぶのに使います |
| `last_modified_at` | post | 最後に更新した日付 |
| `deck` | post, news-article | タイトルの下の 1 文 |
| `breaking`, `live`, `correction`, `sources`, `credits` | news-article | ニュースの詳細 |
| `feed_lang`, `limit`, `feed_content` | feed | フィードの範囲 |
| `feed_source`, `home` | feed | 変更履歴をフィードに:`data` か `layout: changelog` のページの URL と、項目のリンク先 |
| `releases_feed` | changelog, download, 任意のページ | `true`(`site.github` から)か URL。GitHub の `releases.atom` を head にリンクし、changelog とほかのドキュメント拡張ではタイトルの下にもリンク |
