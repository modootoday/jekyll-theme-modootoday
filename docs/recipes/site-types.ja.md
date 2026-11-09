---
lang: ja
permalink: /ja/recipes/site-types/
source_rev: sha256:5bd64dd18a0c
title: サイトの種類
description: 製品、会社、ドキュメント、個人、コミュニティのサイトをどのレイアウトで作るか、そしてどのサイトにも必要なシステムページを 1 ページにまとめます。
nav_order: 30
---
# サイトの種類

各節では、1 種類のサイトを作るレイアウトとその組み合わせ方を説明します。節ごとにリンクしたレイアウトのグループに、すべての front matter のキーとレイアウトごとのライブデモがあります。

## 製品サイト

`/` を `feature` ページにし、`actions:` で `/pricing/` と `/download/` にリンクします。料金プランは 1 つの `pricing` ページにまとめ、`download` の `version` と `date` はリリースに合わせて設定し、フッターから `brand` ページにリンクします。4 ページは `modootoday-marketing.css` を共有するので、訪問者が読み込むのは 1 回だけです。

レイアウト: `feature`, `pricing`, `download`, `brand`。[マーケティングページ](../../layouts/marketing/)にあります。

## 会社のページ

人は `team`、採用は `jobs` と募集ごとの `job` ページ、連絡方法は `contact`、規約とプライバシーは `effective` の日付を付けた `legal` で作ります。サイトの `publisher` を 1 度設定すれば、すべてのページの構造化データが同じ Organization を指します。

レイアウト: `team` と `jobs` は[ディレクトリレイアウト](../../layouts/directory/)、`job` は[詳細ページ](../../layouts/detail/)、`contact` は[マーケティングページ](../../layouts/marketing/)、`legal` は[文書](../../layouts/documents/)にあります。

## ドキュメントサイト

ドキュメントのホームはセクションごとにカードを 1 枚置いた `hub` にします。`reference` の members は CLI や API から生成し、リリースごとに `changelog` に追記し、共通の言葉は 1 つの `glossary` にまとめてガイドから `/glossary/#term` でリンクします。これらのページは `modootoday-docs-extra.css` を読み込み、ガイドのページは基本のシートだけを使います。

レイアウト: `hub`, `reference`, `changelog`, `glossary`。[ドキュメント拡張](../../layouts/docs-extra/)にあります。

## 個人サイト

`/` に `links` ページ、`/cv/` に `resume`、作品は `portfolio` と `project` ページに置きます。リンクページと履歴書で同じ `display_name` を使えば、2 つの ProfilePage が 1 人の Person を表します。履歴書はブラウザーから印刷するときれいな PDF になります。

レイアウト: `links` は[マーケティングページ](../../layouts/marketing/)、`resume` は[文書](../../layouts/documents/)、`portfolio` は[ディレクトリレイアウト](../../layouts/directory/)、`project` は[詳細ページ](../../layouts/detail/)にあります。

## コミュニティサイト

集まりは `events` とイベントごとの `event` ページで並べ、計画は `now`、`next`、`later` に分けた `roadmap` で共有し、支援者には `sponsors` で感謝を伝えます。ロードマップの項目を Issue にリンクすると、読者が進み具合を追えます。

レイアウト: `events` と `sponsors` は[ディレクトリレイアウト](../../layouts/directory/)、`event` は[詳細ページ](../../layouts/detail/)、`roadmap` は[ドキュメント拡張](../../layouts/docs-extra/)にあります。

## システムページ

`layout: error` で `404.md` を追加し、移動したページには `redirect` を使い、検索には `layout: search` の専用ページを置きます。これらのページは小さな `pages` 任意シートを使います。エラーページには `sitemap: false` を付けてサイトマップから外してください。エラーページには Markdown 版がなく `llms.txt` にも載らないため、`modootoday-check --twins` はスタブなしで通ります。

レイアウト: `error`, `redirect`, `search`。[ページシェル](../../layouts/shells/)にあります。
