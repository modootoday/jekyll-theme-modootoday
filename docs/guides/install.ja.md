---
lang: ja
permalink: /ja/guides/install/
source_rev: sha256:fbba74ee43c3
nav_order: 10
title: インストール
description: GitHub Pages または Jekyll 4 のサイトにテーマを追加します。
sections:
  - requirements
  - {c: tabs, name: methods}
  - minimal
  - check
  - starters
---
# インストール

いま使っているビルド方法を選んでください。三つとも同じ Markdown を読みます。

> [!NOTE]
> このページは[英語の原文](../../../guides/install/)の翻訳です。内容が異なる場合は英語版が優先されます。

## 動作要件

- `remote_theme` を使う GitHub Pages: 従来のビルド (`github-pages` 232、Jekyll 3.10)。
- テーマの gem を使う Jekyll 4.4、Ruby 3.3 または 3.4。
- テストしている最も古い Jekyll は 3.9 です。

## 方法を選ぶ

### GitHub Pages

```yaml
# _config.yml（ローカルでのビルドは github-pages gem のタブを参照）
remote_theme: modootoday/jekyll-theme-modootoday@v1.6.0
plugins: [jekyll-remote-theme]
```

### Jekyll 4

```ruby
# Gemfile
source "https://rubygems.org"
gem "jekyll", "~> 4.4"
gem "jekyll-theme-modootoday", "~> 1.6"
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
sass: {silence_deprecations: [import, global-builtin]}   # Jekyll 4: Dart Sass の @import の通知を抑える
defaults:
  - {scope: {path: ""}, values: {layout: doc}}
```

> [!TIP]
> `remote_theme` を使う場合は、`theme:` の行を GitHub Pages タブにある `remote_theme` の 2 行に置き換えてください。
>
> このサイトを手元の github-pages gem でビルドするには、`repository: <owner>/<name>`（GitHub のリポジトリ）も追加するか、環境変数 `PAGES_REPO_NWO=<owner>/<name>` を設定します。どちらもなく、GitHub の `origin` リモートがあるクローンの外でビルドすると、「No repo name found. Specify using PAGES_REPO_NWO environment variables, 'repository' in your configuration, or set up an 'origin' git remote pointing to your github.com repository.」というエラーで止まります。GitHub Pages ではこの値が自動で設定されます。

`sass:` の行は、Jekyll 4 のビルドで `@import` に関する Dart Sass の通知が何千行も出力されないようにします。出力結果はどちらでも同じです。

## ビルドを確認する

`--twins` は、テーマが AI エージェント向けに公開するファイルも確認します（[AI エージェント](../agents/)）。ページごとの Markdown 版と、`llms.txt`、`llms-full.txt` です。Jekyll 4 では `plugins: [jekyll-theme-modootoday]` を追加すると、ビルドが作ります。従来の GitHub Pages では、`modootoday-stubs . --twins --write` を一度実行して各ページの横に Markdown 版のスタブを追加し、サイトのルートに front matter だけを書いた 2 つのファイルを置きます。`layout: llms` の `llms.txt` と `layout: llms-full` の `llms-full.txt` です。エラーページ（`404.md` などの `layout: error`）には Markdown 版を作りません。ほかに Markdown 版が要らないページには `twin: false` を付けます。Markdown だけを確認するには `--twins` を外します。

```sh
bundle exec jekyll build
bundle exec modootoday-check . _site --twins
```

チェッカーは、github.com で同じように表示されない記法をすべて報告します。

`remote_theme` のサイトは Gemfile にテーマがないため、`bundle exec modootoday-check` は使えません。テーマのタグと同じマイナーバージョンで gem を一度インストールし、ビルドしたサイトにチェッカーを実行します。

```sh
gem install jekyll-theme-modootoday -v '~> 1.6'
modootoday-check . _site --twins
```

シェルが `modootoday-check` を見つけられない場合は、gem の bin ディレクトリーが `PATH` にありません。`ruby -S modootoday-check . _site --twins` で実行します。`can't find gem jekyll-theme-modootoday (Gem::GemNotFoundException)` で止まる場合は、`PATH` 上のスクリプトが別の gem の場所（別の Ruby、またはバージョン管理ツールが設定した `GEM_HOME`/`GEM_PATH`）のものです。`gem install` が使った場所を Ruby に伝えます。

```sh
GEM_PATH="$(gem env gemdir)" ruby -S modootoday-check . _site --twins
```

gem をインストールしない場合は、リリースのソースからチェッカーを実行します。必要なのは Ruby だけです。

```sh
curl -sL https://github.com/modootoday/jekyll-theme-modootoday/archive/refs/tags/v1.6.0.tar.gz | tar xz -C /tmp
ruby /tmp/jekyll-theme-modootoday-1.6.0/exe/modootoday-check . _site --twins
```

`remote_theme` の行に書いたタグを使います。

GitHub Actions では、ビルドの次のステップに同じ 2 行を入れます。例: `run: gem install jekyll-theme-modootoday -v '~> 1.6' && modootoday-check docs docs/_site --twins`。

`github-pages` gem が出す次の 2 つの警告は問題ありません。`To use retry middleware with Faraday v2.0+, install faraday-retry gem` が出てもリモートテーマは正しく取得されます。`@import` に関する Sass の通知は、GitHub Pages の Sass が `sass: silence_deprecations` の設定を読まない古い版のため、`_config.yml` で設定しても表示されます。どちらの場合もビルド結果は正しいです。

## スターターサイト

テーマには 3 つのスターターサイトがあり、どれもライブデモ付きの GitHub のテンプレートリポジトリです。[docs](https://github.com/modootoday/jekyll-theme-modootoday-docs-starter)（ガイド、データから作るページ、`ko/` と `ja/` の韓国語と日本語）、[blog](https://github.com/modootoday/jekyll-theme-modootoday-blog-starter)（投稿、ニュース記事、著者ページ、フィード）、[landing](https://github.com/modootoday/jekyll-theme-modootoday-landing-starter)（ヒーロー、料金、規約ページ）です。どれかから始めるには、そのリポジトリで **Use this template** を選び、GitHub Pages のソースを GitHub Actions にします。コピーは `remote_theme` でテーマを読み込み、`Gemfile`、`README.md`、スタブ、そしてサイトをビルドし `modootoday-check` を実行してからデプロイする Pages ワークフローが入っています。`_config.demo.yml` も入っていますが、これはそのスターター自身のライブデモの設定（[ショーケース](../../reference/showcase/)のバーまたはピルと `noindex`）です。ワークフローはスターター自身のリポジトリでだけこの設定をビルドに重ねるので、コピーはこの設定なしでビルドされます。ファイルは削除してもかまいません。テーマの gem を使う Jekyll 4 で始めるには、テーマのリポジトリを `--recurse-submodules` 付きでクローンした場所で `bundle exec rake starters:render` を実行し、`pkg/starters/jekyll4/<name>/` をコピーします。
