---
lang: ja
permalink: /ja/recipes/updates/
source_rev: sha256:9904f084ca96
nav_order: 28
title: 読者に更新を知らせる
description: フィード、GitHub のリリース通知、メールフォーム、インストールしたアプリの案内で読者がサイトの変更を追えるようにし、リリースを公開したらサイトを再ビルドする方法を説明します。
---
# 読者に更新を知らせる

> [!NOTE]
> このページは[英語の原文](../../../recipes/updates/)の翻訳です。内容が異なる場合は英語版が優先されます。

静的サイトは自分から読者に連絡できません。そこでテーマは、読者が好きなときにお知らせを受け取る方法を用意しています。読者に合うチャネルを選んでください。どのチャネルもほかのチャネルなしで動きます。

| チャネル | 向いている読者 | 用意するもの |
|---|---|---|
| Atom フィード | フィードリーダーを使う読者と、サイトを監視するツール | 言語ごとに `feed.xml` ページを一つ |
| GitHub のリリース通知 | GitHub でプロジェクトを使う人 | GitHub にリリースを公開すること以外はありません |
| メールフォーム | 新しい版が出たらメールを受け取りたい読者 | `c: subscribe` セクションとメールサービス |
| 更新の案内 | インストールしたアプリの読者 | `modootoday.pwa` |
| リリースのバー | すべての訪問者、すべてのページ | `banner: {release: latest}` |

## フィード

サイトのルートと言語フォルダーごとに `layout: feed` の `feed.xml` ページを追加します。フィードはテーマが自分で書くので、プラグインは要りません。`modootoday.feed: true` にすると、すべてのページの head がその言語のフィードにリンクするので、フィードリーダーはどのページのアドレスからでもフィードを見つけます。ブログ、著者、アーカイブのページは、自分のフィードへの購読リンクも表示します(front matter の `feed:`)。[著者とフィード](../../layouts/blog-news/#著者とフィード)を参照してください。フィードはサイトにあるファイルなので、だれも登録せず、だれが読んでいるかもわかりません。

変更履歴のページにも、リリースごとに一つの項目がある専用のフィードを作れます。`layout: feed` と `feed_source:` を書いた `changelog.xml` を作り、変更履歴のページから `feed:` でリンクします。二つのファイルはドキュメント拡張の[変更履歴](../../layouts/docs-extra/#変更履歴)を参照してください。

GitHub にリリースを公開すると、GitHub は `https://github.com/OWNER/REPO/releases.atom` にリリースのフィードを置きます。リリースだけを受け取りたい読者のために、変更履歴やダウンロードのページの front matter に `releases_feed: true` を書くと、このフィードにリンクします。

## GitHub のリリース通知

GitHub のアカウントがある読者は、リポジトリで Watch、Custom の順に選び、Releases にチェックを入れられます。すると GitHub は、リリースを公開するたびに、読者が[通知設定](https://docs.github.com/ja/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/configuring-notifications)で決めたとおり GitHub かメールで知らせます。インストールや変更履歴のページにこの方法を書いておいてください。

## メールフォーム

`c: subscribe` セクションは本文と、メールサービス(`modootoday.subscribe.action`)に送るメールフォームを出力します。アドレスを保管してメールを送るのはサービスで、テーマはフォームを描くだけです。[購読](../../components/#購読)を参照してください。

## インストールしたアプリ

`modootoday.pwa` をオンにすると、開いているアプリはデプロイでテーマのファイルが変わったときに短い案内を表示し、ページは常にネットワークから先に取得します。インストールできるサイトのレシピの[更新](../pwa/#更新)を参照してください。案内はサイトを開いている読者にだけ表示され、通知ではありません。

## リリースのバー

`modootoday.banner: {release: latest}` は、すべてのページに「1.7.0 を公開しました。」とそのリリースへの「新機能」リンクを表示します。値はサイトのビルド時に `site.github` から読み、プレリリースは除かれます。サイトを再ビルドしないと変わらないので、リリースごとの再ビルド(下記)と組み合わせてください。GitHub Pages の外では代わりに `release: {version, url}` を書きます。

## プッシュがない理由

プッシュ通知には、すべての読者の購読を保管するサーバー、許可の確認、ブラウザーの提供元が運営するプッシュサービスが必要です。静的サイト向けのテーマにはサーバーがなく、どこにも何も送らないので、プッシュは提供しません。上のチャネルは自分で運営するサーバーが要らず、読者は許可を求めずにいつでも受け取りをやめられます。

## リリースを公開したら再ビルドする

GitHub Pages はプッシュしたときにサイトをビルドします。そのため、ビルドが GitHub から読むデータ(`site.github` のリリースやリポジトリの情報など)は最後のプッシュのときのままです。リリースを公開してもサイトは再ビルドされません。

スターターの Pages ワークフロー(`.github/workflows/pages.yml`)は、リリースが公開されるとデフォルトブランチを再ビルドします。`schedule` のコメントを外すとオンになる週ごとのビルドも入っています。自分の [Pages ワークフロー](https://docs.github.com/ja/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)には同じトリガーを追加してください。

```yaml
on:
  push:
    branches: [main]
  release:
    types: [published]
  schedule:
    - cron: "17 3 * * 1"   # 毎週月曜日 03:17 UTC
```

- リリースで始まった実行はリリースのタグで動き、`github-pages` 環境は通常デフォルトブランチだけにデプロイを許します。そのためスターターのワークフローは、タグをビルドせず、デフォルトブランチで自分をもう一度起動します(`gh workflow run pages.yml --ref main`。`permissions: actions: write` が必要です)。
- 公開リポジトリで 60 日間活動がないと、GitHub は予定されたワークフローを止めます。Actions タブでもう一度オンにしてください。
- GitHub がブランチからビルドするサイト(Settings、Pages、Deploy from a branch)には、トリガーを追加するワークフローがありません。リリースのあとにコミットをプッシュするか、Pages のソースを GitHub Actions に切り替えてください。
