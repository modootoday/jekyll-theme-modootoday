---
lang: ja
permalink: /ja/layouts/detail/
source_rev: sha256:9a2703b36f11
nav_order: 30
title: 詳細ページ
description: プロジェクト、事例、求人、イベント、ポッドキャストのエピソードを 1 件ずつ 1 ページで表示し、概要のリスト、行動喚起 1 つ、構造化データを備えます。
---
# 詳細ページ

詳細ページは1件の項目を表示します。見出し、front matter から読む概要リスト、本文、行動喚起のリンク1つで構成されます。これらのレイアウトは自分のページでだけ `modootoday-detail.css` を読み込み、JavaScript は追加しません。同じ front matter から schema.org のメインエンティティを出力し、`schema:` マップに書いたプロパティが優先されます。 任意の `image: {path, alt, width, height}` を指定すると、ヘッダーの下にカバー画像を表示します。

| レイアウト | 概要 | 行動喚起 | 構造化データ | デモ |
|---|---|---|---|---|
| `project` | クライアント、役割、年、技術、リンク | `cta` | CreativeWork | [プロジェクト](project/) |
| `case-study` | クライアント、役割、年、技術、リンク | `cta` | Article | [事例](case-study/) |
| `job` | 勤務地、雇用形態、給与、掲載日、締切 | 応募する（`apply`） | JobPosting | [求人](job/) |
| `event` | 開始、終了、会場、オンライン、料金 | チケットと .ics ファイル | Event | [イベント](event/) |
| `episode` | シーズンと回、掲載日、長さ、音声プレーヤー | `cta` | PodcastEpisode | [エピソード](episode/) |

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
tickets: {url: https://example.com/tickets, price: 2000, currency: JPY}   # または URL だけ
---
```

カレンダーのリンクは `data:` URL に入った .ics ファイルなので、サーバーなしで動きます。`tickets:` は「チケットを入手」ボタンのリンクで、イベントの `offers` にもなります。マップで書くと `price`(0 以上の数値)と `currency`(KRW や USD などの ISO 4217 コード)が販売情報と情報リストの料金の行に入り、0 は無料と表示されます。両方書くか、どちらも書かないでください。URL だけだと販売情報に価格がないため、`modootoday-check` が警告し(次のメジャーバージョンからはエラー)、マップの形を示します。`availability` や販売期間など、さらに書くときは販売情報を自分で書いてください。`schema: {offers: {type: Offer, price: 0, priceCurrency: JPY, availability: https://schema.org/InStock, url: https://example.com/tickets}}` は `tickets:` から作る販売情報の代わりになります。[イベントのデモ](event/)は自分の front matter を見せています。

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
