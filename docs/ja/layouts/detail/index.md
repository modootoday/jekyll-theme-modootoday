---
title: 詳細ページ
description: プロジェクト、事例、求人、イベント、ポッドキャストのエピソードを1件ずつ表示し、概要リスト、行動喚起1つ、構造化データを備えます。
nav_order: 30
---
# 詳細ページ

詳細ページは1件の項目を表示します。見出し、front matter から読む概要リスト、本文、行動喚起のリンク1つで構成されます。これらのレイアウトは自分のページでだけ `modootoday-detail.css` を読み込み、JavaScript は追加しません。同じ front matter から schema.org のメインエンティティを出力し、`schema:` マップに書いたプロパティが優先されます。 任意の `image: {path, alt, width, height}` を指定すると、ヘッダーの下にカバー画像を表示します。

| レイアウト | 概要 | 行動喚起 | 構造化データ | デモ |
|---|---|---|---|---|
| `project` | クライアント、役割、年、技術、リンク | `cta` | CreativeWork | [プロジェクト](/jekyll-theme-modootoday/ja/layouts/detail/project/) |
| `case-study` | クライアント、役割、年、技術、リンク | `cta` | Article | [事例](/jekyll-theme-modootoday/ja/layouts/detail/case-study/) |
| `job` | 勤務地、雇用形態、給与、掲載日、締切 | 応募する（`apply`） | JobPosting | [求人](/jekyll-theme-modootoday/ja/layouts/detail/job/) |
| `event` | 開始、終了、会場、オンライン | チケットと .ics ファイル | Event | [イベント](/jekyll-theme-modootoday/ja/layouts/detail/event/) |
| `episode` | シーズンと回、掲載日、長さ、音声プレーヤー | `cta` | PodcastEpisode | [エピソード](/jekyll-theme-modootoday/ja/layouts/detail/episode/) |

## 求人

```yaml
---
layout: job
title: テクニカルライター
description: 製品ドキュメントを執筆・管理します。
date: 2026-10-01          # datePosted
deadline: 2026-12-01      # validThrough
employment: full-time     # full-time, part-time, contractor, temporary, intern, volunteer, per-diem, other
location: 東京            # または remote: Japan（応募者が居住すべき国）
salary: {min: 6000000, max: 8000000, currency: JPY, unit: year}
apply: mailto:jobs@example.com
---
```

採用組織はサイトの発行者（`modootoday.schema.publisher`）です。`date` がない、`location` と `remote` のどちらもない、未知の `employment` の値のときは `modootoday-check` が報告します。

## イベント

```yaml
---
layout: event
title: テーマ勉強会
starts: 2026-11-20 19:00:00 +0900
ends: 2026-11-20 21:00:00 +0900
venue: Aホール            # 会場、オンライン URL、またはその両方
address: 東京都千代田区丸の内1-1
online: https://example.com/live
tickets: https://example.com/tickets
---
```

カレンダーのリンクは `data:` URL に入った .ics ファイルなので、サーバーなしで動きます。

## エピソード

```yaml
---
layout: episode
title: 第1回
date: 2026-10-10
season: 1
episode: 3
duration: 42              # 分
audio: /media/ep3.mp3
transcript: /podcast/3/transcript/
---
```

プレーヤーはブラウザー標準の `<audio controls>` で、再生するまで何も読み込みません。

## プロジェクトと事例

```yaml
---
layout: project           # または case-study（著者と日付を持つ Article）
title: アトラス
client: ACME
role: デザインと開発
year: 2026
stack: [Jekyll, Sass]
links:
  - {label: リポジトリ, url: "https://example.com/atlas"}
cta: {label: お問い合わせ, url: /contact/}
---
```

## アクセシビリティ

記事は見出しでラベル付けされ、概要は説明リスト（`dl`）です。繰り返し現れるリンク（応募する、チケット）はスクリーンリーダーにページ名も伝えます。印刷時は行動喚起とプレーヤーを隠します。
