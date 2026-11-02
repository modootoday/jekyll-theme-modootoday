---
title: 厳格な CSP のデモ
description: コアコンポーネントを 1 ページに集め、厳格な Content Security Policy で確認します。
twin: false
sitemap: false
edit: false
nav_exclude: true
sections:
  - alerts
  - {c: tabs, name: tabs}
  - {c: accordion, name: accordion}
  - {c: steps, name: steps}
  - {c: faq, name: faq}
  - figure
  - tables
  - code
  - inline
---
# 厳格な CSP のデモ

このページには、コアコンポーネント、コード、表、図があります。ドキュメントの QA はこのページを厳格な `Content-Security-Policy` ヘッダー付きで返し、違反が 1 件でもあれば失敗します。[Content Security Policy](../../../recipes/csp/) を参照してください。

- 素の Markdown
- インラインのスクリプトとスタイルなし

[CSP のレシピを読む](../../../recipes/csp/) [パフォーマンス](../../../guides/performance/)

## アラート

> [!NOTE]
> アラートはクラス付きの引用で、インラインの要素はありません。

> [!WARNING]
> アラートには `inline code` や[レイアウトのデモ](../)へのリンクを入れられます。

## タブ

### npm

```sh
npm install
```

### gem

```sh
gem install jekyll-theme-modootoday
```

## アコーディオン

### アコーディオンにインラインスクリプトは必要ですか

いいえ。`accordion.js` は `assets/js/` の下にあるファイルです。

### ここでもコピーボタンは動きますか

はい。ページにコードブロックがあるので `code-copy.js` を読み込みます。

## 手順

1. サイトをビルドします。
2. ポリシーを付けてサイトを配信します。
3. 違反の件数を数えます。

## FAQ

### どのポリシーですか

`default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:` に `worker-src` と `manifest-src` を加えたポリシーです。

## 図

![左の Markdown のソースが、右ではスタイルの付いたページになります](../../../../assets/images/sample.svg)

*SVG の図は、インラインスタイルなしでフォーカスできる領域の中でスクロールします。*

## 表

| 項目 | 読み込み元 | インライン |
|---|---|---|
| テーマの CSS | `assets/css/` | いいえ |
| テーマのスクリプト | `assets/js/` | いいえ |
| ペイント前スクリプト | `csp: strict` のときの `theme-init.js` | いいえ |

## コード

`file:_config.yml`

```yaml
modootoday:
  csp: strict
```

## インライン

バッジ `status:available` `tag:beta`、キー `kbd:Ctrl+K`、進捗 `progress:60`、スピナー `loading:spinner`。
