---
lang: ja
permalink: /ja/layouts/blog-news/blog/
source_rev: sha256:4d561d466966
title: ブログのレイアウト
description: "投稿をリスト、グリッド、マガジンで並べ、ページ送りかアーカイブへのリンクを付けるレイアウトです。"
layout: layout-reference
nav_order: 1
---
# ブログのレイアウト

`layout: blog` は本文のあとに、サイトの投稿をカードで並べます。シンプルな `list`、`grid`、最初の投稿を大きく見せる `magazine` から選べます。1 つのカテゴリーやタグだけを表示でき、`jekyll-paginate` を使うと新しい投稿と古い投稿へのリンクが付きます。ライブデモは blog スターターのホームです。このサイトの[ブログ](../../../blog/)もこのレイアウトを使っています。

## Front matter

| キー | 用途 |
|---|---|
| `variant` | `list`（既定）、`grid`、`magazine` |
| `featured` | `true` で最初のカードを大きく表示します |
| `category`, `tag` | このカテゴリーやタグの投稿だけを表示します |
| `archive_url` | 最後のカードのあとにある古い投稿へのリンクの行き先（`/archive/` など） |
| `posts_lang` | `all` ですべての言語の投稿を混ぜます。既定ではページの言語の投稿だけを表示します |

```yaml
---
title: Blog
layout: blog
variant: grid
---
```

ページ送りを使わないときは、新しい投稿を `modootoday.blog.per_page` 件（既定は 10、`_config.yml` で設定）表示します。

投稿、著者、フィードは[ブログとニュース](../)で説明しています。
