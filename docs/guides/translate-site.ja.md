---
lang: ja
permalink: /ja/guides/translate-site/
source_rev: sha256:a6aa3012649d
nav_order: 85
title: サイトを翻訳する
description: 自分のサイトを複数の言語で公開する手順を、言語の一覧、ページの翻訳、言語ごとのホームページとメニューから、欠けた翻訳や古い翻訳を見つける検査まで順にまとめます。
---
# サイトを翻訳する

> [!NOTE]
> このページは[英語版](../../../guides/translate-site/)の翻訳です。内容が異なる場合は英語版が優先されます。

このページはサイトの作者向けです。テーマ自体のドキュメントや UI の文言を翻訳するときは[翻訳ルール](../translation/)を読んでください。各手順の詳しいルールは[設定](../configuration/#言語)にあります。

## 手順

1. `_config.yml` に言語を書きます。`lang:` は既定の言語で、`languages` には `[en, ko]` のようにサイトのすべての言語を書きます。検索エンジンに翻訳を知らせる `hreflang` リンクは、`url:` もあるときだけ作られます。GitHub Pages はこの値を補い、それ以外のビルドでは `_config.yml` に書く必要があります。テーマのラベルはすでに 23 の言語で用意されているので、コピーするものはありません。
2. 各ページを Markdown で翻訳します。原文の隣に置くか(`guides/start.md` の隣の `guides/start.ja.md`、`lang: ja` と `permalink: /ja/guides/start/`)、言語のフォルダーに置きます(`ja/guides/start.md`、`path: ja` に `lang: ja` を与える `defaults` のスコープ)。パスが異なるページどうしは同じ `ref:` を書きます。
3. 言語ごとに `/<lang>/` にホームページを置きます。たとえば `lang: ja` と `permalink: /ja/` を書いた `index.ja.md` です。言語メニューは、翻訳がないページから読者をここへ案内します。
4. `language_switcher: header` または `footer` で言語メニューを有効にします。
5. `tabs.label` のようにサイトに属するラベルは、言語ごとに `_data/i18n/<lang>.yml` に置きます。テーマのラベルの言い回しを変えたいときもここに置きます。点でつないだ名前は入れ子のキーです。`tabs.label` は `tabs: {label: ...}` と書きます。[設定](../configuration/#言語)のカタログの例と同じです。
6. すべてのページを翻訳する言語を `full_languages` に書き、ビルドのたびに下の検査を実行します。翻訳がないページと、`source_rev` がない翻訳やその後に原文が変わった翻訳を報告します。現在の `source_rev` の値も表示するので、翻訳を原文に合わせた後でその値を翻訳の front matter に書きます。`modootoday-stubs --pwa` が言語ごとに書くオフラインページには `source_rev` は要らず、検査の対象外です。

```yaml
lang: en
modootoday:
  languages: [en, ja]
  full_languages: [ja]
  language_switcher: header
```

```sh
bundle exec modootoday-check . _site --i18n-pages
```

結果は警告です。CI などで失敗として扱うには `--strict` を加えます。存在しないホームページへの言語メニューのリンクを見つけるには `--links` を加えます。
