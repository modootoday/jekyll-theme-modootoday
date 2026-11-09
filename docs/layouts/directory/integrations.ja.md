---
lang: ja
permalink: /ja/layouts/directory/integrations/
source_rev: sha256:4ed08212de50
title: 連携のレイアウト
description: "連携やプラグインをロゴと分類付きのカードで並べ、分類で絞り込めるレイアウトです。"
layout: layout-reference
nav_order: 6
twin: true
---
# 連携のレイアウト

`layout: integrations` は、連携、プラグイン、拡張機能をカードで並べます。カードにはロゴ、名前、分類、1 行の説明が入ります。カードは `items:`、`_data` のファイル、レコードのセットから作れます。レコードのセットから作ると、各カードがそれぞれのレコードのページにリンクします。分類が 2 つ以上あると、JavaScript を使わずにカードを絞り込むボタンの列が表示されます。ライブデモは、5 件のレコードから作った docs スターターのプラグイン一覧です。

## Front matter

| キー | 用途 |
|---|---|
| `items` | カード: `name` または `title`、`category`、`text`、`url`、`image`、`alt`、`width`、`height` |
| `data` | `items` の代わりにカードを読む `_data` のファイル名 |
| `records` | `modootoday.records` のレコードのセット。各カードがレコードのページにリンクします |
| `filter` | `false` で分類のボタンを隠し、別のフィールド名を書くとそのフィールドで絞り込みます |
| `filter_text` | `true` で、入力に合わせてカードを絞り込む検索欄を加えます |

ページは構造化データに `ItemList` を出力します。すべてのディレクトリ系レイアウトの項目、絞り込み、レコードのセットは[ディレクトリのレイアウト](../)で、レコードごとにページを作る方法は[生成ページ](../../../recipes/generated-pages/)で説明しています。
