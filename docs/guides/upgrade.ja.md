---
lang: ja
permalink: /ja/guides/upgrade/
source_rev: sha256:7dd06b300fcd
nav_order: 60
title: 移行とアップグレード
description: 別の Jekyll テーマからの移行、既存プロジェクトへの導入、バージョン間のアップグレード。
---
# 移行とアップグレード

> [!NOTE]
> このページは[英語の原文](../../../guides/upgrade/)の翻訳です。内容が異なる場合は英語版が優先されます。

## 別のテーマから

1. `theme:` または `remote_theme:` をこのテーマに置き換え ([インストール](../install/)を参照)、バージョンを固定します。
2. `_config.yml` で `layout: doc` を既定にするか、独自のレイアウトを残して必要な部分だけを include します。
3. ページ本文はそのままにします。GitHub アラート、表、フェンスコードはすでに動きます。できるところでは本文から生の HTML と Liquid を取り除きます。移植できないものは `modootoday-check` が一覧にします。
4. 色とフォントは CSS セレクターを上書きせず `modootoday.tokens` に移します。
5. `jekyll build` と `modootoday-check SRC _site` を実行し、報告された内容を直します。

`jekyll new` で作ったサイト(minima)は 2 か所を変えます。`_config.yml` のテーマの行と `Gemfile` のテーマの gem です。`gem "minima"` を `gem "jekyll-theme-modootoday"` に置き換えて `bundle install` を実行してください。置き換えないと Jekyll 4 は "The jekyll-theme-modootoday theme could not be found" で止まります。GitHub Pages では代わりに[インストール](../install/)の `remote_theme` の 2 行を使います。インストールの `sass: silence_deprecations` の行も加えてください。加えないと Jekyll 4 のビルドが Sass の通知を数百件出力します。ほかに直すところはありません。`layout: page` は名前が違うだけの `doc` レイアウトで、本文に見出しがなければ `title:` をページの見出しとして表示し（About ページ）、ホームページはサイト名を見出しにして記事一覧を表示し、ヘッダーは `header_pages` または `title` のある最上位のページをすべて表示し、記事にはサイトの `author:` が出ます。`modootoday-check` は `.md` のページだけを読み、`jekyll new` が作った `.markdown` ファイルごとに警告します。確認するには名前を `.md` に変えてください。`modootoday-check` はサイトにもテーマにもないレイアウトを報告し、`single`(`doc` または `post`)や `splash` などの Minimal Mistakes のレイアウトには代わりのレイアウトを示します。

よくある対応: just-the-docs の `layout: default` は `layout: doc` になります。`include note.html` タグで作ったコールアウトは `> [!NOTE]` に、HTML で書いたバッジは `` `status:available` `` のコードスパンになります。

## 既存プロジェクトへの導入

| 方法 | 使う場面 | 更新 |
|---|---|---|
| Gem (`theme:`) | サイトに `Gemfile` がある (Jekyll 4 または `github-pages` gem) | `bundle update jekyll-theme-modootoday` |
| `remote_theme:` | `Gemfile` のないクラシックな GitHub Pages | `@vX.Y.Z` タグを変える |
| コピーして取り込む | レイアウトをフォークする必要がある、または依存を追加できない | リリースのタグから `_layouts`、`_includes`、`_sass`、`assets` をコピーし、更新は手作業でマージする |

gem か、タグに固定した `remote_theme:` を推奨します。コピーで取り込んだ場合は、どのバージョンをコピーしたかを記録してください。コピーで取り込むと、変更したファイルについてはアップグレードとチェッカーの保証を失います。

## Markdown 版

Markdown 版はスタブファイル、プラグイン、ソースモードのどれかで作り、切り替えてもページ本文は変わりません。三つの方法の比較は [AI エージェント](../agents/)にあります。

## jekyll-seo-tag から移る

`jekyll-seo-tag` の代わりにキットに SEO タグを書かせるには、次のようにします。

1. `plugins:` と `Gemfile` から `jekyll-seo-tag` を削除し、`_includes/head-custom.html` から `seo` タグを削除します。
2. `modootoday:` から `seo: false` と `hreflang: true` を削除します。キットが canonical リンク、`hreflang` の alternate リンク、Open Graph を再び書きます。手で追加した alternate リンクは削除し、同じリンクが二重に出ないようにします。
3. ブラウザーのバーの色は `modootoday.theme_color` で指定します（[設定](../configuration/)を参照）。キットは既定でライト用とダーク用の `theme-color` タグを 2 つ書きます。独自の `theme-color` タグがあれば削除します。残すと 1 ページに 3 つになります。
4. キットが書くのは `twitter:card` だけです（ページに画像があれば `summary_large_image`）。`twitter:` の設定は読まないため、`twitter:site` が必要なら `_includes/head-custom.html` に meta タグで追加します。
5. 再ビルドして `modootoday-check SRC _site` を実行します。jekyll-seo-tag の JSON-LD に関する警告が消えているはずです。

## アップグレード

飛ばすすべてのバージョンについて `CHANGELOG.md` を読んでください。文書化された名前は[公開 API](../../reference/api/)にあります。アップグレード後にサイトをビルドし、`modootoday-check . _site --strict` を実行してください（ソースのフォルダー、ビルドしたサイトの順）。

| 移行元 | 移行先 | やること |
|---|---|---|
| 1.0.0 より前のリポジトリからのビルド | 1.0 | `~> 1.0` または `@v1.0.0` に固定する。 |
| 1.0 または 1.1 | 1.2 | `~> 1.2` に固定する(`remote_theme` では最新の `v1.2.x` タグ)。 |
| 1.2 | 1.3 | `~> 1.3` に固定する(`remote_theme` では `@v1.3.0`)。 |
| 1.3 | 1.4 | `~> 1.4` に固定する(`remote_theme` では `@v1.4.1`)。 |
| 1.4 | 1.5 | `~> 1.5` に固定する(`remote_theme` では `@v1.5.0`)。 |
| 1.5 | 1.6 | `~> 1.6` に固定する(`remote_theme` では `@v1.6.0`)。 |

どのアップグレードでもページの修正は不要です。各バージョンで加わったもの:

- 1.2: 新しいセクションとヒーローのオプション(`bleed:`、`reveal:`、`visual:` と組み合わせる `c: split`)。すべて任意です。
- 1.3: `reference` のサイドバー(`sidebar: true`)とパッケージ表(`packages:`)。どちらも任意です。
- 1.4: `packages_compact` と `packages_position`(任意)。`reference` ページも `doc` と同じくアラートを変換するようになりました。
- 1.5: 既定の見た目と、ページがテーマの CSS と JavaScript を読み込むしくみが変わります(下記参照)。
- 1.6: 静的な Mermaid の図(front matter の `diagrams:`、[数式と図](../../recipes/figures/math-diagrams/#静的な-mermaid-の図)を参照)、静的な数式(`modootoday.math.mode: static`、`_data/math` の MathML。[静的な数式](../../recipes/figures/math-diagrams/#静的な数式)を参照)、Markdown の表から作るグラフ(`modootoday.chart`、`c: chart`。`modootoday.chart.src` で指定したサイトの Chart.js が描画。[グラフ](../../recipes/figures/charts/)を参照)、`c: widget` や `widget:` で置く自作の custom element であるウィジェット(`modootoday.scripts` の `element:`。[ウィジェット](../../recipes/figures/widgets/)を参照)、いずれも任意。`modootoday.math.base` は、ローダーが使う自分でホストした KaTeX のパスを短くします。`modootoday-check` は JSON-LD に 1 つだけ入れ子になったオブジェクト(`offers`、`organizer` など)も検査し、問題を警告として報告します。次のメジャーバージョンからはエラーです([検査](../structured-data/#検査)を参照)。ビルドはそのまま通りますが、`--strict` では失敗します。 スターターのデモのビルドには、ショーケースのバーかピルを表示できます(`modootoday.showcase`、デモ専用の設定ファイルに書きます。[スターターのデモのショーケース](../../reference/showcase/)を参照)。このときすべてのページに `noindex` が付きます。

`##` 見出しより少ない `sections:` 項目を許していた 1.0 以前の草案を使っていたなら、残りの見出しごとに `notes` のような名前だけを足してください。今は数が一致する必要があり、`modootoday-check` がページと両方の数を報告します。

`name:` を書いた `resume` や `links` のページは、人の名前ではなくファイル名（`resume.md`）を表示していました。Jekyll がページの `name:` をファイル名に置き換えるためです。キーを `display_name:` に変えてください。変えるまではページのタイトルが表示され、`modootoday-check` が警告します。

### 1.5 の見た目

1.5 は既定のスタイルをフラットでニュートラルにします。ニュートラルなグレーの段階、不透明な 4rem のヘッダー、メニューと検索結果以外は影なし、枠線だけのアラート、浮き上がらないボタンとカード、ウェイト 600 の見出し、行の高さ 1.75 の本文です。見出しは小さくなり行が均等に分かれ（すべての幅で h1 2rem、h2 1.5rem、h3 1.25rem）、韓国語・日本語・中国語のページは言語ごとのフォントを使い、日本語はブラウザーが対応していれば文節で改行します。トークン名はそのままで、値だけが変わります。`modootoday.theme_color` のダークモードの既定値も新しいページ背景の `#0a0a0a` になります。1.4 の色、サイズ、影を残すには、トークンブリッジに以前の値を書いてください。

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (heading-weight: 650, line-height: 1.7, measure: 46rem, container: 76rem, header-height: 3.75rem,
  space-section: 3rem);
$mt-overrides: (
  foreground: #1f2328, card-foreground: #1f2328, accent-foreground: #1f2328, muted: #f6f8fa, accent: #eff2f5,
  muted-foreground: #59636e, status-planned: #59636e, code-comment: #59636e, border: #d1d9e0,
  shadow-sm: 0 1px 2px rgba(31, 35, 40, 0.06), shadow: 0 6px 20px -6px rgba(31, 35, 40, 0.16)
);
$mt-overrides-dark: (
  background: #0d1117, primary-foreground: #0d1117, foreground: #e6edf3, card-foreground: #e6edf3,
  accent-foreground: #e6edf3, muted: #1a212b, card: #1a212b, accent: #151b23, muted-foreground: #9198a1,
  status-planned: #9198a1, code-comment: #9198a1, border: #3d444d,
  shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3), shadow: 0 8px 24px -6px rgba(0, 0, 0, 0.5)
);
```

`modootoday.theme_color: {light: "#ffffff", dark: "#0d1117"}` もあわせて設定してください。ヘッダーのぼかし、アラートの帯と背景色、ボタンの浮き上がりはなくなり、自分の `site_css` でのみ戻せます。

ヘッダーはどの幅でも高さ 4rem の 1 行のままです。64rem より狭いとリンクはメニューボタン（`.mt-nav-sheet`）の中に移り、グループのリンクを行内に並べ直していた `.mt-nav-flat` はなくなりました。`.mt-nav-flat` に書いたルールは `.mt-nav-sheet` を対象にしてください。見出しには `scroll-margin-top` がなくなり、アンカーへ移動するとページの `scroll-padding-top` によってヘッダーの下に収まります。サイト名は `.mt-site-title` の中の `span.mt-site-name` になりました。長い名前は行の中で 2 行目を使い（64rem より狭いと 1 段小さい文字）、場所より長い単語はドットの後ろで（「modoo.」の次の行に「today」）、それでも収まらなければどこででも折り返します。2 行目を超える部分は文字が切れる代わりに省略記号で終わります。タイトルの `white-space` や `text-overflow` に書いたルールは `.mt-site-name` を対象にしてください。

コールアウト、引用、図も同じフラットなスタイルになります。コールアウトは内側の余白 1rem の細い枠で、種類の色は 16px のアイコンと見出しだけに付きます。本文の引用は開始側に 2px の線が付き(以前は 3px)、`c: quote` セクションは背景を塗ったカードではなく、同じ線の付いた大きめの引用になります。図、SVG の図の枠、埋め込みの角は 8px(`radius`、以前は `radius-lg`)、キャプションは 14/20 で、`.mt-illustration-tag` バッジは絵に重ならず絵の上に置かれます。コールアウトのルールはコアシートを離れて `content/inline.css` に、図と埋め込みのルールは `media/figure.css` に移り、そのどれかがあるページだけがこれらのシートを読み込みます。部分ファイルは `components/core/inline/` のパスのままなので、サイトで上書きしたファイルも引き続き効きます。`modootoday.css: bundle` ではコアシートにそのまま含まれます。

ボタン、バッジ、タブ、カードも同じフラットなスタイルになります。ボタンは高さ 40px(ヒーローでは 48px)、文字は 14/20 で太さ 500 です。主要な操作(ヒーローや `c: cta` のボタンの行の最初のリンク、マーケティングと詳細のレイアウトの最初のボタン)は無彩色で、前景色で塗り、文字は背景色です。アクセントカラーは既定では何も塗りません。アクセントカラーで塗ったボタンを残すには、サイトのスタイルシートで新しいフックを設定してください: `:root { --mt-button-primary-bg: var(--mt-primary); --mt-button-primary-fg: var(--mt-primary-foreground); }`。バッジは `accent` の塗りの上の 20px のチップで、状態のバッジは色を 6px の点で示し、リンクのバッジには下線が付かなくなりました。タブは 40px で、選択中のタブの下に 2px の前景色のバーがあります。機能カードとリンクカードはセクションに収まるだけ 16rem の列を並べ(`cols-<n>` はウィンドウではなくセクションの幅で数えます)、リンクカードはフォーカスリングをカード全体に描きます。パンくずリストでは、各矢印が前の項目の末尾に付きます。

ヒーロー、料金プラン、`c: cta` セクションもフラットになります。行動を促すセクションには色付きのパネルがなく、見出しとボタンはドキュメントページでは本文の列の開始側に、それ以外のページでは中央に置かれます。ヒーローの見出しの大きさは新しいフック `--mt-hero-title-size`(既定値 `clamp(2.5rem, 1.5rem + 3vw, 3.5rem)`)、太さは 600 で、ラテン文字には -0.04em の字間を付け、韓国語・日本語・中国語には付けません。リード文は 18/28 で、幅は最大 36rem です。ショーケースのヒーローは同じ幅の 2 列に分かれ、文字の後ろにグラデーションではなく単色のパネルを置き、2 つ目の操作をテキストリンクで示し、48rem 未満ではシーンを全幅の 16:9 の帯にします。強制カラーモードでは写真とパネルを隠します。料金プラン(`c: pricing` と `pricing` レイアウト)は細い区切り線のある 1 つの枠付きグリッドになります。おすすめのプランは明るいセルで、上の角にラベルがあり(2px の枠線はなし)、どのプランのボタンもプランの幅いっぱいで一番下に並びます。44rem より狭いグリッドではプランを縦に積みます。月額/年額の切り替えは選んだ側を前景色で塗ります。

記事は `narrow` の幅(40rem)で 18/28(韓国語・日本語・中国語は 18/32)になり、タイトルは `clamp(2.5rem, 2rem + 2vw, 3rem)` です。タグのフッターはページのメタ情報の行の下に 2 本目の線を足さなくなりました。カバーと本文の画像は角が 8px で、細い枠線が付きます。記事カードは箱をなくし、16:9 のカバーに角と枠線があり、タイトルは 18/28・太さ 600 でホバー時に下線が付き、抜粋は 2 行で切れ、グリッドとマガジンの一覧は 18rem の列と 2rem の間隔を使います。ブログの一覧にも記事と同じパンくずリストが表示されます。

フッターは塗りがなくなり、余白が広がりました(上 3rem、下 2rem)。テーマが `_data/nav/footer.yml` からフッターを描けるようになりました([カスタマイズ](../customize/#フッター)を参照)。検索結果は一致した語を示し、エラーレイアウトはリンクだけの本文の段落をチップの行で表示します。ステータスコードは太さ 600 の前景色です(以前は太さ 800 のアクセントカラー)。

どのレイアウトも 3 つの幅のどれかを使います。本文は `measure`(45rem)、グリッドは `container`(75rem)、法的なページ・リンクページ・履歴書・検索フォームは `narrow`(40rem)です。詳細、ディレクトリ、検索、マーケティング、docs-extra のページの段落と通常のリストは、コンテナいっぱいに広がらず `measure` で止まるようになりました。4 列以上の表では 1 列目より後のコードが折り返せるので、そうした表はスクロールせずに本文の列に収まります。

### 1.5 でページがテーマを読み込むしくみ

コアシートに残るのは、トークン、基本要素のルール、ヘッダー、ナビゲーション、テーマ切り替えボタンだけです。ほかのコンポーネントは、それを使うページだけがコアシートのすぐ後に読み込むシートに移り (コード、コールアウトとバッジ、図、ページ下部のナビゲーション、ヒーロー、バナー)、コンテキストシートは `assets/css/modootoday/<group>/<name>.css` に移りました。ルールと順序は同じなので、ページの見た目は変わりません。テーマのスクリプトは `assets/js/modootoday/<group>/<name>.js` の ES モジュール (`<script type="module">`) になり、ヘッダー検索は初めて使うときに読み込みます。

- `assets/css/modootoday.scss` を上書きしている場合は、1.5 版をコピーするか、サイトのコピーを削除してください。古いコピーでもビルドはできますが、移ったコンポーネントがコアシートにも残り、ページがそのルールを 2 回読み込みます。
- テーマのシートやスクリプトを手で読み込んでいる場合 (`head-custom.html` など) は、新しいパスを使い、スクリプトには `type="module"` を付けてください。
- サイトのスタイルシートがテーマのコンポーネントを上書きする場合は、`site_css` で読み込んでください。常にすべてのテーマシートの後に来ます。
