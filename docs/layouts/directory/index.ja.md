---
lang: ja
permalink: /ja/layouts/directory/
source_rev: sha256:ee066a8fdb56
title: ディレクトリレイアウト
description: プロジェクト、メンバー、求人、イベント、スポンサー、連携をカード一覧で表示し、JavaScript なしで絞り込めます。
nav_order: 20
---
# ディレクトリレイアウト

ディレクトリページは本文の後にカード一覧が続きます。カードは front matter の `items:` か `_data` のファイルから読み込みます。これらのレイアウトは自分のページでだけ `modootoday-directory.css` を読み込み、テキスト絞り込みを有効にしない限り JavaScript は追加しません。

| レイアウト | カードの内容 | 絞り込み | 構造化データ | デモ |
|---|---|---|---|---|
| `portfolio` | 画像、タイトル、説明、タグ | `tags` | ItemList | [ポートフォリオ](portfolio/) |
| `team` | 丸い写真、名前、役割 | `group` | Person の一覧 | [チーム](team/) |
| `jobs` | 職種、勤務地、雇用形態 | `department` | ItemList | [求人](jobs/) |
| `events` | 日付タイル、タイトル、場所、カレンダーファイル | なし | Event の一覧 | [イベント](events/) |
| `sponsors` | ロゴ、名前、ランク | `tier` | ItemList | [スポンサー](sponsors/) |
| `integrations` | ロゴ、名前、カテゴリー、説明 | `category` | ItemList | [連携](integrations/) |

`layout: directory` は基本形です。`preset:` に上の名前のどれかを指定するか、省略すると簡単なカードになります。

ほかのテーマから移ったサイトは、`defaults` でコレクションに同じ名前のレイアウトを付けることがよくあります。そのため `_portfolio/atlas.md` は `portfolio` になります。`items:`、`data:`、`records:` のない文書は一覧ではなく一つの項目なので、これらのレイアウトは対応する詳細ページとして描きます。`portfolio` は `project`、`jobs` は `job`、`events` は `event`、それ以外は `detail` になり、構造化データもそのページに従います。レイアウトがまったくないコレクション文書はテーマなしで出力されます(jekyll-default-layout はページと記事にだけレイアウトを付けます)。`modootoday-check` はこれを警告し、`defaults` に入れるレイアウトを示します。

## front matter

| キー | 用途 |
|---|---|
| `items` | カードの一覧: `title` または `name`、`url`、`text`、`image`、`alt`、`width`、`height`、下のプリセットのフィールド |
| `data` | `items` の代わりにカードを読み込む `_data` のファイル名 |
| `records` | `modootoday.records` のレコードのセット。カードごとにレコードのページへリンクします |
| `preset` | `layout: directory` で、上の表のレイアウト名のどれか |
| `filter` | `false` で絞り込みボタンを隠し、別のフィールド名を渡すとそのフィールドで絞り込みます |
| `filter_text` | `true` で、入力に合わせてカードを絞る検索欄を加えます |

## 項目

```yaml
---
layout: team
items:
  - {name: 金エイダ, role: 創業者, group: 経営, image: /assets/ada.jpg, alt: "", url: /about/ada/}
  - {name: 伊藤ベン, role: デザイナー, group: デザイン}
---
```

各項目に `title` か `name` が必要です。すべての項目で `url`、`text`、`image`、`alt`、`width`、`height` を使えます。写真が名前を繰り返すだけなら `alt: ""` にしてください。プリセットごとのフィールド:

- `team`: `role`、`group`
- `jobs`: `department`、`location`、`type`
- `events`: `date`(必須、`YYYY-MM-DD HH:MM`)、`end`、`location`、オンラインなら `online: true`(このとき `url` が開催場所)
- `sponsors`: `tier`
- `integrations`: `category`
- `portfolio`: `tags`(リスト)

複数のページで同じ一覧を使うには `_data/team.yml` に置き、`items:` の代わりに `data: team` と書きます。項目ごとにページも用意するには、レコードセットを宣言して `records: <set>` と書きます。各カードがレコードのページにリンクします ([生成ページ](../../recipes/generated-pages/)を参照)。

## 絞り込み

絞り込むフィールドの値が 2 つ以上あると、カードの上にボタンの列が表示されます。ラジオボタンのグループなのでキーボードで操作でき、スクリーンリーダーが選択を読み上げます。表示される値は 12 個までです。隠すには `filter: false`、別のフィールドで絞り込むには `filter: <フィールド>` と書きます。`:has()` に対応しないブラウザーではすべてのカードが表示されます。

カードの上に検索欄も置くには `filter_text: true` と書きます。入力した語をすべて含むカードだけを表示して件数を知らせ、フィールドの絞り込みと一緒に動きます。JavaScript が必要で、JavaScript がなければすべてのカードが表示されます。

## イベント

各イベントにはページに埋め込まれた `.ics` ファイルへのリンクがあり、サーバーなしでカレンダーに追加できます。日時はサイトの `timezone` に従います。
