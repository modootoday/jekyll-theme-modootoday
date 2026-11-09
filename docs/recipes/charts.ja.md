---
lang: ja
permalink: /ja/recipes/charts/
source_rev: sha256:1f9d4ced30db
nav_order: 26
title: グラフ
description: Markdown の表をグラフの figure にしたり、データファイルをグラフとして表示したりします。表はすべての読者が受け取るテキストとして残ります。
---
# グラフ

> [!NOTE]
> このページは[英語の原文](../../../recipes/charts/)の翻訳です。内容が異なる場合は英語版が優先されます。

グラフは Markdown の表から始まります。テーマは表をグラフの figure（`figure.mt-chart`）に入れ、表はその中にグラフのテキストとして残ります。そのため、JavaScript を使わない読者、スクリーンリーダー、github.com、ページの Markdown 版、`llms-full.txt` のどれもが数値を受け取れます。サイトに Chart.js を置くと、テーマが表からグラフを描き、表はその下の「グラフのデータ」の開閉ボックスに畳まれます。Chart.js がなければ、読者には表が表示されます。

## グラフを有効にする

```yaml
modootoday:
  chart:
    enabled: true
    src: /js/chart.min.js
    integrity: sha384-…
```

`src` はサイトに置いた Chart.js 4 です（[Chart.js を自分でホストする](#chartjs-を自分でホストする)を参照）。`src` がなければグラフは表のままです。`enabled` がないと、`chart:` のコードスパンはこれまでどおりコードスパンのままで、`modootoday-check` はまだグラフではないと警告します。front matter に `chart: false` を書くと、そのページのグラフは表のままです。

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

このページでは同じグラフを 4 四半期分描いています。

`chart:bar stacked`

| 四半期 | ドキュメント | ブログ |
|---|---|---|
| 第 1 四半期 | 4,160 | 2,030 |
| 第 2 四半期 | 5,270 | 2,770 |
| 第 3 四半期 | 6,020 | 3,140 |
| 第 4 四半期 | 6,480 | 3,610 |

*四半期ごとの訪問数*

[キッチンシンク](../../components/kitchen-sink/#グラフ)にほかの例があります。

## データファイルから作るグラフ

`c: chart` セクションは `_data/charts/` のファイルを表示します。1 組の数値を複数のページで使えます。

```yaml
# _data/charts/traffic.yml
label: Month
labels: [Jan, Feb, Mar]
series:
- name: Docs
  values: [1200, 1350, 1610]
- name: Blog
  values: [640, 700, 690]
```

```yaml
sections:
  - c: chart
    name: traffic
    type: line
    data: traffic
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

## Chart.js を自分でホストする

テーマは Chart.js を同梱しません。バージョンを固定したコピーを 1 つサイトに置けば、厳格なコンテンツセキュリティポリシーに何も足す必要がなく、読者のリクエストも CDN に送られません。

1. Chart.js 4 の特定のリリースの `dist/chart.umd.min.js` をダウンロードし（例: `https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js`）、`js/chart.min.js` として保存し、MIT ライセンスはその隣に `js/chart.LICENSE.txt` として置きます。ライセンスは `.txt` のファイルにしてください。GitHub Pages は front matter のない Markdown ファイルもページにするので、`chart.LICENSE.md` はページになり、`modootoday-check` がそれを報告します。
2. ハッシュを計算します: `openssl dgst -sha384 -binary js/chart.min.js | openssl base64 -A`
3. `src: /js/chart.min.js` と `integrity: sha384-<そのハッシュ>` を設定します。

CDN も使えます。その場合 `src` はバージョンを固定した https URL で、`integrity` は必須（ないと何も読み込みません）、CDN のオリジンを `script-src` に加える必要があり、読者の IP アドレスが CDN に送られます。`modootoday-check` は両方の形を検査し、それ以外の外部スクリプトを読み込むページを失敗にします。

Chart.js（gzip で約 70 KB）とテーマのグラフモジュールは、グラフのあるページでだけ、ページの解析後に読み込むので、最初の表示を遅らせません。

## 読者が受け取るもの

- グラフは `role="img"` の `canvas` で、キャプションが名前になります（キャプションがなければ系列の名前）。表は figure の中に「グラフのデータ」の開閉ボックスとして畳まれて残り、スクリーンリーダーやキーボードでほかの開閉ボックスと同じように開けます。アクセシブルな名前にはグラフの名前が付き（「グラフのデータ（訪問）」）、二つのグラフの名前が同じなら番号が付くので、ページ内の開閉ボックスを区別できます。
- 色、グリッド線、軸のテキストは上のフックから取り、再読み込みなしでテーマの切り替えとシステムの配色に従います。折れ線グラフは系列ごとに破線の形も変えるので、色を見分けにくい場合も系列を区別できます。凡例も系列ごとに、その破線の短い線で示します。
- システムで視差効果を減らす設定にすると、グラフをアニメーションなしで描きます。
- 強制カラーモード（Windows のハイコントラスト）ではグラフを描かず、表を開いたままシステムの色で表示します。
- 厳格な CSP でも例外は要りません。Chart.js は CSSOM で canvas の大きさを決め、`style-src 'self'` はそれを許可します（[CSP](../csp/)）。

## チェッカーが報告すること

`modootoday-check` は、不明な種類やオプション、直後に表がない `chart:` の行、表と `data:` の両方がある、またはどちらもない `c: chart` セクション、存在しないデータファイル、系列の値の数がラベルの数と合わないデータファイルをエラーとして報告します。数値でないセルや値は警告で、行の種類が間違っていても報告します。グラフを有効にしたとき、ビルド結果に正しい `chart:` の行だけの段落が残っていればエラーです。種類が間違った行はソースで一度だけ報告します。`modootoday.chart.src` は、バージョンを固定した https URL と `integrity`、またはサイト内のパスでなければなりません。
