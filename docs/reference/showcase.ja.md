---
lang: ja
permalink: /ja/reference/showcase/
source_rev: sha256:91d858b34d4d
nav_order: 30
title: スターターのデモのショーケース
description: スターターのライブデモにテーマ名とドキュメントへのリンクを載せたバーかピルを表示し、コピーしたサイトには出さない方法を説明します。
---
# スターターのデモのショーケース

[設定](../../guides/configuration/)の表の 1 行である `modootoday.showcase` の設定を、ここで詳しく説明します。

> [!NOTE]
> このページは[英語の原文](../../../reference/showcase/)の翻訳です。内容が異なる場合は英語版が優先されます。

スターターのライブデモには、テーマとスターターの名前を示し、テーマのドキュメントへ戻るリンクを載せたバーを表示できます。このバーはデモのビルド専用です。デモのデプロイだけが `_config.yml` に重ねる 2 つ目の設定ファイルに書けば、スターターから作ったサイトには表示されません。GitHub Pages のビルダーは `_config.yml` しか読まないため、このビルダーを使うワークフローではビルドの前にデモのファイルを `_config.yml` に統合します。テーマのスターターは `if: github.repository == '<owner>/<repo>'` の条件が付いたワークフローのステップでこれを行うため、フォークやテンプレートから作ったリポジトリはショーケースなしでビルドされます。

```yaml
# _config.demo.yml: jekyll build --config _config.yml,_config.demo.yml
modootoday:
  showcase:
    enabled: true
    style: bar            # bar (default) or pill
    starter: blog         # names the starter in the label
    docs_url: https://modootoday.github.io/jekyll-theme-modootoday/
    use_url: https://github.com/<owner>/<repo>/generate   # optional
```

クラシックの GitHub Pages では、GitHub Actions のワークフローでビルドし（Settings > Pages > Source: GitHub Actions）、ビルダーが動く前に条件付きのステップでファイルを統合します。次はスターターの `pages.yml` が使うステップです。ビルドの次のステップが `_config.yml` を元に戻すので、続く検査はサイト自身の設定を見ます。

```yaml
# .github/workflows/pages.yml: steps of the build job, around the build
- name: Layer the demo config
  if: github.repository == '<owner>/<repo>'
  run: |
    cp _config.yml "$RUNNER_TEMP/_config.yml"
    ruby -ryaml -rdate -e '
      read = ->(f) { YAML.safe_load_file(f, permitted_classes: [Date, Time], aliases: true) || {} }
      merge = ->(a, b) { a.merge(b) { |_, x, y| x.is_a?(Hash) && y.is_a?(Hash) ? merge.(x, y) : y } }
      File.write("_config.yml", YAML.dump(merge.(read.("_config.yml"), read.("_config.demo.yml"))))'
- uses: actions/jekyll-build-pages@v1   # the classic GitHub Pages builder
  with:
    source: .
    destination: ./_site
- name: Restore _config.yml
  if: github.repository == '<owner>/<repo>'
  run: mv "$RUNNER_TEMP/_config.yml" _config.yml
```

- **バー**(`style: bar`、既定): ヘッダーの上に 44 px のバーを置き、テーマ名、スターター名、ドキュメントへのリンク、このスターターで始めるリンク(`use_url` があるとき)、非表示にするボタンを並べます。固定ヘッダーとアンカー先のオフセットはバーの高さだけ下がります。40rem(640 px)より狭い画面では、テーマ名、ドキュメントへのリンク、ボタンだけが残ります。スマートフォンを横に持ったときや 200% に拡大したときなど、ウィンドウの高さが 30rem(480 px)未満になると、バーはページと一緒にスクロールします。
- **ピル**(`style: pill`): 画面下の中央に浮かぶピルに、テーマ名、スターター名、ドキュメントへのリンク、ボタンを並べます。ページの下に余白を取るため、ピルが最後の行、トップへ戻るリンク、セーフエリアを隠すことはありません。
- **色**はページの配色を反転したものです。明るいページには暗いバー、暗いページには明るいバーを表示します。`brand` トークンはマークにだけ使います。
- **リンク**は設定からだけ読み込みます。新しいウィンドウで開き、矢印を表示し、名前でもそのことを伝えます。
- **フォーカスの順序**: ショーケースは「テーマのショーケース」という名前の領域で、そのリンクは「本文へスキップ」のすぐ後に来ます。
- **非表示**はそのタブでの訪問が終わるまで続きます(`sessionStorage`)。`<head>` の小さなスクリプトがページを描く前にこの値を読むため、次のページにはバーもその余白もなく、表示がずれることもありません。JavaScript がないときやストレージが使えないときは、ショーケースはそのまま残ります。
- **検索エンジン**: ショーケースを有効にすると、すべてのページに `<meta name="robots" content="noindex">` が付きます。デモのサンプルの文章は、スターターから作ったどのサイトも最初に持つ文章だからです。サイトマップにはページが残りますが noindex が優先され、デモのビルドの Lighthouse SEO 監査はページがインデックスから除外されていると報告します。
- **ラベル**はページの言語に従います。`starter` は `showcase.starters.<name>` のラベルを選び、テーマには `docs`、`blog`、`landing` があります。ほかのスターターでは `_data/i18n/<lang>.yml` にそのキーを追加してください。ない場合、ラベルにはテーマ名だけが表示されます。
- `modootoday-check` は `_config.yml` と `_config.demo.yml` のキーを検査し、`_config.yml` 自体で有効にすると警告し、ショーケースが表示されるビルドでは noindex のタグがないページも警告します。`_config.demo.yml` があっても、それなしでビルドしたサイトには警告しません。
