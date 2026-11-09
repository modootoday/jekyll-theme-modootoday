---
lang: ja
permalink: /ja/layouts/demo/filter/
source_rev: sha256:d9a038f1e026
title: 絞り込みデモ
description: "入力して絞り込めるリストと表、表の値ごとのボタンです。セクションパラメーター filter: で絞り込みを設定する方法を、実際のページで示します。"
twin: false
sitemap: false
edit: false
nav_exclude: true
sections: [{name: tools, filter: true}, {name: plans, filter: {facet: 3}}, setup]
---
# 絞り込みデモ

リストや表の上の欄に入力してみてください。入力した語をすべて含む項目だけが残ります。大文字と小文字、2 通りの書き方のアクセント、韓国語の分かち書きは区別しません。JavaScript がなければすべての項目が表示されます。

[検索のレシピ](../../../recipes/search/)

## ツール

- **検索ボリューム**: キーワードの月間検索数
- **順位トラッカー**: ページの順位の推移
- **トレンドチャート**: 過去 1 年の関心度
- **関連キーワード**: 一緒に検索される語
- **검색량 조회**: 韓国語の項目。空白を入れずに入力しても見つかります

## プラン

| プラン | 価格 | 種類 |
|---|---|---|
| スターター | 0 | 無料 |
| チーム | 9 | 有料 |
| アーカイブ | 0 | 無料 |
| ビジネス | 29 | 有料 |

## 設定

```yaml
# front matter
sections:
  - {name: tools, filter: true}
  - {name: plans, filter: {facet: 3}}
  - setup
```

`filter: true` はそのセクションの最初のリストか表を絞り込みます。`{facet: 3}` は 3 列目の値ごとにボタンも追加します。ボタンを押すとその値の行だけが表示され、もう一度押すとすべて表示されます。`sections:` のないページでは front matter に `filter:` を書きます。絞り込みのあるページだけが `filter.js` とそのシートを読み込みます。
