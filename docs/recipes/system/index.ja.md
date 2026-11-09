---
lang: ja
permalink: /ja/recipes/system/
source_rev: sha256:112755a408ed
title: システムページ
description: どのサイトにも必要な見つからない、エラー、移動、検索のページです。
nav_order: 80
---
# システムページ

`layout: error` で `404.md` を追加し、移動したページには `redirect` を使い、検索には `layout: search` の専用ページを置きます。これらのページは小さな pages バンドルを使います。エラーページには `sitemap: false` を付けてサイトマップから外してください。エラーページには Markdown 版がなく `llms.txt` にも載らないため、`modootoday-check --twins` はスタブなしで通ります。

レイアウト: `error`, `redirect`, `search`.
