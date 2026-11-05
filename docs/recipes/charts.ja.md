---
lang: ja
permalink: /ja/recipes/charts/
source_rev: sha256:5fa88f046dfa
nav_order: 26
title: グラフ
description: Markdown の表をグラフの figure にしたり、データファイルをグラフとして表示したりします。表はすべての読者が受け取るテキストとして残ります。
---
# グラフ

> [!NOTE]
> このページは[英語の原文](../../../recipes/charts/)の翻訳です。内容が異なる場合は英語版が優先されます。

グラフは Markdown の表から始まります。テーマは表をグラフの figure（`figure.mt-chart`）に入れ、表はその中にグラフのテキストとして残ります。そのため、JavaScript を使わない読者、スクリーンリーダー、github.com、ページの Markdown 版、`llms-full.txt` のどれもが数値を受け取れます。グラフのスクリプトが figure を描くまでは、読者には表が表示されます。

## グラフを有効にする

```yaml
modootoday:
  chart: {enabled: true}
```

この設定がないと、`chart:` のコードスパンはこれまでどおりコードスパンのままで、`modootoday-check` はまだグラフではないと警告します。

## 表から作るグラフ

表の直前に `chart:<type>` だけの行を置き、直後にキャプションになる強調だけの行を置きます。

```markdown
`chart:bar stacked`

| Quarter | Docs | Blog |
|---|---|---|
| Q1 | 4,160 | 2,030 |
| Q2 | 5,270 | 2,770 |

*Visits per quarter*
```

- 最初の列はラベル、見出し行は系列の名前です。それ以外のセルは数値で、`,` と `%` は無視します。
- 種類は `bar`、`line`、`area`、`pie`、`doughnut` のいずれかです。
- オプションは種類の後に空白で区切って続けます。`stacked` は系列を積み上げ、`horizontal` は棒を横向きにします。

[キッチンシンク](../../components/kitchen-sink/#グラフ)に例があります。

## データファイルから作るグラフ

`c: chart` セクションは `_data/charts/` のファイルを表示します。1 組の数値を複数のページで使えます。

```yaml
# _data/charts/traffic.yml
label: Month
labels: [Jan, Feb, Mar]
series:
  - {name: Docs, values: [1200, 1350, 1610]}
  - {name: Blog, values: [640, 700, 690]}
```

```yaml
sections:
  - {c: chart, name: traffic, type: line, data: traffic}
```

テーマはデータをセクションの最後に表として書き出します。ラベルごとに 1 行、系列ごとに 1 列で、`label` は最初の列の見出しです。セクションのテキストが先に来て、セクションの最後の段落が強調だけならキャプションになります。ラベルと系列の名前はテキストなので、言語ごとにファイルを分け（`traffic-ja.yml`）、翻訳ページからそのファイルを指定します。`stacked: true` と `horizontal: true` は上のオプションと同じです。

`data:` のない `c: chart` セクションは代わりに最初の表を使い、キャプションも上と同じ方法で付きます。グラフのセクションは名前でグラフを求めるので、`modootoday.chart.enabled` が無効でも表をグラフの figure にします。

## 色

figure には配色ごとに 8 つの系列の色があり、どれもページの背景と 3:1 以上のコントラストがあります。ブランドの色を使うには、サイトのスタイルシートでフックを設定します。

```css
:root {
  --mt-chart-1: #0f766e;
  --mt-chart-2: #b45309;
}
```

`--mt-chart-1` から `--mt-chart-8` は系列、`--mt-chart-grid` はグリッド線、`--mt-chart-text` は軸のテキストです。テーマはこれらを設定しないので、設定した値は両方の配色に適用されます。ダークの配色だけを変えるには、サイトのダーク配色のセレクターの下でもう一度設定します。

## チェッカーが報告すること

`modootoday-check` は、不明な種類やオプション、直後に表がない `chart:` の行、表と `data:` の両方がある、またはどちらもない `c: chart` セクション、存在しないデータファイル、系列の値の数がラベルの数と合わないデータファイルをエラーとして報告します。数値でないセルや値は警告です。グラフを有効にしたとき、ビルド結果に `chart:` だけの段落が残っていればエラーです。
