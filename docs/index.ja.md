---
lang: ja
permalink: /ja/
source_rev: sha256:02ec6874f6c3
toc: false
hero: {visual: showcase}
title: ホーム
description: プレーンな Markdown のまま、GitHub・GitHub Pages・AI エージェントのどこでも読みやすいドキュメントを作ります。
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# ドキュメントはプレーンな Markdown のままで

jekyll-theme-modootoday は標準の GitHub Flavored Markdown をすっきりしたドキュメントサイトに変えます。同じファイルが github.com でも、GitHub Pages でも、AI エージェント向けの Markdown 版としても読みやすく表示されます。

[はじめる](guides/install.ja.md) [コンポーネントを見る](components/index.ja.md) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## modoo.today テーマを選ぶ理由

- **標準の Markdown だけ** — アラート、表、リスト、コードブロック。ページに HTML、Liquid、kramdown 独自の記法は入りません。
- **GitHub Pages で動く** — クラシックな `github-pages` ビルド向けの Liquid だけのテーマで、それ以外では Jekyll 4 に対応します。
- **エージェントが読みやすい** — すべてのページに原文そのままの Markdown 版と `llms.txt`、`llms-full.txt` があります。

## クイックスタート

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.7.1
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.7"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## ドキュメントの読み進め方

1. GitHub Pages または Jekyll 4 にテーマを[インストール](guides/install.ja.md)します。
2. プレーンな Markdown で[最初のページを書きます](guides/first-page.ja.md)。
3. [コンポーネント](components/index.ja.md)と[キッチンシンク](components/kitchen-sink.ja.md)から選びます。
4. [設定](guides/configuration.ja.md)で調整し、トークンと `_sass` で見た目を[カスタマイズ](guides/customize.ja.md)します。
5. Markdown 版と `llms.txt` で[エージェントが読める](guides/agents.ja.md)ようにします。

> [!NOTE]
> このページは[英語の原文](index.md)の翻訳です。内容が異なる場合は英語版が優先されます。

## 今すぐ始める

[テーマをインストール](guides/install.ja.md) [すべてのコンポーネントを見る](components/kitchen-sink.ja.md)
