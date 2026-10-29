---
title: 公開 API
description: このテーマが安定して保つ名前と、その非推奨化・削除の手順。
---
# 公開 API

> [!NOTE]
> このページは[英語の原文](../../api/)の翻訳です。内容が異なる場合は英語版が優先されます。

1.0 以降、以下の名前は[セマンティック バージョニング](https://semver.org/lang/ja/)に従います。互換性のない変更はメジャーバージョンでのみ行います。一覧にないもの (内部のインクルード、Sass パーシャルのパス、非公開の `--mt-p-*` プリミティブ、どのルールにも書かれていない HTML の細部) は、どのリリースでも変わることがあります。

## 安定した名前

| 領域 | 安定した名前 |
|---|---|
| 設定 | [設定](../configuration/)に載っている `modootoday:` 配下のすべてのキー |
| デザイントークン | セマンティックおよびコンポーネントのカスタムプロパティ `--mt-*` (プリミティブ `--mt-p-*` を除く)。生成される `tokens.json` も同じ |
| Markdown ルール | `RULES.md` のパターンと、その出力クラス `mt-*` |
| レイアウト | `default`, `doc`, `post`, `twin`, `llms`, `llms-full` |
| 上書きしてよいインクルード | `head-custom.html`, `footer-custom.html` |
| データファイル | `_data/i18n/<lang>.yml` のキー、`_data/nav/<name>.yml`、`_data/components.yml` |
| チェッカー | `modootoday-check` のオプション、終了コード 0 (問題なし) と 1 (問題あり、または使い方の誤り) |

## 非推奨ポリシー

1. なくなる名前は `CHANGELOG.md` とドキュメントで非推奨と明記し、可能な箇所ではチェッカーが警告します。
2. 少なくとも 1 回のマイナーリリースの間は動作し続けます。
3. 削除は次のメジャーリリースでのみ行います。

この一覧は 1.0 で凍結されます。1.x のリリースは名前を追加できますが、上の名前を 2.0 より前に削除したり互換性なく変えたりはしません。Markdown のルールは `RULES.md` の `md-components v1` として確定しています。

> [!IMPORTANT]
> 旧来の `md-*` クラスと `--md-*` プロパティは `mt-*` と `--mt-*` の別名です。1.0 から非推奨で、1.x の間は動作し、2.0 で削除されます。サイト独自の Sass、CSS、インクルード、レイアウト、ページがこれらを使うと `modootoday-check` が警告します。[対応表](../upgrade/)を参照してください。

## コンポーネントの構造

自分の CSS から今すぐ対象にできるマークアップです。この表のクラスと属性は上のポリシーのもとで安定しています。表に名前のない内側の要素 (ラッパー、生成される id、子要素の順序) は安定していません。コンポーネントごとの正式なスロット契約は 1.x で予定しています。下の「1.0 に含まれないもの」を参照してください。

| コンポーネント | ルート | スタイルを当ててよい部分 | 状態とバリエーション |
|---|---|---|---|
| ページの枠 | `body.mt-body` | `a.mt-skip`, `header.mt-header` > `.mt-header-inner` (`.mt-site-title`, `nav.mt-nav`, `.mt-search`, `.mt-theme-toggle`), `main.mt-main`, `footer.mt-footer` > `.mt-footer-inner` | `html[data-theme=light\|dark]` (固定の配色、またはトグルが設定) |
| ドキュメントページ | `article.mt-doc` | `.mt-doc-layout` > `.mt-doc-main` と `.mt-doc-aside` (`nav.mt-toc` を含む), `nav.mt-toc-mobile`, `nav.mt-breadcrumb`, `.mt-page-meta`, `nav.mt-pagination` | — |
| ヒーロー | `section.mt-hero` | `h1`、リードの `p`、リンクだけの `p` (CTA ボタン。最初のリンクが主ボタン) | — |
| セクション | `section.mt-section` | `h2` とその内容 | `[data-section]` = 名前、`[data-c]` と `.mt-c-<c>` = コンポーネント、`.mt-cols-<n>`、`.mt-cta` |
| 本文 (`sections:` なし) | `div.mt-prose` | レンダリングされた本文 | — |
| カードグリッド | `section.mt-section` | `ul > li`、先頭の `strong` がタイトル | `.mt-cols-2`, `.mt-cols-3` (`c: features`) |
| タブ | `section.mt-c-tabs[data-tabs]` | `[role=tablist]`, `[role=tab]`, `[role=tabpanel]` (JS が生成。JS がなければ `h3` とコードブロックのまま) | `[aria-selected]` |
| アコーディオン | `section.mt-c-accordion` | `h3 > button[aria-expanded]`、その後のパネル | `[aria-expanded=true\|false]` |
| ステップ / タイムライン | `section.mt-c-steps`, `section.mt-c-timeline` | `ol > li` または `h3` の項目 | — |
| アラート | `blockquote.mt-callout[role=note]` | `p.mt-callout-title`、本文 | `.mt-callout-<type>`, `[data-variant]` = note, tip, important, warning, caution |
| バッジ | `span.mt-badge` | 記号 (`aria-hidden`)、ラベル | `.mt-badge-<status>`, `.mt-badge-tag`, `.mt-badge-since`, `[data-variant]` |
| キーボードのキー | `kbd.mt-kbd` | キーごとの `kbd` | — |
| 図 | `figure.mt-figure` | `img`, `figcaption` | — |
| 投稿のメタ情報 | `p.mt-post-meta` | `time`, `.mt-post-author`、タグバッジ | — |
| 検索 | `div.mt-search[role=search]` | 入力欄、`.mt-search-results` | — |

ページの枠、ドキュメント、ヒーロー、セクション、本文、アラート、バッジの要素には、2.0 まで非推奨の `md-*` クラスも付きます ([移行とアップグレード](../upgrade/)を参照)。

## 1.0 に含まれないもの

- `_data/components.yml` のパラメーター検査を超えるコンポーネントごとのスロット契約は 1.x で予定しています。
- 右から左へのレイアウト、数式、図は 1.0 の目標ではありません。[ロードマップ](../roadmap/)を参照してください。
