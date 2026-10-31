---
nav_order: 10
nav_title: 導入
title: インストール
description: GitHub Pages または Jekyll 4 のサイトにテーマを追加します。
sections:
  - {c: tabs, name: methods}
  - minimal
  - check
  - {c: cta, name: next}
---
# インストール

いま使っているビルド方法を選んでください。三つとも同じ Markdown を読みます。

> [!NOTE]
> このページは[英語の原文](../../../guides/install/)の翻訳です。内容が異なる場合は英語版が優先されます。

## 方法を選ぶ

### GitHub Pages

```yaml
# _config.yml (classic GitHub Pages build, no Gemfile needed)
remote_theme: modootoday/jekyll-theme-modootoday@v1.4.1
plugins: [jekyll-remote-theme]
```

### Jekyll 4

```ruby
# Gemfile
source "https://rubygems.org"
gem "jekyll", "~> 4.4"
gem "jekyll-theme-modootoday", "~> 1.4"
```

### github-pages gem

```ruby
# Gemfile (reproduce GitHub Pages locally)
source "https://rubygems.org"
gem "github-pages", "~> 232", group: :jekyll_plugins
```

## 最小限の設定

pretty パーマリンクを使い、すべてのページに `doc` レイアウトを適用します。

```yaml
theme: jekyll-theme-modootoday
lang: en
permalink: pretty
markdown: kramdown
kramdown: {input: GFM}
defaults:
  - {scope: {path: ""}, values: {layout: doc}}
```

> [!TIP]
> `remote_theme` を使う場合は、`theme:` の行を GitHub Pages タブにある `remote_theme` の 2 行に置き換えてください。

## ビルドを確認する

```sh
bundle exec jekyll build
bundle exec modootoday-check . _site --twins
```

チェッカーは、github.com で同じように表示されない記法をすべて報告します。

`remote_theme` のサイトは Gemfile にテーマがないため、`bundle exec modootoday-check` は使えません。テーマのタグと同じマイナーバージョンで gem を一度インストールし、ビルドしたサイトにチェッカーを実行します。

```sh
gem install jekyll-theme-modootoday -v '~> 1.4'
modootoday-check . _site --twins
```

シェルが `modootoday-check` を見つけられない場合は、gem の bin ディレクトリーが `PATH` にありません。`ruby -S modootoday-check . _site --twins` で実行します。`can't find gem jekyll-theme-modootoday (Gem::GemNotFoundException)` で止まる場合は、`PATH` 上のスクリプトが別の gem の場所（別の Ruby、またはバージョン管理ツールが設定した `GEM_HOME`/`GEM_PATH`）のものです。`gem install` が使った場所を Ruby に伝えます。

```sh
GEM_PATH="$(gem env gemdir)" ruby -S modootoday-check . _site --twins
```

gem をインストールしない場合は、リリースのソースからチェッカーを実行します。必要なのは Ruby だけです。

```sh
curl -sL https://github.com/modootoday/jekyll-theme-modootoday/archive/refs/tags/v1.4.1.tar.gz | tar xz -C /tmp
ruby /tmp/jekyll-theme-modootoday-1.4.1/exe/modootoday-check . _site --twins
```

`remote_theme` の行に書いたタグを使います。

GitHub Actions では、ビルドの次のステップに同じ 2 行を入れます。例: `run: gem install jekyll-theme-modootoday -v '~> 1.4' && modootoday-check docs docs/_site --twins`。

`github-pages` gem が出す次の 2 つの警告は問題ありません。`To use retry middleware with Faraday v2.0+, install faraday-retry gem` が出てもリモートテーマは正しく取得されます。`@import` に関する Sass の通知は、GitHub Pages の Sass が警告を抑える設定を読まない古い版のため、`_config.yml` で設定しても表示されます。どちらの場合もビルド結果は正しいです。

## 次へ

[最初のページを書く](../first-page/) [ホームに戻る](../../)
