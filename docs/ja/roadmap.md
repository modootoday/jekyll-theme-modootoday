---
title: ロードマップ
description: 1.0 に含まれるすべてのものと、2.0 で変わるもの。
---
# ロードマップ

> [!NOTE]
> このページは[英語の原文](../../roadmap/)の翻訳です。内容が異なる場合は英語版が優先されます。

1.0 は以下の項目がすべて終わった時点で出ます。別の 1.x リストはなく、後回しにしていた作業も 1.0 に含まれます。

## 1.0

- すべてのコンポーネントのライト・ダークでの見た目の仕上げ (ドキュメントサイトとキッチンシンク)。 `status:partial`
- 確定したルール (`md-components v1`) と凍結された[公開 API](../api/)、非推奨ポリシー。 `status:available`
- canonical、hreflang、Open Graph タグと、任意のサイトマップ・フィード。 `status:available`
- 英語、韓国語、日本語のドキュメント。 `status:available`
- サンプルサイトのすべての言語にガイドページ。 `status:available`
- `_data/components.yml` のスロット契約 ([API](../api/))。 `status:available`
- 右から左に書く文字: 論理プロパティ、自動の `dir="rtl"`、[RTL キッチンシンク](../../components/kitchen-sink-rtl/)。 `status:available`
- 厳格な CSP のもとで KaTeX と Mermaid を使う[数式と図のガイド](../math-diagrams/)。テーマはどちらも同梱しません。 `status:available`
- CI で基準スクリーンショットと比較する見た目の回帰チェック (プルリクエストでブロック) と Lighthouse の予算。 `status:available`
- `post` レイアウト用のタグ・カテゴリーのアーカイブページ。 `status:planned`

## 2.0

- 非推奨の `md-*` クラスと `--md-*` プロパティを削除します。[移行とアップグレード](../upgrade/)を参照してください。
