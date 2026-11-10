---
lang: ja
permalink: /ja/guides/performance/
source_rev: sha256:7c8bffe2fe29
nav_order: 75
title: パフォーマンス
description: ページごとに読み込むファイル、CDN で長くキャッシュするためのバージョン付きアセット URL、CI が守るサイズ予算を説明し、サイトを軽く保つ方法を示します。
---
# パフォーマンス

> [!NOTE]
> このページは[英語の原文](../../../guides/performance/) の翻訳です。内容が異なる場合は英語版が優先されます。

テーマは、そのページが使う CSS と JavaScript だけをページに送ります。テーマのファイルにはすべてバージョン付きの URL を使うため、サイトの前段にある CDN でファイルを長くキャッシュできます。

## ページが読み込むファイル

| アセット | 読み込むページ |
|---|---|
| `assets/css/modootoday.css` (コアシート: トークン、基本要素、ヘッダー、ナビゲーション、テーマ切り替えボタン) | すべてのページ |
| コンポーネントシート (`content/code`、`chrome/doc-nav`、`content/inline`、`marketing/hero`、`content/extras`、`media/figure`、`chrome/banner`、`chrome/footer`)。コアシートのすぐ後に読み込む | 本文かページ下部がそのシートを使うページ |
| コンテキストシート (`docs/doc`、`chrome/search`、`content/loading`、`content/lists`、`structure/bleed`、`chrome/terminal`、`media/visual`、`data/filter`、`data/table`、`data/table-stack`) | レイアウトか本文がそのシートを使うページ |
| セクションシート (`tabs`、`faq`、`pricing` など) | `sections:` でそのコンポーネントを使うページ |
| `chrome/menu.js`、`chrome/theme-toggle.js`、`chrome/search-keys.js` | ヘッダー、テーマ切り替えボタン、検索インデックスがあるページ |
| `chrome/search.js`（`text/normalize.js` を含む）と `search.json` | 読者が初めて検索ボックスにフォーカスしたとき、または `/` か Ctrl+K を押したとき |
| `content/code-copy.js` | コードブロックがあるページと、ページ操作メニューがあるページ |
| `content/scroll-region.js` | コードブロックか表があるページ |
| `data/table-stack.js` | 本文に表があるページ |
| `structure/tabs.js`、`structure/accordion.js`、`blog/share.js` | タブ、アコーディオン、ブログのレイアウトを使うページ |
| `data/filter.js`（`data/filter-chips.js`、`text/normalize.js`、`dom/config.js` を先読み） | `filter:` か `filter_text:` を使うページ |
| `data/chart.js`（`data/chart-table.js`、`theme/current.js` を先読み）、サイトの Chart.js の後 | `modootoday.chart` がサイトの Chart.js（`src`）を指すとき、グラフのあるページ |
| Mermaid と KaTeX | 有効にしたとき、図か数式のブロックがあるページ |
| `pwa/register.js`(オフラインページでは `pwa/offline.js` も) | `modootoday.pwa.enabled: true` のとき、すべてのページ |
| `pwa/update-toast.js` と `chrome/toast` | サービスワーカーが新しいテーマのファイルを受け取って待っているページ、またはネットワークが切れたページ(どちらもオフライン用に保存) |
| サイトの `site_css` のシートと `preload` のヒント | すべてのページと、front matter で追加したページ |
| サイトの `scripts` のモジュール（そのシートと、モジュールが読み込むテーマのヘルパーを含む） | ヒーローかセクションが `script:` で名前を指定したページ |

`data/table-stack.js` は、`c: params` の表、`mt-table--stack` か `mt-table--dl` クラスの付いた表、そして 40rem より狭いときに収まらない表を積み重ねます。

`chrome/footer` は、`_data/nav/footer.yml`(またはページの言語の `footer-<lang>.yml`)に列があるときに読み込みます。

テーマのスクリプトは ES モジュール (`<script type="module">`) です。`defer` と同じく、ページを読み終えた後に順番に実行されるため、最初の描画を妨げません。モジュールが読み込むファイルには `<link rel="modulepreload">` が付き、1 つずつ順に取得せず一緒に取得します。クラシックスクリプトは、`csp: strict` のときにファイルから読み込む小さなペイント前テーマスクリプト (`chrome/theme-init.js`) だけです。最初の描画より前に実行する必要があるためです。`modootoday.css: bundle` にすると、すべてのシートがコアシート 1 枚にまとまります。[設定](../configuration/) を参照してください。`modootoday.pwa` をオンにすると、サービスワーカーが `pwa/worker.js` を 1 度読み込んでテーマのファイルと一緒に保存します。ページはこのファイルを読み込みません([インストールできるサイト](../../recipes/pwa/#オフラインで読む)を参照)。

## バージョン付きアセット URL

テーマのスタイルシートとスクリプトの URL には、末尾に `?v=` とテーマのバージョンが付きます (例: `modootoday.css?v=X.Y.Z`)。GitHub Pages はこのクエリを無視して同じファイルを返します。CDN はクエリもキャッシュキーに含めるため、ファイルを 1 年キャッシュしても、新しいテーマのリリースはすぐ訪問者に届きます。

| `modootoday.asset_version` | クエリ | 使う場面 |
|---|---|---|
| `theme` (既定) | `?v=X.Y.Z` | テーマのファイルがテーマのバージョンと一緒にしか変わらないとき |
| `build` | `?v=X.Y.Z-a1b2c3d` | サイトでテーマのファイル (Sass パーシャル、スクリプト) も上書きするとき |
| `false` | なし | アセットのバージョンを自分で管理するとき |

`build` は、GitHub Pages では `site.github.build_revision` のコミットを、それ以外ではビルド時刻を使います。

クエリが付くのはテーマ自身の CSS と JavaScript、`site_css` に登録したシート、そして `modootoday.scripts` の項目の `src` と `css` のファイル（ヒーローのモジュールとウィジェット）です。`theme` では自作のファイルを直しても URL が変わらないので、テーマのリリースの間にファイルが変わるなら `build` を使ってください。それ以外のスタイルシート、画像、フォントの URL は変わらず、`preload` のヒントも同じです。ヒントはページやスタイルシートが要求する URL と一致する必要があり、違うとブラウザーがファイルを二度ダウンロードします。

## CDN で長くキャッシュする

GitHub Pages は `Cache-Control: max-age=600` を返します。前段に CDN を置くなら、テーマのファイルはもっと長くキャッシュしてください。Cloudflare のキャッシュルールの例は次のとおりです。

| 項目 | 値 |
|---|---|
| 条件 | URI パスが `/assets/css/modootoday` か `/assets/js/modootoday` で始まり、クエリ文字列に `v=` がある |
| Edge TTL | 1 年、オリジンのキャッシュヘッダーを無視 |
| Browser TTL | 1 年 |
| キャッシュキー | クエリ文字列を含める (既定) |

HTML の TTL は短くしておくと、デプロイ後に新しい `?v=` がすぐ行き渡ります。

`?v=` が付くのは、ページが読み込むファイルだけです。そのファイルがインポートするモジュール (`text/normalize.js` など) と `modulepreload` のヒントには付けません。URL を一致させるためです。そのため、このルールではオリジンの 10 分のキャッシュのままになります。デプロイ後の 10 分間は、新しいモジュールがキャッシュされた古いモジュールを読み込むことがありますが、テーマはマイナーリリースの中では共有モジュールがエクスポートする名前を変えないので、そのままでも動きます。

## サイズ予算

テーマの CI は、ページを予算より重くする変更を失敗にします。

- テーマのスタイルシートとスクリプトを 1 つずつ、それぞれの上限と比べます (gzip バイト数)。上限は測った大きさに 10% を足した値で、テーマのアセット表のそのファイルの行に書いてあります。機能が大きくなっても、変わるのはその上限だけです。
- ページの種類 (ドキュメント、ランディング、ブログ、コンポーネントのページ、モジュールスクリプトのビジュアルがあるページ、リストのフィルターがあるページ、レコードのページ、グラフのページ) ごとに、1 ページが読み込む CSS と JavaScript (インポートするモジュールを含む) のうちテーマの分を、それらのファイルの上限の合計と比べます。1 ページあたり CSS 8 KiB、JavaScript 6 KiB、テーマのスタイルシート 6 枚という目標は警告として知らせるだけです (すべてのコンポーネントをわざと読み込むコンポーネントのページと、gzip で約 70 KB の Chart.js を載せるグラフのページは除きます)。
- サンプルページに[厳格な Content Security Policy](../../recipes/csp/) をかけたときの違反 0 件 ([デモ](../../layouts/demo/csp/))
