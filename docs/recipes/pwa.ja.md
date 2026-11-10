---
lang: ja
permalink: /ja/recipes/pwa/
source_rev: sha256:512b037912d3
nav_order: 29
title: インストールできるサイト
description: すでにある設定からウェブアプリマニフェストを作り、ブラウザーがサイトをアプリとしてインストールできるようにする方法と、アイコンや確認の手順を説明します。
---
# インストールできるサイト

> [!NOTE]
> このページは[英語の原文](../../../recipes/pwa/)の翻訳です。内容が異なる場合は英語版が優先されます。

`modootoday.pwa` をオンにすると、ブラウザーがサイトをウェブアプリとしてインストールできます。Chrome、Edge、Android はインストールボタンを表示し、iOS と macOS の Safari はサイトの名前とアイコンのままホーム画面や Dock に追加します。テーマはすでにある設定からウェブアプリマニフェストを作るので、同じ値を二度書く必要はありません。既定はオフで、この設定がないサイトは以前とまったく同じにビルドされます。

## オンにする

```yaml
modootoday:
  favicon: brand
  pwa:
    enabled: true
    short_name: Docs   # アイコンの下に出る名前。12 文字以内に
```

リモートテーマはサイトのルートにファイルを追加できないため、小さなファイルを 1 つリポジトリに置きます。gem に入っているスタブ作成ツールで書き出します。

```sh
modootoday-stubs . --pwa           # 書き出すファイルを一覧表示
modootoday-stubs . --pwa --write   # manifest.webmanifest を書き出す
```

`manifest.webmanifest` には front matter と include が 1 つだけ入っています。このファイルをコミットしてください。すべてのページが `<link rel="manifest">` でこのファイルをリンクします。サイトをビルドして `modootoday-check . _site` を実行すると、設定、ファイルが存在して最新か、ビルドされたマニフェストとアイコン、全ページのリンクを確認します。

作成ツールはこのファイルを削除せず、同じパスに自分で作ったファイルがあれば上書きせずに終了コード 3 で止まります。

## マニフェストに入る値

| マニフェストのフィールド | 取得元 |
|---|---|
| `name` | `pwa.name`、なければサイトの `title` |
| `short_name` | `pwa.short_name`、なければ名前。ホーム画面は 12 文字程度より長い名前を切り詰め、`modootoday-check` が警告します。 |
| `description` | `pwa.description`、なければサイトの `description` |
| `lang`、`dir` | サイトの既定言語(`lang:`)とその書字方向 |
| `start_url`、`id` | `pwa.start_url`。`/guides/` のようなサイト内のパス(既定は `/`)の前に `baseurl` を付けた値。クエリ文字列は使えないため、アプリがトラッキング用パラメーター付きで開くことはありません。 |
| `scope` | 常に `baseurl` を付けたサイトのルート(例: `/docs/`)。設定キーではありません。 |
| `display` | `pwa.display`: `standalone`(既定、アドレスバーのないウィンドウ)、`minimal-ui`、`browser` |
| `theme_color` | `modootoday.theme_color`。ブラウザーのバーのタグと同じ色で、ライトの値、`color_scheme: dark` ではダークの値。`theme_color: false` では入りません。 |
| `background_color` | `pwa.background_color`(16 進数の色)、なければページの背景: `#ffffff`、`color_scheme: dark` では `#0a0a0a` |
| `icons` | `pwa.icons`: `brand`(既定)または独自のリスト |

## アイコン

`icons: brand` は `favicon: brand` と同じくテーマのマークを使います。192px のアイコン、512px のアイコン、そして Android が円形に切り抜いてもマークが円の中に収まる 512px の maskable アイコンです。独自のアイコンを使うには、サイトの PNG ファイルを列挙します。

```yaml
modootoday:
  pwa:
    enabled: true
    icons:
      - {src: /assets/icons/app-192.png, sizes: 192x192}
      - {src: /assets/icons/app-512.png, sizes: 512x512}
      - {src: /assets/icons/app-maskable.png, sizes: 512x512, purpose: maskable}
```

- purpose が `any`(既定)の 192px と 512px のアイコンは必須です。どちらかがないと、ブラウザーはインストールを提案しません。
- `maskable` のアイコンを推奨します。絵柄は幅の 80% の中央の円に収め、正方形全体を背景で埋めてください。
- `sizes` はファイルと一致させます。`modootoday-check` はビルドされたサイトから各 PNG の実際のサイズを読み取ります。
- `favicon` が `brand` でないのに `icons` を設定しないと、アプリにテーマのマークが表示されるという警告が出ます。`icons:` に独自のアイコンを書くか、そのまま使うなら `icons: brand` と書きます。

Apple のタッチアイコンは以前と同じく `favicon` から来ます。Safari 16.4 以降もマニフェストを読みます。

## インストールできるか確認する

1. サイトをビルドし、HTTPS か `localhost` で開きます。
2. Chrome のデベロッパーツールを開き、Application、Manifest に進みます。インストールできる場合、Installability の項目には何も表示されません。
3. 公開する前に `modootoday-check . _site --strict` を実行します。

シークレットウィンドウでは Chrome は常にインストールできないと報告します。通常のウィンドウで確認してください。

## 端末に残るもの

インストールで増えるのはショートカットとアプリのウィンドウだけで、マニフェスト自体は何も保存しません。テーマはどこにもデータを送らず、分析ツールを加えず、インストールの案内を自分から出しません。インストールを提案するタイミングはブラウザーが決めます。訪問者はほかのアプリと同じく、ブラウザーのアプリ一覧やホーム画面からアプリを削除します。

## コンテンツセキュリティポリシー

マニフェストはサイト自身のファイルなので、`default-src 'self'` のポリシーで許可されます。ポリシーの `default-src` がそれより狭い場合は `manifest-src 'self'` を加えます。[CSP](../csp/) を参照してください。
