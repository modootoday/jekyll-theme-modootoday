---
title: 翻訳ルール
nav_order: 90
description: 韓国語・日本語のドキュメントと UI 文言の正式なスタイルルール、用語集、チェック。
---
# 翻訳ルール

> [!NOTE]
> このページは[英語版](../../../guides/translation/)の翻訳です。内容が異なる場合は英語版が優先されます。

原文は英語です。韓国語（`ko`）と日本語（`ja`）のページ、`README.ko.md`、サンプルサイト、`i18n/<code>.yml` の UI カタログは英語をローカライズしたものです。ルールはこのページだけで、`i18n/glossary.yml` が機械可読の用語集、`script/i18n-build --check` が両方を検査します。

## 原則

- 英語ページの内容を足したり削ったりせずに伝えます。食い違う場合は英語が優先され、翻訳を直します。
- 直訳せず、ローカライズします。日本語のテクニカルライターが最初から書いたように、語順と文の長さを整え、英語式の名詞の連続をほどきます。
- 一つの概念には一つの語を使います。どのページでも用語集の語をそのまま使います。
- 一部の開発者だけが使う言葉より標準的な語を選びます。
- 識別子はそのまま残します。コード、インラインコード、パス、Liquid、front matter のキーとテーマが読む値、コンポーネント名とセクション名、バッジの値、CSS クラス、`--mt-*` トークン、設定キー、コマンド、URL、製品名、`[!NOTE]` などのマーカーが対象です。

## 文体

| 文章 | 韓国語 | 日本語 |
|---|---|---|
| ドキュメント、README、リポジトリの記事 | 합니다체（案内には ~하세요 も可） | です・ます |
| UI の文（`i18n/*.yml`） | 해요체 | です・ます |
| ラベル、ボタン、見出し | 名詞句 | 体言止め |
| 表のセル、リストの断片 | 名詞句または 합니다체 | 体言止めまたは常体 |
| サンプルページ（`noindex: true`） | ジャンル本来の文体 | ジャンル本来の文体 |

1 ページの中で文体を混ぜません。

## 日本語

- JTF 日本語標準スタイルガイドの表記に従います。-er、-or、-ar で終わる外来語は長音を付けます：サーバー、ブラウザー、フォルダー、パラメーター、ヘッダー、フッター、ユーザー。
- 翻訳調を避けます：「〜を持つ」「〜することが可能です」「〜によって行われる」。代わりに「〜がある」「〜できます」、能動態を使います。
- 本文では全角の 、。（）「」 を使います。日本語とラテン文字・インラインコードの間には半角スペースを 1 つ入れます。JTF は入れませんが、このサイトではコードの隣の読みやすさのために入れます。

## 韓国語

- 標準の綴りと分かち書き（国立国語院）に従います。
- 「~를 가진」「~에 의해」「되어지다」などの翻訳調を避けます。
- 助詞はコードに続けて書き、読みの音に合わせます：`theme`을、`index.md`를。

## 数字と日付

ASCII の数字と言語ごとの桁区切り（1,000）を使います。本文の日付は 2026年10月30日、2026년 10월 30일 と書き、機械が読む日付は ISO 8601 のままにします。バージョンと単位は英語と同じです（`1.0.0`、360 px）。

## 主な用語

避ける表現を含む全体の一覧は `i18n/glossary.yml` にあります。

| 英語 | 韓国語 | 日本語 | 避ける表現 |
|---|---|---|---|
| Markdown twin | Markdown 버전 | Markdown 版 | 쌍둥이, 트윈, ツイン, 双子 |
| front matter | front matter | front matter | 머리말, 프런트 매터, フロントマター |
| include | include | include | 인클루드, インクルード |
| breadcrumb | 이동 경로 | パンくずリスト | 브레드크럼, ブレッドクラム |
| checker | 검사기 | チェッカー | 체커 |
| navigation | 내비게이션 | ナビゲーション | 네비게이션 |
| repository | 저장소 | リポジトリ | 레포지토리 |
| screen reader | 스크린 리더 | スクリーンリーダー | 화면 낭독기 |
| component | 컴포넌트 | コンポーネント | 部品 |

## UI 文言

カタログは `i18n/en.yml` のすべてのキーとプレースホルダー（`[n]`、`[total]`、`[section]`、`%{x}`）を保ち、値だけを変えます。ラベルは短い名詞句にします。編集したら `script/i18n-build` を実行して Liquid カタログを再生成します。

## チェック項目

`script/i18n-build --check` は `script/i18n/lint.rb` を実行し、次の場合に失敗します。

- カタログ：欠けたキーや未知のキー、空の値、前後の空白、プレースホルダーの不一致、韓国語 UI 文の 합니다체
- 韓国語・日本語のページ、README、記事、サンプルページ（コードを除く）：避ける用語、翻訳調、誤った文体（韓国語ドキュメントの 해요체・한다체、日本語本文の常体）、未翻訳の英文

語順、慣用表現、語調などチェックで判断できない点は、レビューでこのページを基準に確認します。

## ほかの言語

残りの 20 のカタログも同じ原則に従います。ネイティブのレビュアーが承認した用語から、その言語の列を用語集に加えます。

## 参考資料

- [Microsoft localization style guides](https://learn.microsoft.com/globalization/reference/microsoft-style-guides) (Korean and Japanese)
- [MDN translated content guidelines](https://github.com/mdn/translated-content) and the Korean team notes
- [Mozilla Korean style guide](https://mozilla-l10n.github.io/styleguides/ko/)
- [JTF 日本語標準スタイルガイド](https://www.jtf.jp/tips/styleguide)
- [Toss technical writing guide](https://technical-writing.dev/)
- [국립국어원 한국어 어문 규범](https://kornorms.korean.go.kr/)
- [Google developer documentation style guide](https://developers.google.com/style)
- [W3C Internationalization](https://www.w3.org/International/)
