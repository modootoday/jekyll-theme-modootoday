---
title: ディレクトリレイアウト
description: プロジェクト、メンバー、求人、イベント、スポンサー、連携をカード一覧で表示し、JavaScript なしで絞り込めます。
nav_order: 20
---
# ディレクトリレイアウト

ディレクトリページは本文の後にカード一覧が続きます。カードは front matter の `items:` か `_data` のファイルから読み込みます。これらのレイアウトは自分のページでだけ `modootoday-directory.css` を読み込み、JavaScript は追加しません。

| レイアウト | カードの内容 | 絞り込み | 構造化データ | デモ |
|---|---|---|---|---|
| `portfolio` | 画像、タイトル、説明、タグ | `tags` | ItemList | [ポートフォリオ](/jekyll-theme-modootoday/ja/layouts/directory/portfolio/) |
| `team` | 丸い写真、名前、役割 | `group` | Person の一覧 | [チーム](/jekyll-theme-modootoday/ja/layouts/directory/team/) |
| `jobs` | 職種、勤務地、雇用形態 | `department` | ItemList | [求人](/jekyll-theme-modootoday/ja/layouts/directory/jobs/) |
| `events` | 日付タイル、タイトル、場所、カレンダーファイル | なし | Event の一覧 | [イベント](/jekyll-theme-modootoday/ja/layouts/directory/events/) |
| `sponsors` | ロゴ、名前、ランク | `tier` | ItemList | [スポンサー](/jekyll-theme-modootoday/ja/layouts/directory/sponsors/) |
| `integrations` | ロゴ、名前、カテゴリー、説明 | `category` | ItemList | [連携](/jekyll-theme-modootoday/ja/layouts/directory/integrations/) |

`layout: directory` は基本形です。`preset:` に上の名前のどれかを指定するか、省略すると簡単なカードになります。

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

複数のページで同じ一覧を使うには `_data/team.yml` に置き、`items:` の代わりに `data: team` と書きます。

## 絞り込み

絞り込むフィールドの値が 2 つ以上あると、カードの上にボタンの列が表示されます。ラジオボタンのグループなのでキーボードで操作でき、スクリーンリーダーが選択を読み上げます。表示される値は 12 個までです。隠すには `filter: false`、別のフィールドで絞り込むには `filter: <フィールド>` と書きます。`:has()` に対応しないブラウザーではすべてのカードが表示されます。

## イベント

各イベントにはページに埋め込まれた `.ics` ファイルへのリンクがあり、サーバーなしでカレンダーに追加できます。日時はサイトの `timezone` に従います。
