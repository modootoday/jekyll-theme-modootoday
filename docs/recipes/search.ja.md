---
lang: ja
permalink: /ja/recipes/search/
source_rev: sha256:cafe0cd79859
nav_order: 25
title: 検索
description: ヘッダーの検索を有効にし、インデックスに入れる内容と検索語の照合方法を決め、長いリストや表を読者が入力して絞り込めるようにする方法を説明します。
---
# 検索

> [!NOTE]
> このページは[英語の原文](../../../recipes/search/)の翻訳です。内容が異なる場合は英語版が優先されます。

ヘッダー検索は Liquid が作る `search.json` ファイルを 1 つ読み込みます。そのため、プラグインや外部サービスなしでクラシックな GitHub Pages でも動きます。検索スクリプトとこのファイルは、読者が検索欄に初めてフォーカスしたとき、または `/` か Ctrl+K を押したときに読み込みます。検索しない訪問ではどちらも読み込みません。

## 有効にする

サイトのルートに `search.json` ファイルを追加します。front matter に `layout: null` と書き、本文は `modootoday/search.json` を include する 1 行です。[このサイトのファイル](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/search.json)をコピーしてください。

すべてのページのヘッダーに検索欄が表示されます。front matter に `search: false` と書いたページと、タイトルのないページは除外されます。

## インデックスの内容を決める

```yaml
modootoday:
  search:
    words: 2000                 # 各ページ本文から索引する語数。0 で全文（既定は 300）
    collections: [skills]       # output: true のコレクション。投稿の後に索引します
    fields: [description, tags] # 本文と一緒に検索する front matter
    exclude: [/v1/]             # 除外する URL の接頭辞。例: 古い版のドキュメント
```

本文を長く入れるほど多く見つかりますが、読者は初めての検索でインデックス全体をダウンロードします。ビルドした `search.json` が 1.5 MB を超えると `modootoday-check` が警告します。

## 検索語の照合方法を決める

```yaml
modootoday:
  search:
    match: terms   # すべての語を順不同で（既定の substring は入力どおり）
    compact: true  # 空白を除いた比較もします
    results: 12    # 既定は 8
```

大文字と小文字を区別せず、テキストを Unicode NFC にそろえて比較するので、2 通りの書き方のアクセントやハングルの音節も互いに見つかります。`compact: true` は韓国語のように分かち書きが揺れる言語向けの設定です。검색량조회 で 검색량 조회 が見つかり、その逆も見つかります。タイトルが一致するページが先に、ページの言語の結果がほかの言語より先に表示されます。語幹処理と初声検索はしません。

これらのキーがなければ、検索はこれまでと同じです。入力どおりに探し、結果は 8 件、各ページ 300 語を索引します。

検索は 2 文字から、漢字・かな・ハングルなら 1 文字（표、表）から始まります。結果のタイトルと抜粋で一致した語はすべて `mark` になり、プライマリカラーを薄く敷いた背景に下線が付きます（1 行の抜粋では下線だけになり、省略記号で切れた語に色が残りません）。見た目は `.mt-search-results mark` で変えられます。Tab で検索ボックスの外に出ると結果は閉じ、Esc は検索語を消します。

## リストや表を絞り込む

1 ページの長いリストや表は、その `sections:` の項目に `filter:` を追加します。`sections:` のないページでは front matter に追加します。

```yaml
sections:
  - {name: tools, filter: true}
  - {name: plans, filter: {facet: 3}}
```

そのセクションの最初のリストか表の上に入力欄ができ、入力した語をすべて含む項目だけを表示して、表示中の件数を知らせます。照合方法は `compact: true` と同じです。`facet: 3` は表の 3 列目の値ごとにボタンを追加します。ディレクトリページでは `filter_text: true` でカードの上に同じ入力欄を置きます。JavaScript がなければすべての項目が表示されます。[絞り込みデモ](../../layouts/demo/filter/)を参照してください。
