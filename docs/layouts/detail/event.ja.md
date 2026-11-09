---
lang: ja
permalink: /ja/layouts/detail/event/
source_rev: sha256:858acc578e19
title: イベントのデモ
image: {path: /assets/images/events/stage.webp, alt: "客席に向かうスポットライトの当たった舞台", width: 800, height: 600}
description: このテーマでサイトを作る方法を扱う夜の勉強会です。短い発表が 2 つと質問の時間があります。参加は無料なので、申し込んでチケットを受け取ってください。
layout: event
nav_order: 4
edit: false
sections: []
starts: "2026-11-20 19:00:00 +0900"
ends: "2026-11-20 21:00:00 +0900"
venue: Aホール
address: 東京都千代田区丸の内1-1
online: "#"
tickets: "#"
schema: {offers: {type: Offer, price: 0, priceCurrency: KRW, availability: "https://schema.org/InStock", url: "https://modootoday.github.io/jekyll-theme-modootoday/ja/layouts/detail/event/"}}
twin: false
---
短い発表が2本と質疑応答です。

**参加費:** 無料です。「チケットを入手」ボタンから申し込んでください。

このページの front matter です。[詳細ページ](../)のガイドで説明しています。

```yaml
layout: event
title: イベントのデモ
starts: "2026-11-20 19:00:00 +0900"
ends: "2026-11-20 21:00:00 +0900"
venue: Aホール
address: 東京都千代田区丸の内1-1
online: "#"
tickets: "#"
schema: {offers: {type: Offer, price: 0, priceCurrency: KRW, availability: "https://schema.org/InStock", url: "https://modootoday.github.io/jekyll-theme-modootoday/ja/layouts/detail/event/"}}
```

`schema:` の `offers` は同じ無料の参加情報をページの構造化データで示し、このページを `url` にします。
