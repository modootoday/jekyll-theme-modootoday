---
lang: ja
permalink: /ja/layouts/blog-news/post/
source_rev: sha256:0c9a316a44ca
title: 投稿のレイアウト
description: "著者、読了時間、カバー、シリーズ、タグ、共有リンク、関連する投稿を備えた 1 本の投稿のレイアウトです。"
layout: layout-reference
nav_order: 2
---
# 投稿のレイアウト

`layout: post` は `_posts` のファイルに既定で付くレイアウトです。本文の上にタイトル、デック、著者と日付と読了時間のバイライン、カバー画像を表示し、本文の下にシリーズ、タグとカテゴリー、共有リンク、前後の投稿、関連する投稿を表示します。ページには `BlogPosting` の構造化データと `article:*` の Open Graph タグが入ります。ライブデモは blog スターターの投稿です。

## Front matter

| キー | 用途 |
|---|---|
| `author` または `authors` | `_data/authors.yml` の ID、名前、または `{name, url, picture}` |
| `image` | カバー: パス、または `{path, alt, width, height}` |
| `image_alt`, `image_caption` | カバーの代替テキストとキャプション |
| `deck` | タイトルの下の 1 文 |
| `series` | 同じシリーズの投稿に「全 3 回中 2 回目」と互いへのリンクが付きます |
| `categories`, `tags` | 投稿の下に表示され、関連する投稿の選択に使われます |
| `last_modified_at` | 最終更新日 |

```yaml
---
title: Shipping 1.0
author: kim
image: {path: /assets/cover.webp, alt: The release dashboard, width: 1024, height: 576}
series: launch
tags: [release]
---
```

著者のデータとフィードは[ブログとニュース](../)で説明しています。
