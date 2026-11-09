---
lang: ja
permalink: /ja/layouts/marketing/pricing/
source_rev: sha256:252e03b3e520
title: 料金のレイアウト
description: "JavaScript なしで月額と年額を切り替えられる料金プランのカードです。"
layout: layout-reference
nav_order: 2
twin: true
---
# 料金のレイアウト

`layout: pricing` は本文のあとに、プランごとに 1 枚のカードを表示します。プランに年額があると、2 つのラジオボタンでできた月額/年額の切り替えが CSS だけで価格を切り替えます。おすすめのプランを 1 つ指定でき、おすすめであることはテキストでも示されます。ライブデモは landing スターターの料金ページです。

## Front matter

| キー | 用途 |
|---|---|
| `plans` | カード: `name`、`monthly`、`yearly`、`features`（リスト）、`recommended: true`、`cta: {label, url}` |
| `currency` | すべての価格の前に付く記号（`$` など） |
| `description` | タイトルの下のリード文 |
| `actions` | リード文の下のボタン: `[{label, url}]` |

```yaml
---
layout: pricing
currency: $
plans:
  - {name: Free, monthly: 0, yearly: 0, features: [One site]}
  - {name: Team, monthly: 12, yearly: 120, recommended: true, features: [Ten sites, Support], cta: {label: Choose Team, url: /buy/}}
---
```

`yearly` はすべてのプランに書くか、どれにも書かないかのどちらかにします。ほかのマーケティング系レイアウトと front matter は[マーケティングページ](../)にあります。
