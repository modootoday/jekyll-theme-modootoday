---
lang: ja
permalink: /ja/recipes/generated-pages/
source_rev: sha256:a2be5639b5f5
nav_order: 27
title: 生成ページ
description: JSON や YAML のデータファイルにあるレコードごとに、クラシックな GitHub Pages でページを 1 つずつ作り、全体を絞り込めるリストにまとめ、ファイルをバイト単位でそのまま公開します。
---
# 生成ページ

> [!NOTE]
> このページは[英語の原文](../../../recipes/generated-pages/)の翻訳です。内容が異なる場合は英語版が優先されます。

カタログ、プラグイン一覧、用語集は、1 つのデータファイルから始まることがよくあります。Jekyll 4 のプラグインならレコードごとにページを作れますが、クラシックな GitHub Pages はサイト独自のプラグインを実行しないため、ページごとにリポジトリ内のファイルが必要です。そのファイルは `modootoday-stubs --records` が書きます。レコードごとに front matter だけの短いページを作り、残りの内容はサイトのビルド時にレイアウトがデータファイルから読み込みます。

[docs スターターのプラグイン一覧](https://modootoday.github.io/jekyll-theme-modootoday-docs-starter/plugins/ "new-window")で確認できます。1 つの JSON ファイルにある 5 件のレコードにそれぞれページがあり、絞り込めるリストにまとまっています。

## レコードセットの宣言

レコードは `_data/plugins.json`（または `.yml`）に置きます。オブジェクトのリスト、または `items` リストのあるマップにします。各レコードには、URL に使える安全なキー（英小文字、数字、`.`、`_`、`-`）とタイトルが必要です。

```json
[
  {"slug": "lantern", "name": "Lantern", "summary": "Highlights the section a reader came to.", "category": "Reading", "version": "2.1.0", "tags": ["search"], "readme": "Lantern reads the words a reader searched for..."}
]
```

次に `_config.yml` にセット名を書きます。

```yaml
modootoday:
  records:
    plugins: {title: name, description: summary, facts: [category, version, tags], body: readme}
```

| 設定 | 既定値 | 意味 |
|---|---|---|
| `data` | セット名 | 拡張子を除いた `_data` 内のファイル名 |
| `key` | `slug` | レコードを指すフィールド。ファイル名と URL になる |
| `dir` | セット名 | ページを置くフォルダー |
| `permalink` | `/<dir>/:key/` | ページの URL。`:key` はレコードのキーに置き換わる |
| `layout` | `detail` | `detail`、`reference`、または `project` や `job` などの詳細レイアウト |
| `title` | `title` | ページのタイトルにコピーするフィールド |
| `description` | `description` | ページの説明にコピーするフィールド |
| `facts` | なし | タイトルの下に情報の一覧として表示するフィールド。リストの値はタグとして表示 |
| `labels` | フィールド名 | 情報のラベル。例: `{version: バージョン}` |
| `body` | なし | ページ本文に変換する Markdown フィールド |
| `lang` | なし | フォルダーで言語が決まらないときのページの言語 |

## ページを書く

```sh
modootoday-stubs . --records           # list the pages it would create, update or delete
modootoday-stubs . --records --write   # write them
modootoday-stubs . --records --check   # CI: exit 1 when a page is missing, out of date or left over
```

1 つのページは `plugins/lantern.md` です。

```yaml
---
layout: detail
title: "Lantern"
description: "Highlights the section a reader came to."
permalink: /plugins/lantern/
record: plugins/lantern
record_index: 0
twin: false
---
```

タイトルと説明をコピーするのは、ページのタイトル、リンクのプレビュー、構造化データ、検索インデックスがレイアウトより先にこれらの値を読むためです。`record_index` はリスト内でのレコードの位置です。そのため、ページは他のレコードを読まずに自分のレコードを見つけます。リストの順序が変わったのにページを書き直していない場合でも、少し遅くはなりますがページはレコードを見つけ、`--check` はそのページが古いと報告します。なくなったレコードのページは削除します（`--no-prune` なら残します）。自分で書いたページを上書きすることはありません。

`--records=plugins,team` は名前を挙げたセットだけを書きます。レコードのページには Markdown 版がありません。

コミットのたびにこのコマンドを実行してください。たとえば Git の pre-commit フックから実行できます。

```sh
#!/bin/sh
modootoday-stubs . --records --write --quiet && git add -A -- plugins
```

## レコードの一覧

ディレクトリーページでは、`items:` や `data:` の代わりに `records:` でセットを一覧にします。各カードはレコードのページにリンクし、セットに書いたフィールドからタイトルと本文を取ります。

```yaml
---
title: Plugins
layout: integrations
records: plugins
filter_text: true
---
```

`layout: integrations` は `category` ごとにボタンを加え、`filter_text: true` は文字で絞り込むフィルターを加えます。[ディレクトリーレイアウト](../../layouts/directory/)を参照してください。

## サイトの確認

`modootoday-check` は、ページのないレコード、レコードのないページ、古いページを、`modootoday-stubs --records --check` と同じ基準で報告します。CI では両方を実行してください。

```sh
modootoday-stubs . --records --check
modootoday-check . _site
```

## ファイルをバイト単位でそのまま公開

front matter のないファイルはそのままコピーされるので、JSON ファイルを入れた `api/` フォルダーは小さな静的 API になります。それを確かめるのが `modootoday-check . _site --byte-exact=api` です。`api/` 以下のすべてのファイルが、同じ SHA-256 のままビルドに含まれている必要があります。`_data/` 以下のフォルダー、`exclude:` に挙げたフォルダー、`_` や `.` で始まるフォルダー（`include:` に挙げていない場合）、front matter のあるファイル、Markdown や Sass のファイルは失敗します。Jekyll がこれらをそのままコピーしないためです。

## 制限

- レコードごとにリポジトリにファイルが 1 つあります。CI はテーマを変更するたびに GitHub Pages のビルダーでレコード 1,000 件をビルドし、Pages の上限の半分である 300 秒を超えると失敗します。
- リストの末尾以外にレコードを加えると、その後ろのページの `record_index` が変わり、`--write` がそれらを書き直します。コミットを小さくするには、新しいレコードを末尾に加えてください。
- 検索インデックスに入るのはレコードのページのタイトル、説明、front matter のフィールドで、本文のフィールドは入りません。
