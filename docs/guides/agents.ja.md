---
lang: ja
permalink: /ja/guides/agents/
source_rev: sha256:4ed66d6e6b1e
nav_order: 50
nav_title: AI 向け
title: エージェント向け
description: AI エージェントのための Markdown 版、URL エイリアス、llms.txt、llms-full.txt。
sections:
  - twins
  - aliases
  - llms
---
# エージェントが読める Markdown

すべてのページは 2 回公開されます。人のための HTML と、エージェントのための元の Markdown です。

> [!NOTE]
> このページは[英語の原文](../../../guides/agents/)の翻訳です。内容が異なる場合は英語版が優先されます。

## Markdown 版

`guide.md` というページは `/guide/index.md` でも配信され、その内容は本文とバイト単位で同一です。Jekyll 4 ではテーマのプラグインが Markdown 版を自動で作ります。

```yaml
plugins: [jekyll-theme-modootoday]
```

クラシックな GitHub Pages ビルドはプラグインを実行できないので、代わりに各ページの隣にスタブを置きます。

```yaml
# guide.md.txt
---
layout: twin
twin_of: guide.md
permalink: /guide/index.md
---
```

`twin_of` はスタブファイルからの相対パスです（`include_relative` で読み込みます）。スタブはページと同じフォルダーに置くか、`../` のパスを使ってください。サイトのソースの外や `_` フォルダーは指せません。

```yaml
# guides/install.md の隣のスタブ guides/install.md.txt
twin_of: install.md          # 正しい: スタブからの相対パス
twin_of: guides/install.md   # 誤り: サイトのルートからのパスは "Could not locate the included file" のエラーになります
```

各 HTML ページは `rel="alternate" type="text/markdown"` で Markdown 版にリンクします。

スタブは `modootoday-stubs` が書きます。`--write` を付けなければ、作成、更新、削除するファイルを表示するだけです。CI では、スタブがない、内容が古い、ページを消した後に残っている、のいずれかで `--check` が失敗します。

```sh
modootoday-stubs . --twins           # list missing, stale and orphan stubs
modootoday-stubs . --twins --write   # write them
modootoday-stubs . --twins --check   # CI: exit 1 when anything would change
```

## URL エイリアス

エージェントによっては `/guide/` ではなく `/guide.md` や `/guide.html` を求めます。使うエイリアスを `_config.yml` で宣言します。

```yaml
modootoday:
  aliases: {md: true, html: true}
```

次に `modootoday-stubs . --aliases --write` が、URL がディレクトリのページごとに最大 2 つのスタブを作ります（ホームページにはありません）。

- `guide.flat.md.txt` は同じ Markdown 版を `/guide.md` でも同じバイトで配信します。
- `guide.html.md.txt` は `redirect` レイアウトを使います。`/guide.html` は meta refresh で `/guide/` に移動させ、`/guide/` を canonical とし、`noindex` なので検索エンジンに残る URL は 1 つです。プラグインもスクリプトも不要なので、クラシックな GitHub Pages や厳格な CSP でも動きます。

`modootoday-check . _site --aliases` は、すべてのエイリアスがビルドにあり、そのページを指しているかを確認します。2 つのページが同じエイリアスを使う場合や、エイリアスが別のファイルのパスと重なる場合はエラーです。front matter のないページがすでに `/guide.md` で配信される `twins: source` とは、`.md` エイリアスを併用できません。

## llms.txt

`/llms.txt` は [llmstxt.org](https://llmstxt.org) に従って、ある言語のすべてのページを一覧にします。`/llms-full.txt` はすべてのページ本文をつなげたものです。プラグインが両方を追加します。従来の GitHub Pages では、サイトのルートに front matter だけを書いた 2 つのファイル `llms.txt` と `llms-full.txt` から作ります。

```yaml
# llms.txt（llms-full.txt は layout: llms-full にして同じように）
---
layout: llms
---
```

ページのあるほかの言語ごとに、その言語のフォルダーに同じ 2 つのファイルを置き、`lang:` を書きます。たとえば `ko/llms.txt` には `layout: llms` と `lang: ko` を書きます。足りないファイルは `modootoday-check --twins` が知らせます。

このサイトで試せます: [llms.txt](../../llms.txt) と [llms-full.txt](../../llms-full.txt)。
