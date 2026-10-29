---
title: ブログとニュース
description: ブログ一覧、ニュースのトップページ、署名、著者ページ、Atom フィードを作ります。
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

## ブログ一覧

```markdown
---
title: ブログ
layout: blog
variant: grid      # list | grid | magazine
category: guides   # 任意の絞り込み。tag: も使えます
---
```

[サンプルのブログ](../blog/)で、このサイトの記事を表示した例を見られます。


## 記事

```markdown
---
title: 1.0 リリース
author: kim            # または authors: [kim, lee]。_data/authors.yml の id
image: /assets/cover.png
series: launch         # 同じ series の記事に「全 3 回中 2 回目」とリンクが付きます
last_modified_at: 2026-10-30
---
```

著者情報は `_data/authors.yml` に書きます。各記事は `BlogPosting` JSON-LD と `article:*` Open Graph タグを出力します。

## ニュース

`layout: news` に `news_sections: [releases, guides]` を書くとトップページになります。記事は `layout: news-article` を使い、`deck:`、`breaking: true`、`live: true`、`correction:`、`sources:`、`credits:` を指定できます。[サンプルのトップページ](../news/)をご覧ください。

## 著者とフィード

著者ページは `layout: author` と `author: kim` で作ります。言語フォルダーごとに `layout: feed` の `feed.xml` を置くと言語別の Atom フィードができ、head から自動でリンクされます。

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

フロントマターの一覧は[英語のガイド](../../blog-news/#settings)の表をご覧ください。
