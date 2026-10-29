---
title: コンポーネント
description: すべてのコンポーネントと、それを生み出す Markdown。
sections:
  - {c: features, name: catalog, cols: 2}
  - status
  - {c: cta, name: next}
---
# コンポーネント

どのコンポーネントも普通の Markdown です。github.com では素の要素として表示されます。

[キッチンシンクを開く](kitchen-sink/)

> [!NOTE]
> このページは[英語の原文](../../components/)の翻訳です。内容が異なる場合は英語版が優先されます。

## カタログ

- **アラート** — `> [!NOTE]` などの 5 種類がコールアウトになります。 `status:available`
- **セクション** — front matter の `sections:` が `##` 見出しをレイアウトに対応させます。 `status:available`
- **カード** — `- **タイトル** — テキスト` 形式の項目のリストがグリッドになります。 `status:available`
- **ボタン** — リンクだけの段落が CTA ボタンになります。 `status:available`
- **タブ** — `###` とコードブロックの組がアクセシブルなタブになります。 `status:available`
- **ステータスバッジ** — ステータスのコードスパンがバッジになります。 `status:available`
- **表** — GFM の表は小さな画面で横にスクロールします。 `status:available`
- **アコーディオンとステップ** — `c: accordion` と `c: steps` のセクション。 `status:available` `since:0.3`
- **図** — 画像と、その後に続く強調だけの段落。 `status:available` `since:0.3`
- **パンくずリスト、目次、テーマ切り替え** — レイアウトが自動で追加します。 `status:available` `since:0.3`
- **タグと導入バージョンのバッジ** — tag と since のコードスパン。 `status:available` `since:0.3`
- **タイムライン** — `c: timeline` のセクション。 `status:available` `since:0.4`
- **キーボードのキー** — `kbd:Ctrl+K` 形式のコードスパン。 `status:available` `since:0.4`
- **検索** — `search.json` ファイルを使うクライアント検索。 `status:available` `since:0.4`
- **コンポーネントのスロット** — `_data/components.yml` のスロット契約。 `status:planned`

## ステータスの凡例

| バッジ | 意味 |
|---|---|
| `status:available` | 提供済みで安定 |
| `status:partial` | 既知の制限付きで動作 |
| `status:planned` | ロードマップに掲載 |

## 次へ

[キッチンシンク](kitchen-sink/) [設定](../configuration/)
