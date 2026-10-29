---
title: 移行とアップグレード
description: 別の Jekyll テーマからの移行、既存プロジェクトへの導入、バージョン間のアップグレード。
---
# 移行とアップグレード

> [!NOTE]
> このページは[英語の原文](../../upgrade/)の翻訳です。内容が異なる場合は英語版が優先されます。

## 別のテーマから

1. `theme:` または `remote_theme:` をこのテーマに置き換え ([インストール](../install/)を参照)、バージョンを固定します。
2. `_config.yml` で `layout: doc` を既定にするか、独自のレイアウトを残して必要な部分だけをインクルードします。
3. ページ本文はそのままにします。GitHub アラート、表、フェンスコードはすでに動きます。できるところでは本文から生の HTML と Liquid を取り除きます。移植できないものは `modootoday-check` が一覧にします。
4. 色とフォントは CSS セレクターを上書きせず `modootoday.tokens` に移します。
5. `jekyll build` と `modootoday-check SRC _site` を実行し、報告された内容を直します。

よくある対応: minima の `layout: page` と just-the-docs の `layout: default` は `layout: doc` になります。`include note.html` タグで作ったコールアウトは `> [!NOTE]` に、HTML で書いたバッジは `` `status:available` `` のコードスパンになります。

## 既存プロジェクトへの導入

| 方法 | 使う場面 | 更新 |
|---|---|---|
| Gem (`theme:`) | サイトに `Gemfile` がある (Jekyll 4 または `github-pages` gem) | `bundle update jekyll-theme-modootoday` |
| `remote_theme:` | `Gemfile` のないクラシックな GitHub Pages | `@vX.Y.Z` タグを変える |
| コピーして取り込む | レイアウトをフォークする必要がある、または依存を追加できない | タグ付きリリースから `_layouts`、`_includes`、`_sass`、`assets` をコピーしてバージョンを記録する。更新は手作業でマージする |

gem か、タグに固定した `remote_theme:` を推奨します。コピーで取り込むと、変更したファイルについてはアップグレードとチェッカーの保証を失います。

## Markdown ツイン

各ページのエージェント向けツインを公開する方法を三つから選びます。

- **スタブファイル** (既定、クラシックな GitHub Pages): ページごとに小さな `<page>.md.txt` を一つ。
- **プラグイン** (Jekyll 4 または GitHub Actions): `plugins: [jekyll-theme-modootoday]` がスタブなしでツインと `llms.txt` を作ります。
- **ソースモード** (クラシックな GitHub Pages、スタブなし): front matter のないページで `modootoday.twins: source` を使います。2026-10-30 に確認したクラシックな Pages サイトでは、生のコピーがソースとバイト単位で同一のまま `text/markdown; charset=utf-8` として配信されました (サンプル 1 件。制限は RULES.md §5a を参照)。

切り替えてもページ本文は変わりません。[エージェント](../agents/)と `RULES.md` の 5a 節を参照してください。

## アップグレード

飛ばすすべてのバージョンについて `CHANGELOG.md` を読んでください。1.0 まではマイナーバージョンでルールが変わることがあります。1.0 以降はメジャーバージョンでのみ変わります ([公開 API](../api/)を参照)。

| 移行元 | 移行先 | やること |
|---|---|---|
| 任意の 0.x | 0.5 | 最初の公開リリース。`~> 0.5` または `@v0.5.0` に固定する |
| 0.x | 1.0 | 自分の CSS の `md-*` クラスと `--md-*` プロパティを `mt-*` と `--mt-*` に置き換える (1.x の間はチェッカーの警告付きで動作する)。`modootoday-check --strict` を実行する |
| 1.x | 2.0 | `md-*` の別名が削除される |

### `md-*` から `mt-*` へ

`md-*` クラスと `--md-*` カスタムプロパティは 1.0 で非推奨になり、2.0 で削除されます。サイト独自の Sass、CSS、インクルード、レイアウト、ページがこれらを使っていると `modootoday-check` が警告し (コードブロックは無視)、`--strict` で警告がエラーになります。各名前を対応する `mt-*` に置き換えてください。存在するのは以下の名前だけで、テーマにほかの `md-*` の名前はありませんでした。

サイトを `grep -rnE '(\.|class=.*)md-[a-z]|--md-' _sass _includes _layouts assets` で検索します。

クラス:

| 旧 | 新 |
|---|---|
| `.md-body` | `.mt-body` |
| `.md-header` | `.mt-header` |
| `.md-site-title` | `.mt-site-title` |
| `.md-skip` | `.mt-skip` |
| `.md-main` | `.mt-main` |
| `.md-doc` | `.mt-doc` |
| `.md-hero` | `.mt-hero` |
| `.md-section` | `.mt-section` |
| `.md-c-<c>` | `.mt-c-<c>` |
| `.md-cta` | `.mt-cta` |
| `.md-prose` | `.mt-prose` |
| `.md-callout` | `.mt-callout` |
| `.md-callout-<type>` | `.mt-callout-<type>` |
| `.md-callout-title` | `.mt-callout-title` |
| `.md-badge` | `.mt-badge` |
| `.md-badge-<value>` | `.mt-badge-<value>` |

カスタムプロパティ:

| 旧 | 新 |
|---|---|
| `--md-font-sans` | `--mt-font-sans` |
| `--md-font-mono` | `--mt-font-mono` |
| `--md-font-size` | `--mt-font-size` |
| `--md-line-height` | `--mt-line-height` |
| `--md-measure` | `--mt-measure` |
| `--md-space` | `--mt-space` |
| `--md-radius` | `--mt-radius` |
| `--md-bg` | `--mt-background` |
| `--md-bg-subtle` | `--mt-muted` |
| `--md-fg` | `--mt-foreground` |
| `--md-fg-muted` | `--mt-muted-foreground` |
| `--md-border` | `--mt-border` |
| `--md-accent` | `--mt-primary` |
| `--md-accent-fg` | `--mt-primary-foreground` |
| `--md-focus` | `--mt-ring` |
| `--md-note` | `--mt-note` |
| `--md-tip` | `--mt-tip` |
| `--md-important` | `--mt-important` |
| `--md-warning` | `--mt-warning` |
| `--md-caution` | `--mt-caution` |
| `--md-available` | `--mt-status-available` |
| `--md-partial` | `--mt-status-partial` |
| `--md-planned` | `--mt-status-planned` |

`--md-*` では `bg-subtle`、`fg`、`accent` などの名前は接頭辞だけでなく名前自体が変わっています。右列の `mt-` の名前は[公開 API](../api/)の一部です。
