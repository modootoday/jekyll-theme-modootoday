---
toc: false
title: ホーム
description: プレーンな Markdown のまま、GitHub・GitHub Pages・AI エージェントのどこでも読みやすいドキュメントを作ります。
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# ドキュメントはプレーンな Markdown のままで

jekyll-theme-modootoday は標準の GitHub Flavored Markdown をすっきりしたドキュメントサイトに変えます。同じファイルが github.com でも、GitHub Pages でも、AI エージェント向けの Markdown ツインとしても読みやすく表示されます。

[はじめる](install/) [コンポーネントを見る](components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## modootoday を選ぶ理由

- **標準の Markdown だけ** — アラート、表、リスト、コードブロック。ページに HTML、Liquid、kramdown 独自の記法は入りません。
- **GitHub Pages で動く** — クラシックな `github-pages` ビルド向けの Liquid だけのテーマで、それ以外では Jekyll 4 に対応します。
- **エージェントが読みやすい** — すべてのページにバイト単位で同一の Markdown ツインと `llms.txt`、`llms-full.txt` があります。

## クイックスタート

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.0.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.0"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## ドキュメントの読み進め方

1. GitHub Pages または Jekyll 4 にテーマを[インストール](install/)します。
2. プレーンな Markdown で[最初のページを書きます](first-page/)。
3. [コンポーネント](components/)と[キッチンシンク](components/kitchen-sink/)から選びます。
4. [設定](configuration/)で調整し、トークンと `_sass` で見た目を[カスタマイズ](customize/)します。
5. ツインと `llms.txt` で[エージェントが読める](agents/)ようにします。

> [!NOTE]
> このページは[英語の原文](../)の翻訳です。内容が異なる場合は英語版が優先されます。

## 今すぐ始める

[テーマをインストール](install/) [すべてのコンポーネントを見る](components/kitchen-sink/)
