---
title: マーケティングページ
description: 機能、料金、ダウンロード、ブランド、リンク、お問い合わせのページを共通の任意スタイルシートで作ります。
nav_order: 40
---
# マーケティングページ

製品まわりのページを作るレイアウトです。何ができるか、いくらか、どこで入手するか、どう見せるか、どう連絡するかを扱います。自分のページでだけ `modootoday-marketing.css` を読み込み、JavaScript は追加しません。どのレイアウトもタイトル、リード文の `description:`、任意の `actions: [{label, url}]` ボタンを読みます。

| レイアウト | front matter | 構造化データ | デモ |
|---|---|---|---|
| `feature` | `features: [{title, text}]`、`cta` | WebPage | [機能](/jekyll-theme-modootoday/ja/layouts/marketing/feature/) |
| `pricing` | `plans`、`currency` | WebPage | [料金](/jekyll-theme-modootoday/ja/layouts/marketing/pricing/) |
| `download` | `version`、`date`、`downloads: [{label, url, size, checksum}]` | WebPage | [ダウンロード](/jekyll-theme-modootoday/ja/layouts/marketing/download/) |
| `brand` | `colors: [{name, hex}]`、`assets: [{label, url, format}]` | WebPage | [ブランド](/jekyll-theme-modootoday/ja/layouts/marketing/brand/) |
| `links` | `image`、`name`、`links: [{label, url}]` | ProfilePage | [リンク](/jekyll-theme-modootoday/ja/layouts/marketing/links/) |
| `contact` | `contacts: [{label, value, url}]`、`form: {action, fields}` | ContactPage | [お問い合わせ](/jekyll-theme-modootoday/ja/layouts/marketing/contact/) |

製品情報を構造化データにするには `schema:` マップ（例: `type: SoftwareApplication` と `offers`）を追加します。メインエンティティとして出力されます。

## 料金

```yaml
---
layout: pricing
currency: ¥
plans:
  - {name: 無料, monthly: 0, yearly: 0, features: [サイト1つ]}
  - {name: チーム, monthly: "1,500", yearly: "15,000", recommended: true, features: [サイト10個, サポート], cta: {label: チームを選ぶ, url: /buy/}}
---
```

プランのカードは料金コンポーネントのスタイルを使います。プランに `yearly` があると、2つのラジオボタンでできた月額／年額の切り替えが CSS だけで価格を切り替えます。`yearly` はすべてのプランに付けるか、どれにも付けないでください。`recommended` は1つだけで、文字でも示されます。

## リンク

リンクページにはサイトのヘッダーがありません。`links:` は大きなボタンになり、完全な URL は ProfilePage データの Person（または `profile: organization`）の `sameAs` に入ります。

## お問い合わせ

```yaml
---
layout: contact
contacts:
  - {label: メール, value: hello@example.com, url: "mailto:hello@example.com"}
form:
  action: https://forms.example.com/your-form   # 外部フォームサービス（https のみ）
  fields: [name, email, message]
---
```

GitHub Pages はフォームの送信を受け取れないため、`form.action` を設定したときだけフォームが表示されます。すべての入力欄に見えるラベルと `autocomplete` があります。

## ブランド

色見本は SVG の塗りなので、厳格なコンテンツセキュリティポリシー（CSP）でもインラインスタイルは不要です。各色は16進コードも文字で表示します。`#rgb` や `#rrggbb` でない色は `modootoday-check` が報告します。
