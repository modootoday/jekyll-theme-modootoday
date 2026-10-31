---
title: "API リファレンスのデモ"
description: "グループ分けしたサイドバーとパッケージ表を備えたライブラリのリファレンスです。"
layout: reference
nav_order: 8
twin: false
edit: false
sections: []
sidebar: true
packages_title: "パッケージ"
members:
  - {name: "build", group: "CLI", signature: "modootoday build [--drafts]", text: "サイトを `_site` にビルドします。"}
  - {name: "serve", group: "CLI", signature: "modootoday serve [--port N]", text: "サイトをビルドして配信し、変更があれば再ビルドします。"}
  - {name: "Site.load", group: "ライブラリ", signature: "Site.load(path) -> Site", text: "`path` 以下の設定とページを読み込みます。"}
  - {name: "Site#render", group: "ライブラリ", signature: "site.render(page) -> String", text: "1 つのページを HTML に変換します。"}
  - {name: "Page#data", group: "ライブラリ", signature: "page.data -> Hash", text: "ページの front matter です。"}
packages:
  - {name: "modootoday-core", version: "1.4.0", text: "解析、変換、ページモデル。", url: "#", links: [{label: "ドキュメント", url: "#"}, {label: "ソース", url: "#"}]}
  - {name: "modootoday-cli", version: "1.4.0", text: "`modootoday` コマンド。", url: "#", links: [{label: "ドキュメント", url: "#"}, {label: "ソース", url: "#"}]}
  - {name: "modootoday-lint", version: "0.9.2", text: "ページをレイアウトの約束事と照らし合わせて検査します。", url: "#", links: [{label: "ドキュメント", url: "#"}, {label: "ソース", url: "#"}]}
---
サイドバーはメンバーを `group:` でまとめ、表はライブラリを構成するパッケージを示します。

> [!TIP]
> 表とメンバーの説明がずれないよう、パッケージは同じマイナーバージョンに固定してください。
