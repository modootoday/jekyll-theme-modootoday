---
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
> このページは[英語の原文](../../install/)の翻訳です。内容が異なる場合は英語版が優先されます。

## 方法を選ぶ

### GitHub Pages

```yaml
# _config.yml (classic GitHub Pages build, no Gemfile needed)
remote_theme: modootoday/jekyll-theme-modootoday@v0.5.0
plugins: [jekyll-remote-theme]
```

### Jekyll 4

```ruby
# Gemfile
source "https://rubygems.org"
gem "jekyll", "~> 4.4"
gem "jekyll-theme-modootoday", "~> 0.5"
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

## 次へ

[最初のページを書く](../first-page/) [ホームに戻る](../)
