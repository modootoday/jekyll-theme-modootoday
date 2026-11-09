---
lang: ja
permalink: /ja/layouts/docs-extra/reference/
source_rev: sha256:c3632f2ca43c
nav_order: 1
title: "リファレンスのデモ"
layout: reference
description: コマンドラインインターフェースをコマンドごとに説明します。項目ごとにシグネチャ、短い説明、わかる場合は追加されたバージョンがあり、必要なコマンドをすぐ見つけられます。
twin: false
edit: false
sections: []
members:
  - {name: build, signature: "modootoday build [--drafts]", text: "サイトを `_site` にビルドします。", since: "3.0"}
  - {name: serve, signature: "modootoday serve [--port N]", text: "サイトをビルドして配信し、変更があれば再ビルドします。"}
  - {name: check, signature: "modootoday check [DIR]", text: "ページをレイアウトの契約と照らし合わせて検査します。", since: "3.2"}
---
すべてのオプションはコマンドに `--help` を付けて確認してください。
