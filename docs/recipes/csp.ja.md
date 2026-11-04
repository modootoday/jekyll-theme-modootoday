---
lang: ja
permalink: /ja/recipes/csp/
source_rev: sha256:ac360e7da233
nav_order: 20
nav_title: CSP
title: Content Security Policy
description: unsafe-inline なしの厳格な CSP でテーマを動かします。
---
# Content Security Policy

> [!NOTE]
> このページは[英語の原文](../../../recipes/csp/)の翻訳です。内容が異なる場合は英語版が優先されます。

テーマは CSS とスクリプトを `assets/` 配下のファイルから読み込みます。既定でインラインになるものは二つです。

| インラインの項目 | 条件 | 厳格にする方法 |
|---|---|---|
| ペイント前のテーマスクリプト (誤った配色が一瞬表示されるのを防ぐ) | `theme-toggle` が有効で `color_scheme: auto` | `modootoday.csp: strict` で、代わりに `assets/js/modootoday/chrome/theme-init.js` をブロッキングスクリプトとして読み込む |
| `<style id="mt-tokens">` | `modootoday.tokens` または `tokens_dark` を設定している | 値をトークンブリッジ (`_sass/modootoday/_site.scss`、[ブランドトークン](../brand-tokens/)を参照) に移し、キーを削除する |

両方に対応すれば、次のポリシーで動きます。

```text
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:
```

`:---`、`:---:`、`---:` で揃えた表の列は例外です。kramdown は揃え方を `style` 属性として書き出し、このポリシーはそれをブロックします。そのため、その列は既定の揃え方に戻り、ブラウザーは違反を報告します。このポリシーで配信するページでは、列の揃えを使わないでください。

GitHub Pages はレスポンスヘッダーを送れません。これらのディレクティブなら、`_includes/head-custom.html` に置いた `<meta http-equiv="Content-Security-Policy">` タグで機能します。インラインスクリプトを残す場合は、代わりにハッシュで許可してください。ハッシュはスクリプトが変わったときだけ変わり、その際は `CHANGELOG.md` で告知します。

テーマのドキュメント QA は、[厳格な CSP のデモ](../../layouts/demo/csp/)をはじめとするサンプルページをこのポリシーをレスポンスヘッダーに付けて返し、違反が 1 件でもあれば失敗します。

このポリシーのもとで数式や図を追加するには、[数式と図](../math-diagrams/)を参照してください。
